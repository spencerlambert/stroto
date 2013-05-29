//
//  WorkAreaController.h
//  StoryTelling
//
//  Created by Aaswini on 15/05/13.
//  Copyright (c) 2013 Aaswini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideUpView.h"
#import "SlideDownView.h"
#import "SlideLeftView.h"
#import "ScreenCaptureView.h"
#import "AudioRecorder.h"

@interface WorkAreaController : UIViewController<UIGestureRecognizerDelegate,SlideUpViewDelegate,SlideDownViewDelegate,SlideLeftViewDelegate>{
    SlideUpView *slideupview;
    SlideDownView *slidedownview;
    SlideLeftView *slideleftview;
    BOOL toolbarsvisible;
    UIImageView *backgroundimageview;
    AudioRecorder *audiorecorder;
}
@property (weak, nonatomic) IBOutlet ScreenCaptureView *captureview;
    

@end
