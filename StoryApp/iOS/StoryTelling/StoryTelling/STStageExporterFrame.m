//
//  STStageExporterFrame.m
//  StoryTelling
//
//  Created by Aaswini on 03/04/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStageExporterFrame.h"
#import "STStageExporterFrameTransformHelper.h"

static NSMutableDictionary *usedFgImages;

@implementation STStageExporterFrame

@synthesize fgImages,bgImage;

-(id)initWithInstances:(NSArray *)instances{
    self = [super init];
    if (self) {
        fgImages = [[NSMutableDictionary alloc] init];
        usedFgImages = [[NSMutableDictionary alloc] init];
        for (NSString *instanceID in instances) {
            [fgImages setObject:[NSNull null] forKey:instanceID];
            [usedFgImages setObject:[NSNull null] forKey:instanceID];
        }
        bgImage = nil;
    }
    return self;
}

-(id)initWithSTStageExporterFrame:(STStageExporterFrame *)frame{
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
    NSMutableArray* actingImages = [[NSMutableArray alloc]init];
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    
    
    for (NSString *instanceID in fgImages) {
        
        STImageInstancePosition *fgimageposition = [fgImages objectForKey:instanceID];
        
        
        
        if ([[usedFgImages objectForKey:instanceID] isKindOfClass:[NSNull class]]) {
            
            if(![fgimageposition isKindOfClass:[NSNull class]]){
                
                
                
                int imageID = [[self.instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",fgimageposition.imageInstanceId]] intValue];
                
                STImage *fgimage = [self.imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
                
                
                
                UIImage *actingImage = [self imageWithImage:fgimage scaledToSize:CGSizeMake(fgimage.sizeScale, fgimage.sizeScale)];
                
                
                
                if(fgimageposition.rotation != 0){
                    
                    actingImage = [self rotateImage:[UIImage imageWithCGImage:actingImage.CGImage] byRadian:fgimageposition.rotation];
                    
                }
                
                if(fgimageposition.scale != 1){
                    
                    float newWidth = fgimageposition.scale * actingImage.size.width;
                    
                    float newHeight = fgimageposition.scale * actingImage.size.height;
                    
                    actingImage = [self imageWithImage:actingImage scaledToSize:CGSizeMake(newWidth, newHeight)];
                    
                }
                
                
                
                CGRect drawRect = CGRectMake(fgimageposition.x - (actingImage.size.width/2.0) + ((size.width - screenWidth)/2), fgimageposition.y - (actingImage.size.height/2.0) + ((size.width - screenWidth)/2), actingImage.size.width, actingImage.size.height);
                
                
                
                STStageExporterFrameTransformHelper *helper = [[STStageExporterFrameTransformHelper alloc]init];
                
                [helper setRotation:fgimageposition.rotation];
                
                [helper setScale:fgimageposition.scale];
                
                
                
                [usedFgImages setObject:helper forKey:instanceID];
                
                
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                [dict setObject:actingImage forKey:@"image"];
                
                [dict setObject:@[[NSNumber numberWithFloat:drawRect.origin.x],[NSNumber numberWithFloat:drawRect.origin.y],[NSNumber numberWithFloat:drawRect.size.width],[NSNumber numberWithFloat:drawRect.size.height]] forKey:@"rect"];
                
                
                
                [actingImages addObject:dict];
                
            }
            
        }
        
        else{
            
            if(![fgimageposition isKindOfClass:[NSNull class]]){
                
                int imageID = [[self.instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",fgimageposition.imageInstanceId]] intValue];
                
                STImage *fgimage = [self.imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
                
                UIImage *actingImage = [self imageWithImage:fgimage scaledToSize:CGSizeMake(fgimage.sizeScale, fgimage.sizeScale)];
                
                STStageExporterFrameTransformHelper *helper = [usedFgImages objectForKey:instanceID];
                
                
                
                float newrotation = [helper rotation] ;
                
                float newscale = [helper scale] ;
                
                
                
                if(fgimageposition.rotation != 0 || [helper rotation] != 0){
                    
                    newrotation = [helper rotation] + fgimageposition.rotation ;
                    
                    actingImage = [self rotateImage:[UIImage imageWithCGImage:actingImage.CGImage] byRadian:newrotation];
                    
                }
                
                if(fgimageposition.scale != 1 || [helper scale] != 1){
                    
                    newscale = [helper scale] + (fgimageposition.scale>=1?(fgimageposition.scale-1):fgimageposition.scale-1) ;
                    
                    float newWidth = newscale * actingImage.size.width;
                    
                    float newHeight = newscale * actingImage.size.height;
                    
                    actingImage = [self imageWithImage:actingImage scaledToSize:CGSizeMake(newWidth, newHeight)];
                    
                }
                
                
                
                
                
                
                
                CGRect drawRect = CGRectMake(fgimageposition.x - (actingImage.size.width/2.0) + ((size.width - screenWidth)/2), fgimageposition.y - (actingImage.size.height/2.0) + ((size.width - screenWidth)/2), actingImage.size.width, actingImage.size.height);
                
                
                
                STStageExporterFrameTransformHelper *helper1 = [[STStageExporterFrameTransformHelper alloc]init];
                
                [helper1 setRotation:newrotation];
                
                [helper1 setScale:newscale];
                
                [usedFgImages setObject:helper1 forKey:instanceID];
                
                
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                
                [dict setObject:actingImage forKey:@"image"];
                
                [dict setObject:@[[NSNumber numberWithFloat:drawRect.origin.x],[NSNumber numberWithFloat:drawRect.origin.y],[NSNumber numberWithFloat:drawRect.size.width],[NSNumber numberWithFloat:drawRect.size.height]] forKey:@"rect"];
                
                
                
                [actingImages addObject:dict];
                
            }
            
        }
        
        
        
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    
    if(bgImage==nil) bgImage = [[STImage alloc] initWithCGImage:[UIImage imageNamed:@"RecordArea.png"].CGImage];
    
    [bgImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    for (NSDictionary *actingImageDict in actingImages) {
        
        UIImage *actingImage = [actingImageDict objectForKey:@"image"];
        
        NSArray *drawCoords = [actingImageDict objectForKey:@"rect"];
        
        CGRect drawRect = CGRectMake([drawCoords[0] floatValue], [drawCoords[1] floatValue], [drawCoords[2] floatValue], [drawCoords[3] floatValue]);
        
        if(actingImage != nil){
            
            [actingImage drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1.0];
            
        }
        
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
    
    
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIImage *newImage;
    
    if(image.size.width >= image.size.height){
        newImage = [self imageWithImage:image scaledToWidth:newSize.width];
    }else if (image.size.height >image.size.width){
        newImage = [self imageWithImage:image scaledToHeight:newSize.height];
    }
    
    return newImage;
    
    //    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    //    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    //    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return newImage;
}

//- (UIImage *)imageByScalingToSize:(CGSize)targetSize withImage:(UIImage*)image
//{
//    UIImage *newImage = nil;
//    
//    CGFloat targetWidth = targetSize.width;
//    CGFloat targetHeight = targetSize.height;
//    
//    CGContextRef bitmap = CGBitmapContextCreate(NULL,
//                                                targetWidth,
//                                                targetHeight,
//                                                CGImageGetBitsPerComponent(image.CGImage),
//                                                4 * targetWidth, CGImageGetColorSpace(image.CGImage),
//                                                (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
//    
//    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), image.CGImage);
//    
//    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
//    newImage = [UIImage imageWithCGImage:ref];
//    
//    if(newImage == nil) NSLog(@"could not scale image");
//    CGContextRelease(bitmap);
//    
//    return newImage ;
//}

- (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width {//method to scale image accordcing to width
    
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight),NO,1.0);
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToHeight: (float) i_height {//method to scale image accordcing to width
    
    float oldHeight = sourceImage.size.height;
    float scaleFactor = i_height / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth, newHeight),NO,1.0);
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees
{
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, image.size.width, image.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, YES, 1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
    CGContextTranslateCTM( ctx, 0.5f * rotatedSize.width, 0.5f * rotatedSize.height ) ;
    CGContextRotateCTM(ctx, degrees);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[image size].width/2,-[image size].height/2,image.size.width, image.size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}

- (UIImage *)rotateImage:(UIImage*)src byRadian:(CGFloat)radian
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0, src.size.width, src.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(radian);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, 1.0);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2.0, rotatedSize.height/2.0);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, radian);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-src.size.width / 2.0, -src.size.height / 2.0, src.size.width, src.size.height), [src CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};


@end

