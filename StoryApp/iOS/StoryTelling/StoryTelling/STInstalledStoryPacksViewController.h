//
//  STInstalledStoryPacksViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 12/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <sqlite3.h>
#import "STStoryDB.h"
@interface STInstalledStoryPacksViewController : UIViewController
{
    NSMutableArray * selectedFGImages;
    NSMutableArray * selectedBGImages;
    sqlite3 *database;
//    STStoryDB *newDB;
}
@property (strong, nonatomic) IBOutlet UILabel *installedStoryPackName;
@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;
@property (strong, nonatomic) NSString *filePath;

-(void)initializeDB;
-(void)loadFGImages;
-(void)loadBGImages;

-(void)doneButtonPressed;

@end
