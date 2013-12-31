//
//  STStagePlayer.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStagePlayer.h"
#import "STImageInstancePosition.h"


@implementation STStagePlayer{
    
    NSArray *timeline;
    NSArray *instanceIDs;
    
    STStagePlayerFrame *previousFrame;
    STImage *currentBGImage;
    
    NSMutableDictionary *frames;
    
    NSDictionary *instanceIDTable;
    NSDictionary *imagesTable;
    
}


-(id)initWithDB:(STStoryDB *)db{
    self = [super init];
    if(self){
        storyDB = db;
        [self initialize];
        frames = [[NSMutableDictionary alloc]init];
    }
    return  self;
}

- (void) initialize{
    timeline = [storyDB getImageInstanceTimeline];
    instanceIDs = [storyDB getInstanceIDsAsString];
    currentBGImage = [[STImage alloc] initWithCGImage:[UIImage imageNamed:@"RecordArea.png"].CGImage];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
    imagesTable = [storyDB getImagesTable];
    
    previousFrame = [[STStagePlayerFrame alloc]initWithInstances:instanceIDs];
    [previousFrame setInstanceIDTable:instanceIDTable];
    [previousFrame setImagesTable:imagesTable];
}

-(void)generateMovie{
    
    [self generateFrames];
    [self processFrames];
}

- (void) generateFrames{
    for (int i=0; i<[timeline count]; i++) {
        STImageInstancePosition *position =timeline[i];
        if ([self isInstanceBG:position.imageInstanceId]) {
            STStagePlayerFrame *currentFrame = [[STStagePlayerFrame alloc] initWithSTStagePlayerFrame:previousFrame];
            int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];;
            [currentFrame addBGImage:[imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]]];
            [frames setValue:currentFrame forKey:[NSString stringWithFormat:@"%f",position.timecode]];
            previousFrame = [[STStagePlayerFrame alloc] initWithSTStagePlayerFrame:currentFrame];
        }
        else{
            if (position.layer != -1) {
                STStagePlayerFrame *currentFrame = [[STStagePlayerFrame alloc] initWithSTStagePlayerFrame:previousFrame];
//                int imageID = [instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]];
//                [currentFrame addFGImage:[imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]] withInstanceID:position.imageInstanceId];
                [currentFrame addFGImage:position withInstanceID:position.imageInstanceId];
                [frames setValue:currentFrame forKey:[NSString stringWithFormat:@"%f",position.timecode]];
                previousFrame = [[STStagePlayerFrame alloc] initWithSTStagePlayerFrame:currentFrame];
            }
            else{
                STStagePlayerFrame *currentFrame = [[STStagePlayerFrame alloc] initWithSTStagePlayerFrame:previousFrame];
                [currentFrame removeFGImageWithInstanceID:position.imageInstanceId];
                [frames setValue:currentFrame forKey:[NSString stringWithFormat:@"%f",position.timecode]];
                previousFrame = [[STStagePlayerFrame alloc] initWithSTStagePlayerFrame:currentFrame];
            }
        }
    }
}

- (void) processFrames{
    NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    CGSize size = [storyDB getStorySize];
    for (NSString *timecode in frames) {
        STStagePlayerFrame *frame  = [frames objectForKey:timecode];
        [images setValue:[frame getImageforFrame:size] forKey:timecode];
//        UIImage *testimage = [frame getImageforFrame:size];
//        NSData *pngData = UIImagePNGRepresentation(testimage);
//        [pngData writeToFile:[NSTemporaryDirectory() stringByAppendingPathComponent:[timecode stringByAppendingPathExtension:@".png"]] atomically:YES];
    }
    [self writeImagesAsMovie:images toPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"test.mp4"] size:size];
    
    
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
    for ( NSString *timecode in images) {
        
        UIImage *image = [images objectForKey:timecode];
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
