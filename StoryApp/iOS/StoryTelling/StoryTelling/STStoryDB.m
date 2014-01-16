//
//  STStoryDB.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStoryDB.h"
#import "STImageInstanceBackground.h"
#import "STImageInstanceForeground.h"


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
           // NSLog(@"%@",databasePath);
            
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
                
                //Removed thumbnail image from DB because it ended up as a duplicate of the full image.
                //Found that it does not simplify anything to have a pre-scaled image.
                sql_stmt = "CREATE TABLE Image (imageId INTEGER PRIMARY KEY AUTOINCREMENT, listDisplayOrder INTEGER, sizeX INTEGER, sizeY INTEGER, fileType TEXT, type TEXT, defaultX INTEGER,defaultY INTEGER,defaultScale NUMERIC,imageData BLOB, sizeScale NUMERIC);";
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


+ (id)loadSTstoryDB:(NSString*)filePath{
    
    return [[self alloc]initWithFilename:filePath];
}

- (id)initWithFilename:(NSString*)filePath{
   
    self = [super init];
    if (self) {
        NSString *docsDir;
        NSArray *dirPaths;
        
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = dirPaths[0];
        
        NSString *newDir = [docsDir stringByAppendingPathComponent:STDIRECTORY];
        // NSLog(@"newDir : %@",newDir);
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
       
        databasePath = [newDir stringByAppendingPathComponent:filePath];
       // databasePath = [databasePath stringByAppendingPathExtension:@".db"];
        
        if([fileManager fileExistsAtPath:databasePath]){
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, & db) == SQLITE_OK)
            {
                return  self;
            }else{
                NSLog(@"Error opening %@",databasePath);
                return nil;
            }

        }else{
            NSLog(@"Database is not found at path %@", databasePath);
            return nil;
        }
    }
    
    return nil;
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
        [self closeDB];
        return [manager removeItemAtPath:databasePath error:nil];
    }
    return  NO;
}

-(BOOL)addImage:(STImage *)image{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO Image('listDisplayOrder','sizeX','sizeY','fileType','type','defaultX','defaultY','defaultScale','imageData','sizeScale') VALUES (?,?,?,?,?,?,?,?,?,?);"];
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
        NSData *imageData;
        if ([image.masks count]>0 && [image.maskImgs count]>0) {
            imageData = [self getImageData:image];
        }
        else{
            imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:image.thumbimage.CGImage]);
        }
        sqlite3_bind_blob(statement, 9, [imageData bytes], [imageData length], SQLITE_STATIC);
        //sqlite3_bind_blob(statement, 10, [imageData bytes], [imageData length], SQLITE_STATIC);
        sqlite3_bind_double(statement, 10, image.sizeScale);
        // Execute the statement.
        int temp = sqlite3_step(statement);
        if (temp != SQLITE_DONE) {
            NSLog(@"Failed to insert image %s",sqlite3_errmsg(db));
            sqlite3_finalize(statement);
            return  false;
        }
    }
    // Clean up and delete the resources used by the prepared statement.
    sqlite3_finalize(statement);
    return  true; 
}

- (BOOL)updateImage:(STImage*)image{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Image set listDisplayOrder = ?,sizeX = ?,sizeY = ?,fileType =?, type = ?, defaultX = ?, defaultY = ?,defaultScale =?, imageData =?, sizeScale =?) where imageId = %d;",image.imageId];
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
        NSData *imageData;
        if ([image.masks count]>0 && [image.maskImgs count]>0) {
            imageData = [self getImageData:image];
        }
        else{
            imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:image.thumbimage.CGImage]);
        }
        sqlite3_bind_blob(statement, 9, [imageData bytes], [imageData length], SQLITE_STATIC);
        //sqlite3_bind_blob(statement, 10, [imageData bytes], [imageData length], SQLITE_STATIC);
        sqlite3_bind_double(statement, 10, image.sizeScale);
        // Execute the statement.
        int temp = sqlite3_step(statement);
        if (temp != SQLITE_DONE) {
            NSLog(@"Failed to update image %s",sqlite3_errmsg(db));
            sqlite3_finalize(statement);
            return  false;
        }
    }
    // Clean up and delete the resources used by the prepared statement.
    sqlite3_finalize(statement);
    return  true;

}

- (STImage*)getImageByID:(int)img_id{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT imageId,listDisplayOrder,sizeX,sizeY,fileType,type,defaultX,defaultY,defaultScale,imageData,sizeScale from Image where imageId = %d;",img_id];
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
            /*
            const void *ptr1 = sqlite3_column_blob(compiled_stmt, 9);
            int size1 = sqlite3_column_bytes(compiled_stmt, 9);
            NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
            UIImage *image1 = [UIImage imageWithData:data1];
            */
            // Thumbnail is really just a pointer to the main image now
            temp.thumbimage = image;
 
            temp.sizeScale = (float)sqlite3_column_double(compiled_stmt, 10);
            sqlite3_finalize(compiled_stmt);
            return  temp;
        }
    }
     sqlite3_finalize(compiled_stmt);
    return  nil;
}

