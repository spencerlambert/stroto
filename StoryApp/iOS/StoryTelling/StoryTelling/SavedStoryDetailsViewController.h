//
//  SavedStoryDetailsViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "STListStoryiPad.h"

@interface SavedStoryDetailsViewController : UIViewController<STListStoryiPadDelegate>{
    MPMoviePlayerViewController *mp;
}

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationBarTitle;
@property (strong, nonatomic) NSString *dbname;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)UploadToYoutubeButtonClicked:(id)sender;
- (IBAction)uploadToFacebookButtonClicked:(id)sender;
- (IBAction)editButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;
-(void)setBarTitle;
@property (strong, nonatomic) IBOutlet STListStoryiPad *listiPad;
@property (weak, nonatomic) STListStoryiPad *storyListiPad;
@end
