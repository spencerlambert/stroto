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

#pragma mark Encoding/Decoding



-(void)encodeWithCoder:(NSCoder *)aCoder
{
    NSLog(@"Encoding");
    
    [aCoder encodeObject:[NSNumber numberWithInt:self.imageId] forKey:@"imageId"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.listDisplayOrder] forKey:@"listDisplayOrder"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.sizeX] forKey:@"sizeX"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.sizeY] forKey:@"sizeY"];
    [aCoder encodeObject: self.fileType forKey:@"fileType"];
    [aCoder encodeObject: self.type forKey:@"type"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.defaultX] forKey:@"defaultX"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.defaultY] forKey:@"defaultY"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.defaultScale] forKey:@"defaultScale"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.minZoomScale] forKey:@"minZoomScale"];
    [aCoder encodeObject:[NSNumber numberWithFloat:self.sizeScale] forKey:@"sizeScale"];

    
    NSLog(@"Encoding finished");
    
}


- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        [self setImageId:[coder decodeIntForKey:@"imageId"]];
        [self setListDisplayOrder:[coder decodeIntForKey:@"listDisplayOrder"]];
        [self setSizeX:[coder decodeIntForKey:@"sizeX"]];
        [self setSizeY:[coder decodeIntForKey:@"sizeY"]];
        [self setFileType:[coder decodeObjectForKey:@"fileType"]];
        [self setType:[coder decodeObjectForKey:@"type"]];
        [self setDefaultX:[coder decodeIntForKey:@"defaultX"]];
        [self setDefaultY:[coder decodeIntForKey:@"defaultY"]];
        [self setDefaultScale:[coder decodeFloatForKey:@"defaultScale"]];
        [self setDefaultScale:[coder decodeFloatForKey:@"minZoomScale"]];
        [self setDefaultScale:[coder decodeFloatForKey:@"sizeScale"]];

    }
    return self;
}

@end
