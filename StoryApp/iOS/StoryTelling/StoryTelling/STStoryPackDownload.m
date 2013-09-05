//
//  STStoryPackDownload.m
//  StoryTelling
//
//  Created by Nandakumar on 05/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryPackDownload.h"
#import "STFreeStoryPacksViewController.h"

@implementation STStoryPackDownload

-(void)downloadStoryPack:(NSURL*)downloadURL
{
    NSLog(@"URL : %@",downloadURL);
    
    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:downloadURL];
    NSString *resourceDocPath = [[NSString alloc] initWithString:[[[[NSBundle mainBundle]  resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"]];
    
    NSString *filePath = [resourceDocPath stringByAppendingPathComponent:@"Database.sqlite"];
    [dbFile writeToFile:filePath atomically:YES];
}
@end
