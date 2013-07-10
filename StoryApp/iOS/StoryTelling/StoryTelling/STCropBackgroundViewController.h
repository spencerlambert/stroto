//
//  STCropBackgroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 10/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCropBackgroundViewController : UIViewController

@property NSMutableArray *backgroundimages;

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
@property (strong, nonatomic) IBOutlet UIView *backgroundimagesView;
@property (strong, nonatomic) IBOutlet UIScrollView *cropView;
@property (strong, nonatomic) IBOutlet UIImageView *cropbackgroundImage;
- (IBAction)done:(id)sender;

@end
