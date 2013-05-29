//
//  SlideUpView.h
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol SlideUpViewDelegate;

@interface SlideUpView : UIView<UIScrollViewDelegate,ThumbImageViewDelegate>{
    UIScrollView *BackgroundImagesHolder;
    BOOL thumbViewShowing;
    UIImage *largeimage;
    NSString *selectedImageUrl;
}
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, assign) id<SlideUpViewDelegate> mydelegate;
- (void)toggleThumbView;
- (void) getPhotosFromLibrary;
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end

@protocol SlideUpViewDelegate <NSObject>

@optional
- (void)setWorkspaceBackground:(UIImage *) selectedImage;
@end