//
//  STExportViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 09/11/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STExportViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SavedStoryDetailsViewController.h"

#define fileString [[NSString alloc] initWithString:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"export_unlocked.txt"]]
#define kInAppPurchaseProductsFetchedNotification @"kInAppPurchaseProductsFetchedNotification"
#define kInAppPurchaseTransactionSucceededNotification @"kInAppPurchaseTransactionSucceededNotification"
#define kInAppPurchaseTransactionFailedNotification @"kInAppPurchaseTransactionFailedNotification"

#define title_screen_sec 5

@interface STExportViewController ()

@end

@implementation STExportViewController

@synthesize addTitleCheck;
@synthesize paidProduct;
@synthesize storyTitle;
@synthesize storySubTitle;
@synthesize listViewiPad;
@synthesize dbname;
@synthesize storyTitleString;
@synthesize storySubTitleString;
@synthesize storyListiPad;
@synthesize unlockButton;
@synthesize saveButton;
@synthesize bgButton;
@synthesize spinningWheel;
@synthesize savingSpin;
@synthesize savingLabel;
@synthesize payment;

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
	// Do any additional setup after loading the view.
    self.storyTitle.text = self.storyTitleString;
    self.storySubTitle.text = self.storySubTitleString;
    [self.listViewiPad setListDelegate:self];
    [self.listViewiPad setIndex:storyListiPad.index];
    storyListiPad = nil;
    [self.listViewiPad reloadInputViews];
    NSLog(@"storyTitle = %@",self.storyTitle.text);
    NSLog(@"storySubTitle = %@",self.storySubTitle.text);
    addTitleCheck.selected = YES;
    [self.spinningWheel setHidden:YES];
    [self.savingSpin setHidden:YES];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
        [self.unlockButton setHidden:YES];
        [self.saveButton setHidden:NO];
    }
    else
    {
        self.payment = 0;
        [self requestProduct];
    }
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
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleAddTitle:(UISwitch *)sender {
}

- (IBAction)saveToGallery:(UIButton *)sender {
    NSString *dataPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
    [[NSFileManager defaultManager] createFileAtPath:dataPath1 contents:[[NSData alloc]init] attributes:Nil];
    [self.bgButton setHidden:NO];
    [self.spinningWheel startAnimating];
    [self.spinningWheel setHidden:NO];
    self.payment = 1;
    [self requestProduct];
}
-(void)requestProduct
{
    NSSet * productIdentifiers = [NSSet setWithObject:@"export_unlock"];
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
}
- (IBAction)save:(UIButton *)sender {
    [self saveVideo];
}

-(void)addTitleToVideo
{
    //append title to video.
    UIImage *temp = [UIImage imageNamed:@"TitlePage.png"];
    UIImage *tempi = [self drawText:storyTitle.text inImage:temp atPoint:CGPointMake(0,100) withFontsize:70];
    tempi = [self drawText:storySubTitle.text inImage:tempi atPoint:CGPointMake(0,350) withFontsize:50];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/upload_dir"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    NSString *savedVideoPath = [dataPath stringByAppendingPathComponent:@"videoOutput.mp4"];
    // printf(" \n\n\n-Video file == %s--\n\n\n",[savedVideoPath UTF8String]);
    CGFloat video_size = [[UIScreen mainScreen] bounds].size.width;
    [self writeImageAsMovie:tempi toPath:savedVideoPath size:CGRectMake(0, 0, video_size, video_size).size duration:title_screen_sec];
    [self mergeVideoRecording];
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
    
    //[videoWriter finishWriting];
    
    NSLog(@"end record page");
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
    NSLog(@"Merge Start");
    NSFileManager *file = [NSFileManager defaultManager];
    NSString* firstAsset1 = [[NSString alloc] initWithFormat:@"%@/upload_dir/%@", NSTemporaryDirectory(), @"videoOutput.mp4"];//title movie
    NSString* secondAsset1 = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mp4", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [self.dbname stringByDeletingPathExtension]];
    NSString *tempVideoFile = [[NSString alloc] initWithFormat:@"%@/upload_dir/title.mp4", NSTemporaryDirectory()];
    
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
        
        NSURL *url = [NSURL fileURLWithPath:tempVideoFile];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             NSLog(@"AVVideoAssetExportSessionStatusCompleted");
             [file removeItemAtPath:firstAsset1 error:nil];
             [file moveItemAtPath:tempVideoFile toPath:firstAsset1 error:nil];
             [self CompileFilesToMakeMovie];
         }];
        
    }
    else{
        [file copyItemAtPath:firstAsset1 toPath:secondAsset1 error:nil];
        [self CompileFilesToMakeMovie];
    }
    NSLog(@"MergeEnd");
    
}

