//
//  STStoryDB.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"


@implementation STStoryDB

//Need private methods for creating the db and making the actual sql calls.
        
//+(STStoryDB*)createNewSTstoryDB:(CGSize*)size{
    
       
//}

-(void)createStory{
    NSString *docsDir;
    NSArray *dirPaths;
   
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"1.db"]];
    NSLog(@"%@",databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, & db) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            " CREATE TABLE Story (displayName TEXT,mainTitle TEXT,subTile TEXT,sizeX INTEGER,sizeY INTEGER,createDateTime  NUMERIC);";
            
            if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(db);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}
@end
