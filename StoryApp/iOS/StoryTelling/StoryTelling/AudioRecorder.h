//
//  AudioRecorder.h
//  StoryTelling
//
//  Created by Aaswini on 23/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecorder : NSObject{
    AVAudioRecorder *audioRecorder;
}
-(void) recordAudio;
-(void) stop;
@end
