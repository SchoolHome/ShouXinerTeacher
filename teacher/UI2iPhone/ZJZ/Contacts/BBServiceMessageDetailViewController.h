//
//  BBServiceMessageDetailViewController.h
//  teacher
//
//  Created by ZhangQing on 14/11/26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBServiceAccountModel.h"
#import "CPDBModelNotifyMessage.h"

#import "SVPullToRefresh.h"

typedef enum{
    AccountMessageLoadStatusRefresh, // 刷新
    AccountMessageLoadStatusAppend,  // 追加
} AccountMessageLoadStatus;

typedef enum{
    AccountInfoStatusExist, // 账户信息存在
    AccountInfoStatusMiss,  // 账户信息不存在
} AccountInfoStatus;

@interface BBServiceMessageDetailViewController : PalmViewController

@property (nonatomic, strong)BBServiceAccountModel *model;
@property (nonatomic, strong)CPDBModelNotifyMessage *notifyMsgmodel;
@property(nonatomic) AccountMessageLoadStatus loadStatus;
@property(nonatomic) AccountInfoStatus infoStatus;
@end
