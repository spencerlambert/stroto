//
//  AppDelegate.m
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

@implementation AppDelegate
@synthesize backgroundImagesArray;
@synthesize foregroundImagesArray;
@synthesize isNewStory;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self internetAvailableNotifier];
    backgroundImagesArray = [[NSMutableArray alloc]init];
    foregroundImagesArray = [[NSMutableArray alloc]init];
    isNewStory=@"true";
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(CGSize )deviceSize
{
    UIDevice *myDevice = [UIDevice currentDevice];

    CGSize sizeOfTab = CGSizeZero;
    if(myDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        NSString *deviceType = [UIDevice currentDevice].model;
        NSLog(@"%@",deviceType);
        
        if([deviceType hasPrefix:@"iPhone"])
        {
            sizeOfTab = CGSizeMake(640, 640);
            return sizeOfTab;
        }
        else
        {
            sizeOfTab = CGSizeMake(320, 320);
            return sizeOfTab;
        }
            
    }
    else
    {
        return sizeOfTab;

    }
}

-(void)internetAvailableNotifier{
    Reachability *internetReachable;
    
    internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.internetAvailable = YES;
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.internetAvailable = NO;
        });
    };
    
    [internetReachable startNotifier];
    
}

@end
