//
//  STStagePlayerFrame.h
//  StoryTelling
//
//  Created by Aaswini on 26/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STImageInstancePosition.h"

@interface STStagePlayerFrame : NSObject

@property STImageInstancePosition *frame;
@property BOOL presented;
@property float timecode;
@property BOOL bgFrame;

-(id)initWithFrame:(STImageInstancePosition *)frame atTimecode:(float)timecode;

@end
