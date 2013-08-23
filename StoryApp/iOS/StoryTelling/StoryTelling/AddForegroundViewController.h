//
//  AddForegroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "AppDelegate.h"

@interface AddForegroundViewController : UIViewController<ELCImagePickerControllerDelegate,UIImagePickerControllerDelegate>{
    NSMutableArray *foregroundImages;
}
- (IBAction)fromGalleryButtonClicked:(id)sender;
- (IBAction)fromCameraButtonClicked:(UIButton *)sender;

@end
