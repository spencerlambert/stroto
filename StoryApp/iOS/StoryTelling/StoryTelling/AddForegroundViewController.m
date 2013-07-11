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

@synthesize delegate;
@synthesize foregroundImagesDelegate;

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
     foregroundImagesDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
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
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        STCropForegroundViewController *cropForeground = [storyboard instantiateViewControllerWithIdentifier:@"cropForeground"];
        [cropForeground setForegroundimages :foregroundImages];
        [self.navigationController pushViewController:cropForeground animated:YES];
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%d Images Selected", [foregroundImages count]] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        alert.tag = 2;
//        [alert show];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Images Selected" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 2){
        if(buttonIndex == 0){
            
            id object = nil;
            
            for (UIViewController *viewControl in self.navigationController.viewControllers)
            {
                NSLog(@"The tag value is:%d",viewControl.view.tag);
                if(viewControl.view.tag==20)
                {
                    object = viewControl;
                    [foregroundImagesDelegate.foregroundImagesArray addObjectsFromArray:foregroundImages];
                }
            }
            [self.navigationController popToViewController:object animated:YES];
            
            
        }
    }
}

@end
