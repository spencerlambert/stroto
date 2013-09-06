//
//  STStage.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "STStageRecorder.h"
#import "STStagePlayer.h"
#import "STStageExporter.h"
#import "STAudioRecording.h"
#import "STImage.h"
#import "STStoryDB.h"


@interface STStage : UIView{
    
    STStageRecorder *stageRecorder;
    STStagePlayer *stagePlayer;
    STStageExporter *stageExporter;
    STAudioRecording *audioRecorder;
    BOOL isRecording ;
    NSArray *imageInstances;
    

}

@property(assign) float frameRate;
@property (nonatomic,retain) STStoryDB *storyDB;

//for recording video
- (void) startRecording;
- (void) stopRecording;
- (void) actortoStage:(STImage *)actor;
- (void) initStage;


@end
