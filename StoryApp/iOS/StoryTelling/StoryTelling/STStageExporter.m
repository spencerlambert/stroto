//
//  STStageExporter.m
//  StoryTelling
//
//  Created by Aaswini on 27/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStageExporter.h"
#import "STImageInstancePosition.h"
#import "STStageExporterFrame.h"
#import "STImage.h"
#import <AVFoundation/AVFoundation.h>


@implementation STStageExporter{
    
    NSArray *timeline;
    NSArray *instanceIDs;
    
    STStageExporterFrame *previousFrame;
    STImage *currentBGImage;
    
    NSMutableDictionary *frames;
    
    NSDictionary *instanceIDTable;
    NSDictionary *imagesTable;
    
}

@synthesize storyDB, dbname;

-(void)initDB{
    if (storyDB != nil) {
        [storyDB closeDB];
        storyDB = nil;
    }
    storyDB = [STStoryDB loadSTstoryDB:self.dbname];
    [self initialize];
    frames = [[NSMutableDictionary alloc]init];
}

- (void) initialize{
    timeline = [storyDB getImageInstanceTimeline];
    instanceIDs = [storyDB getInstanceIDsAsString];
    currentBGImage = [[STImage alloc] initWithCGImage:[UIImage imageNamed:@"RecordArea.png"].CGImage];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
    imagesTable = [storyDB getImagesTable];
    
    previousFrame = [[STStageExporterFrame alloc]initWithInstances:instanceIDs];
    [previousFrame setInstanceIDTable:instanceIDTable];
    [previousFrame setImagesTable:imagesTable];
}

-(void)generateMovie{
    
    [self generateFrames];
    [self processFrames];
    [self processAudio];
    
}

- (void) generateFrames{
    for (int i=0; i<[timeline count]; i++) {
        STImageInstancePosition *position =timeline[i];
        if ([self isInstanceBG:position.imageInstanceId]) {
            STStageExporterFrame *currentFrame = [[STStageExporterFrame alloc] initWithSTStageExporterFrame:previousFrame];
            int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];
            [currentFrame addBGImage:[imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]]];
            [frames setValue:currentFrame forKey:[NSString stringWithFormat:@"%f",position.timecode]];
            previousFrame = [[STStageExporterFrame alloc] initWithSTStageExporterFrame:currentFrame];
        }
        else{
            if (position.layer != -1) {
                STStageExporterFrame *currentFrame = [[STStageExporterFrame alloc] initWithSTStageExporterFrame:previousFrame];
                //                int imageID = [instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]];
                //                [currentFrame addFGImage:[imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]] withInstanceID:position.imageInstanceId];
                [currentFrame addFGImage:position withInstanceID:position.imageInstanceId];
                [frames setValue:currentFrame forKey:[NSString stringWithFormat:@"%f",position.timecode]];
                previousFrame = [[STStageExporterFrame alloc] initWithSTStageExporterFrame:currentFrame];
            }
            else{
                STStageExporterFrame *currentFrame = [[STStageExporterFrame alloc] initWithSTStageExporterFrame:previousFrame];
                [currentFrame removeFGImageWithInstanceID:position.imageInstanceId];
                [frames setValue:currentFrame forKey:[NSString stringWithFormat:@"%f",position.timecode]];
                previousFrame = [[STStageExporterFrame alloc] initWithSTStageExporterFrame:currentFrame];
            }
        }
    }
}

- (void) processFrames{
    NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    float width = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(width,width); //[storyDB getStorySize];
     NSArray * sortedKeys = [[frames allKeys] sortedArrayUsingSelector: @selector(localizedStandardCompare:)];
    for (NSString *timecode in sortedKeys) {
        STStageExporterFrame *frame  = [frames objectForKey:timecode];
        [images setValue:[frame getImageforFrame:size] forKey:timecode];
    }
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *videoAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/videoAssets"];
    if([filemanager fileExistsAtPath:videoAssetPath]){
        [filemanager removeItemAtPath:videoAssetPath error:nil];
    }
    [filemanager createDirectoryAtPath:videoAssetPath withIntermediateDirectories:YES attributes:nil error:nil];
    [self writeImagesAsMovie:images toPath:[videoAssetPath stringByAppendingPathComponent:@"storyVideo.mp4"] size:size];
    
}

- (void)processAudio{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *audioAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/audioAssets"];
    if([filemanager fileExistsAtPath:audioAssetPath]){
        [filemanager removeItemAtPath:audioAssetPath error:nil];
    }
    [filemanager createDirectoryAtPath:audioAssetPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSArray *audioArray = [storyDB getAudioInstanceTimeline];
    for (int i=0; i<[audioArray count]; i++) {
        STAudio *audio = [audioArray objectAtIndex:i];
        NSString* audioFilePath = [audioAssetPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/audioAsset-%d.caf",i]];
        [audio.audio writeToFile:audioFilePath atomically:YES];
    }

}

-(BOOL)isInstanceBG:(int)instanceID{
    int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",instanceID]] intValue];
    STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
    if ([image.type isEqualToString:@"background"]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)writeImagesAsMovie:(NSDictionary *)images toPath:(NSString*)path size:(CGSize)size
{
    
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    
    
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey,
                                   nil];
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings] ;
    
    
    // NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:nil];
    
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    [videoWriter addInput:writerInput];
    
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    
    //Write samples:
    NSArray * sortedKeys = [[images allKeys] sortedArrayUsingSelector: @selector(localizedStandardCompare:)];
    for ( NSString *timecode in sortedKeys) {
        
        UIImage *image = [images objectForKey:timecode];
        //        NSData *pngData = UIImagePNGRepresentation(image);
        //        [pngData writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[timecode stringByAppendingPathExtension:@".png"]] atomically:YES];
        int time = [timecode intValue];
        buffer = [self pixelBufferFromCGImage:image.CGImage];
        while(! adaptor.assetWriterInput.readyForMoreMediaData );
        [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(time,1000)];
    }
    
    while(!adaptor.assetWriterInput.readyForMoreMediaData);
    
    //[videoWriter endSessionAtSourceTime:CMTimeMakeWithSeconds([[[images lastObject] objectForKey:@"time"] intValue], 1000)];
    
    //Finish the session:
    [writerInput markAsFinished];
    
    [videoWriter finishWritingWithCompletionHandler:^(){
        NSLog (@"finished writing");
    }];
    
    while([videoWriter status] != AVAssetWriterStatusFailed && [videoWriter status] != AVAssetWriterStatusCompleted) {
        NSLog(@"Status: %d", [videoWriter status]);
        sleep(1);
    }
    
}




- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, screenWidth,
                                          screenWidth, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context1 = CGBitmapContextCreate(pxdata, screenWidth,
                                                  screenWidth, 8, 4*screenWidth, rgbColorSpace,
                                                  kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context1);
    CGContextConcatCTM(context1, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context1, CGRectMake(0, 0, screenWidth,
                                            screenWidth), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context1);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}


@end

