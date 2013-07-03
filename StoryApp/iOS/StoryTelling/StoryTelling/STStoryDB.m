//
//  STStoryDB.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"
#import "StoryTellingRootViewController.h"

@implementation STStoryDB
static sqlite3 *database = nil;
NSString *storyPath;
//NSString *databasePath;


//Need private methods for creating the db and making the actual sql calls.

+ (STStoryDB*)createNewSTstoryDB:(NSString*)storyPath :(CGSize*)size;{
//    NSString *docsDir;
//    NSArray *dirPaths;
//    
//    // Get the documents directory
//    dirPaths = NSSearchPathForDirectoriesInDomains(
//                                                   NSDocumentDirectory, NSUserDomainMask, YES);
//    NSLog(@"dirPath is %@", dirPaths);
//    
//    docsDir = [dirPaths objectAtIndex:0];
//    NSLog(@"docDir is %@", docsDir);
//    
//    // Build the path to the database file
//    databasePath = [[NSString alloc]
//                    initWithString: [docsDir stringByAppendingPathComponent:
//                                     @"stories.db"]];
//    
//   // BOOL isSuccess = YES;
     NSLog(@" databasepath is %@",storyPath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: storyPath ] == NO)
    {
       
        const char *dbpath = [storyPath UTF8String];
        
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS Story (ID INTEGER PRIMARY KEY AUTOINCREMENT, displayName TEXT, mainTitle TEXT, subTile TEXT, sizeX INTEGER, sizeY INTEGER, createDateTime NUMERIC)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
              //  isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
           // return  isSuccess;
        }
        else {
           // isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    //return isSuccess;
}
@end
