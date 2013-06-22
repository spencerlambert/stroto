//
//  BottomRight.h
//  StoryTelling
//
//  Created by Aaswini on 22/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BottomRightViewDelegate <NSObject>

@optional
- (void)startcapturingview;
- (void)stopcapturingview;
- (void)playcapturedvideo;
@end

@interface BottomRight : UIView{
    BOOL isRecording;
    BOOL finishedRecording;
}
@property (nonatomic, assign) id<BottomRightViewDelegate> mydelegate;
@property (nonatomic, assign) UIButton *startrecording;

@end
