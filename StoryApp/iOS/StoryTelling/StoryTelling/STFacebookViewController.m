//
//  STFacebookViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 04/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STFacebookViewController.h"

#define ST_FACEBOOK_APP_ID @"530535203701796"
@interface STFacebookViewController ()

@end

@implementation STFacebookViewController
@synthesize storyTitle;
@synthesize storySubTitle;
@synthesize uploadButton;
@synthesize uploadProgressBar;
@synthesize filepath;
@synthesize storySubTitleString;
@synthesize storyTitleString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    if (!FBSession.activeSession.isOpen)
    {
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_stream", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }

        }];


    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.storyTitle.text = storyTitleString;
    self.storySubTitle.text = storySubTitleString;
//    NSLog (@"self.storyTitle.text = %@",self.storyTitle.text);
//    NSLog (@"self.storySubTitle.text = %@",self.storySubTitle.text);
//    NSLog (@"self.filepath = %@",self.filepath);
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField

{
    [storyTitle resignFirstResponder];
    [storySubTitle resignFirstResponder];
    return  YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadStory:(UIButton *)sender {
//       [FBSession.activeSession closeAndClearTokenInformation];
    if (FBSession.activeSession.isOpen) {
        NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filepath isDirectory:NO];
        NSData *videoData = [NSData dataWithContentsOfFile:filepath];
        NSDictionary *videoObject = @{
                                      @"title":storyTitleString,
                                      @"description": storySubTitleString,
                                      [pathURL absoluteString]: videoData
                                      };
        FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/videos" parameters:videoObject HTTPMethod:@"POST"];
        [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error)
                NSLog(@"Done: %@", result);
            else
                NSLog(@"Error: %@", error.localizedDescription);
        }];
        
    }
    else{
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"publish_stream", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            NSURL *pathURL = [[NSURL alloc]initFileURLWithPath:filepath isDirectory:NO];
            NSData *videoData = [NSData dataWithContentsOfFile:filepath];
            NSDictionary *videoObject = @{
                                          @"title":storyTitleString,
                                          @"description": storySubTitleString,
                                          [pathURL absoluteString]: videoData
                                          };
            FBRequest *uploadRequest = [FBRequest requestWithGraphPath:@"me/videos" parameters:videoObject HTTPMethod:@"POST"];
            [uploadRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error)
                    NSLog(@"Done: %@", result);
                else
                    NSLog(@"Error: %@", error.localizedDescription);
            }];

            
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
        }];
        
    }
}
@end
