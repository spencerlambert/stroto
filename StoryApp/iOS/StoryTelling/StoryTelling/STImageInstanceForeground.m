//
//  STImageInstanceForeground.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STImageInstanceForeground.h"

@implementation STImageInstanceForeground

- (id)initFGInstanceWithID:(int)instanceID imageID:(int)imageId{
    self = [super initInstanceWithID:instanceID imageID:imageId];
    if(self){
        self.instanceType = true;
    }
    return  self;
}

@end
