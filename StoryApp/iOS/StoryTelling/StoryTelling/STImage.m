//
//  STImage.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//


#import "STImage.h"


#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))

@implementation STImage

- (id)initWithCGImage:(CGImageRef)CGImage{
    self = [super initWithCGImage:CGImage];
    if(self){
        [self setSizeX:[self size].width];
        [self setSizeY:[self size].height];
        [self setDefaultScale:1];
        [self setMinZoomScale:0];
        [self setDefaultX:0];
        [self setDefaultY:0];
        [self setImageData: UIImagePNGRepresentation(self)];
        [self setSizeScale:IS_IPAD?200:100];
        [self setIsEdited:NO];
        [self setMasks:[[NSMutableArray alloc]init]];
        [self setMaskImgs:[[NSMutableArray alloc]init]];
    }
    return self;
}
@end
