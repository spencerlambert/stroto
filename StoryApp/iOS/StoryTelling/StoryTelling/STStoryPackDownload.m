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

int dbSize;
NSString *filename;
-(void)downloadStoryPack:(NSString*)downloadURL
{
    NSLog(@"URL : %@",downloadURL);
    filename = [downloadURL lastPathComponent];
    NSLog(@"filename: %@",filename);
    self.fileData = [[NSMutableData alloc]init];
    NSURLConnection *downloadConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:downloadURL]] delegate:self startImmediately:NO] ;
    [downloadConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
   [downloadConnection start];
}

#pragma mark - URLConnection delegate methods
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response : %@",response);
    NSLog(@"Response.expectedContentLength : %lld",response.expectedContentLength);
    dbSize = response.expectedContentLength;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:downloadURL]];
    NSLog(@"data length : %d", [data length]);
    NSLog(@"dbSize : %d",dbSize);
    float progress = (float)[fileData length]/(float)dbSize;
    [progressDelegate updateProgress:progress];
    [self.fileData appendData:data];
    }
-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
    installedFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"story_dir/story_packs/"];
    NSLog(@"installedFilePath : %@",installedFilePath);
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManger createDirectoryAtPath:installedFilePath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    installedFilePath = [installedFilePath stringByAppendingPathComponent:filename];
    BOOL dbSuccess = [self.fileData writeToFile:installedFilePath atomically:YES];
    NSLog(@"Save Success : %@",dbSuccess?@"Yes":@"No");
    [progressDelegate finishedDownloadingDB:installedFilePath];

}

@end