//
//  ViewController.m
//  StrotoBasic
//
//  Created by Nandakumar on 29/10/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 320 : 150)
#define THUMB_V_PADDING 15
#define THUMB_H_PADDING (IS_IPAD ? 13 : 6)

#import "ViewController.h"
#import <sqlite3.h>
#import "NSData+Base64.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize storyPacksView;
float scrollViewHeight,scrollViewWidth,xPosition,yPosition;
UIScrollView *storyPacksHolder;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showStoryPacks];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showStoryPacks
{
    NSArray *storyPacksList= [[NSBundle mainBundle] pathsForResourcesOfType:@"db" inDirectory:@"StoryPacks"];
//NSLog(@"StoryPacksList : %@",storyPacksList);
    int count = [storyPacksList count];
NSLog (@"number of story packs :%i",count);
    float holderWidth=0;
    scrollViewHeight = [storyPacksView bounds].size.height;
    scrollViewWidth  = [storyPacksView bounds].size.width;
    xPosition = (IS_IPAD ? 45 : THUMB_H_PADDING);
    yPosition = (IS_IPAD ? 20 : THUMB_V_PADDING);
//    xPosition = 45;
//    yPosition = 20;
    storyPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [storyPacksHolder setBackgroundColor:[UIColor greenColor]];
    [storyPacksHolder setPagingEnabled:YES];
    [storyPacksHolder setBounces:YES];
    storyPacksHolder.tag = 1;
    [storyPacksHolder setCanCancelContentTouches:NO];
    [storyPacksHolder setClipsToBounds:NO];
    for(UIView *view in storyPacksView.subviews)
        [view removeFromSuperview];
    [storyPacksHolder setHidden:NO];
    int i=0;
    int page = 0;
    do
    {
    for(int k=0; k<3; k++)
    {
        for(int j=0; j<2;j++)
        {
        sqlite3 *db;
        if([[[storyPacksList[i] lastPathComponent] pathExtension] isEqualToString:@"db"])
        {
            const char *dbpath = [storyPacksList[i] UTF8String];
//NSLog(@"database path UTF8String: %s",dbpath);
            if (sqlite3_open(dbpath, & db) == SQLITE_OK){
//NSLog(@"storyPacksList[%d] : %@ successfully opened.",i,storyPacksList[i]);
                NSString *sql = [NSString stringWithFormat:@"SELECT Name,ImageDataPNG_Base64 FROM StoryPackInfo;"];
                const char *sql_stmt = [sql UTF8String];
                sqlite3_stmt *compiled_stmt;
                int success =  sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, nil);
//                NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(db), sqlite3_errcode(db));
//                NSLog(@"success : %d",success);
                if(success == SQLITE_OK){
//                    NSLog(@"SQL query Statement preparation on database success.");
                    if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
                        NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(compiled_stmt, 1)];
                        NSData *data = [NSData dataFromBase64String:dataAsString];
                        UIImage *image = [UIImage imageWithData:data];
//                        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
                        UIImageView *thumbView = [[UIImageView alloc] initWithImage:image];
                        CGRect frame = [thumbView frame];
                        [thumbView setContentMode:UIViewContentModeScaleAspectFit];
                        frame.origin.y = yPosition;
                        frame.origin.x = xPosition;//thumb_H_padding
                        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
                        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
                        [thumbView setFrame:frame];
                        [thumbView setUserInteractionEnabled:YES];
                        [thumbView setHidden:NO];
                        //setting tap.
                        [thumbView setTag:i];
                        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
                        click.numberOfTapsRequired = 1;
                        [thumbView addGestureRecognizer:click];
                        [thumbView setUserInteractionEnabled:YES];
                        [storyPacksHolder addSubview:thumbView];
                        xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
                        
                    }
                }
                
                sqlite3_finalize(compiled_stmt);
                sqlite3_close(db);
            }
            NSLog(@"Story i = %d ,\n xPos = %f , ypos = %f",i,xPosition,yPosition);
        }
            i++;
            if(i == count)
                break;
        }
         holderWidth +=xPosition;
//        xPosition = storyPacksView.bounds.size.width * page + THUMB_H_PADDING ;
        xPosition = storyPacksView.bounds.size.width * page + (IS_IPAD ? 45 : THUMB_H_PADDING);
        yPosition += (THUMB_HEIGHT + THUMB_V_PADDING);
//        yPosition += (THUMB_HEIGHT + 30);
        if(i == count)
        {
            break;
        }
}
        {
            page++;
//            xPosition = storyPacksView.bounds.size.width * page + THUMB_H_PADDING ;
            xPosition = storyPacksView.bounds.size.width * page + (IS_IPAD ? 45 : THUMB_H_PADDING) ;
//            yPosition = THUMB_V_PADDING;
            yPosition = (IS_IPAD ? 20 : THUMB_V_PADDING);
        }
//        NSLog(@"Width : %f",storyPacksView.bounds.size.width);
    holderWidth=storyPacksView.bounds.size.width*page;
    }while(page<(count/6));
    [storyPacksHolder setContentSize:CGSizeMake(holderWidth, scrollViewHeight)];
    [storyPacksView addSubview:storyPacksHolder];
}
-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    
}
@end
