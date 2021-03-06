//
//  STStageRecorder.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStageRecorder.h"

@implementation STStageRecorder

-(id)initWithDB:(STStoryDB *)db{
    self = [super init];
    if(self){
        storyDB = db;
        timeLine = [storyDB getImageInstanceTimeline];
    }
    return  self;
}

-(void) reloadImageInstances{
        timeLine = [storyDB getImageInstanceTimeline];
}

-(void)writeImageInstance:(STImageInstancePosition*)instance {
    [storyDB updateImageInstanceTimeline:instance];
    [self reloadImageInstances];
}
@end
