//
//  STModiferImageInstanceZoom.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifierImageInstance.h"

@interface STModiferImageInstanceZoom : STModifierImageInstance {
    // Sets the rate of the zoom, this is defined when the instance is created and
    // then getNewImageInstancePosition uses these settings in it's calculations.
    
    int zoomRate;
    BOOL isZoomIn;
//  BOOL isZoomOut;  No need for two bool variables, isZoomIn will do the thing for you.
}

- (STImageInstancePosition*)getNewImageInstancePosition:(id)timeline;

@end
