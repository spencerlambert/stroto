//
//  STFreeStoryPacksViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STImage.h"

@interface STFreeStoryPacksViewController : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (strong, nonatomic) IBOutlet UILabel *freeStoryPackName;

@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;

@property (strong, nonatomic) NSDictionary *freeStoryPackDetailsJson;
@property (strong, nonatomic) NSDictionary *freeStoryPackURL;
@property (assign, nonatomic) int storyPackID;

-(IBAction)buyButtonTapped:(id)sender;
@end
