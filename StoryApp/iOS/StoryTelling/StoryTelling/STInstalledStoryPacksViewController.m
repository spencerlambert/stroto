//
//  STInstalledStoryPacksViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 12/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STInstalledStoryPacksViewController.h"
#import "CreateStoryRootViewController.h"

@interface STInstalledStoryPacksViewController ()

@end

@implementation STInstalledStoryPacksViewController

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
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setTitle:@"Select Images To Use"];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed) ];
    [self.navigationItem setRightBarButtonItem:doneButton];
}
-(void)doneButtonPressed
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
