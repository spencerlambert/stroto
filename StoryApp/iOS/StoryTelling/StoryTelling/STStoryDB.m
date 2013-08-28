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

+(id)createNewSTstoryDB:(CGSize)size{
    return [[self alloc] initAsNewFile:size];
    
}



-(id)initAsNewFile: (CGSize)size{
    
    self = [super init];
       
    if (self) {
        
       // NSLog(@"size : %@",NSStringFromCGSize(*size));
        
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        
        NSString *newDir = [docsDir stringByAppendingPathComponent:STDIRECTORY];
        // NSLog(@"newDir : %@",newDir);
        
        NSFileManager *fileManger = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManger createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            NSLog(@"error creating directory: %@", error);
        }
        
        NSArray *arrayFiles = [fileManger contentsOfDirectoryAtPath:newDir error:nil];
       // NSLog(@"Files : %@",arrayFiles);
        
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
           // NSLog(@"Count : %d",[self dbnumber:arrayFiles]);
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
                    NSLog(@"Failed to create table1");
                }
                
                [self updateVersion:1.0];
                
                sql_stmt = "CREATE TABLE Story (displayName TEXT, mainTitle TEXT, subTitle TEXT, sizeX INTEGER, sizeY INTEGER, createDateTime  NUMERIC);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table2");
                }
                
                [self initStoryTable:size];
                
                sql_stmt = "CREATE TABLE Image (imageId INTEGER PRIMARY KEY AUTOINCREMENT, listDisplayOrder INTEGER, sizeX INTEGER, sizeY INTEGER, fileType TEXT, type TEXT, defaultX INTEGER,defaultY INTEGER,defaultScale NUMERIC,imageData BLOB, thumbnailData BLOB);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table3");
                }
                
                sql_stmt = "CREATE TABLE Sound (soundId INTEGER PRIMARY KEY AUTOINCREMENT, mp3Data BLOB);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table4");
                }
                
                sql_stmt = "CREATE TABLE AudioRecording (audioId INTEGER PRIMARY KEY AUTOINCREMENT,timecode NUMERIC, audioData       BLOB);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table5");
                }
                
                sql_stmt = "CREATE TABLE ImageInstance (imageInstanceId INTEGER PRIMARY KEY AUTOINCREMENT, imageId INTEGER);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table6");
                }
                
                sql_stmt = "CREATE TABLE ImageInstanceTimeline (imageInstanceId INTEGER, timecode NUMERIC, x INTEGER, y INTEGER, scale NUMERIC, rotation NUMERIC, flip INTEGER, layer INTEGER);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table7");
                }
                
                sql_stmt = "CREATE TABLE SoundTimeline (soundId INTEGER,timecode INTEGER, volume INTEGER);";
                if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table8");
                }
                
            } else {
                NSLog(@"Failed to open/create database");
            }
        }
    }
    return self;
}

-(BOOL)updateVersion:(float)version{
    char *errMsg;
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM Version; INSERT into Version values(%f);",version];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"Failed to insert version");
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
    // NSLog(@"newDir : %@",dbpath);
    while ([manager fileExistsAtPath:dbpath]) {
        count++;
        dbpath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.db",count+1]];
    // NSLog(@"newDir : %@",dbpath);
    }
    return count;
}

-(BOOL)deleteSTstoryDB{
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:databasePath]){
        return [manager removeItemAtPath:databasePath error:nil];
    }
    return  NO;
}

-(BOOL)addImage:(STImage *)image{
   
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO Image('listDisplayOrder','sizeX','sizeY','fileType','type','defaultX','defaultY','defaultScale','imageData','thumbnailData') VALUES (?,?,?,?,?,?,?,?,?,?);"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *statement;
        // Prepare the statement.
    if (sqlite3_prepare_v2(db, sql_stmt, -1, &statement, NULL) == SQLITE_OK) {
        
        sqlite3_bind_int(statement, 1, image.listDisplayOrder);
        sqlite3_bind_int(statement, 2, image.sizeX);
        sqlite3_bind_int(statement, 3, image.sizeY);
        sqlite3_bind_text(statement, 4, [image.fileType UTF8String], -1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [image.type UTF8String], -1,SQLITE_TRANSIENT);
        sqlite3_bind_int(statement, 6, image.defaultX);
        sqlite3_bind_int(statement, 7, image.defaultY);
        sqlite3_bind_double(statement, 8, image.defaultScale);
        sqlite3_bind_blob(statement, 9, [image.imageData bytes], [image.imageData length], SQLITE_STATIC);
        NSData *imageData = UIImagePNGRepresentation(image.thumbimage);
        sqlite3_bind_blob(statement, 10, [imageData bytes], [imageData length], SQLITE_STATIC);
        // Execute the statement.
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"Failed to insert images");
            return  false;
        }
    }
    // Clean up and delete the resources used by the prepared statement.
    sqlite3_finalize(statement);
    return  true; 
}

