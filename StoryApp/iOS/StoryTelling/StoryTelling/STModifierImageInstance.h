//
//  STModifierImageInstance.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifier.h"
#import "STImageInstancePosition.h"

@interface STModifierImageInstance : STModifier

// Each sub class should override this function
// This function gets an array of STImageInstancePositions and then calculates
// what the next position should be.
- (STImagePosition*)getNewImageInstancePosition:(id*)timeline;

@end
