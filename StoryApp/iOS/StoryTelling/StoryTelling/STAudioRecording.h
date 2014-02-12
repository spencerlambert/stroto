//
//  STAudioRecording.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STStoryDB.h"
#import <AVFoundation/AVFoundation.h>

@interface STAudioRecording : NSObject<AVAudioRecorderDelegate>{
   
    STStoryDB *storyDB;
    AVAudioRecorder *audioRecorder;
    BOOL startedRecording;
    
}

@property (nonatomic)float startedTime;

-(id)initWithDB:(STStoryDB *)db;
-(void) recordAudio;
-(void) stop;
-(void) pause;

@end
