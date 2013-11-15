//
//  STModifierImageInstanceFollowTangent.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifierImageInstanceFollowTangent.h"

@implementation STModifierImageInstanceFollowTangent
-(id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}
-(STImageInstancePosition*)getNewImageInstancePosition:(id)timeline
{
    STImageInstancePosition *newImageInstancePosition = [[STImageInstancePosition alloc]init];
    newImageInstancePosition = (STImageInstancePosition*)[(NSArray*)timeline lastObject];
    STImageInstancePosition *previousImageInstancePosition = [[STImageInstancePosition alloc]init];
    previousImageInstancePosition = (STImageInstancePosition*)[(NSArray*)timeline objectAtIndex:[(NSArray*)timeline count]-2];
    float dX = newImageInstancePosition.x-previousImageInstancePosition.x;
    float dY = newImageInstancePosition.y-previousImageInstancePosition.y;
    //angle in radians/2# radians = angle in degrees/360 degrees.// 360/2# = 180/#
    newImageInstancePosition.rotation = atan2f(dY, dX)*180.0f / M_PI;
    return newImageInstancePosition;
}
@end
