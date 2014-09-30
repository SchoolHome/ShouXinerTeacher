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

@interface BBWSPViewController : PalmViewController<ReachTouchScrollviewDelegate,UIScrollViewDelegate>


-(id)initWithVideoUrl:(NSURL *)url andGroupModel:(BBGroupModel *)groupModel;
@end



@interface TouchScrollview : UIScrollView
@property (nonatomic, weak) id<ReachTouchScrollviewDelegate> touchDelegate;
@end