//
//  STStoryPackViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
#define THUMB_HEIGHT 57
#define THUMB_V_PADDING 3
#define THUMB_H_PADDING 8
#define NAME_LABEL_HEIGHT 25
#define PRICE_LABEL_HEIGHT 10
#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define paidBody [NSString stringWithFormat:@"{\"st_request\":\"get_paid_list\"}"]
#define freeBody [NSString stringWithFormat:@"{\"st_request\":\"get_free_list\"}"]

#import "STStoryPacksViewController.h"
#import "STPaidStoryPacksViewController.h"
#import "STFreeStoryPacksViewController.h"

@implementation STStoryPacksViewController
@synthesize installedStoryPacksView;
@synthesize paidStoryPacksView;
@synthesize freeStoryPacksView;

@synthesize paidJson;
@synthesize freeJson;

@synthesize installedImages;//to be used later

//@synthesize testImageView;
-(void)viewDidLoad{
//disabling back navigation
    self.navigationItem.hidesBackButton = YES;
//Activity Indicator
    [self.loader setHidden:FALSE];
    [self.loader startAnimating];
//json retrieval
    [self performSelectorInBackground:@selector(jsonPost) withObject:nil];
}

-(void)jsonPost

{
    BOOL isPaid = NO;
    NSString *body = freeBody;
    int i = 0;
    while(i<=1)
    {
//        returning only some packs when put outside of while
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
//        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
            if ([data length] >0 && error == nil){
                if(isPaid)
                {
                    paidJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                   NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
//                    NSLog(@"inside YES, isPaid= %c",isPaid);
//                    NSLog(@"html= %@",html);
//                    NSLog(@"paid_st_list = %@",[paidJson valueForKey:@"st_list"]);
//                    NSLog(@"paidList_count = %d",[[[self paidJson]valueForKey:@"st_list"] count]);
                }
                else
                {
                    freeJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                    NSLog(@"inside NO, isPaid= %c",isPaid);
//                    NSLog(@"free_st_list = %@",[freeJson valueForKey:@"st_list"]);
//                    NSLog(@"free_list_count = %d",[[[self freeJson]valueForKey:@"st_list"] count]);
                }
            }
            else if ([data length] == 0 && error == nil){
                NSLog(@"Nothing was downloaded.");
            }
            else if (error != nil){
                NSLog(@"Error happened = %@", error); }
      }];
        i++;
        isPaid = YES;
        body = paidBody;
    }
    [self reloadPaidView];
    [self reloadFreeView];
}

