//
//  STStoryPackDownload.h
//  StoryTelling
//
//  Created by Nandakumar on 05/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STStoryPackDownload : NSObject

@property (nonatomic, weak) NSString *installedFilePath;

-(void)downloadStoryPack:(NSString*)downloadURL;

@end
