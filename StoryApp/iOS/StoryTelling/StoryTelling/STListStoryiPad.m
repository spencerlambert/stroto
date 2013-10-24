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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DBNamesiPad count];
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
