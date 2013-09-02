//
//  STStoryPackIAPHelper.m
//  StoryTelling
//
//  Created by Nandakumar on 02/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryPackIAPHelper.h"

@implementation STStoryPackIAPHelper
+(STStoryPackIAPHelper*)sharedInstance
{
    static dispatch_once_t once;
    static STStoryPackIAPHelper *sharedIstance;
    dispatch_once(&once, ^{
        
    });
}
@end
