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

@end
