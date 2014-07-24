//
//  MessageGroupCell.h
//  teacher
//
//  Created by ZhangQing on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPUIModelMessageGroup.h"
#import "CPUIModelMessageGroupMember.h"
#import "CPUIModelUserInfo.h"
#import "CPUIModelMessage.h"
#import "CPDBModelNotifyMessage.h"

#import "EGOImageView.h"
@interface BBMessageGroupBaseCell : UITableViewCell
//notifyMessage change
@property (nonatomic , strong) id msgGroup;
//姓名
@property (nonatomic , strong) UILabel *userNameLabel;
//内容
@property (nonatomic , strong) UILabel *contentLabel;
//头像
@property (nonatomic , strong) EGOImageView *userHeadImageView;
//时间
@property (nonatomic , strong) UILabel *dateLabel;
//未读数
@property (nonatomic , strong) UILabel *unreadedCountLabel;
//未读书背景图
@property (nonatomic ,strong) UIImageView *imageviewMessageAlert;

//notifyMessage change
-(void)setUIModelMsgGroup:(CPUIModelMessageGroup *)msgGroup;

-(void)setDBModelNotifyMsgGroup:(CPDBModelNotifyMessage *)msgGroup;
@end
