//
//  STStagePlayerFrame.m
//  StoryTelling
//
//  Created by Aaswini on 26/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerFrame.h"

@implementation STStagePlayerFrame


-(id)initWithFrame:(STImageInstancePosition *)frame atTimecode:(float)timecode{

    self = [super init] ;
    if(self){
        [self setFrame:frame];
        [self setPresented:NO];
        [self setTimecode:timecode];
    }
    return self;
}
@end
