//
//  playViewController.h
//  StrotoBasic
//
//  Created by Nandakumar on 01/11/13.
//  Copyright (c) 2013 stroto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideUpView.h"
#import "SlideDownView.h"
#import "ViewController.h"

@interface playViewController : UIViewController<UIGestureRecognizerDelegate,SlideUpViewDelegate,SlideDownViewDelegate>
{
    SlideUpView *bgImages;
    SlideDownView *fgImages;
    UIImageView *bgImageView;
    NSMutableArray *pickedImages;
    BOOL imageSelected;
    UIImageView *fgImageView;
    NSMutableArray *bgImagesArray;
    NSMutableArray *fgImagesArray;
    sqlite3 *database;
    UIPanGestureRecognizer *pan;
    UIPinchGestureRecognizer *pinch;
    UITapGestureRecognizer *tap;
    UIRotationGestureRecognizer *rotate;
}
@property (weak, nonatomic) NSString *dbName;
//@property (weak, nonatomic) NSMutableArray *bgImagesArray;
//@property (weak, nonatomic) NSMutableArray *fgImagesArray;

@end
