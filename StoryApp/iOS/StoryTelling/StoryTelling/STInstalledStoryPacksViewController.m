//
//  STInstalledStoryPacksViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 12/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STInstalledStoryPacksViewController.h"
#import "CreateStoryRootViewController.h"

#define THUMB_HEIGHT 80
#define THUMB_V_PADDING 6
#define THUMB_H_PADDING 8

@interface STInstalledStoryPacksViewController ()

@end

@implementation STInstalledStoryPacksViewController

@synthesize backgroundImagesView;
@synthesize foregroundImagesView;
@synthesize installedStoryPackName;

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
    
    //for testing
    [self.navigationItem setHidesBackButton:NO]; //do Yes and activate done button.
    
    
    [self.navigationItem setTitle:@"Select Images To Use"];
    //initializing DB.
    [self performSelectorOnMainThread:@selector(initializeDB) withObject:nil waitUntilDone:YES];
    //loading bg and fg images.
    [self performSelectorInBackground:@selector(loadBGImages) withObject:nil];
    

    
//    [self performSelectorInBackground:@selector(loadFGImages) withObject:nil];
    //done button.
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
//    [self.navigationItem setRightBarButtonItem:doneButton];
    
    
}
- (void)initializeDB {
    NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:filePath ofType:@"sqlite3"];
    NSLog(@"sqLiteDb = %@",sqLiteDb);
        if (sqlite3_open([sqLiteDb UTF8String], &database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
}

-(void)loadBGImages
{
    NSString *query = @"SELECT ImageDataPNG, ImageType, DefaultScale  FROM Images WHERE ImageType='Background'";
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
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW){
            ////////////////////////////////////////////
                        
            NSData* data = (__bridge NSData*) sqlite3_column_blob(statement, 0);
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
            [backgroundImagesHolder addSubview:thumbView];
            [backgroundImagesView addSubview:backgroundImagesHolder];
            xPosition += (frame.size.width + THUMB_H_PADDING);
        }
        [backgroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
        [backgroundImagesView addSubview:backgroundImagesHolder];
            ////////////////////////////////////////////
        }
}


-(void)loadFGImages
{
    NSString *query = @"SELECT ImageDataPNG, ImageType, DefaultScale  FROM Images WHERE ImageType='Foreground'";
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
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)
        == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW){
            ////////////////////////////////////////////
            
            NSData* data = (__bridge NSData*) sqlite3_column_blob(statement, 0);
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
            [foregroundImagesView addSubview:foregroundImagesHolder];
            xPosition += (frame.size.width + THUMB_H_PADDING);
        }
        [foregroundImagesHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
        [foregroundImagesView addSubview:foregroundImagesHolder];
        ////////////////////////////////////////////
    }
    
}

-(void)doneButtonPressed
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
