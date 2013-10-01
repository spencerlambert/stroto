//
//  STSelectImagesFromStoryViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStoryDB.h"

@interface STSelectImagesFromStoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *storyNameLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (weak, nonatomic) IBOutlet UIView *foregroundImagesView;
@property (weak, nonatomic) NSString *dbLocation;
@end
