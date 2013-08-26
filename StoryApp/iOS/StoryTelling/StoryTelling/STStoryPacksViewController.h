//
//  STStoryPackViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STStoryPacksViewController : UIViewController
{
    
}
@property (strong, nonatomic) IBOutlet UIView *installedStoryPacksView;
@property (strong, nonatomic) IBOutlet UIView *paidStoryPacksView;
@property (strong, nonatomic) IBOutlet UIView *freeStoryPacksView;
- (IBAction)previousView:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSDictionary *paidJson;
@property (strong, nonatomic) NSDictionary *freeJson;

@property (strong,nonatomic) NSArray *freeImages;
@property (strong, nonatomic) NSArray *paidImages;
@property (strong, nonatomic) NSArray *installedImages;


@end
