//
//  STStagePlayerFrame.h
//  StoryTelling
//
//  Created by Aaswini on 30/12/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STImage.h"

@interface STStagePlayerFrame : NSObject{
    
    NSDictionary *fgImages;
    STImage *bgImage;
}

-(id)initWithInstances:(NSArray *)instances ;

-(void)addFGImage:(STImage *)image withInstanceID:(int)instanceID;
-(void)removeFGImageWithInstanceID:(int)instanceID;

-(void)addBGImage:(STImage *)image;

@end
