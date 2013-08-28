//
//  STStoryPackViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
#define THUMB_HEIGHT 55
#define THUMB_V_PADDING 3
#define THUMB_H_PADDING 8
#define LABEL_HEIGHT 30
#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define paidBody [NSString stringWithFormat:@"{\"st_request\":\"get_paid_list\"}"]
#define freeBody [NSString stringWithFormat:@"{\"st_request\":\"get_free_list\"}"]
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

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
    [self.loader setHidden:FALSE];
    [self.loader startAnimating];
    //########################################################################
    //json retrieval
//    [self performSelectorOnMainThread:@selector(jsonPost) withObject:nil waitUntilDone:YES];
    [self performSelectorInBackground:@selector(jsonPost) withObject:nil];
    //########################################################################
    //loading scroll view
   // [self reloadPaidView];
//    [self performSelectorOnMainThread:@selector(reloadPaidView) withObject:nil waitUntilDone:NO];
    //[self reloadFreeView];
//    [self performSelectorOnMainThread:@selector(reloadFreeView) withObject:nil waitUntilDone:NO];
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
    [self reloadPaidView];
    [self reloadFreeView];
}

-(void)reloadPaidView
{
    
    //showing images in scroll views
   // float scrollViewHeight = THUMB_HEIGHT + 2*THUMB_V_PADDING+LABEL_HEIGHT;
    float scrollViewHeight = [paidStoryPacksView bounds].size.height;
    float scrollViewWidth  = [paidStoryPacksView bounds].size.width;
    float __block xPosition = THUMB_H_PADDING;
    UIScrollView *paidStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [paidStoryPacksHolder setCanCancelContentTouches:NO];
    [paidStoryPacksHolder setClipsToBounds:NO];
    for(UIView *view in paidStoryPacksView.subviews){
        [view removeFromSuperview];
    }
    [paidStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [paidStoryPacksHolder setHidden:NO];
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
    while(!paidJson){
        NSLog(@"NUll in paidJSON");
        continue;}
    for (int i = 0; i<[[paidJson valueForKey:@"st_list"] count];i++) {
        
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
    UIImage *image = [UIImage imageWithData:data];
    STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
     UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
     click.numberOfTapsRequired = 1;
        
        //showing thubnail images
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setHidden:NO];
       // [thumbView addGestureRecognizer:click];
        [thumbView setTag:i];
       // [thumbView setUserInteractionEnabled:YES];
        [paidStoryPacksHolder addSubview:thumbView];
        
        //setting storyPackName
        UILabel *storyPackName = [[UILabel alloc] init];
        CGRect textFrame = frame;
        textFrame.origin.y += frame.size.height + THUMB_V_PADDING;
        textFrame.size.height = LABEL_HEIGHT;
        [storyPackName setOpaque:NO];
        [storyPackName setBackgroundColor:nil];
        [storyPackName setTextColor:[UIColor whiteColor]];
        [storyPackName setFont:[UIFont fontWithName:@"System" size:8.5]];
        [storyPackName setNumberOfLines:0];
       
//        [storyPackName setLineBreakMode:NSLineBreakByTruncatingTail];
//        [storyPackName setTranslatesAutoresizingMaskIntoConstraints:YES];
        [storyPackName adjustsFontSizeToFitWidth];
        //[storyPackName textRectForBounds:textFrame limitedToNumberOfLines:0];
       
        storyPackName.text = [[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Name"];
        [storyPackName setFrame:textFrame];
        [storyPackName setTag:i];
//        [storyPackName setUserInteractionEnabled:YES];
        [storyPackName setHidden:NO];
        
        //selectedforegroundimage = 0;
        [paidStoryPacksHolder addSubview:storyPackName];
        xPosition += (frame.size.width + THUMB_H_PADDING);
            
                 }
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
    //###########################################################################
}
-(void)reloadFreeView
{
    //showing images in scroll views
    float scrollViewHeight = THUMB_HEIGHT + 2*THUMB_V_PADDING+LABEL_HEIGHT;
    float scrollViewWidth  = [freeStoryPacksView bounds].size.width;
    UIScrollView *freeStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [freeStoryPacksHolder setCanCancelContentTouches:NO];
    [freeStoryPacksHolder setClipsToBounds:NO];
    float __block xPosition = THUMB_H_PADDING;
    while(!freeJson){
        NSLog(@"NUll in freeJSON");
        continue;} ///waiting for getting data from server
    for (int i = 0; i<[[freeJson valueForKey:@"st_list"] count];i++) {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]]; //getting image data
        
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
         click.numberOfTapsRequired = 1;
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
       // [thumbView setUserInteractionEnabled:YES];
        [thumbView setHidden:NO];
        //[thumbView addGestureRecognizer:click];
        [thumbView setTag:i];
        [freeStoryPacksHolder addSubview:thumbView];
        
        //setting storyPackName
        UILabel *storyPackName = [[UILabel alloc] init];
        CGRect textFrame = frame;
        textFrame.origin.y += frame.size.height + THUMB_V_PADDING;
        textFrame.size.height = LABEL_HEIGHT;
        [storyPackName setBackgroundColor:nil];
        [storyPackName setTextColor:[UIColor whiteColor]];
        [storyPackName setFont:[UIFont fontWithName:@"System" size:5.0]];
        [storyPackName setOpaque:NO];
       
        [storyPackName setNumberOfLines:0];
//        [storyPackName setLineBreakMode:NSLineBreakByTruncatingTail];
        [storyPackName adjustsFontSizeToFitWidth];
        [storyPackName adjustsLetterSpacingToFitWidth];
//        [storyPackName setTranslatesAutoresizingMaskIntoConstraints:YES];

        //[storyPackName textRectForBounds:textFrame limitedToNumberOfLines:2];
        
        storyPackName.text = [[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Name"];
        [storyPackName setFrame:textFrame];
        [storyPackName setTag:i];
        //[storyPackName setFont:[UIFont fontWithName:@"System" size:8]];
//        [storyPackName setUserInteractionEnabled:YES];
        [storyPackName setHidden:NO];
        
        [freeStoryPacksHolder addSubview:storyPackName];
        xPosition += (frame.size.width + THUMB_H_PADDING);
        //selectedforegroundimage = 0;
    }
    [freeStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in freeStoryPacksView.subviews){
        [view removeFromSuperview];
    }
    [freeStoryPacksHolder setHidden:NO];
    [freeStoryPacksView addSubview:freeStoryPacksHolder];
    
    [self.loader stopAnimating];
    [self.loader setHidden:TRUE];
    //###########################################################################
}
-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    
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
