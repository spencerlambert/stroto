//
//  STAudioRecording.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STAudioRecording.h"

@implementation STAudioRecording

@synthesize startedTime;

-(id)initWithDB:(STStoryDB *)db{
    self = [self init];
    if(self){
        storyDB = db;
    }
    return  self;
}

- (id)init{
    self = [super init];
    startedRecording = NO;
    NSString *soundFilePath = [[NSString alloc] initWithFormat:@"%@/%@", NSTemporaryDirectory(), @"sound.caf"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];
    
    [audioRecorder setDelegate:self];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [audioRecorder prepareToRecord];
    }
    return self;
}

-(void) recordAudio
{
    if (!audioRecorder.recording)
    {
        @try {
            //            AVAudioSession *session = [AVAudioSession sharedInstance];
            //            [session setCategory:AVAudioSessionCategoryRecord error:nil];
            [audioRecorder record];
            startedRecording = YES;
        }@catch (NSException *e) {
            NSLog(@"%@",e);
        }
    }
}

-(void) stop
{
    if(startedRecording)
    {
        @try {
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayback error:nil];
            [audioRecorder stop];
        }@catch (NSException *e) {
            NSLog(@"%@",e);
        }
    }
}

-(void) pause
{
    if (audioRecorder.recording)
    {
        [audioRecorder pause];
    }
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    
    if (flag) {
        NSString *soundFilePath = [[NSString alloc] initWithFormat:@"%@/%@", NSTemporaryDirectory(), @"sound.caf"];
        NSData *data = [[NSData alloc]initWithContentsOfFile:soundFilePath];
        STAudio *audio = [[STAudio alloc]initWithAudio:data atTimecode:startedTime];
        [storyDB addAudio:audio];
    }
}

@end
