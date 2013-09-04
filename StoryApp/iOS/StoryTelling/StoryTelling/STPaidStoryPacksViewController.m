//
//  STPaidStoryPacksViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define paidDetailsBody [NSString stringWithFormat:@"{\"st_request\":\"get_story_details\",\"st_story_id\":\"%d\"}",storyPackID]
#define THUMB_HEIGHT 80
#define THUMB_V_PADDING 6
#define THUMB_H_PADDING 8

#import "STPaidStoryPacksViewController.h"
#import "STStoryPackIAPHelper.h"
#import <StoreKit/StoreKit.h>
@interface STPaidStoryPacksViewController () <SKProductsRequestDelegate>
{
     NSArray *_products;
}
@end

@implementation STPaidStoryPacksViewController

@synthesize paidStoryPackDetailsJson;
@synthesize storyPackID;
@synthesize paidButtonLabel;
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
//    self.navigationController.title = @"Story Packs";
    //for test white views
    [STStoryPackIAPHelper sharedInstance];
    NSLog(@"paidStorypackID = %d",self.storyPackID);
    NSLog(@"string Defined : %@",paidDetailsBody);
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
    [self reloadBackgroundImages];
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
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    //    [paidStoryPacksHolder setAlpha:0.5]; //for knowing the bounds
    //    [paidStoryPacksHolder setBackgroundColor:[UIColor blueColor]];  //for knowing the bounds
    for(UIView *view in backgroundImagesView.subviews){
        [view removeFromSuperview];
    }
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
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    //    [paidStoryPacksHolder setAlpha:0.5]; //for knowing the bounds
    //    [paidStoryPacksHolder setBackgroundColor:[UIColor blueColor]];  //for knowing the bounds
    for(UIView *view in foregroundImagesView.subviews){
        [view removeFromSuperview];
    }
    [foregroundImagesView addSubview:foregroundImagesHolder];
    }
    //stoping activity indicator
    [self.loader stopAnimating];
    [self.loader setHidden:TRUE];
    
}
//- (void)buyButtonTapped:(id)sender {
//    
//    UIButton *buyButton = (UIButton *)sender;
//    
//    NSSet * productIdentifier = [NSSet setWithObject:
//                                  @"free_sp_test_1",
//                                  nil];
////    NSSet * productIdentifiers = [NSSet setWithObject:[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]];
//    
//    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifier ];
//    
////    SKProduct *product = ;// change the tag to product ID
//    
////    NSLog(@"Buying %@...", product.productIdentifier);
////    [[STStoryPackIAPHelper sharedInstance] buyProduct:product];
//    
//}
- (IBAction)buyButtonTapped:(id)sender {
    
    //    UIButton *buyButton = (UIButton *)sender;
    
    //    NSSet * productIdentifiers = [NSSet setWithObject:[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]];

    NSSet * productIdentifiers = [NSSet setWithObjects:
                                  @"paid_sp_test_1",
                                  nil];
    
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
    
    //    SKProductsRequest *productReq =  [[IAPHelper alloc] initWithProductIdentifiers:productIdentifiers ];
    NSLog(@"response : %@",productReq.description );
    
    //    SKProduct *product = ;// change the tag to product ID
    
    //    NSLog(@"Buying %@...", product.productIdentifier);
    //    [[STStoryPackIAPHelper sharedInstance] buyProduct:product];
    
}

#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded List of Products");
    //    SKProductsRequest *productsRequest = nil;
    NSArray *skProducts = response.products;
    NSLog(@"response.products : %@",response.products);
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product : %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    //    _completionhandler(YES, skProducts);
    //    _completionhandler = nil;
}

-(void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"Loading request : %@",request.description);
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products : %@",error.description);
    //    _productsRequest = nil;
    //    _completionhandler(NO, nil);
    //    _completionhandler = nil;
    
}
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
    [super viewDidUnload];
}
@end
