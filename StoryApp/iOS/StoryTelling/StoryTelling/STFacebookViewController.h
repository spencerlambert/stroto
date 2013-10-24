//
//  STFacebookViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 04/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <FacebookSDK/FacebookSDK.h>
#include <FacebookSDK/FBSession.h>
#include <FacebookSDK/FBRequest.h>
#include <FacebookSDK/FBRequestConnection.h>
#include <Social/Social.h>
#include <social/SLComposeViewController.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "STListStoryiPad.h"
#import "CreateStoryRootViewController.h"

@interface STFacebookViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,STListStoryiPadDelegate,CreateStoryRootViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *storyTitle;
@property (weak, nonatomic) IBOutlet UITextField *storySubTitle;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIProgressView *uploadProgressBar;
@property (strong, nonatomic) NSString *filepath;
@property (weak, nonatomic) NSString *storyTitleString;
@property (weak, nonatomic) NSString *storySubTitleString;
@property NSString *dbname;
@property (weak, nonatomic) IBOutlet UIButton *greyBGButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;
- (IBAction)uploadStory:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet STListStoryiPad *listViewiPad;
@property (weak, nonatomic) STListStoryiPad *storyListiPad;
@property BOOL iQuit1;


@end
