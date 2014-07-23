//
//  CPDBModelNotifyMessage.h
//  teacher
//
//  Created by ZhangQing on 14-7-22.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "CPDBModelMessage.h"

@interface CPDBModelNotifyMessage : CPDBModelMessage


@property (nonatomic,strong) NSNumber *oaid;
@property (nonatomic,strong) NSNumber *bodyFrom;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) NSArray *imageUrl;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong)NSString *to;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *xmppType;
@property (nonatomic,strong) NSString *fromUserName;
@property (nonatomic,strong) NSString *fromUserAvatar;



@end
