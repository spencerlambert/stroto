//
//  STExportViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 09/11/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STExportViewController.h"

@interface STExportViewController ()

@end

@implementation STExportViewController

@synthesize checkBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    checkBox.selected = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleCheckBox:(UIButton *)sender {
    checkBox.selected = !checkBox.selected; // toggle the selection
    
    if (checkBox.selected)
    {
        [checkBox setImage:[UIImage imageNamed:@"uicheckbox_checked.png"]forState:UIControlStateSelected];
    }
    else
    {
        [checkBox setImage:[UIImage imageNamed:@"uicheckbox_unchecked.png"]forState:UIControlStateNormal];
    }
}

- (IBAction)saveToGallery:(UIButton *)sender {
}
@end
