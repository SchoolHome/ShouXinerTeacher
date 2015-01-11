//
//  BBServiceAccountModel.h
//  teacher
//
//  Created by ZhangQing on 15/1/1.
//  Copyright (c) 2015年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPDBModelNotifyMessage.h"
@interface BBServiceAccountModel : NSObject

@property (nonatomic)int accountID;
@property (nonatomic, strong)NSString *accountIntraduction;
@property (nonatomic, strong)NSString *accountName;
@property (nonatomic, strong)NSString *accountLogo;

+ (BBServiceAccountModel  *)convertByDic:(NSDictionary *)dic;

@end
