//
//  STStagePlayerView.h
//  StoryTelling
//
//  Created by Aaswini on 28/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStoryDB.h"
#import "STStagePlayerFrame.h"
#import "STStageAudioFrame.h"

@interface STStagePlayerView : UIView

@property(assign) float frameRate;
@property (nonatomic,retain) STStoryDB *storyDB;
@property UISlider *slider;

-(void)startPlaying;
-(void)stopPlaying;
-(void)pausePlaying;
-(void)resumePlaying;
-(void)initialize;

@end
