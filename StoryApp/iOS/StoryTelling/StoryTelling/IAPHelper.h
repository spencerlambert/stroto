//
//  STStoryPackPurchaseHelper.h
//  StoryTelling
//
//  Created by Nandakumar on 02/09/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray* products);

#import <Foundation/Foundation.h>

@interface IAPHelper : NSObject

-(id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

@end
