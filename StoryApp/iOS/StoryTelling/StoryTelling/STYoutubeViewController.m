//
//  STYoutubeViewController.m
//  StoryTelling
//
//  Created by Aaswini on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STYoutubeViewController.h"
#import <GTLUtilities.h>
#import <GTMHTTPUploadFetcher.h>
#import <GTMHTTPFetcherLogging.h>
#import <GTMOAuth2ViewControllerTouch.h>
#import "SavedStoryDetailsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CreateStoryRootViewController.h"
#import "STStoryDB.h"

#define title_screen_sec 5

NSString *const kKeychainItemName = @"Stroto: YouTube";
NSURL *uploadLocationURL;

@interface STYoutubeViewController ()
// Accessor for the app's single instance of the service object.
@property (nonatomic, readonly) GTLServiceYouTube *youTubeService;
@end

@implementation STYoutubeViewController{
    GTLServiceTicket *_uploadFileTicket;
}

NSString *videoAssetPath;
NSString *audioAssetPath;

NSString *uploadDirPath;
NSString *titleVideoPath;

@synthesize mainTitle,subTitle;
@synthesize greyBGButton;
@synthesize spinningWheel;
@synthesize storyList;
@synthesize listViewOutlet;
@synthesize uploadButton;

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
    [mainTitle setText:self.maintitle];
    [subTitle setText:@"by:"];
    [self.listViewOutlet setListDelegate:self];
    [self.listViewOutlet setIndex:storyList.index];
//    [self.listViewOutlet setDBNamesiPad:self.storyList.DBNamesiPad];
//    [self.listViewOutlet setStoryNamesiPad:self.storyList.storyNamesiPad];
    storyList = nil;
    [self.listViewOutlet reloadInputViews];
    // Load the OAuth 2 token from the keychain, if it was previously saved.
    //    clientID = @"283801024967.apps.googleusercontent.com";
    //    clientSecret = @"K18TEG58lqLlR1AhpBEluY2B";
    
    clientID = @"847626307960.apps.googleusercontent.com";
    clientSecret = @"hKBN9pEi7Nm7dXD740-3MHmW";
    
    GTMOAuth2Authentication *auth = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName clientID:clientID clientSecret:clientSecret];
    
    self.youTubeService.authorizer = auth;
    
    uploadDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/upload_dir"];
    titleVideoPath = [uploadDirPath stringByAppendingPathComponent:@"titleVideo.mp4"];
    videoAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/videoAssets"];
    audioAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/audioAssets"];
    
}
- (void)viewWillAppear:(BOOL)animated{
    if (![self isSignedIn]) {
        // Sign in.
        GTMOAuth2ViewControllerTouch *signin = [GTMOAuth2ViewControllerTouch controllerWithScope:kGTLAuthScopeYouTube clientID:clientID clientSecret:clientSecret keychainItemName:kKeychainItemName delegate:self finishedSelector:@selector(viewController:finishedWithAuth:error:)];
        
        [self presentViewController:signin animated:YES completion:nil];
    }else{
        [[self userName] setText:[self signedInUsername]];
        [[[(UITableView*)self.listViewOutlet subviews] objectAtIndex:0] reloadData];
       }
    
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)signedInUsername {
    // Get the email address of the signed-in user.
    GTMOAuth2Authentication *auth = self.youTubeService.authorizer;
    BOOL isSignedIn = auth.canAuthorize;
    if (isSignedIn) {
        return auth.userEmail;
    } else {
        return nil;
    }
}

