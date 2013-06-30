//
//  STImagePosition.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//


/*******
 This is a simple class to handle the position values of:
 
 imageid
 x
 y
 rotation
 scale
 timecode
 
 Used for saving the position of an image in a STstoryDB.
 Can be kept in memory durring a recording, then dumped to
 the sqlite db in the background.
********/

#import <Foundation/Foundation.h>

@interface STImagePosition : NSObject

@end
