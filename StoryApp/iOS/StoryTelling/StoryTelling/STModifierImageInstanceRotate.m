//
//  STModifierImageInstanceRotate.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifierImageInstanceRotate.h"

@implementation STModifierImageInstanceRotate

-(id)init
{
    self = [super init];
    if(self)
    {
        rotationAngle =0.1f;
        isRotationClockwise = 1;
    }
    return self;
}


-(STImageInstancePosition*)getNewImageInstancePosition:(id)timeline
{
    STImageInstancePosition *newImageInstancePosition = [[STImageInstancePosition alloc] init];
    
    newImageInstancePosition = (STImageInstancePosition*)[(NSArray*) timeline lastObject];
    if(isRotationClockwise)
        newImageInstancePosition.rotation += rotationAngle;
    else
        newImageInstancePosition.rotation -= rotationAngle;
    
    return (newImageInstancePosition);
}

@end
