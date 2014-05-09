//
//  STStageExporterFrameTransformHelper.m
//  StoryTelling
//
//  Created by Aaswini on 09/05/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStageExporterFrameTransformHelper.h"

@implementation STStageExporterFrameTransformHelper

- (id) init{
    self = [super init];
    if(self){
        self.rotation = 0;
        self.scale = 1;
    }
    return self;
}

@end
