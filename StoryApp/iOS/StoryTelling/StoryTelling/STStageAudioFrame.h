//
//  STStageAudioFrame.h
//  StoryTelling
//
//  Created by Aaswini on 07/03/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STAudio.h"

@interface STStageAudioFrame : NSObject

@property STAudio *frame;
@property BOOL presented;
@property float timecode;

-(id)initWithFrame:(STAudio *)frame atTimecode:(float)timecode;

@end
