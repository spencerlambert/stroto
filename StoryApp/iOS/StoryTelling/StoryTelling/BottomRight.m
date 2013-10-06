//
//  BottomRight.m
//  StoryTelling
//
//  Created by Aaswini on 22/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "BottomRight.h"


#define THUMB_HEIGHT 45
#define THUMB_WIDTH 45
#define THUMB_V_PADDING 15
#define THUMB_H_PADDING 15
#define STATUS_BAR_HEIGHT 0

#define BUTTON_PADDING_X 20
#define BUTTON_PADDING_Y 20
#define BUTTON_HEIGHT 50
#define BUTTON_WIDTH 55

@implementation BottomRight

@synthesize startrecording;
@synthesize mydelegate;

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
        startrecording = [UIButton buttonWithType:UIButtonTypeCustom];
        [startrecording setFrame:CGRectMake(0, -7, frame.size.width, frame.size.height)];
        [startrecording setBackgroundImage:btnimage forState:UIControlStateNormal];
        [startrecording addTarget:self action:@selector(startrecordingbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:startrecording];
        isRecording = NO;
        finishedRecording = NO;
        startedRecording = NO;
    }
    return self;
}

- (void) startrecordingbtn_clicked{
    if (!startedRecording){
        if([mydelegate respondsToSelector:@selector(startcapturingview)]){
            UIImage *btnimage = [UIImage imageNamed:@"RecordOn.png"];
            [startrecording setBackgroundImage:btnimage forState:UIControlStateNormal];
            startedRecording  =YES;
            isRecording = YES;
            [mydelegate startcapturingview];
        }
    }else{
        if (isRecording){
            if([mydelegate respondsToSelector:@selector(pausecapturingview)]){
                UIImage *btnimage = [UIImage imageNamed:@"RecordOff.png"];
                [startrecording setBackgroundImage:btnimage forState:UIControlStateNormal];
                isRecording = NO;
                [mydelegate pausecapturingview];
            }
        }
        else{
            if([mydelegate respondsToSelector:@selector(resumecapturingview)]){
                UIImage *btnimage = [UIImage imageNamed:@"RecordOn.png"];
                [startrecording setBackgroundImage:btnimage forState:UIControlStateNormal];
                isRecording = YES;
                [mydelegate resumecapturingview];
            }
        }
    }
//    if(!isRecording && !finishedRecording){
//        if([mydelegate respondsToSelector:@selector(startcapturingview)]){
//            UIImage *btnimage = [UIImage imageNamed:@"RecordOn.png"];
//            [startrecording setBackgroundImage:btnimage forState:UIControlStateNormal];
//            isRecording = YES;
//            [mydelegate startcapturingview];
//        }
//    }
//    else if (isRecording && !finishedRecording){
//        if([mydelegate respondsToSelector:@selector(stopcapturingview)]){
//            
//            //Quick change by Spence to make record/pause option.
//            // -- Just wanted to get a feel for the interface.  Sorry if I'm messing too much :)
//            //UIImage *btnimage = [UIImage imageNamed:@"VideoPlayButton.png"];
//            UIImage *btnimage = [UIImage imageNamed:@"RecordOff.png"];
//            [startrecording setBackgroundImage:btnimage forState:UIControlStateNormal];
//            isRecording = NO;
//            //ToDo: Implement Pause
//            //finishedRecording = YES;
//            [mydelegate stopcapturingview];
//        }
//    }
//    else if (isRecording && finishedRecording){
//        if([mydelegate respondsToSelector:@selector(playcapturedvideo)]){
//            [mydelegate playcapturedvideo];
//        }
//    }
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
