//
//  STStoryPackViewController.m
//  StoryTelling
//
//  Created by Nandakumar on 23/08/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 150 : 57)
#define THUMB_V_PADDING 3
#define THUMB_H_PADDING 8
#define RADIUS (IS_IPAD ? 20 :10 )
#define NAME_LABEL_HEIGHT 25
#define PRICE_LABEL_HEIGHT (IS_IPAD ? 15 : 10)
#define fontSize (IS_IPAD ? 15 : 10)
#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define paidBody [NSString stringWithFormat:@"{\"st_request\":\"get_paid_list\"}"]
#define freeBody [NSString stringWithFormat:@"{\"st_request\":\"get_free_list\"}"]

#import "STStoryPacksViewController.h"
#import "STPaidStoryPacksViewController.h"
#import "STFreeStoryPacksViewController.h"
#import "NSData+Base64.h"
#import "STInstalledStoryPacksViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@implementation STStoryPacksViewController{
    BOOL internetAvailable;
    BOOL loadingFreeOver;
    BOOL loadingPaidOver;
}

@synthesize installedStoryPacksView;
@synthesize paidStoryPacksView;
@synthesize freeStoryPacksView;

@synthesize paidJson;
@synthesize freeJson;
//@synthesize priceArray;

@synthesize installedImages;//to be used later
NSString *databasePath;
//@synthesize testImageView;
-(void)viewDidLoad{
    loadingFreeOver = NO;
    loadingPaidOver = NO;
//disabling back navigation
    self.navigationItem.hidesBackButton = YES;
//Activity Indicator
    [self.loader setHidden:FALSE];
    [self.loader setUserInteractionEnabled:NO];
    [self.loader setOpaque:YES];
    [self.loader startAnimating];
    [self performSelectorInBackground:@selector(showInstalledPacks) withObject:nil];
//json retrieval
    [((AppDelegate *)[[UIApplication sharedApplication]delegate]) internetAvailableNotifier];
    internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
//    NSLog(@"internet availability : %hhd", ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable);
    if (internetAvailable)
        [self performSelectorInBackground:@selector(jsonPost) withObject:nil];
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [self.loader stopAnimating];
        [self.loader setHidden:TRUE];
        
    }
    [self performSelector:@selector(dismissLoader) withObject:nil afterDelay:60];
    
}

-(void)dismissLoader{
    [self.loader stopAnimating];
    [self.loader setHidden:TRUE];
    [((AppDelegate *)[[UIApplication sharedApplication]delegate]) internetAvailableNotifier];
    internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
    //    NSLog(@"internet availability : %hhd", ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable);
    if (!internetAvailable){
       
           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [self.loader stopAnimating];
        [self.loader setHidden:TRUE];
        
    }

    
}

-(void)jsonPost

{
    [self jsonRequestPaid:paidBody];
    [self jsonRequestFree:freeBody];
}

- (void) jsonRequestPaid:(NSString*)body {
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15 ];
    
    NSData *requestData = [NSData dataWithBytes:[body UTF8String] length:[body length]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            paidJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            [self performSelectorInBackground:@selector(reloadPaidView) withObject:nil];
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
            loadingPaidOver = YES;
        }
        else if (error != nil){
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:[error.userInfo objectForKey:NSLocalizedDescriptionKey] waitUntilDone:NO];
            NSLog(@"Error happened = %@", error);
            loadingPaidOver = YES;
            [self performSelectorOnMainThread:@selector(showError:) withObject:[NSNumber numberWithInt:1] waitUntilDone:YES];
        }
    }];
    
}

- (void) jsonRequestFree:(NSString*)body {
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15 ];
    
    NSData *requestData = [NSData dataWithBytes:[body UTF8String] length:[body length]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data, NSError *error) {
        if ([data length] >0 && error == nil){
            freeJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            [self performSelectorInBackground:@selector(reloadFreeView) withObject:nil];
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
            loadingFreeOver = YES;
        }
        else if (error != nil){
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:[error.userInfo objectForKey:NSLocalizedDescriptionKey] waitUntilDone:NO];
            NSLog(@"Error happened = %@", error);
            loadingFreeOver = YES;
            [self performSelectorOnMainThread:@selector(showError:) withObject:[NSNumber numberWithInt:0] waitUntilDone:YES];
        }
    }];
    
}



