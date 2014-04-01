//
//  STModifierToolbar.h
//  StoryTelling
//
//  Created by Aaswini on 10/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STModifierToolbarDelegate <NSObject>

@optional

-(void)handleFlip;
-(void)handleFollowTangent:(BOOL)value;
-(void)handlePerspectiveGround:(BOOL)value;
-(void)handlePerspectiveSky:(BOOL)value;
-(void)handleRotateLeft:(BOOL)value;
-(void)handleRotateRight:(BOOL)value;
-(void)handleZoomLarger:(BOOL)value;
-(void)handleZoomSmaller:(BOOL)value;

@end

@interface STModifierToolbar : UIView

@property (nonatomic,assign)id<STModifierToolbarDelegate> modifierDelegate;

- (id)initWithFrame:(CGRect)frame withBtnSize:(CGSize)size;
- (void)toggle;


@end
