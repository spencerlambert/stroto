//
//  STImageInstance.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STImageInstance.h"

@implementation STImageInstance

@synthesize imageInstanceID;
@synthesize imageID;

- (id)initInstanceWithID:(int)instanceID imageID:(int)imageId{
    self = [super init];
    if(self){
        imageInstanceID = instanceID;
        imageID = imageId;
    }
    return  self;
}

@end
