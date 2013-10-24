//
//  STYoutubeViewController.h
//  StoryTelling
//
//  Created by Aaswini on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLYouTube.h"
#import "STListStoryiPad.h"
@interface STYoutubeViewController : UIViewController<UITextFieldDelegate,STListStoryiPadDelegate>{
    NSString *clientID ;
    NSString *clientSecret;
    IBOutlet UIProgressView *uploadProgressIndicator;
}
@property (weak, nonatomic) IBOutlet UITextField *mainTitle;
@property (weak, nonatomic) IBOutlet UITextField *subTitle;
@property (strong, nonatomic) NSString *dbname;
@property (strong, nonatomic) NSString *maintitle;
@property (weak, nonatomic) IBOutlet UIButton *greyBGButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinningWheel;
@property (weak, nonatomic) IBOutlet UILabel *userName;
- (IBAction)logout:(id)sender;
@property (weak, nonatomic) IBOutlet STListStoryiPad *listViewOutlet;
@property (weak, nonatomic) STListStoryiPad *storyList;
- (IBAction)upload:(id)sender;
@end
