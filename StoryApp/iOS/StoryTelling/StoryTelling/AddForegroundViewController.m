//
//  AddForegroundViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto LLC. All rights reserved.
//

#import "AddForegroundViewController.h"
#import "STCropForegroundViewController.h"
#import "CreateStoryRootViewController.h"

@interface AddForegroundViewController ()

@end

@implementation AddForegroundViewController


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
    if(info == NULL || [info count]<=0){
    }
    else{
        
        foregroundImages = [[NSMutableArray alloc]initWithArray:info];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        STCropForegroundViewController *cropForeground = [storyboard instantiateViewControllerWithIdentifier:@"cropForeground"];
        [cropForeground setForegroundimages :foregroundImages];
        [self.navigationController pushViewController:cropForeground animated:YES];

    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
