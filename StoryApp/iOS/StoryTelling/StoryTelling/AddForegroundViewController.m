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

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@interface AddForegroundViewController ()

@end

@implementation AddForegroundViewController
{
    NSMutableArray *selectedImages;
}

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
    
    [super viewDidUnload];
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

- (IBAction)fromCameraButtonClicked:(UIButton *)sender {
    @try
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
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

#pragma -mark delegate method of UIImage picker
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    NSLog(@"Media Info: %@", info);
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    UIImage *sourceImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
    
    CGFloat targetWidth = sourceImage.size.width;
    CGFloat targetHeight = sourceImage.size.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft || sourceImage.imageOrientation == UIImageOrientationRight) {
        targetWidth = sourceImage.size.height;
        targetHeight = sourceImage.size.width;
    }
    
	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
	} else {
		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
	}
    
	if (sourceImage.imageOrientation == UIImageOrientationLeft) {
		CGContextRotateCTM (bitmap, DEGREES_TO_RADIANS(90));
		CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
	} else if (sourceImage.imageOrientation == UIImageOrientationRight) {
		CGContextRotateCTM (bitmap, DEGREES_TO_RADIANS(-90));
		CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
	} else if (sourceImage.imageOrientation == UIImageOrientationUp) {
		// NOTHING
	} else if (sourceImage.imageOrientation == UIImageOrientationDown) {
		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
		CGContextRotateCTM (bitmap, DEGREES_TO_RADIANS(-180.));
	}
    
	CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
    
	CGContextRelease(bitmap);
	CGImageRelease(ref);
    [workingDictionary setObject:newImage forKey:@"UIImagePickerControllerOriginalImage"];
    [returnArray addObject:workingDictionary];
    
    if(returnArray != NULL){
        
        foregroundImages = [[NSMutableArray alloc]initWithArray:returnArray];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        STCropForegroundViewController *cropForeground = [storyboard instantiateViewControllerWithIdentifier:@"cropForeground"];
        [cropForeground setForegroundimages:foregroundImages];
        cropForeground.isFromCamera = YES;
        [self.navigationController pushViewController:cropForeground animated:YES];
        
    }
    
}


@end