-(void)CompileFilesToMakeMovie
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSString* audio_inputFilePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.caf", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [self.dbname stringByDeletingPathExtension]];
    NSURL*    audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
    
    NSString* video_inputFilePath = [[NSString alloc] initWithFormat:@"%@/upload_dir/videoOutput.mp4", NSTemporaryDirectory()];
    NSURL*    video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
    
    NSString* outputFileName = [NSString stringWithFormat:@"%@.mov",[self.dbname stringByDeletingPathExtension]];
    NSString* outputFilePath = [[NSString alloc] initWithFormat:@"%@/upload_dir/%@", NSTemporaryDirectory(), outputFileName];
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:outputFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:CMTimeMakeWithSeconds(title_screen_sec,1) error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
                          NSString *sourcePath = outputFilePath;
                        NSLog(@"sourcepath : %@",sourcePath);
                       UISaveVideoAtPathToSavedPhotosAlbum(sourcePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
     }];
    
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"productsresponse= %@",response);
    NSLog(@"invalidProductIdentifiers : %@",response.invalidProductIdentifiers);
    paidProduct = [response.products objectAtIndex:0];
    NSLog(@"Product Title : %@",[[response.products objectAtIndex:0] localizedTitle]);
    NSLog(@"product description : %@", [[response.products objectAtIndex:0] productIdentifier]);
    NSLog(@"Product Price %f", [[response.products objectAtIndex:0] price].floatValue);
    NSLocale *priceLocale = paidProduct.priceLocale;
    NSDecimalNumber *price = paidProduct.price;
    NSLog(@"%@" ,[NSString stringWithFormat:NSLocalizedString(@"Unlock Feature - %@%@", nil), [priceLocale objectForKey:NSLocaleCurrencySymbol], [price stringValue]]);
    [self.unlockButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Unlock Feature - %@%@", nil), [priceLocale objectForKey:NSLocaleCurrencySymbol], [price stringValue]] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseProductsFetchedNotification object:self userInfo:nil];
    }
-(void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"requestDidFinish");
    if (payment) {
        SKPayment *paidPayment = [SKPayment paymentWithProduct:paidProduct];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:paidPayment];
    }
    
    
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [self.spinningWheel stopAnimating];
    [self.spinningWheel setHidden:YES];
    NSLog(@"Failed to load the list of Products : %@",error);
    if(error)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to load the list of Products" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
      
}
#pragma mark - SKPaymentTransactionObserver Protocol Methods

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"paymentQueue:(SKPaymentQueue *)queue updatedTransactions");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                [self finishTransaction:transaction wasSuccessful:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction");
    [self recordTransaction:transaction];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"recordTransaction");
    if ([transaction.payment.productIdentifier isEqualToString:@"export_unlock"])
    {
        //        [self.loader startAnimating];
        NSLog(@"Receipt from transaction : %@",transaction.transactionReceipt);
//        [self saveVideo];
    }
}

-(void)saveVideo
{
  //save Video to gallery
    [self.bgButton setHidden:NO];
    [self.savingLabel setHidden:NO];
    [self.savingSpin setHidden:NO];
    [self.savingSpin startAnimating];

    if([addTitleCheck isOn])
    {
        [self addTitleToVideo];
    }
    else
    {
        NSFileManager *filemngr =[NSFileManager defaultManager];
        NSString *moviePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mov", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [dbname stringByDeletingPathExtension]];
        if([filemngr fileExistsAtPath:moviePath]){
            NSLog(@"path : %@",moviePath);
            UISaveVideoAtPathToSavedPhotosAlbum(moviePath,self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }
}

- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    [self.bgButton setHidden:YES];
    [self.savingLabel setHidden:YES];
    [self.savingSpin stopAnimating];
    [self.savingSpin setHidden:YES];
    NSFileManager *file = [NSFileManager defaultManager];
    [file removeItemAtPath:[[NSString alloc] initWithFormat:@"%@/upload_dir/%@", NSTemporaryDirectory(), @"videoOutput.mp4"] error:nil];
    [file removeItemAtPath:[[NSString alloc] initWithFormat:@"%@/upload_dir/title.mp4", NSTemporaryDirectory()] error:nil];
    NSString *dataPath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
    [file removeItemAtPath:[[NSString alloc] initWithFormat:@"%@/upload_dir/title.mp4", NSTemporaryDirectory()] error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:dataPath1 error:nil];


    if (error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Photo/Video Saving Failed"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo/Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    NSLog(@"finishTransaction");
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    [self.bgButton setHidden:YES];
    [self.spinningWheel stopAnimating];
    [self.spinningWheel setHidden:YES];
    if (wasSuccessful)
    {
        NSLog(@"success Transaction !!");
        [[NSFileManager defaultManager] createFileAtPath:fileString contents:Nil attributes:nil];
        NSURL *installedFileUrl = [NSURL fileURLWithPath:fileString];
        [self addSkipBackupAttributeToItemAtURL:installedFileUrl];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
            NSLog(@"File created successfully");
            [self.unlockButton setHidden:YES];
            [self.saveButton setHidden:NO];
        }
        else
            NSLog(@"File cannot be created.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feature Unlock"
                                                        message:@"Successful"
                                                       delegate:Nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        NSLog(@"failed Transaction !!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Feature Unlock"
                                                        message:@"Failed, Try Again Later."
                                                       delegate:Nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //         send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseTransactionFailedNotification object:self userInfo:userInfo];
    }
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [self.bgButton setHidden:YES];
        [self.spinningWheel stopAnimating];
        [self.spinningWheel setHidden:YES];
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
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
