//
//  CPOperationReceive.m
//  iCouple
//
//  Created by yong wei on 12-4-23.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "CPOperationMsgReceive.h"
#import "XMPPUserMessage.h"
#import "XMPPGroupMessage.h"
#import "CPSystemEngine.h"
#import "CPLGModelAccount.h"
#import "CPMsgManager.h"
#import "CPDBModelMessage.h"
#import "CPUIModelMessage.h"
#import "CPDBManagement.h"
#import "CoreUtils.h"
#import "CPResManager.h"
#import "CPUIModelManagement.h"
#import "ModelConvertUtils.h"
#import "MsgPlaySound.h"
#import "AlarmClockHelper.h"
@implementation CPOperationMsgReceive
- (id) initWithMsgs:(NSArray *) receiveMsgs
{
    self = [super init];
    if (self)
    {
        userMsgs = receiveMsgs;
    }
    return self;
}

-(NSNumber *)excuteUserMsgWithMsg:(XMPPUserMessage *)userMsg
{
    
    NSString *fromUserAccount = userMsg.from;
    //NSString *toUserAccount = userMsg.to;
    NSString *msgText = userMsg.message;
    NSInteger receiveMsgType = [userMsg.type integerValue];
    NSNumber *alarmTimeNumber = nil;
    NSString *alarmIsHidden = nil;
    //收到一个ttw，沉淀在xiaoshuang中；收到一个ttd，沉淀在IM中,即不做任何处理
    if (receiveMsgType==UserMessageTypeAsk)//||receiveMsgType==UserMessageTypeAnswer)
    {
        fromUserAccount = @"xiaoshuang";
    }
    NSNumber *msgGroupID = [[[CPSystemEngine sharedInstance] msgManager] getMsgGroupIdWithUserName:fromUserAccount];
    NSNumber *newMsgID = nil;
    //    if (msgGroupID)
    {
        CPDBModelMessage *dbMsg = [[CPDBModelMessage alloc] init];
        if (receiveMsgType==UserMessageTypeAsk)
        {
            [dbMsg setMsgOwnerName:@"xiaoshuang"];
        }
        else
        {
            [dbMsg setMsgOwnerName:[ModelConvertUtils getAccountNameWithName:userMsg.from]];
        }
        [dbMsg setMsgSenderID:[ModelConvertUtils getAccountNameWithName:userMsg.from]];
        [dbMsg setMsgGroupID:msgGroupID];
        [dbMsg setMsgText:msgText];
        [dbMsg setDate:userMsg.delayedTime];
        [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_STATUS_IS_NOT_READ]];
        NSString *fileSuffix = nil;
        NSString *mimeType = @"";
        NSInteger dbResType = 0;
        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DEFAULT]];
        switch (receiveMsgType)
        {
            case UserMessageTypeUnknown:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_UNKNOWN]];
                [dbMsg setMsgText:NSLocalizedString(@"AutoMsgUpdateMsg",nil)];
                break;
            case UserMessageTypeText:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
                break;
            case UserMessageTypeImage:
                [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_IMG]];
                dbResType = RESOURCE_FILE_TYPE_MSG_IMG;
                fileSuffix = @"jpg";
                mimeType = @"image/jpeg";
                break;
            case UserMessageTypeAudio:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_AUDIO]];
                [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                dbResType = RESOURCE_FILE_TYPE_MSG_AUDIO;
                fileSuffix = @"amr";
                mimeType = @"audio/amr";
                break;
            case UserMessageTypeVideo:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_VIDEO]];
                dbResType = RESOURCE_FILE_TYPE_MSG_VIDEO;
                fileSuffix = @"mp4";
                mimeType = @"video/mp4";
                break;
            case UserMessageTypeMagic:
            case UserMessageTypeFeeling:
            case UserMessageTypeSound:
            case UserMessageTypeAsk:
            case UserMessageTypeAnswer:
                [dbMsg setMagicMsgID:userMsg.resID];
                [dbMsg setPetMsgID:userMsg.petID];
                fileSuffix = @"amr";
                mimeType = @"audio/amr";
                dbResType = RESOURCE_FILE_TYPE_MSG_AUDIO;
            {
                switch (receiveMsgType)
                {
                    case UserMessageTypeMagic:
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_MAGIC]];
                        break;
                    case UserMessageTypeFeeling:
                        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_CQ]];
                        break;
                    case UserMessageTypeSound:
                        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_CS]];
                        break;
                    case UserMessageTypeAsk:
                        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TTW]];
                        [dbMsg setUuidAsk:userMsg.uuid];
                        break;
                    case UserMessageTypeAnswer:
                        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TTD]];
                        [dbMsg setUuidAsk:userMsg.uuid];
                        break;
                }
            }
                break;
            case UserMessageTypeAlarm:
            {
                NSInteger alarmType = [userMsg.resourceWidth integerValue];
                alarmIsHidden = [NSString stringWithFormat:@"%@",userMsg.resourceHeight];
                if (alarmType==1)
                {
                    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARM_TEXT]];
                }
                else
                {
                    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARM_AUDIO]];
                    [dbMsg setMagicMsgID:userMsg.resID];
                    [dbMsg setPetMsgID:userMsg.petID];
                    fileSuffix = @"amr";
                    mimeType = @"audio/amr";
                    dbResType = RESOURCE_FILE_TYPE_MSG_AUDIO;
                }
                alarmTimeNumber = [CoreUtils getLongFormatWithDateString:userMsg.resourceThumb];
                [dbMsg setMobile:[alarmTimeNumber stringValue]];
                [dbMsg setLocationInfo:alarmIsHidden];
            }
                break;
            default:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
                mimeType = @"application/octet-stream";
                break;
        }
        [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
        if (!dbMsg.date)
        {
            [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
        }
        
        NSNumber *dbResID = nil;
        if (userMsg.resource&&![@"" isEqualToString:userMsg.resource]&&![userMsg.resource isEqual:[NSNull null]])
        {
            NSString *filePath = [NSString stringWithFormat:@"%@/msg/",[[[CPSystemEngine sharedInstance] accountModel] loginName]];
            CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
            NSString *fileUUID = [CoreUtils getUUID];
            [dbRes setFileName:[NSString stringWithFormat:@"%@.%@",fileUUID,fileSuffix]];
            [dbRes setFilePrefix:filePath];
            [dbRes setType:[NSNumber numberWithInt:dbResType]];
            if (dbResType==RESOURCE_FILE_TYPE_MSG_VIDEO)
            {
                [dbRes setMark:[NSNumber numberWithInt:MARK_PRE_DOWNLOAD]];
            }else
            {
                [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
            }
            [dbRes setServerUrl:userMsg.resource];
            [dbRes setMediaTime:userMsg.resContentLength];
            [dbRes setFileSize:userMsg.resContentSize];
            [dbRes setMimeType:mimeType];
            [dbRes setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_MSG]];
            dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
            [dbMsg setAttachResID:dbResID];
            newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
            
            [[[CPSystemEngine sharedInstance] dbManagement] updateResourceObjIDWithResID:dbResID obj_id:newMsgID];
            
            if (receiveMsgType==UserMessageTypeVideo&&[CoreUtils stringIsNotNull:userMsg.resourceThumb])
            {
                CPDBModelResource *dbResThub = [[CPDBModelResource alloc] init];
                [dbResThub setFileName:[NSString stringWithFormat:@"%@.jpg",fileUUID]];
                [dbResThub setFilePrefix:filePath];
                [dbResThub setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
                [dbResThub setType:[NSNumber numberWithInt:RESOURCE_FILE_TYPE_MSG_IMG]];
                [dbResThub setServerUrl:userMsg.resourceThumb];
                [dbResThub setMimeType:@"image/jpeg"];
                [dbResThub setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_MSG]];
                [dbResThub setObjID:newMsgID];
                [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbResThub];
                
            }
            
            CPDBModelResource *newDbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithID:dbResID];
            if ([newDbRes.mark integerValue]==MARK_DEFAULT)
            {
                [[[CPSystemEngine sharedInstance] dbManagement] updateMessageWithID:newMsgID andStatus:[NSNumber numberWithInt:MSG_SEND_STATE_DOWN_SUCESS]];
            }
            else
            {
                if (newDbRes)
                {
                    [[[CPSystemEngine sharedInstance] dbManagement] addResCachedWithRes:newDbRes];
                }
                
                NSArray *downloadList = [[[CPSystemEngine sharedInstance] dbManagement] findAllResourcesWillDownload];
                [[[CPSystemEngine sharedInstance] resManager] reloadDownloadCacheWithArray:downloadList];
                
            }
            //                    [[[CPSystemEngine sharedInstance] resManager] excuteResourceCached];
        }
        else
        {
            newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
        }
        if (receiveMsgType==UserMessageTypeAlarm)
        {
            AlarmClockHelper *alarmHelper = [AlarmClockHelper sharedInstance];
            AlarmObject *object = [[AlarmObject alloc] init];
            object.msgID = [newMsgID stringValue];
            object.alarmTime = [CoreUtils getDateFormatWithLong: alarmTimeNumber];
            object.state = [NSNumber numberWithInt:Create];
            object.groupID = msgGroupID;
            object.userNickName = [[[[CPSystemEngine sharedInstance] dbManagement] findUserInfoWithAccount:[ModelConvertUtils getAccountNameWithName:fromUserAccount]] nickName];
            CPDBModelMessage *newMessage = [[[CPSystemEngine sharedInstance] dbManagement] findMessageWithID:newMsgID];
            if ([newMessage.contentType integerValue]==MSG_CONTENT_TYPE_ALARM_TEXT)
            {
                object.alarmClockType = [NSNumber numberWithInt:TextAlarmClock];
            }
            else
            {
                BOOL isHidden = [newMessage.locationInfo boolValue];
                if (isHidden)
                {
                    object.alarmClockType = [NSNumber numberWithInt:MysticalSoundAlarm];
                }
                else
                {
                    object.alarmClockType = [NSNumber numberWithInt:SoundAlarmClock];
                }
            }
            object.msgText = msgText;
            [alarmHelper addAlarmClockObject:object];
            [alarmHelper endTimeAlarm];
            [alarmHelper beginTimeAlarm];
        }
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSString *shakeKey = [NSString stringWithFormat:@"%@_Ringalert",account.uid];
        NSString *soundKey = [NSString stringWithFormat:@"%@_Vibration",account.uid];
        BOOL isShake = [[[NSUserDefaults standardUserDefaults] objectForKey:shakeKey] boolValue];
        BOOL isSound = [[[NSUserDefaults standardUserDefaults] objectForKey:soundKey] boolValue];
        if (isShake) {
            MsgPlaySound *play = [[MsgPlaySound alloc] initSystemShake];
            [play play];
        }
        if (isSound) {
            MsgPlaySound *play = [[MsgPlaySound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
            [play play];
        }
    }
    return newMsgID;
}
-(NSNumber *)excuteGroupMsgWithMsg:(XMPPGroupMessage *)userMsg
{
    CPLogInfo(@"-5- %@",userMsg);
    NSNumber *newMsgID = nil;
    //群聊信息，from是群得ID，to是自己，
    NSString *fromUserAccount = userMsg.from;
    //NSString *toUserAccount = userMsg.to;
    NSString *msgText = userMsg.message;
    NSNumber *msgGroupID = [[[CPSystemEngine sharedInstance] msgManager] getMsgGroupIdWithServerID:fromUserAccount];
    
    //    if (msgGroupID)
    {
        CPDBModelMessage *dbMsg = [[CPDBModelMessage alloc] init];
        [dbMsg setMsgGroupID:msgGroupID];
        [dbMsg setMsgText:msgText];
        [dbMsg setMsgOwnerName:fromUserAccount];
        [dbMsg setMsgSenderID:[ModelConvertUtils getAccountNameWithName:userMsg.sender]];
        [dbMsg setMsgGroupServerID:userMsg.from];
        [dbMsg setDate:userMsg.delayedTime];
        [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_STATUS_IS_NOT_READ]];
        NSInteger receiveMsgType = [userMsg.type integerValue];
        NSString *fileSuffix = nil;
        NSString *mimeType = @"";
        NSInteger dbResType = 0;
        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DEFAULT]];
        switch (receiveMsgType)
        {
            case GroupMessageTypeUnknown:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_UNKNOWN]];
                [dbMsg setMsgText:NSLocalizedString(@"AutoMsgUpdateMsg",nil)];
                break;
            case GroupMessageTypeText:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
                break;
            case GroupMessageTypeImage:
                [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_IMG]];
                dbResType = RESOURCE_FILE_GROUP_MSG_IMG;
                fileSuffix = @"jpg";
                mimeType = @"image/jpeg";
                break;
            case GroupMessageTypeAudio:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_AUDIO]];
                [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                dbResType = RESOURCE_FILE_GROUP_MSG_AUDIO;
                fileSuffix = @"amr";
                mimeType = @"audio/amr";
                break;
            case GroupMessageTypeVideo:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_VIDEO]];
                dbResType = RESOURCE_FILE_GROUP_MSG_VIDEO;
                fileSuffix = @"mp4";
                mimeType = @"video/mp4";
                break;
            case GroupMessageTypeMagic:
                //            case GroupMessageTypeFeeling:
            case GroupMessageTypeSound:
                //            case GroupMessageTypeAsk:
                [dbMsg setMagicMsgID:userMsg.resID];
                [dbMsg setPetMsgID:userMsg.petID];
                dbResType = RESOURCE_FILE_GROUP_MSG_AUDIO;
                fileSuffix = @"amr";
                mimeType = @"audio/amr";
            {
                switch (receiveMsgType)
                {
                    case GroupMessageTypeMagic:
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_MAGIC]];
                        break;
                        //                    case GroupMessageTypeFeeling:
                        //                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_CQ]];
                        //                        break;
                    case GroupMessageTypeSound:
                        [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DOWNING]];
                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_CS]];
                        break;
                        //                    case GroupMessageTypeAsk:
                        //                        [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_CS]];
                        //                        break;
                }
            }
                break;
            default:
                [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
                mimeType = @"application/octet-stream";
                break;
        }
        [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
        if (!dbMsg.date)
        {
            [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
        }
        CPLogInfo(@"-6- %@",userMsg);
        NSNumber *dbResID = nil;
        if (userMsg.resource&&![@"" isEqualToString:userMsg.resource]&&![userMsg.resource isEqual:[NSNull null]])
        {
            NSString *filePath = [NSString stringWithFormat:@"%@/msg/",[[[CPSystemEngine sharedInstance] accountModel] loginName]];
            CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
            NSString *fileUUID = [CoreUtils getUUID];
            [dbRes setFileName:[NSString stringWithFormat:@"%@.%@",fileUUID,fileSuffix]];
            [dbRes setFilePrefix:filePath];
            [dbRes setType:[NSNumber numberWithInt:dbResType]];
            if (dbResType==RESOURCE_FILE_GROUP_MSG_VIDEO)
            {
                [dbRes setMark:[NSNumber numberWithInt:MARK_PRE_DOWNLOAD]];
            }else
            {
                [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
            }
            [dbRes setServerUrl:userMsg.resource];
            [dbRes setMediaTime:userMsg.resContentLength];
            [dbRes setFileSize:userMsg.resContentSize];
            [dbRes setMimeType:mimeType];
            [dbRes setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_MSG]];
            dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
            [dbMsg setAttachResID:dbResID];
            newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
            
            [[[CPSystemEngine sharedInstance] dbManagement] updateResourceObjIDWithResID:dbResID obj_id:newMsgID];
            
            if ([CoreUtils stringIsNotNull:userMsg.resourceThumb])
            {
                CPDBModelResource *dbResThub = [[CPDBModelResource alloc] init];
                [dbResThub setFileName:[NSString stringWithFormat:@"%@.jpg",fileUUID]];
                [dbResThub setFilePrefix:filePath];
                [dbResThub setType:[NSNumber numberWithInt:RESOURCE_FILE_TYPE_MSG_IMG]];
                [dbResThub setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
                [dbResThub setServerUrl:userMsg.resourceThumb];
                [dbResThub setMimeType:@"image/jpeg"];
                [dbResThub setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_MSG]];
                [dbResThub setObjID:newMsgID];
                [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbResThub];
                
            }
            
            CPDBModelResource *newDbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithID:dbResID];
            if ([newDbRes.mark integerValue]==MARK_DEFAULT)
            {
                [[[CPSystemEngine sharedInstance] dbManagement] updateMessageWithID:newMsgID andStatus:[NSNumber numberWithInt:MSG_SEND_STATE_DOWN_SUCESS]];
            }
            else
            {
                if (newDbRes)
                {
                    [[[CPSystemEngine sharedInstance] dbManagement] addResCachedWithRes:newDbRes];
                }
                
                NSArray *downloadList = [[[CPSystemEngine sharedInstance] dbManagement] findAllResourcesWillDownload];
                [[[CPSystemEngine sharedInstance] resManager] reloadDownloadCacheWithArray:downloadList];
                
            }
            //                    [[[CPSystemEngine sharedInstance] resManager] excuteResourceCached];
        }
        else
        {
            CPLogInfo(@"-7- %@",userMsg);
            newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
        }
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSString *shakeKey = [NSString stringWithFormat:@"%@_Ringalert",account.uid];
        NSString *soundKey = [NSString stringWithFormat:@"%@_Vibration",account.uid];
        BOOL isShake = [[[NSUserDefaults standardUserDefaults] objectForKey:shakeKey] boolValue];
        BOOL isSound = [[[NSUserDefaults standardUserDefaults] objectForKey:soundKey] boolValue];
        if (isShake) {
            MsgPlaySound *play = [[MsgPlaySound alloc] initSystemShake];
            [play play];
        }
        if (isSound) {
            MsgPlaySound *play = [[MsgPlaySound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
            [play play];
        }
    }
    return newMsgID;
}
-(void)main
{
    @autoreleasepool
    {
        for(NSObject *receiveMsg in userMsgs)
        {
            NSNumber *newMsgID = nil;
            if (receiveMsg&&[receiveMsg isKindOfClass:[XMPPUserMessage class]])
            {
                newMsgID = [self excuteUserMsgWithMsg:(XMPPUserMessage *)receiveMsg];
            }
            else if (receiveMsg&&[receiveMsg isKindOfClass:[XMPPGroupMessage class]])
            {
                newMsgID = [self excuteGroupMsgWithMsg:(XMPPGroupMessage *)receiveMsg];
            }
            if (newMsgID)
            {
                [[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
            }
        }
    }
}

@end
