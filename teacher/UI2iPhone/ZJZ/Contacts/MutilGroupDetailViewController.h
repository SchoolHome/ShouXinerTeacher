//
//  MutilGroupDetailViewController.h
//  teacher
//
//  Created by ZhangQing on 14-11-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

@protocol MutilGroupMemberDisplayViewDelegate <NSObject>

@required
- (void)addMemberBtnTapped: (NSArray *)members;

@end

typedef enum
{
    GROUP_MEMBER_FROM_TYPE_NORMAL =1,
    GROUP_MEMBER_FROM_TYPE_IM = 2
}GROUP_MEMBER_FROM_TYPE;

@class MutilGroupMemberDisplayView;
@interface MutilGroupDetailViewController : PalmViewController <MutilGroupMemberDisplayViewDelegate>
{
    NSString *groupName;
}
- (id)initWithMsgGroup: (CPUIModelMessageGroup *)tempMsgGroup andGroupName:(NSString *)tempGroupName
           andFromType:(GROUP_MEMBER_FROM_TYPE)type;

- (void)refreshMsgGroup;
@end



@interface MutilGroupMemberDisplayView : UIView

@property (nonatomic, strong)NSArray *members;
@property (nonatomic, weak)id<MutilGroupMemberDisplayViewDelegate> delegate;

@end