//
//  STSelectImagesFromStoryViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STSelectImagesFromStoryViewController.h"

@interface STSelectImagesFromStoryViewController ()

@end

@implementation STSelectImagesFromStoryViewController
@synthesize dbLocation;
@synthesize storyNameLabel;
@synthesize backgroundImagesView;
@synthesize foregroundImagesView;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStoryNameLabel:nil];
    [self setBackgroundImagesView:nil];
    [self setForegroundImagesView:nil];
    [super viewDidUnload];
}
@end
