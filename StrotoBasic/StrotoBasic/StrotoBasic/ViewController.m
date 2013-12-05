//
//  ViewController.m
//  StrotoBasic
//
//  Created by Nandakumar on 29/10/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))

#define THUMB_HEIGHT (IS_IPAD ? 305 : 130)
#define THUMB_V_PADDING (IS_IPAD ? 30 : 20)
#define THUMB_H_PADDING (IS_IPAD ? 25 : 18)
#define RADIUS (IS_IPAD ? 25 :15 )

#define urlAsString [NSString stringWithFormat:@"http://storypacks.stroto.com"]
#define freeBody [NSString stringWithFormat:@"{\"st_request\":\"get_free_list\"}"]

#import "ViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController
{
    BOOL internetAvailable;
}
@synthesize storyPacksView;
@synthesize basicJsonDict;

float scrollViewHeight,scrollViewWidth,xPosition,yPosition;
UIScrollView *storyPacksHolder;
NSArray *storyPacksList;

-(void)viewWillAppear:(BOOL)animated
{
    [self performSelector:@selector(checkNetwork) withObject:nil afterDelay:0];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [((AppDelegate *)[[UIApplication sharedApplication]delegate]) internetAvailableNotifier];
//    internetAvailable = ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable;
//   [self internetAvailableNotifier];
//      NSLog(@"internet availability view controller: %hhd", ((AppDelegate *)[[UIApplication sharedApplication]delegate]).internetAvailable);
//    if (internetAvailable)
//        [self performSelectorInBackground:@selector(jsonRequest) withObject:nil];
//    else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    [self showStoryPacks];
//    }
}

-(void)checkNetwork
{
    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com/m"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        {
            NSLog(@"Device is connected to the internet");
            internetAvailable = 1;
            [self performSelectorInBackground:@selector(jsonRequest) withObject:nil];
            }
    else
        {
            NSLog(@"Device is not connected to the internet");
            internetAvailable = 0;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"The device data is off, please turn it on to access the downloadable Story Packs" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                   [alert show];
            
            }
   
}
-(void)internetAvailableNotifier{
    Reachability *internetReachable;
    
    internetReachable = [Reachability reachabilityWithHostname:@"storypacks.stroto.com"];
    
    // Internet is reachable
    internetReachable.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            internetAvailable = YES;
            NSLog(@"internet availability app delegate: %hhd", internetAvailable);
        });
    };
    
    // Internet is not reachable
    internetReachable.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            internetAvailable = NO;
            NSLog(@"internet availability app delegate: %hhd", internetAvailable);
        });
    };
    
    [internetReachable startNotifier];
    
}


- (void) jsonRequest{
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15 ];
    NSData *requestData = [NSData dataWithBytes:[freeBody UTF8String] length:[freeBody length]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:requestData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response,NSData *data,NSError *error) {
            if ([data length] >0 && error == nil){
                basicJsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                [self performSelectorInBackground:@selector(showStoryPacks) withObject:nil];
            }
            else if ([data length] == 0 && error == nil){
                NSLog(@"Nothing was downloaded.");
            }
            else if (error != nil){
                [self performSelectorOnMainThread:@selector(showAlert:) withObject:[error.userInfo objectForKey:NSLocalizedDescriptionKey] waitUntilDone:NO];
                NSLog(@"Error happened = %@", error);
                [self performSelectorOnMainThread:@selector(showError) withObject:nil waitUntilDone:YES];
            }
        }];
        
}

