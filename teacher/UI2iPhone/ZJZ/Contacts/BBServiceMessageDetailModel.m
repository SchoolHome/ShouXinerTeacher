//
//  BBServiceMessageDetailModel.m
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageDetailModel.h"

@implementation BBServiceMessageDetailModel

+ (BBServiceMessageDetailModel  *)convertByDic:(NSDictionary *)dic;
{
    BBServiceMessageDetailModel *tempModel = [[BBServiceMessageDetailModel alloc] init];
    
    tempModel.mid = dic[@"mid"];
    tempModel.imageUrl = dic[@"image"];
    tempModel.type = [dic[@"type"] integerValue] == 2 ? DETAIL_CELL_TYPE_SINGLE : DETAIL_CELL_TYPE_MUTIL;
    tempModel.content = dic[@"content"];
    tempModel.link = dic[@"link"];
    tempModel.ts = dic[@"ts"];
    tempModel.avatar = dic[@"avatar"];
    
    return tempModel;
}

@end
