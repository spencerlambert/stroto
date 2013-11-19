//
//  STStageRecorder.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"
#import "STImageInstancePosition.h"

@interface STStageRecorder : NSObject{
    STStoryDB *storyDB;
    NSArray *timeLine;
}
-(id)initWithDB:(STStoryDB *)db;
-(void)reloadImageInstances;
-(void)writeImageInstance:(STImageInstancePosition*)instance ;

@end
