//
//  STImage.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STImage.h"

@implementation STImage

- (id)initWithCGImage:(CGImageRef)CGImage{
    self = [super initWithCGImage:CGImage];
    if(self){
        [self setSizeX:[self size].width];
        [self setSizeY:[self size].height];
        [self setDefaultScale:1];
        [self setDefaultX:0];
        [self setDefaultY:0];
        [self setImageData: UIImagePNGRepresentation(self)];
    }
    return self;
}

@end