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
    NSMutableString *filename = (NSMutableString* )downloadURL;
    NSString *staticURLPart = @"http://storypacks.stroto.com/download/";
   if( [filename rangeOfString:staticURLPart].location!=NSNotFound)
   {
       NSLog(@"%@", filename);
   }
    NSData *dbFile = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:downloadURL]];
    NSString *resourceDocPath = [[NSString alloc] initWithString:[[[[NSBundle mainBundle]  resourcePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Documents"]];
    
    NSString *filePath = [resourceDocPath stringByAppendingPathComponent:@"Database.sqlite"];
    [dbFile writeToFile:filePath atomically:YES];
}
@end
