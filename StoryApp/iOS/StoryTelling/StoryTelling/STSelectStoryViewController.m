//
//  STSelectStoryViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STSelectStoryViewController.h"
#import "STStoryDB.h"
#import "STSelectImagesFromStoryViewController.h"

@interface STSelectStoryViewController ()

@end

@implementation STSelectStoryViewController

{
    NSMutableArray *storyNames;
    NSMutableArray *dbNames;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self showStoryNames];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)showStoryNames
{
    NSString *docsDir;
    NSArray *dirPaths;
    storyNames = [[NSMutableArray alloc]init];
    dbNames = [[NSMutableArray alloc]init];
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    docsDir = dirPaths[0];
    //story directory
    NSString *storyDir = [docsDir stringByAppendingPathComponent:@"story_dir/"];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist= [filemgr contentsOfDirectoryAtPath:storyDir error:nil];
    int count = [filelist count];
    NSLog (@"Number of dbs : %i",count);
    for(int i=0;i<count;i++)
    {
        sqlite3 *db;
        if([[[filelist[i] lastPathComponent] pathExtension] isEqualToString:@"db"]){
            //1.db, 2.db etc.
    NSLog(@"%@",filelist[i]);
            [dbNames addObject:filelist[i]];
            //location of the dbfile in device
            NSString *databasePath = [storyDir stringByAppendingPathComponent:filelist[i]];
            const char *dbpath = [databasePath UTF8String];
            
            if (sqlite3_open(dbpath, & db) == SQLITE_OK){
                NSString *sql = [NSString stringWithFormat:@"SELECT displayName from Story;"];
                const char *sql_stmt = [sql UTF8String];
                sqlite3_stmt *compiled_stmt;
                if(sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
                    if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
                        NSString *temp = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 0)];
                        [storyNames addObject:temp];
                    }
                }
                sqlite3_finalize(compiled_stmt);
                sqlite3_close(db);
            }
            
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [storyNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    // Configure the cell...
    if(cell == nil)
    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell. accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [storyNames objectAtIndex:indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    STSelectImagesFromStoryViewController *imagesFromStory = [[STSelectImagesFromStoryViewController alloc] init];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"%@",deviceType);
    if([deviceType hasPrefix:@"iPad"]){
        imagesFromStory =
        [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"imagesFromStory"];
    }
    else{
        imagesFromStory = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"imagesFromStory"];
    }
    [imagesFromStory setDbLocation:dbNames[indexPath.row]];
    [imagesFromStory setStoryNameLabelText:storyNames[indexPath.row]];
    [self.navigationController pushViewController:imagesFromStory animated:YES];
    
    
}

- (void)viewDidUnload {
    [self setStoryNameTable:nil];
    [super viewDidUnload];
}
@end
