//
//  STFGImageView.h
//  StoryTelling
//
//  Created by Aaswini on 12/12/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFGImageView : UIImageView

@property BOOL isEdited;
@property BOOL isRotated;
@property BOOL isScaled;

@property NSMutableArray *rotation;
@property NSMutableArray *scale;


@end
