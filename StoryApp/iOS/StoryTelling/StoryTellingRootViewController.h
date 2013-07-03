//
//  StoryTellingRootViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface StoryTellingRootViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *storyTable;
@property (strong, nonatomic) AppDelegate *newstoryFlag;
- (IBAction)createNewStory:(id)sender;



@end
