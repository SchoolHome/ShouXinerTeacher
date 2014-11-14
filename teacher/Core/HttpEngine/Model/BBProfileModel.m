//
//  BBProfileModel.m
//  teacher
//
//  Created by mac on 14/11/12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBProfileModel.h"

@implementation BBProfileModel

+(id)shareProfileModel
{
    static BBProfileModel *model;
    @synchronized(model){
        if (nil == model) {
            model = [[BBProfileModel alloc] init];
        }
    }
    return model;
}

-(void)coverWithJson:(NSDictionary *)jsonDic
{
    self.uid = jsonDic[@"uid"];
    self.jid = jsonDic[@"jid"];
    self.username = jsonDic[@"username"];
    self.avatar = jsonDic[@"avatar"];
    self.sex = [jsonDic[@"sex"] integerValue];
    self.brithday = jsonDic[@"brithday"];
    self.sign = jsonDic[@"sign"];
    self.cityname = jsonDic[@"cityname"];
    self.city = jsonDic[@"city"];
}
@end
