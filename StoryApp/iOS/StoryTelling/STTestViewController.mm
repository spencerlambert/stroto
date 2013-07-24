//
//  STTestViewController.m
//  StoryTelling
//
//  Created by Aaswini on 24/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STTestViewController.h"

@interface STTestViewController ()

@end

@implementation STTestViewController

@synthesize myimage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
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

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageview.image = self.myimage;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageview:nil];
    [super viewDidUnload];
}

- (void)cut {
    cv::Mat inputMat;
    inputMat = [self cvMatFromUIImage:self.myimage];
    cv::cvtColor(inputMat , inputMat , CV_RGBA2RGB);
    //cv::Mat mask = cv::Mat::ones(inputMat.size, CV_8U) * cv::GC_BGD;
    cv::Mat result; // segmentation (4 possible values)
    cv::Mat bgModel,fgModel; // the models (internally used)
    cv::Rect rectangle(10,100,380,180);
    // GrabCut segmentation
    cv::grabCut(inputMat,    // input image
                result,      // segmentation result
                rectangle,   // rectangle containing foreground
                bgModel,fgModel, // models
                1,           // number of iterations
                cv::GC_INIT_WITH_RECT); // use rectangle
    cv::compare(result,cv::GC_PR_FGD,result,cv::CMP_EQ);
    // Generate output image
    cv::Mat foreground(inputMat.size(),CV_8UC3,
                       cv::Scalar(255,255,255));
    inputMat.copyTo(foreground,// bg pixels are not copied
                    result);
    // checking first bit with bitwise-and
    result= result&1; // will be 1 if FG
    // Generate output image
    cv::Mat foreground1(inputMat.size(),CV_8UC3,
                        cv::Scalar(255,255,255)); // all white image
    inputMat.copyTo(foreground1,result); // bg pixels not copied
    
    
    //    cv::Mat greyMat;
    //cv::cvtColor(inputMat, greyMat, CV_BGR2GRAY);
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[self UIImageFromCVMat:foreground1]];
    [self.view addSubview:imageview];
}
- (IBAction)grabcut:(id)sender {
    [self cut];
}
@end
