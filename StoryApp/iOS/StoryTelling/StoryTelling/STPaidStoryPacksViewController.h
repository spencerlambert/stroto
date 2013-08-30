//
//  STPaidStoryPacksViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STImage.h"

@interface STPaidStoryPacksViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (strong, nonatomic) IBOutlet UILabel *paidStoryPackName;
@property (strong, nonatomic) IBOutlet UIButton *paidButtonLabel;

@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;

@property (strong, nonatomic) NSDictionary *paidStoryPackDetailsJson;
@property (assign, nonatomic) int storyPackID;

@end
