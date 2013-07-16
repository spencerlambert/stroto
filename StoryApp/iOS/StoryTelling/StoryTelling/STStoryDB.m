//
//  STStoryDB.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"


@implementation STStoryDB {
    sqlite3 *db;
}

//Need private methods for creating the db and making the actual sql calls.
        
+(id)createNewSTstoryDB:(CGSize*)size{
     return [[self alloc] initAsNewFile:size];
       
}



-(id)initAsNewFile: (CGSize*)size{
    
    self = [super init];
    
    if (self) {
    
        NSLog(@"size : %@",NSStringFromCGSize(*size));
        
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        
        NSString *newDir = [docsDir stringByAppendingPathComponent:STDIRECTORY];
        NSLog(@"newDir : %@",newDir);
        
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManger createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"error creating directory: %@", error);
        }
        
        NSArray *arrayFiles = [fileManger contentsOfDirectoryAtPath:newDir error:nil];
        NSLog(@"Files : %@",arrayFiles);
        
        //    if ([[NSFileManager defaultManager] createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error: NULL] == NO){
        //    // Build the path to the database file
        //    databasePath = [[NSString alloc]
        //                     initWithString: [docsDir stringByAppendingPathComponent:
        //                                      @"1.db"]];
        //    NSLog(@"%@",databasePath);
        
        
        if([self dbnumber:arrayFiles] == 0)
        {
            // Build the path to the database file
            databasePath = [[NSString alloc]
                            initWithString: [newDir stringByAppendingPathComponent:
                                             @"1.db"]];
            NSLog(@"%@",databasePath);
            
        }
        else
        {
            NSLog(@"Count : %d",[self dbnumber:arrayFiles]);
            databasePath = [[NSString alloc]
                            initWithString: [newDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.db",[self dbnumber:arrayFiles]+1]]] ;
            NSLog(@"%@",databasePath);
        }
        
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        
        if ([filemgr fileExistsAtPath: databasePath ] == NO)
        {
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, & db) == SQLITE_OK)
            {
                char *errMsg;
                const char *sql_stmt = "CREATE TABLE Version (version  NUMERIC);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                [self updateVersion];
                
                sql_stmt = "CREATE TABLE Story (displayName TEXT, mainTitle TEXT, subTile TEXT, sizeX INTEGER, sizeY INTEGER, createDateTime  NUMERIC);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                //char *errMsg1;
                sql_stmt = "CREATE TABLE Image (imageId INTEGER PRIMARY KEY AUTOINCREMENT, listDisplayOrder INTEGER, sizeX INTEGER, sizeY INTEGER, fileType TEXT, type TEXT, defaultX INTEGER,defaultY INTEGER,defaultScale NUMERIC,imageData BLOB, thumbnailData BLOB);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                sql_stmt = "CREATE TABLE Sound (soundId INTEGER PRIMARY KEY AUTOINCREMENT, mp3Data BLOB);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                sql_stmt = "CREATE TABLE AudioRecording (audioId INTEGER PRIMARY KEY AUTOINCREMENT,timecode NUMERIC, audioData       BLOB);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                sql_stmt = "CREATE TABLE ImageInstance (imageInstanceId INTEGER PRIMARY KEY AUTOINCREMENT, imageId INTEGER);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                sql_stmt = "CREATE TABLE ImageInstanceTimeline (imageInstanceId INTEGER, timecode NUMERIC, x INTEGER, y INTEGER, scale NUMERIC, rotation NUMERIC, flip INTEGER, layer INTEGER);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                sql_stmt = "CREATE TABLE SoundTimeline (soundId INTEGER,timecode INTEGER, volume INTEGER);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                
                //sqlite3_close(db);
            } else {
                NSLog(@"Failed to open/create database");
            }
        }
        // }
        // I'm not sure why this is returning the databasePath.
        //return databasePath;
        
    }
    return self;
}

-(BOOL)updateVersion{
    char *errMsg;
    const char *sql_stmt = "DELETE FROM Version; INSERT into Version values(1.0);";
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"Failed to insert");
        return  false;
    }
    return true;
}

-(int)dbnumber:(NSArray *)array{
    int count = 0;
    for(NSString *path in array){
        if([[[path lastPathComponent] pathExtension] isEqualToString:@"db"]){
            count++;
        }
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:STDIRECTORY];
    NSString *dbpath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.db",count+1]];
    NSLog(@"newDir : %@",dbpath);
    while ([manager fileExistsAtPath:dbpath]) {
        count++;
        dbpath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.db",count+1]];
        NSLog(@"newDir : %@",dbpath);
    }
    return count;
}
@end
