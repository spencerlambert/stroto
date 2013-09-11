//
//  WorkAreaController.h
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideUpView.h"
#import "SlideDownView.h"
#import "SlideLeftView.h"
#import "ScreenCaptureView.h"
#import "AudioRecorder.h"
#import "UIView+Hierarchy.h"
#import "BottomRight.h"
#import "TopRightView.h"
#import "STStage.h"
#import "STStoryDB.h"

@protocol WorkAreaDelegate <NSObject>

-(void) finishedRecording;

@end

@interface WorkAreaController : UIViewController<UIGestureRecognizerDelegate,SlideUpViewDelegate,SlideDownViewDelegate,BottomRightViewDelegate,TopRightViewDelegate>{
    SlideUpView *slideupview;
    SlideDownView *slidedownview;
    SlideLeftView *slideleftview;
    BOOL toolbarsvisible;
    UIImageView *backgroundimageview;
    AudioRecorder *audiorecorder;
    NSMutableArray *pickedimages;
    BOOL imageselected;
    UIImageView *selectedimage;
    UIPanGestureRecognizer *pan;
    UIPinchGestureRecognizer *pinch;
    UIRotationGestureRecognizer *rotate;
    UITapGestureRecognizer *tap;
    UIView *loaderView;
    BOOL recordbtnClicked;
}
//@property (weak, nonatomic) IBOutlet STStage *captureview;
@property (weak, nonatomic) IBOutlet ScreenCaptureView *captureview;
@property (strong, nonatomic) NSMutableArray *backgroundImages;
@property (strong, nonatomic) NSMutableArray *foregroundImages;
@property (strong, nonatomic) NSString *storyname;
@property (strong, nonatomic) STImage *selectedForegroundImage;
@property STStoryDB *storyDB;

@property (weak, nonatomic) id<WorkAreaDelegate> mydelegate;

@end
