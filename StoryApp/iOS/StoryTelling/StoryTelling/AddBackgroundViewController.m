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

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)


@interface AddBackgroundViewController ()

@end

@implementation AddBackgroundViewController
{
    NSMutableArray *selectedimages;
}


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

- (IBAction)fromCamraPackButtonClicked:(id)sender {
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
    }else{
        backgroundImages = [[NSMutableArray alloc]initWithArray:info];
        STCropBackgroundViewController *cropBackground = [[STCropBackgroundViewController alloc] init];
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"%@",deviceType);
        if([deviceType hasPrefix:@"iPad"]){
            cropBackground = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"cropBackground"];
        }else{
            
            cropBackground = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"cropBackground"];
        }
            [cropBackground setBackgroundimages:backgroundImages];
            [self.navigationController pushViewController:cropBackground animated:YES];
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

    //[workingDictionary setObject:photoTaken forKey:@"UIImagePickerControllerThumbnailImage"];
    //UIImage *sourceImage = [[UIImage alloc]initWithCGImage:photoTaken.CGImage];
    
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
    [workingDictionary setObject:newImage forKey:@"UIImagePickerControllerThumbnailImage"];
    [workingDictionary setObject:@"thumb.png" forKey:@"UIImagePickerControllerReferenceURL"];
    //self.testimg.image = [workingDictionary objectForKey:@"UIImagePickerControllerOriginalImage"];
    //self.testimg.transform = CGAffineTransformMakeRotation(M_PI_2);
    [returnArray addObject:workingDictionary];
    if(returnArray != NULL){
		
    backgroundImages = [[NSMutableArray alloc]initWithArray:returnArray];
        
    [picker dismissViewControllerAnimated:YES completion:nil];
        STCropBackgroundViewController *cropBackground = [[STCropBackgroundViewController alloc] init];
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"%@",deviceType);
        if([deviceType hasPrefix:@"iPad"]){
            cropBackground = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil]instantiateViewControllerWithIdentifier:@"cropBackground"];
        }else{
            cropBackground = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]instantiateViewControllerWithIdentifier:@"cropBackground"];
        }
        [cropBackground setBackgroundimages:backgroundImages];
        cropBackground.isFromCamera = YES;
        [self.navigationController pushViewController:cropBackground animated:YES];
        
   }

}

- (void)viewDidUnload {
   
    [super viewDidUnload];
}
@end
