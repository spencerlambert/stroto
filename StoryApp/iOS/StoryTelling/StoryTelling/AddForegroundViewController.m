//
//  AddForegroundViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "AddForegroundViewController.h"

@interface AddForegroundViewController ()

@end

@implementation AddForegroundViewController

@synthesize delegate;

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

- (IBAction)fromGalleryButtonClicked:(id)sender {
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName: nil bundle: nil];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    [self presentViewController:elcPicker animated:YES completion:nil];
}

- (IBAction)fromStoryPackButtonClicked:(id)sender {
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(info != NULL){
        foregroundImages = [[NSMutableArray alloc]initWithArray:info];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%d Images Selected", [foregroundImages count]] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
        [delegate setforegroundimages:foregroundImages];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Images Selected" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

@end