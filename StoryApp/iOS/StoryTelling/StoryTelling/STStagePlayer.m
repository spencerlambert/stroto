//
//  STStagePlayer.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStagePlayer.h"

@implementation STStagePlayer


-(id)initWithDB:(STStoryDB *)db{
    self = [super init];
    if(self){
        storyDB = db;
    }
    return  self;
}



@end
