//
//  STModifierImageInstanceRotate.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STModifierImageInstance.h"

@interface STModifierImageInstanceRotate : STModifierImageInstance
{
    float rotationAngle;
    BOOL isRotationClockwise;
}
-(id)init;
@end
