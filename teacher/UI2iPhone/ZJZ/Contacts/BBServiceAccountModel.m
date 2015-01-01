//
//  BBServiceAccountModel.m
//  teacher
//
//  Created by ZhangQing on 15/1/1.
//  Copyright (c) 2015年 ws. All rights reserved.
//

#import "BBServiceAccountModel.h"

#import "FXStringUtil.h"
@implementation BBServiceAccountModel

+ (BBServiceAccountModel  *)convertByDic:(NSDictionary *)dic
{
    BBServiceAccountModel *tempModel = [[BBServiceAccountModel alloc] init];
    tempModel.accountID = [dic[@"id"] intValue];
    tempModel.accountIntraduction = [FXStringUtil fliterStringIsNull:dic[@"intraduction"]];
    tempModel.accountLogo = [FXStringUtil fliterStringIsNull:dic[@"logo"]];
    tempModel.accountName = [FXStringUtil fliterStringIsNull:dic[@"name"]];
    return tempModel;
}

@end
