//
//  STStage.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STImage.h"
#import "STStoryDB.h"
#import "STStageRecorder.h"
#import "STAudioRecording.h"


@interface STStage : UIView{
    
    BOOL isRecording ;
    NSArray *imageInstances;
    NSMutableArray *timeline;
    NSDate *startedAt;
    float pauseInterval;
    NSDate *pausedTime;
    
    STStageRecorder *stageRecorder;
    STAudioRecording *audioRecorder;


}

@property(assign) float frameRate;
@property (nonatomic,retain) STStoryDB *storyDB;

//for recording video
- (void) startRecording;
- (void) stopRecording;
- (void) pauseRecording;
- (void) resumeRecording;
- (void) actortoStage:(STImage *)actor;
- (void) initStage;


@end
