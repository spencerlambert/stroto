//
//  STStagePlayerViewController.m
//  StoryTelling
//
//  Created by Aaswini on 10/01/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerViewController.h"
#import "STImage.h"
#import "STStagePlayerView.h"

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
    
    STStagePlayerView *playerview;
    int i, pausedAt ;
    
    NSTimer *timer;
    NSTimer *timer1;
    float processingTime;
    float remainingProcessingTime;
    bool timerPaused;
    
    STPlayerToolbar  * toolbar_view;
    
    NSDictionary *audioTimeline;
    AVAudioPlayer *audioplayer;
    
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
    if (storyDB != nil) {
        [storyDB closeDB];
        storyDB = nil;
    }
    storyDB = [STStoryDB loadSTstoryDB:self.dbname];
    [self initialize];
    CGRect capturebounds = [[UIScreen mainScreen] bounds];
    float thumbHeight = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    float thumbHeightBottom = THUMB_HEIGHT + THUMB_V_PADDING * 2 ;
    if (IS_IPHONE_5) {
        thumbHeightBottom = THUMB_HEIGHT + THUMB_V_PADDING + IPHONE_5_ADDITIONAL * 2 ;
    }
    playerview = [[STStagePlayerView alloc]init];
    [playerview setFrame:CGRectMake(0,thumbHeight,capturebounds.size.width,capturebounds.size.height-(thumbHeight + thumbHeightBottom)-STATUS_BAR_HEIGHT)];
    [playerview setBackgroundColor:[UIColor whiteColor]];
    [playerview setClipsToBounds:YES];
    [self.view addSubview:playerview];
    
    toolbar_view = [[STPlayerToolbar alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [toolbar_view setMydelegate:self];
    [toolbar_view.slider setMinimumValue:0];
    
    [playerview setSlider:toolbar_view.slider];
    [playerview setFrameRate:22.0f];
    [playerview setStoryDB:storyDB];
    
    TopRightView *back_btn_view = [[TopRightView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [back_btn_view setMydelegate:self];
    [self.view addSubview:back_btn_view];

    [self.view addSubview:toolbar_view];
    

}


-(void)viewDidAppear:(BOOL)animated{
    [playerview startPlaying];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [toolbar_view initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) initialize{
    
    timeline = [self getProcessedTimeline:[storyDB getImageInstanceTimeline]];
    instanceIDs = [storyDB getInstanceIDsAsString];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
    imagesTable = [storyDB getImagesTable];
    
//    audioTimeline = [storyDB getAudio];
//    if([audioTimeline count] >0){
//        STAudio *audio = [audioTimeline objectForKey:[[audioTimeline allKeys]objectAtIndex:0]];
//        audioplayer = [[AVAudioPlayer alloc]initWithData:audio.audio error:nil];
//        [audioplayer play];
//    }
    
}

-(NSArray *)getProcessedTimeline:(NSArray *)timeline{
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (STImageInstancePosition *position in timeline) {
        STStagePlayerFrame *frame = [[STStagePlayerFrame alloc]initWithFrame:position atTimecode:position.timecode];
        [frames addObject:frame];
    }
    return frames;
}


-(void)doneBtnClicked{
    
    [storyDB closeDB];
    storyDB = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pauseBtnClicked{
    [playerview stopPlaying];
}

-(void)playBtnClicked{
    [playerview startPlaying];
}




@end