- (void) showError:(NSNumber *)isPaid{
    UILabel *txtView = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 150, 60)];
    [txtView setText:@"Can't reach Story Pack Server, please try again."];
    UIButton *button;
    button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    if ([isPaid intValue] == 1)
        [button addTarget:self
                   action:@selector(retryPaid)
         forControlEvents:UIControlEventTouchDown];
    else
        [button addTarget:self
                   action:@selector(retryFree)
         forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Retry Server" forState:UIControlStateNormal];
    button.frame = IS_IPAD?CGRectMake(703, 28.0, 40.0, 40.0):CGRectMake(170, 0, 200.0, 60.0);
    if ([isPaid intValue] == 1){
        [paidStoryPacksView addSubview:txtView];
        [paidStoryPacksView addSubview:button];
    }
    else{
        [freeStoryPacksView addSubview:txtView];
        [freeStoryPacksView addSubview:button];
    }
    [self.loader setHidden:YES];
}

- (void) retryPaid{
    [self jsonRequestPaid:paidBody];
}

- (void) retryFree{
    [self jsonRequestFree:freeBody];
}


-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];

}
# pragma mark - story pack scroll views
-(void)showInstalledPacks
{
    NSString *docsDir;
    NSArray *dirPaths;
    StoryPackNames= [[NSMutableArray alloc]init];
    dbNames = [[NSMutableArray alloc]init];
    // Get the root directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // get the docs directory
    docsDir = dirPaths[0];
    NSString *storypacksDir = [docsDir stringByAppendingPathComponent:@"story_dir/story_packs/"];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *storyPacksList= [filemgr contentsOfDirectoryAtPath:storypacksDir error:nil];
    NSArray *defaultPacks = [[NSBundle mainBundle] pathsForResourcesOfType:@"db" inDirectory:@"StoryPacks"];
    NSMutableArray *allPacks = [[NSMutableArray alloc] init];
NSLog(@"StoryPacksList : %@",storyPacksList);
    int count = [storyPacksList count];
    for(int i=0; i<count; i++){
        if([[[storyPacksList[i] lastPathComponent] pathExtension] isEqualToString:@"db"])
          databasePath = [storypacksDir stringByAppendingPathComponent:storyPacksList[i]];
        [allPacks addObject:databasePath];
    }
    [allPacks addObjectsFromArray:defaultPacks];
    count = [allPacks count];
NSLog (@"number of all story packs :%i",count);
    float scrollViewHeight = [installedStoryPacksView bounds].size.height;
    float scrollViewWidth  = [installedStoryPacksView bounds].size.width;
    float xPosition = THUMB_H_PADDING;
    UIScrollView *installedStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    installedStoryPacksHolder.tag = 1;
    [installedStoryPacksHolder setCanCancelContentTouches:NO];
    [installedStoryPacksHolder setClipsToBounds:NO];
    for(UIView *view in installedStoryPacksView.subviews)
        [view removeFromSuperview];
    [installedStoryPacksHolder setHidden:NO];
    for(int i=0; i<count; i++){
        sqlite3 *db;
        if([[[allPacks[i] lastPathComponent] pathExtension] isEqualToString:@"db"])
        {
NSLog(@"allpacklist[%d] : %@",i,allPacks[i]);
            [dbNames addObject:allPacks[i]];
            databasePath = allPacks[i];
NSLog(@"database path : %@",databasePath);
            const char *dbpath = [allPacks[i] UTF8String];
NSLog(@"database path UTF8String: %s",dbpath);
            if (sqlite3_open(dbpath, & db) == SQLITE_OK){
NSLog(@"dbNames[%d] : %@ successfully opened.",i,dbNames[i]);
                NSString *sql = [NSString stringWithFormat:@"SELECT Name,ImageDataPNG_Base64 FROM StoryPackInfo;"];
                const char *sql_stmt = [sql UTF8String];
                sqlite3_stmt *compiled_stmt;
                
                int success =  sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, nil);
                NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(db), sqlite3_errcode(db));
                NSLog(@"success : %d",success);
                if(success == SQLITE_OK){
                    
                    
NSLog(@"SQL query Statement preparation on database success.");
                    if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
                        NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(compiled_stmt, 1)];
                        NSData *data = [NSData dataFromBase64String:dataAsString];
                        UIImage *image = [UIImage imageWithData:data];
                        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
                        //showing installed story pack's thubnail images
                        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
                        CGRect frame = [thumbView frame];
                        thumbView.layer.cornerRadius = RADIUS;
                        thumbView.clipsToBounds = YES;
                        [thumbView setContentMode:UIViewContentModeScaleAspectFit];
                        frame.origin.y = THUMB_V_PADDING;
                        frame.origin.x = xPosition;//thumb_H_padding
                        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
                        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
                        [thumbView setFrame:frame];
                        [thumbView setUserInteractionEnabled:YES];
                        [thumbView setHidden:NO];
                        //setting tap.
                        [thumbView setTag:i];
                        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInstallTap:)];
                        click.numberOfTapsRequired = 1;
                        [thumbView addGestureRecognizer:click];
                        [thumbView setUserInteractionEnabled:YES];
                        [installedStoryPacksHolder addSubview:thumbView];
                        
                        //story pack name
                        //showing storypackname
                        UILabel *storyPackName = [[UILabel alloc] init];
                        CGRect textFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + THUMB_V_PADDING, frame.size.width, NAME_LABEL_HEIGHT);
                        [storyPackName setOpaque:NO];
                        [storyPackName setBackgroundColor:nil];
                        [storyPackName setTextColor:[UIColor whiteColor]];
                        [storyPackName setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
                        [storyPackName setNumberOfLines:2];
                        storyPackName.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 0)];
                        [storyPackName setFrame:textFrame];
                        [storyPackName setHidden:NO];
                        [storyPackName setTag:i];
                        
                        UITapGestureRecognizer *nameClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleInstallTap:)];
                        nameClick.numberOfTapsRequired = 1;
                        [storyPackName addGestureRecognizer:nameClick];
                        [storyPackName setUserInteractionEnabled:YES];
                        [installedStoryPacksHolder addSubview:storyPackName];
