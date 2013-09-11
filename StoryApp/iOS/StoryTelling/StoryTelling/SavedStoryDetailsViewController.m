//
//  SavedStoryDetailsViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "SavedStoryDetailsViewController.h"
#import "STStoryDB.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CreateStoryRootViewController.h"

@interface SavedStoryDetailsViewController ()

@end

@implementation SavedStoryDetailsViewController{
    STStoryDB *storyDB;
}

@synthesize dbname;
@synthesize navigationBarTitle;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    storyDB = [STStoryDB loadSTstoryDB:dbname];
    [navigationBarTitle setTitle:[storyDB getStoryName]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)playButtonClicked:(id)sender {
    NSFileManager *filemngr =[NSFileManager defaultManager];
    NSString *moviePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mov", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [dbname stringByDeletingPathExtension]];
    if([filemngr fileExistsAtPath:moviePath]){
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:moviePath];
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:outputURL];
    mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:mp];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)UploadToYoutubeButtonClicked:(id)sender {
}

- (IBAction)uploadToFacebookButtonClicked:(id)sender {
}

- (IBAction)editButtonClicked:(id)sender {
    CreateStoryRootViewController *createStory =
    [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"CreateStoryRootViewController"];
    [createStory setDbname:dbname];
    [self.navigationController pushViewController:createStory animated:YES];

    
}

- (IBAction)deleteButtonClicked:(id)sender {
}
@end
