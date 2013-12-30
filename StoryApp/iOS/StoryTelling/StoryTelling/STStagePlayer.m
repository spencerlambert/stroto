//
//  STStagePlayer.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStagePlayer.h"
#import "STImageInstancePosition.h"


@implementation STStagePlayer{
    
    NSArray *timeline;
    NSArray *instanceIDs;
    
    STStagePlayerFrame *previousFrame;
    STImage *currentBGImage;
    
    NSMutableArray *frames;
    
    NSDictionary *instanceIDTable;
    
}


-(id)initWithDB:(STStoryDB *)db{
    self = [super init];
    if(self){
        storyDB = db;
        frames = [[NSMutableArray alloc]init];
    }
    return  self;
}

- (void) initialize{
    timeline = [storyDB getImageInstanceTimeline];
    instanceIDs = [storyDB getInstanceIDsAsString];
    previousFrame = [[STStagePlayerFrame alloc]initWithInstances:instanceIDs];
    currentBGImage = [[STImage alloc] initWithCGImage:[UIImage imageNamed:@"RecordArea.png"].CGImage];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
}

- (void) compileFrames{
    for (int i=0; i<[timeline count]; i++) {
        STImageInstancePosition *position =timeline[i];
        
    }
}

-(BOOL)isInstanceBG:(int)instanceID{
    
}

@end
