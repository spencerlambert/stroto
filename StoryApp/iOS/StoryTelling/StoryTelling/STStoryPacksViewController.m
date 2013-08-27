//
//  STStoryPackViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define paidBody [NSString stringWithFormat:@"{\"st_request\":\"get_paid_list\"}"]
#define freeBody [NSString stringWithFormat:@"{\"st_request\":\"get_free_list\"}"]

#import "STStoryPacksViewController.h"

@implementation STStoryPacksViewController
@synthesize installedStoryPacksView;
@synthesize paidStoryPacksView;
@synthesize freeStoryPacksView;

@synthesize paidJson;
@synthesize freeJson;

@synthesize installedImages;
@synthesize paidImages;
@synthesize freeImages;

//@synthesize testImageView;
-(void)viewDidLoad{
    //disabling back navigation
    self.navigationItem.hidesBackButton = YES;
    
    //########################################################################
    //json retrieval
    [self performSelectorOnMainThread:@selector(jsonPost) withObject:nil waitUntilDone:YES];
    //########################################################################
    //loading scroll view
    [self reloadPaidView];
    [self reloadFreeView];
}
-(void)reloadPaidView
{
    //showing images in scroll views
    float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [paidStoryPacksView bounds].size.width;
    UIScrollView *paidStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [paidStoryPacksHolder setCanCancelContentTouches:NO];
    [paidStoryPacksHolder setClipsToBounds:NO];
    float xPosition = THUMB_H_PADDING;
    while(!paidJson){continue;}
    for (int i = 0; i<[[paidJson valueForKey:@"st_list"] count];i++) {
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
    UIImage *image = [UIImage imageWithData:data];
    STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
    //               UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    // click.numberOfTapsRequired = 1;
        
    //   testImageView.image = [UIImage imageWithData:stimage.imageData]; //test
        
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setHidden:NO];
//        [thumbView addGestureRecognizer:click];
        [thumbView setTag:i];
        [paidStoryPacksHolder addSubview:thumbView];
//        [thumbView setUserInteractionEnabled:YES];
        xPosition += (frame.size.width + THUMB_H_PADDING);
        //selectedforegroundimage = 0;
    }
    [paidStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in paidStoryPacksView.subviews){
        [view removeFromSuperview];
   }
    [paidStoryPacksHolder setHidden:NO];
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
    //###########################################################################
}
-(void)reloadFreeView
{
    //showing images in scroll views
    float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [freeStoryPacksView bounds].size.width;
    UIScrollView *freeStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [freeStoryPacksHolder setCanCancelContentTouches:NO];
    [freeStoryPacksHolder setClipsToBounds:NO];
    float xPosition = THUMB_H_PADDING;
    while(!freeJson){continue;}
    for (int i = 0; i<[[freeJson valueForKey:@"st_list"] count];i++) {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
        //               UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        // click.numberOfTapsRequired = 1;
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setHidden:NO];
        //        [thumbView addGestureRecognizer:click];
        [thumbView setTag:i];
        [freeStoryPacksHolder addSubview:thumbView];
        //        [thumbView setUserInteractionEnabled:YES];
        xPosition += (frame.size.width + THUMB_H_PADDING);
        //selectedforegroundimage = 0;
    }
    [freeStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in paidStoryPacksView.subviews){
        [view removeFromSuperview];
    }
    [freeStoryPacksHolder setHidden:NO];
    [paidStoryPacksView addSubview:freeStoryPacksHolder];
    //###########################################################################
}


-(void)jsonPost

{
    BOOL isPaid = NO;
    NSString *body = freeBody;
    int i = 0;
    while(i<=1)
    {
        //returning only some packs when put outside of while
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        //[urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
     NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
    if ([data length] >0 && error == nil){
                                               if(isPaid)
                                              {
                                                  paidJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding ];
                                                  //NSLog(@"inside YES, isPaid= %c",isPaid);
                                                  NSLog(@"html= %@",html);
                                                  NSLog(@"paid_st_list = %@",[paidJson valueForKey:@"st_list"]);
                                                  NSLog(@"paidList_count = %d",[[[self paidJson]valueForKey:@"st_list"] count]);

                                              }
                                              else
                                              {
                                                  freeJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  //NSLog(@"inside NO, isPaid= %c",isPaid);
                                                  NSLog(@"free_st_list = %@",[freeJson valueForKey:@"st_list"]);
                                                  NSLog(@"free_list_count = %d",[[[self freeJson]valueForKey:@"st_list"] count]);

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
}
- (void)viewDidUnload {
    [self setInstalledStoryPacksView:nil];
    [self setPaidStoryPacksView:nil];
    [self setFreeStoryPacksView:nil];
    [super viewDidUnload];
}
- (IBAction)previousView:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
