//
//  STPaidStoryPacksViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define paidDetailsBody [NSString stringWithFormat:@"{\"st_request\":\"get_story_details\",\"st_story_id\":\"%d\"}",storyPackID]
#define appleReceipt [NSString stringWithFormat:@"{\"st_request\":\"purchase\",\"st_story_id\":\"%d\",\"apple_receipt\":\"%@\"}",storyPackID,appleReceiptData]

#define THUMB_HEIGHT 80
#define THUMB_V_PADDING 6
#define THUMB_H_PADDING 8

#import "STPaidStoryPacksViewController.h"
#import "STStoryPackDownload.h"
#import <QuartzCore/QuartzCore.h>
#import "STInstalledStoryPacksViewController.h"

@interface STPaidStoryPacksViewController () 
@end

@implementation STPaidStoryPacksViewController

@synthesize storyPackID;
@synthesize paidStoryPackDetailsJson;
@synthesize paidStoryPackURLJson;
@synthesize paidProduct;
@synthesize paidButtonLabel;
@synthesize buyPackButton;
@synthesize backgroundButton;
@synthesize paidStoryPackName;
@synthesize backgroundImagesView;
@synthesize foregroundImagesView;


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
    NSLog(@"paidStorypackID = %d",self.storyPackID);
    [self.buyPackButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.buyPackButton.layer.borderWidth = 1.0f;
    [self.buyPackButton.layer setCornerRadius:10.0f];
    [self.paidButtonLabel setHidden:YES];
    //Activity Indicator
    [self.loader setHidden:FALSE];
    [self.loader startAnimating];
    [self performSelectorInBackground:@selector(paidJsonDetails) withObject:nil];
}
-(void) paidJsonDetails
{
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    //        [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPBody:[paidDetailsBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){        
                paidStoryPackDetailsJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                 NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
                                    NSLog(@"html= %@",html);
                   }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); }
    }];
    while(!paidStoryPackDetailsJson){       //checking for data
        //        NSLog(@"NUll in paidStoryPackDetailsJson");
        continue;}
    
    paidStoryPackName.text = [NSString stringWithFormat:@"%@",[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"Name"]];
    [paidButtonLabel setTitle:[NSString stringWithFormat:@"$%@",[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"Price"]] forState:UIControlStateNormal];
    [self performSelectorInBackground:@selector(reloadBackgroundImages) withObject:nil];
    [self reloadForegroundImages];
}
-(void)reloadBackgroundImages
{
  if([[paidStoryPackDetailsJson valueForKey:@"st_bg_list"]count])
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
    [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [backgroundImagesHolder setHidden:NO];
    [backgroundImagesView addSubview:backgroundImagesHolder];
    while(!paidStoryPackDetailsJson){       //checking for data
        //        NSLog(@"NUll in paidJSON");
        continue;}
    for (int i = 0; i<[[paidStoryPackDetailsJson valueForKey:@"st_bg_list"]count];i++)
    {
         NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[paidStoryPackDetailsJson valueForKey:@"st_bg_list"] objectAtIndex:i ] valueForKey:@"ThumbnailURL" ]]];
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
//    } //testing is needed.
    [backgroundImagesView addSubview:backgroundImagesHolder];
  }
}

-(void)reloadForegroundImages
{
    if([[paidStoryPackDetailsJson valueForKey:@"st_fg_list"]count])
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
    [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [foregroundImagesHolder setHidden:NO];
    [foregroundImagesView addSubview:foregroundImagesHolder];
    while(!paidStoryPackDetailsJson){       //checking for data
        //        NSLog(@"NUll in paidJSON");
        continue;}
    for (int i = 0; i<[[paidStoryPackDetailsJson valueForKey:@"st_fg_list"]count];i++)
    {
         NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[paidStoryPackDetailsJson valueForKey:@"st_fg_list"] objectAtIndex:i ] valueForKey:@"ThumbnailURL" ]]];
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
//    } //testing is needed.
    [foregroundImagesView addSubview:foregroundImagesHolder];
    }
    //stoping activity indicator
    [self.loader stopAnimating];
    [self.loader setHidden:TRUE];
    [self.paidButtonLabel setHidden:NO];
    
}
#pragma mark - In App Purchase
- (IBAction)buyButtonTapped:(id)sender
{
    NSSet * productIdentifiers = [NSSet setWithObject:[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]];
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
}
-(IBAction)buyPack:(id)sender{
    SKPayment *paidPayment = [SKPayment paymentWithProduct:paidProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:paidPayment];
    NSLog(@"observationInfo : %@",[[SKPaymentQueue defaultQueue] observationInfo]);
}

