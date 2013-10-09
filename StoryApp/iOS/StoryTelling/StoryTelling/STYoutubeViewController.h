//
//  STYoutubeViewController.h
//  StoryTelling
//
//  Created by Aaswini on 01/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLYouTube.h"

@interface STYoutubeViewController : UIViewController<UITextFieldDelegate>{
    NSString *clientID ;
    NSString *clientSecret;
    IBOutlet UIProgressView *uploadProgressIndicator;
}
@property (weak, nonatomic) IBOutlet UITextField *mainTitle;
@property (weak, nonatomic) IBOutlet UITextField *subTitle;
@property (strong, nonatomic) NSString *dbname;
- (IBAction)signIn:(id)sender;
- (IBAction)upload:(id)sender;

@end