//
//  AddBackgroundViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "AddBackgroundViewController.h"
#import "CreateStoryRootViewController.h"
#import "STCropBackgroundViewController.h"

@interface AddBackgroundViewController ()

@end

@implementation AddBackgroundViewController
{
    NSMutableArray *selectedimages;
}
@synthesize backgroundImagesDelegate;
@synthesize delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    backgroundImagesDelegate = (AppDelegate *) [[UIApplication sharedApplication]delegate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (IBAction)fromCamraPackButtonClicked:(id)sender {
    @try
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        
        [self presentModalViewController:picker animated:YES];
    }
    @catch (NSException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Camera" message:@"Camera is not available  " delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    [self dismissViewControllerAnimated:YES completion:nil];
        if(info != NULL){
        backgroundImages = [[NSMutableArray alloc]initWithArray:info];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            STCropBackgroundViewController *cropBackground = [storyboard instantiateViewControllerWithIdentifier:@"cropBackground"];
            [cropBackground setBackgroundimages:backgroundImages];
            [self.navigationController pushViewController:cropBackground animated:YES];
            //[self presentViewController:cropBackground animated:YES completion:nil];
                    
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%d Images Selected", [backgroundImages count]] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        alert.tag=1;
//        [alert show];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Images Selected" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1){
        if(buttonIndex == 0){
            
                id object = nil;
                
                for (UIViewController *viewControl in self.navigationController.viewControllers)
                {
                    if(viewControl.view.tag==20)
                    {
                        object = viewControl;
                        [backgroundImagesDelegate.backgroundImagesArray addObjectsFromArray:backgroundImages];
                    }
                }
                [self.navigationController popToViewController:object animated:YES];
            

        }
    }

    }

#pragma -mark delegate method of UIImage picker
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSLog(@"Media Info: %@", info);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    UIImage *photoTaken = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
       
    NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
    
    [workingDictionary setObject:photoTaken forKey:@"UIImagePickerControllerThumbnailImage"];
    UIImage *img = [[UIImage alloc]initWithCGImage:photoTaken.CGImage scale:0 orientation:UIImageOrientationRight];
    
    [workingDictionary setObject:img forKey:@"UIImagePickerControllerOriginalImage"];
    //self.testimg.image = [workingDictionary objectForKey:@"UIImagePickerControllerOriginalImage"];
    //self.testimg.transform = CGAffineTransformMakeRotation(M_PI_2);
    [returnArray addObject:workingDictionary];
    
    if(returnArray != NULL){
    
		
    backgroundImages = [[NSMutableArray alloc]initWithArray:returnArray];
        
    [picker dismissViewControllerAnimated:YES completion:nil];
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        STCropBackgroundViewController *cropBackground = [storyboard instantiateViewControllerWithIdentifier:@"cropBackground"];
        [cropBackground setBackgroundimages:backgroundImages];
        cropBackground.isFromCamera = YES;
        [self.navigationController pushViewController:cropBackground animated:YES];
        
            }

}
- (void)viewDidUnload {
   
    [super viewDidUnload];
}
@end
