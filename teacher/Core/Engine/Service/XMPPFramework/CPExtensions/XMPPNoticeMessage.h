//
//  XMPPNoticeMessage.h
//  teacher
//
//  Created by singlew on 14-7-21.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "XMPPUserMessage.h"

@interface XMPPNoticeMessage : XMPPUserMessage
+ (XMPPNoticeMessage *) fromXMLElement:(XMPPMessage *)message;

@property (nonatomic,strong) NSNumber *oaid;
@property (nonatomic,strong) NSNumber *bodyFrom;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) NSString *imageUrl;
@end
