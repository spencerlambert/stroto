//
//  STStagePlayerView.m
//  StoryTelling
//
//  Created by Aaswini on 28/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerView.h"
#import "UIView+Hierarchy.h"
#import <AVFoundation/AVFoundation.h>



@implementation STStagePlayerView{
    
    BOOL isPlaying;
    
    NSDate *startedAt;
    float pauseInterval;
    NSDate *pausedTime;
    
    NSArray *timeline;
    NSArray *audioTimeline;
    NSArray *instanceIDs;
    
    NSDictionary *instanceIDTable;
    NSDictionary *imagesTable;
    
    UIImageView *backgroundimageview;
    
    AVAudioPlayer *audioplayer;
}

@synthesize storyDB;


- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
//		[self initialize];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        [self initialize];
    }
    return self;
}

- (id) init {
	self = [super init];
	if (self) {
//		[self initialize];
	}
	return self;
}

- (void) initialize{
    self.frameRate = 22.0f;
    startedAt = nil;
    pauseInterval = 0;
    isPlaying = false;
    instanceIDs = [storyDB getInstanceIDsAsString];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
    imagesTable = [storyDB getImagesTable];

    timeline = [self getProcessedTimeline:[storyDB getImageInstanceTimeline]];
    audioTimeline = [self getProcessedAudioTimeline:[storyDB getAudioInstanceTimeline]];
    
    CGRect bounds = [self bounds];
    backgroundimageview = [[UIImageView alloc]initWithFrame:bounds];
    backgroundimageview.contentMode = UIViewContentModeScaleToFill;
    [self resetBGImage];
    [backgroundimageview setTag:-1];
    [self addSubview:backgroundimageview];
    
    if (timeline.count>0) {
        float end = [storyDB getMaximumTimecode]- ((STStagePlayerFrame *)timeline[0]).timecode;
        [self.slider setMaximumValue:end/1000.0f];
    }
    if (audioplayer != nil) {
        [audioplayer stop];
        audioplayer = nil;
    }


}

-(NSArray *)getProcessedTimeline:(NSArray *)rawTimeline{
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (STImageInstancePosition *position in rawTimeline) {
        STStagePlayerFrame *frame = [[STStagePlayerFrame alloc]initWithFrame:position atTimecode:position.timecode];
        if([self isInstanceBG:[position imageInstanceId]] || position.layer == -1){
            [frame setBgFrame:YES];
        }
        [frames addObject:frame];
    }
    return frames;
}

-(NSArray *)getProcessedAudioTimeline:(NSArray *)myAudioTimeline{
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (STAudio *audio in myAudioTimeline) {
        STStageAudioFrame *frame = [[STStageAudioFrame alloc]initWithFrame:audio atTimecode:audio.timecode];
        [frames addObject:frame];
    }
    return frames;
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

- (BOOL) isImageActing:(int)instanceID{
    for (UIView *subview in [self subviews]) {
        if ([subview tag] == instanceID) {
            return YES;
        }
    }
    return NO;
}

-(float)getTimecode{
    float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval;
    return millisElapsed;
}

-(void)startPlaying{
    
    [self initialize];
    [self removeAllFgImages];
    isPlaying = YES;
    startedAt =[NSDate date];
}

-(void)stopPlaying{
    isPlaying = NO;
    [self.slider setValue:0 animated:YES];
}

-(void)pausePlaying{
    if(isPlaying){
        pausedTime = [NSDate date];
        isPlaying = false;
    }
}

-(void)resumePlaying{
    if(!isPlaying){
        pauseInterval += [[NSDate date]timeIntervalSinceDate:pausedTime] * 1000.0;
        isPlaying = true;
    }
  
}

-(void) removeAllFgImages{
    for (UIView *view in self.subviews) {
        if([view tag] != -1){
            [view removeFromSuperview];
        }
    }
}

-(void) resetBGImage{
    backgroundimageview.image = [UIImage imageNamed:@"RecordAreaBlank.png"];
}


-(void) drawRect:(CGRect)rect{
    NSDate *start = [NSDate date];
    if(isPlaying){
        
        float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval;
        
        [self.slider setValue:millisElapsed/1000.0f];
        
        NSArray *audioFrames = [self getAudioFrameforTimecode:millisElapsed];
        
        if ([audioFrames count] != 0) {
            STStageAudioFrame *audioFrame = [audioFrames objectAtIndex:0];
            [audioFrame setPresented:YES];
            
            [self performSelectorOnMainThread:@selector(playAudio:) withObject:[[audioFrame frame]audio] waitUntilDone:NO];
        }
        NSArray *frames = [self getFrameforTimecode:millisElapsed];
        
        if([frames count] != 0){
            for (STStagePlayerFrame *frame in frames) {
                [frame setPresented:YES];
                
                STImageInstancePosition *position = [frame frame];
                
                if ([self isInstanceBG:position.imageInstanceId]){
                    int imageID = [[instanceIDTable objectForKey:[NSString stringWithFormat:@"%d",position.imageInstanceId]] intValue];
                    [self setBGImage:[NSNumber numberWithInt:imageID]];
                }
                else{
                    if (position.layer != -1){
                        if ([self isImageActing:position.imageInstanceId]){
                            UIImageView *fgimageView = (UIImageView *) [self viewWithTag:position.imageInstanceId];
                            [fgimageView bringToFront];
                            
                            if(position.rotation != 0){
                                [fgimageView setTransform:CGAffineTransformRotate(fgimageView.transform, position.rotation)];
                            }
                            else if(position.scale != 1){
                                [fgimageView setTransform:CGAffineTransformScale(fgimageView.transform, position.scale, position.scale)];
                            }
                            else{
                                [fgimageView setCenter:CGPointMake(position.x, position.y)];
                            }
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
                            
                            [self addFGimage:imageview];
                            
                            imageview.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageWidth, imageHeight);
                            
                            [imageview setTag:position.imageInstanceId];
                            
                            [imageview bringToFront];
                            
                            if(position.rotation != 0){
                                [imageview setTransform:CGAffineTransformRotate(imageview.transform, position.rotation)];
                            }
                            if(position.scale != 1){
                                [imageview setTransform:CGAffineTransformScale(imageview.transform, position.scale, position.scale)];
                            }
                        }
                    }
                    else{
                        [[self viewWithTag:position.imageInstanceId] removeFromSuperview ];
                    }
                }
            }
        }
    }
    float processingSeconds = [[NSDate date] timeIntervalSinceDate:start];
	float delayRemaining = (1.0 / self.frameRate) - processingSeconds;
	[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delayRemaining > 0.0 ? delayRemaining : 0.01];
}

