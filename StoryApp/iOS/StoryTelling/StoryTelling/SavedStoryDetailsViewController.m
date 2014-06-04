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
#import "STExportViewController.h"
#import "STStagePlayerViewController.h"

@interface SavedStoryDetailsViewController ()

@end

@implementation SavedStoryDetailsViewController{
    STStoryDB *storyDB;
}

@synthesize dbname;
@synthesize navigationBarTitle;
@synthesize storyListiPad;
@synthesize listiPad;

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
    
//    player = [[STStagePlayer alloc]initWithDB:storyDB];
//    [player generateMovie];
    
    
    [storyDB closeDB];
    [self.listiPad setListDelegate:self];
    [self.listiPad setIndex:storyListiPad.index];
//    [self.listiPad setStoryNamesiPad:storyListiPad.storyNamesiPad];
//    [self.listiPad setDBNamesiPad:storyListiPad.DBNamesiPad];
    storyListiPad = nil;
    [self.listiPad reloadInputViews];
}
-(void)viewWillAppear:(BOOL)animated
{
    [(UITableView*)[[self.listiPad subviews]objectAtIndex:0] reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)playButtonClicked:(id)sender {
    
    STStagePlayerViewController *player = [[STStagePlayerViewController alloc]init];
    [player setDbname:dbname];
    [self presentViewController:player animated:YES completion:nil];
    
    
    //*****************************************************************************************************

    
    /* NSFileManager *filemngr =[NSFileManager defaultManager];
    NSString *moviePath = [[NSString alloc] initWithFormat:@"%@/test.mp4", NSTemporaryDirectory()];
    if([filemngr fileExistsAtPath:moviePath]){
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:moviePath];
        mp = [[MPMoviePlayerViewController alloc] initWithContentURL:outputURL];
        mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:outputURL options:nil];
        
        if(CMTimeCompare(asset.duration,kCMTimeZero) > 0){
            [self presentMoviePlayerViewControllerAnimated:mp];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Processing movie, Please wait." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
     */
    
//*****************************************************************************************************
    
//    NSFileManager *filemngr =[NSFileManager defaultManager];
//    NSString *moviePath = [[NSString alloc] initWithFormat:@"%@/mov_dir/%@.mov", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0], [dbname stringByDeletingPathExtension]];
//    if([filemngr fileExistsAtPath:moviePath]){
//        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:moviePath];
//        mp = [[MPMoviePlayerViewController alloc] initWithContentURL:outputURL];
//        mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
//        AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:outputURL options:nil];
//
//        if(CMTimeCompare(asset.duration,kCMTimeZero) > 0){
//             [self presentMoviePlayerViewControllerAnimated:mp];
//        }else{
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Processing movie, Please wait." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//            [alert show];
//        }
//       
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alert show];
//    }
    
    
}

- (IBAction)UploadToYoutubeButtonClicked:(id)sender {
    STStageExporter *exporter = [[STStageExporter alloc]init];
    [exporter setDbname:self.dbname];
    [exporter initDB];
    [exporter generateMovie];
    
    {
        NSFileManager *filemngr =[NSFileManager defaultManager];
        NSString *videoAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/videoAssets"];
        NSString *moviePath = [videoAssetPath stringByAppendingPathComponent:@"storyVideo.mp4"];
        if([filemngr fileExistsAtPath:moviePath]){
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:moviePath];
//            mp = [[MPMoviePlayerViewController alloc] initWithContentURL:outputURL];
//            mp.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
            AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:outputURL options:nil];
            
            if(CMTimeCompare(asset.duration,kCMTimeZero) > 0){
//                [self presentMoviePlayerViewControllerAnimated:mp];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Processing movie, Please wait." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }

    }
  }

