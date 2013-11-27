//
//  STFreeStoryPacksViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define freeDetailsBody [NSString stringWithFormat:@"{\"st_request\":\"get_story_details\",\"st_story_id\":\"%d\"}",storyPackID]
#define AppleServerError [NSString stringWithFormat:@"{\"st_request\":\"purchase\",\"st_story_id\":\"%d\",\"apple_receipt\":\"APPLE DOWN\"}",storyPackID]
#define appleReceipt [NSString stringWithFormat:@"{\"st_request\":\"purchase\",\"st_story_id\":\"%d\",\"apple_receipt\":\"%@\"}",storyPackID,appleReceiptData]

#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 250 : 80)
#define THUMB_V_PADDING (IS_IPAD ? 25 : 6)
#define THUMB_H_PADDING 8

#import "STFreeStoryPacksViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "STInstalledStoryPacksViewController.h"
#import "AppDelegate.h"

@interface STFreeStoryPacksViewController () 
@end

@implementation STFreeStoryPacksViewController

@synthesize storyPackID;
@synthesize freeStoryPackDetailsJson;
@synthesize freeStoryPackURLJson;
@synthesize freeProduct;
@synthesize freeStoryPackName;
@synthesize freeButton;
@synthesize backgroundButton;
@synthesize backgroundImagesView;
@synthesize foregroundImagesView;
@synthesize loader;
@synthesize downloadRectView;
@synthesize progressView;
@synthesize downloadPercentageLabel;
@synthesize BGHideDownload;

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
//    NSLog(@"freeStoryPackID = %d",self.storyPackID);
    [self.freeButton setHidden:YES];
    //Activity Indicator
    [self.loader setHidden:FALSE];
    [self.loader startAnimating];
    
    [((AppDelegate *)[[UIApplication sharedApplication]delegate]) internetAvailableNotifier];
    BOOL internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
   
    if (internetAvailable)
        [self performSelectorInBackground:@selector(freeJsonDetails) withObject:nil];
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self dismissLoader];
    }
    
    [self performSelector:@selector(dismissLoader) withObject:nil afterDelay:60];
    
}
-(void)freeJsonDetails
{
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    
    NSData *requestData = [NSData dataWithBytes:[freeDetailsBody UTF8String] length:[freeDetailsBody length]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            freeStoryPackDetailsJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

            [self performSelectorInBackground:@selector(updateText)  withObject:nil];
            [self performSelectorInBackground:@selector(reloadBackgroundImages)  withObject:nil];
            [self performSelectorInBackground:@selector(reloadForegroundImages)  withObject:nil];

            //[self reloadForegroundImages];
            
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
            NSLog(@"html= %@",html);
            NSLog(@"st_details = %@",[freeStoryPackDetailsJson valueForKey:@"st_details"]);
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error);
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:[error.userInfo objectForKey:NSLocalizedDescriptionKey] waitUntilDone:NO];
            return ;
        }
    }];

}

-(void)updateText
{
    freeStoryPackName.text = [NSString stringWithFormat:@"%@",[[freeStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"Name"]];
    [self.freeButton setHidden:NO];

}


-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [self dismissLoader];
}

-(void)dismissLoader{
    [self.loader stopAnimating];
    [self.loader setHidden:TRUE];
}

-(void)reloadBackgroundImages
{
    if([[freeStoryPackDetailsJson valueForKey:@"st_bg_list"]count])
    {
    //for showing paid story packs in scroll view
    
    //    float scrollViewHeight = THUMB_HEIGHT + 3*THUMB_V_PADDING+NAME_LABEL_HEIGHT+PRICE_LABEL_HEIGHT;
    float scrollViewHeight = [backgroundImagesView bounds].size.height;
    float scrollViewWidth  = [backgroundImagesView bounds].size.width;
    //    [paidStoryPacksView setBackgroundColor:[UIColor whiteColor]];
    float __block xPosition = THUMB_H_PADDING;
    UIScrollView *backgroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [backgroundImagesHolder setUserInteractionEnabled:YES];
    backgroundImagesHolder.tag = 1;
    [backgroundImagesHolder setCanCancelContentTouches:NO];
    [backgroundImagesHolder setClipsToBounds:NO];
    for(UIView *view in backgroundImagesView.subviews)
        [view removeFromSuperview];
    [backgroundImagesHolder setHidden:NO];
    while(!freeStoryPackDetailsJson){       //checking for data
        //        NSLog(@"NUll in paidJSON");
        continue;}
    for (int i = 0; i<[[freeStoryPackDetailsJson valueForKey:@"st_bg_list"]count];i++)
    {
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[freeStoryPackDetailsJson valueForKey:@"st_bg_list"] objectAtIndex:i ] valueForKey:@"ThumbnailURL" ]]];
        
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
        //showing paid story pack's thubnail images
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        [thumbView setContentMode:UIViewContentModeScaleAspectFit];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setHidden:NO];
        [backgroundImagesHolder addSubview:thumbView];
        [backgroundImagesView addSubview:backgroundImagesHolder];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    //    [paidStoryPacksHolder setAlpha:0.5]; //for knowing the bounds
    //    [paidStoryPacksHolder setBackgroundColor:[UIColor blueColor]];  //for knowing the bounds
        
