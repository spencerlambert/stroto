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
@synthesize fileData;
@synthesize progressDelegate;

-(void)downloadStoryPack:(NSString*)downloadURL
{
    NSLog(@"URL : %@",downloadURL);
    NSString *filename = [downloadURL lastPathComponent];
    NSLog(@"filename: %@",filename);
    self.fileData = [[NSMutableData alloc]init];
    NSURLConnection *downloadConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]] delegate:self];
   [downloadConnection start];
    installedFilePath = [installedFilePath stringByAppendingPathComponent:filename];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:downloadURL]];
    [self.fileData appendData:data];
    }
-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    installedFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"story_dir/story_packs/"];
    NSLog(@"installedFilePath : %@",installedFilePath);
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManger createDirectoryAtPath:installedFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    BOOL dbSuccess = [self.fileData writeToFile:installedFilePath atomically:YES];
    NSLog(@"Save Success : %@",dbSuccess?@"Yes":@"No");

}
- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    int percentage = totalBytesWritten / expectedTotalBytes;
    [progressDelegate updateProgress:percentage];
}
- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes
{
    
}

@end