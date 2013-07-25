//
//  STCropForegroundViewController.m
//  StoryTelling
//
//  Created by Aaswini on 10/07/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STCropForegroundViewController.h"
#import "STImage.h"
#import "AppDelegate.h"
#import "STForegroundEraseViewController.h"

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10


@interface STCropForegroundViewController ()

@end

@implementation STCropForegroundViewController

int selectedforegroundimage = 0;
bool eraseMode = NO;

@synthesize foregroundimagesView;
@synthesize slider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    eraseMode = NO;
    [self.cropView setDelegate:self];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self convertToSTImage];
    [self clearScrollView];
    [self reloadForegroundImagesView];
    [self prepareScrollView];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return  self.cropforegroundImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setForegroundimagesView:nil];
    //[self setCropView:nil];
    [self setCropforegroundImage:nil];
    [self setSlider:nil];
    [super viewDidUnload];
}

- (void) reloadForegroundImagesView{
    float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [foregroundimagesView bounds].size.width;
    UIScrollView *ForegroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [ForegroundImagesHolder setCanCancelContentTouches:NO];
    [ForegroundImagesHolder setClipsToBounds:YES];
    
    float xPosition = THUMB_H_PADDING;
    
    
    
    for (int i = 0; i<[[self foregroundimages]count];i++) {
        STImage *stimage = [[self foregroundimages]objectAtIndex:i];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        click.numberOfTapsRequired = 1;
        UIImage *thumbImage = [stimage thumbimage];
        thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
                                         scale:(thumbImage.scale * 1.4)
                                   orientation:(thumbImage.imageOrientation)];
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:thumbImage ];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;
        frame.size.width = 50; //thumbImage.size.width;
        frame.size.height = 50; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView addGestureRecognizer:click];
        [thumbView setTag:i];
        [ForegroundImagesHolder addSubview:thumbView];
        [thumbView setUserInteractionEnabled:YES];
        xPosition += (frame.size.width + THUMB_H_PADDING);
        selectedforegroundimage = 0;
    }
    
    [ForegroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in foregroundimagesView.subviews){
        [view removeFromSuperview];
    }
    [foregroundimagesView addSubview:ForegroundImagesHolder];
    // [self.cropforegroundImage setImage:[[self foregroundimages] objectAtIndex:0]];
    NSLog(@"(%f,%f)",((UIImage*)[[self foregroundimages]objectAtIndex:0]).size.width,((UIImage*)[[self foregroundimages]objectAtIndex:0]).size.height);
    self.cropforegroundImage = [[UIImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:0]];
//    [self.cropforegroundImage setSize:((UIImage*)[[self foregroundimages]objectAtIndex:0]).size];
//    [self.cropforegroundImage setOriginalImage:((STImage*)[[self foregroundimages]objectAtIndex:0]).orgImage];
    //[self.cropforegroundImage setUserInteractionEnabled:YES];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    
}

