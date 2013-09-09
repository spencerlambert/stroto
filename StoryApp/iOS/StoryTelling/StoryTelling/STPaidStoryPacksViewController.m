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

@interface STPaidStoryPacksViewController () <SKProductsRequestDelegate>
{
     NSArray *_products;
}
@end

@implementation STPaidStoryPacksViewController

@synthesize storyPackID;
@synthesize paidButtonLabel;
@synthesize paidStoryPackName;
@synthesize backgroundImagesView;
@synthesize foregroundImagesView;
@synthesize paidStoryPackDetailsJson;

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
    NSLog(@"paidStorypackID = %d",self.storyPackID);
    //Activity Indicator
    [self.paidButtonLabel setHidden:YES];
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
    [self buyButtonTapped:nil];
    paidStoryPackName.text = [NSString stringWithFormat:@"%@",[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"Name"]];
//    [paidButtonLabel setTitle:[NSString stringWithFormat:@"$%@",[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"Price"]] forState:UIControlStateNormal];
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
    [self.paidButtonLabel setHidden:NO];
    
}
- (IBAction)buyButtonTapped:(id)sender
{
    NSSet * productIdentifiers = [NSSet setWithObject:[[paidStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]];
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
}
#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Product Title : %@",[[response.products objectAtIndex:0] localizedTitle]);
    NSLog(@"product description : %@", [[response.products objectAtIndex:0] productIdentifier]);
    NSLog(@"Product Price %f", [[response.products objectAtIndex:0] price].floatValue);
    [self.paidButtonLabel setTitle:[NSString stringWithFormat:@"%0.2f",
                                   [[response.products objectAtIndex:0] price].floatValue] forState:UIControlStateNormal];
    NSLog(@"Product price locale : %@",[[response.products objectAtIndex:0] priceLocale]);
    NSLog(@"invalidProductIdentifiers : %@",response.invalidProductIdentifiers);
}

-(void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"Loading request.description : %@",request.description);
    NSLog(@"Request : %@",request);
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products : %@",error);
    if(error)
    {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Apple server down, try again later..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

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
