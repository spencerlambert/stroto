//
//  SlideDownView.m
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "SlideDownView.h"

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define STATUS_BAR_HEIGHT 20

@interface SlideDownView (ViewHandlingMethods)
- (void)pickImageNamed:(NSString *)name;
- (NSArray *)imageNames;
- (void)createThumbScrollViewIfNecessary;
@end

@implementation SlideDownView

@synthesize photos;
@synthesize mydelegate;

- (id)initWithFrame:(CGRect)frame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    frame = CGRectMake(0, CGRectGetMaxY(bounds)-thumbHeight-STATUS_BAR_HEIGHT, bounds.size.width, thumbHeight);
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor brownColor]];
        [self setOpaque:NO];
        [self setAlpha:0.75];
        [self getPhotosFromLibrary];
    }    
    return self;
}

#pragma mark View handling methods

- (void)toggleThumbView {
    CGRect frame = [self frame];
    if (thumbViewShowing) {
        frame.origin.y -= frame.size.height;
    } else {
        frame.origin.y += frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = !thumbViewShowing;
}

- (void)createThumbScrollViewIfNecessary {
    
    if (!CutoutImagesHolder) {
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [self bounds].size.width;
        CutoutImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        [CutoutImagesHolder setCanCancelContentTouches:NO];
        [CutoutImagesHolder setClipsToBounds:NO];
        
        // now place all the thumb views as subviews of the scroll view
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        
        
        for (ALAsset *asset in self.photos) {
            UIImage *thumbImage = [UIImage imageWithCGImage:[asset thumbnail]];
            if (thumbImage) {
                thumbImage =
                [UIImage imageWithCGImage:[thumbImage CGImage]
                                    scale:(thumbImage.scale * 2.4)
                              orientation:(thumbImage.imageOrientation)];
                ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:thumbImage ];
                [thumbView setThumbdelegate:self];
                [thumbView setImageName:[[asset defaultRepresentation] filename]];
                CGRect frame = [thumbView frame];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;
                [thumbView setFrame:frame];
                [thumbView setHome:frame];
                //thumbView.contentMode = UIViewContentModeScaleAspectFit;
                [thumbView setClipsToBounds:YES];
                [CutoutImagesHolder addSubview:thumbView];
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
        }
        [CutoutImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
        [self addSubview:CutoutImagesHolder];
    }
}

- (void) getPhotosFromLibrary {
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [SlideDownView defaultAssetsLibrary];
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset) {
                  if(![[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo])
                  [collector addObject:asset];
              }
          }];
         
         self.photos = collector;
         [self createThumbScrollViewIfNecessary];
     }
                    failureBlock:^(NSError *error) { NSLog(@"Boom!!!");}
     ];
    
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

-(void)findLargeImage:(NSString *)mediaurl withFrame:(CGRect) testframe
{
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            largeimage = [UIImage imageWithCGImage:iref];
        }
        if([self.mydelegate respondsToSelector:@selector(checkFrameIntersection:withFrame:)])
            [self.mydelegate checkFrameIntersection:largeimage withFrame:testframe];
    };
    
    //
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
    {
        NSLog(@"Sorry cant get image - %@",[myerror localizedDescription]);
    };
    
    if(mediaurl && [mediaurl length])
    {
        NSURL *asseturl = [NSURL URLWithString:mediaurl];
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:asseturl
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }
}

- (NSString *)getOriginalUrlOfThumbnail:(ThumbImageView *)tiv{
    for (ALAsset *asset in self.photos) {
        if([[[asset defaultRepresentation] filename] isEqualToString:[tiv imageName]]){
            return [[[asset defaultRepresentation] url] absoluteString];;
        }
    }
    return @"nil";
}

- (void)checkThumbImageIntersection:(ThumbImageView *)tiv withFrame:(CGRect) testframe{
    NSString *imageUrl = [self getOriginalUrlOfThumbnail:tiv];
    [self findLargeImage:imageUrl withFrame:testframe];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
