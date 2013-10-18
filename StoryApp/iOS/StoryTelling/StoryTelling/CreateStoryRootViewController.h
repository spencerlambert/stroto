//
//  CreateStoryRootViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBackgroundViewController.h"
#import "AppDelegate.h"
#import "STStoryDB.h"
#import "WorkAreaController.h"

@interface CreateStoryRootViewController : UIViewController<UITextFieldDelegate,WorkAreaDelegate,UINavigationBarDelegate>

@property (strong, nonatomic) IBOutlet UITextField *storyNameTextField;
@property (strong, nonatomic) IBOutlet UIView *BackgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *ForegroundImagesView;
@property (strong, nonatomic) NSMutableArray *backgroundImages;
@property (strong, nonatomic) NSMutableArray *foregroundImages;
@property (strong, nonatomic) AppDelegate *imagesDelegate;
@property BOOL isEditStory;
@property (strong, nonatomic) NSString *dbname;


- (IBAction)nextButtonClicked:(id)sender;
- (BOOL) createStoryDirectories:(NSString *)storyName;
- (void) reloadBackgroundImagesView ;
- (void) reloadForegroundImagesView ;
-(IBAction)resigngTxtField;


@end
