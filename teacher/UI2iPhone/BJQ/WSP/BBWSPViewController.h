//
//  BBWSPViewController.h
//  teacher
//
//  Created by ZhangQing on 14-9-27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBGroupModel.h"
@protocol ReachTouchScrollviewDelegate <NSObject>

-(void)scrollviewTouched;

@end

@interface BBWSPViewController : PalmViewController<ReachTouchScrollviewDelegate>
@property(nonatomic,strong) BBGroupModel *currentGroup;
@end



@interface ReachTouchScrollview : UIScrollView
@property (nonatomic, weak) id<ReachTouchScrollviewDelegate> touchDelegate;
@end