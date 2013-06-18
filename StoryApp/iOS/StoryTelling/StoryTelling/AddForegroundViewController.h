//
//  AddForegroundViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

@protocol AddForegroundViewControllerDelegate <NSObject>

- (void)setforegroundimages:(NSMutableArray *)info;

@end

@interface AddForegroundViewController : UIViewController<ELCImagePickerControllerDelegate>{
    NSMutableArray *foregroundImages;
}
@property id<AddForegroundViewControllerDelegate> delegate;
- (IBAction)fromGalleryButtonClicked:(id)sender;
- (IBAction)fromStoryPackButtonClicked:(id)sender;

@end
