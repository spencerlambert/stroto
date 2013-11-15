//
//  STStageRecorder.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"
#import "STImage.h"

@interface STStageRecorder : NSObject{
    STStoryDB *storyDB;
    NSArray *imageInstances;
}
-(id)initWithDB:(STStoryDB *)db;
-(void)reloadImageInstances;
-(void)writeImageInstance:(STImage*)instance atTimeCode:(int)timeCode;

@end