//    [self getStoryName:storyPackName andDB:db];
                       xPosition += (frame.size.width + THUMB_H_PADDING);
                    }
                }
                
                sqlite3_finalize(compiled_stmt);
                sqlite3_close(db);
            }
            
        }
    }
    [installedStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [installedStoryPacksView addSubview:installedStoryPacksHolder];
}

- (void)getStoryName:(UILabel*)storyPackName andDB:(sqlite3*)database
{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT Name from StoryPackInfo;"];
    const char *sql_stmt = [sql UTF8String];
    sqlite3_stmt *compiled_stmt;
    if(sqlite3_prepare_v2(database, sql_stmt, -1, &compiled_stmt, NULL) == SQLITE_OK){
        if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
            storyPackName.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiled_stmt, 0)];
            sqlite3_finalize(compiled_stmt);
        }
    }
    sqlite3_finalize(compiled_stmt);
}
-(void)handleInstallTap:(UITapGestureRecognizer*)recognizer
{
NSLog(@"recognizer tag: %d",recognizer.view.tag);
    
    STInstalledStoryPacksViewController *installController = [[STInstalledStoryPacksViewController alloc] init];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"%@",deviceType);
    if([deviceType hasPrefix:@"iPad"]){
        installController =
        [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                   bundle:NULL] instantiateViewControllerWithIdentifier:@"installedStoryPacks"];
    }
    else{
        installController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"installedStoryPacks"];
    }
