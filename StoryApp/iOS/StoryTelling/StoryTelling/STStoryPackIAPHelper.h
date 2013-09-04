//
//  STStoryPackIAPHelper.h
//  StoryTelling
//
//  Created by Nandakumar on 02/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface STStoryPackIAPHelper : IAPHelper<SKPaymentTransactionObserver, SKRequestDelegate, SKProductsRequestDelegate>
+(STStoryPackIAPHelper*)sharedInstance;
@end
