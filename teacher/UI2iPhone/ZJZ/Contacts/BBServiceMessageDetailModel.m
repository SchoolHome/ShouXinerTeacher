//
//  BBServiceMessageDetailModel.m
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageDetailModel.h"

#import "FXStringUtil.h"
@implementation BBServiceMessageDetailModel

+ (BBServiceMessageDetailModel  *)convertByDic:(NSDictionary *)dic;
{
    BBServiceMessageDetailModel *tempModel = [[BBServiceMessageDetailModel alloc] init];
    
    tempModel.mid = [FXStringUtil fliterStringIsNull:dic[@"mid"]];
    tempModel.imageUrl = [FXStringUtil fliterStringIsNull:dic[@"image"]];
    tempModel.type = [dic[@"type"] integerValue] == 2 ? DETAIL_CELL_TYPE_SINGLE : DETAIL_CELL_TYPE_BANNER;
    tempModel.content = [FXStringUtil fliterStringIsNull:dic[@"content"]];
    tempModel.link = [FXStringUtil fliterStringIsNull:dic[@"link"]];
    tempModel.ts = dic[@"ts"];
    tempModel.avatar = [FXStringUtil fliterStringIsNull:dic[@"avatar"]];
    tempModel.userName = [FXStringUtil fliterStringIsNull:dic[@"username"]];
    
    return tempModel;
}


@end
