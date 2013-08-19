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
       // imageInstanceId = x = y = rotation = scale = timecode = layer = flip =  0;
       
        /*unsigned_int*/     imageInstanceId = 0;    //non-negative
        /*int*/              x = 100;                //default x position
        /*int*/              y = 100;                //default y position
        /*float*/            scale = 1.0f;           //default no scaling
        /*float*/            rotation = 0.0f;        //default no rotation
        /*float*/            timecode = 0.0f;        //default
        /*int*/              layer = 0;              //default
        /*int*/              flip = 0;               //default
        /*int*/              perspective = -1;       //default no perspective
    }
    return  self;
}
@end
