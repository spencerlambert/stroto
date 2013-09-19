//
//  STStoryPackDownload.m
//  StoryTelling
//
//  Created by Nandakumar on 05/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryPackDownload.h"

@implementation STStoryPackDownload

@synthesize installedFilePath;

-(void)downloadStoryPack:(NSString*)downloadURL
{
    NSLog(@"URL : %@",downloadURL);
    NSString *filename = [downloadURL lastPathComponent];
    NSLog(@"filename: %@",filename);
    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:downloadURL]];
    installedFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"story_dir/story_packs/"];
    NSLog(@"installedFilePath : %@",installedFilePath);
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManger createDirectoryAtPath:installedFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    installedFilePath = [installedFilePath stringByAppendingPathComponent:filename];
    BOOL dbSuccess = [dbFile writeToFile:installedFilePath atomically:YES];
    NSLog(@"Save Success : %@",dbSuccess?@"Yes":@"No");
}

@end