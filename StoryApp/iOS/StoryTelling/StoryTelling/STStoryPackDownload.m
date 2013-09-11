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

-(void)downloadStoryPack:(NSString*)downloadURL
{
    NSLog(@"URL : %@",downloadURL);
    NSString *filename = [downloadURL lastPathComponent];
    NSLog(@"filename: %@",filename);
    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:downloadURL]];
    NSString *resourceDocPath = [[NSString alloc] initWithString:[[[[NSBundle mainBundle]  resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents/story_dir"]];
    NSString *filePath = [resourceDocPath stringByAppendingPathComponent:filename];
    [dbFile writeToFile:filePath atomically:YES];
}
@end