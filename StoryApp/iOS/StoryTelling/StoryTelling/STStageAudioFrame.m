//
//  STStageAudioFrame.m
//  StoryTelling
//
//  Created by Aaswini on 07/03/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStageAudioFrame.h"

@implementation STStageAudioFrame

-(id)initWithFrame:(STAudio *)frame atTimecode:(float)timecode{
    self = [super init] ;
    if(self){
        [self setFrame:frame];
        [self setPresented:NO];
        [self setTimecode:timecode];
    }
    return self;
}

@end
