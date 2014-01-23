//
//  STPlayerToolbar.h
//  StoryTelling
//
//  Created by Aaswini on 23/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STPlayerToolbarDelegate <NSObject>

@optional

-(void) playBtnClicked;
-(void) pauseBtnClicked;

@end

@interface STPlayerToolbar : UIView{
    
    UIView *toolbar;
   
    
}

@property (nonatomic, assign) id<STPlayerToolbarDelegate> mydelegate;

@property (nonatomic,retain)  UISlider *slider;
@property (nonatomic,retain)  UIButton *playBtn;

-(void) initialize;

@end
