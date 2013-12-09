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

long long int dbSize;
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
//    NSLog(@"data length : %d", [data length]);
//    NSLog(@"fileData length : %@",fileData);
//    NSLog(@"dbSize : %d",dbSize);
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
    if(dbSuccess)
    {
        NSLog(@"DB writing success!!");
        NSURL *installedFileUrl = [NSURL fileURLWithPath:installedFilePath];
        [self addSkipBackupAttributeToItemAtURL:installedFileUrl];
        [progressDelegate finishedDownloadingDB:installedFilePath];
    }
    else
    {
        NSLog(@"DB writing not success!!");
    }
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end