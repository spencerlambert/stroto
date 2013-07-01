//
//  STImageInstance.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

/***
 
 // This table holds instance ids for every image,
 // it makes it possible to track the movements of the
 // same image type used multiple times.
 CREATE TABLE ImageInstance (
    imageInstanceId INTEGER PRIMARY KEY AUTOINCREMENT,
    imageId         INTEGER,
 );

 
***/

#import "STImage.h"

@interface STImageInstance : STImage

@end
