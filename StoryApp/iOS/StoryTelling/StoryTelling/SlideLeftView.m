//
//  SlideLeftView.m
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "SlideLeftView.h"

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define STATUS_BAR_HEIGHT 20

#define BUTTON_PADDING_X 15
#define BUTTON_PADDING_Y 30
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 50

@interface SlideLeftView (ButtonHandlers)
- (void) addbtn_slideupview_clicked;
- (void) startrecordingbtn_clicked;
- (void) stoprecordingbtn_clicked;
- (void) playrecordedvideo;
- (void) addbtn_slidedownview_clicked;
@end

@implementation SlideLeftView

@synthesize mydelegate;
@synthesize startrecording;
@synthesize playVideo;
@synthesize stoprecording;

- (id)initWithFrame:(CGRect)frame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float paddingtop = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    float paddingright = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    float paddingbottom = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    frame = CGRectMake(CGRectGetMaxX(bounds)-paddingright, CGRectGetMinY(bounds) + paddingtop, paddingright, CGRectGetMaxY(bounds) - paddingtop - paddingbottom - STATUS_BAR_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor yellowColor]];
        [self setOpaque:NO];
        [self setAlpha:0.75];
    }
    
    [self initbuttons];
    [self addSubview:addbtn_slideupview];
    [self addSubview:startrecording];
    [self addSubview:stoprecording];
    [self addSubview:playVideo];
    [self addSubview:addbtn_slidedownview];
    
    return self;
}

- (void) initbuttons{
    
    //SlideUpView Image Add Button
    UIImage *btnimage = [UIImage imageNamed:@"AddButton.png"];
    addbtn_slideupview = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(BUTTON_PADDING_X, BUTTON_PADDING_Y - 20, 50, 50);
    [addbtn_slideupview setFrame:frame];
    [addbtn_slideupview setImage:btnimage forState:UIControlStateNormal];
    [addbtn_slideupview addTarget:self action:@selector(addbtn_slideupview_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Record Start Button
    btnimage = [UIImage imageNamed:@"StartRecordingButton.png"];
    startrecording = [UIButton buttonWithType:UIButtonTypeCustom];
    frame = CGRectMake(BUTTON_PADDING_X, frame.origin.y + 50 + BUTTON_PADDING_Y, 50, 50);
    [startrecording setFrame:frame];
    [startrecording setImage:btnimage forState:UIControlStateNormal];
    [startrecording addTarget:self action:@selector(startrecordingbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Record Stop Button
    btnimage = [UIImage imageNamed:@"RecordStop.png"];
    stoprecording = [UIButton buttonWithType:UIButtonTypeCustom];
    frame = CGRectMake(BUTTON_PADDING_X, frame.origin.y + 50 + BUTTON_PADDING_Y, 50, 50);
    [stoprecording setFrame:frame];
    [stoprecording setImage:btnimage forState:UIControlStateNormal];
    stoprecording.enabled = NO;
    [stoprecording addTarget:self action:@selector(stoprecordingbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    //Recorded Video Play Button
    btnimage = [UIImage imageNamed:@"VideoPlayButton.png"];
    playVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    frame = CGRectMake(BUTTON_PADDING_X, frame.origin.y + 50 + BUTTON_PADDING_Y, 50, 50);
    [playVideo setFrame:frame];
    [playVideo setImage:btnimage forState:UIControlStateNormal];
    playVideo.enabled = NO;
    [playVideo addTarget:self action:@selector(playrecordedvideo) forControlEvents:UIControlEventTouchUpInside];
    
    //SlideDownView Image Add Button
    btnimage = [UIImage imageNamed:@"AddButton.png"];
    addbtn_slidedownview = [UIButton buttonWithType:UIButtonTypeCustom];
    frame = CGRectMake(BUTTON_PADDING_X, frame.origin.y + 50 + BUTTON_PADDING_Y, 50, 50);
    [addbtn_slidedownview setFrame:frame];
    [addbtn_slidedownview setImage:btnimage forState:UIControlStateNormal];
    [addbtn_slidedownview addTarget:self action:@selector(addbtn_slidedownview_clicked) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)toggleThumbView {
    CGRect frame = [self frame];
    if (thumbViewShowing) {
        frame.origin.x -= frame.size.width;
    } else {
        frame.origin.x += frame.size.width;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = !thumbViewShowing;
}


- (void) addbtn_slideupview_clicked{
    NSLog(@"1");
}

- (void) startrecordingbtn_clicked{
    if([mydelegate respondsToSelector:@selector(startcapturingview)]){
        [mydelegate startcapturingview];
    }
}

- (void) stoprecordingbtn_clicked{
    if([mydelegate respondsToSelector:@selector(stopcapturingview)]){
        [mydelegate stopcapturingview];
    }
}

- (void) playrecordedvideo{
    if([mydelegate respondsToSelector:@selector(playcapturedvideo)]){
        [mydelegate playcapturedvideo];
    }
}

- (void) addbtn_slidedownview_clicked{
    NSLog(@"4");
}

@end
