//
//  WorkAreaController.m
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "WorkAreaController.h"
#import <MediaPlayer/MediaPlayer.h>


#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define STATUS_BAR_HEIGHT 20

@interface WorkAreaController ()

@end

@implementation WorkAreaController

@synthesize captureview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect capturebounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    [captureview setFrame:CGRectMake(0,thumbHeight,capturebounds.size.width,capturebounds.size.height-(2*thumbHeight)-STATUS_BAR_HEIGHT)];
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
    [self setWorkspaceBackground:[UIImage imageNamed:@"RecordArea.png"]];
    
    CGRect frame = CGRectMake(0, CGRectGetMaxY(capturebounds)-thumbHeight-STATUS_BAR_HEIGHT, capturebounds.size.width, thumbHeight);
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
    [self.view addSubview:back_btn_view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doSingleTap:(UIGestureRecognizer *) gestureRecognizer {
    //[slideupview toggleThumbView];
    //[slidedownview toggleThumbView];
    [slideleftview toggleThumbView];
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
    
    if(!imageselected)
        for (UIImageView *temp in pickedimages) {
            if([touch.view isDescendantOfView:temp])
            {
                imageselected = YES;
                selectedimage = temp;
                [temp.layer setBorderColor:[[UIColor blackColor] CGColor]];
                [temp.layer setBorderWidth: 2.0];
                [temp addGestureRecognizer:pan];
                [temp addGestureRecognizer:pinch];
                [temp addGestureRecognizer:rotate];
                UIView *temp1 = temp;
                [temp1 bringToFront];
                return NO;
                
            }
        }
    else
    {
        if(![touch.view isDescendantOfView:selectedimage]){
            imageselected = NO;
            [selectedimage.layer setBorderColor:[[UIColor clearColor] CGColor]];
            [selectedimage.layer setBorderWidth: 0.0];
            [selectedimage removeGestureRecognizer:pinch];
            [selectedimage removeGestureRecognizer:pan];
            [selectedimage removeGestureRecognizer:rotate];
            selectedimage = NULL;
            return NO;
        }
    }
    
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

- (void) setWorkspaceBackground:(UIImage *)selectedImage{
    backgroundimageview.image = selectedImage;
}

- (void)checkFrameIntersection:(UIImage *)tiv withFrame:(CGRect) testframe{
    CGRect mainframe = CGRectMake(0, CGRectGetHeight(slideupview.frame), CGRectGetWidth(slideupview.frame), CGRectGetHeight(captureview.frame)-CGRectGetHeight(slidedownview.frame));
    if(CGRectIntersectsRect(mainframe, testframe)){
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(testframe.origin.x, testframe.origin.y, 100, 100)];
        imageview.image = tiv;
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
//        pan.delegate = self;
//        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
//        pinch.delegate = self;
//        UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)];
//        rotate.delegate = self;
//        [imageview setUserInteractionEnabled:YES];
//        [imageview addGestureRecognizer:pan];
//        [imageview addGestureRecognizer:pinch];
//        [imageview addGestureRecognizer:rotate];
        [imageview setUserInteractionEnabled:YES];
        [captureview addSubview:imageview];
        [pickedimages addObject:imageview];
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

#pragma mark SlideLeftView Delegate Methods

- (void)startcapturingview{
    slideleftview.startrecording.enabled = NO;
    slideleftview.stoprecording.enabled = YES;
    [audiorecorder recordAudio];
    [captureview startRecording];
}

- (void)stopcapturingview{
    slideleftview.stoprecording.enabled = NO;
    [captureview stopRecording];
    [audiorecorder stop];
    [self performSelector:@selector(CompileFilesToMakeMovie) withObject:nil afterDelay:10.0];
}

-(void)CompileFilesToMakeMovie
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSString* audio_inputFilePath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"sound.caf"];
    NSURL*    audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
    
    NSString* video_inputFilePath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"output.mp4"];
    NSURL*    video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
    
    NSString* outputFileName = @"outputFile.mov";
    NSString* outputFilePath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], outputFileName];
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
        
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
             NSString *sourcePath = outputFilePath;
             UISaveVideoAtPathToSavedPhotosAlbum(sourcePath,nil,nil,nil);
             slideleftview.playVideo.enabled = YES;
     }
     ];  
}

- (void)playcapturedvideo{
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], @"outputFile.mov"];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:outputURL];
    mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:mp];

}

@end
