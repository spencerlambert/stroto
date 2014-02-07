//
//  STAudio.m
//  StoryTelling
//
//  Created by Aaswini on 07/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STAudio.h"

@implementation STAudio

-(id)initWithAudio:(NSData *)audioData atTimecode:(float)timeCode{
    self = [super init];
    if(self){
        self.audio = audioData;
        self.timecode = timeCode;
    }
    return  self;

    
}

@end
