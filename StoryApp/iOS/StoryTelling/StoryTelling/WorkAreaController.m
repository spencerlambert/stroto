//
//  WorkAreaController.m
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "WorkAreaController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SavedStoryDetailsViewController.h"


#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define THUMB_ADDITIONAL 22
#define THUMB_HEIGHT 70
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define STATUS_BAR_HEIGHT 0


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface WorkAreaController ()

@end

@implementation WorkAreaController

@synthesize captureview;
@synthesize selectedForegroundImage;
@synthesize storyDB;
@synthesize mydelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(void)initWorkArea{
    
    [self setBackgroundImages:[NSMutableArray arrayWithArray:[storyDB getBackgroundImagesSorted]]];
    [self setForegroundImages:[NSMutableArray arrayWithArray:[storyDB getForegroundImagesSorted]]];
    //    [captureview setStoryDB:storyDB];
    //    [captureview initStage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initWorkArea];
    [self setSelectedForegroundImage:nil];
    recordbtnClicked = NO;
    CGRect capturebounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    if (IS_IPHONE_5) {
        thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING + THUMB_ADDITIONAL * 2 ;
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [captureview setFrame:CGRectMake(0,thumbHeight,capturebounds.size.width,capturebounds.size.height-(2*thumbHeight))];
    } else {
        [captureview setFrame:CGRectMake(0,thumbHeight,capturebounds.size.width,capturebounds.size.height-(2*thumbHeight)-STATUS_BAR_HEIGHT)];
        
    }
    imageselected = NO;
    pickedimages = [[NSMutableArray alloc]init];
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)];
    rotate.delegate = self;
    audiorecorder = [[AudioRecorder alloc]init];
    CGRect bounds = [captureview bounds];
    backgroundimageview = [[UIImageView alloc]initWithFrame:bounds];
    backgroundimageview.contentMode = UIViewContentModeScaleToFill;
    [backgroundimageview setUserInteractionEnabled:YES];
    [captureview addSubview:backgroundimageview];
    backgroundimageview.image = [UIImage imageNamed:@"RecordArea.png"];
    
    CGRect frame;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        frame = CGRectMake(0, CGRectGetMaxY(capturebounds)-thumbHeight, capturebounds.size.width, thumbHeight);
    } else {
        frame = CGRectMake(0, CGRectGetMaxY(capturebounds)-thumbHeight-STATUS_BAR_HEIGHT, capturebounds.size.width, thumbHeight);
    }
    UIImageView *bottombar = [[UIImageView alloc]initWithFrame:frame];
    [bottombar setImage:[UIImage imageNamed:@"BottomBar.png"]];
    [self.view addSubview:bottombar];
    
    frame = CGRectMake(CGRectGetMinX(capturebounds), CGRectGetMinY(capturebounds), capturebounds.size.width, thumbHeight);
    UIImageView *topbar = [[UIImageView alloc]initWithFrame:frame];
    [topbar setImage:[UIImage imageNamed:@"TopBar.png"]];
    [self.view addSubview:topbar];
    
    //    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    //    pinch.delegate = self;
    //    [backgroundimageview addGestureRecognizer:pinch];
    
    slideupview = [[SlideUpView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    slideupview.mydelegate = self;
    [slideupview setPhotos:[self backgroundImages]];
    [slideupview createThumbScrollViewIfNecessary];
    [self.view addSubview:slideupview];
    
    slidedownview = [[SlideDownView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    slidedownview.mydelegate = self;
    [slidedownview setPhotos:[self foregroundImages]];
    [slidedownview createThumbScrollViewIfNecessary];
    [self.view addSubview:slidedownview];
    
    //    slideleftview = [[SlideLeftView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    //    slideleftview.mydelegate = self;
    //    [self.view addSubview:slideleftview];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    //[captureview performSelector:@selector(startRecording) withObject:nil afterDelay:1.0];
	//[captureview performSelector:@selector(stopRecording) withObject:nil afterDelay:30.0];
    
    BottomRight *record_btn_view = [[BottomRight alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [record_btn_view setMydelegate:self];
    [self.view addSubview:record_btn_view];
    
    TopRightView *back_btn_view = [[TopRightView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [back_btn_view setMydelegate:self];
    [self.view addSubview:back_btn_view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) doSingleTap:(UIGestureRecognizer *) gestureRecognizer {
    //[slideupview toggleThumbView];
    //[slidedownview toggleThumbView];
    [slideleftview toggleThumbView];
    
    if([self selectedForegroundImage]!=nil){
        
        CGPoint point=[gestureRecognizer locationInView:self.view];
        NSLog(@"%f %f",point.x,point.y);
        
        //        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(point.x-50,point.y-(60+20)-50, 100, 100)];
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(point.x-(selectedForegroundImage.sizeScale/2),point.y-(60+20)-(selectedForegroundImage.sizeScale/2), selectedForegroundImage.sizeScale, selectedForegroundImage.sizeScale)];
        imageview.image=selectedForegroundImage;
        [imageview setContentMode:UIViewContentModeScaleAspectFit];
        [captureview addSubview:imageview];
        
        //        [captureview actortoStage:selectedForegroundImage];
        
        [imageview bringToFront];
        pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        pinch.delegate = self;
        rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)];
        rotate.delegate = self;
        tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tap.delegate=self;
        [imageview setUserInteractionEnabled:YES];
        [imageview addGestureRecognizer:pan];
        [imageview addGestureRecognizer:pinch];
        [imageview addGestureRecognizer:rotate];
        [imageview addGestureRecognizer:tap];
        
        [self setSelectedForegroundImage:nil];
    }
    
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(slideupview.superview != nil){
        if([touch.view isDescendantOfView:slideupview]){
            return NO;
        }
    }
    if(slidedownview.superview != nil){
        if([touch.view isDescendantOfView:slidedownview]){
            return NO;
        }
    }
    if(slideleftview.superview != nil){
        if([touch.view isDescendantOfView:slideleftview]){
            return NO;
        }
    }
    
    //    for (UIImageView *temp in pickedimages) {
    //        if([touch.view isDescendantOfView:temp])
    //        {
    //            [temp bringToFront];
    //        }
    //    }
    
    
    //    if(!imageselected)
    //        for (UIImageView *temp in pickedimages) {
    //            if([touch.view isDescendantOfView:temp])
    //            {
    //                imageselected = YES;
    //                selectedimage = temp;
    //                [temp.layer setBorderColor:[[UIColor blackColor] CGColor]];
    //                [temp.layer setBorderWidth: 2.0];
    //                [temp addGestureRecognizer:pan];
    //                [temp addGestureRecognizer:pinch];
    //                [temp addGestureRecognizer:rotate];
    //                UIView *temp1 = temp;
    //                [temp1 bringToFront];
    //                return NO;
    //
    //            }
    //        }
    //    else
    //    {
    //        if(![touch.view isDescendantOfView:selectedimage]){
    //            imageselected = NO;
    //            [selectedimage.layer setBorderColor:[[UIColor clearColor] CGColor]];
    //            [selectedimage.layer setBorderWidth: 0.0];
    //            [selectedimage removeGestureRecognizer:pinch];
    //            [selectedimage removeGestureRecognizer:pan];
    //            [selectedimage removeGestureRecognizer:rotate];
    //            selectedimage = NULL;
    //            return NO;
    //        }
    //    }
    
    return YES;
}

#pragma mark Auto Rotate to Landscape Functions

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark SlideUpViewDelegate methods

- (void) setWorkspaceBackground:(STImage *)selectedImage{
    backgroundimageview.image = selectedImage;
    // [captureview actortoStage:selectedImage];
}

//adding foreground image to work area
-(void) setForegroundImage:(STImage *)selectedImage{
    [self setSelectedForegroundImage:selectedImage];
    NSLog(@"%@", [selectedImage description]);
    NSLog(@"foreground image set");
}

//- (void)checkFrameIntersection:(UIImage *)tiv withFrame:(CGRect) testframe{
//    CGRect mainframe = CGRectMake(0, CGRectGetHeight(slideupview.frame), CGRectGetWidth(slideupview.frame), CGRectGetHeight(captureview.frame)-CGRectGetHeight(slidedownview.frame));
//    if(CGRectIntersectsRect(mainframe, testframe)){
//        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(testframe.origin.x, testframe.origin.y, 100, 100)];
//        imageview.image = tiv;
//        pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
//        pan.delegate = self;
//        pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
//        pinch.delegate = self;
//        rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)];
//        rotate.delegate = self;
//        [imageview setUserInteractionEnabled:YES];
//        [imageview addGestureRecognizer:pan];
//        [imageview addGestureRecognizer:pinch];
//        [imageview addGestureRecognizer:rotate];
//        [imageview setUserInteractionEnabled:YES];
//        [captureview addSubview:imageview];
//        [pickedimages addObject:imageview];
//    }
//}

#pragma mark UIGestureRecognizerDelegate methods

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view bringToFront];
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    [recognizer.view bringToFront];
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    [recognizer.view bringToFront];
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

-(IBAction)handleTap:(UITapGestureRecognizer*)recognizer{
    [recognizer.view bringToFront];
}


#pragma mark BottomRightView Delegate Methods

- (void)startcapturingview{
    //    slideleftview.startrecording.enabled = NO;
    //    slideleftview.stoprecording.enabled = YES;
    recordbtnClicked = YES;
    [audiorecorder recordAudio];
    //Changing record methods: captureview is now just a UIView
    [captureview startRecording];
}

-(void)pausecapturingview{
    [audiorecorder pause];
    [captureview pauseRecording];
}

-(void)resumecapturingview{
    [audiorecorder recordAudio];
    [captureview resumeRecording];
}

#pragma mark TopRightView Delegate Methods

- (void)stopcapturingview{
    // slideleftview.stoprecording.enabled = NO;
    //Changing record methods: captureview is now just a UIView
    [captureview stopRecording];
    [audiorecorder stop];
    if(recordbtnClicked){
        if (!loaderView) {
            loaderView = [self getLoaderView];
            [self.view addSubview:loaderView];
        }
        [self performSelector:@selector(CompileRecording) withObject:nil afterDelay:10.0];
    }else{
        [storyDB closeDB];
        [mydelegate finishedRecording];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

-(void)CompileRecording
{
    [self mergeAudioRecording];
}

-(void)mergeAudioRecording{
    NSFileManager *file = [NSFileManager defaultManager];
    NSString* audio_inputFilePath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"sound.caf"];
    NSString* audio_FilePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.caf", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [storyDB getDBName]];
    NSString *tempSoundFile = [[NSString alloc] initWithFormat:@"%@/mov_dir/temp.m4a", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    [file createDirectoryAtPath:[[NSString alloc] initWithFormat:@"%@/mov_dir/", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]] withIntermediateDirectories:YES attributes:nil error:nil];
    if([file fileExistsAtPath:audio_FilePath]){
        
        
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        AVMutableComposition *composition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack setPreferredVolume:0.8];
        NSURL *url = [NSURL fileURLWithPath:audio_FilePath];
        AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        
        AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
        
        AVMutableCompositionTrack *compositionAudioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack setPreferredVolume:0.3];
        NSURL *url1 = [NSURL fileURLWithPath:audio_inputFilePath ];
        AVAsset *avAsset1 = [AVURLAsset URLAssetWithURL:url1 options:nil];
        AVAssetTrack *clipAudioTrack1 = [[avAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset1.duration) ofTrack:clipAudioTrack1 atTime:avAsset.duration error:nil];
        
        
        AVAssetExportSession *exportSession = [AVAssetExportSession
                                               exportSessionWithAsset:composition
                                               presetName:AVAssetExportPresetAppleM4A];
        if (nil == exportSession) return;
        
        
        // configure export session  output with all our parameters
        exportSession.outputURL = [NSURL fileURLWithPath:tempSoundFile]; // output path
        exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
        
        // perform the export
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            if (AVAssetExportSessionStatusCompleted == exportSession.status) {
                NSLog(@"AVAssetExportSessionStatusCompleted");
                [file removeItemAtPath:audio_FilePath error:nil];
                [file moveItemAtPath:tempSoundFile toPath:audio_FilePath error:nil];
                [self mergeVideoRecording];
            } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
                NSLog(@"AVAssetExportSessionStatusFailed");
            } else {
                NSLog(@"Export Session Status: %d", exportSession.status);
            }
        }];
        
    }
    else{
        [file copyItemAtPath:audio_inputFilePath toPath:audio_FilePath error:nil];
        [self mergeVideoRecording];
    }
}

