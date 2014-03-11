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
#import "STPlayerToolbar.h"
#import <AVFoundation/AVFoundation.h>
#import "STStagePlayerFrame.h"


@interface STStagePlayerViewController : UIViewController<TopRightViewDelegate, STPlayerToolbarDelegate>

@property (nonatomic,retain) STStoryDB *storyDB;
@property NSString *dbname;


@end
