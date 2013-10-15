//
//  SavedStoryDetailsViewController.m
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "SavedStoryDetailsViewController.h"
#import "STStoryDB.h"
#import "CreateStoryRootViewController.h"
#include "STFacebookViewController.h"
#import "STYoutubeViewController.h"

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
    [storyDB closeDB];
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
        mp = [[MPMoviePlayerViewController alloc] initWithContentURL:outputURL];
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
    NSFileManager *filemngr =[NSFileManager defaultManager];
//NSLog(@"dbname: %@",dbname);
    NSString *moviePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mov", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [dbname stringByDeletingPathExtension]];
//NSLog(@"movie path : %@",moviePath);
    if([filemngr fileExistsAtPath:moviePath])
    {
        STFacebookViewController *facebookController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:Nil] instantiateViewControllerWithIdentifier:@"toFacebook"];
//setting the title and subtitle.
        facebookController.storyTitleString = navigationBarTitle.title;
        facebookController.storySubTitleString = @"by: ";
        NSLog(@"facebookController.storyTitleString : %@",facebookController.storyTitleString);
        NSLog(@"facebookController.storySubTitleString : %@",facebookController.storySubTitleString);
//passing mov file path
        facebookController.filepath = moviePath;
NSLog(@"facebookcontroller.filepath : %@",facebookController.filepath);
        //read request
        if([SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook])
        {
            [self.navigationController pushViewController:facebookController animated:YES];
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil ];
            NSLog(@"Error : No account found, go to settings an set up an account");
            [alert show];
        }
        //end read

    
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }

}

- (IBAction)editButtonClicked:(id)sender {
    CreateStoryRootViewController *createStory =
    [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"CreateStoryRootViewController"];
    [createStory setDbname:dbname];
    [createStory setIsEditStory:YES];
    [self.navigationController pushViewController:createStory animated:YES];

    
}

- (IBAction)deleteButtonClicked:(id)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Do you want to delete the story ?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No" , nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
//        NSLog(@"Clicked button index 0");
        storyDB = [STStoryDB loadSTstoryDB:dbname];
        [storyDB deleteSTstoryDB];
        NSString *moviePath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        moviePath = [moviePath stringByAppendingString:[NSString stringWithFormat:@"/mov_dir/%@.mov",[dbname stringByDeletingPathExtension]] ];
        NSString *mp4Path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        mp4Path = [mp4Path stringByAppendingString:[NSString stringWithFormat:@"/mov_dir/%@.mp4",[dbname stringByDeletingPathExtension]] ];
        NSString *cafPath =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        cafPath = [cafPath stringByAppendingString:[NSString stringWithFormat:@"/mov_dir/%@.caf",[dbname stringByDeletingPathExtension]] ];
        NSFileManager *file = [NSFileManager defaultManager];
        if([file fileExistsAtPath:moviePath]){
            [file removeItemAtPath:moviePath error:nil];
            [file removeItemAtPath:mp4Path error:nil];
            [file removeItemAtPath:cafPath error:nil];
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
        // Add the action here
    } else if(buttonIndex == 1)
    {
//        NSLog(@"Clicked button index other than 0");
        
        // Add another action here
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier  isEqual: @"youtubeSegue"]) {
        STYoutubeViewController *controller = segue.destinationViewController;
        [controller setDbname:dbname];
        [controller setMaintitle:navigationBarTitle.title];
    }
}
@end
