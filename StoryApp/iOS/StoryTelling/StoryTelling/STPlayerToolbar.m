//
//  STPlayerToolbar.m
//  StoryTelling
//
//  Created by Aaswini on 23/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STPlayerToolbar.h"
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define THUMB_HEIGHT (IS_IPAD ? 95 : 45)
#define THUMB_WIDTH (IS_IPAD ? 95 : 45)
#define THUMB_V_PADDING 15
#define THUMB_H_PADDING 15
#define STATUS_BAR_HEIGHT 0
#define IPHONE_5_ADDITIONAL 44


#define BUTTON_PADDING_X 20
#define BUTTON_PADDING_Y 20
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 55

@implementation STPlayerToolbar

@synthesize slider, mydelegate, playBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                CGRect bounds = [[UIScreen mainScreen] bounds];
        float paddingtop = THUMB_HEIGHT + THUMB_V_PADDING * 2;
        float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
        if (IS_IPHONE_5) {
            thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING + IPHONE_5_ADDITIONAL * 2 ;
        }

        CGRect frame = CGRectMake(0, CGRectGetMaxY(bounds)-thumbHeight, bounds.size.width ,paddingtop);
        [self setFrame:frame];
        playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [playBtn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [playBtn addTarget:self action:@selector(playbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playBtn];
        
        slider = [[UISlider alloc]initWithFrame:CGRectMake(10,0,bounds.size.width-20,0)];
        slider.continuous = YES;
        
        [self addSubview:slider];
        [self initialize];

    }
    return self;
}

-(void)initialize{
    
   
    
    // Initialization code
   
    //        [playBtn setBackgroundImage:btnimage forState:UIControlStateNormal];
    [playBtn setTitle:@"Pause" forState:UIControlStateNormal];
    
    
}

-(void)playbtn_clicked{
    
    if([[playBtn titleLabel].text  isEqual: @"Play"]){
        [playBtn setTitle:@"Pause" forState:UIControlStateNormal];
        [mydelegate playBtnClicked];
    }else{
        [playBtn setTitle:@"Play" forState:UIControlStateNormal];
        [mydelegate pauseBtnClicked];
    }
}

@end
