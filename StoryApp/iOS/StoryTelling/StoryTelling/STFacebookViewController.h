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

@interface STFacebookViewController : UIViewController<FBRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *storyTitle;
@property (weak, nonatomic) IBOutlet UITextField *storySubTitle;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) NSString *filepath;
- (IBAction)uploadStory:(UIButton *)sender;

@end
