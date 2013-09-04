//
//  STStageRecorder.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"

@interface STStageRecorder : NSObject{
    STStoryDB *storyDB;
}
-(id)initWithDB:(STStoryDB *)db;

@end
