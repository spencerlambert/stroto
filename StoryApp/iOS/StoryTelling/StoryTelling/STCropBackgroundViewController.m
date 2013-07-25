//
//  STCropBackgroundViewController.m
//  StoryTelling
//
//  Created by Aaswini on 10/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STCropBackgroundViewController.h"
#import "STImage.h"
#import "AppDelegate.h"

#define THUMB_HEIGHT 78
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10

@interface STCropBackgroundViewController ()

@end

@implementation STCropBackgroundViewController

int selectedbackgroundimage = 0;

@synthesize backgroundimagesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [self.cropView setDelegate:self];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self convertToSTImage];
    [self clearScrollView];
    [self reloadBackgroundImagesView];
    [self prepareScrollView];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return  self.cropbackgroundImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundimagesView:nil];
//    [self setCropView:nil];
    [self setCropbackgroundImage:nil];
    [super viewDidUnload];
}

- (void) reloadBackgroundImagesView{
    float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [backgroundimagesView bounds].size.width;
    UIScrollView *BackgroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [BackgroundImagesHolder setCanCancelContentTouches:NO];
    [BackgroundImagesHolder setClipsToBounds:YES];
    
    float xPosition = THUMB_H_PADDING;
    
    
    
    for (int i = 0; i<[[self backgroundimages]count];i++) {
        STImage *stimage = [[self backgroundimages]objectAtIndex:i];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        click.numberOfTapsRequired = 1;
        UIImage *thumbImage = [stimage thumbimage];
        thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
                                         scale:(thumbImage.scale * 1.4)
                                   orientation:(thumbImage.imageOrientation)];
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage ];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;
        frame.size.width = THUMB_HEIGHT;//thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT;//thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView addGestureRecognizer:click];
        [thumbView setTag:i];
        [BackgroundImagesHolder addSubview:thumbView];
        [thumbView setUserInteractionEnabled:YES];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    
    [BackgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in backgroundimagesView.subviews){
        [view removeFromSuperview];
    }
    [backgroundimagesView addSubview:BackgroundImagesHolder];
    self.cropbackgroundImage = [[UIImageView alloc] initWithImage:[[self backgroundimages]objectAtIndex:0]];
    [self.cropbackgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropbackgroundImage];
    selectedbackgroundimage = 0;
}

-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    //NSLog(@"%d",selectedbackgroundimage);
    STImage *img = [[self backgroundimages]objectAtIndex:selectedbackgroundimage];
    CGFloat currentScale = self.cropbackgroundImage.frame.size.width / self.cropbackgroundImage.bounds.size.width;
    [img setDefaultScale:currentScale];
    [img setMinZoomScale:[self.cropView minimumZoomScale]];
    [img setDefaultX:[self cropView].contentOffset.x];
    [img setDefaultY:[self cropView].contentOffset.y];
    [img setThumbimage:[self updateThumbImage]];
    [[self backgroundimages]replaceObjectAtIndex:selectedbackgroundimage withObject:img];
    selectedbackgroundimage = recognizer.view.tag;
    [self clearScrollView];
    self.cropbackgroundImage = [[UIImageView alloc] initWithImage:[[self backgroundimages]objectAtIndex:recognizer.view.tag]];
    [self.cropbackgroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropbackgroundImage];
    [self prepareScrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    [self updateThumbImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateThumbImage];
}

- (void) prepareScrollView{
    STImage *image = (STImage*)self.cropbackgroundImage.image;
    self.cropbackgroundImage.transform = CGAffineTransformScale(self.cropbackgroundImage.transform, image.defaultScale, image.defaultScale);
    [self.cropbackgroundImage setFrame:CGRectMake(0, 0, self.cropbackgroundImage.frame.size.width, self.cropbackgroundImage.frame.size.height)];
    [self.cropView setContentSize:self.cropbackgroundImage.frame.size];
    [self.cropView setContentOffset:CGPointMake(image.defaultX, image.defaultY) animated:NO];
    [self.cropView setMinimumZoomScale:image.minZoomScale==0?[self getMinimumZoomScale]:image.minZoomScale];
    if(image.minZoomScale==0)
        [self.cropView zoomToRect:[self getInitZoomRect] animated:YES];
}

