//
//  STEraseImageView.m
//  StoryTelling
//
//  Created by Aaswini on 18/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STEraseImageView.h"

@implementation STEraseImageView

cv::Mat inputMat;
cv::Mat maskMat;
cv::Mat bgdModel, fgdModel;
enum{ NOT_SET = 0, IN_PROCESS = 1, SET = 2 };
enum{ FOREGROUND = 1 , BACKGROUND = 2 };
uchar lblsState;
cv::vector<cv::Point> fgdPxls, bgdPxls;
cv::Rect rect;


@synthesize brush;
@synthesize flags;
@synthesize maskView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) initialize{
    brush = 0;
    lblsState = NOT_SET;
    inputMat = [self cvMatFromUIImage:self.image];
    cv::cvtColor(inputMat , inputMat , CV_RGBA2RGB);
    rect = cv::Rect(0,0, self.size.width-1,self.size.height-1);
//    maskMat = cv::Mat(inputMat.rows,inputMat.cols,CV_8UC1);
//    maskMat.setTo(cv::GC_PR_FGD);
    cv::grabCut( inputMat, maskMat, rect, bgdModel, fgdModel, 1, cv::GC_INIT_WITH_RECT );
//    maskMat = cv::Mat(inputMat.rows,inputMat.cols,CV_8UC1);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    mouseSwiped = NO;
//    UITouch *touch = [touches anyObject];
//    lastPoint = [touch locationInView:self];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    mouseSwiped = YES;
//    UITouch *touch = [touches anyObject];
//    CGPoint currentPoint = [touch locationInView:self];
//    UIImage *img = self.image;
//    CGSize s = img.size;
//    UIGraphicsBeginImageContextWithOptions(s, NO, 1);
//    [self.image drawInRect:CGRectMake(0, 0, s.width, s.height)];
//    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10 );
//    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 255, 0, 0, 1.0);
//    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
//    CGContextStrokePath(UIGraphicsGetCurrentContext());
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    lastPoint = currentPoint;
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    if(!mouseSwiped) {
//        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1);
//        //UIGraphicsBeginImageContext(self.frame.size);
//        [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10);
//        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 200, 200, 200, 1.0);
//        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
//        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//        CGContextStrokePath(UIGraphicsGetCurrentContext());
//        CGContextFlush(UIGraphicsGetCurrentContext());
//        self.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    else{
//        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 1);
//        [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) blendMode:kCGBlendModeNormal alpha:1];
//        self.image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    self.location = [touch locationInView:self];
    lblsState = IN_PROCESS;
    
    int x = self.location.x;
    int y = self.location.y;
    if( flags & BACKGROUND )
    {
        bgdPxls.push_back({static_cast<short>(x) , static_cast<short>(y)});
    }
    if( flags & FOREGROUND )
    {
        fgdPxls.push_back({static_cast<short>(x) , static_cast<short>(y)}) ;
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    
//    {
//        CGSize s = self.size;;
//        UIGraphicsBeginImageContextWithOptions(s, NO, self.image.scale);
//        [self.mask drawInRect:CGRectMake(0, 0, s.width, s.height)];
//        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
//        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentLocation.x, currentLocation.y);
//        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 20 );
//        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 255, 255, 255, 1.0);
//        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeColor);
//        CGContextStrokePath(UIGraphicsGetCurrentContext());
//        self.mask = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    
//    {
//        inputMat.push_back(currentLocation);
//    }
//    
    //UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 0);
    UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, 20.0);
    if(flags == FOREGROUND)
        CGContextSetRGBStrokeColor(ctx, 255.0, 0.0, 0.0, 1.0);
    else
        CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 255.0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeColor);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.location.x, self.location.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.location = currentLocation;
    
    int x = currentLocation.x;
    int y = currentLocation.y;
    if( flags & BACKGROUND )
    {
        bgdPxls.push_back({static_cast<short>(x) , static_cast<short>(y)});
    }
    if( flags & FOREGROUND )
    {
        fgdPxls.push_back({static_cast<short>(x) , static_cast<short>(y)}) ;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
//    UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 0);
//    //UIGraphicsBeginImageContext(self.frame.size);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [self.image drawInRect:CGRectMake(0, 0, self.image.size.width,self.image.size.height)];
//    CGContextSetLineCap(ctx, kCGLineCapRound);
//    CGContextSetLineWidth(ctx, 5.0);
//    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
//    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
//    CGContextBeginPath(ctx);
//    CGContextMoveToPoint(ctx, self.location.x, self.location.y);
//    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
//    CGContextStrokePath(ctx);
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    self.location = currentLocation;
    
    if(lblsState == IN_PROCESS){
        lblsState = NOT_SET;
    }
    
    int x = currentLocation.x;
    int y = currentLocation.y;
    if( flags & BACKGROUND )
    {
        bgdPxls.push_back({static_cast<short>(x) , static_cast<short>(y)});
    }
    if( flags & FOREGROUND )
    {
        fgdPxls.push_back({static_cast<short>(x) , static_cast<short>(y)}) ;
    }
}

void changeMask( cv::Mat& mask, cv::vector<cv::Point> bgdPixels, cv::vector<cv::Point> fgdPixels )
{
    cv::vector<cv::Point>::const_iterator it = bgdPixels.begin(), itEnd = bgdPixels.end();
    for( ; it != itEnd; ++it )
        mask.at<uchar>(*it) = cv::GC_BGD;
    it = fgdPixels.begin(), itEnd = fgdPixels.end();
    for( ; it != itEnd; ++it )
        mask.at<uchar>(*it) = cv::GC_FGD;
}

- (void) clearPixels{
    bgdPxls.clear(); fgdPxls.clear();
}

- (void) doGrabCut{
    changeMask( maskMat, bgdPxls, fgdPxls );
    [self clearPixels];
    cv::grabCut( inputMat, maskMat, rect, bgdModel, fgdModel, cv::GC_INIT_WITH_MASK );
    showImage( inputMat, maskMat, bgdPxls, fgdPxls );
    [self setImage:[self UIImageFromCVMat:inputMat]];
}

void getBinMask( const cv::Mat& comMask, cv::Mat& binMask )
{
    if( comMask.empty() || comMask.type()!=CV_8UC1 )
        CV_Error( CV_StsBadArg, "comMask is empty or has incorrect type (not CV_8UC1)" );
    if( binMask.empty() || binMask.rows!=comMask.rows || binMask.cols!=comMask.cols )
        binMask.create( comMask.size(), CV_8UC1 );
    binMask = comMask & 1;
}

cv::Mat showImage( cv::Mat& _img, cv::Mat& _mask, cv::vector<cv::Point>& _bgdPxls, cv::vector<cv::Point>& _fgdPxls )
{
    cv::Mat res;
    cv::Mat binMask;
    if( _mask.empty() )
        _img.copyTo( res );
    else
    {
        getBinMask( _mask, binMask );
        _img.copyTo( res, binMask );
    }
    
    return res;

}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels

//    int cols = 3264;
//    int rows = 1960; // assuming a ~1.66 aspect ratio here...
//    cv::Mat cvMat(rows, cols,  CV_8UC3);
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
