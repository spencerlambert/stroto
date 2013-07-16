//
//  STCropForegroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 10/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCropForegroundViewController : UIViewController

@property NSMutableArray *foregroundimages;
@property NSArray *sizePicker;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
@property (strong, nonatomic) IBOutlet UIView *foregroundimagesView;
@property (strong, nonatomic) IBOutlet UIScrollView *cropView;
@property (strong, nonatomic) IBOutlet UIImageView *cropforegroundImage;
@property (weak, nonatomic) IBOutlet UIPickerView *sizePickerOutlet;
- (IBAction)done:(id)sender;
@end