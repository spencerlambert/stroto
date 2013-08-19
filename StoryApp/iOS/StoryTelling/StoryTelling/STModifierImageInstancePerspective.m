//
//  STModifierImageInstancePerspective.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifierImageInstancePerspective.h"

@implementation STModifierImageInstancePerspective
-(id)init
{
    self = [super init];
    if(self)
    {
        isGroundPerspective = -1;     //perspective : 0=ground, 1=sky, -1=No perspective.
    }
    return self;
}
-(STImageInstancePosition*)getNewImageInstancePosition:(id)timeline
{
    //perspective : 0=ground, 1=sky, -1=No perspective.
    STImageInstancePosition *newImageInstancePosition = (STImageInstancePosition*)[(NSArray*)timeline lastObject];
    STImageInstancePosition *previousImageInstancePosition = (STImageInstancePosition*)[(NSArray*)timeline objectAtIndex:[(NSArray*)timeline count]-2];
    newImageInstancePosition->perspective = isGroundPerspective; //setting up perspective (1 or 0)
    int yChange =  newImageInstancePosition->y - previousImageInstancePosition->y; //gives delta y
    if(isGroundPerspective == 1)
    {
        //moving image down along y axis(performing zoom in) , yChange = +ve
        //moving image up along y axis(zoom out) , yChange = -ve
        newImageInstancePosition->scale += (float)yChange * 0.001f;
    }
    
    else if(isGroundPerspective == 0)
    {
        //moving image down along y axis(performing zoom out) , yChange = +ve
        //moving image up along y axis(zoom in) , yChange = -ve
        newImageInstancePosition->scale -= (float)yChange * 0.001f;
    }
    return newImageInstancePosition;
}

@end
