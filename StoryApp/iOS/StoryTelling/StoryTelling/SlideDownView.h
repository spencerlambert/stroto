//
//  SlideDownView.h
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "STImage.h"

@protocol SlideDownViewDelegate;

@interface SlideDownView : UIView<UIScrollViewDelegate,ThumbImageViewDelegate>{
    UIScrollView *CutoutImagesHolder;
    BOOL thumbViewShowing;
    UIImage *largeimage;
}

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, assign) id<SlideDownViewDelegate> mydelegate;
- (void)createThumbScrollViewIfNecessary;
- (void)toggleThumbView;
- (void) getPhotosFromLibrary;
+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end

@protocol SlideDownViewDelegate <NSObject>

@optional
- (void)checkFrameIntersection:(UIImage *)tiv withFrame:(CGRect)testframe;
- (void)setForegroundImage:(STImage *) selectedImage;
@end
