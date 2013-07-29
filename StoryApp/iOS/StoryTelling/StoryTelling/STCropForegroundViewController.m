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

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10


@interface STCropForegroundViewController ()

@end

@implementation STCropForegroundViewController

int selectedforegroundimage = 0;

@synthesize foregroundimagesView;
@synthesize slider;
@synthesize cropMainView,eraseMainView,sizeMainView;
@synthesize grabcutView;
@synthesize grabCutController;
@synthesize indicatorView,activityIndicator;
@synthesize bgBtn,fgBtn;

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
    edit_fg = YES;
    [self highlightButton:fgBtn with:YES];
    grabCutController = [[CvGrabCutController alloc] init];
    image_changed = NO;
    grabcutView.userInteractionEnabled = YES;
    grabcutView.exclusiveTouch = YES;
    selectedView = 0;
    [self.cropView setDelegate:self];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self convertToSTImage];
    [self clearScrollView];
    [self reloadForegroundImagesView];
    [self prepareScrollView];
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEraseTapGesture:)];
//    tapGesture.numberOfTapsRequired = 1;
//    [grabcutView addGestureRecognizer:tapGesture];
//    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
//                                          initWithTarget:self action:@selector(handleErasePanGesture:)];
//    [grabcutView addGestureRecognizer:panGesture];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) highlightButton:(UIButton*)button with:(BOOL)boolean{
    [button setHighlighted:boolean];
}

-(void) viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (IBAction)handleEraseTapGesture:(UIGestureRecognizer *)sender;
{
//    if (self.editing == NO) {
//        return;
//    }
    
    
    CGPoint tapPoint = [sender locationInView:sender.view];
    NSLog(@"tap (%f,%f)", tapPoint.x, tapPoint.y);
    NSLog(@"->  (%f,%f)", tapPoint.x*scale_x, tapPoint.y*scale_y);
    tapPoint = CGPointMake(tapPoint.x * scale_x, tapPoint.y * scale_y);
    
    [grabCutController maskLabel:tapPoint foreground:edit_fg];
    
    grabcutView.image = [grabCutController getImage];
}

- (void)updateEraseView;
{
    grabcutView.image = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    UIImage *mask = [grabCutController getSaveImageMask];
    {
        const float colorMasking = *CGColorGetComponents([UIColor blackColor].CGColor); //{1.0, 1.0, 0.0, 0.0, 1.0, 1.0};
        mask = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(mask.CGImage, &colorMasking)];
        grabcutView.image = [self maskImage:grabcutView.image withMask:mask];
        
//        STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
//        STImage *img1 = [[STImage alloc] initWithCGImage:self.grabcutView.image.CGImage];
//        img1.listDisplayOrder = img.listDisplayOrder;
//        img1.fileType = img.fileType;
//        img1.type = img.type;
//        img1.sizeX = img.sizeX;
//        img1.sizeY = img.sizeY;
//        img1.defaultScale = img.defaultScale;
//        img1.minZoomScale = img.minZoomScale;
//        img1.defaultX = img.defaultX;
//        img1.defaultY = img.defaultY;
//        [img1 setThumbimage:[self updateEraseThumbImage]];
//        [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
        
        
    }
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    
    CGImageRelease(mask);
    CGImageRelease(maskedImageRef);
    
    // returns new image with mask applied
    return maskedImage;
}

- (IBAction)handleErasePanGesture:(UIPanGestureRecognizer *)sender;
{
//    if (self.editing == NO) {
//        return;
//    }
    
    CGPoint tapPoint = [sender locationInView:sender.view];
    NSLog(@"tap (%f,%f)", tapPoint.x, tapPoint.y);
    
    tapPoint = CGPointMake(tapPoint.x * scale_x, tapPoint.y * scale_y);
    [grabCutController maskLabel:tapPoint foreground:edit_fg];
    
    grabcutView.image = [grabCutController getImage];
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
    [self setCropMainView:nil];
    [self setEraseMainView:nil];
    [self setSizeMainView:nil];
    [self setGrabcutView:nil];
    [self setActivityIndicator:nil];
    [self setIndicatorView:nil];
    [self setBgBtn:nil];
    [self setFgBtn:nil];
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
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
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
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    grabcutView.image = [self.foregroundimages objectAtIndex:0];
    [grabCutController setImage:grabcutView.image];
    [self calculateScale];
    
}

- (void)calculateScale;
{
    NSLog(@"imageView bounds: %f,%f", grabcutView.bounds.size.width, grabcutView.bounds.size.height);
    NSLog(@"imageView.image bounds: %f,%f", grabcutView.image.size.width, grabcutView.image.size.height);
    
    scale_x = grabcutView.image.size.width / grabcutView.bounds.size.width;
    scale_y = grabcutView.image.size.height / grabcutView.bounds.size.height;
    
    NSLog(@"scale_x: %f", scale_x);
    NSLog(@"scale_y: %f", scale_y);
}

