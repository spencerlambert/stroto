//
//  SlideLeftView.h
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideLeftViewDelegate;

@interface SlideLeftView : UIView{
    BOOL thumbViewShowing;
    UIButton *addbtn_slideupview;
    UIButton *addbtn_slidedownview;
}
@property (nonatomic, assign) id<SlideLeftViewDelegate> mydelegate;
@property (nonatomic, assign) UIButton *startrecording;
@property (nonatomic, assign) UIButton *stoprecording;
@property (nonatomic, assign) UIButton *playVideo;
- (void)toggleThumbView;
@end

@protocol SlideLeftViewDelegate <NSObject>

@optional
- (void)startcapturingview;
- (void)stopcapturingview;
- (void)playcapturedvideo;
@end