-(void)playAudio:(NSData*)audioData{
    if (audioplayer == nil) {
        audioplayer = [[AVAudioPlayer alloc]initWithData:audioData error:nil];
    }
    else{
        if([audioplayer isPlaying])
            [audioplayer stop];
        audioplayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
    }
    [audioplayer play];
}

-(NSArray *)getFrameforTimecode:(float)timecode{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timecode == %f",timecode];
    NSArray *visible = [timeline filteredArrayUsingPredicate:predicate];
    NSMutableArray *newvisible = [NSMutableArray arrayWithArray:visible];
    NSPredicate *newpredicate = [NSPredicate predicateWithFormat:@"(timecode <= %f) AND (bgFrame == YES) AND (presented == NO)",timecode];
    NSArray *newArray = [timeline filteredArrayUsingPredicate:newpredicate];
    for (int i=[newArray count]-1;i>=0;i--) {
        STStagePlayerFrame *arrayobj = [newArray objectAtIndex:i];
        if(![newvisible containsObject:arrayobj]){
            [newvisible insertObject:arrayobj atIndex:0];
        }
    }
    visible = nil;
    visible = newvisible;
    if (visible.count == 0) {
        float timecode1 = timecode - (1.0 / self.frameRate * 1000);
        NSPredicate *rangePredicate = [NSPredicate predicateWithFormat:@"(timecode >= %f) AND (timecode <= %f)  ",timecode1,timecode];
        NSArray *visible1 = [timeline filteredArrayUsingPredicate:rangePredicate];
        
        NSPredicate *presentedPredicate = [NSPredicate predicateWithFormat:@"presented == NO"];
        return [visible1 filteredArrayUsingPredicate:presentedPredicate];
    }else{
        
        NSPredicate *presentedPredicate = [NSPredicate predicateWithFormat:@"presented == NO"];
        return [visible filteredArrayUsingPredicate:presentedPredicate];
    }
    
    return [[NSArray alloc]init];
}

-(NSArray *)getAudioFrameforTimecode:(float)timecode{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timecode == %f",timecode];
    NSArray *visible = [audioTimeline filteredArrayUsingPredicate:predicate];
        if (visible.count == 0) {
        float timecode1 = timecode - (1.0 / self.frameRate * 1000);
        NSPredicate *rangePredicate = [NSPredicate predicateWithFormat:@"(timecode >= %f) AND (timecode <= %f)  ",timecode1,timecode];
        NSArray *visible1 = [audioTimeline filteredArrayUsingPredicate:rangePredicate];
        
        NSPredicate *presentedPredicate = [NSPredicate predicateWithFormat:@"presented == NO"];
        return [visible1 filteredArrayUsingPredicate:presentedPredicate];
    }else{
        
        NSPredicate *presentedPredicate = [NSPredicate predicateWithFormat:@"presented == NO"];
        return [visible filteredArrayUsingPredicate:presentedPredicate];
    }
    
    return [[NSArray alloc]init];
}


-(void)setBGImage:(NSNumber*)imageID{
    STImage *image = [imagesTable objectForKey:[NSString stringWithFormat:@"%d",[imageID intValue]]];
    [backgroundimageview setImage:image ];
}

-(void) addFGimage:(UIView*)view{
    [self addSubview:view];
}
@end
