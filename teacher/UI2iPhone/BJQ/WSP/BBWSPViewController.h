//
//  BBWSPViewController.h
//  teacher
//
//  Created by ZhangQing on 14-9-27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBGroupModel.h"
typedef enum
{
    VIDEO_TYPE_PHOTO = 1,
    VIDEO_TYPE_CARMER = 2
}VIDEO_CHOOSEN_TYPE;
@protocol WSPScrollviewDelegate <NSObject>

-(void)scrollviewTouched;

@end

@interface BBWSPViewController : PalmViewController<WSPScrollviewDelegate,UIScrollViewDelegate>


-(id)initWithVideoUrl:(NSURL *)url andType:(VIDEO_CHOOSEN_TYPE)type andGroupModel:(BBGroupModel *)groupModel;
@end



@interface TouchScrollview : UIScrollView
@property (nonatomic, weak) id<WSPScrollviewDelegate> touchDelegate;
@end