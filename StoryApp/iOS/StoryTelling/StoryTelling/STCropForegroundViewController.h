//
//  STCropForegroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 10/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCropForegroundViewController : UIViewController<UIScrollViewDelegate>

- (IBAction)sliderChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property NSMutableArray *foregroundimages;

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
@property (strong, nonatomic) IBOutlet UIView *foregroundimagesView;
@property (strong, nonatomic) IBOutlet UIScrollView *cropView;
@property (strong, nonatomic) IBOutlet UIImageView *cropforegroundImage;

- (IBAction)done:(id)sender;
@end
