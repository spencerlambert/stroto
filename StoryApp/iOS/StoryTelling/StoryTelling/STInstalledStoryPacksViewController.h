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
    NSDictionary * selectedFGImages;
    NSDictionary * selectedBGImages;
    sqlite3 *database;
//    STStoryDB *newDB;
    @public
    NSString *filePath;
}
@property (strong, nonatomic) IBOutlet UILabel *installedStoryPackName;
@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;

-(void)initializeDB;
-(void)loadFGImages;
-(void)loadBGImages;

-(void)doneButtonPressed;

@end
