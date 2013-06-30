//
//  SavedStoryDetailsViewController.h
//  StoryTelling
//
//  Created by Aaswini on 09/06/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedStoryDetailsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationItem *NavigationBarTitle;
- (IBAction)playButtonClicked:(id)sender;
- (IBAction)UploadToYoutubeButtonClicked:(id)sender;
- (IBAction)uploadToFacebookButtonClicked:(id)sender;
- (IBAction)editButtonClicked:(id)sender;
- (IBAction)deleteButtonClicked:(id)sender;


@end
