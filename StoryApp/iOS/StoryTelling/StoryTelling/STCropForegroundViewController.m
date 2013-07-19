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
bool eraseMode = NO;

@synthesize foregroundimagesView;
@synthesize sizePicker;
@synthesize sizePickerOutlet;

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
    [[self mainScrollView] setContentSize:CGSizeMake(320, 1150)];
    sizePicker = [[NSArray alloc]initWithObjects:@"Small",@"Medium",@"Large", nil];
    [[self sizePickerOutlet ] setFrame:CGRectMake(sizePickerOutlet.frame.origin.x, sizePickerOutlet.frame.origin.y, sizePickerOutlet.frame.size.width, sizePickerOutlet.frame.size.height-100)];
    [self clearScrollView];
    [self reloadForegroundImagesView];
    [self prepareScrollView];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    [self setMainScrollView:nil];
    [self setSizePickerOutlet:nil];
    [self setEraseBtn:nil];
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
    self.cropforegroundImage = [[STEraseImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:0]];
    //[self.cropforegroundImage setUserInteractionEnabled:YES];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    
}

-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    //NSLog(@"%d",selectedforegroundimage);
    STImage *img = [[self foregroundimages]objectAtIndex:selectedforegroundimage];
    CGFloat currentScale = self.cropforegroundImage.frame.size.width / self.cropforegroundImage.bounds.size.width;
    [img setDefaultScale:currentScale];
    [img setMinZoomScale:[self.cropView minimumZoomScale]];
    [img setDefaultX:[self cropView].contentOffset.x];
    [img setDefaultY:[self cropView].contentOffset.y];
    [img setThumbimage:[self updateThumbImage]];
    [[self foregroundimages]replaceObjectAtIndex:selectedforegroundimage withObject:img];
    selectedforegroundimage = recognizer.view.tag;
    [self clearScrollView];
    self.cropforegroundImage = [[STEraseImageView alloc] initWithImage:[[self foregroundimages]objectAtIndex:recognizer.view.tag]];
    //[self.cropforegroundImage setUserInteractionEnabled:YES];
    [self.cropforegroundImage setContentMode:UIViewContentModeScaleAspectFill];
    [self.cropView addSubview:self.cropforegroundImage];
    [self prepareScrollView];
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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [sizePicker count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    title=[sizePicker objectAtIndex:row];
    return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

- (IBAction)erasePressed:(id)sender
{
    eraseMode = !eraseMode;
    if(eraseMode){
        [self.cropView setScrollEnabled:NO];
        [self.cropView setDelaysContentTouches:NO];
        [self.cropView setMultipleTouchEnabled:NO];
        [self.cropforegroundImage setUserInteractionEnabled:YES];
    }
    else{
        [self.cropView setScrollEnabled:YES];
        [self.cropView setDelaysContentTouches:YES];
        [self.cropView setMultipleTouchEnabled:YES];
        [self.cropforegroundImage setUserInteractionEnabled:NO];
    }
}

@end
