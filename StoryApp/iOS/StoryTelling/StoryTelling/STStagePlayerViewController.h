//
//  STStagePlayerViewController.h
//  StoryTelling
//
//  Created by Aaswini on 10/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStoryDB.h"
#import "UIView+Hierarchy.h"
#import "TopRightView.h"
#import "BottomLeft.h"

@interface STStagePlayerViewController : UIViewController<TopRightViewDelegate,BottomLeftViewDelegate>

@property (nonatomic,retain) STStoryDB *storyDB;

@end
