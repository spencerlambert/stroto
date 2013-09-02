//
//  STStoryPackPurchaseHelper.m
//  StoryTelling
//
//  Created by Nandakumar on 02/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

@interface IAPHelper () <SKProductsRequestDelegate>
@end

@implementation IAPHelper
{
    SKProductsRequest * __productsRequest;
    RequestProductsCompletionHandler __completionhandler;
    NSSet * __productIdentifiers;
    NSMutableSet * __purchasedProductIdentifiers;
}
-(id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if(self == [super init])
    {
        __productIdentifiers = productIdentifiers;
        __purchasedProductIdentifiers = [NSMutableSet set];
        for(NSString* productIdentifier in __productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults]boolForKey:productIdentifier];
            if (productPurchased) {
                [__purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"previously Purchased: %@",productIdentifier);
            }else {
                NSLog(@"Not purchased: %@",productIdentifier);
            }
        }
    }
    return self;
}
-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    __completionhandler = [completionHandler copy];
    __productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:__productIdentifiers];
    __productsRequest.delegate = self;
    [__productsRequest start];
}
#pragma mark - SKProductsRequestDelegate
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loaded List of Products");
    __productsRequest = nil;
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product : %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    __completionhandler(YES, skProducts);
    __completionhandler = nil;
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products");
    __productsRequest = nil;
    __completionhandler(NO, nil);
    __completionhandler = nil;
    
}
@end
