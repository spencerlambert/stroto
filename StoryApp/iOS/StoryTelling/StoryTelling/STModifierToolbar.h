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
-(void)handleFollowTangent;
-(void)handlePerspectiveGround;
-(void)handlePerspectiveSky;
-(void)handleRotateLeft;
-(void)handleRotateRight;
-(void)handleZoomLarger;
-(void)handleZoomSmaller;

@end

@interface STModifierToolbar : UIView

@property (nonatomic,assign)id<STModifierToolbarDelegate> modifierDelegate;

- (id)initWithFrame:(CGRect)frame withBtnSize:(CGSize)size;
- (void)toggle;


@end
