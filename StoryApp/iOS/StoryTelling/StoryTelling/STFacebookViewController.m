//
//  STFacebookViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 04/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STFacebookViewController.h"
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>
#import "SavedStoryDetailsViewController.h"

#define ST_FACEBOOK_APP_ID @"530535203701796"
#define title_screen_sec 5

@interface STFacebookViewController ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic, retain) ACAccountStore *accountStore;
@property (nonatomic, retain) ACAccount *facebookAccount;

@end

@implementation STFacebookViewController{
    
    
    NSString *videoAssetPath;
    NSString *audioAssetPath;
    
    NSString *uploadDirPath;
    NSString *titleVideoPath;
}

@synthesize storyTitle;
@synthesize storySubTitle;
@synthesize uploadButton;
@synthesize uploadProgressBar;
@synthesize filepath;
@synthesize storySubTitleString;
@synthesize storyTitleString;
@synthesize spinningWheel;
@synthesize greyBGButton;
@synthesize listViewiPad;
@synthesize storyListiPad;

bool writingFinished;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.iQuit1 = NO;
//    self.dbname = [[filepath lastPathComponent]stringByDeletingPathExtension];
    
    self.uploadProgressBar.progress = 0.0f;
    
    self.storyTitle.text = storyTitleString;
    self.storySubTitle.text = storySubTitleString;
    
    [self.listViewiPad setListDelegate:self];
    [self.listViewiPad setIndex:storyListiPad.index];
    
    storyListiPad = nil;
    
    [self.listViewiPad reloadInputViews];
    
    //social framework ios
    if(!_accountStore)
        _accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    //read request
    [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                           options:@{ACFacebookAppIdKey: ST_FACEBOOK_APP_ID, ACFacebookPermissionsKey: @[@"basic_info"]}
                                        completion:^(BOOL granted, NSError *error) {
                                            if(granted){
                                                NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];
                                                _facebookAccount = [accounts lastObject];
                                                NSLog(@"Read Success");
                                                //do nothing, as here we dont want user info.
                                            }else{
                                                // ouch
                                                NSLog(@"Fail");
                                                NSLog(@"Error: %@", error);
                                            }
                                        }];
    
    uploadDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/upload_dir"];
    titleVideoPath = [uploadDirPath stringByAppendingPathComponent:@"titleVideo.mp4"];
    videoAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/videoAssets"];
    audioAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/audioAssets"];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[CreateStoryRootViewController class]])
    {
        ((CreateStoryRootViewController*)segue.destinationViewController).myDelegate = self;
        AppDelegate *newstoryFlag = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [newstoryFlag setIsNewStory:@"true"];
    }
}

-(void)iQuit{
    self.iQuit1 = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [[[(UITableView*)self.listViewiPad subviews] objectAtIndex:0] reloadData];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)upload
{
    //social framework ios
    NSURL *videourl = [NSURL URLWithString:@"https://graph.facebook.com/me/videos"];
    
    NSString* outputFileName = @"videoToUpload.mov";
    NSString* outputFilePath = [videoAssetPath stringByAppendingPathComponent:outputFileName];
    
    NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:outputFilePath isDirectory:NO];
    
    NSData *videoData = [NSData dataWithContentsOfFile:outputFilePath];
    
    NSString *desc = storySubTitle.text;
    desc = [desc stringByAppendingString:@" \n Created using : Stroto (http://www.stroto.com)"];
    
    NSDictionary *params = @{@"title": storyTitle.text,
                             @"description":desc};
    
    SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                              requestMethod:SLRequestMethodPOST
                                                        URL:videourl
                                                 parameters:params];
    NSLog(@"FILE: %@", [pathURL absoluteString]);
    [merequest addMultipartData:videoData
                       withName:@"source"
                           type:@"video/quicktime"
                       filename:[pathURL absoluteString]];
    
    merequest.account = _facebookAccount;
    NSURLRequest *request = [merequest preparedURLRequest];
    NSURLConnection *reConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [reConnect scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [reConnect start];
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float progress =(float) totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"progress :%f",progress);
    self.uploadProgressBar.progress = progress;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/upload_dir"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
    NSString *dataPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
    [[NSFileManager defaultManager] removeItemAtPath:dataPath1 error:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Video Upload Complete" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.uploadButton setEnabled:YES] ;
    [alert show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"response: %@",response);
    NSLog(@"response.expectedContentLength: %lld",response.expectedContentLength);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"error: %@",error);
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField

