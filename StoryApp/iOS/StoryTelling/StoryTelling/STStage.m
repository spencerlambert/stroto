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

@implementation STStage{
    float initialTimecode;
}

@synthesize storyDB;

- (void) initialize{
    self.frameRate = 22.0f;
    isRecording = false;
    startedAt = nil;
    pauseInterval = 0;
    timeline = [[NSMutableArray alloc]init];
    initialTimecode =0;
}

-(void) initRecorders{
    stageRecorder = [[STStageRecorder alloc]initWithDB:storyDB];
    audioRecorder = [[STAudioRecording alloc]initWithDB:storyDB];
    initialTimecode = [storyDB getMaximumTimecode];
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
    [audioRecorder setStartedTime:[self getTimecode]];
    [audioRecorder recordAudio];
}
- (void) stopRecording{
    isRecording = NO;
    [audioRecorder stop];
}
-(void)updateRecordingtoDB{
    
    [self updateTimeline];
    [self finalizeRecording];
    
}
-(void) pauseRecording{
    if(isRecording){
        pausedTime = [NSDate date];
        isRecording = false;
        [audioRecorder pause];
    }
}

-(void) resumeRecording{
    if(!isRecording){
        pauseInterval += [[NSDate date]timeIntervalSinceDate:pausedTime] * 1000.0;
        isRecording = true;
        [audioRecorder recordAudio];
    }
}

-(void) drawRect:(CGRect)rect{
    NSDate *start = [NSDate date];
    if(isRecording){
        
        float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval + initialTimecode;
        
        for (STImageInstance *instance in imageInstances) {
            if(instance.instanceType == false){
                STBGImageView *imageview = ((STBGImageView *)[self viewWithTag:99999]);
                if ([imageview isChanged]){
                    STImageInstancePosition *position = [[STImageInstancePosition alloc]init];
                    [position setTimecode:millisElapsed];
                    [position setImageInstanceId:imageview.imageInstanceID];
                    [position setX:imageview.center.x];
                    [position setY:imageview.center.y];
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
                    [position setX:imageview.center.x];
                    [position setY:imageview.center.y];
                    if([imageview isRotated]){
                        float rotation =0;
                        for (NSNumber *rotationobj in imageview.rotation) {
                            rotation += [rotationobj floatValue];
                        }
                        [position setRotation:rotation];
                        [imageview.rotation removeAllObjects];
                    }
                    if([imageview isScaled]){
                        float scale =1;
                        for (NSNumber *scaleobj in imageview.scale) {
                            if([scaleobj floatValue] >=1)
                                scale += [scaleobj floatValue] -1;
                            else
                                scale -= 1 - [scaleobj floatValue];
                        }
                        [position setScale:scale];
                        [imageview.scale removeAllObjects];
                    }
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


-(void)updateTimeline{
    
    for (STImageInstancePosition *position in timeline) {
        [stageRecorder writeImageInstance:position];
    }
    
}

-(void)finalizeRecording{
    NSArray *temp = [storyDB getInstanceIDs];
    for (NSNumber *instanceID in temp) {
        STImageInstancePosition *position = [[STImageInstancePosition alloc]init];
        [position setImageInstanceId:instanceID.intValue];
        [position setLayer:-1];
        [position setTimecode:[storyDB getMaximumTimecode] + ((1.0/self.frameRate)*1000)];
        [stageRecorder writeImageInstance:position];
    }
    
}

-(float)getTimecode{
     float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval + initialTimecode;
    return millisElapsed;
}


@end