-(void)reloadPaidView
{
//for showing paid story packs in scroll view
    
//    float scrollViewHeight = THUMB_HEIGHT + 3*THUMB_V_PADDING+NAME_LABEL_HEIGHT+PRICE_LABEL_HEIGHT;
    float scrollViewHeight = [paidStoryPacksView bounds].size.height;
    float scrollViewWidth  = [paidStoryPacksView bounds].size.width;
//    [paidStoryPacksView setBackgroundColor:[UIColor whiteColor]];
    float __block xPosition = THUMB_H_PADDING;
    UIScrollView *paidStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [paidStoryPacksHolder setCanCancelContentTouches:NO];
    [paidStoryPacksHolder setClipsToBounds:NO];
    for(UIView *view in paidStoryPacksView.subviews)
    [view removeFromSuperview];
    [paidStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [paidStoryPacksHolder setHidden:NO];
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
    while(!paidJson){       //checking for data
//        NSLog(@"NUll in paidJSON");
     continue;}
    for (int i = 0; i<[[paidJson valueForKey:@"st_list"] count];i++)
    {
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
//showing paid story pack's thubnail images
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setHidden:NO];
        [thumbView setTag:i];
        
//Implementing Tap on thumbnails
        
        
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        click.numberOfTapsRequired = 1;
        [thumbView addGestureRecognizer:click];
        [thumbView setUserInteractionEnabled:YES];
        
        [paidStoryPacksHolder addSubview:thumbView];
//showing storyPackName for paid packs
        UILabel *storyPackName = [[UILabel alloc] init];
        CGRect textFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + THUMB_V_PADDING, frame.size.width, NAME_LABEL_HEIGHT);
        [storyPackName setOpaque:NO];
        [storyPackName setBackgroundColor:nil];
        [storyPackName setTextColor:[UIColor whiteColor]];
        [storyPackName setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
        [storyPackName setNumberOfLines:2];
        storyPackName.text = [[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Name"];
//        storyPackName.text = @"Goldilocks and The three Bears";//test largest name!
        [storyPackName setFrame:textFrame];
        [storyPackName setTag:i];
        [storyPackName setHidden:NO];
        
//implementing tap on name label
        
        
//        [storyPackName addGestureRecognizer:click];
//        [storyPackName setUserInteractionEnabled:YES];
        
//        selectedforegroundimage = 0;
        [paidStoryPacksHolder addSubview:storyPackName];
//price display for paid story packs.
        UILabel *storyPackPrice = [[UILabel alloc] init];
        CGRect priceTextFrame = CGRectMake(frame.origin.x, textFrame.origin.y+textFrame.size.height+THUMB_V_PADDING, frame.size.width, PRICE_LABEL_HEIGHT);
        [storyPackPrice setOpaque:NO];
        [storyPackPrice setBackgroundColor:nil];
        [storyPackPrice setTextColor:[UIColor whiteColor]];
        [storyPackPrice setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
        [storyPackPrice setNumberOfLines:1];
        storyPackPrice.text = [NSString stringWithFormat:@"$%@",[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Price"]];
        [storyPackPrice setFrame:priceTextFrame];
        [storyPackPrice setTag:i];
        [storyPackPrice setHidden:NO];
//        implementing tap on price label
//        [storyPackPrice addGestureRecognizer:click];
//        [storyPackPrice setUserInteractionEnabled:YES];
        //selectedStoryPack = 0;
        [paidStoryPacksHolder addSubview:storyPackPrice];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
//    [paidStoryPacksHolder setAlpha:0.5]; //for knowing the bounds
//    [paidStoryPacksHolder setBackgroundColor:[UIColor blueColor]];  //for knowing the bounds
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
}
-(void)reloadFreeView
{
//for showing free story packs in scroll view

//    float scrollViewHeight = THUMB_HEIGHT + 4*THUMB_V_PADDING+NAME_LABEL_HEIGHT;
    float scrollViewHeight = [freeStoryPacksView bounds].size.height;
    float scrollViewWidth  = [freeStoryPacksView bounds].size.width;
//    [freeStoryPacksView setBackgroundColor:[UIColor whiteColor]];//for knowing the bounds
    UIScrollView *freeStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [freeStoryPacksHolder setCanCancelContentTouches:NO];
    [freeStoryPacksHolder setClipsToBounds:NO];
    float __block xPosition = THUMB_H_PADDING;
    while(!freeJson){
//        NSLog(@"NUll in freeJSON");
        continue;} ///waiting for getting data from server
    for (int i = 0; i<[[freeJson valueForKey:@"st_list"] count];i++)
    {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]]; //getting image data
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
//showing free story packs thumbnails
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setHidden:NO];
//implementing Tap on storypack thumbnails
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        click.numberOfTapsRequired = 1;
        [thumbView addGestureRecognizer:click];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setTag:i];
        [freeStoryPacksHolder addSubview:thumbView];
//showing storyPackName
        UILabel *storyPackName = [[UILabel alloc] init];
        CGRect textFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + THUMB_V_PADDING, frame.size.width, NAME_LABEL_HEIGHT);
        [storyPackName setBackgroundColor:nil];
        [storyPackName setTextColor:[UIColor whiteColor]];
        [storyPackName setFont:[UIFont fontWithName:@"Helvetica" size:10.0]];
        [storyPackName setOpaque:NO];
        [storyPackName setNumberOfLines:2];
        storyPackName.text = [[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Name"];
        [storyPackName setFrame:textFrame];
        [storyPackName setTag:i];
//implementing tap on storypack name
//        [storyPackName addGestureRecognizer:click];
//        [storyPackName setUserInteractionEnabled:YES];
        [storyPackName setHidden:NO];
        [freeStoryPacksHolder addSubview:storyPackName];
        xPosition += (frame.size.width + THUMB_H_PADDING);
        //selectedStoryPack = 0;
    }
    [freeStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in freeStoryPacksView.subviews){
        [view removeFromSuperview];
    }
    [freeStoryPacksHolder setHidden:NO];
//    [freeStoryPacksHolder setAlpha:0.5];//for knowing the bounds
//    [freeStoryPacksHolder setBackgroundColor:[UIColor blueColor]];//for knowing the bounds
    [freeStoryPacksView addSubview:freeStoryPacksHolder];
//stoping activity indicator
    [self.loader stopAnimating];
    [self.loader setHidden:TRUE];
    
}
-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    STPaidStoryPacksViewController *paidStoryPacks = [storyboard instantiateViewControllerWithIdentifier:@"paidStoryPacks"];
    [self.navigationController pushViewController:paidStoryPacks animated:YES];
//      [self presentViewController:paidStoryPacks animated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setInstalledStoryPacksView:nil];
    [self setPaidStoryPacksView:nil];
    [self setFreeStoryPacksView:nil];
    [self setLoader:nil];
    [super viewDidUnload];
}
- (IBAction)previousView:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
