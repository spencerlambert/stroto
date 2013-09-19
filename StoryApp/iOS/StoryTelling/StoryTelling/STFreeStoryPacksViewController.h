//
//  STFreeStoryPacksViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STImage.h"
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseProductsFetchedNotification @"kInAppPurchaseProductsFetchedNotification"
#define kInAppPurchaseTransactionSucceededNotification @"kInAppPurchaseTransactionSucceededNotification"
#define kInAppPurchaseTransactionFailedNotification @"kInAppPurchaseTransactionFailedNotification"

@interface STFreeStoryPacksViewController : UIViewController <UIAlertViewDelegate,SKProductsRequestDelegate,SKRequestDelegate,SKPaymentTransactionObserver>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (strong, nonatomic) IBOutlet UILabel *freeStoryPackName;

@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;

@property (strong, nonatomic) NSDictionary *freeStoryPackDetailsJson;
@property (strong, nonatomic) NSDictionary *freeStoryPackURLJson;
@property (strong, nonatomic) SKProduct *freeProduct;
@property (assign, nonatomic) int storyPackID;

@property (strong, nonatomic) IBOutlet UIButton *freeButton;
@property (strong, nonatomic) IBOutlet UIButton *installButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;

-(IBAction)buyButtonTapped:(id)sender;
- (IBAction)InstallPack:(UIButton*)sender;
- (IBAction)showFree:(UIButton *)sender;

@end
