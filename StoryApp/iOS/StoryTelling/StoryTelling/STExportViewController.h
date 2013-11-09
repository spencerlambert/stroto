//
//  STExportViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 09/11/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STListStoryiPad.h"

@interface STExportViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *storyTitle;
@property (weak, nonatomic) IBOutlet UITextField *storySubTitle;
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
- (IBAction)toggleCheckBox:(UIButton *)sender;
- (IBAction)saveToGallery:(UIButton *)sender;

@end
