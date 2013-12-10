//
//  STStoryPackDownload.h
//  StoryTelling
//
//  Created by Nandakumar on 05/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STStoryPackDownloadDelegate<NSObject>

-(void)updateProgress:(float)progress;
-(void)finishedDownloadingDB:(NSString*)DBFilePath;

@end

@interface STStoryPackDownload : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>


@property (nonatomic, weak) NSString *installedFilePath;
@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, strong)  id<STStoryPackDownloadDelegate> progressDelegate;
@property (nonatomic, strong) NSString *filename;

-(void)downloadStoryPack:(NSString*)downloadURL;

@end
