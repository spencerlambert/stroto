//
//  STListStoryiPad.m
//  StoryTelling
//
//  Created by Nandakumar on 23/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STListStoryiPad.h"
#import "STStoryDB.h"
#import "SavedStoryDetailsViewController.h"

@implementation STListStoryiPad

@synthesize DBNamesiPad;
@synthesize storyNamesiPad;
@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadTableSource];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(int)loadTableSource
{
    NSString *docsDir;
    NSArray *dirPaths;
    storyNamesiPad = [[NSMutableArray alloc]init];
    DBNamesiPad = [[NSMutableArray alloc]init];
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
            [DBNamesiPad addObject:filelist[i]];
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
                        [storyNamesiPad addObject:temp];
                    }
                }
                sqlite3_finalize(compiled_stmt);
                sqlite3_close(db);
            }
            
        }
    }
    return [DBNamesiPad count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self loadTableSource]);
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell. accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [storyNamesiPad objectAtIndex:indexPath.row];
    if([indexPath isEqual:index])
        [tableView selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    index = indexPath;
    [self.listDelegate didSelectTableCellWithName:DBNamesiPad[indexPath.row]];
}

@end
