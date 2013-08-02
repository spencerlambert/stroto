//
//  AddBackgroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "AppDelegate.h"

@interface AddBackgroundViewController : UIViewController<ELCImagePickerControllerDelegate,UIImagePickerControllerDelegate>{
    NSMutableArray *backgroundImages;
}

- (IBAction)fromGalleryButtonClicked:(id)sender;
- (IBAction)fromStoryPackButtonClicked:(id)sender;
- (IBAction)fromCamraPackButtonClicked:(id)sender;

@end