- (void) clearScrollView{
    for(UIView *view in self.cropView.subviews){
        [view removeFromSuperview];
    }
}

-(void)convertToSTImage{
    NSMutableArray *stimages = [[NSMutableArray alloc]init];
    int count = 0;
    for(NSMutableDictionary *imageDictionary in [self backgroundimages]){
        UIImage *Image = [imageDictionary objectForKey:@"UIImagePickerControllerOriginalImage"];
        STImage *stimage = [[STImage alloc] initWithCGImage:[Image CGImage]];
        [stimage setThumbimage:[imageDictionary objectForKey:@"UIImagePickerControllerThumbnailImage"]];
        [stimage setFileType:[[imageDictionary objectForKey:@"UIImagePickerControllerReferenceURL"] pathExtension]];
        [stimage setType:@"background"];
        [stimage setListDisplayOrder:count++];
        [stimages addObject:stimage];
    }
    [self setBackgroundimages:stimages];
}

- (IBAction)done:(id)sender {
    STImage *img = [[self backgroundimages]objectAtIndex:selectedbackgroundimage];
    CGFloat currentScale = self.cropbackgroundImage.frame.size.width / self.cropbackgroundImage.bounds.size.width;
    [img setDefaultScale:currentScale];
    [img setMinZoomScale:[self.cropView minimumZoomScale]];
    [img setDefaultX:[self cropView].contentOffset.x];
    [img setDefaultY:[self cropView].contentOffset.y];
    [img setThumbimage:[self updateThumbImage]];
    [[self backgroundimages]replaceObjectAtIndex:selectedbackgroundimage withObject:img];
    //[self.navigationController popToRootViewControllerAnimated:YES];
    AppDelegate *backgroundImagesDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [backgroundImagesDelegate.backgroundImagesArray addObjectsFromArray:[self backgroundimages]];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (float)getMinimumZoomScale{
    float heightMinimumScale = self.cropView.frame.size.height/self.cropbackgroundImage.frame.size.height;
    float widthMinimumScale = self.cropView.frame.size.width/self.cropbackgroundImage.frame.size.width;
    if(widthMinimumScale > heightMinimumScale)
        return widthMinimumScale;
    else
        return heightMinimumScale;
}

- (CGRect) getInitZoomRect{
    CGRect zoomrect;
    zoomrect = CGRectMake(0, 0, self.cropbackgroundImage.frame.size.width, self.cropbackgroundImage.frame.size.height);
    return zoomrect;
}

- (UIImage*) updateThumbImage{
    float scale = 1.0f/self.cropView.zoomScale;
    CGRect visibleRect;
    visibleRect.origin.x = self.cropView.contentOffset.x * scale;
    visibleRect.origin.y = self.cropView.contentOffset.y * scale;
    visibleRect.size.width = self.cropView.bounds.size.width * scale;
    visibleRect.size.height = self.cropView.bounds.size.height * scale;
    UIImage *temp = [self cropImage:self.cropbackgroundImage.image srcImage:&visibleRect];
    UIImageView *thumbview = (UIImageView*)[self subviewWithTag:selectedbackgroundimage inView:[backgroundimagesView.subviews objectAtIndex:0]];
    thumbview.image = temp;
    return temp;
}

- (UIView*) subviewWithTag:(int)tag inView:(UIView*)view{
    for(UIView *temp in view.subviews){
        if(temp.tag == tag)return temp;
    }
    return nil;
}

- (UIImage*) cropImage:(UIImage*)srcImage srcImage:(CGRect*)rect
{
    CGImageRef cr = CGImageCreateWithImageInRect([srcImage CGImage], *rect);
    UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
    CGImageRelease(cr);
    return cropped;
}

@end
