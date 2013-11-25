//
//  playViewController.m
//  StrotoBasic
//
//  Created by Nandakumar on 01/11/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//

#import "playViewController.h"
#import "UIView+Hierarchy.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 128 : 70)  //128 : 70
#define IPHONE_5_ADDITIONAL 44
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10

@interface playViewController ()<TopRightViewDelegate>

@end

@implementation playViewController

@synthesize dbName;
@synthesize selectedForegroundImage;
@synthesize playView;

UIButton *button ;
NSString *bgQuery = @"SELECT ImageDataPNG_Base64, ImageType, DefaultScale  FROM Images WHERE ImageType='Background';";
NSString *fgQuery = @"SELECT ImageDataPNG_Base64, ImageType, DefaultScale  FROM Images WHERE ImageType='Foreground';";

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
    int code = sqlite3_open_v2([dbName UTF8String], &database,SQLITE_OPEN_READWRITE,NULL);
    if (code != SQLITE_OK) {
        NSLog(@"Failed to open database!");
    }
    else{
        NSLog(@"DB Successfully Initialized with code : %d", code);
    }
    NSMutableArray *arrayAndQuery = [[NSMutableArray alloc] init];
    bgImagesArray = [[NSMutableArray alloc] init];
    arrayAndQuery = [NSMutableArray arrayWithObjects:bgImagesArray, bgQuery,nil];
    NSLog(@"arrayAndQuery : %@ ",arrayAndQuery);
    [self performSelectorOnMainThread:@selector(getImagesFromDB:) withObject:arrayAndQuery waitUntilDone:YES];
    fgImagesArray = [[NSMutableArray alloc] init];
    arrayAndQuery = [NSMutableArray arrayWithObjects:fgImagesArray,fgQuery, nil];
    [self performSelectorOnMainThread:@selector(getImagesFromDB:) withObject:arrayAndQuery waitUntilDone:YES];
    
    [self setSelectedForegroundImage:nil];
    CGRect playbounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    float thumbHeightBottom = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    if(IS_IPHONE_5) {
        thumbHeightBottom = THUMB_HEIGHT + THUMB_V_PADDING + IPHONE_5_ADDITIONAL * 2 ;
        }
    imageSelected = NO;
    pickedImages = [[NSMutableArray alloc]init];
    
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)];
    rotate.delegate = self;
    
    CGRect bounds = [playView bounds];
    bgImageView = [[UIImageView alloc]initWithFrame:bounds];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    [bgImageView setUserInteractionEnabled:YES];
    [playView addSubview:bgImageView];
    bgImageView.image = [UIImage imageNamed:@"RecordArea.png"];
    
    CGRect frame = CGRectMake(0, CGRectGetMaxY(playbounds)-thumbHeightBottom, playbounds.size.width, thumbHeightBottom);
    UIImageView *bottombar = [[UIImageView alloc]initWithFrame:frame];
    [bottombar setImage:[UIImage imageNamed:@"BottomBar.png"]];
    [self.view addSubview:bottombar];
    
    frame = CGRectMake(CGRectGetMinX(playbounds), CGRectGetMinY(playbounds), playbounds.size.width, thumbHeight);
    UIImageView *topbar = [[UIImageView alloc]initWithFrame:frame];
    [topbar setImage:[UIImage imageNamed:@"TopBar.png"]];
    [self.view addSubview:topbar];
    
    bgImages = [[SlideUpView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    bgImages.mydelegate = self;
    [bgImages setPhotos:bgImagesArray];
    [bgImages createThumbScrollViewIfNecessary];
    [self.view addSubview:bgImages];
    
    fgImages = [[SlideDownView alloc]initWithFrame:CGRectMake(0,0,0,0)];
    fgImages.mydelegate = self;
    [fgImages setPhotos:fgImagesArray];
    [fgImages createThumbScrollViewIfNecessary];
    [self.view addSubview:fgImages];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    TopRightView *doneView = [[TopRightView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [doneView setMydelegate:self];
    [self.view addSubview:doneView];
    
    button= [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(closeBtn)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = IS_IPAD?CGRectMake(703, 28.0, 40.0, 40.0):CGRectMake(294.0, 15.0, 20.0, 20.0);
    [button setBackgroundImage:[UIImage imageNamed:@"color_trans.png" ]forState:UIControlStateNormal];
    [bgImageView addSubview:button];
}
-(void)closeBtn{
    bgImageView.image = [UIImage imageNamed:@"RecordAreaBlank.png"];
    [button setEnabled:NO];
}
-(void)goBack{
    ViewController *stories = [[ViewController alloc] init];
    if(IS_IPAD)
        stories = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"rootView"];
    else
        stories = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"rootView"];
    [self presentViewController:stories animated:YES completion:nil];
}
-(void)getImagesFromDB:(NSArray*)imagesArraywithQuery
{
    sqlite3_stmt *statement;
    switch (sqlite3_prepare_v2(database, [imagesArraywithQuery[1] UTF8String], -1, &statement, nil))
    {
        case SQLITE_OK:
            NSLog(@"SQLITE_OK");
            while (sqlite3_step(statement) == SQLITE_ROW){
                NSString *dataAsString = [NSString stringWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
                NSData *data = [NSData dataFromBase64String:dataAsString];
                UIImage *image = [UIImage imageWithData:data];
                [((NSMutableArray*)[imagesArraywithQuery objectAtIndex:0]) addObject:image];
            }
            break;
        case SQLITE_ERROR:
            
            NSLog(@"SQLITE_ERROR : %d", sqlite3_step(statement));
            break;
            
        case SQLITE_INTERNAL:
            NSLog(@"SQLITE_INTERNAL");
            break;
            
        case SQLITE_BUSY:
            NSLog(@"SQLITE_BUSY");
            break;
            
        case SQLITE_MISMATCH:
            NSLog(@"SQLITE_MISMATCH");
            break;
        default:
            NSLog(@"Default...");
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doSingleTap:(UIGestureRecognizer *) gestureRecognizer {
    //[slideupview toggleThumbView];
    //[slidedownview toggleThumbView];
    
    if([self selectedForegroundImage]!=nil){
        
        CGPoint point=[gestureRecognizer locationInView:self.view];
        NSLog(@"%f %f",point.x,point.y);
        
        //        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(point.x-50,point.y-(60+20)-50, 100, 100)];
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(point.x-((IS_IPAD?200:100)/2),point.y-(60+20)-((IS_IPAD?200:100)/2), (IS_IPAD?200:100), (IS_IPAD?200:100))];
        imageview.image=selectedForegroundImage;
        [imageview setContentMode:UIViewContentModeScaleAspectFit];
        [playView addSubview:imageview];
        
        float widthRatio = imageview.bounds.size.width / imageview.image.size.width;
        float heightRatio = imageview.bounds.size.height / imageview.image.size.height;
        float scale = MIN(widthRatio, heightRatio);
        float imageWidth = scale * imageview.image.size.width;
        float imageHeight = scale * imageview.image.size.height;
        
        imageview.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageWidth, imageHeight);
        //        [captureview actortoStage:selectedForegroundImage];
        [imageview bringToFront];
        pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        pan.delegate = self;
        pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
        pinch.delegate = self;
        rotate = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotate:)];
        rotate.delegate = self;
        tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tap.delegate=self;
        [imageview setUserInteractionEnabled:YES];
        [imageview addGestureRecognizer:pan];
        [imageview addGestureRecognizer:pinch];
        [imageview addGestureRecognizer:rotate];
        [imageview addGestureRecognizer:tap];
        
        [self setSelectedForegroundImage:nil];
        [fgImages clearBorder];
        for(UIView *subviews in [playView subviews])
        {
            [subviews setUserInteractionEnabled:YES];
        }
    }
    
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(bgImages.superview != nil){
        if([touch.view isDescendantOfView:bgImages]){
            return NO;
        }
    }
    if(fgImages.superview != nil){
        if([touch.view isDescendantOfView:fgImages]){
            return NO;
        }
    }
    return YES;
}

#pragma mark SlideUpViewDelegate methods

- (void) setWorkspaceBackground:(UIImage *)selectedImage{
    bgImageView.image = selectedImage;
    // [captureview actortoStage:selectedImage];
    [button setEnabled:NO];
}

//adding foreground image to work area
-(void) setForegroundImage:(UIImage *)selectedImage{
    if(selectedImage != nil)
    {
        for (UIView *subviews in [playView subviews]) {
            [subviews setUserInteractionEnabled:NO];
        }
    [self setSelectedForegroundImage:selectedImage];
    NSLog(@"%@", [selectedImage description]);
    NSLog(@"foreground image set");
    }
    else{
        for (UIView *subviews in [playView subviews]) {
            [subviews setUserInteractionEnabled:YES];
        }
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    [recognizer.view bringToFront];
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    [recognizer.view bringToFront];
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    [recognizer.view bringToFront];
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

-(IBAction)handleTap:(UITapGestureRecognizer*)recognizer{
    [recognizer.view bringToFront];
}


@end
