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
    [btn2 addTarget:self action:@selector(handleFollowTangentUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn2 addTarget:self action:@selector(handleFollowTangentDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn2];
    
    UIButton *btn3=[UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame= CGRectMake(0, btnSize.height*2, btnSize.width, btnSize.height);
    [btn3 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonPerspectiveGround.png"] forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(handlePerspectiveGroundUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn3 addTarget:self action:@selector(handlePerspectiveGroundDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn3];
    
    UIButton *btn4=[UIButton buttonWithType:UIButtonTypeCustom];
    btn4.frame= CGRectMake(0, btnSize.height*3, btnSize.width, btnSize.height);
    [btn4 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonPerspectiveSky.png"] forState:UIControlStateNormal];
    [btn4 addTarget:self action:@selector(handlePerspectiveSkyUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn4 addTarget:self action:@selector(handlePerspectiveSkyDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn4];
    
    UIButton *btn5=[UIButton buttonWithType:UIButtonTypeCustom];
    btn5.frame= CGRectMake(0, btnSize.height*4, btnSize.width, btnSize.height);
    [btn5 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonRotateRight.png"] forState:UIControlStateNormal];
    [btn5 addTarget:self action:@selector(handleRotateLeftUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn5 addTarget:self action:@selector(handleRotateLeftDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn5];
    
    UIButton *btn6=[UIButton buttonWithType:UIButtonTypeCustom];
    btn6.frame= CGRectMake(0, btnSize.height*5, btnSize.width, btnSize.height);
    [btn6 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonRotateLeft.png"] forState:UIControlStateNormal];
    [btn6 addTarget:self action:@selector(handleRotateRightUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn6 addTarget:self action:@selector(handleRotateRightDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn6];
    
    UIButton *btn7=[UIButton buttonWithType:UIButtonTypeCustom];
    btn7.frame= CGRectMake(0, btnSize.height*6, btnSize.width, btnSize.height);
    [btn7 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonZoomLarger.png"] forState:UIControlStateNormal];
    [btn7 addTarget:self action:@selector(handleZoomLargerUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn7 addTarget:self action:@selector(handleZoomLargerDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn7];
    
    UIButton *btn8=[UIButton buttonWithType:UIButtonTypeCustom];
    btn8.frame= CGRectMake(0, btnSize.height*7, btnSize.width, btnSize.height);
    [btn8 setBackgroundImage:[UIImage imageNamed:@"ModifierButtonZoomSmaller.png"] forState:UIControlStateNormal];
    [btn8 addTarget:self action:@selector(handleZoomSmallerUp:) forControlEvents:UIControlEventTouchUpInside];
    [btn8 addTarget:self action:@selector(handleZoomSmallerDown:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:btn8];
    
    
}

-(void)handleFlip: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
      if([modifierDelegate respondsToSelector:@selector(handleFlip)])
          [modifierDelegate handleFlip];
    }
}

-(void)handleFollowTangentUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleFollowTangent:)])
            [modifierDelegate handleFollowTangent:NO];
    }
}

-(void)handlePerspectiveGroundUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handlePerspectiveGround:)])
            [modifierDelegate handlePerspectiveGround:NO];
    }
}

-(void)handlePerspectiveSkyUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if (modifierDelegate != nil) {
        if([modifierDelegate respondsToSelector:@selector(handlePerspectiveSky:)])
            [modifierDelegate handlePerspectiveSky:NO];
    }
}

-(void)handleRotateLeftUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleRotateLeft:)])
            [modifierDelegate handleRotateLeft:NO];
    }
}

-(void)handleRotateRightUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleRotateRight:)])
            [modifierDelegate handleRotateRight:NO];
    }
}

-(void)handleZoomLargerUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleZoomLarger:)])
            [modifierDelegate handleZoomLarger:NO];
    }
}

-(void)handleZoomSmallerUp: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleZoomSmaller:)])
            [modifierDelegate handleZoomSmaller:NO];
    }
}

-(void)handleFollowTangentDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleFollowTangent:)])
            [modifierDelegate handleFollowTangent:YES];
    }
}

-(void)handlePerspectiveGroundDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handlePerspectiveGround:)])
            [modifierDelegate handlePerspectiveGround:YES];
    }
}

-(void)handlePerspectiveSkyDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if (modifierDelegate != nil) {
        if([modifierDelegate respondsToSelector:@selector(handlePerspectiveSky:)])
            [modifierDelegate handlePerspectiveSky:YES];
    }
}

-(void)handleRotateLeftDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleRotateLeft:)])
            [modifierDelegate handleRotateLeft:YES];
    }
}


-(void)handleRotateRightDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleRotateRight:)])
            [modifierDelegate handleRotateRight:YES];
    }
}

-(void)handleZoomLargerDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleZoomLarger:)])
            [modifierDelegate handleZoomLarger:YES];
    }
}

-(void)handleZoomSmallerDown: (UIButton *)button{
    NSLog(@"%s",__FUNCTION__);
    if(modifierDelegate != nil){
        if([modifierDelegate respondsToSelector:@selector(handleZoomSmaller:)])
            [modifierDelegate handleZoomSmaller:YES];
    }
}

-(void)toggle{
    NSLog(@"%s",__FUNCTION__);
    if(self.frame.origin.x == 0){
        [self setFrame:CGRectMake(-320, self.frame.origin.y,320, self.frame.size.height)];
    }else{
        [self setFrame:CGRectMake(0, self.frame.origin.y, 320, self.frame.size.height)];
    }
}





@end
