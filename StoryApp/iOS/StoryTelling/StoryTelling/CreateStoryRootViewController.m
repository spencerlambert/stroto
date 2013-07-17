//
//  CreateStoryRootViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "CreateStoryRootViewController.h"
#import "WorkAreaController.h"
#import "STImage.h"

#define THUMB_HEIGHT 60
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10

@interface CreateStoryRootViewController ()

@end

@implementation CreateStoryRootViewController

@synthesize backgroundImages;
@synthesize foregroundImages;
@synthesize storyNameTextField;
@synthesize BackgroundImagesView;
@synthesize ForegroundImagesView;
@synthesize imagesDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.tag=20;
}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    imagesDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if([imagesDelegate.isNewStory isEqual: @"true"]){
       // [self setBackgroundImages:[[NSMutableArray alloc]init]];
      //  [self setForegroundImages:[[NSMutableArray alloc]init]];
        [imagesDelegate setBackgroundImagesArray:[[NSMutableArray alloc]init]];
        [imagesDelegate setForegroundImagesArray:[[NSMutableArray alloc]init]];
        [imagesDelegate setIsNewStory:@"false"];
        
    }else{
    backgroundImages = [[NSMutableArray alloc]initWithArray:imagesDelegate.backgroundImagesArray];
    foregroundImages = [[NSMutableArray alloc]initWithArray:imagesDelegate.foregroundImagesArray];
    }
    [self reloadBackgroundImagesView];
    [self reloadForegroundImagesView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL) createStoryDirectories:(NSString *)storyName{
    
    return YES;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [segue.destinationViewController setDelegate:self];
}

- (void) reloadBackgroundImagesView{
    float scrollViewHeight = THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [BackgroundImagesView bounds].size.width;
    UIScrollView *BackgroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [BackgroundImagesHolder setCanCancelContentTouches:NO];
    [BackgroundImagesHolder setClipsToBounds:YES];
    
    float xPosition = THUMB_H_PADDING;
    
//    for (NSMutableDictionary *imageDictionary in backgroundImages) {
//        UIImage *thumbImage = [imageDictionary objectForKey:@"UIImagePickerControllerThumbnailImage"];
//        if (thumbImage) {
//            thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
//                                             scale:(thumbImage.scale * 2.4)
//                                       orientation:(thumbImage.imageOrientation)];
//            UIImageView *thumbView = [[UIImageView alloc] initWithImage:thumbImage ];
//            CGRect frame = [thumbView frame];
//            frame.origin.y = THUMB_V_PADDING;
//            frame.origin.x = xPosition;
//            [thumbView setFrame:frame];
//            //thumbView.contentMode = UIViewContentModeScaleAspectFit;
//            [thumbView setClipsToBounds:YES];
//            [BackgroundImagesHolder addSubview:thumbView];
//            xPosition += (frame.size.width + THUMB_H_PADDING);
//        }
//    }
    
    for (int i = 0; i<[[self backgroundImages]count];i++) {
        STImage *stimage = [[self backgroundImages]objectAtIndex:i];
        UIImage *thumbImage = [stimage thumbimage];
        thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
                                         scale:(thumbImage.scale * 1.4)
                                   orientation:(thumbImage.imageOrientation)];
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:thumbImage ];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;
        frame.size.width = 50;
        frame.size.height = 50;
        [thumbView setFrame:frame];
        [thumbView setTag:i];
        [BackgroundImagesHolder addSubview:thumbView];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    
    [BackgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in BackgroundImagesView.subviews){
        [view removeFromSuperview];
    }
    [BackgroundImagesView addSubview:BackgroundImagesHolder];
    
}
-(void)resigngTxtField{
    [self.storyNameTextField resignFirstResponder];
}

- (IBAction)backButtonClicked:(UIBarButtonItem *)sender {
    if(([backgroundImages count]>0)||([foregroundImages count]>0)||([storyNameTextField.text length]>0)){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"You have an un-saved project.What would you like to do?" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Clear" , nil];
        //  [alert setBackgroundColor:[UIColor blackColor]];
        [alert show];
        
    }
    else{
        id object=nil;
        for (UIViewController *viewControl in self.navigationController.viewControllers)
        {
            NSLog(@"The tag value is:%d",viewControl.view.tag);
            if(viewControl.view.tag==100)
            {
                object = viewControl;
            }
        }
        [self.navigationController popToViewController:object animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.storyNameTextField resignFirstResponder];
    return  YES;
}

- (void) reloadForegroundImagesView{
    float scrollViewHeight = [ForegroundImagesView bounds].size.width; //THUMB_HEIGHT + THUMB_V_PADDING;
    float scrollViewWidth  = [ForegroundImagesView bounds].size.width;
    UIScrollView *ForegroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [ForegroundImagesHolder setCanCancelContentTouches:NO];
    [ForegroundImagesHolder setClipsToBounds:YES];
    
    float xPosition = THUMB_H_PADDING;
    
//    for (NSMutableDictionary *imageDictionary in foregroundImages) {
//        UIImage *thumbImage = [imageDictionary objectForKey:@"UIImagePickerControllerThumbnailImage"];
//        if (thumbImage) {
//            thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
//                                             scale:(thumbImage.scale * 2.4)
//                                       orientation:(thumbImage.imageOrientation)];
//            UIImageView *thumbView = [[UIImageView alloc] initWithImage:thumbImage ];
//            CGRect frame = [thumbView frame];
//            frame.origin.y = THUMB_V_PADDING;
//            frame.origin.x = xPosition;
//            [thumbView setFrame:frame];
//            //thumbView.contentMode = UIViewContentModeScaleAspectFit;
//            [thumbView setClipsToBounds:YES];
//            [ForegroundImagesHolder addSubview:thumbView];
//            xPosition += (frame.size.width + THUMB_H_PADDING);
//        }
//    }
    
    for (int i = 0; i<[[self foregroundImages]count];i++) {
        STImage *stimage = [[self foregroundImages]objectAtIndex:i];
        UIImage *thumbImage = [stimage thumbimage];
        thumbImage = [UIImage imageWithCGImage:[thumbImage CGImage]
                                         scale:(thumbImage.scale * 1.4)
                                   orientation:(thumbImage.imageOrientation)];
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:thumbImage ];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;
        frame.size.width = 50;
        frame.size.height = 50;
        [thumbView setFrame:frame];
        [thumbView setTag:i];
        [ForegroundImagesHolder addSubview:thumbView];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }

    [ForegroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    for(UIView *view in ForegroundImagesView.subviews){
        [view removeFromSuperview];
    }
    [ForegroundImagesView addSubview:ForegroundImagesHolder];
}

- (void)setbackgroundimages:(NSMutableArray *)info{
    self.backgroundImages = info;
    
}

- (void)setforegroundimages:(NSMutableArray *)info{
    self.foregroundImages = info;
}

- (IBAction)nextButtonClicked:(id)sender{
    WorkAreaController *workarea =
    [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"workarea"];
    [workarea setBackgroundImages:backgroundImages];
    [workarea setForegroundImages:foregroundImages];
    [workarea setStoryname:[storyNameTextField text]];
    [self presentViewController:workarea animated:YES completion:nil];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0){
        //continue button clicked
        
    }
    else{
        //clear button clicked
        id object=nil;
        for (UIViewController *viewControl in self.navigationController.viewControllers)
        {
            NSLog(@"The tag value is:%d",viewControl.view.tag);
            if(viewControl.view.tag==100)
            {
                object = viewControl;
            }
        }
        [self.navigationController popToViewController:object animated:YES];
    }
}


@end
