//
//  BottomLeft.h
//  StoryTelling
//
//  Created by Aaswini on 21/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomLeftViewDelegate <NSObject>

@optional
- (void)startplayingview;
- (void)pauseplayingview;
- (void)resumeplayingview;
- (void)playBtnClicked;

@end

@interface BottomLeft : UIView{
    BOOL isPlaying;
    BOOL finishedPlaying;
    BOOL startedPlaying;
}

@property (nonatomic, assign) id<BottomLeftViewDelegate> mydelegate;
@property (nonatomic, assign) UIButton *startplaying;


@end
