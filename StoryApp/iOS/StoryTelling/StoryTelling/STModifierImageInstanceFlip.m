//
//  STModifierImageInstanceFlip.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifierImageInstanceFlip.h"

@implementation STModifierImageInstanceFlip

-(STImageInstancePosition*)getNewImageInstancePosition:(id)timeline
{
    STImageInstancePosition *newImageInstancePosition = (STImageInstancePosition*)[(NSArray*)timeline lastObject];
    if(newImageInstancePosition)
    {
    if(newImageInstancePosition.flip)
        newImageInstancePosition.flip = 0;
    else
        newImageInstancePosition.flip = 1;
    }
    return newImageInstancePosition;
}
@end