-(void)mergeVideoRecording{
    NSFileManager *file = [NSFileManager defaultManager];
    NSString* firstAsset1 = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"output.mp4"];
    NSString* secondAsset1 = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [storyDB getDBName]];
    NSString *tempVideoFile = [[NSString alloc] initWithFormat:@"%@/mov_dir/temp.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    [file createDirectoryAtPath:[[NSString alloc] initWithFormat:@"%@/mov_dir/", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]] withIntermediateDirectories:YES attributes:nil error:nil];
    if([file fileExistsAtPath:secondAsset1]){
        
        
        NSURL *url1 = [NSURL fileURLWithPath:secondAsset1];
        AVAsset *firstAsset = [AVURLAsset URLAssetWithURL:url1 options:nil];
        NSURL *url2 = [NSURL fileURLWithPath:firstAsset1];
        AVAsset *secondAsset = [AVURLAsset URLAssetWithURL:url2 options:nil];
        
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration)
                            ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstAsset.duration error:nil];
        
        
        NSURL *url = [NSURL fileURLWithPath:tempVideoFile];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             NSLog(@"AVVideoAssetExportSessionStatusCompleted");
             [file removeItemAtPath:secondAsset1 error:nil];
             [file moveItemAtPath:tempVideoFile toPath:secondAsset1 error:nil];
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
    
    NSString* audio_inputFilePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.caf", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [storyDB getDBName]];
    NSURL*    audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
    
    NSString* video_inputFilePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [storyDB getDBName]];
    NSURL*    video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
    
    NSString* outputFileName = [NSString stringWithFormat:@"%@.mov",[storyDB getDBName]];
    NSString* outputFilePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], outputFileName];
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:outputFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(1,1),CMTimeAdd(videoAsset.duration,CMTimeMakeWithSeconds(-1,1)));
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
//         NSString *sourcePath = outputFilePath;
//         UISaveVideoAtPathToSavedPhotosAlbum(sourcePath,nil,nil,nil);
         //             slideleftview.playVideo.enabled = YES;
    }];
    
    
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:audio_inputFilePath])
    //        [[NSFileManager defaultManager] removeItemAtPath:audio_inputFilePath error:nil];
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:video_inputFilePath])
    //        [[NSFileManager defaultManager] removeItemAtPath:video_inputFilePath error:nil];
    
    [loaderView removeFromSuperview];
    [mydelegate finishedRecording];
    [storyDB closeDB];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *) getLoaderView{
    loaderView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [loaderView setBackgroundColor:[UIColor blackColor]];
    [loaderView setAlpha:0.5f];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator startAnimating];
    [loaderView addSubview:indicator];
    [indicator setCenter:loaderView.center];
    return loaderView;
}

@end
