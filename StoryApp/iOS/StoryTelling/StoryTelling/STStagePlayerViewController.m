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
    int i, pausedAt ;
    
    STPlayerToolbar  * toolbar_view;
    
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
    [self.view removeConstraints:self.view.constraints];
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
    [playerview setClipsToBounds:YES];
    [self.view addSubview:playerview];
    
    CGRect bounds = [playerview bounds];
    backgroundimageview = [[UIImageView alloc]initWithFrame:bounds];
    backgroundimageview.contentMode = UIViewContentModeScaleToFill;
    [playerview addSubview:backgroundimageview];
    
    TopRightView *back_btn_view = [[TopRightView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [back_btn_view setMydelegate:self];
    [self.view addSubview:back_btn_view];
  
    toolbar_view = [[STPlayerToolbar alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [toolbar_view setMydelegate:self];
    [toolbar_view.slider setMinimumValue:0];
    [toolbar_view.slider setMaximumValue:[timeline count]];
    [self.view addSubview:toolbar_view];
    
}

-(void)viewDidAppear:(BOOL)animated{
    i=0;
    pausedAt =0 ;
    [self performSelectorOnMainThread:@selector(processTimeline) withObject:nil waitUntilDone:NO];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [toolbar_view initialize];
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
    
    for (STImageInstancePosition *position in timeline) {
        NSLog(@"%f",position.timecode);
    }
    
    
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

-(void) setSliderValue:(NSNumber *)value{
    [toolbar_view.slider setValue:[value floatValue]];
}

-(void)processTimeline{
    
    if(i < [timeline count]){
        [self performSelectorOnMainThread:@selector(setSliderValue:) withObject:[NSNumber numberWithFloat:i] waitUntilDone:YES] ;
        STImageInstancePosition *position =timeline[i];
        i++;
        if ([self isInstanceBG:position.imageInstanceId]) {
            int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];;
            STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
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
                    NSArray *params = [NSArray arrayWithObjects:fgimageView, position, nil];
                    [self performSelectorOnMainThread:@selector(getGesturevalues:) withObject:params waitUntilDone:YES];
                }
                else{
                    int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];;
                    STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",imageID]];
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                    [imageview setFrame:CGRectMake(position.x, position.y, image.sizeScale, image.sizeScale)];
                    [imageview setCenter:CGPointMake(position.x, position.y)];
                    [imageview setContentMode:UIViewContentModeScaleAspectFit];
                    
                    float widthRatio = imageview.bounds.size.width / imageview.image.size.width;
                    float heightRatio = imageview.bounds.size.height / imageview.image.size.height;
                    float scale = MIN(widthRatio, heightRatio);
                    float imageWidth = scale * imageview.image.size.width;
                    float imageHeight = scale * imageview.image.size.height;
                    
                    [self performSelectorOnMainThread:@selector(addFGimage:) withObject:imageview waitUntilDone:YES];
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
                [[playerview viewWithTag:position.imageInstanceId] removeFromSuperview ];
                i++;
                [self processTimeline];
            }
        }
        if (i>=[timeline count]) {
            
        [toolbar_view.slider setValue:0];
        [toolbar_view.playBtn setTitle:@"Play" forState:UIControlStateNormal];
            i= 0;
            pausedAt=0;
        }
    }
}

-(void)setBGImage:(STImage*)bgimage{
    [backgroundimageview setImage:bgimage];
}

-(void) addFGimage:(UIView*)view{
    [playerview addSubview:view];
}

-(void)getGesturevalues : (NSArray *)values{
    
    UIView *view = values[0];
    STImageInstancePosition *positionvalue = values[1];
    
    [UIView animateWithDuration:0
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         [view bringToFront];
                         
                         if(positionvalue.rotation != 0){
                             [view setTransform:CGAffineTransformRotate(view.transform, positionvalue.rotation)];
                         }
                         else if(positionvalue.scale != 1){
                             [view setTransform:CGAffineTransformScale(view.transform, positionvalue.scale, positionvalue.scale)];
                         }
                         else{
                             [view setCenter:CGPointMake(positionvalue.x, positionvalue.y)];
                         }
                     }completion:^(BOOL finished){
                         
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

-(void)doneBtnClicked{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pauseBtnClicked{
    pausedAt = i;
    i= [timeline count];
}

-(void)playBtnClicked{
    i = pausedAt;
    pausedAt =0;
    [self processTimeline];
    
}



@end
