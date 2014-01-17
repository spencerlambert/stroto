//
//  STFGImageView.m
//  StoryTelling
//
//  Created by Aaswini on 12/12/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STFGImageView.h"

@implementation STFGImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.rotation = [[NSMutableArray alloc]init];
        self.scale = [[NSMutableArray alloc]init];
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

@end
