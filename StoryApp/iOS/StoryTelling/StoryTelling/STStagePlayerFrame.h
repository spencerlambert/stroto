//
//  STStagePlayerFrame.h
//  StoryTelling
//
//  Created by Aaswini on 30/12/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STImage.h"
#import "STImageInstancePosition.h"

@interface STStagePlayerFrame : NSObject{
    
    
}

@property NSMutableDictionary *fgImages;
@property STImage *bgImage;

@property NSDictionary *instanceIDTable;
@property NSDictionary *imagesTable;

-(id)initWithInstances:(NSArray *)instances ;
-(id)initWithSTStagePlayerFrame:(STStagePlayerFrame *)frame;

-(void)addFGImage:(STImageInstancePosition *)image withInstanceID:(int)instanceID;
-(void)removeFGImageWithInstanceID:(int)instanceID;

-(void)addBGImage:(STImage *)image;

-(UIImage *)getImageforFrame :(CGSize) size;
@end
