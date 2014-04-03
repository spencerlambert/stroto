//
//  STStageExporterFrame.h
//  StoryTelling
//
//  Created by Aaswini on 03/04/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STImage.h"
#import "STImageInstancePosition.h"

@interface STStageExporterFrame : NSObject

@property NSMutableDictionary *fgImages;
@property STImage *bgImage;

@property NSDictionary *instanceIDTable;
@property NSDictionary *imagesTable;

-(id)initWithInstances:(NSArray *)instances ;
-(id)initWithSTStageExporterFrame:(STStageExporterFrame *)frame;

-(void)addFGImage:(STImageInstancePosition *)image withInstanceID:(int)instanceID;
-(void)removeFGImageWithInstanceID:(int)instanceID;

-(void)addBGImage:(STImage *)image;

-(UIImage *)getImageforFrame :(CGSize) size;

@end


