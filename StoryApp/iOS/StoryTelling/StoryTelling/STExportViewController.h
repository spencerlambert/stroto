//
//  STExportViewController.h
//  StoryTelling
//
//  Created by Nandakumar on 09/11/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STListStoryiPad.h"
#import <StoreKit/StoreKit.h>

@interface STExportViewController : UIViewController<SKProductsRequestDelegate, SKRequestDelegate, SKPaymentTransactionObserver, UITextFieldDelegate,UIAlertViewDelegate, STListStoryiPadDelegate>
@property (weak, nonatomic) IBOutlet UITextField *storyTitle;
@property (weak, nonatomic) IBOutlet UITextField *storySubTitle;
@property (weak, nonatomic) IBOutlet UISwitch *addTitleCheck;
@property (weak, nonatomic) IBOutlet STListStoryiPad *listViewiPad;
@property (weak, nonatomic) STListStoryiPad *storyListiPad;
@property (strong, nonatomic) SKProduct *paidProduct;
@property (weak, nonatomic) NSString *dbname;
@property (weak, nonatomic) NSString *storyTitleString;
@property (weak, nonatomic) NSString *storySubTitleString;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (IBAction)toggleAddTitle:(UISwitch *)sender;
- (IBAction)saveToGallery:(UIButton *)sender;

@end
