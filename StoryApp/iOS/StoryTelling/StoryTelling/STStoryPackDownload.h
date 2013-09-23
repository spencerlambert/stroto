//
//  STStoryPackDownload.h
//  StoryTelling
//
//  Created by Nandakumar on 05/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STStoryPackDownloadDelegate

-(void)updateProgress:(float)count;

@end

@interface STStoryPackDownload : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDownloadDelegate>

@property (nonatomic, weak) NSString *installedFilePath;
@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, weak) id<STStoryPackDownloadDelegate> progressDelegate;

-(void)downloadStoryPack:(NSString*)downloadURL;

@end
