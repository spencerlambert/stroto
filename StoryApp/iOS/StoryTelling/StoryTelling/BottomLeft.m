//
//  BottomLeft.m
//  StoryTelling
//
//  Created by Aaswini on 21/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "BottomLeft.h"



#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 95 : 45)
#define THUMB_WIDTH (IS_IPAD ? 95 : 45)
#define THUMB_V_PADDING 15
#define THUMB_H_PADDING 15
#define STATUS_BAR_HEIGHT 0

#define BUTTON_PADDING_X 20
#define BUTTON_PADDING_Y 20
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 55

@implementation BottomLeft

@synthesize mydelegate;
@synthesize  startplaying;

- (id)initWithFrame:(CGRect)frame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float paddingtop = THUMB_HEIGHT + THUMB_V_PADDING * 2;
    float paddingright = THUMB_WIDTH + THUMB_H_PADDING * 2;
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    frame = CGRectMake(CGRectGetMaxX(bounds)-paddingright, CGRectGetMaxY(bounds)-thumbHeight, paddingright,paddingtop);
    UIImage *btnimage = [UIImage imageNamed:@"RecordOff.png"];
    self = [super initWithFrame:frame];
    if (self) {
        startplaying = [UIButton buttonWithType:UIButtonTypeCustom];
        [startplaying setFrame:CGRectMake(0, -7, frame.size.width, frame.size.height)];
        [startplaying setBackgroundImage:btnimage forState:UIControlStateNormal];
        [startplaying addTarget:self action:@selector(startplayingbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:startplaying];
        isPlaying = NO;
        finishedPlaying = NO;
        startedPlaying = NO;
    }
    return self;
}

- (void) startplayingbtn_clicked{
    if (!startedPlaying){
        if([mydelegate respondsToSelector:@selector(startplayingview)]){
            UIImage *btnimage = [UIImage imageNamed:@"RecordOn.png"];
            [startplaying setBackgroundImage:btnimage forState:UIControlStateNormal];
            startedPlaying  =YES;
            isPlaying = YES;
            [mydelegate startplayingview];
        }
    }else{
        if (isPlaying){
            if([mydelegate respondsToSelector:@selector(pauseplayingview)]){
                UIImage *btnimage = [UIImage imageNamed:@"RecordOff.png"];
                [startplaying setBackgroundImage:btnimage forState:UIControlStateNormal];
                isPlaying = NO;
                [mydelegate pauseplayingview];
            }
        }
        else{
            if([mydelegate respondsToSelector:@selector(resumeplayingview)]){
                UIImage *btnimage = [UIImage imageNamed:@"RecordOn.png"];
                [startplaying setBackgroundImage:btnimage forState:UIControlStateNormal];
                isPlaying = YES;
                [mydelegate resumeplayingview];
            }
        }
    }

}
@end