//    for(UIView *view in backgroundImagesView.subviews){
//        [view removeFromSuperview];
//    }//testing is needed.
        
    [backgroundImagesView addSubview:backgroundImagesHolder];
    }
}

-(void)reloadForegroundImages
{
    if([[freeStoryPackDetailsJson valueForKey:@"st_fg_list"]count])
    {
    //for showing paid story packs in scroll view
    
    //    float scrollViewHeight = THUMB_HEIGHT + 3*THUMB_V_PADDING+NAME_LABEL_HEIGHT+PRICE_LABEL_HEIGHT;
    float scrollViewHeight = [foregroundImagesView bounds].size.height;
    float scrollViewWidth  = [foregroundImagesView bounds].size.width;
    //    [foregroundImagesView setBackgroundColor:[UIColor whiteColor]];
    float __block xPosition = THUMB_H_PADDING;
    UIScrollView *foregroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [foregroundImagesHolder setUserInteractionEnabled:YES];
    foregroundImagesHolder.tag = 1;
    [foregroundImagesHolder setCanCancelContentTouches:NO];
    [foregroundImagesHolder setClipsToBounds:NO];
    for(UIView *view in foregroundImagesView.subviews)
        [view removeFromSuperview];
    [foregroundImagesHolder setHidden:NO];
    while(!freeStoryPackDetailsJson){       //checking for data
        //        NSLog(@"NUll in paidJSON");
        continue;}
    for (int i = 0; i<[[freeStoryPackDetailsJson valueForKey:@"st_fg_list"]count];i++)
    {
         NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[freeStoryPackDetailsJson valueForKey:@"st_fg_list"] objectAtIndex:i ] valueForKey:@"ThumbnailURL" ]]];
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
        //showing paid story pack's thubnail images
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        [thumbView setContentMode:UIViewContentModeScaleAspectFit];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setHidden:NO];
        [foregroundImagesHolder addSubview:thumbView];
        [foregroundImagesView addSubview:foregroundImagesHolder];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    //    [paidStoryPacksHolder setAlpha:0.5]; //for knowing the bounds
    //    [paidStoryPacksHolder setBackgroundColor:[UIColor blueColor]];  //for knowing the bounds
//    for(UIView *view in foregroundImagesView.subviews){
//        [view removeFromSuperview];
//    }//testing is needed.
    [foregroundImagesView addSubview:foregroundImagesHolder];
    }
    //stoping activity indicator
    [self.loader stopAnimating];
    [self.loader setHidden:YES];
    [self.freeButton setHidden:NO];
    
}

#pragma mark - In App Purchase

- (IBAction)buyButtonTapped:(id)sender
{
    NSSet * productIdentifiers = [NSSet setWithObject:[[freeStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]];
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
//    [self.freeButton setHidden:YES];
    [self.loader startAnimating];
    [self.loader setHidden:NO];
    [self.BGHideDownload setHidden:NO];
    [self.backgroundButton setHidden:YES];
}


- (IBAction)showFree:(UIButton *)sender {
    //touched background.
    [self.backgroundButton setHidden:YES];
    [self.freeButton setHidden:NO];

}

#pragma mark - SKProductsRequestDelegate Protocol Methods

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Response : %@",response);
    NSLog(@"invalidProductIdentifiers : %@",response.invalidProductIdentifiers);
    freeProduct = [response.products objectAtIndex:0];
    NSLog(@"Product Title : %@",[[response.products objectAtIndex:0] localizedTitle]);
    NSLog(@"product description : %@", [[response.products objectAtIndex:0] productIdentifier]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseProductsFetchedNotification object:self userInfo:nil];
}

