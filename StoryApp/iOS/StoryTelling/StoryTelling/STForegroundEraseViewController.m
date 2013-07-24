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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [(STTestViewController*)segue.destinationViewController setMyimage:self.image];
}

- (IBAction)done:(id)sender {
//    UIImage *image = [UIImage imageNamed:@"AddButton"];
//    id<ImageProcessingProtocol> imageProcessor = [[ImageProcessingImpl alloc] init];
//    UIImage * processedImage = [imageProcessor processImage:image];
//    UIImageView *view = [[UIImageView alloc] initWithImage:processedImage];
//    [self.view addSubview:view];
    [self.navigationController  popViewControllerAnimated:YES];
}
@end