- (NSArray*)getBackgroundImagesSorted{
    NSMutableArray *bgImages = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageId,listDisplayOrder,sizeX,sizeY,fileType,type,defaultX,defaultY,defaultScale,imageData,sizeScale from Image where type='background';"];
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
            /*
             const void *ptr1 = sqlite3_column_blob(compiled_stmt, 9);
             int size1 = sqlite3_column_bytes(compiled_stmt, 9);
             NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
             UIImage *image1 = [UIImage imageWithData:data1];
             */
            // Thumbnail is really just a pointer to the main image now
            temp.thumbimage = image;
            
            temp.sizeScale = (float)sqlite3_column_double(compiled_stmt,10);
            [bgImages addObject:temp];
        }
        
    }
    sqlite3_finalize(compiled_stmt);
    return bgImages;
}

- (NSDictionary*)getImagesTable{
    NSMutableDictionary *bgImages = [[NSMutableDictionary alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageId,listDisplayOrder,sizeX,sizeY,fileType,type,defaultX,defaultY,defaultScale,imageData,sizeScale from Image;"];
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
            /*
            const void *ptr1 = sqlite3_column_blob(compiled_stmt, 9);
            int size1 = sqlite3_column_bytes(compiled_stmt, 9);
            NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
            UIImage *image1 = [UIImage imageWithData:data1];
            */
            // Thumbnail is really just a pointer to the main image now
            temp.thumbimage = image;
            
            temp.sizeScale = (float)sqlite3_column_double(compiled_stmt,10);
            
            [bgImages setObject:temp forKey:[NSString stringWithFormat:@"%d", temp.imageId]];
        }
        
    }
    sqlite3_finalize(compiled_stmt);
    return bgImages;
}

- (NSArray*)getForegroundImagesSorted{
    NSMutableArray *fgImages = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageId,listDisplayOrder,sizeX,sizeY,fileType,type,defaultX,defaultY,defaultScale,imageData,sizeScale from Image where type='foreground';"];
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
            /*
            const void *ptr1 = sqlite3_column_blob(compiled_stmt, 9);
            int size1 = sqlite3_column_bytes(compiled_stmt, 9);
            NSData *data1 = [[NSData alloc] initWithBytes:ptr1 length:size1];
            UIImage *image1 = [UIImage imageWithData:data1];
            */
            // Thumbnail is really just a pointer to the main image now
            temp.thumbimage = image;
            
            temp.sizeScale= (float)sqlite3_column_double(compiled_stmt, 10);
            [fgImages addObject:temp];
        }
        
    }
    sqlite3_finalize(compiled_stmt);
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
    char *errMsg;
    NSString *sql = [NSString stringWithFormat:@"UPDATE Story set displayName='%@';",name];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"Failed to update story name : %s",errMsg);
        return  false;
    }
    return true;
}

-(NSData*)getImageData:(STImage*)image{
    return UIImagePNGRepresentation([self maskImage:[image.maskImgs lastObject] withMask:[image.masks lastObject]]);
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
         maskImage = [self negativeImage:maskImage];
     }
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
    CGContextRef context = CGBitmapContextCreate(nil,
                                                 CGImageGetWidth(maskedImageRef),
                                                 CGImageGetHeight(maskedImageRef),
                                                 CGImageGetBitsPerComponent(maskedImageRef),
                                                 CGImageGetBytesPerRow(maskedImageRef),
                                                 CGImageGetColorSpace(maskedImageRef),
                                                 CGImageGetBitmapInfo(maskedImageRef));
    
    CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(maskedImageRef), CGImageGetHeight(maskedImageRef));
    CGContextDrawImage(context, imageRect, maskedImageRef);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    maskedImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGContextRelease(context);
    }
    
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

- (UIImage *)negativeImage:(UIImage*)image
{
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    CGSize size = image.size;
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colourSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    // draw the current image to the newly created context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            // get RGB values. We're dealing with premultiplied alpha
            // here, so we need to divide by the alpha channel (if it
            // isn't zero, of course) to get uninflected RGB. We
            // multiply by 255 to keep precision while still using
            // integers
            int r, g, b;
            if(linePointer[3])
            {
                r = linePointer[0] * 255 / linePointer[3];
                g = linePointer[1] * 255 / linePointer[3];
                b = linePointer[2] * 255 / linePointer[3];
            }
            else
                r = g = b = 0;
            
            // perform the colour inversion
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            
            // multiply by alpha again, divide by 255 to undo the
            // scaling before, store the new values and advance
            // the pointer we're reading pixel data from
            linePointer[0] = r * linePointer[3] / 255;
            linePointer[1] = g * linePointer[3] / 255;
            linePointer[2] = b * linePointer[3] / 255;
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a
    // UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    // and return
    return returnImage;
}



