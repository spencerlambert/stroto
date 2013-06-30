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
    imageData           BLOB
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
 
 
 // Stores the times that the background changes.
 // NOTE: Everytime Start or Pause is pressed, this
 // table needs an updadate on the current state.
 // When layer is set to -1, the image is not currently
 // being displayed.
 CREATE TABLE BackgroundTimeline (
    imageInstanceId     INTEGER,
    timecode            NUMERIC,
    x                   INTEGER,
    y                   INTEGER,
    scale               NUMERIC,
    rotation            NUMERIC,
    layer               INTEGER
 );

 
 // Stores the times that the foreground images change.
 // NOTE: Everytime Start is pressed, this
 // table needs an updadate on the current state.
 // When layer is set to -1, the image is not currently
 // being displayed.
 CREATE TABLE ForegroundTimeline (
    imageInstanceId     INTEGER,
    timecode            NUMERIC,
    x                   INTEGER,
    y                   INTEGER,
    scale               NUMERIC,
    rotation            NUMERIC,
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
- (int)updateForegoundImage:(UIImage*)image :(int*)fg_id;
- (BOOL)deleteForegroundImage:(int*)fg_id;
- (UIImage*)getForegoundImage:(int*)fg_id;
- (NSMutableArray*)getForegroundImageSortedListIds; // Returns a list of fg_ids sorted by the listDisplayOrder

- (BOOL)addBackgroundTimelineImage:(STImagePosition*)position;
- (BOOL)addForegroundTimelineImage:(STImagePosition*)position;

//Still need other methods for getting the timeline in playback mode.

@end
