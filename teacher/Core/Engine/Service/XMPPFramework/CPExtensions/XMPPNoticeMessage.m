//
//  XMPPNoticeMessage.m
//  teacher
//
//  Created by singlew on 14-7-21.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "XMPPNoticeMessage.h"
#import "CoreUtils.h"

#import "XMPPDateTimeProfiles.h"
#import "XMPPMessage+EXT.h"
#import "XMPPMessage+SYS.h"

@implementation XMPPNoticeMessage
+ (XMPPNoticeMessage *) fromXMLElement:(XMPPMessage *)message{
    XMPPNoticeMessage *noticeMessage = nil;
    
    if(message){
        UserMessageType userMsgType = UserMessageTypeUnknown;
        
        NSString *subTypeStr = [message subTypeStr];
        CPLogInfo(@"subTypeStr:%@\n", subTypeStr);
        
        if( !subTypeStr ){
            userMsgType = UserMessageTypeText;
        }else if( [subTypeStr isEqualToString:@"sys_direct"]){
            userMsgType = UserMessageTypeNotice;
        }
        
        if( userMsgType == UserMessageTypeUnknown ){
            //            return nil;
            CPLogInfo(@"unrecognized system message!!!");
        }
        
        NSNumber *msgOaid = nil;
        NSNumber *msgBodyFrom = nil;
        NSString *msgTitle = nil;
        NSString *msgContent = nil;
        NSString *msgLink = nil;
        NSArray *msgImageUrl = nil;
        NSString *msgUserName = nil;
        NSString *msgUserAvatar = nil;
        NSString *msgMid = nil;
        
        switch (userMsgType){
            case UserMessageTypeNotice:{
                NSString *body = [[message elementForName:@"body"] stringValue];
                NSDictionary *jsonDict = [body objectFromJSONString];
                msgOaid = [jsonDict objectForKey:@"oaid"];
                msgBodyFrom = [jsonDict objectForKey:@"from"];
                msgTitle = [jsonDict objectForKey:@"title"];
                msgContent = [jsonDict objectForKey:@"content"];
                msgLink = [jsonDict objectForKey:@"link"];
                msgImageUrl = [jsonDict objectForKey:@"img"];
                msgUserName = [jsonDict objectForKey:@"from_uname"];
                msgUserAvatar = [jsonDict objectForKey:@"from_avatar"];
                msgMid = [jsonDict objectForKey:@"mid"];
            }
            break;
            case UserMessageTypeUnknown:
                break;
            default:
                break;
        }
        
        if (msgMid == nil || [msgMid isEqualToString:@""]) {
            return nil;
        }
        
        NSNumber *delayedTime = nil;
        NSXMLElement *delay = nil;
        delay = [message elementForName:@"delay" xmlns:@"urn:xmpp:delay"];
        if (delay)
        {
            NSString *stampValue = [delay attributeStringValueForName:@"stamp"];
            NSDate *date = [XMPPDateTimeProfiles parseDateTime:stampValue];
            delayedTime = [CoreUtils getLongFormatWithDate:date];
        }
        
        noticeMessage = [[XMPPNoticeMessage alloc] init];
        
        noticeMessage.from = [[message from] bare];
        noticeMessage.to = [[message to] bare];
        noticeMessage.type = [NSNumber numberWithInt:userMsgType];
        
        noticeMessage.oaid = msgOaid;
        noticeMessage.bodyFrom = msgBodyFrom;
        noticeMessage.title = msgTitle;
        noticeMessage.content = msgContent;
        noticeMessage.link = msgLink;
        noticeMessage.imageUrl = msgImageUrl;
        noticeMessage.fromUserName = msgUserName;
        noticeMessage.fromUserAvatar = msgUserAvatar;
        noticeMessage.mid = msgMid;
        noticeMessage.resourceMimeType = nil;
        noticeMessage.delayedTime = delayedTime;
    }
    
    return noticeMessage;
}
@end
