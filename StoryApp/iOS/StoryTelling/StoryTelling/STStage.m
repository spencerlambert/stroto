//
//  STStage.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStage.h"
#import "STImageInstance.h"
#import "STFGImageView.h"
#import "STBGImageView.h"

@interface STStage (Actor_Entry_Handlers)

- (int) createImageInstanceEntry:(STImage *)actor;
- (void) reLoadImageInstances;

@end

@implementation STStage

@synthesize storyDB;

- (void) initialize{
    self.frameRate = 22.0f;
    isRecording = false;
    startedAt = nil;
    pauseInterval = 0;
    timeline = [[NSMutableArray alloc]init];
}

-(void) initRecorders{
    stageRecorder = [[STStageRecorder alloc]initWithDB:storyDB];
    audioRecorder = [[STAudioRecording alloc]initWithDB:storyDB];
}
- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id) init {
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

-(void)initStage{
    isRecording = NO;
    [self reLoadImageInstances];
}

- (void) reLoadImageInstances{
    imageInstances = [storyDB getImageInstanceTable];
}

- (int) createImageInstanceEntry:(STImage *)actor{
    return [storyDB addImageInstance:actor.imageId];
}

- (int) actortoStage:(STImage *)actor{
    int instanceID = [self createImageInstanceEntry:actor];
    [self reLoadImageInstances];
    return instanceID;
}

- (void) startRecording{
    [self initRecorders];
    isRecording = YES;
    startedAt =[NSDate date];
  }
- (void) stopRecording{
    isRecording = NO;
    [self updateTimeline];
}
-(void) pauseRecording{
    if(isRecording){
        pausedTime = [NSDate date];
        isRecording = false;
    }
}

-(void) resumeRecording{
    if(!isRecording){
        pauseInterval += [[NSDate date]timeIntervalSinceDate:pausedTime] * 1000.0;
        isRecording = true;
    }
}

-(void) drawRect:(CGRect)rect{
    NSDate *start = [NSDate date];
    if(isRecording){
        
        float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval;
        
        for (STImageInstance *instance in imageInstances) {
            if(instance.instanceType == false){
                STBGImageView *imageview = ((STBGImageView *)[self viewWithTag:99999]);
                if ([imageview isChanged]){
                STImageInstancePosition *position = [[STImageInstancePosition alloc]init];
                [position setTimecode:millisElapsed];
                [position setImageInstanceId:imageview.imageInstanceID];
                [position setX:imageview.frame.origin.x];
                [position setY:imageview.frame.origin.y];
//                [stageRecorder writeImageInstance:position];
                [timeline addObject:position];
                [imageview setIsChanged:NO];
                }
                
            }
            else if (instance.instanceType == true){
                
               STFGImageView *imageview = ((STFGImageView*)[self viewWithTag:instance.imageInstanceID]);
//                STImage *image = (STImage*)imageview.image;
                if([imageview isEdited]){
                STImageInstancePosition *position = [[STImageInstancePosition alloc]init];
                [position setTimecode:millisElapsed];
                [position setImageInstanceId:instance.imageInstanceID];
                [position setX:imageview.frame.origin.x];
                [position setY:imageview.frame.origin.y];
//                [stageRecorder writeImageInstance:position];
                [timeline addObject:position];
                [imageview setIsEdited:NO];
                                        
                }
            }
            
        }
        
//        for (STImageInstancePosition *position in array){
//            [stageRecorder writeImageInstance:position];
//        }
        
    }
    float processingSeconds = [[NSDate date] timeIntervalSinceDate:start];
	float delayRemaining = (1.0 / self.frameRate) - processingSeconds;
	[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delayRemaining > 0.0 ? delayRemaining : 0.01];

    
}

-(UIView *)subviewWithTag:(int)tag{
    for(UIView *views in self.subviews){
        if(views.tag == tag)
            return views;
    }
    return NULL;
}

-(void) getVideofromDB{
//    UIImage *bottomImage = [UIImage imageNamed:@"color_red.png"]; //background image
//    UIImage *image       = [UIImage imageNamed:@"StartRecording.png"]; //foreground image
//    UIImage *image1      = [UIImage imageNamed:@"AddButton.png"]; //foreground image
//    UIImage *image2      = [UIImage imageNamed:@"RecordStop.png"]; //foreground image
//    
//    CGSize newSize = CGSizeMake(320, 480);
//    UIGraphicsBeginImageContext( newSize );
//    
//    // Use existing opacity as is
//    [bottomImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    
//    // Apply supplied opacity if applicable
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.4];
//    [image1 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.3];
//    [image2 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.2];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    resultView = [[UIImageView alloc] initWithImage:newImage];
//    resultView.frame = CGRectMake(0, 0,320,460);
//    [self.view addSubview:resultView];
}

-(void)updateTimeline{
    
    for (STImageInstancePosition *position in timeline) {
        [stageRecorder writeImageInstance:position];
    }
    
}

@end
