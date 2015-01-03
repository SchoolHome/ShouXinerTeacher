//
//  BBServiceMessageDetailViewController.h
//  teacher
//
//  Created by ZhangQing on 14/11/26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBServiceAccountModel.h"

#import "SVPullToRefresh.h"

typedef enum{
    AccountMessageLoadStatusRefresh, // 刷新
    AccountMessageLoadStatusAppend,  // 追加
} AccountMessageLoadStatus;

@interface BBServiceMessageDetailViewController : PalmViewController

@property (nonatomic, strong)BBServiceAccountModel *model;
@property(nonatomic) AccountMessageLoadStatus loadStatus;
@end