-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    //NSLog(@"%d",selectedforegroundimage);
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    STImage *img1 = [[STImage alloc] initWithCGImage:self.cropforegroundImage.image.CGImage];
    img1.listDisplayOrder = img.listDisplayOrder;
    img1.fileType = img.fileType;
    img1.type = img.type;
    img1.sizeX = img.sizeX;
    img1.sizeY = img.sizeY;
    CGFloat currentScale = self.cropforegroundImage.frame.size.width / self.cropforegroundImage.bounds.size.width;
    [img1 setDefaultScale:currentScale];
    [img1 setMinZoomScale:[self.cropView minimumZoomScale]];
    [img1 setDefaultX:[self cropView].contentOffset.x];
    [img1 setDefaultY:[self cropView].contentOffset.y];
    [img1 setThumbimage:[self updateThumbImage]];
    [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
    selectedforegroundimage = recognizer.view.tag;
    [self clearScrollView];
    self.cropforegroundImage = [[UIImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:recognizer.view.tag]];
//    [self.cropforegroundImage setSize:((UIImage*)[[self foregroundimages]objectAtIndex:recognizer.view.tag]).size];
//    [self.cropforegroundImage setOriginalImage:((STImage*)[[self foregroundimages]objectAtIndex:recognizer.view.tag]).orgImage];
    //[self.cropforegroundImage setUserInteractionEnabled:YES];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    [self prepareScrollView];
    [self scrollViewDidZoom:self.cropView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if([scrollView isDescendantOfView:self.cropView]){
        UIView *subView = [scrollView.subviews objectAtIndex:0];
        
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        
        subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                     scrollView.contentSize.height * 0.5 + offsetY);
        
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    [self updateThumbImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateThumbImage];
}

- (void) prepareScrollView{
    STImage *image = (STImage*)self.cropforegroundImage.image;
    self.cropforegroundImage.transform = CGAffineTransformScale(self.cropforegroundImage.transform, image.defaultScale, image.defaultScale);
    [self.cropforegroundImage setFrame:CGRectMake(0, 0, self.cropforegroundImage.frame.size.width, self.cropforegroundImage.frame.size.height)];
    [self.cropView setContentSize:self.cropforegroundImage.frame.size];
    [self.cropView setContentOffset:CGPointMake(image.defaultX, image.defaultY) animated:NO];
    //NSLog(@"MINZOOMSCALE : %f" , [self getMinimumZoomScale]);
    [self.cropView setMinimumZoomScale:image.minZoomScale==0?[self getMinimumZoomScale]:image.minZoomScale];
    if(image.minZoomScale==0)
        [self.cropView zoomToRect:[self getInitZoomRect] animated:YES];
//    else
//        [self.cropView zoomToRect:CGRectMake(image.defaultX, image.defaultY, self.cropforegroundImage.image.size.width, self.cropforegroundImage.image.size.height) animated:YES];
}

- (void) clearScrollView{
    for(UIView *view in self.cropView.subviews){
        [view removeFromSuperview];
    }
}

-(void)convertToSTImage{
    NSMutableArray *stimages = [[NSMutableArray alloc]init];
    int count = 0;
    for(NSMutableDictionary *imageDictionary in [self foregroundimages]){
        UIImage *Image = [imageDictionary objectForKey:@"UIImagePickerControllerOriginalImage"];
        STImage *stimage = [[STImage alloc] initWithCGImage:[Image CGImage]];
        [stimage setThumbimage:[imageDictionary objectForKey:@"UIImagePickerControllerThumbnailImage"]];
        [stimage setFileType:[[imageDictionary objectForKey:@"UIImagePickerControllerReferenceURL"] pathExtension]];
        [stimage setType:@"foreground"];
        [stimage setListDisplayOrder:count++];
        [stimage setOrgImage:[[UIImage alloc] initWithCGImage:[Image CGImage] ]];
        [stimages addObject:stimage];
    }
    [self setForegroundimages:stimages];
}

- (UIImage*) updateThumbImage{
    float scale = 1.0f/self.cropView.zoomScale;
    CGRect visibleRect;
    visibleRect.origin.x = self.cropView.contentOffset.x * scale;
    visibleRect.origin.y = self.cropView.contentOffset.y * scale;
    visibleRect.size.width = self.cropView.bounds.size.width * scale;
    visibleRect.size.height = self.cropView.bounds.size.height * scale;
    UIImage *temp = [self cropImage:self.cropforegroundImage.image srcImage:&visibleRect];
    UIImageView *thumbview = (UIImageView*)[self subviewWithTag:selectedforegroundimage inView:[foregroundimagesView.subviews objectAtIndex:0]];
    thumbview.image = temp;
    return temp;
}

- (UIView*) subviewWithTag:(int)tag inView:(UIView*)view{
    for(UIView *temp in view.subviews){
        if(temp.tag == tag)return temp;
    }
    return nil;
}

- (UIImage*) cropImage:(UIImage*)srcImage srcImage:(CGRect*) rect
{
    CGImageRef cr = CGImageCreateWithImageInRect([srcImage CGImage], *rect);
    UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
    CGImageRelease(cr);
    return cropped;
}



- (IBAction)done:(id)sender {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    CGFloat currentScale = self.cropforegroundImage.frame.size.width / self.cropforegroundImage.bounds.size.width;
    [img setDefaultScale:currentScale];
    [img setMinZoomScale:[self.cropView minimumZoomScale]];
    [img setDefaultX:[self cropView].contentOffset.x];
    [img setDefaultY:[self cropView].contentOffset.y];
    [img setThumbimage:[self updateThumbImage]];
    [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img];
    AppDelegate *foregroundImagesDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [foregroundImagesDelegate.foregroundImagesArray addObjectsFromArray:[self foregroundimages]];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (float)getMinimumZoomScale{
    float heightMinimumScale = self.cropView.frame.size.height/self.cropforegroundImage.frame.size.height;
    float widthMinimumScale = self.cropView.frame.size.width/self.cropforegroundImage.frame.size.width;
    if(widthMinimumScale < heightMinimumScale)
        return widthMinimumScale;
    else
        return heightMinimumScale;
}

- (CGRect) getInitZoomRect{
    CGRect zoomrect;
    zoomrect = CGRectMake(0, 0, self.cropforegroundImage.frame.size.width, self.cropforegroundImage.frame.size.height);
    return zoomrect;
}

- (IBAction)sliderChanged:(id)sender {
    
    if(slider.value < 1){
        [slider setValue:0];
        
    }else if(slider.value <2){
        [slider setValue:1];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [(STForegroundEraseViewController*) segue.destinationViewController setImage:self.cropforegroundImage.image];
}
@end