- (IBAction)uploadToFacebookButtonClicked:(id)sender {
    NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"We are currently processing another upload request, please try later" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else{
        
        NSFileManager *filemngr =[NSFileManager defaultManager];
        
        STStageExporter *exporter = [[STStageExporter alloc]init];
        [exporter setDbname:self.dbname];
        [exporter initDB];
        [exporter generateMovie];
        
        NSString *videoAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/videoAssets"];
        NSString *moviePath = [videoAssetPath stringByAppendingPathComponent:@"storyVideo.mp4"];
        
        
        if([filemngr fileExistsAtPath:moviePath])
        {
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:moviePath];
            AVURLAsset* asset = [[AVURLAsset alloc]initWithURL:outputURL options:nil];
            
            if(CMTimeCompare(asset.duration,kCMTimeZero) > 0){
                
                STFacebookViewController *facebookController = [[STFacebookViewController alloc] init];
                NSString *deviceType = [UIDevice currentDevice].model;
                if([deviceType hasPrefix:@"iPad"]){
                    facebookController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"toFacebook"];
                }
                else{
                    facebookController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"toFacebook"];
                }
                facebookController.storyTitleString = navigationBarTitle.title;
                facebookController.storySubTitleString = @"by: ";
                facebookController.filepath = moviePath;
                facebookController.dbname = dbname;
                
                if([SLComposeViewController isAvailableForServiceType: SLServiceTypeFacebook])
                {
                    STListStoryiPad *temp = [[STListStoryiPad alloc] init];
                    [facebookController setStoryListiPad:temp];
                    [[facebookController storyListiPad] setIndex:self.listiPad.index];
                    [self.navigationController pushViewController:facebookController animated:YES];
                }
                else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:Nil ];
                    NSLog(@"Error : No account found, go to settings an set up an account");
                    [alert show];
                }
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Processing movie, Please wait." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"File Not Found" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }

}

- (IBAction)editButtonClicked:(id)sender {
    CreateStoryRootViewController *createStory = [[CreateStoryRootViewController alloc] init];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"%@",deviceType);
    if([deviceType hasPrefix:@"iPad"])
    {
    createStory =[[UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                               bundle:NULL] instantiateViewControllerWithIdentifier:@"CreateStoryRootViewController"];
    }
    else
    {
    createStory =[[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                bundle:NULL] instantiateViewControllerWithIdentifier:@"CreateStoryRootViewController"];
    }
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
        STListStoryiPad *temp = [[STListStoryiPad alloc] init];
        [controller setStoryList:temp];
//        [[controller storyList] setDBNamesiPad:self.listiPad.DBNamesiPad];
//        [[controller storyList] setStoryNamesiPad:self.listiPad.storyNamesiPad];
        [[controller storyList] setIndex:self.listiPad.index];
    }
    if([segue.identifier  isEqual: @"createNew"])
    {
//        ((CreateStoryRootViewController*)segue.destinationViewController).myDelegate = self;
        AppDelegate *newstoryFlag = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [newstoryFlag setIsNewStory:@"true"];
    }
    if([segue.identifier isEqual:@"export"])
    {
        STExportViewController *exportController = segue.destinationViewController;
        [exportController setDbname:dbname];
        [exportController setStoryTitleString:navigationBarTitle.title];
        [exportController setStorySubTitleString:@"by: "];
        STListStoryiPad *temp = [[STListStoryiPad alloc] init];
        [exportController setStoryListiPad:temp];
        [[exportController storyListiPad] setIndex:self.listiPad.index];
        NSLog(@"export.storyTitleString : %@",exportController.storyTitleString);
        NSLog(@"export.storySubTitleString : %@",exportController.storySubTitleString);
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqual:@"youtubeSegue"]){
        NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"We are currently processing another upload request, please try later" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            return NO;
        }

        NSFileManager *filemngr =[NSFileManager defaultManager];
        NSString *videoAssetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/videoAssets"];
        NSString *moviePath = [videoAssetPath stringByAppendingPathComponent:@"storyVideo.mp4"];
        
        if([filemngr fileExistsAtPath:moviePath])
        {
            return YES;
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Video to Upload" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            return NO;
  
        }
    }
    else if([identifier isEqual:@"export"]){
        NSString *dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/movie_process_lock.lock"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"We are currently processing another upload request, please try later" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            return NO;
        }

    }
    return YES;
}

- (void) didSelectTableCellWithName:(NSString*)dbName{
    [self setDbname:dbName];
    storyDB = [STStoryDB loadSTstoryDB:dbname];
    [navigationBarTitle setTitle:[storyDB getStoryName]];
    [storyDB closeDB];
}

-(void)setBarTitle
{
    storyDB = [STStoryDB loadSTstoryDB:dbname];
    [navigationBarTitle setTitle:[storyDB getStoryName]];
    [storyDB closeDB];
}

@end
