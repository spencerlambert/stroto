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
#import "STImage.h"

@protocol SlideUpViewDelegate;

@interface SlideUpView : UIView<UIScrollViewDelegate,ThumbImageViewDelegate>{
    UIScrollView *BackgroundImagesHolder;
    BOOL thumbViewShowing;
    UIImage *largeimage;
    NSString *selectedImageUrl;
}
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) id<SlideUpViewDelegate> mydelegate;
- (void)createThumbScrollViewIfNecessary;
- (void)toggleThumbView;
- (void) getPhotosFromLibrary;
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end

@protocol SlideUpViewDelegate <NSObject>

@optional
- (void)setWorkspaceBackground:(STImage *) selectedImage;
@end