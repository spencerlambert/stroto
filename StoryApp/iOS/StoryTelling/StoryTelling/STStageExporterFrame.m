//
//  STStageExporterFrame.m
//  StoryTelling
//
//  Created by Aaswini on 03/04/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStageExporterFrame.h"

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
    
    UIGraphicsBeginImageContext(size);
    if(bgImage==nil) bgImage = [[STImage alloc] initWithCGImage:[UIImage imageNamed:@"RecordArea.png"].CGImage];
    [bgImage drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    for (NSString *instanceID in fgImages) {
        STImageInstancePosition *fgimageposition = [fgImages objectForKey:instanceID];
        
        if ([[usedFgImages objectForKey:instanceID] isKindOfClass:[NSNull class]]) {
            if(![fgimageposition isKindOfClass:[NSNull class]]){
                
                int imageID = [[self.instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",fgimageposition.imageInstanceId]] intValue];
                STImage *fgimage = [self.imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
                
                UIImage *actingImage = [self imageByScalingToSize:CGSizeMake(fgimage.sizeScale, fgimage.sizeScale) withImage:fgimage];
                
                if(fgimageposition.rotation != 0){
                    actingImage = [self rotateInRadians:fgimageposition.rotation withImage:actingImage];
                }
                if(fgimageposition.scale != 1){
                    float newWidth = fgimageposition.scale * actingImage.size.width;
                    float newHeight = fgimageposition.scale * actingImage.size.height;
                    actingImage = [self imageByScalingToSize:CGSizeMake(newWidth, newHeight) withImage:actingImage];
                }
                
                [actingImage drawInRect:CGRectMake(fgimageposition.x-(fgimage.sizeScale/2),fgimageposition.y-(fgimage.sizeScale/2),actingImage.size.width,actingImage.size.height) blendMode:kCGBlendModeNormal alpha:1];
                
                [usedFgImages setObject:actingImage forKey:instanceID];
            }
        }
        else{
            if(![fgimageposition isKindOfClass:[NSNull class]]){
                UIImage* actingImage = [usedFgImages objectForKey:instanceID];
            }
        }
        
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize withImage:(UIImage*)image
{
    UIImage *newImage = nil;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                targetWidth,
                                                targetHeight,
                                                CGImageGetBitsPerComponent(image.CGImage),
                                                4 * targetWidth, CGImageGetColorSpace(image.CGImage),
                                                (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), image.CGImage);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    newImage = [UIImage imageWithCGImage:ref];
    
    if(newImage == nil) NSLog(@"could not scale image");
    CGContextRelease(bitmap);
    
    return newImage ;
}

- (UIImage*)rotateInRadians:(CGFloat)radians withImage:(UIImage*)image
{
    CGImageRef cgImage = image.CGImage;
    const CGFloat originalWidth = CGImageGetWidth(cgImage);
    const CGFloat originalHeight = CGImageGetHeight(cgImage);
    
    const CGRect imgRect = (CGRect){.origin.x = 0.0f, .origin.y = 0.0f,
        .size.width = originalWidth, .size.height = originalHeight};
    const CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, CGAffineTransformMakeRotation(radians));
    
    CGContextRef bmContext = NYXImageCreateARGBBitmapContext(rotatedRect.size.width, rotatedRect.size.height, 0);
    if (!bmContext)
        return nil;
    
    CGContextSetShouldAntialias(bmContext, true);
    CGContextSetAllowsAntialiasing(bmContext, true);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    CGContextTranslateCTM(bmContext, +(rotatedRect.size.width * 0.5f), +(rotatedRect.size.height * 0.5f));
    CGContextRotateCTM(bmContext, radians);
    
    CGContextDrawImage(bmContext, (CGRect){.origin.x = -originalWidth * 0.5f,  .origin.y = -originalHeight * 0.5f,
        .size.width = originalWidth, .size.height = originalHeight}, cgImage);
    
    CGImageRef rotatedImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* rotated = [UIImage imageWithCGImage:rotatedImageRef];
    
    CGImageRelease(rotatedImageRef);
    CGContextRelease(bmContext);
    
    return rotated;
}

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@end

