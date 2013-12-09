//
//  ViewController.m
//  StrotoBasic
//
//  Created by Nandakumar on 29/10/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))

#define THUMB_HEIGHT (IS_IPAD ? 305 : 130)
#define THUMB_V_PADDING (IS_IPAD ? 30 : 20)
#define THUMB_H_PADDING (IS_IPAD ? 25 : 18)
#define RADIUS (IS_IPAD ? 25 :15 )

#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define freeBody [NSString stringWithFormat:@"{\"st_request\":\"get_free_list\"}"]
#define basic [NSString stringWithFormat:@"{\"st_request\":\"purchase\",\"st_story_id\":\"%d\",\"apple_receipt\":\"BASIC VERSION\"}",storyPackID]

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
{
    BOOL internetAvailable;
    NSDictionary *jsonData;
}

@synthesize storyPacksView;
@synthesize basicJsonDict;
@synthesize spinner;
@synthesize loadingLabel;
@synthesize storyPackID;

float scrollViewHeight,scrollViewWidth,xPosition,yPosition;
UIScrollView *storyPacksHolder;

-(void)viewWillAppear:(BOOL)animated
{

 }
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self startSpin];
    basicJsonDict = [[NSDictionary alloc] init];
    [self performSelector:@selector(startRequest) withObject:nil afterDelay:1];
    [self performSelector:@selector(showStoryPacks) withObject:nil afterDelay:3];
    [self performSelector:@selector(dismissLoader) withObject:nil afterDelay:60];
}
-(void)startRequest
{
    internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
    if(internetAvailable)
    {
        NSLog(@"internet Available");
        [self performSelectorOnMainThread:@selector(jsonRequest:) withObject:freeBody waitUntilDone:1];
    }
    else{
        NSLog(@"internet Unavailable");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self stopSpin];
    }
 
}

-(void)dismissLoader{
    [self stopSpin];
    [((AppDelegate *)[[UIApplication sharedApplication]delegate]) internetAvailableNotifier];
    internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
    //    NSLog(@"internet availability : %hhd", ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable);
    if (!internetAvailable){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self stopSpin];
    }
}

-(void)startSpin
{
    //start activity indicator
    [self.spinner startAnimating];
    [self.spinner setHidden:NO];
    [self.loadingLabel setHidden:NO];
}

-(void)stopSpin
{
    //stop activity indicator
    [self.spinner stopAnimating];
    [self.spinner setHidden:YES];
    [self.loadingLabel setHidden:YES];
}

- (void) jsonRequest:(NSString *)body{
    jsonData = [[NSDictionary alloc] init];
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15 ];
    NSData *requestData = [NSData dataWithBytes:[body UTF8String] length:[body length]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error) {
            if ([data length] >0 && error == nil){
                jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"jsonData : %@",jsonData);
            }
            else if ([data length] == 0 && error == nil){
                NSLog(@"Nothing was downloaded.");
            }
            else if (error != nil){
                [self performSelectorOnMainThread:@selector(showAlert:) withObject:[error.userInfo objectForKey:NSLocalizedDescriptionKey] waitUntilDone:NO];
                NSLog(@"Error happened = %@", error);
                [self performSelectorOnMainThread:@selector(showError) withObject:nil waitUntilDone:YES];
            }
        }];
}