-(void)requestDidFinish:(SKRequest *)request
{
    SKPayment *freePayment = [SKPayment paymentWithProduct:freeProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:freePayment];
    [self.loader stopAnimating];
    [self.loader setHidden:YES];

}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products : %@",error);
    if(error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Apple server down, Do you want to download from our server ?? " delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex = %d",buttonIndex);
    if (buttonIndex == 0) {
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        NSData *requestData = [NSData dataWithBytes:[AppleServerError UTF8String] length:[AppleServerError length]];
        [urlRequest setHTTPMethod:@"POST"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
        [urlRequest setHTTPBody:requestData];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            freeStoryPackURLJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            STStoryPackDownload *freedownload = [[STStoryPackDownload alloc] init];
            [freedownload downloadStoryPack:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[freeStoryPackURLJson valueForKey:@"st_storypack_url" ]]]];
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
            NSLog(@"html= %@",html);
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); }
    }];
    }
}

#pragma mark - SKPaymentTransactionObserver Protocol Methods

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
//    NSLog(@"paymentQueue:(SKPaymentQueue *)queue updatedTransactions");
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
            case SKPaymentTransactionStateRestored:
                //                [self restoreTransaction:transaction];
                //                [self dismissViewControllerAnimated:YES completion:nil];
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

// sends the receipt to json server.
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"recordTransaction");
    if ([transaction.payment.productIdentifier isEqualToString:[[freeStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]])
    {
//        [self.loader startAnimating];
        NSLog(@"Receipt from transaction : %@",transaction.transactionReceipt);
        [self sendReceipt:transaction.transactionReceipt];
    }
}

-(void) sendReceipt:(NSData*)appleReceiptData
{
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSData *requestData = [NSData dataWithBytes:[appleReceipt UTF8String] length:[appleReceipt length]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];

    
    NSLog(@"receipt ( inside sendReceipt:) : %@", appleReceipt);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [self.loader setHidden:NO];
    [self.loader startAnimating];
    [self.downloadRectView.layer setCornerRadius:9];
    [self.downloadRectView.layer setMasksToBounds:YES];
    [self.downloadRectView setHidden:NO];
    [self.navigationItem setHidesBackButton:YES];
    [self.progressView setHidden:NO];
    [self.downloadPercentageLabel setHidden:NO];
    [self.BGHideDownload setHidden:NO];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            freeStoryPackURLJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            STStoryPackDownload *freeDownload = [[STStoryPackDownload alloc] init];
            
            //progress bar delegate.
            [freeDownload setProgressDelegate:self];
//            [self.progressView setHidden:NO];
//            [self.downloadPercentageLabel setHidden:NO];
            
            
            [freeDownload downloadStoryPack:[NSString stringWithFormat:@"%@",[freeStoryPackURLJson valueForKey:@"st_storypack_url" ]]];
            
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
            NSLog(@"html= %@",html);

        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); }
    }];
}
//show installed View.
-(void)finishedDownloadingDB:(NSString*)DBFilePath
{
    //stopping progressBar.
    [self.loader stopAnimating];
    [self.loader setHidden:YES];
    [self.downloadRectView setHidden:YES];
    [self.progressView setHidden:YES];
    [self.downloadPercentageLabel setHidden:YES];
    [self.BGHideDownload setHidden:YES];
    STInstalledStoryPacksViewController *installController = [[STInstalledStoryPacksViewController alloc] init];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"%@",deviceType);
    if([deviceType hasPrefix:@"iPad"]){
        installController =
        [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"installedStoryPacks"];
    }
    else{
        installController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"installedStoryPacks"];
    }
    installController.filePath = DBFilePath;
    [self.navigationController pushViewController:installController animated:YES];
}


//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    NSLog(@"finishTransaction");
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        NSLog(@"success Transaction !!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Free StoryPack Purchase"
                                                        message:@"Successful"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        NSLog(@"failed Transaction !!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Free Story Pack Purchase"
                                                        message:@"Failed, Try Again Later."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
//         send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseTransactionFailedNotification object:self userInfo:userInfo];
        //for retrying, enabling product request button
        [self.loader stopAnimating];
        [self.loader setHidden:YES];
        [self.backgroundButton setHidden:YES];
        [self.BGHideDownload setHidden:YES];
        [self.freeButton setHidden:NO];

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
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFreeStoryPackName:nil];
    [self setBackgroundImagesView:nil];
    [self setForegroundImagesView:nil];
    [self setLoader:nil];
    [self setFreeButton:nil];
    [self setBackgroundButton:nil];
    [self setProgressView:nil];
    [self setDownloadPercentageLabel:nil];
    [self setBGHideDownload:nil];
    [self setDownloadRectView:nil];
    [super viewDidUnload];
}

-(void)updateProgress:(float)progress{
//    NSLog(@"progress : %f",progress);
    self.downloadPercentageLabel.text = [NSString stringWithFormat:@"Downloading %0.0f%%",(progress*100)];
    [self.progressView setProgress:progress animated:YES];
    [self.progressView setProgressTintColor:[UIColor blueColor]];
}

@end
