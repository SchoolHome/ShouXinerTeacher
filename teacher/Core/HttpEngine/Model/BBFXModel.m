//
//  BBFXModel.m
//  teacher
//
//  Created by mac on 14/11/7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFXModel.h"
@implementation BBFXModel
-(id)initWithJson:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        self.discoverID = dic[@"id"];
        self.url = dic[@"url"];
        self.image = dic[@"image"];
        self.title = dic[@"title"];
        self.isNew = [dic[@"new"] boolValue];
    }
    return self;
}
@end