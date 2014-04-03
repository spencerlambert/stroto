//
//  STStageExporter.h
//  StoryTelling
//
//  Created by Aaswini on 27/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStagePlayer.h"
#import "STStoryDB.h"

@interface STStageExporter : STStagePlayer

@property (nonatomic,retain) STStoryDB *storyDB;
@property NSString *dbname;

-(void)initDB;
-(void)generateMovie;


@end
