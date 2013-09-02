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
#import "ACMagnifyingView.h"
#import "ACMagnifyingGlass.h"
#import "ACLoupe.h"

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10


@interface STCropForegroundViewController ()

@end

@implementation STCropForegroundViewController
@synthesize isFromCamera;
int selectedforegroundimage = 0;
CGPoint centerPoint;
CGPoint grabcutCenter;
CGRect grabcutFrame;

@synthesize foregroundimagesView;
@synthesize slider;
@synthesize cropMainView,eraseMainView,sizeMainView;
@synthesize grabcutView;
@synthesize grabCutController;
@synthesize indicatorView,activityIndicator;
@synthesize bgBtn,fgBtn,applyBtn,undoBtn;
@synthesize sizeView;

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
    isEditing = NO;
    isEdited = NO;
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
    undoImages = [[NSMutableArray alloc]initWithCapacity:[self.foregroundimages count]];
    for (int i =0; i<[self.foregroundimages count]; i++) {
        NSMutableArray *temp = [[NSMutableArray alloc]init];
        undoImages[i] = temp;
    }
    [self clearScrollView];
    croppedImages = [[NSMutableArray alloc]initWithCapacity:[self.foregroundimages count]];
    [self reloadForegroundImagesView];
    [self prepareScrollView];
    [undoBtn setEnabled:NO];
    [undoBtn setAlpha:0.5];
    
    testImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
   // [self.view addSubview:testImage];
    testImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(160, 0, 150, 150)];
   //[self.view addSubview:testImage1];
    
    
    //    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEraseTapGesture:)];
    //    tapGesture.numberOfTapsRequired = 1;
    //    [grabcutView addGestureRecognizer:tapGesture];
    //
    //    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
    //                                          initWithTarget:self action:@selector(handleErasePanGesture:)];
    //    [grabcutView addGestureRecognizer:panGesture];
    //
    //    ACLoupe *loupe = [[ACLoupe alloc] init];
    //    self.magnifyingView.magnifyingGlass = loupe;
    //	loupe.scaleAtTouchPoint =YES;
    
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
    if(!isEditing){
        [grabCutController saveMask];
    }
    isEditing = YES;
    
    CGPoint tapPoint = [sender locationInView:sender.view];
    NSLog(@"tap (%f,%f)", tapPoint.x, tapPoint.y);
    NSLog(@"->  (%f,%f)", tapPoint.x*scale_x, tapPoint.y*scale_y);
    tapPoint = CGPointMake(tapPoint.x * scale_x, tapPoint.y * scale_y);
    
    [grabCutController maskLabel:tapPoint foreground:edit_fg];
    
    grabcutView.image = [grabCutController getImage];
}

- (void)updateEraseView;
{
    STImage *test = [[croppedImages[selectedforegroundimage] lastObject] objectForKey:@"image"];
    UIImage *mask = [grabCutController getSaveImageMask];
    {
        const float colorMasking = *CGColorGetComponents([UIColor blackColor].CGColor); //{1.0, 1.0, 0.0, 0.0, 1.0, 1.0};
        mask = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(mask.CGImage, &colorMasking)];
        grabcutView.image = [self maskImage:test withMask:mask];
        lastEdit = grabcutView.image;
    }
    testImage.image = test;
    testImage1.image = [grabCutController getImage];
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
    if(!isEditing){
        [grabCutController saveMask];
    }
    isEditing = YES;
    
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
    [self setSizeView:nil];
    [self setApplyBtn:nil];
    [self setUndoBtn:nil];
    //    [self setMagnifyingView:nil];
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
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage ];
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
    
    //init crop imageview
    self.cropforegroundImage = [[UIImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:0]];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    
    //init erase imageview
    grabcutView.image = [self.foregroundEraseImages objectAtIndex:0];
    [grabCutController setImage:grabcutView.image];
    grabcutCenter = [grabcutView center];
    grabcutFrame = [grabcutView frame];
    [self calculateScale];
    
    //init size imageview
    sizeView.image  = [[self foregroundimages]objectAtIndex:0];
    sizeView.contentMode = UIViewContentModeScaleAspectFit;
    slider.maximumValue = sizeView.frame.size.width;
    slider.minimumValue = 24;
    slider.value = slider.maximumValue;
    centerPoint = [sizeView center];
    
    for(int i =0; i< [self foregroundimages].count ; i++){
        NSMutableDictionary *temp = [[NSMutableDictionary alloc]init];
        //[temp setValue:((STImage *)self.foregroundimages[i]).thumbimage forKey:@"image"];
        [temp setValue:((STImage *)self.foregroundimages[i]) forKey:@"image"];
        [temp setValue:[NSNumber numberWithInt:0] forKey:@"count"];
        NSMutableArray *temp1 = [[NSMutableArray alloc]init];
        [temp1 addObject:temp];
        croppedImages[i] = temp1;
    }
}