-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    
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
    
//    if(selectedView == 0){
//        [self handleCropViewSingleTap:recognizer];
//    }
//    else if (selectedView == 1){
//        [self handleEraseViewSingleTap:recognizer];
//    }
    
    selectedforegroundimage = recognizer.view.tag;
    
    [self clearScrollView];
    self.cropforegroundImage = [[UIImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:recognizer.view.tag]];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    [self prepareScrollView];
    [self scrollViewDidZoom:self.cropView];
    
    grabcutView.image = [[self foregroundimages]objectAtIndex:recognizer.view.tag];
    [grabCutController setImage:grabcutView.image];
    [self calculateScale];
    
    
}

- (void) handleCropViewSingleTap:(UIGestureRecognizer *)recognizer{
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
}

- (void) handleEraseViewSingleTap:(UIGestureRecognizer *)recognizer{
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    STImage *img1 = [[STImage alloc] initWithCGImage:self.grabcutView.image.CGImage];
    img1.listDisplayOrder = img.listDisplayOrder;
    img1.fileType = img.fileType;
    img1.type = img.type;
    img1.sizeX = img.sizeX;
    img1.sizeY = img.sizeY;
    img1.defaultScale = img.defaultScale;
    img1.minZoomScale = img.minZoomScale;
    img1.defaultX = img.defaultX;
    img1.defaultY = img.defaultY;
    [img1 setThumbimage:[self updateEraseThumbImage]];
    [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
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

- (UIImage*) updateEraseThumbImage{
    float scale = 1.0f/self.cropView.zoomScale;
    CGRect visibleRect;
    visibleRect.origin.x = self.cropView.contentOffset.x * scale;
    visibleRect.origin.y = self.cropView.contentOffset.y * scale;
    visibleRect.size.width = self.cropView.bounds.size.width * scale;
    visibleRect.size.height = self.cropView.bounds.size.height * scale;
    UIImage *temp = [self cropImage:self.grabcutView.image srcImage:&visibleRect];
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



- (IBAction)pickBG:(id)sender {
    edit_fg = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self highlightButton:bgBtn with:!edit_fg];
    });
    [self highlightButton:fgBtn with:edit_fg];
}

- (IBAction)pickFG:(id)sender {
    edit_fg = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self highlightButton:fgBtn with:edit_fg];
    });
    [self highlightButton:bgBtn with:!edit_fg];
    //[self highlightButton:fgBtn with:edit_fg];
}

- (IBAction)applyGrabcut:(id)sender {
    [self performSelectorOnMainThread:@selector(actionGrabCutIteration) withObject:nil waitUntilDone:NO];
    [self.eraseMainView bringSubviewToFront:indicatorView];
    [indicatorView setUserInteractionEnabled:YES];
    [self indicateActivity:YES];
    [self highlightButton:bgBtn with:NO];
    [self highlightButton:fgBtn with:NO];
}

- (void)actionGrabCutIteration;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [grabCutController nextIteration];
        [self performSelectorOnMainThread:@selector(grabCutDone) withObject:nil waitUntilDone:NO];
    });
}

- (void)grabCutDone;
{
    image_changed = YES;
    
    grabcutView.image = [grabCutController getImage];
    [self updateEraseView];
    [self indicateActivity: NO];
    [self highlightButton:bgBtn with:!edit_fg];
    [self highlightButton:fgBtn with:edit_fg];
    [self.eraseMainView sendSubviewToBack:indicatorView];
    [indicatorView setUserInteractionEnabled:NO];
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

- (IBAction)editForegroundSegment:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [cropMainView setHidden:NO];
        [eraseMainView setHidden:YES];
        [sizeMainView setHidden:YES];
        selectedView = selectedSegment;
    }
    else if (selectedSegment == 1){
        [cropMainView setHidden:YES];
        [eraseMainView setHidden:NO];
        [self.eraseMainView bringSubviewToFront:grabcutView];
        [sizeMainView setHidden:YES];
        selectedView = selectedSegment;
    }
    else{
        [cropMainView setHidden:YES];
        [eraseMainView setHidden:YES];
        [sizeMainView setHidden:NO];
        selectedView = selectedSegment;
    }
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

- (void)indicateActivity:(BOOL)active{
    
    indicatorView.hidden = !active;
    
    if(active){
        [activityIndicator startAnimating];
    }
    else{
        [activityIndicator stopAnimating];
    }
    
}


@end