//NSLog(@"Path : %@",databasePath);
//    databasePath = [databasePath stringByDeletingLastPathComponent];
//NSLog(@"Path after deleting last path component: %@",databasePath);
//    databasePath = [databasePath stringByAppendingString:@"/"];
//    databasePath = [databasePath stringByAppendingString:dbNames[recognizer.view.tag]];
//NSLog(@"Path after appending : %@",databasePath);
    NSLog(@"dbnames[%d] : %@",recognizer.view.tag,dbNames[recognizer.view.tag]);
    installController.filePath =dbNames[recognizer.view.tag];
    [self.navigationController pushViewController:installController animated:YES];
}

//-(void)getPrice
//{
//    NSMutableSet * productIdentifiers = [[NSMutableSet alloc] init];
//    for(int i=0; i<[[paidJson valueForKey:@"st_list"] count]; i++)
//    {
//    [productIdentifiers addObject:[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"AppleStoreKey"]];
//    }
//    SKProductsRequest *productReq =  [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers ];
//    productReq.delegate = self;
//    [productReq start];
//}
//-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
//{
//    SKProduct *product = [[SKProduct alloc] init];
//    for(int i=0 ; i<[response.products count] ; i++)
//    {
//        product = [response.products objectAtIndex:i];
//        NSLocale *priceLocale = product.priceLocale;
//        NSDecimalNumber *price = product.price;
//        [self.priceArray addObject:[NSString stringWithFormat:NSLocalizedString(@"Price - %@%@", nil), [priceLocale objectForKey:NSLocaleCurrencySymbol], [price stringValue]]];
//    }
//}
//-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
//{
//   NSLog(@"Failed to load the list of Products : %@",error);
//}
//-(void)requestDidFinish:(SKRequest *)request
//{
//    
//}

