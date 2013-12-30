//
//  STStagePlayerFrame.m
//  StoryTelling
//
//  Created by Aaswini on 30/12/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerFrame.h"

@implementation STStagePlayerFrame

-(id)initWithInstances:(NSArray *)instances{
    self = [super init];
    if (self) {
        fgImages = [[NSDictionary alloc] initWithObjects:[[NSArray alloc]init] forKeys:instances];
        bgImage = nil;
    }
    return self;
}

-(void)addFGImage:(STImage *)image withInstanceID:(int)instanceID{
    
    [fgImages setValue:image forKey:[NSString stringWithFormat:@"%d",instanceID]];
    
}

-(void)removeFGImageWithInstanceID:(int)instanceID{
    
    [fgImages setValue:nil forKey:[NSString stringWithFormat:@"%d",instanceID]];
    
}

-(void)addBGImage:(STImage *)image{
    
    bgImage = image;
    
}

@end
