//
//  TopRightView.m
//  StoryTelling
//
//  Created by Aaswini on 22/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "TopRightView.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define THUMB_HEIGHT 45
#define THUMB_WIDTH 45
#define THUMB_V_PADDING 15
#define THUMB_H_PADDING 15
#define STATUS_BAR_HEIGHT 0

#define BUTTON_PADDING_X 20
#define BUTTON_PADDING_Y 15
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 55

@implementation TopRightView

@synthesize done;
@synthesize mydelegate;

- (id)initWithFrame:(CGRect)frame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float paddingtop = THUMB_HEIGHT + THUMB_V_PADDING * 2;
    float paddingright = THUMB_WIDTH + THUMB_H_PADDING * 2;
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2;

    if (IS_IPHONE_5) {
        frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds)-thumbHeight, paddingright,paddingtop);
    } else {
        frame = CGRectMake(CGRectGetMaxX(bounds)-paddingright, CGRectGetMinY(bounds)+BUTTON_PADDING_Y, paddingright,paddingtop);
    }
    UIImage *btnimage;
    if (IS_IPHONE_5) {
        btnimage = [UIImage imageNamed:@"ButtonDoneL.png"];
    } else {
        btnimage = [UIImage imageNamed:@"ButtonDoneR.png"];
    }
    self = [super initWithFrame:frame];
    if (self) {
        done = [UIButton buttonWithType:UIButtonTypeCustom];
        [done setFrame:CGRectMake(0,-7, frame.size.width, frame.size.height)];
        [done setBackgroundImage:btnimage forState:UIControlStateNormal];
        [done addTarget:self action:@selector(donebtn_clicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:done];

/*
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(donebtn_clicked)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"navbutton.png"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(frame.size.width*0.25,frame.size.height/4, frame.size.width*0.75,frame.size.height/2);
    [self addSubview:button];
*/
        finishedRecording = NO;
    }
    return self;
}
    

-(void)donebtn_clicked{
    if(!finishedRecording){
        if([mydelegate respondsToSelector:@selector(stopcapturingview)]){
            [mydelegate stopcapturingview];
            
        }
    }
    }

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
