//
//  ViewController.h
//  StrotoBasic
//
//  Created by Nandakumar on 29/10/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>
#import "playViewController.h"
#import "STStoryPackDownload.h"

@interface ViewController : UIViewController<STStoryPackDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIView *storyPacksView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (weak, nonatomic) IBOutlet UIView *downloadRectView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadPercentageLabel;
@property (weak, nonatomic) IBOutlet UIButton *BGHideDownload;

@property (assign, nonatomic) int storyPackID;
@property (strong, nonatomic) NSString *storyDBName;
@property (strong, nonatomic) NSDictionary *basicJsonDict;

@end
