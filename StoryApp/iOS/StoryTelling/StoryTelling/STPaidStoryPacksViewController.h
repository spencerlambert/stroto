//
//  STPaidStoryPacksViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "STImage.h"
#import "STStoryPackDownload.h"

#define kInAppPurchaseProductsFetchedNotification @"kInAppPurchaseProductsFetchedNotification"
#define kInAppPurchaseTransactionSucceededNotification @"kInAppPurchaseTransactionSucceededNotification"
#define kInAppPurchaseTransactionFailedNotification @"kInAppPurchaseTransactionFailedNotification"

@interface STPaidStoryPacksViewController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver,SKRequestDelegate,STStoryPackDownloadDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadPercentageLabel;
@property (weak, nonatomic) IBOutlet UIButton *BGHideDownload;
@property (strong, nonatomic) IBOutlet UILabel *paidStoryPackName;

@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;

@property (strong, nonatomic) NSDictionary *paidStoryPackDetailsJson;
@property (strong, nonatomic) NSDictionary *paidStoryPackURLJson;
@property (strong, nonatomic) SKProduct *paidProduct;
@property (assign, nonatomic) int storyPackID;

@property (strong, nonatomic) IBOutlet UIButton *paidButtonLabel;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;

-(IBAction)buyButtonTapped:(id)sender;
- (IBAction)showPrice:(UIButton *)sender;

@end
