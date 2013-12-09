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

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *storyPacksView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (assign, nonatomic) int storyPackID;
@property (strong, nonatomic) NSDictionary *basicJsonDict;

@end
