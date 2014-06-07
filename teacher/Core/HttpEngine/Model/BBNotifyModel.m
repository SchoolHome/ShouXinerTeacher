//
//  BBNotifyModel.m
//  teacher
//
//  Created by xxx on 14-4-3.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBNotifyModel.h"

@implementation BBNotifyModel

+(BBNotifyModel *)fromJson:(NSDictionary *)dict{

    if (dict) {
        
        BBNotifyModel *nt = [[BBNotifyModel alloc] init];
        nt.ts = dict[@"ts"];
        nt.mid = dict[@"mid"];
        nt.sender = dict[@"sender"];
        nt.sender_name = dict[@"sender_name"];
        
        if ([dict[@"sender_avatar"] isKindOfClass:[NSNull class]]) {
            nt.sender_avatar = nil;
        }else{
            nt.sender_avatar = dict[@"sender_avatar"];
        }
        nt.topicid = dict[@"topicid"];
        nt.topic_title = dict[@"topic_title"];
        nt.type = dict[@"type"];

//        @property(nonatomic,strong) NSString *imageUrl;
//        @property(nonatomic,strong) NSString *content;
//        @property(nonatomic,strong) NSString *comment;
        nt.imageUrl = dict[@"image"];
        nt.content = dict[@"content"];
        nt.comment = dict[@"comment"];
        
        return nt;
    }
    
    return nil;
}

@end
