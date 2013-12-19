//
//  STStoryDB.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

/********************
 
 This class handles the functions to read and write things the the sqlite story db.
 
 
 DB Design
 
 // Each story gets it's own sqlite file.
 
 // For tracking the version of the database.
 // When new tables or changes are made, can use this
 // value to update the sqlite file to the newest version.
 // Very helpful when releasing new code and being able to
 // still use older files.
 CREATE TABLE Version (
    version         NUMERIC
 );
 
 // This table gets one entry only, for keeping basic
 // information about this story.
 //
 // sizeX and sizeY store the record area size
 //    iPod = 320x320
 //    iPhone4 = 640x640
 //    iPad  = ??
 //
 // The size will be used to help in scaling files
 // arcoss files, it also established the range and
 // scale in the Timeline files.
 CREATE TABLE Story (
    displayName     TEXT,
    mainTitle       TEXT,
    subTitle         TEXT,
    sizeX           INTEGER,
    sizeY           INTEGER,
    createDateTime  NUMERIC
 );
 
 // Keeps a copy of the images.
 //
 // fileType: enum('png','jpg')
 // type: enum('foreground','backgound');
 //
 // The default X, Y and Scale values are for 
 // being able to store the full scale image, say on 
 // a backgound, but display it as cropped.
 // On foregound images the defaultScale sets the size 
 // that the image is displaied when entering the screen.
 CREATE TABLE Image (
    imageId             INTEGER PRIMARY KEY AUTOINCREMENT,
    listDisplayOrder    INTEGER,
    sizeX               INTEGER,
    sizeY               INTEGER,
    fileType            TEXT,
    type                TEXT,
    defaultX            INTEGER,
    defaultY            INTEGER,
    defaultScale        INTEGER,
    imageData           BLOB,
    thumbnailData       BLOB,
    sizeScale           NUMERIC
 );
 
 // Keeps a copy of sound effects/music to be used in stories.
 // This is a future feature.
 CREATE TABLE Sound (
    soundId             INTEGER PRIMARY KEY AUTOINCREMENT,
    mp3Data             BLOB
 );
 
 // Stores the recorded audio and the timecode to
 // start playing it in the story.  Because of the 
 // Start/Pause feature in story create, we will have 
 // multiple audio files.
 CREATE TABLE AudioRecording (
    audioId         INTEGER PRIMARY KEY AUTOINCREMENT,
    timecode        NUMERIC,
    audioData       BLOB
 );
 
 
 // This table holds instance ids for every image,
 // it makes it possible to track the movements of the 
 // same image type used multiple times.
 CREATE TABLE ImageInstance (
    imageInstanceId INTEGER PRIMARY KEY AUTOINCREMENT,
    imageId         INTEGER,
 );
 
 
 // Stores the times that the forground and background
 // images change.
 //
 // NOTE: Everytime Start or Pause is pressed, this
 // table needs an updadate on the current state.
 //
 // Flip value is 0 for no and 1 for yes, it will mirror
 // the image, so that it's shown in reverse on the page.
 //
 // When layer is set to -1, the image is not currently
 // being displayed.
 CREATE TABLE ImageInstanceTimeline (
    imageInstanceId     INTEGER,
    timecode            NUMERIC,
    x                   INTEGER,
    y                   INTEGER,
    scale               NUMERIC,
    rotation            NUMERIC,
    flip                INTEGER,
    layer               INTEGER
 );

 // Future feature for playing sound effects/music in story.
 CREATE TABLE SoundTimeline (
    soundId             INTEGER,
    timecode            INTEGER,
    volume              INTEGER,
 );
 
 // NOTE: Only make a DB entry when the foreground or
 // background image change.  Try and pull 30 times per
 // second.  On the first start and a start after a pause,
 // save the state of all images.
 
 
*********************/

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "STImageInstancePosition.h"
#import "STImage.h"
#import "STStoryFile.h"
#import "CvGrabCutController.hh"


#define STDIRECTORY @"story_dir/"




@interface STStoryDB : NSObject{

NSString *databasePath;
}



+ (id)createNewSTstoryDB:(CGSize)size;
//+ (id)loadSTstoryDB:(STStoryFile*)stroyFile;
+ (id)loadSTstoryDB:(NSString*)filePath;
+ (NSMutableArray*)getStoryFiles;  //This returns an array of local stories that have sqlite dbs as STStoryFile objects.

- (id)initWithFilename:(NSString*)filePath;
- (id)initAsNewFile:(CGSize)size;

- (BOOL)updateDisplayName:(NSString*)name;

- (BOOL)addImage:(STImage*)image;  // Updates the STImage with the DB imageId
- (BOOL)updateImage:(STImage*)image;
- (BOOL)deleteImage:(STImage*)image;  // Only deletes if the image has no Instances in the ImageInstance table.
- (STImage*)getImageByID:(int)img_id;
// Changed to NSArray as the return type, because I don't think we need a Mutable list.
- (NSArray*)getBackgroundImagesSorted; // Returns a list of background STIImage* sorted by the listDisplayOrder
- (NSArray*)getForegroundImagesSorted; // Returns a list of background STIImage* sorted by the listDisplayOrder


// I'm still thinking about these.  Not sure how I want to break the timeline into to objects.
// I'm thinking having a STTimeline class that can store the timeline for all types of actors, images, sounds, audio, etc.
// Then have things like STImageInstanceTimeline that hold the specific items.
- (void)updateImageInstanceTimeline:(STImageInstancePosition*)timelineInstance;
- (NSArray *)getImageInstanceTimeline;

-(BOOL)updateVersion:(float)version;
-(BOOL)deleteSTstoryDB;//Delete the current db

- (NSArray*)getImageInstanceTable;
- (int)addImageInstance:(int)imageId;
- (NSArray *)getInstanceIDs;
- (NSArray *)getTimecodes;

- (NSString *)getDBName;
- (NSString *)getStoryName;
-(void) closeDB;
//Still need other methods for getting the timeline in playback mode.

@end
