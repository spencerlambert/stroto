//
//  playViewController.m
//  StrotoBasic
//
//  Created by Nandakumar on 01/11/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//

#import "playViewController.h"

@interface playViewController ()

@end

@implementation playViewController

@synthesize dbName;

NSString *bgQuery = @"SELECT ImageDataPNG_Base64, ImageType, DefaultScale  FROM Images WHERE ImageType='Background';";
NSString *fgQuery = @"SELECT ImageDataPNG_Base64, ImageType, DefaultScale  FROM Images WHERE ImageType='Foreground';";

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
    int code = sqlite3_open_v2([dbName UTF8String], &database,SQLITE_OPEN_READWRITE,NULL);
    if (code != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
    else{
        NSLog(@"DB Successfully Initialized with code : %d", code);
    }
    NSArray *arrayAndQuery = [NSArray arrayWithObjects:bgImagesArray,bgQuery, nil];
    [self performSelectorOnMainThread:@selector(getImagesFromDB:) withObject:arrayAndQuery waitUntilDone:YES];
    arrayAndQuery = [NSArray arrayWithObjects:fgImagesArray,fgQuery, nil];
    [self performSelectorOnMainThread:@selector(getImagesFromDB:) withObject:arrayAndQuery waitUntilDone:YES];
    if(bgImagesArray)
    {
        NSLog(@"bg Images : %@", bgImagesArray);
    }
    if(fgImagesArray)
    {
        NSLog(@"fg Images : %@", fgImagesArray);
    }
}

-(void)getImagesFromDB:(NSArray*)imagesArraywithQuery
{
    sqlite3_stmt *statement;
    switch (sqlite3_prepare_v2(database, [imagesArraywithQuery[1] UTF8String], -1, &statement, nil))
    {
        case SQLITE_OK:
            NSLog(@"SQLITE_OK");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
                NSData *data = [NSData dataFromBase64String:dataAsString];
                UIImage *image = [UIImage imageWithData:data];
                [((NSMutableArray*)[imagesArraywithQuery objectAtIndex:0]) addObject:image];
            }
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