-(NSArray*)getImageInstanceTable{
    NSMutableArray *imageInstances = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * from ImageInstance;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            int imageID = sqlite3_column_int(compiled_stmt, 1);
            STImage *image = [self getImageByID:imageID];
            if ([image.type isEqualToString:@"background"]) {
                STImageInstanceBackground *instance = [[STImageInstanceBackground alloc]initBGInstanceWithID:instanceID imageID:imageID];
                [imageInstances addObject:instance];
            }else if([image.type isEqualToString:@"foreground"]){
                STImageInstanceForeground *instance = [[STImageInstanceForeground alloc]initFGInstanceWithID:instanceID imageID:imageID];
                [imageInstances addObject:instance];
            }
        }
    }
    sqlite3_finalize(compiled_stmt);
    return imageInstances;
}

-(NSDictionary*)getImageInstanceTableAsDictionary{
    NSMutableDictionary *imageInstances = [[NSMutableDictionary alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * from ImageInstance;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            int imageID = sqlite3_column_int(compiled_stmt, 1);
            [imageInstances setValue:[NSNumber numberWithInt:imageID] forKey:[NSString stringWithFormat:@"%d",instanceID]];
        }
    }
    sqlite3_finalize(compiled_stmt);
    return imageInstances;
}

- (int)addImageInstance:(int)imageId{
    char *errMsg;
    NSString *sql = [NSString stringWithFormat:@"INSERT into ImageInstance ('imageId') values(%d);", imageId ];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"Failed to insert ImageInstance : %s",errMsg);
        return -1;
    }
    
//    sql = @"select last_insert_rowid();";
//    const char *sql_stmt1 = [sql UTF8String];
//    sqlite3_stmt *compiled_stmt;
//    int id1 = sqlite3_last_insert_rowid(db);
//    if(sqlite3_prepare_v2(db, sql_stmt1, -1, &compiled_stmt, NULL) == SQLITE_OK){
//        int instanceID = sqlite3_column_int(compiled_stmt, 0);
//        return instanceID;
//    }
//    else{
//    return  -1;
    int instanceID = sqlite3_last_insert_rowid(db);
        return instanceID;
//    }
}

- (void)updateImageInstanceTimeline:(STImageInstancePosition*)timelineInstance{
    char *errMsg;
    NSString *sql = [NSString stringWithFormat:@"INSERT into ImageInstanceTimeline ('imageInstanceId','timecode','x','y','scale','rotation','flip','layer') values(%d,%f,%d,%d,%f,%f,%d,%d);", timelineInstance.imageInstanceId,timelineInstance.timecode,timelineInstance.x,timelineInstance.y,timelineInstance.scale,timelineInstance.rotation,timelineInstance.flip,timelineInstance.layer ];
    const char *sql_stmt = [sql UTF8String];
    if (sqlite3_exec(db, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSLog(@"Failed to insert ImageInstance : %s",errMsg);
    }
}

- (NSArray *)getImageInstanceTimeline{
    NSMutableArray *imageInstancesTimeline = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT * from ImageInstanceTimeline;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            STImageInstancePosition *timelineInstance = [[STImageInstancePosition alloc]init];
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            float timecode = sqlite3_column_double(compiled_stmt, 1);
            int x = sqlite3_column_int(compiled_stmt, 2);
            int y = sqlite3_column_int(compiled_stmt, 3);
            float scale = sqlite3_column_double(compiled_stmt, 4);
            float rotation = sqlite3_column_double(compiled_stmt, 5);
            int flip = sqlite3_column_int(compiled_stmt, 6);
            int layer = sqlite3_column_int(compiled_stmt, 7);
            timelineInstance.imageInstanceId = instanceID;
            timelineInstance.timecode = timecode;
            timelineInstance.x = x;
            timelineInstance.y = y;
            timelineInstance.scale = scale;
            timelineInstance.rotation = rotation;
            timelineInstance.flip = flip;
            timelineInstance.layer = layer;
            [imageInstancesTimeline addObject:timelineInstance];
        }
    }
    sqlite3_finalize(compiled_stmt);
    return imageInstancesTimeline;
}

- (NSString *)getDBName{
    return [[databasePath lastPathComponent]stringByDeletingPathExtension];
}