- (IBAction)showPrice:(UIButton *)sender {
    //touched Background
    [self.buyPackButton setHidden:YES];
    [self.backgroundButton setHidden:YES];
    [self.paidButtonLabel setHidden:NO];

}

#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    paidProduct = [response.products objectAtIndex:0];
    NSLog(@"Product Title : %@",[[response.products objectAtIndex:0] localizedTitle]);
    NSLog(@"product description : %@", [[response.products objectAtIndex:0] productIdentifier]);
    NSLog(@"Product Price %f", [[response.products objectAtIndex:0] price].floatValue);
    NSLog(@"invalidProductIdentifiers : %@",response.invalidProductIdentifiers);
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseProductsFetchedNotification object:self userInfo:nil];
}

-(void)requestDidFinish:(SKRequest *)request
{
//working of buy buttons
    [self.paidButtonLabel setHidden:YES];
    [self.buyPackButton setHidden:NO];
    [self.backgroundButton setHidden:NO];
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products : %@",error);
    if(error)
    {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Apple server down, try again later..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
//for retrying, enabling product request button
    [self.buyPackButton setHidden:YES];
    [self.backgroundButton setHidden:YES];
    [self.paidButtonLabel setHidden:NO];
}

#pragma mark - SKPaymentTransactionObserver Protocol Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"paymentQueue:(SKPaymentQueue *)queue updatedTransactions");
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
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
    [self finishTransaction:transaction wasSuccessful:YES];
    
    //    STInstalledStoryPacksViewController *installController =
    //    [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
    //                               bundle:NULL] instantiateViewControllerWithIdentifier:@"installedStoryPacks"];
    //    
    //    [self.navigationController pushViewController:installController animated:YES];
    
}
// sends the receipt to json server.
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"recordTransaction");
    if ([transaction.payment.productIdentifier isEqualToString:[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]])
    {
        [self.loader startAnimating];
        NSLog(@"Receipt from transaction : %@",transaction.transactionReceipt);
        [self sendReceipt:transaction.transactionReceipt];
    }
}
-(void) sendReceipt:(NSData*)appleReceiptData
{
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[appleReceipt dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"receipt ( inside sendReceipt:) : %@", appleReceipt);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            paidStoryPackURLJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            STStoryPackDownload *paidDownload = [[STStoryPackDownload alloc] init];
            [paidDownload downloadStoryPack:[NSString stringWithFormat:@"%@",[paidStoryPackURLJson valueForKey:@"st_storypack_url" ]]];
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
            NSLog(@"html= %@",html);
            [self.loader startAnimating];
            STInstalledStoryPacksViewController *installController =
            [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                       bundle:NULL] instantiateViewControllerWithIdentifier:@"installedStoryPacks"];
            installController.filePath = paidDownload.installedFilePath;
            [self.navigationController pushViewController:installController animated:YES];
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); }
    }];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Paid StoryPack Purchase"
                                                        message:@"Successful"
                                                       delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        NSLog(@"failed Transaction !!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Paid StoryPack Purchase"
                                                        message:@"Failed"
                                                       delegate:self
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
    [self setPaidButtonLabel:nil];
    [self setBackgroundImagesView:nil];
    [self setForegroundImagesView:nil];
    [self setPaidStoryPackName:nil];
    [self setLoader:nil];
    [self setBuyPackButton:nil];
    [self setBackgroundButton:nil];
    [super viewDidUnload];
}
@end
