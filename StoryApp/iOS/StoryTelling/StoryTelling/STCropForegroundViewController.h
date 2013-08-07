//
//  STCropForegroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 10/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CvGrabCutController.hh"

@interface STCropForegroundViewController : UIViewController<UIScrollViewDelegate>{
    
    BOOL image_changed;
    BOOL edit_fg;
    
    float scale_x;
    float scale_y;
    
    CvGrabCutController* grabCutController;

    int selectedView;
    
    BOOL isEdited;
    BOOL isEditing;
    UIImage *lastEdit;
    NSMutableArray *undoImages;
}

- (IBAction)editForegroundSegment:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *cropMainView;
@property (weak, nonatomic) IBOutlet UIView *eraseMainView;
@property (weak, nonatomic) IBOutlet UIView *sizeMainView;

@property NSMutableArray *foregroundimages;
@property NSMutableArray *foregroundEraseImages;
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer;
@property (strong, nonatomic) IBOutlet UIView *foregroundimagesView;
@property (strong, nonatomic) IBOutlet UIScrollView *cropView;
@property (strong, nonatomic) IBOutlet UIImageView *cropforegroundImage;

- (IBAction)pickBG:(id)sender;
- (IBAction)pickFG:(id)sender;
- (IBAction)applyGrabcut:(id)sender;
- (IBAction)undoGrabcut:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *grabcutView;
@property (nonatomic, retain) CvGrabCutController *grabCutController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UIButton *bgBtn;
@property (weak, nonatomic) IBOutlet UIButton *fgBtn;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;
@property (weak, nonatomic) IBOutlet UIButton *undoBtn;




- (IBAction)sliderChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIImageView *sizeView;

- (IBAction)done:(id)sender;

@end
