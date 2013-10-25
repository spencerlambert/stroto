//
//  STSelectImagesFromStoryViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STSelectImagesFromStoryViewController.h"
#import "CreateStoryRootViewController.h"
#import "AppDelegate.h"

#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 250 : 80)
#define THUMB_V_PADDING (IS_IPAD ? 12 : 6)
#define THUMB_H_PADDING 8

@interface STSelectImagesFromStoryViewController ()

@end

@implementation STSelectImagesFromStoryViewController
@synthesize storyNameLabel;
@synthesize backgroundImagesView;
@synthesize foregroundImagesView;
@synthesize dbLocation;
@synthesize storyNameLabelText;

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:NO];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    [self.navigationItem setRightBarButtonItem:doneButton];
    [self initializeDB];
}
-(void)initializeDB
{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    docsDir = dirPaths[0];
    //story directory
    NSString *storyDir = [docsDir stringByAppendingPathComponent:@"story_dir/"];
    NSString *databasePath = [storyDir stringByAppendingPathComponent:dbLocation];
    NSLog(@"sqLiteDb = %@",databasePath);
    int code = sqlite3_open_v2([databasePath UTF8String], &database,SQLITE_OPEN_READWRITE,NULL);
    if (code != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
    else{
        NSLog(@"DB Successfully Initialized with code : %d", code);
        [self.storyNameLabel setText:self.storyNameLabelText];
        [self performSelectorInBackground:@selector(loadBGImages) withObject:nil];
        }
}
-(void)loadBGImages
{
    NSString *query = @"SELECT imageData  FROM Image WHERE type='background';";
    sqlite3_stmt *statement;
    float scrollViewHeight = [backgroundImagesView bounds].size.height;
    float scrollViewWidth  = [backgroundImagesView bounds].size.width;
    float xPosition = THUMB_H_PADDING;
    UIScrollView *backgroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [backgroundImagesHolder setUserInteractionEnabled:YES];
    backgroundImagesHolder.tag = 1;
    [backgroundImagesHolder setCanCancelContentTouches:NO];
    [backgroundImagesHolder setClipsToBounds:NO];
    for(UIView *view in backgroundImagesView.subviews)
        [view removeFromSuperview];
    [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [backgroundImagesHolder setHidden:NO];
    [backgroundImagesView addSubview:backgroundImagesHolder];
    switch (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil))
    {
        case SQLITE_OK:
            NSLog(@"SQLITE_OK");
            
            NSLog(@"Inside BG SQLITE_OK ");    //    NSLog(@"sql statement for background : %@",statement);
            while (sqlite3_step(statement) == SQLITE_ROW){
                ////////////////////////////////////////////
                            const void *ptr = sqlite3_column_blob(statement, 0);
                            int size = sqlite3_column_bytes(statement, 0);
                            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
                                UIImage *image = [UIImage imageWithData:data];
                STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
                //showing installed story pack's thubnail images
                UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
                CGRect frame = [thumbView frame];
                [thumbView setContentMode:UIViewContentModeScaleAspectFit];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;//thumb_H_padding
                frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
                frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
                [thumbView setFrame:frame];
                [thumbView setUserInteractionEnabled:YES];
                [thumbView setHidden:NO];
                //selecting images for use.
                UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Overlay.png"]];
                frame.origin.x = 0;
                frame.origin.y = 0;
                [checkmarkImageView setFrame:frame];
                
                //Adding tap for checkmark
                checkmarkImageView.tag =2;
                UITapGestureRecognizer *checkmarkClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
                checkmarkClick.numberOfTapsRequired = 1;
                [checkmarkImageView addGestureRecognizer:checkmarkClick];
                [checkmarkImageView setUserInteractionEnabled:YES];
                [thumbView addSubview:checkmarkImageView];
                //Adding tap for bg images
                thumbView.tag = 1;
                //            [selectedBGImages addObject:thumbView.image];
                UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
                imageClick.numberOfTapsRequired = 1;
                [thumbView addGestureRecognizer:imageClick];
                [backgroundImagesHolder addSubview:thumbView];
                [backgroundImagesView addSubview:backgroundImagesHolder];
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
            [backgroundImagesHolder setTag:100];
            [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
            [backgroundImagesView addSubview:backgroundImagesHolder];
            
            break;
        case SQLITE_ERROR:
            
            NSLog(@"SQLITE_ERROR : %d", sqlite3_step(statement));
            break;
            
        case SQLITE_INTERNAL:
            NSLog(@"SQLITE_INTERNAL");
            break;
            
        case SQLITE_BUSY:
            NSLog(@"SQLITE_BUSY");
            break;
            
        case SQLITE_MISMATCH:
            NSLog(@"SQLITE_MISMATCH");
            break;
        default:
            NSLog(@"Default...");
            break;
    }
    [self performSelectorInBackground:@selector(loadFGImages) withObject:nil];
}

-(void)loadFGImages
{
    NSString *query = @"SELECT imageData  FROM Image WHERE type='foreground';";
    
    sqlite3_stmt *statement;
    float scrollViewHeight = [foregroundImagesView bounds].size.height;
    float scrollViewWidth  = [foregroundImagesView bounds].size.width;
    float xPosition = THUMB_H_PADDING;
    UIScrollView *foregroundImagesHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [foregroundImagesHolder setUserInteractionEnabled:YES];
    foregroundImagesHolder.tag = 1;
    [foregroundImagesHolder setCanCancelContentTouches:NO];
    [foregroundImagesHolder setClipsToBounds:NO];
    for(UIView *view in foregroundImagesView.subviews)
        [view removeFromSuperview];
    [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [foregroundImagesHolder setHidden:NO];
    [foregroundImagesView addSubview:foregroundImagesHolder];
    switch (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil))
    {
        case SQLITE_OK:
            NSLog(@"SQLITE_OK");
            
            NSLog(@"Inside FG SQLITE_OK ");
            while (sqlite3_step(statement) == SQLITE_ROW){
                ////////////////////////////////////////////
                            const void *ptr = sqlite3_column_blob(statement, 0);
                            int size = sqlite3_column_bytes(statement, 0);
                            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
                                UIImage *image = [UIImage imageWithData:data];
                STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
                //showing installed story pack's thubnail images
                UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
                CGRect frame = [thumbView frame];
                [thumbView setContentMode:UIViewContentModeScaleAspectFit];
                frame.origin.y = THUMB_V_PADDING;
                frame.origin.x = xPosition;//thumb_H_padding
                frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
                frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
                [thumbView setFrame:frame];
                [thumbView setUserInteractionEnabled:YES];
                [thumbView setHidden:NO];
                [foregroundImagesHolder addSubview:thumbView];
                //selecting images for use.
                UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Overlay.png"]];
                frame.origin.x = 0;
                frame.origin.y = 0;
                [checkmarkImageView setFrame:frame];
                //Adding tap for checkmark
                checkmarkImageView.tag =2;
                UITapGestureRecognizer *checkmarkClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
                checkmarkClick.numberOfTapsRequired = 1;
                [checkmarkImageView addGestureRecognizer:checkmarkClick];
                [checkmarkImageView setUserInteractionEnabled:YES];
                [thumbView addSubview:checkmarkImageView];
                //Adding tap for bg images
                thumbView.tag = 1;
                //            [selectedFGImages addObject:thumbView.image];
                UITapGestureRecognizer *imageClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
                imageClick.numberOfTapsRequired = 1;
                [thumbView addGestureRecognizer:imageClick];
                [thumbView addSubview:checkmarkImageView];
                [foregroundImagesView addSubview:foregroundImagesHolder];
                xPosition += (frame.size.width + THUMB_H_PADDING);
            }
            [foregroundImagesHolder setTag:101];
            [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
            [foregroundImagesView addSubview:foregroundImagesHolder];
            
            break;
        case SQLITE_ERROR:
            NSLog(@"SQLITE_ERROR");
            
            NSLog(@"SQLITE_ERROR : %d", sqlite3_step(statement));
            break;
            
        case SQLITE_INTERNAL:
            NSLog(@"SQLITE_INTERNAL");
            break;
            
        case SQLITE_BUSY:
            NSLog(@"SQLITE_BUSY");
            break;
            
        case SQLITE_MISMATCH:
            NSLog(@"SQLITE_MISMATCH");
            break;
        default:
            NSLog(@"Default...");
            break;
    }
    
}
-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    if(recognizer.view.tag == 2)
    {
        //        [recognizer.view setTag:0];
        [recognizer.view.superview setTag:0];
        [recognizer.view setHidden:YES];
        
    }
    else if (recognizer.view.tag == 0)
    {
        recognizer.view.tag = 1;
        [recognizer.view.subviews[0] setTag:2];
        [recognizer.view.subviews[0] setHidden:NO];
    }
}
-(void)doneButtonPressed
{
    selectedFGImages = [[NSMutableArray alloc]init];
    selectedBGImages = [[NSMutableArray alloc]init];
    UIScrollView *foregroundImagesHolder = (UIScrollView *)[self.view viewWithTag:101];
    UIScrollView *backgroundImagesHolder = (UIScrollView *)[self.view viewWithTag:100];
    NSLog(@"fgholder : %@",foregroundImagesHolder);
    NSLog(@"bgholder : %@",backgroundImagesHolder);
    
    for(UIView * demo in foregroundImagesHolder.subviews)
    {
        if([demo class]== [UIImageView class])
        {
            if(demo.tag == 1)
            {
                UIImageView* fg = (UIImageView *)demo;
                NSLog(@"fg.image : %@",fg.image);
                [selectedFGImages addObject:fg.image];
            }
        }
    }
    
    for(UIView * demo in backgroundImagesHolder.subviews)
    {
        if([demo class]== [UIImageView class])
        {
            if(demo.tag == 1)
            {
                UIImageView* bg = (UIImageView *)demo;
                NSLog(@"bg.image : %@",bg);
                [selectedBGImages addObject:bg.image];
            }
        }
    }
    [self convertToSTImage];
    NSLog(@"selected fg : %@",selectedFGImages);
    NSLog(@"selected bg : %@",selectedBGImages);
    AppDelegate *imagesDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [imagesDelegate.foregroundImagesArray addObjectsFromArray:selectedFGImages];
    [imagesDelegate.backgroundImagesArray addObjectsFromArray:selectedBGImages];
    [self.navigationController popToViewController:[self getCreateStoryController] animated:YES];
    
}
-(void)convertToSTImage{
    
    int count = 0;
    NSMutableArray *stFGImages = [[NSMutableArray alloc]init];
    NSMutableArray *stBGImages = [[NSMutableArray alloc]init];
    for(UIImage *Image  in selectedFGImages){
        NSLog(@"FG IMAGE : %@",Image);
        STImage *stimage = [[STImage alloc] initWithCGImage:[Image CGImage]];
        [stimage setThumbimage:Image];
        [stimage setFileType:@"PNG"];
        [stimage setType:@"foreground"];
        [stimage setListDisplayOrder:count++];
        [stFGImages addObject:stimage];
    }
    selectedFGImages = stFGImages ;
    for(UIImage *Image  in selectedBGImages){
        NSLog(@"BG IMAGE : %@",Image);
        STImage *stimage = [[STImage alloc] initWithCGImage:[Image CGImage]];
        [stimage setThumbimage:Image];
        [stimage setFileType:@"PNG"];
        [stimage setType:@"background"];
        [stimage setListDisplayOrder:count++];
        [stBGImages addObject:stimage];
    }
    selectedBGImages = stBGImages;
}

- (UIViewController *) getCreateStoryController
{
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:[CreateStoryRootViewController class]]) {
            return temp;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setStoryNameLabel:nil];
    [self setBackgroundImagesView:nil];
    [self setForegroundImagesView:nil];
    [super viewDidUnload];
}
@end
