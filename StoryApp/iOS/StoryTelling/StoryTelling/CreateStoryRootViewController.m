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


#define THUMB_HEIGHT 70
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10

@interface CreateStoryRootViewController ()

@end

@implementation CreateStoryRootViewController{
    STStoryDB *newStory;
}

@synthesize backgroundImages;
@synthesize foregroundImages;
@synthesize storyNameTextField;
@synthesize BackgroundImagesView;
@synthesize ForegroundImagesView;
@synthesize imagesDelegate;
@synthesize isEditStory;
@synthesize dbname;
bool nextButtonClicked = NO;

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
    
    if (!isEditStory) {
        CGSize storySize = [AppDelegate deviceSize];
        newStory = [STStoryDB createNewSTstoryDB:storySize];
        NSDateFormatter *dateTimeFormat = [[NSDateFormatter alloc] init];
        [dateTimeFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [[NSDate alloc] init];
        NSString *dateTime = [dateTimeFormat stringFromDate:now];
        //NSLog(@"Title is %@", dateTime );
        [storyNameTextField setText:dateTime];
        [newStory updateDisplayName:dateTime];
    }
    else{
        newStory = [STStoryDB loadSTstoryDB:dbname];
        [storyNameTextField setText:[newStory getStoryName]];
        imagesDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        imagesDelegate.backgroundImagesArray = [[NSMutableArray alloc]initWithArray:[newStory getBackgroundImagesSorted]];
        imagesDelegate.foregroundImagesArray = [[NSMutableArray alloc]initWithArray:[newStory getForegroundImagesSorted]];
        [imagesDelegate setIsNewStory:@"false"];
    }
}

- (void) navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    [self updateDB];
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL) navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    return YES;
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
    
    if([segue.identifier isEqualToString:@"workarea"])
    {
        nextButtonClicked = YES;
        [self updateDB];
        WorkAreaController *workarea = segue.destinationViewController;
        //    [workarea setBackgroundImages:backgroundImages];
        //    [workarea setForegroundImages:foregroundImages];
        [workarea setStoryname:[storyNameTextField text]];
        [workarea setStoryDB:newStory];
        [workarea setMydelegate:self];
    }
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
        frame.size.width = THUMB_HEIGHT;
        frame.size.height = THUMB_HEIGHT;
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

- (void)backButtonClicked {
    //    if(([backgroundImages count]>0)||([foregroundImages count]>0)||([storyNameTextField.text length]>0)){
    //        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"You have an un-saved project.What would you like to do?" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:@"Clear" , nil];
    //    [alert show];
    //
    //    }
    //    else{
    //        [newStory deleteSTstoryDB];
//    [self updateDB];
    [self.navigationController popViewControllerAnimated:YES];
    //            }
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
        [thumbView setContentMode:UIViewContentModeScaleAspectFit];
        CGRect frame = [thumbView frame];
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;
        frame.size.width = THUMB_HEIGHT;
        frame.size.height = THUMB_HEIGHT;
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
//    [self updateDB];
//    WorkAreaController *workarea =
//    [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
//                               bundle:NULL] instantiateViewControllerWithIdentifier:@"workarea"];
//    //    [workarea setBackgroundImages:backgroundImages];
//    //    [workarea setForegroundImages:foregroundImages];
//    [workarea setStoryname:[storyNameTextField text]];
//    [workarea setStoryDB:newStory];
//    [workarea setMydelegate:self];
//    [self.navigationController pushViewController:workarea animated:YES];
//    [self presentViewController:workarea animated:YES completion:nil];
    
}
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if(buttonIndex==1){
//        //clear button clicked
//        [newStory deleteSTstoryDB];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//}

- (void)updateDB{
    [newStory updateDisplayName:storyNameTextField.text];
    for(STImage *image in backgroundImages){
        if(image.imageId == 0){
            [newStory addImage:image];
        }else{
            [newStory updateImage:image];
        }
    }
    for (STImage *image in foregroundImages) {
        if(image.imageId == 0){
            [newStory addImage:image];
        }else{
            [newStory updateImage:image];
        }
    }
}

-(void)finishedRecording{
    [newStory closeDB];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