- (NSString *)getStoryName{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT displayName from Story;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
            NSString *temp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 0)];
            sqlite3_finalize(compiled_stmt);
            return  temp;
        }
    }
    sqlite3_finalize(compiled_stmt);
    return @"";
}

-(CGSize)getStorySize{
    CGSize size;
    NSString *sql = [NSString stringWithFormat:@"SELECT sizeX,sizeY from Story;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
            int sizex = sqlite3_column_int(compiled_stmt, 0);
            int sizey = sqlite3_column_int(compiled_stmt, 1);
            size = CGSizeMake(sizex, sizey);
        }
    }
    sqlite3_finalize(compiled_stmt);
    return size;
 
}

- (NSArray *)getInstanceIDs{
    NSMutableArray *instanceIDs = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageInstanceId from ImageInstance;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            [instanceIDs addObject:[NSNumber numberWithInt:instanceID]];
        }
    }
    sqlite3_finalize(compiled_stmt);
    return instanceIDs;
}

- (NSArray *)getInstanceIDsAsString{
    NSMutableArray *instanceIDs = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageInstanceId from ImageInstance;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            [instanceIDs addObject:[NSString stringWithFormat:@"%d",instanceID]];
        }
    }
    sqlite3_finalize(compiled_stmt);
    return instanceIDs;
}

-(NSArray *)getTimecodes{
    NSMutableArray *timecodes = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT timecode from ImageInstanceTimeline;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while (sqlite3_step(compiled_stmt) == SQLITE_ROW){
            float timeecode = sqlite3_column_int(compiled_stmt, 1);
            [timecodes addObject:[NSNumber numberWithFloat:timeecode]];
        }
    }
    sqlite3_finalize(compiled_stmt);
    return timecodes;
   
}

-(STImageInstancePosition *)getLastRow:(int)imageinstanceID{
    STImageInstancePosition *timelineInstance = [[STImageInstancePosition alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageInstanceId,timecode,x, y, scale, rotation, flip, layer FROM ImageInstanceTimeline where rowid = (select max(rowid) from ImageInstanceTimeline where imageInstanceID = %d);",imageinstanceID];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            float timecode = sqlite3_column_int(compiled_stmt, 1);
            int x = sqlite3_column_int(compiled_stmt, 2);
            int y = sqlite3_column_int(compiled_stmt, 3);
            float scale = sqlite3_column_int(compiled_stmt, 4);
            float rotation = sqlite3_column_int(compiled_stmt, 5);
            int flip = sqlite3_column_int(compiled_stmt, 6);
            int layer = sqlite3_column_int(compiled_stmt, 7);
            timelineInstance.imageInstanceId = instanceID;
            timelineInstance.timecode = timecode;
            timelineInstance.x = x;
            timelineInstance.y = y;
            timelineInstance.scale = scale;
            timelineInstance.rotation = rotation;
            timelineInstance.flip = flip;
            timelineInstance.layer = layer;
            
        }
    }
    sqlite3_finalize(compiled_stmt);
    return timelineInstance;
}

-(NSArray *)getimageInstanceTimeline:(int)imageinstanceID{
    NSMutableArray *imageInstancesTimeline = [[NSMutableArray alloc]init];
    NSString *sql = [NSString stringWithFormat:@"SELECT imageInstanceId,timecode,x, y, scale, rotation, flip, layer FROM ImageInstanceTimeline where imageInstanceID = %d);",imageinstanceID];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        while(sqlite3_step(compiled_stmt) == SQLITE_ROW){
            STImageInstancePosition *timelineInstance = [[STImageInstancePosition alloc]init];
            int instanceID = sqlite3_column_int(compiled_stmt, 0);
            float timecode = sqlite3_column_int(compiled_stmt, 1);
            int x = sqlite3_column_int(compiled_stmt, 2);
            int y = sqlite3_column_int(compiled_stmt, 3);
            float scale = sqlite3_column_int(compiled_stmt, 4);
            float rotation = sqlite3_column_int(compiled_stmt, 5);
            int flip = sqlite3_column_int(compiled_stmt, 6);
            int layer = sqlite3_column_int(compiled_stmt, 7);
            timelineInstance.imageInstanceId = instanceID;
            timelineInstance.timecode = timecode;
            timelineInstance.x = x;
            timelineInstance.y = y;
            timelineInstance.scale = scale;
            timelineInstance.rotation = rotation;
            timelineInstance.flip = flip;
            timelineInstance.layer = layer;
            [imageInstancesTimeline addObject:timelineInstance];
        }
    }
    sqlite3_finalize(compiled_stmt);
    return imageInstancesTimeline;

}


- (void)closeDB
{
    sqlite3_close(db);
}

@end
