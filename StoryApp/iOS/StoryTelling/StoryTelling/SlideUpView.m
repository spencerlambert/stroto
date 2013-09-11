//
//  SlideUpView.m
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "SlideUpView.h"
#import "STImage.h"

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10

@interface SlideUpView (ViewHandlingMethods)
- (void)createThumbScrollViewIfNecessary;
@end

@implementation SlideUpView

@synthesize photos;

- (id)initWithFrame:(CGRect)frame
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    frame = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), bounds.size.width - thumbHeight, thumbHeight);
    self = [super initWithFrame:frame];
/***
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        [self setAlpha:1];
    }
***/
    return self;
}

#pragma mark View handling methods

- (void)toggleThumbView {
    CGRect frame = [self frame];
    if (thumbViewShowing) {
        frame.origin.y += frame.size.height;
    } else {
        frame.origin.y -= frame.size.height;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setFrame:frame];
    [UIView commitAnimations];
    
    thumbViewShowing = !thumbViewShowing;
}

- (void)createThumbScrollViewIfNecessary {
    
    if (!BackgroundImagesHolder) {
        
        float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
        float scrollViewWidth  = [self bounds].size.width;
        BackgroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
        [BackgroundImagesHolder setCanCancelContentTouches:NO];
        [BackgroundImagesHolder setClipsToBounds:YES];
        
        // now place all the thumb views as subviews of the scroll view
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        
        
        for (int i = 0; i<[[self photos]count];i++) {
            STImage *stimage = [[self photos]objectAtIndex:i];
            UIImage *thumbImage = stimage.thumbimage;
            if (thumbImage) {
                thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
                                                 scale:(thumbImage.scale * 1.4)
                                           orientation:(thumbImage.imageOrientation)];
                ThumbImageView *thumbView = [[ThumbImageView alloc] initWithImage:thumbImage ];
                [thumbView setThumbdelegate:self];
                CGRect frame = [thumbView frame];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;
                frame.size.height = THUMB_HEIGHT;
                frame.size.width = THUMB_HEIGHT;
                [thumbView setFrame:frame];
                [thumbView setHome:frame];
                //thumbView.contentMode = UIViewContentModeScaleAspectFit;
                [thumbView setClipsToBounds:YES];
                [thumbView setOriginalImage:stimage];
                [BackgroundImagesHolder addSubview:thumbView];
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
        }
        [BackgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
        [self addSubview:BackgroundImagesHolder];
        //[self setClipsToBounds:YES];
    }
}

- (void) getPhotosFromLibrary {
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [SlideUpView defaultAssetsLibrary];
    
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

- (void)thumbImageViewWasTapped:(ThumbImageView *)tiv{
    //NSLog(@"image name = %@" , tiv);
//    NSString *imageUrl = [self getOriginalUrlOfThumbnail:tiv];
//    [self findLargeImage:imageUrl];
    if ([self.mydelegate respondsToSelector:@selector(setWorkspaceBackground:)]){
        [self.mydelegate setWorkspaceBackground:[tiv originalImage]];
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


-(void)findLargeImage:(NSString *)mediaurl
{
    //
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *rep = [myasset defaultRepresentation];
        CGImageRef iref = [rep fullResolutionImage];
        if (iref) {
            largeimage = [UIImage imageWithCGImage:iref];
        }
        if ([self.mydelegate respondsToSelector:@selector(setWorkspaceBackground:)]){
            [self.mydelegate setWorkspaceBackground:largeimage];
        }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
