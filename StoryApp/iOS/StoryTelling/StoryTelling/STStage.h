//
//  STStage.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STStageRecorder.h"
#import "STStagePlayer.h"
#import "STStageExporter.h"
#import "STAudioRecording.h"


@interface STStage : UIView{
    
    STStageRecorder *stageRecorder;
    STStagePlayer *stagePlayer;
    STStageExporter *stageExporter;
    STAudioRecording *audioRecording;

}

@end
