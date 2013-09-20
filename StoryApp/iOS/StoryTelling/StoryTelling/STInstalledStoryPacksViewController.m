//
//  STInstalledStoryPacksViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 12/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STInstalledStoryPacksViewController.h"
#import "CreateStoryRootViewController.h"
//
#import "NSData+Base64.h"
#define THUMB_HEIGHT 80
#define THUMB_V_PADDING 6
#define THUMB_H_PADDING 8

@interface STInstalledStoryPacksViewController ()

@end

@implementation STInstalledStoryPacksViewController

@synthesize backgroundImagesView;
@synthesize foregroundImagesView;
@synthesize installedStoryPackName;
@synthesize filePath;

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
    [self.navigationItem setHidesBackButton:NO]; //do Yes and activate done button after testing..
    
    
    [self.navigationItem setTitle:@"Select Images To Use"];
    //initializing DB.
    [self performSelectorOnMainThread:@selector(initializeDB) withObject:nil waitUntilDone:YES];
    //loading bg and fg images.
    [self performSelectorInBackground:@selector(loadBGImages) withObject:nil];
    

    
    [self performSelectorInBackground:@selector(loadFGImages) withObject:nil];
    //done button.
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
//    [self.navigationItem setRightBarButtonItem:doneButton];
    
    
}
- (void)initializeDB {

    NSLog(@"sqLiteDb = %@",filePath);
        if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
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
//            const void *ptr = sqlite3_column_blob(statement, 0);
//            int size = sqlite3_column_bytes(statement, 0);
//            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
        //from db
            NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
        //base64_encode local test
//            NSError * error;
//            NSString *dataAsString = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://192.168.1.205/sajin/test2/iphone/connection.php"] encoding:NSUTF8StringEncoding error:&error];
            NSData *data = [NSData dataFromBase64String:dataAsString];
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
            UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]];
            frame.origin.x = 0;
            frame.origin.y = 0;
            [checkmarkImageView setFrame:frame];
            [thumbView addSubview:checkmarkImageView];
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
//            const void *ptr = sqlite3_column_blob(statement, 0);
//            int size = sqlite3_column_bytes(statement, 0);
//            NSData *data = [[NSData alloc] initWithBytes:ptr length:size];
        //from db
            NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
        //base64_encode local test
//            NSError * error;
//            NSString *dataAsString = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://192.168.1.205/sajin/test2/iphone/connection.php"] encoding:NSUTF8StringEncoding error:&error];
            NSData *data = [NSData dataFromBase64String:dataAsString];
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
            UIImageView *checkmarkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]];
            frame.origin.x = 0;
            frame.origin.y = 0;
            [checkmarkImageView setFrame:frame];
            [thumbView addSubview:checkmarkImageView];
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
