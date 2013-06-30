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
 CRATE TABLE Version (
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
    subTile         TEXT,
    sizeX           INTEGER,
    sizeY           INTEGER,
    createDateTime  NUMERIC
 );
 
 // Keeps a copy of the cropped images.
 // fileType: enum('png','jpg')
 // type: enum('foreground','backgound');
 CREATE TABLE Image (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    listDisplayOrder    INTEGER,
    sizeX               INTEGER,
    sizeY               INTEGER,
    fileType            TEXT,
    type                TEXT,
    image               BLOB
 );

 // Stores the recorded audio and the timecode to
 // start playing it in the story.  Because of the 
 // Start/Pause feature in story create, we will have 
 // multiple audio files.
 CREATE TABLE AudioRecording (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    playAtTimecode  NUMERIC,
    data            BLOB
 );
 
 // Stores the times that the background changes.
 // NOTE: Everytime Start or Pause is pressed, this
 // table needs an updadate on the current state.
 CREATE TABLE BackgroundTimeline (
    imageId             INTEGER,
    timecode            INTEGER,
    x                   INTEGER,
    y                   INTEGER,
    scale               NUMERIC,
    rotation            NUMERIC
 );

 
 // Stores the times that the foreground images change.
 // NOTE: Everytime Start is pressed, this
 // table needs an updadate on the current state.
 CREATE TABLE ForegroundTimeline (
    imageId             INTEGER,
    timecode            INTEGER,
    x                   INTEGER,
    y                   INTEGER,
    scale               NUMERIC,
    rotation            NUMERIC
 );
 
 // NOTE: Only make a DB entry when the foreground or
 // background image change.  Try and pull 30 times per
 // second.  On the first start and a start after a pause,
 // save the state of all images.
 
 
*********************/

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "STImagePosition.h"

@interface STStoryDB : NSObject;
+ (STStoryDB*)createNewSTstoryDB:(NSString*)storyPath :(CGSize*)size;
+ (STStoryDB*)loadSTstoryDB:(NSString*)stroyPath;

- (BOOL)updateDisplayName:(NSString*)name;

- (int)addBackgroundImage:(UIImage*)image;
- (int)updateBackgoundImage:(UIImage*)image :(int*)bg_id;
- (BOOL)deleteBackgroundImage:(int*)bg_id;
- (UIImage*)getBackgoundImage:(int*)bg_id;
- (NSMutableArray*)getBackgroundImageSortedListIds; // Returns a list of bg_ids sorted by the listDisplayOrder


- (int)addForegroundImage:(UIImage*)image;
- (int)updateForegoundImage:(UIImage*)image :(int*)bg_id;
- (BOOL)deleteForegroundImage:(int*)bg_id;
- (UIImage*)getForegoundImage:(int*)bg_id;
- (NSMutableArray*)getForegroundImageSortedListIds; // Returns a list of bg_ids sorted by the listDisplayOrder

- (BOOL)addBackgroundTimelineImage:(STImagePosition*)position;
- (BOOL)addForegroundTimelineImage:(STImagePosition*)position;

//Still need other methods for getting the timeline in playback mode.

@end
