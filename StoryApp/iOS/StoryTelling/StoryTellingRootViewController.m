//
//  StoryTellingRootViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "StoryTellingRootViewController.h"
#import "STStoryDB.h"

@interface StoryTellingRootViewController ()

@end

@implementation StoryTellingRootViewController
@synthesize newstoryFlag;
//static sqlite3 *database = nil;


STStoryDB *story;

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
    self.view.tag=100;

}

-(void)viewWillAppear:(BOOL)animated{
    newstoryFlag = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [newstoryFlag setIsNewStory:@"true"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createNewStory:(id)sender {
   // story = [[STStoryDB alloc]init];
    
    NSString *docsDir;
        NSArray *dirPaths;
    NSString *storyPath;
    
     // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(
                                                       NSDocumentDirectory, NSUserDomainMask, YES);
    
        docsDir = [dirPaths objectAtIndex:0];
    
        // Build the path to the database file
        storyPath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"stories.sqlite"]];
    NSLog(@"Storypath is %@",storyPath);
    [STStoryDB createNewSTstoryDB:storyPath :280];
}
//-(void)createNewSTstoryDB:(NSString*)storyPath {
//    NSString *docsDir;
//    NSArray *dirPaths;
//    
//    // Get the documents directory
//    dirPaths = NSSearchPathForDirectoriesInDomains(
//                                                   NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    docsDir = [dirPaths objectAtIndex:0];
//    
//    // Build the path to the database file
//    storyPath = [[NSString alloc]
//                 initWithString: [docsDir stringByAppendingPathComponent:
//                                  @"stories.db"]];
//    // BOOL isSuccess = YES;
//    
//    NSFileManager *filemgr = [NSFileManager defaultManager];
//    
//    if ([filemgr fileExistsAtPath: storyPath ] == NO)
//    {
//        const char *dbpath = [storyPath UTF8String];
//        
//        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//        {
//            char *errMsg;
//            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS Story (ID INTEGER PRIMARY KEY AUTOINCREMENT, displayName TEXT, mainTitle TEXT, subTile TEXT, sizeX INTEGER, sizeY INTEGER, createDateTime NUMERIC)";
//            
//            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
//            {
//                //  isSuccess = NO;
//                NSLog(@"Failed to create table");
//            }
//            sqlite3_close(database);
//            // return  isSuccess;
//        }
//        else {
//            // isSuccess = NO;
//            NSLog(@"Failed to open/create database");
//        }
//    }
//    //return isSuccess;
//}
//

@end
