//
//  STStage.m
//  StoryTelling
//
//  Created by Spencer Lambert on 6/30/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import "STStage.h"
#import "STImageInstance.h"

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
        [self reLoadImageInstances];
        NSMutableArray *array = [[NSMutableArray alloc]init];
        
        float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval;
        
        for (STImageInstance *instance in imageInstances) {
            if(instance.instanceType == false){
                UIImageView *imageview = ((UIImageView*)[self viewWithTag:99999]);
                STImage *image = (STImage*)imageview.image;
                STImageInstancePosition *position = [[STImageInstancePosition alloc]init];
                [position setTimecode:millisElapsed];
                [position setImageInstanceId:instance.imageInstanceID];
                [position setX:imageview.frame.origin.x];
                [position setY:imageview.frame.origin.y];
                [array addObject:position];
                
            }
            else if (instance.instanceType == true){
                
                UIImageView *imageview = ((UIImageView*)[self viewWithTag:instance.imageInstanceID]);
                STImage *image = (STImage*)imageview.image;
                STImageInstancePosition *position = [[STImageInstancePosition alloc]init];
                [position setTimecode:millisElapsed];
                [position setImageInstanceId:instance.imageInstanceID];
                [position setX:imageview.frame.origin.x];
                [position setY:imageview.frame.origin.y];
                [array addObject:position];
            }
            
        }
        
        for (STImageInstancePosition *position in array){
            [stageRecorder writeImageInstance:position];
        }
        
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

@end
