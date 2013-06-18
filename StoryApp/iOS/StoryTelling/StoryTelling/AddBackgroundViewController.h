//
//  AddBackgroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

@protocol AddBackgroundViewControllerDelegate <NSObject>

- (void)setbackgroundimages:(NSMutableArray *)info;

@end

@interface AddBackgroundViewController : UIViewController<ELCImagePickerControllerDelegate>{
    NSMutableArray *backgroundImages;
}

@property id<AddBackgroundViewControllerDelegate> delegate;
- (IBAction)fromGalleryButtonClicked:(id)sender;
- (IBAction)fromStoryPackButtonClicked:(id)sender;

@end
