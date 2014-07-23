//
//  CPOperationReceiveYTZMessage.m
//  teacher
//
//  Created by ZhangQing on 14-7-21.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "CPOperationReceiveYTZMessage.h"

#import "CPSystemEngine.h"
#import "CPDBManagement.h"
#import "CPUIModelMessage.h"

#import "CPDBModelNotifyMessage.h"
#import "XMPPNoticeMessage.h"
#import "CoreUtils.h"

#import "PalmUIManagement.h"
@implementation CPOperationReceiveYTZMessage
- (id) initWithMsgs:(NSArray *) receiveMsgs
{
    self = [super init];
    if (self)
    {
        YTZMsgs = receiveMsgs;
    }
    return self;
}
-(NSNumber *)excuteUserMsgWithMsg:(XMPPNoticeMessage *)userMsg
{
    
    NSString *fromUserAccount = userMsg.from;
    //NSString *toUserAccount = userMsg.to;
//    NSString *msgText = userMsg.message;
//    NSInteger receiveMsgType = [userMsg.type integerValue];

    //NSNumber *msgGroupID = [[[CPSystemEngine sharedInstance] msgManager] getMsgGroupIdWithUserName:fromUserAccount];

    CPDBModelNotifyMessage *dbMsg = [[CPDBModelNotifyMessage alloc] init];

       // [dbMsg setMsgOwnerName:[ModelConvertUtils getAccountNameWithName:userMsg.from]];

       // [dbMsg setMsgSenderID:[ModelConvertUtils getAccountNameWithName:userMsg.from]];
        //[dbMsg setMsgGroupID:msgGroupID];
        //[dbMsg setMsgText:msgText];

    [dbMsg setDate:userMsg.delayedTime];
    [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_STATUS_IS_NOT_READ]];
    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
    [dbMsg setFrom:userMsg.from];
    [dbMsg setTo:userMsg.to];
    [dbMsg setType:userMsg.type];
    [dbMsg setXmppType:userMsg.xmppType];
    [dbMsg setOaid:userMsg.oaid];
    [dbMsg setTitle:userMsg.title];
    [dbMsg setContent:userMsg.content];
    [dbMsg setLink:userMsg.link];
    [dbMsg setImageUrl:userMsg.imageUrl];
    [dbMsg setBodyFrom:userMsg.bodyFrom];
    [dbMsg setFromUserAvatar:userMsg.fromUserAvatar];
    [dbMsg setFromUserName:userMsg.fromUserName];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
    if (!dbMsg.date)
    {
        [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
    }
        
 

    NSNumber  *newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertNotifyMessage:dbMsg];

    return newMsgID;

}
-(void)main
{
    @autoreleasepool
    {
        for(NSObject *receiveMsg in YTZMsgs)
        {
            NSNumber *newMsgID = nil;
            if (receiveMsg&&[receiveMsg isKindOfClass:[XMPPNoticeMessage class]])
            {
                newMsgID = [self excuteUserMsgWithMsg:(XMPPNoticeMessage *)receiveMsg];
            }
            if (newMsgID)
            {
                //[[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
                [[PalmUIManagement sharedInstance] setNoticeArray:[[[CPSystemEngine sharedInstance] dbManagement] findAllNewNotiyfMessages]];
                [[CPSystemEngine sharedInstance] updateTagByNoticeMsg];
            }
        }
    }
}
@end
