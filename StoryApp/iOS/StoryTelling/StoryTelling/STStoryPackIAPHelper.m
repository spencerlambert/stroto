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
    static STStoryPackIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"free_sp_test_1",
                                      @"paid_sp_test_1",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}
@end