-(void)showStoryPacks
{
    basicJsonDict = jsonData;
    NSLog(@"basicjsonDict after: %@",jsonData);
    int count = [[basicJsonDict valueForKey:@"st_list"] count];
NSLog (@"number of story packs :%i",count);
    float holderWidth=0;
    scrollViewHeight = [storyPacksView bounds].size.height;
    scrollViewWidth  = [storyPacksView bounds].size.width;
    xPosition = (IS_IPAD ? 60 : THUMB_H_PADDING);
    yPosition = (IS_IPAD ? 30 : THUMB_V_PADDING);
    storyPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [storyPacksHolder setAutoresizesSubviews:YES];
//    [storyPacksHolder setBackgroundColor:[UIColor greenColor]];
    [storyPacksHolder setPagingEnabled:YES];
    [storyPacksHolder setBounces:YES];
    storyPacksHolder.tag = 1;
    [storyPacksHolder setCanCancelContentTouches:NO];
    [storyPacksHolder setClipsToBounds:NO];
    for(UIView *view in storyPacksView.subviews)
        [view removeFromSuperview];
    [storyPacksHolder setHidden:NO];
    int i=0;
    int page = 0;
    do
    {
    for(int k=0; k<3; k++)
    {
        for(int j=0; j<2;j++)
        {
            if(i== count)
            {
                [self stopSpin];
                break;
            }
        if([[[basicJsonDict valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"])
        {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[basicJsonDict valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
            UIImage *image = [UIImage imageWithData:data];
            UIImageView *thumbView = [[UIImageView alloc] initWithImage:image];
            thumbView.layer.cornerRadius = RADIUS;
            thumbView.clipsToBounds = YES;
            CGRect frame = [thumbView frame];
            [thumbView setContentMode:UIViewContentModeScaleAspectFit];
            frame.origin.y = yPosition;
            frame.origin.x = xPosition;//thumb_H_padding
            frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
            frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
            [thumbView setFrame:frame];
            [thumbView setUserInteractionEnabled:YES];
            [thumbView setHidden:NO];
            //setting tap.
            [thumbView setTag:i];
            UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
            click.numberOfTapsRequired = 1;
            [thumbView addGestureRecognizer:click];
            [thumbView setUserInteractionEnabled:YES];
            [storyPacksHolder addSubview:thumbView];
            xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
//          NSLog(@"Story i = %d ,\n xPos = %f , ypos = %f",i,xPosition,yPosition);
        }
            i++;
            if(i == count)
            {
                [self stopSpin];
                break;
            }
        }
         holderWidth +=xPosition;
//        xPosition = storyPacksView.bounds.size.width * page + THUMB_H_PADDING ;
        xPosition = storyPacksView.bounds.size.width * page + (IS_IPAD ? 60 : THUMB_H_PADDING);
        yPosition += (THUMB_HEIGHT + THUMB_V_PADDING);
//        yPosition += (THUMB_HEIGHT + 30);
        if(i == count)
        {
            [self stopSpin];
            break;
        }
}
        {
            page++;
//            xPosition = storyPacksView.bounds.size.width * page + THUMB_H_PADDING ;
            xPosition = storyPacksView.bounds.size.width * page + (IS_IPAD ? 60 : THUMB_H_PADDING) ;
//            yPosition = THUMB_V_PADDING;
            yPosition = (IS_IPAD ? 30 : THUMB_V_PADDING);
        }
//        NSLog(@"Width : %f",storyPacksView.bounds.size.width);
    holderWidth=storyPacksView.bounds.size.width*page;
    }while(page<=(count/6));
    [storyPacksHolder setContentSize:CGSizeMake(holderWidth, scrollViewHeight)];
//    NSLog(@"storyPacksHolder default autoresizesSubviews = %hhd",storyPacksHolder.autoresizesSubviews);
    [storyPacksView addSubview:storyPacksHolder];
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    NSLog(@"tag: %d",recognizer.view.tag);
//    [self startSpin];
    self.storyPackID = (int)[[[self.basicJsonDict valueForKey:@"st_list"] objectAtIndex:recognizer.view.tag] valueForKey:@"StoryPackID"];
//    [self performSelector:@selector(jsonRequest:) withObject:basic];
//    [self performSelector:@selector(callDownload) withObject:nil afterDelay:1];
}

-(void)callDownload
{
    STStoryPackDownload *freedownload = [[STStoryPackDownload alloc] init];
    [freedownload downloadStoryPack:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[jsonData valueForKey:@"st_storypack_url" ]]]];
    //    playViewController *playGround = [[playViewController alloc] init];
    // if(IS_IPAD)
    //     playGround = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"playGround"];
    //    else
    //        playGround = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"playGround"];
    //    playGround.dbName =storyPacksList[recognizer.view.tag];
    //    [self presentViewController:playGround animated:YES completion:nil];

}

-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) showError{
    UILabel *txtView = [[UILabel alloc] initWithFrame:IS_IPAD?CGRectMake(276, 487, 217, 50):CGRectMake(75, 170, 185, 50)];
    [txtView setTextAlignment:NSTextAlignmentJustified];
    [txtView setTextColor:[UIColor whiteColor]];
    [txtView setText:@"Can't reach Story Pack Server, please try again."];
    [txtView setNumberOfLines:IS_IPAD?2:3];
    [txtView setLineBreakMode:NSLineBreakByTruncatingTail];
    UIButton *button;
    button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Retry Server" forState:UIControlStateNormal];
    button.frame = IS_IPAD?CGRectMake(315, 529, 100, 40.0):CGRectMake(70, 200, 200.0, 60.0);
//    [txtView setBackgroundColor:[UIColor whiteColor]];
    [self.storyPacksView addSubview:txtView];
    [self.storyPacksView addSubview:button];
}

- (void) retry{
    [self jsonRequest:freeBody];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
