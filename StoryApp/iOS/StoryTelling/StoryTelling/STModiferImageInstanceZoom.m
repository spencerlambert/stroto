//
//  STModiferImageInstanceZoom.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModiferImageInstanceZoom.h"

@implementation STModiferImageInstanceZoom

-(id)init
{
    self = [super init];
    if (self)
    {
    zoomRate = 5;
    isZoomIn = 1;
    }
    return (self);
}

- (STImageInstancePosition*)getNewImageInstancePosition:(id)timeline
{
    
STImageInstancePosition *newImageInstancePosition = [[STImageInstancePosition alloc] init];
    
newImageInstancePosition = (STImageInstancePosition*)[(NSArray*)timeline lastObject];

if(isZoomIn)
    newImageInstancePosition->scale += newImageInstancePosition->scale * zoomRate/100 ;
else
    newImageInstancePosition->scale -= newImageInstancePosition->scale * zoomRate/100 ;

return (newImageInstancePosition);

}

@end
