//
//  STStagePlayerFrame.m
//  StoryTelling
//
//  Created by Aaswini on 30/12/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerFrame.h"

@implementation STStagePlayerFrame

@synthesize fgImages,bgImage;

-(id)initWithInstances:(NSArray *)instances{
    self = [super init];
    if (self) {
        fgImages = [[NSMutableDictionary alloc] init];
        for (NSString *instanceID in instances) {
            [fgImages setObject:[NSNull null] forKey:instanceID];
        }
        bgImage = nil;
    }
    return self;
}

-(id)initWithSTStagePlayerFrame:(STStagePlayerFrame *)frame{
    self = [super init];
    if (self) {
        fgImages = [[NSMutableDictionary alloc] initWithDictionary:[frame fgImages]];
        bgImage = [frame bgImage];
        self.imagesTable = [[NSMutableDictionary alloc]initWithDictionary:frame.imagesTable];
        self.instanceIDTable = [[NSMutableDictionary alloc]initWithDictionary:frame.instanceIDTable];
    }
    return self;
}

-(void)addFGImage:(STImageInstancePosition *)image withInstanceID:(int)instanceID{
    
    [fgImages setValue:image forKey:[NSString stringWithFormat:@"%d",instanceID]];
    
}

-(void)removeFGImageWithInstanceID:(int)instanceID{
    
    [fgImages setValue:nil forKey:[NSString stringWithFormat:@"%d",instanceID]];
    
}

-(void)addBGImage:(STImage *)image{
    
//    bgImage = image;
    bgImage = [[STImage alloc]initWithCGImage:image.CGImage];
    
}

-(UIImage *)getImageforFrame:(CGSize)size{
    
    UIGraphicsBeginImageContext(size);
    if(bgImage==nil) bgImage = [[STImage alloc] initWithCGImage:[UIImage imageNamed:@"RecordArea.png"].CGImage];
    [bgImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    for (NSString *instanceID in fgImages) {
        STImageInstancePosition *fgimageposition = [fgImages objectForKey:instanceID];
        
        if(![fgimageposition isKindOfClass:[NSNull class]]){
        
        int imageID = [[self.instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",fgimageposition.imageInstanceId]] intValue];
        STImage *fgimage = [self.imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
        
        [fgimage drawInRect:CGRectMake(fgimageposition.x,fgimageposition.y,fgimage.sizeX,fgimage.sizeY) blendMode:kCGBlendModeNormal alpha:1];
        }
        
    }

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

-(UIImage *)rotateImage : (UIImage *)image withAngle :(float)angle{
    
}



@end
