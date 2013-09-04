//
//  STStage.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStage.h"

@interface STStage (Actor_Entry_Handlers)

- (void) createImageInstanceEntry:(STImage *)actor;
- (void) reLoadImageInstances;

@end



@implementation STStage

@synthesize storyDB;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)initStage{
    isRecording = NO;
    stageRecorder = [[STStageRecorder alloc]initWithDB:storyDB];
    stagePlayer = [[STStagePlayer alloc]initWithDB:storyDB];
    audioRecorder = [[STAudioRecording alloc]initWithDB:storyDB];
    [self reLoadImageInstances];
}

- (void) reLoadImageInstances{
    imageInstances = [storyDB getImageInstanceTable];
}

- (void) createImageInstanceEntry:(STImage *)actor{
    [storyDB addImageInstance:actor.imageId];
}

- (void) actortoStage:(STImage *)actor{
    [self createImageInstanceEntry:actor];
    [self reLoadImageInstances];
}

- (void) startRecording{
    isRecording = YES;
}
- (void) stopRecording{
    isRecording = NO;
}

@end
