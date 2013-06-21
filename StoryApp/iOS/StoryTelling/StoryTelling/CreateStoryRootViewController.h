//
//  CreateStoryRootViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBackgroundViewController.h"
#import "AppDelegate.h"

@interface CreateStoryRootViewController : UIViewController<AddBackgroundViewControllerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *storyNameTextField;
@property (strong, nonatomic) IBOutlet UIView *BackgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *ForegroundImagesView;
@property (strong, nonatomic) NSMutableArray *backgroundImages;
@property (strong, nonatomic) NSMutableArray *foregroundImages;
@property (strong, nonatomic) AppDelegate *imagesDelegate;

- (IBAction)nextButtonClicked:(id)sender;
- (BOOL) createStoryDirectories:(NSString *)storyName;
- (void) reloadBackgroundImagesView ;
- (void) reloadForegroundImagesView ;
-(IBAction)resigngTxtField;

@end
