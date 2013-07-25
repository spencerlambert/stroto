//
//  STEraseImageView.h
//  StoryTelling
//
//  Created by Aaswini on 18/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STEraseImageView : UIImageView{
    CGPoint lastPoint;
    BOOL mouseSwiped;
    
    
    
    
}
@property CGSize size;
@property CGPoint location;
@property UIImageView *maskView;
@property UIImage *originalImage;
@property int brush;
@property int flags;

- (void) doGrabCut;
- (void) initialize;

@end
