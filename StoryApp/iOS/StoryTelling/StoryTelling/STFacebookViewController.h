//
//  STFacebookViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 04/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <FacebookSDK/FacebookSDK.h>

@interface STFacebookViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *storyTitle;
@property (weak, nonatomic) IBOutlet UITextView *storySubTitle;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;


@end
