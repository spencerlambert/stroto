//
//  AppDelegate.h
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) NSMutableArray *backgroundImagesArray;
@property (nonatomic,retain) NSMutableArray *foregroundImagesArray;
@property (nonatomic,retain) NSString *isNewStory;

+(CGSize)deviceSize;

@end
