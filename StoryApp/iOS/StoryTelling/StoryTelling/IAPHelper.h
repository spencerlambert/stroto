//
//  STStoryPackPurchaseHelper.h
//  StoryTelling
//
//  Created by Nandakumar on 02/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray* products);

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface IAPHelper : NSObject
-(id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
@end
