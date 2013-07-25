//
//  STForegroundEraseViewController.m
//  StoryTelling
//
//  Created by Aaswini on 23/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STForegroundEraseViewController.h"
#import "STTestViewController.h"

@interface STForegroundEraseViewController ()

@end

@implementation STForegroundEraseViewController

@synthesize mask;

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
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [self.imageview setImage:self.image];
    [self.imageview initialize];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [self.imageview doGrabCut];
    [(STTestViewController*)segue.destinationViewController setMyimage:self.imageview.image];
}

- (IBAction)done:(id)sender {
    [self.navigationController  popViewControllerAnimated:YES];
}

- (IBAction)fgMask:(id)sender{
    [self.imageview setFlags:1];
//    self.imageview.flags = 1;
}

- (IBAction)bgMask:(id)sender{
    [self.imageview setFlags:2];
//    self.imageview.flags = 2;
}

@end
