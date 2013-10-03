//
//  STYoutubeViewController.h
//  StoryTelling
//
//  Created by Aaswini on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLYouTube.h"

@interface STYoutubeViewController : UIViewController

@property (nonatomic, readonly) GTLServiceYouTube *youTubeService;
- (IBAction)signIn:(id)sender;
- (IBAction)upload:(id)sender;

@end
