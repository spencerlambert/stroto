//
//  AudioRecorder.h
//  StoryTelling
//
//  Created by Aaswini on 23/05/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorder : NSObject{
    AVAudioRecorder *audioRecorder;
    BOOL startedRecording;
}
-(void) recordAudio;
-(void) stop;
-(void) pause;

@end
