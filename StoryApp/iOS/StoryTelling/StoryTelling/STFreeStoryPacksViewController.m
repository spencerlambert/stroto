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
#define THUMB_HEIGHT 80
#define THUMB_V_PADDING 6
#define THUMB_H_PADDING 8

#import "STFreeStoryPacksViewController.h"
#import "STStoryPackDownload.h"

@interface STFreeStoryPacksViewController ()
@end

@implementation STFreeStoryPacksViewController

@synthesize freeStoryPackDetailsJson;
@synthesize freeStoryPackURL;
@synthesize storyPackID;
@synthesize freeStoryPackName;
@synthesize freeButton;
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
//    NSLog(@"freeStoryPackID = %d",self.storyPackID);
    [self.freeButton setHidden:YES];
    [self.loader setHidden:FALSE];
    [self.loader startAnimating];
    [self performSelectorInBackground:@selector(freeJsonDetails) withObject:nil];
}
-(void)freeJsonDetails
{
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    //        [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPBody:[freeDetailsBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            freeStoryPackDetailsJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
//            NSLog(@"html= %@",html);
            NSLog(@"st_details = %@",[freeStoryPackDetailsJson valueForKey:@"st_details"]);
            NSLog(@"Background Images:%@",[freeStoryPackDetailsJson valueForKey:@"st_bg_list"]);
//            NSLog(@"Single Image = %@",[[freeStoryPackDetailsJson valueForKey:@"st_bg_list"] objectAtIndex:0 ]);
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error); }
    }];
    while(!freeStoryPackDetailsJson){       //checking for data
        //        NSLog(@"NUll in freeStoryPackDetailsJson");
        continue;}
    freeStoryPackName.text = [NSString stringWithFormat:@"%@",[[freeStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"Name"]];
    [self reloadBackgroundImages];
    [self reloadForegroundImages];
    [self.freeButton setHidden:NO];

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
    [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [backgroundImagesHolder setHidden:NO];
    [backgroundImagesView addSubview:backgroundImagesHolder];
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
    [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [foregroundImagesHolder setHidden:NO];
    [foregroundImagesView addSubview:foregroundImagesHolder];
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
- (IBAction)buyButtonTapped:(id)sender
{
    NSSet * productIdentifiers = [NSSet setWithObject:[[freeStoryPackDetailsJson valueForKey:@"st_details"] valueForKey:@"AppleStoreKey"]];
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
}

#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Product Title : %@",[[response.products objectAtIndex:0] localizedTitle]);
    NSLog(@"product description : %@", [[response.products objectAtIndex:0] productIdentifier]);
    NSLog(@"invalidProductIdentifiers : %@",response.invalidProductIdentifiers);
}

-(void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"requestDidFinish : %@",request.description);
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products : %@",error);
    if(error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Apple server down, Do you want to download from our server ?? " delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        [alert show];
        alert.delegate = self;
    }

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex = %d",buttonIndex);
    if (buttonIndex == 0) {
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[AppleServerError dataUsingEncoding:NSUTF8StringEncoding]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            freeStoryPackURL = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            STStoryPackDownload *freedownload = [[STStoryPackDownload alloc] init];
            [freedownload downloadStoryPack:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[freeStoryPackURL valueForKey:@"st_storypack_url" ]]]];
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
    [super viewDidUnload];
}
@end
