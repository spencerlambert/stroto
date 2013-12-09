//
//  AppDelegate.h
//  StrotoBasic
//
//  Created by Nandakumar on 29/10/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL internetAvailable;

-(void)internetAvailableNotifier;

@end
