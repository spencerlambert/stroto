//
//  STImageInstancePosition.h
//  StoryTelling
//
//  Created by Spencer Lambert on 6/29/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//


/*******
 This is a simple class to handle the position values of:
 
 imageInstanceId
 x
 y
 rotation
 scale
 timecode
 layer
 flip
 
 Used for saving the position of an image in a STstoryDB.
 Can be kept in memory durring a recording, then dumped to
 the sqlite db in the background.
********/

#import <Foundation/Foundation.h>

@interface STImageInstancePosition : NSObject

{
 @public
    
int imageInstanceId;
int x;
int y;
float rotation;
float scale;
float timecode;
int layer;
int flip;
int perspective;
}
-(id)init;
@end