{
    [storyTitle resignFirstResponder];
    [storySubTitle resignFirstResponder];
    return  YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//upload button click
- (IBAction)uploadStory:(UIButton *)sender {
    
    [self.uploadButton setEnabled:NO] ;
    
    NSString *dataPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
    [[NSFileManager defaultManager] createFileAtPath:dataPath1 contents:[[NSData alloc]init] attributes:Nil];
    
    //video upload using social framework.
    ACAccountType *facebookTypeAccount = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [_accountStore requestAccessToAccountsWithType:facebookTypeAccount
                                           options:@{ACFacebookAppIdKey:ST_FACEBOOK_APP_ID, ACFacebookPermissionsKey: @[@"publish_stream"], ACFacebookAudienceKey: ACFacebookAudienceFriends}
                                        completion:^(BOOL granted, NSError *error) {
                                            if(granted){
                                                NSArray *accounts = [_accountStore accountsWithAccountType:facebookTypeAccount];
                                                _facebookAccount = [accounts lastObject];
                                                NSLog(@"Success, upload starting");
                                                
                                                [self performSelectorInBackground:@selector(showSpin) withObject:Nil];
                                                
                                                //append title to video.
                                                UIImage *temp = [UIImage imageNamed:@"TitlePage.png"];
                                                UIImage *tempi = [self drawText:storyTitle.text inImage:temp atPoint:CGPointMake(0,100) withFontsize:70];
                                                tempi = [self drawText:storySubTitle.text inImage:tempi atPoint:CGPointMake(0,350) withFontsize:50];
                                                
                                                if ([[NSFileManager defaultManager] fileExistsAtPath:uploadDirPath]){
                                                    [[NSFileManager defaultManager] removeItemAtPath:uploadDirPath error:nil];
                                                }
                                                
                                                //Create upload folder
                                                [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:NO attributes:nil error:nil];
                                                
                                                CGSize size = CGSizeMake(320, 320);//[[STStoryDB loadSTstoryDB:self.dbname] getStorySize];
                                                [self writeImageAsMovie:tempi toPath:titleVideoPath size:CGRectMake(0, 0, size.width, size.height).size duration:title_screen_sec];
                                                [self mergeVideoRecording];
                                                
                                                
                                            }else{
                                                // ouch
                                                NSLog(@"Fail");
                                                NSLog(@"Error: %@", error);
                                            }
                                        }];
    
    
}
-(void)showSpin
{
    [self.greyBGButton setHidden:NO];
    [self.spinningWheel setHidden:NO];
    [self.spinningWheel startAnimating];
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
        withFontsize:(float) size
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:size];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(void)writeImageAsMovie:(UIImage *)image toPath:(NSString*)path size:(CGSize)size duration:(int)duration
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
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    
    //Write samples:
    for (int i=0; i<duration ; i++) {
        buffer = [self pixelBufferFromCGImage:[image CGImage]];
        while(! adaptor.assetWriterInput.readyForMoreMediaData );
        [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMakeWithSeconds(i,1)];
    }
    
    while(!adaptor.assetWriterInput.readyForMoreMediaData);
    
    [videoWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(duration, 1)];
    
    //Finish the session:
    [writerInput markAsFinished];
    
    writingFinished = false;
    [videoWriter finishWritingWithCompletionHandler:^(){
        
        NSLog (@"finished writing");
        writingFinished = true;
        //[self mergeVideoRecording];
    }];
    
    while([videoWriter status] != AVAssetWriterStatusFailed && [videoWriter status] != AVAssetWriterStatusCompleted) {
        NSLog(@"Status: %d", [videoWriter status]);
        sleep(1);
    }
    
    
    
}


- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CGFloat video_size = [[UIScreen mainScreen] bounds].size.width;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, video_size,
                                          video_size, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, video_size,
                                                 video_size, 8, 4*video_size, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, video_size,
                                           video_size), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void)mergeVideoRecording{
    NSFileManager *file = [NSFileManager defaultManager];
    
    NSString* firstAsset1 = [NSString stringWithString:titleVideoPath];
    
    NSString* secondAsset1 =  [videoAssetPath stringByAppendingPathComponent:@"storyVideo.mp4"];
    NSString *outputFilePath = [videoAssetPath stringByAppendingPathComponent:@"/finalVideoOutput.mp4"];
    
    if([file fileExistsAtPath:firstAsset1]){
        
        
        NSURL *url1 = [NSURL fileURLWithPath:firstAsset1];
        AVAsset *firstAsset = [AVURLAsset URLAssetWithURL:url1 options:nil];
        NSURL *url2 = [NSURL fileURLWithPath:secondAsset1];
        AVAsset *secondAsset = [AVURLAsset URLAssetWithURL:url2 options:nil];
        
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration)
                            ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:CMTimeMakeWithSeconds(title_screen_sec,1) error:nil];
        
        
        NSURL *url = [NSURL fileURLWithPath:outputFilePath];
        
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetPassthrough];
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             NSLog(@"AVVideoAssetExportSessionStatusCompleted");
             [file removeItemAtPath:firstAsset1 error:nil];
             [file removeItemAtPath:secondAsset1 error:nil];
             [self CompileFilesToMakeMovie];
         }];
        
    }
    else{
        [file copyItemAtPath:firstAsset1 toPath:secondAsset1 error:nil];
        [self CompileFilesToMakeMovie];
    }
    
}

-(void)CompileFilesToMakeMovie
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    STStoryDB *storyDB = [[STStoryDB alloc]initWithFilename:self.dbname];
    NSArray *audioArray = [storyDB getAudioInstanceTimeline];
    NSMutableArray *audioURLs = [[NSMutableArray alloc]init];
    for (int i=0; i<[audioArray count]; i++) {
        NSString* audioFilePath = [audioAssetPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/audioAsset-%d.caf",i]];
        audioURLs[i] = [NSURL fileURLWithPath:audioFilePath];
    }
    
    NSString* video_inputFilePath = [videoAssetPath stringByAppendingPathComponent:@"/finalVideoOutput.mp4"];
    NSURL* video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
    
    NSString* outputFileName = @"videoToUpload.mov";
    NSString* outputFilePath = [videoAssetPath stringByAppendingPathComponent:outputFileName];
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:outputFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    NSMutableArray *audiourlassets = [[NSMutableArray alloc]init];
    for (int i=0; i<[audioURLs count]; i++) {
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[audioURLs objectAtIndex:i] options:nil];
        audiourlassets[i] = audioAsset;
    }
    
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    float elapsedtime = 0;
    if ([audiourlassets objectAtIndex:0]!=nil) {
        AVURLAsset *audioAsset = audiourlassets[0];
        if([[audioAsset tracksWithMediaType:AVMediaTypeAudio]count]>0){
            [b_compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:CMTimeMakeWithSeconds(title_screen_sec,1) error:nil];
        }
        elapsedtime = elapsedtime + title_screen_sec + audioAsset.duration.value;
    }
    
    for (int i=1; i<[audiourlassets count]; i++) {
        AVURLAsset *audioAsset = audiourlassets[i];
        if([[audioAsset tracksWithMediaType:AVMediaTypeAudio]count]>0){
            [b_compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:CMTimeMakeWithSeconds(elapsedtime,1) error:nil];
        }
        elapsedtime = elapsedtime + audioAsset.duration.value;
    }
    
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         [self performSelectorInBackground:@selector(stopSpin) withObject:Nil];
         [self performSelectorOnMainThread:@selector(upload) withObject:self waitUntilDone:YES];
     }];
}

-(void)stopSpin
{
    [self.spinningWheel stopAnimating];
    [self.spinningWheel setHidden:YES];
    [self.greyBGButton setHidden:YES];
    [self.uploadProgressBar setHidden:NO];
}

-(void)didSelectTableCellWithName:(NSString *)dbName
{
    for (UIViewController *view in self.navigationController.viewControllers) {
        if([view isKindOfClass:[SavedStoryDetailsViewController class]]){
            [((SavedStoryDetailsViewController*)view) setDbname:dbName];
            [((SavedStoryDetailsViewController*)view) setBarTitle];
            [[((SavedStoryDetailsViewController*)view) listiPad] setIndex:listViewiPad.index];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
