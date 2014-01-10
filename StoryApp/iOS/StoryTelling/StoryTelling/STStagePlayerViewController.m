//
//  STStagePlayerViewController.m
//  StoryTelling
//
//  Created by Aaswini on 10/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerViewController.h"
#import "STImage.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPAD ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height == 1024 ))
#define THUMB_HEIGHT (IS_IPAD ? 128 : 70)
#define IPHONE_5_ADDITIONAL 44
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define STATUS_BAR_HEIGHT 0


@interface STStagePlayerViewController (){
    
    NSArray *timeline;
    NSArray *instanceIDs;
    
    NSDictionary *instanceIDTable;
    NSDictionary *imagesTable;
    
    UIView *playerview;
    UIImageView *backgroundimageview;
    
}

@end

@implementation STStagePlayerViewController

@synthesize storyDB;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initialize];
    CGRect capturebounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    float thumbHeightBottom = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    if (IS_IPHONE_5) {
        thumbHeightBottom = THUMB_HEIGHT + THUMB_V_PADDING + IPHONE_5_ADDITIONAL * 2 ;
    }
    playerview = [[UIView alloc]init];
    [playerview setFrame:CGRectMake(0,thumbHeight,capturebounds.size.width,capturebounds.size.height-(thumbHeight + thumbHeightBottom)-STATUS_BAR_HEIGHT)];
    [playerview setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:playerview];

    CGRect bounds = [playerview bounds];
    backgroundimageview = [[UIImageView alloc]initWithFrame:bounds];
    backgroundimageview.contentMode = UIViewContentModeScaleToFill;
    [playerview addSubview:backgroundimageview];
    [self processTimeline];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) initialize{
    timeline = [storyDB getImageInstanceTimeline];
    instanceIDs = [storyDB getInstanceIDsAsString];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
    imagesTable = [storyDB getImagesTable];
}

-(BOOL)isInstanceBG:(int)instanceID{
    int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",instanceID]] intValue];
    STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
    if ([image.type isEqualToString:@"background"]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)processTimeline{
    

    for (int i=0; i<[timeline count]; i++) {
        STImageInstancePosition *position =timeline[i];
        if ([self isInstanceBG:position.imageInstanceId]) {
            int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];;
            STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
            [backgroundimageview setImage:image];
        }
        else{
            if (position.layer != -1) {
                if ([self isImageActing:position.imageInstanceId]) {
                    UIImageView *fgimageView = (UIImageView *) [playerview viewWithTag:position.imageInstanceId];
//                    [UIView beginAnimations:nil context:nil];
//                    [UIView setAnimationBeginsFromCurrentState:YES];
//                    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//                    [UIView setAnimationDuration:10];
//                    [fgimageView setCenter:CGPointMake(position.x, position.y)];
//                    [UIView commitAnimations];
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [UIView animateWithDuration:40.0f
                                          delay:0.1f
                                        options: UIViewAnimationOptionBeginFromCurrentState
                                     animations: ^(void){fgimageView.center = CGPointMake(position.x, position.y);}
                                     completion:NULL];
                        
                    });
                }
                else{
                    int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];;
                    STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                    [imageview setFrame:CGRectMake(position.x, position.y, image.sizeScale, image.sizeScale)];
                    [imageview setContentMode:UIViewContentModeScaleAspectFit];
                    
                    float widthRatio = imageview.bounds.size.width / imageview.image.size.width;
                    float heightRatio = imageview.bounds.size.height / imageview.image.size.height;
                    float scale = MIN(widthRatio, heightRatio);
                    float imageWidth = scale * imageview.image.size.width;
                    float imageHeight = scale * imageview.image.size.height;
                    
                    imageview.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageWidth, imageHeight);
                    
                    [imageview setTag:position.imageInstanceId];
                    
                    [imageview bringToFront];
                    
                    [playerview addSubview:imageview];
                    
                }
            }
            else{
                //[[playerview viewWithTag:position.imageInstanceId] removeFromSuperview ];
                
            }
        }
        
    }
}

- (BOOL) isImageActing:(int)instanceID{
    for (UIView *subview in [playerview subviews]) {
        if ([subview tag] == instanceID) {
            return YES;
        }
    }
    return NO;
}

@end
