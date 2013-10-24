//
//  STListStoryiPad.h
//  StoryTelling
//
//  Created by Nandakumar on 23/10/13.
//  Copyright (c) 2013 Stroto, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STListStoryiPadDelegate

- (void) didSelectTableCellWithName:(NSString*)dbName;

@end

@interface STListStoryiPad : UIView<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) id<STListStoryiPadDelegate> listDelegate;
@property (weak, nonatomic)  NSMutableArray *DBNamesiPad;
@property (weak, nonatomic)  NSMutableArray *storyNamesiPad;
@property (strong, nonatomic)  NSIndexPath *index;
@end
