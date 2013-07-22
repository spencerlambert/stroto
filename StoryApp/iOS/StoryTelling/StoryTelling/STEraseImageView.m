//
//  STEraseImageView.m
//  StoryTelling
//
//  Created by Aaswini on 18/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STEraseImageView.h"

@implementation STEraseImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) initialize{
    
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
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    
    {
        CGSize s = self.size;;
        UIGraphicsBeginImageContextWithOptions(s, NO, self.image.scale);
        [self.mask drawInRect:CGRectMake(0, 0, s.width, s.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentLocation.x, currentLocation.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 20 );
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 255, 255, 255, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeColor);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.mask = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    //       UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, 20.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.location.x, self.location.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.location = currentLocation;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    //UIGraphicsBeginImageContext(self.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.image drawInRect:CGRectMake(0, 0, self.size.width,self.size.height)];
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, 5.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeClear);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, self.location.x, self.location.y);
    CGContextAddLineToPoint(ctx, currentLocation.x, currentLocation.y);
    CGContextStrokePath(ctx);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.location = currentLocation;
}

@end
