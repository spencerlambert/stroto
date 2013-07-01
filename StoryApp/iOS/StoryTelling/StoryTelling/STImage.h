//
//  STImage.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

/***
 
 Need to track at least this data.
 
 imageId             INTEGER PRIMARY KEY AUTOINCREMENT,
 listDisplayOrder    INTEGER,
 sizeX               INTEGER,
 sizeY               INTEGER,
 fileType            TEXT,
 type                TEXT,
 
 Could use CGPoint:
    defaultX            INTEGER,
    defaultY            INTEGER,
 
 defaultScale        INTEGER,
 imageData           BLOB

 
 Note: Aaswini, I'm not familiar with all the different data types in Objective-C.
 You can make adjustments to my definitions if you find better ways of doing things,
 please change them.
 
 ***/

#import <UIKit/UIKit.h>

@interface STImage : UIImage

@end
