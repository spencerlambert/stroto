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
    int i;
    
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
    i=0;
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
    }

-(void)viewDidAppear:(BOOL)animated{
    
    [self performSelectorOnMainThread:@selector(processTimeline) withObject:nil waitUntilDone:NO];
//    [self processTimeline];

    
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
    

    //for (int i=0; i<[timeline count]; i++)
    if(i < [timeline count]){
        STImageInstancePosition *position =timeline[i];
        i++;
        if ([self isInstanceBG:position.imageInstanceId]) {
            int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];;
            STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [backgroundimageview setImage:image];
//            });
            [self performSelectorOnMainThread:@selector(setBGImage:) withObject:image waitUntilDone:YES];
            if(timeline[i]!=nil){
                  STImageInstancePosition *position1 =timeline[i];
                float tempvalue = position1.timecode - position.timecode ;
                [self performSelector:@selector(processTimeline) withObject:nil afterDelay:tempvalue/1000];
            }
        }
        else{
            if (position.layer != -1) {
                if ([self isImageActing:position.imageInstanceId]) {
                    UIImageView *fgimageView = (UIImageView *) [playerview viewWithTag:position.imageInstanceId];
                    
//                    dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    [UIView animateWithDuration:10.0f
//                                          delay:.1f
//                                        options: UIViewAnimationOptionBeginFromCurrentState
//                                     animations: ^(void){fgimageView.center = CGPointMake(position.x, position.y);}
//                                     completion:NULL];
//                        
//                    });
//                    [self temp:fgimageView withPosition:CGPointMake(position.x, position.y)];
                    NSArray *params = [NSArray arrayWithObjects:fgimageView, [NSNumber numberWithInt:position.x], [NSNumber numberWithInt:position.y], nil];
                    //[self performSelectorOnMainThread:@selector(getPanvalues:) withObject:params waitUntilDone:YES];
                     if(position.rotation != 0){
                        //   if ([self isImageActing:position.imageInstanceId]) {
                      
                        NSArray *params1 = [NSArray arrayWithObjects:fgimageView, [NSNumber numberWithFloat:position.rotation], nil];
                        [self performSelectorOnMainThread:@selector(getRotatevalues:) withObject:params1 waitUntilDone:YES];
                    }
                     else{
                         if(timeline[i]!=nil){
                             STImageInstancePosition *position1 =timeline[i];
                             float tempvalue = position1.timecode - position.timecode ;
                             [self performSelector:@selector(processTimeline) withObject:nil afterDelay:tempvalue/1000];
                         }
                     }
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
                    
                    [self performSelectorOnMainThread:@selector(addFGimage:) withObject:imageview waitUntilDone:YES];
                    
                    
//                    dispatch_async(dispatch_get_main_queue(), ^(void) {
//                        [playerview addSubview:imageview];
//                    });
                    
                    imageview.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageWidth, imageHeight);
                    
                    [imageview setTag:position.imageInstanceId];
                    
                    [imageview bringToFront];
                    
                    if(timeline[i]!=nil){
                        STImageInstancePosition *position1 =timeline[i];
                        float tempvalue = position1.timecode - position.timecode ;
                        [self performSelector:@selector(processTimeline) withObject:nil afterDelay:tempvalue/1000];

                    }

                    
                }
            }
            else{
                //[[playerview viewWithTag:position.imageInstanceId] removeFromSuperview ];
                
            }
        }
        
    }
}

-(void)setBGImage:(STImage*)bgimage{
    [backgroundimageview setImage:bgimage];
}

-(void) addFGimage:(UIView*)view{
    [playerview addSubview:view];
}

-(void)getPanvalues : (NSArray*)values{
    
    UIView *view = values[0];
    NSNumber *x = values[1];
    NSNumber *y = values[2];
//                        [UIView beginAnimations:nil context:nil];
    
//                        [UIView setAnimationBeginsFromCurrentState:YES];
//                        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//                        [UIView setAnimationDuration:10];
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//    [view setCenter:CGPointMake(position.x, position.y)];
//    });
//                        [UIView commitAnimations];

    [UIView animateWithDuration:.1
                          delay:0.1
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
    [view setCenter:CGPointMake([x intValue], [y intValue])];
                         //                         [token setFrame:CGRectMake(xx, 0, 64, 64)];
                         //here you may add any othe actions, but notice, that ALL of them will do in SINGLE step. so, we setting ONLY xx coordinate to move it horizantly first.
                     }
                     completion:^(BOOL finished){
                         if(timeline[i]!=nil){
                             STImageInstancePosition *position = timeline[i-1];
                             STImageInstancePosition *position1 =timeline[i];
                             
                             float tempvalue = position1.timecode - position.timecode ;
                             [self performSelector:@selector(processTimeline) withObject:nil afterDelay:tempvalue/1000];

                         }
                     }];
    
}

-(void)getRotatevalues : (NSArray *) values{
    
    UIView *view = values[0];
    NSNumber *x = values[1];
    
        [UIView animateWithDuration:.1 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            [view setTransform:CGAffineTransformRotate(view.transform, [x floatValue])];
            
        } completion:^(BOOL finished) {
           // if (finished && !CGAffineTransformEqualToTransform(view.transform, CGAffineTransformIdentity)) {
                if(timeline[i]!=nil){
                    STImageInstancePosition *position = timeline[i-1];
                    STImageInstancePosition *position1 =timeline[i];
                    
                    float tempvalue = position1.timecode - position.timecode ;
                
               [self performSelector:@selector(processTimeline) withObject:nil afterDelay:tempvalue/1000];
                }
        }];
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