- (STImage*)getImageByID:(int)img_id{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * from Image where imageId = %d;",img_id];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
            const void *ptr = sqlite3_column_blob(compiled_stmt, 9);
            int size = sqlite3_column_bytes(compiled_stmt, 9);
            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
            UIImage *image = [UIImage imageWithData:data];
            STImage *temp = [[STImage alloc]initWithCGImage:image.CGImage];
            temp.imageId = img_id;
            temp.listDisplayOrder = sqlite3_column_int(compiled_stmt, 1);
            temp.sizeX = sqlite3_column_int(compiled_stmt, 2);
            temp.sizeY = sqlite3_column_int(compiled_stmt, 3);
            temp.fileType =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 4)];
            temp.type =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 5)];
            temp.defaultX = sqlite3_column_int(compiled_stmt, 6);
            temp.defaultY = sqlite3_column_int(compiled_stmt, 7);
            temp.defaultScale = (float)sqlite3_column_double(compiled_stmt, 8);
            const void *ptr1 = sqlite3_column_blob(compiled_stmt, 10);
            int size1 = sqlite3_column_bytes(compiled_stmt, 10);
            NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
            UIImage *image1 = [UIImage imageWithData:data1];
            temp.thumbimage = image1;
            return  temp;
        }
    }
    return  nil;
}

- (NSArray*)getBackgroundImagesSorted{
    NSMutableArray *bgImages = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * from Image where type='background';"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            const void *ptr = sqlite3_column_blob(compiled_stmt, 9);
            int size = sqlite3_column_bytes(compiled_stmt, 9);
            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
            UIImage *image = [UIImage imageWithData:data];
            STImage *temp = [[STImage alloc]initWithCGImage:image.CGImage];
            temp.imageId = sqlite3_column_int(compiled_stmt, 0);
            temp.listDisplayOrder = sqlite3_column_int(compiled_stmt, 1);
            temp.sizeX = sqlite3_column_int(compiled_stmt, 2);
            temp.sizeY = sqlite3_column_int(compiled_stmt, 3);
            temp.fileType =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 4)];
            temp.type =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 5)];
            temp.defaultX = sqlite3_column_int(compiled_stmt, 6);
            temp.defaultY = sqlite3_column_int(compiled_stmt, 7);
            temp.defaultScale = (float)sqlite3_column_double(compiled_stmt, 8);
            const void *ptr1 = sqlite3_column_blob(compiled_stmt, 10);
            int size1 = sqlite3_column_bytes(compiled_stmt, 10);
            NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
            UIImage *image1 = [UIImage imageWithData:data1];
            temp.thumbimage = image1;
            [bgImages addObject:temp];
        }
        
    }
    return bgImages;
}

- (NSArray*)getForegroundImagesSorted{
    NSMutableArray *fgImages = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * from Image where type='foreground';"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            const void *ptr = sqlite3_column_blob(compiled_stmt, 9);
            int size = sqlite3_column_bytes(compiled_stmt, 9);
            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
            UIImage *image = [UIImage imageWithData:data];
            STImage *temp = [[STImage alloc]initWithCGImage:image.CGImage];
            temp.imageId = sqlite3_column_int(compiled_stmt, 0);
            temp.listDisplayOrder = sqlite3_column_int(compiled_stmt, 1);
            temp.sizeX = sqlite3_column_int(compiled_stmt, 2);
            temp.sizeY = sqlite3_column_int(compiled_stmt, 3);
            temp.fileType =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 4)];
            temp.type =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 5)];
            temp.defaultX = sqlite3_column_int(compiled_stmt, 6);
            temp.defaultY = sqlite3_column_int(compiled_stmt, 7);
            temp.defaultScale = (float)sqlite3_column_double(compiled_stmt, 8);
            const void *ptr1 = sqlite3_column_blob(compiled_stmt, 10);
            int size1 = sqlite3_column_bytes(compiled_stmt, 10);
            NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
            UIImage *image1 = [UIImage imageWithData:data1];
            temp.thumbimage = image1;
            [fgImages addObject:temp];
        }
        
    }
    return fgImages;
}

//To init the Story table
-(void)initStoryTable:(CGSize)size{
   NSString *sql = [NSString stringWithFormat:@"INSERT into Story values('','','',%f,%f,%.0f);", size.width,size.height,[[NSDate date]timeIntervalSince1970] ];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, NULL) != SQLITE_OK)
    {
        NSLog(@"Failed to insert story");
    }
   }

- (BOOL)updateDisplayName:(NSString*)name{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Story set displayName='%@';",name];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, NULL) != SQLITE_OK)
    {
        NSLog(@"Failed to update story name");
        return  false;
    }
    return true;
}

@end
