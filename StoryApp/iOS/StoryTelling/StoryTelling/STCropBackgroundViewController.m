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

#define THUMB_HEIGHT 60
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
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self convertToSTImage];
    [self reloadBackgroundImagesView];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackgroundimagesView:nil];
    [self setCropView:nil];
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
        frame.size.width = thumbImage.size.width;
        frame.size.height = thumbImage.size.height;
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
    [self.cropbackgroundImage setImage:[[self backgroundimages] objectAtIndex:0]];
    
}

-(void)handleSingleTap:(UIGestureRecognizer *)recognizer{
    NSLog(@"%d",selectedbackgroundimage);
    STImage *img = [[self backgroundimages]objectAtIndex:selectedbackgroundimage];
    [img setDefaultScale:[self cropView].zoomScale];
    [img setDefaultX:[self cropView].contentOffset.x];
    [img setDefaultY:[self cropView].contentOffset.y];
    [[self backgroundimages]replaceObjectAtIndex:selectedbackgroundimage withObject:img];
    selectedbackgroundimage = recognizer.view.tag;
    [self.cropbackgroundImage setImage:[[self backgroundimages]objectAtIndex:recognizer.view.tag]];
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
    //[self.navigationController popToRootViewControllerAnimated:YES];
    AppDelegate *backgroundImagesDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [backgroundImagesDelegate.backgroundImagesArray addObjectsFromArray:[self backgroundimages]];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}
@end
