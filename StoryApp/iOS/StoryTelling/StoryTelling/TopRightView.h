//
//  TopRightView.h
//  StoryTelling
//
//  Created by Aaswini on 22/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopRightViewDelegate <NSObject>

@optional

-(void)doneBtnClicked;

@end

@interface TopRightView : UIView{
    
    BOOL finishedRecording;
    
}

@property (nonatomic, assign) UIButton *done;
@property (nonatomic, assign) id<TopRightViewDelegate> mydelegate;

@end
