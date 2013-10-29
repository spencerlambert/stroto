//
//  ViewController.h
//  StrotoBasic
//
//  Created by Nandakumar on 29/10/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *storyPacksView;
@property (strong, nonatomic) NSMutableArray *storyPackNames;
@property (strong, nonatomic) NSMutableArray *dbNames;

@end
