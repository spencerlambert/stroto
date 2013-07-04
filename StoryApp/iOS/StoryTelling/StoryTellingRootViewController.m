//
//  StoryTellingRootViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "StoryTellingRootViewController.h"
#import "STStoryDB.h"

@interface StoryTellingRootViewController ()

@end

@implementation StoryTellingRootViewController
@synthesize newstoryFlag;


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
    self.view.tag=100;

}

-(void)viewWillAppear:(BOOL)animated{
    newstoryFlag = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [newstoryFlag setIsNewStory:@"true"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createNewStory:(id)sender {
   STStoryDB *newStory = [[STStoryDB alloc] init];
    [newStory createStory];
    
}


@end
