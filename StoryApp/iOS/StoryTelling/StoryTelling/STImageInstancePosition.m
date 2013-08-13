//
//  STImageInstancePosition.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//


#import "STImageInstancePosition.h"

@implementation STImageInstancePosition : NSObject 
-(id)init
{
    self = [super init];
    if(self)
    {
        imageInstanceId = x = y = rotation = scale = timecode = layer = flip =  0;
        
    }
    return  self;
}
@end
