//
//  STExportViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 09/11/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STExportViewController.h"

@interface STExportViewController ()<SKProductsRequestDelegate, SKRequestDelegate>

@end

@implementation STExportViewController

@synthesize addTitleCheck;
@synthesize paidProduct;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    addTitleCheck.selected = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleAddTitle:(UISwitch *)sender {
}

- (IBAction)saveToGallery:(UIButton *)sender {
    
    NSSet * productIdentifiers = [NSSet setWithObject:@"export_unlock"];
    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
    productReq.delegate = self;
    [productReq start];
}
#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    paidProduct = [response.products objectAtIndex:0];
    NSLog(@"Product Title : %@",[[response.products objectAtIndex:0] localizedTitle]);
    NSLog(@"product description : %@", [[response.products objectAtIndex:0] productIdentifier]);
    NSLog(@"Product Price %f", [[response.products objectAtIndex:0] price].floatValue);
    NSLog(@"invalidProductIdentifiers : %@",response.invalidProductIdentifiers);
    }

-(void)requestDidFinish:(SKRequest *)request
{
    SKPayment *paidPayment = [SKPayment paymentWithProduct:paidProduct];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:paidPayment];
    
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Failed to load the list of Products : %@",error);
    if(error)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
      
}

@end