- (void)calculateScale;
{
    //NSLog(@"imageView bounds: %f,%f", grabcutView.bounds.size.width, grabcutView.bounds.size.height);
    //NSLog(@"imageView.image bounds: %f,%f", grabcutView.image.size.width, grabcutView.image.size.height);
    
    scale_x = grabcutView.bounds.size.width / grabcutView.image.size.width;
    scale_y = grabcutView.bounds.size.height / grabcutView.image.size.height;
    
    if( scale_y >= scale_x)
    {
        scale_x = grabcutView.bounds.size.width / grabcutView.image.size.width;
        float newHeight = scale_x * grabcutView.image.size.height;
        CGRect frame = grabcutView.frame;
        frame.size.height = newHeight;
        grabcutView.frame = frame;
        scale_y = grabcutView.bounds.size.height/grabcutView.image.size.height;
        scale_x = 1/scale_x;
        scale_y = 1/scale_y;
        [grabcutView setCenter:grabcutCenter];
        
    }else
    {
        scale_y = grabcutView.bounds.size.height / grabcutView.image.size.height;
        float newWidth = scale_y * grabcutView.image.size.width;
        CGRect frame = grabcutView.frame;
        frame.size.width = newWidth;
        grabcutView.frame = frame;
        scale_x = grabcutView.bounds.size.width/grabcutView.image.size.width;
        scale_x = 1/scale_x;
        scale_y = 1/scale_y;
        [grabcutView setCenter:grabcutCenter];
    }
    //NSLog(@"scale_x: %f", scale_x );
    //NSLog(@"scale_y: %f", scale_y);
    
}

-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    
    isEdited = NO;
    
    if(selectedView == 0){
        [self handleCropViewSingleTap];
    }
    else if (selectedView == 1){
        [self handleEraseViewSingleTap];
    }
    else if (selectedView == 2){
        [self handleSizeViewSingleTap];
    }
    
    selectedforegroundimage = recognizer.view.tag;
    if ([undoImages[selectedforegroundimage] count] == 0) {
        [undoBtn setEnabled:NO];
        [undoBtn setAlpha:0.5];
    }else{
        [undoBtn setEnabled:YES];
        [undoBtn setAlpha:1.0];
    }
    
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    
    [self clearScrollView];
    self.cropforegroundImage = [[UIImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:selectedforegroundimage]];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    [self prepareScrollView];
    [self scrollViewDidZoom:self.cropView];
    
    
    if(img.isEdited){
        [grabcutView setFrame:grabcutFrame];
        grabcutView.image = [[self foregroundEraseImages]objectAtIndex:selectedforegroundimage];
        [grabCutController setImage:grabcutView.image];
        [self calculateScale];
    }else if (!img.isEdited && img.minZoomScale!=0){
        [grabcutView setFrame:grabcutFrame];
        grabcutView.image = img.thumbimage;
        [grabCutController setImage:grabcutView.image];
        [self calculateScale];
    }
    else{
        [grabcutView setFrame:grabcutFrame];
        grabcutView.image = ((STImage*)[[self foregroundEraseImages]objectAtIndex:selectedforegroundimage]).orgImage;
        [grabCutController setImage:grabcutView.image];
        [self calculateScale];
    }
    
    sizeView.image = ((UIImageView*)recognizer.view).image;
    CGRect frame = sizeView.frame;
    frame.size.width = img.sizeScale;
    frame.size.height = img.sizeScale;
    [sizeView setFrame:frame];
    [sizeView setCenter:centerPoint];
    slider.maximumValue = 269;
    slider.minimumValue = 24;
    slider.value = img.sizeScale;
}

