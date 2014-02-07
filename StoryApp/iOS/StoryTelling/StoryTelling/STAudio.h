//
//  STAudio.h
//  StoryTelling
//
//  Created by Aaswini on 07/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STAudio : NSObject

@property NSData *audio;
@property float timecode;

-(id)initWithAudio:(NSData *)audioData atTimecode:(float)timeCode;

@end
