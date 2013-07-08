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

-(id)initAsNewFile:(NSString*)filePath :(CGSize*)size{
    
    NSLog(@"size : %@",NSStringFromCGSize(*size));
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    sqlite3 *db;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    NSString *newDir = [docsDir stringByAppendingPathComponent:STDIRECTORY];
    NSLog(@"newDir : %@",newDir);
    
    NSArray *arrayFiles = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:newDir error:nil];
    NSLog(@"Files : %@",arrayFiles);
    
//    if ([[NSFileManager defaultManager] createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO){
//    // Build the path to the database file
//    databasePath = [[NSString alloc]
//                     initWithString: [docsDir stringByAppendingPathComponent:
//                                      @"1.db"]];
//    NSLog(@"%@",databasePath);
    
    
    if([arrayFiles count] == 0)
    {
        // Build the path to the database file
        databasePath = [[NSString alloc]
                        initWithString: [newDir stringByAppendingPathComponent:
                                         @"1.db"]];
        NSLog(@"%@",databasePath);

    }
    else
    {
        NSLog(@"Count : %d",[arrayFiles count]);
        databasePath = [[NSString alloc]
                        initWithString: [newDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.db",[arrayFiles count]]]] ;
        NSLog(@"%@",databasePath);
    }

    
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
   // }
    return databasePath;
}
@end