-(void)showStoryPacks
{
//    storyPacksList= [[NSBundle mainBundle] pathsForResourcesOfType:@"db" inDirectory:@"StoryPacks"];
NSLog(@"StoryPacksList : %@",storyPacksList);
    int count = [[basicJsonDict valueForKey:@"st_list"] count];
NSLog (@"number of story packs :%i",count);
    float holderWidth=0;
    scrollViewHeight = [storyPacksView bounds].size.height;
    scrollViewWidth  = [storyPacksView bounds].size.width;
    xPosition = (IS_IPAD ? 60 : THUMB_H_PADDING);
    yPosition = (IS_IPAD ? 30 : THUMB_V_PADDING);
    storyPacksHolder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    [storyPacksHolder setAutoresizesSubviews:YES];
//    [storyPacksHolder setBackgroundColor:[UIColor greenColor]];
    [storyPacksHolder setPagingEnabled:YES];
    [storyPacksHolder setBounces:YES];
    storyPacksHolder.tag = 1;
    [storyPacksHolder setCanCancelContentTouches:NO];
    [storyPacksHolder setClipsToBounds:NO];
    for(UIView *view in storyPacksView.subviews)
        [view removeFromSuperview];
    [storyPacksHolder setHidden:NO];
    int i=0;
    int page = 0;
    do
    {
    for(int k=0; k<3; k++)
    {
        for(int j=0; j<2;j++)
        {
//        sqlite3 *db;
            if(i== count) break;
        if([[[basicJsonDict valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"])
        {
//            const char *dbpath = [storyPacksList[i] UTF8String];
//NSLog(@"database path UTF8String: %s",dbpath);
//            if (sqlite3_open(dbpath, & db) == SQLITE_OK){
//NSLog(@"storyPacksList[%d] : %@ successfully opened.",i,storyPacksList[i]);
//                NSString *sql = [NSString stringWithFormat:@"SELECT Name,ImageDataPNG_Base64 FROM StoryPackInfo;"];
//                const char *sql_stmt = [sql UTF8String];
//                sqlite3_stmt *compiled_stmt;
//                int success =  sqlite3_prepare_v2(db, sql_stmt, -1, &compiled_stmt, nil);
//                NSLog(@"%s SQLITE_ERROR '%s' (%1d)", __FUNCTION__, sqlite3_errmsg(db), sqlite3_errcode(db));
//                NSLog(@"success : %d",success);
//                if(success == SQLITE_OK){
//                    NSLog(@"SQL query Statement preparation on database success.");
//                    if(sqlite3_step(compiled_stmt) == SQLITE_ROW){
//                        NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(compiled_stmt, 1)];
                        
                        
                        
                       NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[basicJsonDict valueForKey:@"st_list"] objectAtIndex:i] valueForKey:@"ThumbnailURL"]]];
                        
                        
                        
                        
//                        NSData *data = [NSData dataFromBase64String:dataAsString];
                        UIImage *image = [UIImage imageWithData:data];
//                        STImage *stimage = [[STImage alloc] initWithCGImage:[image CGImage]];
                        UIImageView *thumbView = [[UIImageView alloc] initWithImage:image];
//                        thumbView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                        thumbView.layer.cornerRadius = RADIUS;
                        thumbView.clipsToBounds = YES;
                        CGRect frame = [thumbView frame];
                        [thumbView setContentMode:UIViewContentModeScaleAspectFit];
                        frame.origin.y = yPosition;
                        frame.origin.x = xPosition;//thumb_H_padding
                        frame.size.width = THUMB_HEIGHT; //thumbImage.size.width;
                        frame.size.height = THUMB_HEIGHT; // thumbImage.size.height;
                        [thumbView setFrame:frame];
                        [thumbView setUserInteractionEnabled:YES];
                        [thumbView setHidden:NO];
                        //setting tap.
                        [thumbView setTag:i];
                        UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
                        click.numberOfTapsRequired = 1;
                        [thumbView addGestureRecognizer:click];
                        [thumbView setUserInteractionEnabled:YES];
//                        NSLog(@"thumbView autoresizing mask = %d",thumbView.autoresizingMask);
                        [storyPacksHolder addSubview:thumbView];
                        xPosition += (THUMB_HEIGHT + THUMB_H_PADDING);
                        
//                    }
//                }
                
//                sqlite3_finalize(compiled_stmt);
//                sqlite3_close(db);
//            }
//            NSLog(@"Story i = %d ,\n xPos = %f , ypos = %f",i,xPosition,yPosition);
        }
            i++;
            if(i == count)
                break;
        }
         holderWidth +=xPosition;
//        xPosition = storyPacksView.bounds.size.width * page + THUMB_H_PADDING ;
        xPosition = storyPacksView.bounds.size.width * page + (IS_IPAD ? 60 : THUMB_H_PADDING);
        yPosition += (THUMB_HEIGHT + THUMB_V_PADDING);
//        yPosition += (THUMB_HEIGHT + 30);
        if(i == count)
        {
            break;
        }
}
        {
            page++;
//            xPosition = storyPacksView.bounds.size.width * page + THUMB_H_PADDING ;
            xPosition = storyPacksView.bounds.size.width * page + (IS_IPAD ? 60 : THUMB_H_PADDING) ;
//            yPosition = THUMB_V_PADDING;
            yPosition = (IS_IPAD ? 30 : THUMB_V_PADDING);
        }
//        NSLog(@"Width : %f",storyPacksView.bounds.size.width);
    holderWidth=storyPacksView.bounds.size.width*page;
    }while(page<=(count/6));
    [storyPacksHolder setContentSize:CGSizeMake(holderWidth, scrollViewHeight)];
//    NSLog(@"storyPacksHolder default autoresizesSubviews = %hhd",storyPacksHolder.autoresizesSubviews);
    [storyPacksView addSubview:storyPacksHolder];
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    playViewController *playGround = [[playViewController alloc] init];
 if(IS_IPAD)
     playGround = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"playGround"];
    else
        playGround = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"playGround"];
    playGround.dbName =storyPacksList[recognizer.view.tag];
    [self presentViewController:playGround animated:YES completion:nil];
}

-(void)showAlert:(NSString*)message{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void) showError{
    UILabel *txtView = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 150, 60)];
    [txtView setText:@"Can't reach Story Pack Server, please try again."];
    UIButton *button;
    button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Retry Server" forState:UIControlStateNormal];
    button.frame = IS_IPAD?CGRectMake(703, 28.0, 40.0, 40.0):CGRectMake(170, 0, 200.0, 60.0);
    [self.storyPacksView addSubview:txtView];
    [self.storyPacksView addSubview:button];
}

- (void) retry{
    [self jsonRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