- (BOOL)isSignedIn {
    NSString *name = [self signedInUsername];
    return (name != nil);
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error{
    
    if (error == nil) {
        self.youTubeService.authorizer = auth;
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        NSLog(@"ERROR : %@",error);
    }
}

- (IBAction)logout:(id)sender {
    
    // Sign out.
    GTLServiceYouTube *service = self.youTubeService;
    
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
    service.authorizer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)upload:(id)sender {
    [self.uploadButton setEnabled:NO];
    NSString *dataPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
    [[NSFileManager defaultManager] createFileAtPath:dataPath1 contents:[[NSData alloc]init] attributes:Nil];
    [self.greyBGButton setHidden:NO];
    [self.spinningWheel setHidden:NO];
    [self.spinningWheel startAnimating];
    UIImage *temp = [UIImage imageNamed:@"TitlePage.png"];
    UIImage *tempi = [self drawText:mainTitle.text inImage:temp atPoint:CGPointMake(0,100) withFontsize:70];
    tempi = [self drawText:subTitle.text inImage:tempi atPoint:CGPointMake(0,350) withFontsize:50];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:uploadDirPath]){
        [[NSFileManager defaultManager] removeItemAtPath:uploadDirPath error:nil];
    }
    
    //Create upload folder
    [[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    CGSize size = [[STStoryDB loadSTstoryDB:self.dbname] getStorySize];
    [self writeImageAsMovie:tempi toPath:titleVideoPath size:CGRectMake(0, 0, size.width, size.height).size duration:title_screen_sec];
    [self mergeVideoRecording];
}


#pragma mark - Upload

- (void)uploadVideoFile {
    // Collect the metadata for the upload from the user interface.
    
    // Status.
    GTLYouTubeVideoStatus *status = [GTLYouTubeVideoStatus object];
    status.privacyStatus = @"public";
    
    // Snippet.
    
    
    GTLYouTubeVideoSnippet *snippet = [GTLYouTubeVideoSnippet object];
    NSString *text = [mainTitle text];
    snippet.title = text;
    
    
    NSString *desc = [subTitle text];
    //if ([desc length] > 0) {
        desc = [desc stringByAppendingString:@" \n Created using : Stroto (http://www.stroto.com)"];
        snippet.descriptionProperty = desc;
    //}
    //    NSString *tagsStr = [_uploadTagsField stringValue];
    //    if ([tagsStr length] > 0) {
    //        snippet.tags = [tagsStr componentsSeparatedByString:@","];
    //    }
    //    if ([_uploadCategoryPopup isEnabled]) {
    //        NSMenuItem *selectedCategory = [_uploadCategoryPopup selectedItem];
    //        snippet.categoryId = [selectedCategory representedObject];
    //    }
    
    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
    video.status = status;
    video.snippet = snippet;
    
    [self uploadVideoWithVideoObject:video
             resumeUploadLocationURL:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [subTitle resignFirstResponder];
    [mainTitle resignFirstResponder];
    return  YES;
}


//- (void)restartUpload {
//    // Restart a stopped upload, using the location URL from the previous
//    // upload attempt
//    if (_uploadLocationURL == nil) return;
//
//    // Since we are restarting an upload, we do not need to add metadata to the
//    // video object.
//    GTLYouTubeVideo *video = [GTLYouTubeVideo object];
//
//    [self uploadVideoWithVideoObject:video
//             resumeUploadLocationURL:_uploadLocationURL];
//}

- (void)uploadVideoWithVideoObject:(GTLYouTubeVideo *)video
           resumeUploadLocationURL:(NSURL *)locationURL {
    // Get a file handle for the upload data.
    //    NSString *path = [_uploadPathField stringValue];
   
    NSString* outputFileName = @"videoToUpload.mov";
    NSString* outputFilePath = [videoAssetPath stringByAppendingPathComponent:outputFileName];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:outputFilePath];

    if (fileHandle) {
        //        NSString *mimeType = [self MIMETypeForFilename:filename
        //                                       defaultMIMEType:@"video/mp4"];
        
        NSString *mimeType = @"video/*";
        
        GTLUploadParameters *uploadParameters =
        [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                   MIMEType:mimeType];
        uploadParameters.uploadLocationURL = locationURL;
        
        GTLQueryYouTube *query = [GTLQueryYouTube queryForVideosInsertWithObject:video
                                                                            part:@"snippet,status"
                                                                uploadParameters:uploadParameters];
        
        GTLServiceYouTube *service = self.youTubeService;
        _uploadFileTicket = [service executeQuery:query
                                completionHandler:^(GTLServiceTicket *ticket,
                                                    GTLYouTubeVideo *uploadedVideo,
                                                    NSError *error) {
                                    // Callback
                                    _uploadFileTicket = nil;
                                    NSString *alert = [NSString stringWithFormat:@"Uploaded file %@",uploadedVideo.snippet.title];
                                    if (error == nil) {
                                        [self displayAlert:@"Uploaded"
                                                    format:alert];
//                                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                                        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
                                        NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/upload_dir"];
                                        NSString *dataPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
                                        if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                                            [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
                                        [[NSFileManager defaultManager] removeItemAtPath:dataPath1 error:nil];
                                         NSString* secondAsset1 =  [[NSString alloc] initWithFormat:@"%@/test.mp4", NSTemporaryDirectory()];
                                        [[NSFileManager defaultManager]removeItemAtPath:secondAsset1 error:nil];
                                        NSString* audio_inputFilePath = [[NSString alloc] initWithFormat:@"%@/audioOutput.caf", NSTemporaryDirectory()];
                                        [[NSFileManager defaultManager]removeItemAtPath:audio_inputFilePath error:nil];
                                        [self.navigationController popViewControllerAnimated:YES];
                                        
                                    } else {
                                        [self displayAlert:@"Upload Failed"
                                                    format:@"%@", error];
                                    }
                                    
                                    [uploadProgressIndicator setProgress:0];
                                    
                                    uploadLocationURL = nil;
                                }];
        [self performSelectorInBackground:@selector(stopSpin) withObject:nil];
        UIProgressView *progressIndicator = uploadProgressIndicator;
        _uploadFileTicket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                                  unsigned long long numberOfBytesRead,
                                                  unsigned long long dataLength) {
            [progressIndicator setProgress:(double)numberOfBytesRead/(double)dataLength];
        };
        
        // To allow restarting after stopping, we need to track the upload location
        // URL.
        //
        // For compatibility with systems that do not support Objective-C blocks
        // (iOS 3 and Mac OS X 10.5), the location URL may also be obtained in the
        // progress callback as ((GTMHTTPUploadFetcher *)[ticket objectFetcher]).locationURL
        
        GTMHTTPUploadFetcher *uploadFetcher = (GTMHTTPUploadFetcher *)[_uploadFileTicket objectFetcher];
        uploadFetcher.locationChangeBlock = ^(NSURL *url) {
            uploadLocationURL = url;
        };
    } else {
        // Could not read file data.
        [self displayAlert:@"File Not Found" format:@"Video is not Recorded"];
    }
}

//- (NSString *)MIMETypeForFilename:(NSString *)filename
//                  defaultMIMEType:(NSString *)defaultType {
//    NSString *result = defaultType;
//    NSString *extension = [filename pathExtension];
//    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
//                                                            (__bridge CFStringRef)extension, NULL);
//    if (uti) {
//        CFStringRef cfMIMEType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
//        if (cfMIMEType) {
//            result = CFBridgingRelease(cfMIMEType);
//        }
//        CFRelease(uti);
//    }
//    return result;
//}

-(void)stopSpin
{
    [self.greyBGButton setHidden:YES];
    [self.spinningWheel stopAnimating];
    [self.spinningWheel setHidden:YES];
    [uploadProgressIndicator setHidden:NO];
}
- (void)displayAlert:(NSString *)title format:(NSString *)format, ... {
    NSString *result = format;
    if (format) {
        va_list argList;
        va_start(argList, format);
        result = [[NSString alloc] initWithFormat:format
                                        arguments:argList];
        va_end(argList);
    }
    [[[UIAlertView alloc]initWithTitle:title message:format delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
    [self.uploadButton setEnabled:YES];
}

- (GTLServiceYouTube *)youTubeService {
    static GTLServiceYouTube *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[GTLServiceYouTube alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    });
    return service;
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
    CGContextRef context = CGBitmapContextCreate(pxdata, screenWidth,
                                                 screenWidth, 8, 4*screenWidth, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, screenWidth,
                                           screenWidth), image);
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
         //                 NSString *sourcePath = outputFilePath;
         //              UISaveVideoAtPathToSavedPhotosAlbum(sourcePath,nil,nil,nil);
         //             slideleftview.playVideo.enabled = YES;
         
         [self performSelectorOnMainThread:@selector(uploadVideoFile) withObject:self waitUntilDone:YES];
     }];
}

-(void)didSelectTableCellWithName:(NSString *)dbName
{
    for (UIViewController *view in self.navigationController.viewControllers) {
        if([view isKindOfClass:[SavedStoryDetailsViewController class]]){
            [((SavedStoryDetailsViewController*)view) setDbname:dbName];
            [((SavedStoryDetailsViewController*)view) setBarTitle];
            [[((SavedStoryDetailsViewController*)view) listiPad] setIndex:listViewOutlet.index];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[CreateStoryRootViewController class]])
    {
//        ((CreateStoryRootViewController*)segue.destinationViewController).myDelegate = self;
        AppDelegate *newstoryFlag = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [newstoryFlag setIsNewStory:@"true"];
    }
}

@end