- (void) handleCropViewSingleTap{
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    STImage *img1 = [[STImage alloc] initWithCGImage:img.CGImage];
    img1.listDisplayOrder = img.listDisplayOrder;
    img1.fileType = img.fileType;
    img1.type = img.type;
    img1.sizeX = img.sizeX;
    img1.sizeY = img.sizeY;
    img1.sizeScale = img.sizeScale;
    img1.isEdited = img.isEdited;
    img1.orgImage = img.orgImage;
    img1.masks = img.masks;
    img1.maskImgs = img.maskImgs;
    CGFloat currentScale = self.cropforegroundImage.frame.size.width / self.cropforegroundImage.bounds.size.width;
    [img1 setDefaultScale:currentScale];
    [img1 setMinZoomScale:[self.cropView minimumZoomScale]];
    [img1 setDefaultX:[self cropView].contentOffset.x];
    [img1 setDefaultY:[self cropView].contentOffset.y];
    [img1 setThumbimage:[self updateThumbImage]];
    [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
    
    grabcutView.image = img1.thumbimage;
    sizeView.image = img1.thumbimage;
}

- (void) handleEraseViewSingleTap{
    STImage *img = [[self foregroundEraseImages]objectAtIndex:selectedforegroundimage];
    STImage *img1 = [[STImage alloc] initWithCGImage:self.grabcutView.image.CGImage];
    img1.listDisplayOrder = img.listDisplayOrder;
    img1.fileType = img.fileType;
    img1.type = img.type;
    img1.sizeX = img.sizeX;
    img1.sizeY = img.sizeY;
    img1.orgImage = img.orgImage;
    img1.sizeScale = img.sizeScale;
    img1.isEdited = img.isEdited;
    img1.defaultScale = img.defaultScale;
    img1.minZoomScale = img.minZoomScale;
    img1.defaultX = img.defaultX;
    img1.defaultY = img.defaultY;
    img1.masks = img.masks;
    img1.maskImgs = img.maskImgs;
    [img1 setThumbimage:[self updateEraseThumbImage]];
    [[self foregroundEraseImages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
    
    if(img.isEdited && !isEditing){
        img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
        img1.listDisplayOrder = img.listDisplayOrder;
        img1.fileType = img.fileType;
        img1.type = img.type;
        img1.sizeX = img.sizeX;
        img1.sizeY = img.sizeY;
        img1.orgImage = img.orgImage;
        img1.sizeScale = img.sizeScale;
        img1.defaultScale = 1;
        img1.minZoomScale = 0;
        img1.defaultX = 0;
        img1.defaultY = 0;
//        img1.mask = img.mask;
//        img1.maskImg = img.maskImg;
        [img1 setThumbimage:[self updateEraseThumbImage]];
        [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
        [self clearScrollView];
        self.cropforegroundImage = [[UIImageView alloc] initWithImage:img1];
        [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.cropView addSubview:self.cropforegroundImage];
        [self prepareScrollView];
    }
    else if (img.isEdited && isEditing){
        img1 = [[STImage alloc] initWithCGImage:lastEdit.CGImage];
        img1.listDisplayOrder = img.listDisplayOrder;
        img1.fileType = img.fileType;
        img1.type = img.type;
        img1.sizeX = img.sizeX;
        img1.sizeY = img.sizeY;
        img1.orgImage = img.orgImage;
        img1.sizeScale = img.sizeScale;
        img1.defaultScale = 1;
        img1.minZoomScale = 0;
        img1.defaultX = 0;
        img1.defaultY = 0;
        img1.masks = img.masks;
        img1.maskImgs = img.maskImgs;
        [img1 setThumbimage:img.thumbimage];
        [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img1];
        [self clearScrollView];
        self.cropforegroundImage = [[UIImageView alloc] initWithImage:img1];
        [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.cropView addSubview:self.cropforegroundImage];
        [self prepareScrollView];
    }
}

-(void) handleSizeViewSingleTap{
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    img.sizeScale = slider.value;
    [[self foregroundimages] replaceObjectAtIndex:selectedforegroundimage withObject:img];
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
    NSMutableArray *eraseImages = [[NSMutableArray alloc]init];
    int count = 0;
    for(NSMutableDictionary *imageDictionary in [self foregroundimages]){
        UIImage *Image = [imageDictionary objectForKey:@"UIImagePickerControllerOriginalImage"];
        STImage *stimage = [[STImage alloc] initWithCGImage:[Image CGImage]];
        if(Image.size.width >= Image.size.height && Image.size.width > 640){
            Image = [self imageWithImage:Image scaledToWidth:640];
        }else if (Image.size.height >Image.size.width && Image.size.height > 640){
            Image = [self imageWithImage:Image scaledToHeight:640];
        }
        [stimage setThumbimage:Image];
        [stimage setFileType:[[imageDictionary objectForKey:@"UIImagePickerControllerReferenceURL"] pathExtension]];
        [stimage setType:@"foreground"];
        [stimage setListDisplayOrder:count++];
        [stimage setOrgImage:[[UIImage alloc] initWithCGImage:[Image CGImage]]];
        [stimages addObject:stimage];
    }
    //[self setForegroundimages:stimages];
    for(NSMutableDictionary *imageDictionary in [self foregroundimages]){
        UIImage *Image = [imageDictionary objectForKey:@"UIImagePickerControllerOriginalImage"];
        if(Image.size.width >= Image.size.height && Image.size.width > 640){
            Image = [self imageWithImage:Image scaledToWidth:640];
        }else if (Image.size.height >Image.size.width && Image.size.height > 640){
            Image = [self imageWithImage:Image scaledToHeight:640];
        }
        STImage *stimage = [[STImage alloc] initWithCGImage:[Image CGImage]];
        [stimage setThumbimage:Image];
        [stimage setFileType:[[imageDictionary objectForKey:@"UIImagePickerControllerReferenceURL"] pathExtension]];
        [stimage setType:@"foreground"];
        [stimage setListDisplayOrder:count++];
        [stimage setOrgImage:[[UIImage alloc] initWithCGImage:[Image CGImage]]];
        [eraseImages addObject:stimage];
    }
    [self setForegroundimages:stimages];
    [self setForegroundEraseImages:eraseImages];
}

- (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width {//method to scale image accordcing to width
    
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *) imageWithImage: (UIImage*) sourceImage scaledToHeight: (float) i_height {//method to scale image accordcing to width
    
    float oldHeight = sourceImage.size.height;
    float scaleFactor = i_height / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



- (UIImage*) updateThumbImage{
    float scale = 1.0f/self.cropView.zoomScale;
    CGRect visibleRect;
    visibleRect.origin.x = self.cropView.contentOffset.x * scale;
    visibleRect.origin.y = self.cropView.contentOffset.y * scale;
    visibleRect.size.width = self.cropView.bounds.size.width * scale;
    visibleRect.size.height = self.cropView.bounds.size.height * scale;
    UIImage *temp = [self cropImage:self.cropforegroundImage.image srcImage:&visibleRect];
    if(temp.size.width >= temp.size.height && temp.size.width > 640){
        temp = [self imageWithImage:temp scaledToWidth:640];
    }else if (temp.size.height >temp.size.width && temp.size.height > 640){
        temp = [self imageWithImage:temp scaledToHeight:640];
    }
    UIImageView *thumbview = (UIImageView*)[self subviewWithTag:selectedforegroundimage inView:[foregroundimagesView.subviews objectAtIndex:0]];
    thumbview.image = temp;
    return temp;
}

- (UIImage*) updateEraseThumbImage{
    //    float scale = 1.0f/self.cropView.zoomScale;
    //    CGRect visibleRect;
    //    visibleRect.origin.x = self.cropView.contentOffset.x * scale;
    //    visibleRect.origin.y = self.cropView.contentOffset.y * scale;
    //    visibleRect.size.width = self.cropView.bounds.size.width * scale;
    //    visibleRect.size.height = self.cropView.bounds.size.height * scale;
    //    UIImage *temp = [self cropImage:self.grabcutView.image srcImage:&visibleRect];
    UIImage *temp = self.grabcutView.image;
    if(temp.size.width >= temp.size.height && temp.size.width > 640){
        temp = [self imageWithImage:temp scaledToWidth:640];
    }else if (temp.size.height >temp.size.width && temp.size.height > 640){
        temp = [self imageWithImage:temp scaledToHeight:640];
    }
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
    
    //    grabcutView.image = [grabCutController getImage];
    [self updateEraseView];
    [undoImages[selectedforegroundimage] addObject:[grabCutController getSaveImageMask]];
    [self updateEraseThumbImage];
    [self indicateActivity: NO];
    [self highlightButton:bgBtn with:!edit_fg];
    [self highlightButton:fgBtn with:edit_fg];
    [self.eraseMainView sendSubviewToBack:indicatorView];
    [indicatorView setUserInteractionEnabled:NO];
    
    STImage *img = [self.foregroundEraseImages objectAtIndex:selectedforegroundimage];
    img.isEdited = YES;
    [img.maskImgs addObject:[[croppedImages[selectedforegroundimage] lastObject] objectForKey:@"image"]];
    [img.masks addObject:[grabCutController getInverseSaveImageMask]];
    [self.foregroundEraseImages replaceObjectAtIndex:selectedforegroundimage withObject:img];
    
    isEdited = YES;
    isEditing = NO;
    
    [undoBtn setEnabled:YES];
    [undoBtn setAlpha:1.0];
    
}

- (IBAction)done:(id)sender {
    if(selectedView == 0){
        [self handleCropViewSingleTap];
    }
    else if (selectedView == 1){
        [self handleEraseViewSingleTap];
    }
    else if (selectedView == 2){
        [self handleSizeViewSingleTap];
    }
    

    
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

- (UIImage*) updateThumbImage1{
    float scale = 1.0f/self.cropView.zoomScale;
    CGRect visibleRect;
    visibleRect.origin.x = self.cropView.contentOffset.x * scale;
    visibleRect.origin.y = self.cropView.contentOffset.y * scale;
    visibleRect.size.width = self.cropView.bounds.size.width * scale;
    visibleRect.size.height = self.cropView.bounds.size.height * scale;
    UIImage *temp = [self cropImage:self.cropforegroundImage.image srcImage:&visibleRect];
    if(temp.size.width >= temp.size.height && temp.size.width > 640){
        temp = [self imageWithImage:temp scaledToWidth:640];
    }else if (temp.size.height >temp.size.width && temp.size.height > 640){
        temp = [self imageWithImage:temp scaledToHeight:640];
    }
   // testImage1.image = temp;
    
    return temp;
}


- (IBAction)editForegroundSegment:(id)sender {
    
    isEdited = NO;
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if(selectedView == 0){
        [self handleCropViewSingleTap];
    }
    else if (selectedView == 1){
        [self handleEraseViewSingleTap];
        if ([undoImages[selectedforegroundimage] count] == 0) {
            [undoBtn setEnabled:NO];
            [undoBtn setAlpha:0.5];
        }else{
            [undoBtn setEnabled:YES];
            [undoBtn setAlpha:1.0];
        }
    }
    else if (selectedView == 2){
        [self handleSizeViewSingleTap];
    }
    
    
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    
    if (selectedSegment == 0) {
        
        for (int i=0; i< [[self foregroundimages] count]; i++) {
            STImage *tempImg = [[self foregroundimages] objectAtIndex:i];
            if (tempImg.minZoomScale!=0 && [croppedImages[i] count]>1 ) {
                [croppedImages[i] removeLastObject];
            }
        }
        
        [cropMainView setHidden:NO];
        [eraseMainView setHidden:YES];
        [sizeMainView setHidden:YES];
        selectedView = selectedSegment;
        
        [self clearScrollView];
        self.cropforegroundImage = [[UIImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:selectedforegroundimage]];
        [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.cropView addSubview:self.cropforegroundImage];
        [self prepareScrollView];
        [self scrollViewDidZoom:self.cropView];
        
    }
    else if (selectedSegment == 1){
        if(selectedView == 0 || selectedView == 2)
        {
            for(int i=0; i < [self foregroundimages].count; i++){
                STImage *temp = self.foregroundimages[i];
                if(temp.minZoomScale !=0){
                    STImage *temp1 = [[STImage alloc] initWithCGImage:((UIImage*)[[croppedImages[i] lastObject] valueForKey:@"image"]).CGImage];
                    temp1.minZoomScale = temp.minZoomScale;
                    temp1.defaultScale = temp.defaultScale;
                    temp1.defaultX = temp.defaultX;
                    temp1.defaultY = temp.defaultY;
                    [self clearScrollView];
                    self.cropforegroundImage = [[UIImageView alloc] initWithImage:temp1];
                    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
                    [self.cropView addSubview:self.cropforegroundImage];
                    [self prepareScrollView];
                    [self scrollViewDidZoom:self.cropView];
                    STImage *temp2 = [[STImage alloc]initWithCGImage:[self updateThumbImage1].CGImage];
                    NSMutableDictionary *temp3 = [[NSMutableDictionary alloc]init];
                    [temp3 setValue:temp2 forKey:@"image"];
                    [temp3 setValue:[NSNumber numberWithInteger:[undoImages[i] count]] forKey:@"count"];
                    [croppedImages[i] addObject:temp3];
                    UIImage *mask = [self getBlankMask:temp2.size];
                    [undoImages addObject:mask];
                   // testImage1.image = temp2;//[undoImages lastObject];
                }
            }
        }
        [cropMainView setHidden:YES];
        [eraseMainView setHidden:NO];
        [self.eraseMainView bringSubviewToFront:grabcutView];
        [sizeMainView setHidden:YES];
        selectedView = selectedSegment;
        
        [self handleEraseViewSingleTap];
        if(img.isEdited){
            [grabcutView setFrame:grabcutFrame];
            grabcutView.image = [[self foregroundEraseImages]objectAtIndex:selectedforegroundimage];
            [grabCutController setImage:grabcutView.image];
            [self calculateScale];
        }else if (!img.isEdited && img.minZoomScale!=0){
            [grabcutView setFrame:grabcutFrame];
            grabcutView.image = img.thumbimage;
            [grabCutController setImage:grabcutView.image];
            [self calculateScale];
        }
        else{
            [grabcutView setFrame:grabcutFrame];
            grabcutView.image = ((STImage*)[[self foregroundEraseImages]objectAtIndex:selectedforegroundimage]).orgImage;
            [grabCutController setImage:grabcutView.image];
            [self calculateScale];
        }
        if(isEditing){
            isEditing = NO;
        }
    }
    else{
        [cropMainView setHidden:YES];
        [eraseMainView setHidden:YES];
        [sizeMainView setHidden:NO];
        selectedView = selectedSegment;
        
        sizeView.image = img.thumbimage;
        CGRect frame = sizeView.frame;
        frame.size.width = img.sizeScale;
        frame.size.height = img.sizeScale;
        [sizeView setFrame:frame];
        [sizeView setCenter:centerPoint];
        slider.maximumValue = 269;
        slider.minimumValue = 24;
        slider.value = img.sizeScale;
        
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
    zoomrect = CGRectMake(0, 0,self.cropforegroundImage.frame.size.width, self.cropforegroundImage.frame.size.height);
    return zoomrect;
}

- (UIImage *) getBlankMask:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

- (IBAction)undoGrabcut:(id)sender {
    if(isEditing)
    {
        STImage *test = [[croppedImages[selectedforegroundimage] lastObject] objectForKey:@"image"];
        UIImage *mask = [undoImages[selectedforegroundimage] lastObject];
        {
            const float colorMasking = *CGColorGetComponents([UIColor blackColor].CGColor); //{1.0, 1.0, 0.0, 0.0, 1.0, 1.0};
            mask = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(mask.CGImage, &colorMasking)];
            grabcutView.image = [self maskImage:test withMask:mask];
            testImage.image = mask;
            testImage1.image = test;
        }
        isEditing = NO;
        [grabCutController restoreMask];
        return;
    }
    if([undoImages[selectedforegroundimage] count]>1){
        int count = [undoImages[selectedforegroundimage] count];
        if([[[croppedImages[selectedforegroundimage] lastObject] objectForKey:@"count"] intValue] == count-1)
            [croppedImages[selectedforegroundimage] removeLastObject];
        UIImage *test = [[croppedImages[selectedforegroundimage] lastObject] objectForKey:@"image"];
        UIImage *mask = [undoImages[selectedforegroundimage] objectAtIndex:count-2];
        {
            const float colorMasking = *CGColorGetComponents([UIColor blackColor].CGColor); //{1.0, 1.0, 0.0, 0.0, 1.0, 1.0};
            mask = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(mask.CGImage, &colorMasking)];
            grabcutView.image = [self maskImage:test withMask:mask];
            testImage1.image = mask;
            lastEdit = grabcutView.image;
            [self calculateScale];
            [grabCutController setImage:grabcutView.image];
        }
        [undoImages[selectedforegroundimage] removeLastObject];
        STImage *temp = (STImage*)[self foregroundimages][selectedforegroundimage];
        [temp.masks removeLastObject];
        [temp.maskImgs removeLastObject];
        [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:temp];
        STImage *temp1 = (STImage*)[self foregroundEraseImages][selectedforegroundimage];
        [temp1.masks removeLastObject];
        [temp1.maskImgs removeLastObject];
        [[self foregroundEraseImages]replaceObjectAtIndex:selectedforegroundimage withObject:temp1];
    }
    else
    {
        [undoImages[selectedforegroundimage] removeAllObjects];
        [undoBtn setEnabled:NO];
        [undoBtn setAlpha:0.5];
        STImage *img = [[self foregroundEraseImages]objectAtIndex:selectedforegroundimage];
        STImage *img1 = [[STImage alloc] initWithCGImage:img.orgImage.CGImage];
        img1.listDisplayOrder = img.listDisplayOrder;
        img1.fileType = img.fileType;
        img1.type = img.type;
        img1.sizeX = img.sizeX;
        img1.sizeY = img.sizeY;
        img1.orgImage = img.orgImage;
        img1.sizeScale = img.sizeScale;
        img1.isEdited = NO;
        img1.defaultScale = img.defaultScale;
        img1.minZoomScale = img.minZoomScale;
        img1.defaultX = img.defaultX;
        img1.defaultY = img.defaultY;
        img1.masks = img.masks;
        img1.maskImgs = img.maskImgs;
        grabcutView.image = [[croppedImages[selectedforegroundimage] lastObject] objectForKey:@"image"];
        //[croppedImages[selectedforegroundimage] removeLastObject];
        
        [img1 setThumbimage:[self updateEraseThumbImage]];
        grabCutController = [[CvGrabCutController alloc] init];
        [grabCutController setImage:grabcutView.image];
        [self calculateScale];
        [self.foregroundEraseImages replaceObjectAtIndex:selectedforegroundimage withObject:img1];
        
        
        img =  [[self foregroundimages] objectAtIndex:selectedforegroundimage];
        img1 = [[STImage alloc]initWithCGImage:img.orgImage.CGImage];
        img1.listDisplayOrder = img.listDisplayOrder;
        img1.fileType = img.fileType;
        img1.type = img.type;
        img1.sizeX = img.sizeX;
        img1.sizeY = img.sizeY;
        img1.orgImage = img.orgImage;
        img1.sizeScale = img.sizeScale;
        img1.isEdited = NO;
        img1.defaultScale = img.defaultScale;
        img1.minZoomScale = img.minZoomScale;
        img1.defaultX = img.defaultX;
        img1.defaultY = img.defaultY;
        img1.masks = img.masks;
        img1.maskImgs = img.maskImgs;
        [img1 setThumbimage:[self updateEraseThumbImage]];
        [self cropforegroundImage].image = img1;
        [self sizeView].image = img1;
        [self.foregroundimages replaceObjectAtIndex:selectedforegroundimage withObject:img1];
        
        [applyBtn setEnabled:YES];
    }
    
    isEditing = NO;
    
}

- (IBAction)sliderChanged:(id)sender {
    
    CGRect frame = sizeView.frame;
    frame.size.width = slider.value;
    frame.size.height = slider.value;
    sizeView.frame = frame;
    [sizeView setCenter:centerPoint];
    NSLog(@"%f,%f",sizeView.center.x,sizeView.center.y);
    NSLog(@"slider value is %f",slider.value);
    NSLog(@"frame width is %f",sizeView.frame.size.width);
    NSLog(@"bounds  is %f", sizeView.bounds.size.width);
    
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
