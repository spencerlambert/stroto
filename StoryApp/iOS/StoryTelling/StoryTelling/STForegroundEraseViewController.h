//
//  STForegroundEraseViewController.h
//  StoryTelling
//
//  Created by Aaswini on 23/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STEraseImageView.h"

@interface STForegroundEraseViewController : UIViewController

@property UIImage *image;
@property IBOutlet STEraseImageView *imageview;
@property UIImage *mask;

- (IBAction)done:(id)sender;
- (IBAction)bgMask:(id)sender;
- (IBAction)fgMask:(id)sender;

@end
