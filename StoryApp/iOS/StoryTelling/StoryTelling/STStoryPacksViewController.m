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

-(void)viewDidLoad{
    self.navigationItem.hidesBackButton = YES;//disabling back navigation
    //########################################################################
    //json retrieval
    
    [self performSelector:@selector(jsonPost:andBool:) withObject:paidBody withObject:@(1)]; //bool ispaid=YES
    
    [self performSelector:@selector(jsonPost:andBool:) withObject:freeBody withObject:@(0)];  //bool ispaid=NO
   
    
    //########################################################################
    //showing images in scroll views
    float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [paidStoryPacksView bounds].size.width;
    UIScrollView *paidStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [paidStoryPacksHolder setCanCancelContentTouches:NO];
    [paidStoryPacksHolder setClipsToBounds:YES];
    float xPosition = THUMB_H_PADDING;
    
//    for (int i = 0; i<[[self paidJson]valueForKey:[@"st_list"] count];i++) {
//        STImage *stimage = [[self paidImages]objectAtIndex:i];
//        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
//        click.numberOfTapsRequired = 1;
//        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage ];
//        CGRect frame = [thumbView frame];
//        frame.origin.y = THUMB_V_PADDING;
//        frame.origin.x = xPosition;
//        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
//        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
//        [thumbView setFrame:frame];
//        [thumbView setUserInteractionEnabled:YES];
//        [thumbView addGestureRecognizer:click];
//        [thumbView setTag:i];
//        [ForegroundImagesHolder addSubview:thumbView];
//        [thumbView setUserInteractionEnabled:YES];
//        xPosition += (frame.size.width + THUMB_H_PADDING);
//        selectedforegroundimage = 0;
//    }
    
    [paidStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in paidStoryPacksView.subviews){
        [view removeFromSuperview];
    }
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
    //###########################################################################
    
    
}
-(void)jsonPost:(NSString*)body andBool:(BOOL)isPaid
{NSString *urlAsString = @"http://storypacks.stroto.com";
    // urlAsString = [urlAsString stringByAppendingString:@"?param1=First"]; urlAsString = [urlAsString stringByAppendingString:@"&param2=Second"];
    
    NSURL *url = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    //[urlRequest setTimeoutInterval:30.0f];
    
    [urlRequest setHTTPMethod:@"POST"];

    [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
   
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:queue completionHandler:^(NSURLResponse *response,
                                                                       NSData *data, NSError *error) {
                                           if ([data length] >0 && error == nil){
                                               NSLog(@"isPaid= %c",isPaid);
                                               if(isPaid)
                                              {
                                                  paidJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                  NSLog(@"paid_st_list = %@",[paidJson valueForKey:@"st_list"]);
                                                  NSLog(@"paidList_count = %d",[[[self paidJson]valueForKey:@"st_list"] count]);

                                              }
                                              else
                                              {
                                                  freeJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
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
