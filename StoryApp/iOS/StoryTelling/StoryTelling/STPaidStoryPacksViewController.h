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

#define kInAppPurchaseProductsFetchedNotification @"kInAppPurchaseProductsFetchedNotification"
#define kInAppPurchaseTransactionSucceededNotification @"kInAppPurchaseTransactionSucceededNotification"

@interface STPaidStoryPacksViewController : UIViewController<SKProductsRequestDelegate, SKPaymentTransactionObserver,SKRequestDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loader;
@property (strong, nonatomic) IBOutlet UILabel *paidStoryPackName;


@property (strong, nonatomic) IBOutlet UIView *backgroundImagesView;
@property (strong, nonatomic) IBOutlet UIView *foregroundImagesView;

@property (strong, nonatomic) NSDictionary *paidStoryPackDetailsJson;
@property (strong, nonatomic) NSDictionary *paidStoryPackURLJson;
@property (strong, nonatomic) SKProduct *paidProduct;
@property (assign, nonatomic) int storyPackID;

@property (strong, nonatomic) IBOutlet UIButton *paidButtonLabel;
@property (strong, nonatomic) IBOutlet UIButton *buyPackButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;

-(IBAction)buyButtonTapped:(id)sender;
-(IBAction)buyPack:(id)sender;
- (IBAction)showPrice:(UIButton *)sender;
@end
