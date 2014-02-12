//
//  STModifierToolbar.m
//  StoryTelling
//
//  Created by Aaswini on 10/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STModifierToolbar.h"

@implementation STModifierToolbar{
    
    CGSize btnSize;
}
@synthesize modifierDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        btnSize = CGSizeMake(40, 40);
        [self initialize];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame withBtnSize:(CGSize)size{
    btnSize = size;
    self = [super initWithFrame:frame];
    if(self){
        [self initialize];
    }
    return self;
}

-(void)initialize{
    
    UIButton *btn1=[UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame= CGRectMake(0, 0, btnSize.width, btnSize.height);
    [btn1 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonFlip.png"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(handleFlip:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn1];
    
    UIButton *btn2=[UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame= CGRectMake(0, btnSize.height, btnSize.width, btnSize.height);
    [btn2 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonFollowTangent.png"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(handleFollowTangent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn2];
    
    UIButton *btn3=[UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame= CGRectMake(0, btnSize.height*2, btnSize.width, btnSize.height);
    [btn3 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonPerspectiveGround.png"] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(handlePerspectiveGround:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn3];
    
    UIButton *btn4=[UIButton buttonWithType:UIButtonTypeCustom];
    btn4.frame= CGRectMake(0, btnSize.height*3, btnSize.width, btnSize.height);
    [btn4 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonPerspectiveSky.png"] forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(handlePerspectiveSky:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn4];
    
    UIButton *btn5=[UIButton buttonWithType:UIButtonTypeCustom];
    btn5.frame= CGRectMake(0, btnSize.height*4, btnSize.width, btnSize.height);
    [btn5 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonRotateLeft.png"] forState:UIControlStateNormal];
    [btn5 addTarget:self action:@selector(handleRotateLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn5];
    
    UIButton *btn6=[UIButton buttonWithType:UIButtonTypeCustom];
    btn6.frame= CGRectMake(0, btnSize.height*5, btnSize.width, btnSize.height);
    [btn6 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonRotateRight.png"] forState:UIControlStateNormal];
    [btn6 addTarget:self action:@selector(handleRotateRight:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn6];
    
    UIButton *btn7=[UIButton buttonWithType:UIButtonTypeCustom];
    btn7.frame= CGRectMake(0, btnSize.height*6, btnSize.width, btnSize.height);
    [btn7 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonZoomLarger.png"] forState:UIControlStateNormal];
    [btn7 addTarget:self action:@selector(handleZoomLarger:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn7];
    
    UIButton *btn8=[UIButton buttonWithType:UIButtonTypeCustom];
    btn8.frame= CGRectMake(0, btnSize.height*7, btnSize.width, btnSize.height);
    [btn8 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonZoomSmaller.png"] forState:UIControlStateNormal];
    [btn8 addTarget:self action:@selector(handleZoomSmaller:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn8];
    
    
}

-(void)handleFlip: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
      if([modifierDelegate respondsToSelector:@selector(handleFlip)])
          [modifierDelegate handleFlip];
    }
    }

-(void)handleFollowTangent: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleFollowTangent)])
            [modifierDelegate handleFollowTangent];
    }
}

-(void)handlePerspectiveGround: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handlePerspectiveGround)])
            [modifierDelegate handlePerspectiveGround];
    }
}

-(void)handlePerspectiveSky: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if (modifierDelegate != nil) {
        if([modifierDelegate respondsToSelector:@selector(handlePerspectiveSky)])
            [modifierDelegate handlePerspectiveSky];
    }
}

-(void)handleRotateLeft: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleRotateLeft)])
            [modifierDelegate handleRotateLeft];
    }
}

-(void)handleRotateRight: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleRotateRight)])
            [modifierDelegate handleRotateRight];
    }
}

-(void)handleZoomLarger: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleZoomLarger)])
            [modifierDelegate handleZoomLarger];
    }
}

-(void)handleZoomSmaller: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleZoomSmaller)])
            [modifierDelegate handleZoomSmaller];
    }
}





@end
