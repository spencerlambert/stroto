//
//  StoryTellingRootViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "StoryTellingRootViewController.h"
#import "STStoryDB.h"
#import "SavedStoryDetailsViewController.h"

@interface StoryTellingRootViewController ()

@end

@implementation StoryTellingRootViewController {
    STStoryDB* newStory;
    NSMutableArray *displayNames;
    NSMutableArray *dbNames;
}

@synthesize newstoryFlag;



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
    [self displaydbNames];

}

-(void)viewWillAppear:(BOOL)animated{
    newstoryFlag = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    [newstoryFlag setIsNewStory:@"true"];
    [self displaydbNames];
    [[self storyTable] reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)createNewStory:(id)sender {
//    
//    CGSize storySize = [AppDelegate deviceSize];
//    NSLog(@"Demo : %@",NSStringFromCGSize(storySize));
//    newStory = [STStoryDB createNewSTstoryDB:&storySize];
//
//}

- (void)displaydbNames{
    NSString *docsDir;
    NSArray *dirPaths;
    displayNames = [[NSMutableArray alloc]init];
    dbNames = [[NSMutableArray alloc]init];
    
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    NSString *newDir = [docsDir stringByAppendingPathComponent:STDIRECTORY];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSArray *filelist= [filemgr contentsOfDirectoryAtPath:newDir error:nil];
    
    int count = [filelist count];
    
    
    NSLog (@"%i",count);
    for(int i=0; i<count; i++){
        sqlite3 *db;
        if([[[filelist[i] lastPathComponent] pathExtension] isEqualToString:@"db"]){
            NSLog(@"%@",filelist[i]);
            [dbNames addObject:filelist[i]];
            NSString *databasePath = [newDir stringByAppendingPathComponent:filelist[i]];
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, & db) == SQLITE_OK){
                NSString *sql = [NSString stringWithFormat:@"SELECT displayName from Story;"];
                const char *sql_stmt = [sql UTF8String];
                sqlite3_stmt *compiled_stmt;
                if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
                    if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
                        NSString *temp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 0)];
                        [displayNames addObject:temp];
                        NSLog(@"aaa is %@",temp);
                    }
                }
            }
            
        }
    }
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [displayNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
   
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell. accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [displayNames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     SavedStoryDetailsViewController *savedStory =
    [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"savedStory"];
    
    [savedStory setDbname:dbNames[indexPath.row]];
    [self.navigationController pushViewController:savedStory animated:YES];

}

- (void)viewDidUnload {

    [super viewDidUnload];
}
@end
