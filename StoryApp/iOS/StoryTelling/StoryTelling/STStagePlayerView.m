//
//  STStagePlayerView.m
//  StoryTelling
//
//  Created by Aaswini on 28/02/14.
//  Copyright (c) 2014 Stroto, LLC. All rights reserved.
//

#import "STStagePlayerView.h"

@implementation STStagePlayerView{
    
    BOOL isPlaying;
    
    NSDate *startedAt;
    float pauseInterval;
    NSDate *pausedTime;
    
    NSArray *timeline;
    NSArray *instanceIDs;
    
    NSDictionary *instanceIDTable;
    NSDictionary *imagesTable;
}

@synthesize storyDB;


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

- (void) initialize{
    self.frameRate = 22.0f;
    startedAt = nil;
    pauseInterval = 0;
    isPlaying = false;
    timeline = [self getProcessedTimeline:[storyDB getImageInstanceTimeline]];
    instanceIDs = [storyDB getInstanceIDsAsString];
    instanceIDTable = [storyDB getImageInstanceTableAsDictionary];
    imagesTable = [storyDB getImagesTable];

}

-(NSArray *)getProcessedTimeline:(NSArray *)timeline{
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (STImageInstancePosition *position in timeline) {
        STStagePlayerFrame *frame = [[STStagePlayerFrame alloc]initWithFrame:position atTimecode:position.timecode];
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
   
    isPlaying = YES;
    startedAt =[NSDate date];
}

-(void)stopPlaying{
    isPlaying = NO;
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

-(void) drawRect:(CGRect)rect{
    NSDate *start = [NSDate date];
    if(isPlaying){
        
        float millisElapsed = ([[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0) - pauseInterval;
        
        
    }
}

-(STStagePlayerFrame *)getFrameforTimecode:(float)timecode{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timecode == %f",timecode];
    NSArray *visible = [timeline filteredArrayUsingPredicate:predicate];
    if (visible.count == 0) {
        float timecode1 = timecode - (1.0 / self.frameRate * 1000);
        predicate = [NSPredicate predicateWithFormat:@"(timecode >= %f) AND (timecode <= %f)  ",timecode1,timecode];
        NSArray *visible1 = [timeline filteredArrayUsingPredicate:predicate];
        if (visible1.count != 0) {
            for (STStagePlayerFrame *frame in visible1) {
                if (!frame.presented) {
                    return frame;
                }
            }
        }
    }else{
        STStagePlayerFrame *frame = [visible objectAtIndex:0];
        if (!frame.presented) {
            return frame;
        }
    }
    
    return nil;
}

-(void)setFramePresented:(float)timecode{
    
}

@end