-(void)reloadPaidView
{
//for showing paid story packs in scroll view
    
//    float scrollViewHeight = THUMB_HEIGHT + 3*THUMB_V_PADDING+NAME_LABEL_HEIGHT+PRICE_LABEL_HEIGHT;
    float scrollViewHeight = [paidStoryPacksView bounds].size.height;
    float scrollViewWidth  = [paidStoryPacksView bounds].size.width;
//    [paidStoryPacksView setBackgroundColor:[UIColor whiteColor]];
    float __block xPosition = THUMB_H_PADDING;
    UIScrollView *paidStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    paidStoryPacksHolder.tag = 1;
    [paidStoryPacksHolder setCanCancelContentTouches:NO];
    [paidStoryPacksHolder setClipsToBounds:NO];
    for(UIView *view in paidStoryPacksView.subviews)
    [view removeFromSuperview];
    [paidStoryPacksHolder setHidden:NO];
    while(!paidJson){       //checking for data
//        NSLog(@"NUll in paidJSON");
     continue;}
    
// [self getPrice];
    
    for (int i = 0; i<[[paidJson valueForKey:@"st_list"] count];i++)
    {
        NSData* data;
        
        internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
        if (!internetAvailable) {
            xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
            continue;
        }
        
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
        if (data==nil || data.length ==0) {
            xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
            continue;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
//showing paid story pack's thubnail images
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        thumbView.layer.cornerRadius = RADIUS;
        thumbView.clipsToBounds = YES;
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setHidden:NO];
//Implementing Tap on thumbnails
//        NSLog(@"[valueForKey:StoryPackID] intValue = %d",[[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]);
        [thumbView setTag:[[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        click.numberOfTapsRequired = 1;
        [thumbView addGestureRecognizer:click];
        [thumbView setUserInteractionEnabled:YES];
        [paidStoryPacksHolder addSubview:thumbView];
//showing storyPackName for paid packs
        UILabel *storyPackName = [[UILabel alloc] init];
        CGRect textFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + THUMB_V_PADDING, frame.size.width, NAME_LABEL_HEIGHT);
        [storyPackName setOpaque:NO];
        [storyPackName setBackgroundColor:nil];
        [storyPackName setTextColor:[UIColor whiteColor]];
        [storyPackName setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
        [storyPackName setNumberOfLines:2];
        storyPackName.text = [[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Name"];
//        storyPackName.text = @"Goldilocks and The three Bears";//test largest name!
        [storyPackName setFrame:textFrame];
        [storyPackName setHidden:NO];
//implementing tap on name label
        [storyPackName setTag:[[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]];
        UITapGestureRecognizer *nameClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        nameClick.numberOfTapsRequired = 1;
        [storyPackName addGestureRecognizer:nameClick];
        [storyPackName setUserInteractionEnabled:YES];
        [paidStoryPacksHolder addSubview:storyPackName];
//price display for paid story packs.
        UILabel *storyPackPrice = [[UILabel alloc] init];
        CGRect priceTextFrame = CGRectMake(frame.origin.x, textFrame.origin.y+textFrame.size.height+THUMB_V_PADDING, frame.size.width, PRICE_LABEL_HEIGHT);
        [storyPackPrice setOpaque:NO];
        [storyPackPrice setBackgroundColor:nil];
        [storyPackPrice setTextColor:[UIColor whiteColor]];
        [storyPackPrice setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
        [storyPackPrice setNumberOfLines:1];
//        storyPackPrice.text = [self.priceArray objectAtIndex:i];
        storyPackPrice.text = [NSString stringWithFormat:@"$%@",[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Price"]];
        [storyPackPrice setFrame:priceTextFrame];
        [storyPackPrice setHidden:NO];
//implementing tap on price label
        [storyPackPrice setTag:[[[[paidJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]];
        UITapGestureRecognizer *priceClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        priceClick.numberOfTapsRequired = 1;
        [storyPackPrice addGestureRecognizer:priceClick];
        [storyPackPrice setUserInteractionEnabled:YES];
        [paidStoryPacksHolder addSubview:storyPackPrice];
        [paidStoryPacksView addSubview:paidStoryPacksHolder];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
//    [paidStoryPacksHolder setAlpha:0.5]; //for knowing the bounds
//    [paidStoryPacksHolder setBackgroundColor:[UIColor blueColor]];  //for knowing the bounds
    [paidStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [paidStoryPacksView addSubview:paidStoryPacksHolder];
    
    loadingPaidOver = YES;
    
    if (loadingFreeOver) {
        [self.loader stopAnimating];
        [self.loader setHidden:TRUE];
    }
}
-(void)reloadFreeView
{
//for showing free story packs in scroll view

//    float scrollViewHeight = THUMB_HEIGHT + 4*THUMB_V_PADDING+NAME_LABEL_HEIGHT;
    float scrollViewHeight = [freeStoryPacksView bounds].size.height;
    float scrollViewWidth  = [freeStoryPacksView bounds].size.width;
//    [freeStoryPacksView setBackgroundColor:[UIColor whiteColor]];//for knowing the bounds
    UIScrollView *freeStoryPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    freeStoryPacksHolder.tag = 2;
    [freeStoryPacksHolder setCanCancelContentTouches:NO];
    [freeStoryPacksHolder setClipsToBounds:NO];
    float __block xPosition = THUMB_H_PADDING;
    while(!freeJson){
//        NSLog(@"NUll in freeJSON");
        continue;} ///waiting for getting data from server
    for (int i = 0; i<[[freeJson valueForKey:@"st_list"] count];i++)
    {
        NSData * data;
        internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
        if (!internetAvailable) {
            xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
            continue;
        }
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]]; //getting image data
        
        if (data==nil || data.length ==0) {
            xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
            continue;
        }
        
        UIImage *image = [UIImage imageWithData:data];
        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
//showing free story packs thumbnails
        UIImageView *thumbView = [[UIImageView alloc] initWithImage:stimage];
        CGRect frame = [thumbView frame];
        thumbView.layer.cornerRadius = RADIUS;
        thumbView.clipsToBounds = YES;
        frame.origin.y = THUMB_V_PADDING;
        frame.origin.x = xPosition;//thumb_H_padding
        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
        [thumbView setFrame:frame];
        [thumbView setHidden:NO];
//implementing Tap on storypack thumbnails
//        NSLog(@"valueForKey:StoryPackID = %d",[[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]);
        [thumbView setTag:[[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]];
        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        click.numberOfTapsRequired = 1;
        [thumbView addGestureRecognizer:click];
        [thumbView setUserInteractionEnabled:YES];
        [freeStoryPacksHolder addSubview:thumbView];
//showing storyPackName
        UILabel *storyPackName = [[UILabel alloc] init];
        CGRect textFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + THUMB_V_PADDING, frame.size.width, NAME_LABEL_HEIGHT);
        [storyPackName setBackgroundColor:nil];
        [storyPackName setTextColor:[UIColor whiteColor]];
        [storyPackName setFont:[UIFont fontWithName:@"Helvetica" size:fontSize]];
        [storyPackName setOpaque:NO];
        [storyPackName setNumberOfLines:2];
        storyPackName.text = [[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"Name"];
        [storyPackName setFrame:textFrame];
        [storyPackName setHidden:NO];
//implementing tap on storypack name
        [storyPackName setTag:[[[[freeJson valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"StoryPackID"] intValue]];
        UITapGestureRecognizer *nameClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
        nameClick.numberOfTapsRequired = 1;
        [storyPackName addGestureRecognizer:nameClick];
        [storyPackName setUserInteractionEnabled:YES];
        [freeStoryPacksHolder addSubview:storyPackName];
        [freeStoryPacksView addSubview:freeStoryPacksHolder];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }
    [freeStoryPacksHolder setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
    [freeStoryPacksHolder setHidden:NO];
//    [freeStoryPacksHolder setAlpha:0.5];//for knowing the bounds
//    [freeStoryPacksHolder setBackgroundColor:[UIColor blueColor]];//for knowing the bounds
    [freeStoryPacksView addSubview:freeStoryPacksHolder];
//stoping activity indicator
    
    loadingFreeOver = YES;
    
    if (loadingPaidOver) {
        [self.loader stopAnimating];
        [self.loader setHidden:TRUE];
    }
    
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    UIStoryboard *storyboard = [[UIStoryboard alloc] init];
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"%@",deviceType);
    if([deviceType hasPrefix:@"iPad"]){
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
    else{
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    }
//
//    NSLog(@"recognizer.view.superview.tag = %d",recognizer.view.superview.tag);
//    if(recognizer.view)
    if(recognizer.view.superview.tag == 1)
    {
        STPaidStoryPacksViewController *paidStoryPacks = [storyboard instantiateViewControllerWithIdentifier:@"paidStoryPacks"];
        
        paidStoryPacks.storyPackID = (unsigned int)recognizer.view.tag;
//        NSLog(@"recognizer.view.tag = %d",recognizer.view.tag);
//        NSLog(@"paidStoryPacks.storyPackID = %d",paidStoryPacks.storyPackID);

   [self.navigationController pushViewController:paidStoryPacks animated:YES];
    }
    else if(recognizer.view.superview.tag == 2)
    {
          STFreeStoryPacksViewController *freeStoryPacks = [storyboard instantiateViewControllerWithIdentifier:@"freeStoryPacks"];
        
        freeStoryPacks.storyPackID = (unsigned int)recognizer.view.tag;
//        NSLog(@"recognizer.view.tag = %d",recognizer.view.tag);
//        NSLog(@"freeStoryPacks.storyPackID = %d",freeStoryPacks.storyPackID);

      [self.navigationController pushViewController:freeStoryPacks animated:YES];
    
    }
}

- (void)viewDidUnload {
    [self setInstalledStoryPacksView:nil];
    [self setPaidStoryPacksView:nil];
    [self setFreeStoryPacksView:nil];
    [self setLoader:nil];
    [super viewDidUnload];
}
- (IBAction)previousView:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
