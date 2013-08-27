//
//  STStoryPackViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STImage.h"

@interface STStoryPacksViewController : UIViewController
{
    
}
@property (strong, nonatomic) IBOutlet UIView *installedStoryPacksView;
@property (strong, nonatomic) IBOutlet UIView *paidStoryPacksView;
@property (strong, nonatomic) IBOutlet UIView *freeStoryPacksView;
- (IBAction)previousView:(UIBarButtonItem *)sender;

@property (strong, nonatomic) NSDictionary *paidJson;   //holding json from get_paid_list
@property (strong, nonatomic) NSDictionary *freeJson;   //holding json from get_free_list

@property (strong,nonatomic) NSArray *freeImages;       //not used
@property (strong, nonatomic) NSArray *paidImages;      //not used
@property (strong, nonatomic) NSArray *installedImages; //not used

@end
