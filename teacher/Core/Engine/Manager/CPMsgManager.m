//
//  CPMsgManager.m
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPMsgManager.h"
#import "XMPPSystemMessage.h"
#import "CPSystemEngine.h"
#import "CPSystemManager.h"
#import "CPUserManager.h"
#import "CPDBManagement.h"
#import "ModelConvertUtils.h"
#import "CPUIModelManagement.h"

#import "CPUIModelMessage.h"
#import "CPUIModelMessageGroup.h"
#import "CPUIModelMessageGroupMember.h"
#import "CPDBModelMessage.h"
#import "CPDBModelMessageGroup.h"
#import "CPDBModelMessageGroupMember.h"

#import "CoreUtils.h"

#import "XMPPUserMessage.h"
#import "XMPPGroupMessage.h"
#import "XMPPGroupMemberChangeMessage.h"
#import "CPXmppEngine.h"
#import "CPHttpEngine.h"

#import "CPResManager.h"
#import "HPTopTipView.h"
#import "AsiGetRequestModel.h"

@implementation CPMsgManager

@synthesize willSendXmppMsg = willSendXmppMsg_;
-(id)init
{
    self = [super init];
    if (self) 
    {
        if (!self.willSendXmppMsg) 
        {
            self.willSendXmppMsg = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
    
}
#pragma mark ui managament method
-(void)refreshMsgGroupWithUserInfo:(CPDBModelUserInfo *)dbUserInfo
{
    NSArray *oldMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
    BOOL hasCompare = NO;
    for(CPUIModelMessageGroup *uiMsgGroup in oldMsgGroups)
    {
        if ([uiMsgGroup isMsgSingleGroup])
        {
            if ([uiMsgGroup.memberList count]==1)
            {
                CPUIModelUserInfo *uiUserInfo = [(CPUIModelMessageGroupMember *)[uiMsgGroup.memberList objectAtIndex:0] userInfo];
                if (dbUserInfo.userInfoID&&uiUserInfo.userInfoID&&[dbUserInfo.userInfoID isEqualToNumber:uiUserInfo.userInfoID])
                {
                    [ModelConvertUtils convertDbUserInfoToUi:dbUserInfo withUiUserInfo:uiUserInfo];
                    if (uiUserInfo.coupleAccount)
                    {
                        CPDBModelUserInfo *dbUserCouple = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiUserInfo.coupleAccount];
                        if (dbUserCouple)
                        {
                            [uiUserInfo setCoupleUserInfo:[ModelConvertUtils dbUserInfoToUi:dbUserCouple]];
                        }
                    }
                    hasCompare = YES;
                }
            }
        }
    }
    if (hasCompare) 
    {
        [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
    }
}
-(void)refreshCurrentMsgGroupWithUserInfo:(CPDBModelUserInfo *)dbUserInfo
{
    CPUIModelMessageGroup *uiMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
    if ([uiMsgGroup isMsgSingleGroup])
    {
        if ([uiMsgGroup.memberList count]==1)
        {
            CPUIModelUserInfo *uiUserInfo = [(CPUIModelMessageGroupMember *)[uiMsgGroup.memberList objectAtIndex:0] userInfo];
            if (dbUserInfo.userInfoID&&uiUserInfo.userInfoID&&[dbUserInfo.userInfoID isEqualToNumber:uiUserInfo.userInfoID])
            {
                [ModelConvertUtils convertDbUserInfoToUi:dbUserInfo withUiUserInfo:uiUserInfo];
                if (uiUserInfo.coupleAccount)
                {
                    CPDBModelUserInfo *dbUserCouple = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiUserInfo.coupleAccount];
                    if (dbUserCouple)
                    {
                        [uiUserInfo setCoupleUserInfo:[ModelConvertUtils dbUserInfoToUi:dbUserCouple]];
                    }
                }
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupMemList];
            }
        }
    }
}
-(void)refreshCoupleMsgGroupWithUserInfo:(CPDBModelUserInfo *)dbUserInfo
{
    CPUIModelMessageGroup *coupleMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
    if ([coupleMsgGroup isMsgSingleGroup])
    {
        if ([coupleMsgGroup.memberList count]==1)
        {
            CPUIModelUserInfo *uiUserInfo = [(CPUIModelMessageGroupMember *)[coupleMsgGroup.memberList objectAtIndex:0] userInfo];
            if (dbUserInfo.userInfoID&&uiUserInfo.userInfoID&&[dbUserInfo.userInfoID isEqualToNumber:uiUserInfo.userInfoID])
            {
                [ModelConvertUtils convertDbUserInfoToUi:dbUserInfo withUiUserInfo:uiUserInfo];
                [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupMemList];
            }
        }
    }
}

-(CPUIModelMessage *)uiMsgConvertByCachedResWithDbMsg:(CPDBModelMessage *)dbMsg
{
    NSString *documentPath = [CoreUtils getDocumentPath];
    CPUIModelMessage *uiMsg = [ModelConvertUtils dbMessageToUi:dbMsg];
    if (uiMsg.attachResID&&[uiMsg.attachResID longLongValue]>0) 
    {
        CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] getResCachedWithID:uiMsg.attachResID];
        if (dbRes&&dbRes.filePrefix&&dbRes.fileName)
        {
            [uiMsg setMediaTime:dbRes.mediaTime];
            [uiMsg setFilePath:[NSString stringWithFormat:@"%@/%@%@",documentPath,dbRes.filePrefix,dbRes.fileName]];
        }
    }
    return uiMsg;
}
-(NSArray *)getMsgListAskWithMsg:(CPUIModelMessage *)uiMsg
{
    if([uiMsg.contentType integerValue]==MSG_CONTENT_TYPE_TTW)
    {
        return [NSArray arrayWithObject:uiMsg];
    }
    if (!uiMsg.msgGroupID||!uiMsg.uuidAsk)
    {
        CPLogInfo(@"%@---%@",uiMsg.msgGroupID,uiMsg.uuidAsk);
        return nil;
    }
    NSMutableArray *newMsgAskList = [[NSMutableArray alloc] init];
    CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:uiMsg.msgGroupID];
    if (dbMsgGroup)
    {
        NSArray *msgList = dbMsgGroup.msgList;
        for(CPDBModelMessage *dbMsg in msgList)
        {
            if ([dbMsg.contentType integerValue]==MSG_CONTENT_TYPE_TTW&&dbMsg.uuidAsk&&[dbMsg.uuidAsk isEqualToString:uiMsg.uuidAsk])
            {
                [newMsgAskList addObject:[self uiMsgConvertByCachedResWithDbMsg:dbMsg]];
            }
        }
        if ([dbMsgGroup isSysMsgGroup])
        {
            NSString *sendUserName = uiMsg.msgSenderName;
            CPDBModelMessageGroup *userMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:sendUserName];
            for(CPDBModelMessage *dbMsg in userMsgGroup.msgList)
            {
                if ([dbMsg.contentType integerValue]==MSG_CONTENT_TYPE_TTW&&dbMsg.uuidAsk&&[dbMsg.uuidAsk isEqualToString:uiMsg.uuidAsk])
                {
                    [newMsgAskList addObject:[self uiMsgConvertByCachedResWithDbMsg:dbMsg]];
                }
            }
        }
        else 
        {
            CPDBModelMessageGroup *sysMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:@"xiaoshuang"];
            for(CPDBModelMessage *dbMsg in sysMsgGroup.msgList)
            {
                if ([dbMsg.contentType integerValue]==MSG_CONTENT_TYPE_TTW&&dbMsg.uuidAsk&&[dbMsg.uuidAsk isEqualToString:uiMsg.uuidAsk])
                {
                    [newMsgAskList addObject:[self uiMsgConvertByCachedResWithDbMsg:dbMsg]];
                }
            }
        }
    }
    return newMsgAskList;
}
#pragma mark init method
-(CPUIModelMessage *)uiMsgConvertWithDbMsg:(CPDBModelMessage *)dbMsg
{
    NSString *documentPath = [CoreUtils getDocumentPath];
    CPUIModelMessage *uiMsg = [ModelConvertUtils dbMessageToUi:dbMsg];
    if (uiMsg.attachResID&&[uiMsg.attachResID longLongValue]>0) 
    {
        CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] getResWithID:uiMsg.attachResID];
        if (dbRes&&dbRes.filePrefix&&dbRes.fileName)
        {
            if ([dbRes isVideoMsg])
            {
                NSString *fileNameThub = [dbRes.fileName stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
                NSString *thubPath = [NSString stringWithFormat:@"%@/%@%@",documentPath,dbRes.filePrefix,fileNameThub];
                [uiMsg setThubFilePath:thubPath];
                
                if (!dbRes.fileSize||[dbRes.fileSize intValue]==0)
                {
                    NSString *filePath = [[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes];
                    NSNumber *fileSize = [CoreUtils getFileSizeWithName:filePath];
                    [[[CPSystemEngine sharedInstance] msgManager] updateXmppMsgWithFileSize:fileSize andMsgID:dbRes.objID];
                    [dbRes setFileSize:fileSize];
                    [[[CPSystemEngine sharedInstance] dbManagement] updateResourceWithID:dbRes.resID obj:dbRes];
                }else 
                {
                    [uiMsg setFileSize:dbRes.fileSize];
                }
            }
            [uiMsg setMediaTime:dbRes.mediaTime];
            [uiMsg setFilePath:[NSString stringWithFormat:@"%@/%@%@",documentPath,dbRes.filePrefix,dbRes.fileName]];
//            CPLogInfo(@"msg 's file path is   %@",uiMsg.filePath);
        }
    }
    return uiMsg;
}

-(void)addWillSendMsg:(NSObject *)xmppMsg andMsgID:(NSNumber *)msgID
{
    [self.willSendXmppMsg setObject:xmppMsg forKey:msgID];
}
-(XMPPUserMessage *)getWillSendMsgWithID:(NSNumber *)msgID
{
    return [self.willSendXmppMsg objectForKey:msgID];
}
-(void)removeWillSendXmppMsg:(NSNumber *)msgID
{
    [self.willSendXmppMsg removeObjectForKey:msgID];
}
-(void)updateXmppMsgWithThub:(NSString *)thubServerUrl andMsgID:(NSNumber *)msgID
{
    NSObject *xmppMsg = [self getWillSendMsgWithID:msgID];
    if (xmppMsg)
    {
        if ([xmppMsg isKindOfClass:[XMPPUserMessage class]])
        {
            XMPPUserMessage *singleMsg = (XMPPUserMessage *)xmppMsg;
            [singleMsg setResourceThumb:thubServerUrl];
        }
        else if([xmppMsg isKindOfClass:[XMPPGroupMessage class]])
        {
            XMPPGroupMessage *groupMsg = (XMPPGroupMessage *)xmppMsg;
            [groupMsg setResourceThumb:thubServerUrl];
        }
    }
}
-(void)updateXmppMsgWithFileSize:(NSNumber *)fileSize andMsgID:(NSNumber *)msgID
{
    NSObject *xmppMsg = [self getWillSendMsgWithID:msgID];
    if (xmppMsg)
    {
        if ([xmppMsg isKindOfClass:[XMPPUserMessage class]])
        {
            XMPPUserMessage *singleMsg = (XMPPUserMessage *)xmppMsg;
            [singleMsg setResContentSize:fileSize];
        }
        else if([xmppMsg isKindOfClass:[XMPPGroupMessage class]])
        {
            XMPPGroupMessage *groupMsg = (XMPPGroupMessage *)xmppMsg;
            [groupMsg setResContentSize:fileSize];
        }
    }
}
-(void)updateXmppMsgWithMediaTime:(NSNumber *)mediaTime andMsgID:(NSNumber *)msgID
{
    NSObject *xmppMsg = [self getWillSendMsgWithID:msgID];
    if (xmppMsg)
    {
        if ([xmppMsg isKindOfClass:[XMPPUserMessage class]])
        {
            XMPPUserMessage *singleMsg = (XMPPUserMessage *)xmppMsg;
            [singleMsg setResContentLength:mediaTime];
        }
        else if([xmppMsg isKindOfClass:[XMPPGroupMessage class]])
        {
            XMPPGroupMessage *groupMsg = (XMPPGroupMessage *)xmppMsg;
            [groupMsg setResContentLength:mediaTime];
        }
    }
}
-(void)initMsgGroups
{
//    NSArray *msgGroups = [[[CPSystemEngine sharedInstance] dbManagement] findAllMessageGroups];
    
    
}
-(void)sendMsgByWillCachedWithID:(NSNumber *)msgID resUrl:(NSString *)resUrl
{
    CPLogInfo(@"msgID is %@,resUrl is %@",msgID,resUrl);
    CPLogInfo(@"willSendXmppMsg is %@",self.willSendXmppMsg);
    if (!msgID||!resUrl)
    {
        return;
    }
    NSObject *xmppMsg = [self getWillSendMsgWithID:msgID];
    if (xmppMsg)
    {
        if ([xmppMsg isKindOfClass:[XMPPUserMessage class]])
        {
            XMPPUserMessage *singleMsg = (XMPPUserMessage *)xmppMsg;
            [singleMsg setResource:resUrl];
            [[[CPSystemEngine sharedInstance] sysManager] sendXMPPMsg:singleMsg];
        }
        else if([xmppMsg isKindOfClass:[XMPPGroupMessage class]])
        {
            XMPPGroupMessage *groupMsg = (XMPPGroupMessage *)xmppMsg;
            [groupMsg setResource:resUrl];
            [[[CPSystemEngine sharedInstance] xmppEngine] sendGroupMessage:groupMsg];
        }
        [self.willSendXmppMsg removeObjectForKey:msgID];
    }
}
-(void)removeAllWillSendXmppMsgs
{
    if (self.willSendXmppMsg&&[self.willSendXmppMsg count]>0)
    {
        [[CPSystemEngine sharedInstance] removeWillSendMsgsByOperationWithIDs:[self.willSendXmppMsg allKeys]];
        [self.willSendXmppMsg removeAllObjects];
    }
}
-(CPUIModelMessageGroup *)uiMsgGroupConvertWithDbMsgGroup:(CPDBModelMessageGroup *)msgGroup
{
    CPUIModelMessageGroup *uiMsgGroup = [ModelConvertUtils dbMessageGroupToUi:msgGroup];
    NSMutableArray *groupMemberArray = [[NSMutableArray alloc] init];
    for(CPDBModelMessageGroupMember *dbMsgMember in msgGroup.memberList)
    {
        CPUIModelMessageGroupMember *uiMsgGroupMember = [ModelConvertUtils dbMessageGroupMemberToUi:dbMsgMember];
        CPUIModelUserInfo *userInfo = [ModelConvertUtils dbUserInfoToUi:[[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:dbMsgMember.userName]];
        if (userInfo)
        {
            [uiMsgGroupMember setUserInfo:userInfo];
            [uiMsgGroupMember setNickName:userInfo.nickName];
            [uiMsgGroupMember setHeaderPath:userInfo.headerPath];
            [uiMsgGroupMember setUserName:userInfo.name];
            [uiMsgGroupMember setDomain:userInfo.domain];
        }
        else 
        {
            CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithServerUrl:dbMsgMember.headerPath];
            [uiMsgGroupMember setHeaderPath:[[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes]];
        }
        
        [groupMemberArray addObject:uiMsgGroupMember];
    }
    [uiMsgGroup setMemberList:[groupMemberArray sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
    
    NSMutableArray *groupMsgList = [[NSMutableArray alloc] init];
    NSInteger dbMsgCount = [msgGroup.msgList count];
    //        for(CPDBModelMessage *dbMsg in msgGroup.msgList)
    for(int i=0;i<dbMsgCount;i++)
    {
        if (dbMsgCount-i>USER_MSG_INIT_MAX_COUNT)
        {
            continue;
        }
        CPDBModelMessage *dbMsg = [msgGroup.msgList objectAtIndex:i];
        [groupMsgList addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
    }
    [uiMsgGroup setMsgList:groupMsgList];
    return uiMsgGroup;
}
-(void)refreshMsgGroupList
{
    NSArray *msgGroupList = [[[CPSystemEngine sharedInstance] dbManagement] findAllMessageGroups];
    NSMutableArray *uiMsgGroupList = [[NSMutableArray alloc] init];
    NSInteger friendMsgGroupUnReadedCount = 0;
    NSInteger coupleMsgGroupUnReadedCount = 0;
    NSInteger closedMsgGroupUnReadedCount = 0;

    BOOL hasResponseUserName = NO;
    NSString *responseActionUserName = [[[CPSystemEngine sharedInstance] userManager] responseActionUserName];

    for(CPDBModelMessageGroup *msgGroup in msgGroupList)
    {
        CPUIModelMessageGroup *uiMsgGroup = [ModelConvertUtils dbMessageGroupToUi:msgGroup];
        NSInteger msgGroupRelationType = [uiMsgGroup.relationType integerValue];
        switch (msgGroupRelationType)
        {
            case MSG_GROUP_UI_RELATION_TYPE_COMMON:
                friendMsgGroupUnReadedCount += [uiMsgGroup.unReadedCount integerValue];
                break;
            case MSG_GROUP_UI_RELATION_TYPE_COUPLE:
                coupleMsgGroupUnReadedCount += [uiMsgGroup.unReadedCount integerValue];
                break;
            case MSG_GROUP_UI_RELATION_TYPE_CLOSER:
                closedMsgGroupUnReadedCount += [uiMsgGroup.unReadedCount integerValue];
                break;
            default:
                break;
        }
        
        NSMutableArray *groupMemberArray = [[NSMutableArray alloc] init];
        for(CPDBModelMessageGroupMember *dbMsgMember in msgGroup.memberList)
        {
            CPUIModelMessageGroupMember *uiMsgGroupMember = [ModelConvertUtils dbMessageGroupMemberToUi:dbMsgMember];
            CPUIModelUserInfo *userInfo = [ModelConvertUtils dbUserInfoToUi:[[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:dbMsgMember.userName]];
            if (userInfo)
            {
                [uiMsgGroupMember setUserInfo:userInfo];
                [uiMsgGroupMember setNickName:userInfo.nickName];
                [uiMsgGroupMember setHeaderPath:userInfo.headerPath];
                [uiMsgGroupMember setUserName:userInfo.name];
                [uiMsgGroupMember setDomain:userInfo.domain];
            }
            else 
            {
                CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithServerUrl:dbMsgMember.headerPath];
                [uiMsgGroupMember setHeaderPath:[[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes]];
            }

            [groupMemberArray addObject:uiMsgGroupMember];
        }
        [uiMsgGroup setMemberList:[groupMemberArray sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
        
        NSMutableArray *groupMsgList = [[NSMutableArray alloc] init];
        NSInteger dbMsgCount = [msgGroup.msgList count];
//        for(CPDBModelMessage *dbMsg in msgGroup.msgList)
        for(int i=0;i<dbMsgCount;i++)
        {
            if (dbMsgCount-i>USER_MSG_INIT_MAX_COUNT)
            {
                continue;
            }
            CPDBModelMessage *dbMsg = [msgGroup.msgList objectAtIndex:i];
            [groupMsgList addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
        }
        [uiMsgGroup setMsgList:groupMsgList];

        
        if ([uiMsgGroup.relationType integerValue]==MSG_GROUP_UI_RELATION_TYPE_COUPLE) 
        {
            [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:uiMsgGroup];
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
        }
        else
        {
            [uiMsgGroupList addObject:uiMsgGroup];
        }
        //
        if (responseActionUserName)
        {
            NSInteger msgGroupType = [uiMsgGroup.type integerValue];
            if (msgGroupType==MSG_GROUP_UI_TYPE_SINGLE||msgGroupType==MSG_GROUP_UI_TYPE_SINGLE_PRE)
            {
                if ([uiMsgGroup.memberList count]>0)
                {
                    CPUIModelMessageGroupMember *uiGroupMem = [uiMsgGroup.memberList objectAtIndex:0];
                    if (uiGroupMem.userName&&[uiGroupMem.userName isEqualToString:responseActionUserName])
                    {
                        NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
                        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:response_action_res_code];
                        [resDic setObject:uiMsgGroup forKey:response_action_msg_group];
                        [[CPSystemEngine sharedInstance] updateTagByResponseActionWithDic:resDic];
                        hasResponseUserName = YES;
                        [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:uiMsgGroup.msgGroupID
                                                                                    andGroupType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                        CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:uiMsgGroup.msgGroupID];
                        [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                    }
                }
            }
        }
    }
    if (responseActionUserName)
    {
        if (hasResponseUserName)
        {
            //
        }
        else 
        {
            NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
            [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:response_action_res_code];
            [resDic setObject:@"服务器正在开小差，请退出应用重试" forKey:response_action_res_desc];
            [[CPSystemEngine sharedInstance] updateTagByResponseActionWithDic:resDic];
        }
        [[[CPSystemEngine sharedInstance] userManager] setResponseActionUserName:nil];
    }
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[uiMsgGroupList sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
    
    if (friendMsgGroupUnReadedCount>0)
    {
        [[CPSystemEngine sharedInstance] updateTagByFriendMsgUnReadedCount:friendMsgGroupUnReadedCount];
    }
    if (coupleMsgGroupUnReadedCount>0)
    {
        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgUnReadedCount:coupleMsgGroupUnReadedCount];
    }
    if (closedMsgGroupUnReadedCount>0)
    {
        [[CPSystemEngine sharedInstance] updateTagByClosedMsgUnReadedCount:closedMsgGroupUnReadedCount];
    }
}

-(void)refreshMsgListWithMsgGroupID:(NSNumber *)msgGroupID isCreated:(BOOL)isCreatedConver
{
    if (msgGroupID)
    {
        CPDBModelMessageGroup *newDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:msgGroupID];
        if (newDbMsgGroup)
        {
            CPUIModelMessageGroup *uiMsgGroup = [ModelConvertUtils dbMessageGroupToUi:newDbMsgGroup];
            NSArray *dbMsgList =  [[[CPSystemEngine sharedInstance] dbManagement] findAllMessagesWithGroupID:msgGroupID];
            if (dbMsgList) 
            {
                NSMutableArray *uiMsgList = [[NSMutableArray alloc] init];
                NSInteger dbMsgCount = [dbMsgList count];
                for(int i=0;i<dbMsgCount;i++)
//              for(int i=dbMsgCount-1;i>=0;i--)
                {
                    if (dbMsgCount-i>USER_MSG_INIT_MAX_COUNT)
                    {
                        continue;
                    }
                    CPDBModelMessage *dbMsg = [dbMsgList objectAtIndex:i];
                    [uiMsgList addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
                }
                [uiMsgGroup setMsgList:uiMsgList];
                if ([dbMsgList count]>0)
                {
                    NSInteger msgGroupType = [uiMsgGroup.type integerValue];
                    if (msgGroupType>10)
                    {
                        NSInteger unReadedCount = 0;
                        for(CPDBModelMessage *dbMsg in dbMsgList)
                        {
                            if ([dbMsg.isReaded integerValue]>0)
                            {
                                unReadedCount ++;
                            }
                        }
                        [uiMsgGroup setUnReadedCount:[NSNumber numberWithInt:unReadedCount]];
                        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupUnReadedCountWithID:msgGroupID
                                                                                                     andCount:[NSNumber numberWithInt:unReadedCount]];
                        NSNumber *newMsgGroupType = [NSNumber numberWithInt:msgGroupType-10];
                        [uiMsgGroup setType:newMsgGroupType];
                        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:msgGroupID 
                                                                                    andGroupType:newMsgGroupType];
                    }
                }
            }
            [uiMsgGroup setMsgGroupID:newDbMsgGroup.msgGroupID];
            NSArray *msgGroupMemberList = [[[CPSystemEngine sharedInstance] dbManagement] findAllMessageGroupMembersWithGroupID:msgGroupID];
            CPDBModelMessageGroup *cachedDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:msgGroupID];
            [cachedDbMsgGroup setMemberList:msgGroupMemberList];
            if (msgGroupMemberList)
            {
                NSMutableArray *uiGroupMemberList = [[NSMutableArray alloc] init];
                for(CPDBModelMessageGroupMember *dbGroupMember in msgGroupMemberList)
                {
                    CPUIModelMessageGroupMember *uiGroupMember = [ModelConvertUtils dbMessageGroupMemberToUi:dbGroupMember];
                    CPUIModelUserInfo *userInfo = [ModelConvertUtils dbUserInfoToUi:[[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiGroupMember.userName]];
                    if (userInfo)
                    {
                        [uiGroupMember setUserInfo:userInfo];
                        [uiGroupMember setNickName:userInfo.nickName];
                        [uiGroupMember setHeaderPath:userInfo.headerPath];
                        [uiGroupMember setUserName:userInfo.name];
                        [uiGroupMember setDomain:userInfo.domain];
                    }
                    else 
                    {
                        CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithServerUrl:dbGroupMember.headerPath];
                        [uiGroupMember setHeaderPath:[[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes]];
                    }

                    [uiGroupMemberList addObject:uiGroupMember];
                }
                [uiMsgGroup setMemberList:[uiGroupMemberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
            }   
            CPUIModelMessageGroup *currentMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
            if (currentMsgGroup.msgGroupID)
            {
                if ([currentMsgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
                {
                    [[CPUIModelManagement sharedInstance] setUserMsgGroup:uiMsgGroup];
                    [[CPSystemEngine sharedInstance] updateTagByMsgGroup];
                }
            }
            if (isCreatedConver)
            {
                [[CPUIModelManagement sharedInstance] setUserMsgGroup:uiMsgGroup];
                //get member 's recent and profile
                if (uiMsgGroup)
                {
                    if ([uiMsgGroup isMsgSingleGroup]&&[uiMsgGroup.memberList count]==1)
                    {
                        CPUIModelUserInfo *uiUserInfo = [(CPUIModelMessageGroupMember *)[uiMsgGroup.memberList objectAtIndex:0] userInfo];
                        if (uiUserInfo.name)
                        {
                            [[[CPSystemEngine sharedInstance] userManager] getUserProfileWithUserName:uiUserInfo.name];
                            [[[CPSystemEngine sharedInstance] userManager] getUserRecentWithUserName:uiUserInfo.name];
                        }
                    }
                }    
                [[CPSystemEngine sharedInstance] updateTagByCreateMsgGroupWithCode:[NSNumber numberWithInt:RES_CODE_SUCESS]];
            }
            NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
            BOOL hasExistMsgGroup = NO;
            for(int i=0;i<[oldUserMsgList count];i++)
            {
                CPUIModelMessageGroup *uiOldMsgGroup = [oldUserMsgList objectAtIndex:i];
                if ([uiOldMsgGroup.msgGroupID compare:msgGroupID]==NSOrderedSame)
                {
                    hasExistMsgGroup = YES;
                    [oldUserMsgList replaceObjectAtIndex:i withObject:uiMsgGroup];
                    break;
                }
            }
//            NSLog(@"11 oldUserMsgList is %@",oldUserMsgList);
            if (!hasExistMsgGroup)
            {
                [oldUserMsgList insertObject:uiMsgGroup atIndex:0];
            }
//            NSLog(@"22 oldUserMsgList is %@",oldUserMsgList);
            [[CPUIModelManagement sharedInstance] setUserMessageGroupList:oldUserMsgList];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
            [self refreshSysUnReadedCount];
        }
    }
}
-(void)refreshMsgGroupMemsWithMsgGroupID:(NSNumber *)msgGroupID
{
    if (msgGroupID)
    {
        NSArray *msgGroupMemberList = [[[CPSystemEngine sharedInstance] dbManagement] findAllMessageGroupMembersWithGroupID:msgGroupID];
        CPDBModelMessageGroup *cachedDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:msgGroupID];
        [cachedDbMsgGroup setMemberList:msgGroupMemberList];
        if (msgGroupMemberList)
        {
            NSMutableArray *uiGroupMemberList = [[NSMutableArray alloc] init];
            for(CPDBModelMessageGroupMember *dbGroupMember in msgGroupMemberList)
            {
                CPUIModelMessageGroupMember *uiGroupMember = [ModelConvertUtils dbMessageGroupMemberToUi:dbGroupMember];
                CPUIModelUserInfo *userInfo = [ModelConvertUtils dbUserInfoToUi:[[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiGroupMember.userName]];
                if (userInfo)
                {
                    [uiGroupMember setUserInfo:userInfo];
                    [uiGroupMember setNickName:userInfo.nickName];
                    [uiGroupMember setHeaderPath:userInfo.headerPath];
                    [uiGroupMember setUserName:userInfo.name];
                    [uiGroupMember setDomain:userInfo.domain];
                }
                else 
                {
                    CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithServerUrl:dbGroupMember.headerPath];
                    [uiGroupMember setHeaderPath:[[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes]];
                }
                [uiGroupMemberList addObject:uiGroupMember];
            }
            CPUIModelMessageGroup *currentMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
            if (currentMsgGroup.msgGroupID&&[currentMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
            {
                [currentMsgGroup setMemberList:[uiGroupMemberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupMemList];
            }
            NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
            BOOL hasExistMsgGroup = NO;
            for(int i=0;i<[oldUserMsgList count];i++)
            {
                CPUIModelMessageGroup *uiOldMsgGroup = [oldUserMsgList objectAtIndex:i];
                if ([uiOldMsgGroup.msgGroupID compare:msgGroupID]==NSOrderedSame)
                {
                    hasExistMsgGroup = YES;
                    [uiOldMsgGroup setMemberList:[uiGroupMemberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
                    break;
                }
            }
//            [[CPUIModelManagement sharedInstance] setUserMessageGroupList:oldUserMsgList];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
        } 
    }
}
-(void)refreshMsgGroupWithDelUserName:(NSString *)userName
{
    CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:userName];
    if (dbMsgGroup.msgGroupID)
    {
        CPUIModelMessageGroup *coupleUiMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
        if (coupleUiMsgGroup.msgGroupID&&[coupleUiMsgGroup.msgGroupID isEqualToNumber:dbMsgGroup.msgGroupID])
        {
            [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:nil];
            [[CPUIModelManagement sharedInstance] setCoupleModel:nil];
            [[CPSystemEngine sharedInstance] updateTagByCouple];
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
        }
        CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:dbMsgGroup.msgGroupID])
        {        
            [[CPUIModelManagement sharedInstance] setUserMsgGroup:nil];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
        }
        NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
        for(CPUIModelMessageGroup *uiMsgGroup in oldUserMsgList)
        {
            if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:dbMsgGroup.msgGroupID])
            {
                [oldUserMsgList removeObject:uiMsgGroup];
                break;
            } 
        }
        [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUserMsgList sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
        [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
        [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupWithID:dbMsgGroup.msgGroupID];
    }
}
#pragma mark private method
-(void)refreshCurrentConverGroupMsgListByHistoryWithGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    BOOL hasHistoryMsgs = NO;
    BOOL hasCoupleGroup = NO;
    if (uiMsgGroup&&uiMsgGroup.msgGroupID)
    {
        NSArray *oldMsgList = [[NSMutableArray alloc] initWithArray:uiMsgGroup.msgList];
        NSNumber *msgGroupID = [uiMsgGroup.msgGroupID copy];
        CPUIModelMessageGroup *coupleMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
        if (coupleMsgGroup.msgGroupID&&[coupleMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
            hasCoupleGroup = YES;
        }
        NSNumber *oldMsgTime = nil;
        if ([oldMsgList count]>0)
        {
            CPUIModelMessage *uiMsg = [oldMsgList objectAtIndex:0];
            if (uiMsg)
            {
                oldMsgTime = uiMsg.date;
            }
        }
        NSArray *dbMsgList = nil;
        if (oldMsgTime&&[oldMsgTime longLongValue]>0)
        {
            dbMsgList = [[[CPSystemEngine sharedInstance] dbManagement] findMsgListByPageWithGroupID:msgGroupID last_msg_time:oldMsgTime max_msg_count:USER_MSG_LOAD_MAX_COUNT];
        }
        else
        {
            NSInteger oldMsgCount = [oldMsgList count];
            if (oldMsgCount<USER_MSG_LOAD_MAX_COUNT)
            {
                oldMsgCount = USER_MSG_LOAD_MAX_COUNT;
            }
            dbMsgList =  [[[CPSystemEngine sharedInstance] dbManagement] findMsgListByPageWithGroupID:msgGroupID max_msg_count:oldMsgCount];
        }
        NSInteger dbMsgCount = [dbMsgList count];
        if (dbMsgCount>0)
        {
            NSMutableArray *uiMsgList = [[NSMutableArray alloc] init];
            for(int i=dbMsgCount-1;i>=0;i--)
            {
                CPDBModelMessage *dbMsg = [dbMsgList objectAtIndex:i];
                [uiMsgList addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
            }
            [uiMsgList addObjectsFromArray:oldMsgList]; 
            if (coupleMsgGroup&&hasCoupleGroup)
            {
                [coupleMsgGroup setMsgList:uiMsgList];
                [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupMsgInsert];
            }
            CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
            if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
            {
                [currMsgGroup setMsgList:uiMsgList];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupMsgInsert];
            }
            NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
            for(int i=0;i<[oldUserMsgList count];i++)
            {
                CPUIModelMessageGroup *uiOldMsgGroup = [oldUserMsgList objectAtIndex:i];
                if ([uiOldMsgGroup.msgGroupID compare:msgGroupID]==NSOrderedSame)
                {
                    [uiOldMsgGroup setMsgList:uiMsgList];
//                    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:oldUserMsgList];
                    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                    break;
                }
            }
        }else 
        {
            hasHistoryMsgs = YES;
        }
    }
    else
    {
        hasHistoryMsgs = YES;
        CPLogInfo(@"----ui msg group 's group id is null---");
    }
    if (hasHistoryMsgs)
    {
        if (hasCoupleGroup)
        {
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupMsgInsertEnd];
        }
        else 
        {
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupMsgInsertEnd];
        }
    }
}
-(void)refreshMsgListOnlyWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    NSArray *oldMsgList = [[NSMutableArray alloc] initWithArray:uiMsgGroup.msgList];
    NSNumber *oldMsgTime = nil;
    if ([oldMsgList count]>0)
    {
        CPUIModelMessage *uiMsg = [oldMsgList objectAtIndex:0];
        if (uiMsg)
        {
            oldMsgTime = uiMsg.date;
        }
    }
    NSArray *dbMsgList = nil;
    if (oldMsgTime&&[oldMsgTime longLongValue]>0)
    {
        dbMsgList = [[[CPSystemEngine sharedInstance] dbManagement] findMsgListByNewestTimeWithGroupID:uiMsgGroup.msgGroupID
                                                                                       newest_msg_time:oldMsgTime];
    }
    else
    {
        NSInteger oldMsgCount = [oldMsgList count];
        if (oldMsgCount<USER_MSG_INIT_MAX_COUNT)
        {
            oldMsgCount = USER_MSG_INIT_MAX_COUNT;
        }
        dbMsgList =  [[[CPSystemEngine sharedInstance] dbManagement] findMsgListByPageWithGroupID:uiMsgGroup.msgGroupID
                                                                                    max_msg_count:oldMsgCount];
    }
    if (dbMsgList) 
    {
        NSMutableArray *uiMsgListTmp = [[NSMutableArray alloc] init];
        NSInteger dbMsgCount = [dbMsgList count];
        for(int i=dbMsgCount-1;i>=0;i--)
        {
            CPDBModelMessage *dbMsg = [dbMsgList objectAtIndex:i];
            
            [uiMsgListTmp addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
        }
        [uiMsgGroup setMsgList:uiMsgListTmp];
    }
}
-(void)refreshSysUnReadedCount
{
    NSInteger friendMsgGroupUnReadedCount = 0;
    NSInteger coupleMsgGroupUnReadedCount = 0;
    NSInteger closedMsgGroupUnReadedCount = 0;
    
    NSInteger oldFriendMsgGroupUnReadedCount = [[CPUIModelManagement sharedInstance] friendMsgUnReadedCount];
    NSInteger oldCoupleMsgGroupUnReadedCount = [[CPUIModelManagement sharedInstance] coupleMsgUnReadedCount];
    NSInteger oldClosedMsgGroupUnReadedCount = [[CPUIModelManagement sharedInstance] closedMsgUnReadedCount]; 
    NSArray *oldMsgGroupList = [[CPUIModelManagement sharedInstance] userMessageGroupList];
    for(CPUIModelMessageGroup *uiMsgGroup in oldMsgGroupList)
    {
        NSInteger msgGroupRelationType = [uiMsgGroup.relationType integerValue];
        switch (msgGroupRelationType)
        {
            case MSG_GROUP_UI_RELATION_TYPE_COMMON:
                friendMsgGroupUnReadedCount += [uiMsgGroup.unReadedCount integerValue];
                break;
            case MSG_GROUP_UI_RELATION_TYPE_COUPLE:
                coupleMsgGroupUnReadedCount += [uiMsgGroup.unReadedCount integerValue];
                break;
            case MSG_GROUP_UI_RELATION_TYPE_CLOSER:
                closedMsgGroupUnReadedCount += [uiMsgGroup.unReadedCount integerValue];
                break;
            default:
                break;
        }
    }
    CPUIModelMessageGroup *coupleUiMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
    coupleMsgGroupUnReadedCount = [coupleUiMsgGroup.unReadedCount integerValue];
    if (friendMsgGroupUnReadedCount<0)
    {
        friendMsgGroupUnReadedCount = 0;
    }
    if (friendMsgGroupUnReadedCount!=oldFriendMsgGroupUnReadedCount)
    {
        [[CPSystemEngine sharedInstance] updateTagByFriendMsgUnReadedCount:friendMsgGroupUnReadedCount];
    }
    if (coupleMsgGroupUnReadedCount<0)
    {
        coupleMsgGroupUnReadedCount = 0;
    }
    if (oldCoupleMsgGroupUnReadedCount!=coupleMsgGroupUnReadedCount)
    {
        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgUnReadedCount:coupleMsgGroupUnReadedCount];
    }
    if (closedMsgGroupUnReadedCount<0)
    {
        closedMsgGroupUnReadedCount = 0;
    }
    if (oldClosedMsgGroupUnReadedCount!=closedMsgGroupUnReadedCount)
    {
        [[CPSystemEngine sharedInstance] updateTagByClosedMsgUnReadedCount:closedMsgGroupUnReadedCount];
    }
}
-(void)refreshSysUnReadedCountWithType:(NSInteger)msgGroupType andChangeCount:(NSInteger)count
{
    if (count==0) 
    {
        return;
    }
    switch (msgGroupType)
    {
        case MSG_GROUP_UI_RELATION_TYPE_COMMON:
        {
            NSInteger friendMsgGroupUnReadedCount = [[CPUIModelManagement sharedInstance] friendMsgUnReadedCount]+count;
            if (friendMsgGroupUnReadedCount<0)
            {
                friendMsgGroupUnReadedCount = 0;
            }
            [[CPSystemEngine sharedInstance] updateTagByFriendMsgUnReadedCount:friendMsgGroupUnReadedCount];
        }
            break;
        case MSG_GROUP_UI_RELATION_TYPE_COUPLE:
        {
            NSInteger coupleMsgGroupUnReadedCount = [[CPUIModelManagement sharedInstance] coupleMsgUnReadedCount]+count;
            if (coupleMsgGroupUnReadedCount<0)
            {
                coupleMsgGroupUnReadedCount = 0;
            }
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgUnReadedCount:coupleMsgGroupUnReadedCount];
        }
            break;
        case MSG_GROUP_UI_RELATION_TYPE_CLOSER:
        {
            NSInteger closedMsgGroupUnReadedCount = [[CPUIModelManagement sharedInstance] closedMsgUnReadedCount]+count;
            if (closedMsgGroupUnReadedCount<0)
            {
                closedMsgGroupUnReadedCount = 0;
            }
            [[CPSystemEngine sharedInstance] updateTagByClosedMsgUnReadedCount:closedMsgGroupUnReadedCount];
        }
            break;
    }
}
-(CPUIModelMessageGroup *)refreshMsgListOnlyWithMsgGroupID:(NSNumber *)msgGroupID
{
    if (!msgGroupID)
    {
        return nil;
    }
    CPUIModelMessageGroup *reMsgGroup = nil;
    NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
    for(CPUIModelMessageGroup *uiMsgGroup in oldUserMsgList)
    {
        if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
//            NSInteger oldMsgGroupUnReadedCount = [uiMsgGroup.unReadedCount integerValue];
            CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:uiMsgGroup.msgGroupID];
            [uiMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
            [uiMsgGroup setUpdateDate:dbMsgGroup.updateDate];
//            [self refreshSysUnReadedCountWithType:[uiMsgGroup.relationType integerValue] 
//                                   andChangeCount:[uiMsgGroup.unReadedCount integerValue]-oldMsgGroupUnReadedCount];
            [self refreshMsgListOnlyWithMsgGroup:uiMsgGroup];
            reMsgGroup = uiMsgGroup;
            break;
        } 
    }
    
    [self refreshSysUnReadedCount];
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUserMsgList sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
    return reMsgGroup;
}
-(void)refreshMsgGroupByAppendMsgWithNewMsgID:(NSNumber *)newMsgID
{
    CPDBModelMessage *newDbMsg = [[[CPSystemEngine sharedInstance] dbManagement] findMessageWithID:newMsgID];
    if (newDbMsg.msgGroupID)
    {
        CPDBModelMessageGroup *existDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:newDbMsg.msgGroupID];
        NSInteger newMsgType = 0;
        NSInteger existMsgGroupType = [existDbMsgGroup.type integerValue];
        if (existMsgGroupType==MSG_GROUP_UI_TYPE_SINGLE_PRE)
        {
            newMsgType = MSG_GROUP_UI_TYPE_SINGLE;
        }
        if(existMsgGroupType==MSG_GROUP_UI_TYPE_MULTI_PRE)
        {
            newMsgType = MSG_GROUP_UI_TYPE_MULTI;
        }
        if(existMsgGroupType==MSG_GROUP_UI_TYPE_CONVER_PRE)
        {
            newMsgType = MSG_GROUP_UI_TYPE_CONVER;
        }
        if (newMsgType>0)
        {
            [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:newDbMsg.msgGroupID
                                                                        andGroupType:[NSNumber numberWithInt:newMsgType]];
            [existDbMsgGroup setType:[NSNumber numberWithInt:newMsgType]];
            
            NSMutableArray *uiMsgGroups = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
            for(CPUIModelMessageGroup *msgGroup in uiMsgGroups)
            {
                if (msgGroup.msgGroupID&&[msgGroup.msgGroupID isEqualToNumber:newDbMsg.msgGroupID])
                {
                    [msgGroup setType:[NSNumber numberWithInt:newMsgType]];
                    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                    break;
                }
            }
        }
                
        CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        BOOL isCurrentGroup = NO;
        if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:newDbMsg.msgGroupID])
        {        
            if (!currMsgGroup.msgList) 
            {
                [currMsgGroup setMsgList:[NSArray array]];
            }
            NSMutableArray *oldMsgList = [[NSMutableArray alloc] initWithArray:currMsgGroup.msgList];
            {
                if (oldMsgList)
                {
                    [oldMsgList addObject:[self uiMsgConvertWithDbMsg:newDbMsg]];
                }
            }
//            [[[CPSystemEngine sharedInstance] dbManagement] markReadedWithMsg:newDbMsg];
            [currMsgGroup setMsgList:[oldMsgList sortedArrayUsingSelector:@selector(orderMsgWithDate:)]];
            CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:newDbMsg.msgGroupID];
            [currMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
            [currMsgGroup setUpdateDate:dbMsgGroup.updateDate];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupMsgAppend];
            isCurrentGroup = YES;
        }
        CPUIModelMessageGroup *coupleUiMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
        CPUIModelMessageGroup *tempMsgGroup = nil;
        if (coupleUiMsgGroup.msgGroupID&&[coupleUiMsgGroup.msgGroupID isEqualToNumber:newDbMsg.msgGroupID])
        {
            [self refreshMsgListOnlyWithMsgGroup:coupleUiMsgGroup];
            CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:coupleUiMsgGroup.msgGroupID];
            [coupleUiMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
            [coupleUiMsgGroup setUpdateDate:dbMsgGroup.updateDate];
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupData];
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupMsgAppend];
            
            NSInteger coupleMsgGroupUnReadedCount = [coupleUiMsgGroup.unReadedCount integerValue];
            if (coupleMsgGroupUnReadedCount<0)
            {
                coupleMsgGroupUnReadedCount = 0;
            }
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgUnReadedCount:coupleMsgGroupUnReadedCount];
            tempMsgGroup = coupleUiMsgGroup;

        }else 
        {
            tempMsgGroup = [self refreshMsgListOnlyWithMsgGroupID:newDbMsg.msgGroupID];
        }
        if ([newDbMsg.flag integerValue]==2&&tempMsgGroup&&!isCurrentGroup)
        {
            NSNumber *unReadedCount = tempMsgGroup.unReadedCount;
            NSString *msgText = newDbMsg.msgText;
            NSNumber *groupID = newDbMsg.msgGroupID;
            NSString *tipsNickName = tempMsgGroup.groupName;
            switch ([newDbMsg.contentType integerValue])
            {
                case MSG_CONTENT_TYPE_AUDIO:
                    msgText = @"发来一段音频";
                    break;
                case MSG_CONTENT_TYPE_VIDEO:
                    msgText = @"发来一段视频";
                    break;
                case MSG_CONTENT_TYPE_CQ:
                    msgText = @"发来一个传情";
                    break;
                case MSG_CONTENT_TYPE_CS:
                    msgText = @"发来一个传声";
                    break;
                case MSG_CONTENT_TYPE_IMG:
                    msgText = @"发来一张图片";
                    break;
                case MSG_CONTENT_TYPE_MAGIC:
                    msgText = @"发来一个魔法表情";
                    break;
                case MSG_CONTENT_TYPE_TTD:
                    msgText = @"发来一个偷偷答";
                    break;
                case MSG_CONTENT_TYPE_TTW:
                    msgText = @"发来一个偷偷问";
                    break;
                default:
                    break;
            }
            if (![CoreUtils stringIsNotNull:tipsNickName])
            {
                NSArray *memberList = [tempMsgGroup memberList];
                if ([memberList count]>0)
                {
                    CPUIModelMessageGroupMember *groupMem = [memberList objectAtIndex:0];
                    CPDBModelUserInfo *userInfo = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:groupMem.userName];
                    NSString *memNickName = userInfo.nickName;
                    if (![CoreUtils stringIsNotNull:memNickName])
                    {
                        memNickName = groupMem.nickName;
                    }
                    if ([tempMsgGroup isMsgSingleGroup])
                    {
                        tipsNickName = memNickName;
                    }
                    else 
                    {
                        tipsNickName = [NSString stringWithFormat:@"%@(%d人)",memNickName,[memberList count]+1];
                    }
                }    
            }
            [[[CPSystemEngine sharedInstance] msgManager] addNewMsgTipWithNickName:tipsNickName
                                                                        andMsgText:msgText
                                                                    andUnReadCount:unReadedCount 
                                                                        andGroupID:groupID andGroup:tempMsgGroup];
        }
        if([newDbMsg.flag integerValue]==2)
        {
            [[CPUIModelManagement sharedInstance] playSoundByReceiveNewMsg];
        }
    }
}
-(void)refreshMsgListWithUiMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    NSArray *oldMsgList = [[NSMutableArray alloc] initWithArray:uiMsgGroup.msgList];
    NSNumber *oldMsgTime = nil;
    if ([oldMsgList count]>0)
    {
        CPUIModelMessage *uiMsg = [oldMsgList objectAtIndex:0];
        if (uiMsg)
        {
            oldMsgTime = uiMsg.date;
        }
    }
    NSArray *dbMsgList = nil;
    if (oldMsgTime&&[oldMsgTime longLongValue]>0)
    {
        dbMsgList = [[[CPSystemEngine sharedInstance] dbManagement] findMsgListByNewestTimeWithGroupID:uiMsgGroup.msgGroupID 
                                                                                       newest_msg_time:oldMsgTime];
    }
    else
    {
        NSInteger oldMsgCount = [oldMsgList count];
        if (oldMsgCount<USER_MSG_INIT_MAX_COUNT)
        {
            oldMsgCount = USER_MSG_INIT_MAX_COUNT;
        }
        dbMsgList =  [[[CPSystemEngine sharedInstance] dbManagement] findMsgListByPageWithGroupID:uiMsgGroup.msgGroupID 
                                                                                    max_msg_count:oldMsgCount];
    }
    if (dbMsgList) 
    {
        NSMutableArray *uiMsgListTmp = [[NSMutableArray alloc] init];
        NSInteger dbMsgCount = [dbMsgList count];
        for(int i=dbMsgCount-1;i>=0;i--)
        {
            CPDBModelMessage *dbMsg = [dbMsgList objectAtIndex:i];
            
            [uiMsgListTmp addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
        }
        [uiMsgGroup setMsgList:uiMsgListTmp];
    }
}

-(void)refreshMsgListWithMsgGroupID:(NSNumber *)msgGroupID
{
    if (!msgGroupID)
    {
        return;
    }
    NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
    for(CPUIModelMessageGroup *uiMsgGroup in oldUserMsgList)
    {
        if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
            [self refreshMsgListWithUiMsgGroup:uiMsgGroup];
        } 
    }
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUserMsgList sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
    
    CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
    if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {        
        [self refreshMsgListWithUiMsgGroup:currMsgGroup];
        [[CPSystemEngine sharedInstance] updateTagByMsgGroupMsgReload];
    }
    
    CPUIModelMessageGroup *coupleMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
    if (coupleMsgGroup.msgGroupID&&[coupleMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {
        [self refreshMsgListWithUiMsgGroup:coupleMsgGroup];
        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupMsgReload];
    }
}

-(void)refreshMsgGroupInfoWithMsgGroupID:(NSNumber *)msgGroupID
{
    if (!msgGroupID)
    {
        return;
    }
//    CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:msgGroupID];
    CPUIModelMessageGroup *coupleUiMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
    if (coupleUiMsgGroup.msgGroupID&&[coupleUiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {
//        [coupleUiMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
    }
    CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
    if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {        
//        [currMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
        [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
    }
    NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
    for(CPUIModelMessageGroup *uiMsgGroup in oldUserMsgList)
    {
        if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
//            [uiMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
            [self refreshMsgListOnlyWithMsgGroup:uiMsgGroup];
        } 
    }
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUserMsgList sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
}
-(void)refreshMsgGroupInfoReadedWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    NSNumber *msgGroupID = uiMsgGroup.msgGroupID;
    if (!msgGroupID)
    {
        return;
    }
//    NSInteger oldMsgGroupUnReadedCount = [uiMsgGroup.unReadedCount integerValue];
    [[[CPSystemEngine sharedInstance] dbManagement] markMsgReadedWithGroupID:msgGroupID];
    CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:msgGroupID];
    CPUIModelMessageGroup *coupleUiMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
    if (coupleUiMsgGroup.msgGroupID&&[coupleUiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {
        [coupleUiMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroupData];
    }
    CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
    if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {        
        [currMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
        [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
    }
    NSMutableArray *oldUserMsgList = [[NSMutableArray alloc]initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
    for(CPUIModelMessageGroup *uiMsgGroup in oldUserMsgList)
    {
        if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
            [uiMsgGroup setUnReadedCount:dbMsgGroup.unReadedCount];
//            [self refreshSysUnReadedCountWithType:[uiMsgGroup.relationType integerValue] 
//                                   andChangeCount:[uiMsgGroup.unReadedCount integerValue]-oldMsgGroupUnReadedCount];
            [self refreshMsgListOnlyWithMsgGroup:uiMsgGroup];
            break;
        } 
    }
    [self refreshSysUnReadedCount];
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUserMsgList sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
}

#pragma mark send  & receive msg 
-(NSNumber *)sendMsgWithMsgGroup:(CPUIModelMessageGroup *)msgGroup newMsg:(CPUIModelMessage *)uiMsg
{
    CPDBModelMessage *dbMsg = [ModelConvertUtils uiMessageToDb:uiMsg];
    if (msgGroup.msgGroupID&&[msgGroup.msgGroupID longLongValue]>0)
    {
        [dbMsg setMsgGroupID:msgGroup.msgGroupID];
    }
    else 
    {
        CPLogError(@"this msg not send,msgGroup.msgGroupID  is  %@",msgGroup.msgGroupID);
//        if ([msgGroup.memberList count]>0)
//        {
//            CPDBModelMessageGroup *dbMsgGroup = [ModelConvertUtils uiMessageGroupToDb:msgGroup];
//            if([msgGroup.memberList count]==1)
//            {
//                [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
//            }else 
//            {
//                [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_MULTI]];
//            }
//            NSNumber *newMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:dbMsgGroup];
//            [dbMsg setMsgGroupID:newMsgGroupID];
//        }
//        else 
//        {
//            CPLogError(@"send new msg,but member list is 0");
//            return;
//        }
        return nil;
    }
    //如果当前的隐藏的单聊，需要刷新下msg group的属性
    if ([msgGroup.type integerValue]==MSG_GROUP_TYPE_SINGLE_PRE)
    {
        CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:msgGroup.msgGroupID];
        [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
        NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
        [dbMsgGroup setUpdateDate:nowDate];
        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:dbMsgGroup.msgGroupID
                                                                             obj:dbMsgGroup];
        NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
        for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
        {
            if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroup.msgGroupID])
            {
                [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                [uiMsgGroup setUpdateDate:nowDate];
                [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                break;
            }
        }
        CPUIModelMessageGroup *currentMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        if (currentMsgGroup.msgGroupID&&[currentMsgGroup.msgGroupID isEqualToNumber:msgGroup.msgGroupID])
        {
            [currentMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroup];
        }
    }
        
    [dbMsg setMsgSenderID:[[CPSystemEngine sharedInstance] getAccountName]];
    [dbMsg setMsgOwnerName:[[CPSystemEngine sharedInstance] getAccountName]];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_SEND]];
    [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
    [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_SENDING]];
    NSNumber *newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
//    [self refreshMsgListWithMsgGroupID:msgGroup.msgGroupID isCreated:NO];
    [self refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
    return newMsgID;
}
-(NSNumber *)sendMsgAlarmWithMsgGroup:(CPUIModelMessageGroup *)msgGroup newMsg:(CPUIModelMessage *)uiMsg
{
    CPDBModelMessage *dbMsg = [ModelConvertUtils uiMessageToDb:uiMsg];
    [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_STATUS_IS_NOT_READ]];
    if (uiMsg.linkMsgID)
    {
        CPDBModelMessage *oldMsg = [[[CPSystemEngine sharedInstance] dbManagement] findMessageWithID:uiMsg.linkMsgID];
        [dbMsg setAttachResID:oldMsg.attachResID];
        [dbMsg setMsgSenderID:oldMsg.msgSenderID];
        
        CPDBModelMessageGroup *oldMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithCreatorName:@"xiaoshuang"];
        if (oldMsgGroup.msgGroupID)
        {
            [msgGroup setMsgGroupID:oldMsgGroup.msgGroupID];
        }
    }
    else
    {
        [dbMsg setMsgSenderID:[[CPSystemEngine sharedInstance] getAccountName]];
    }
    if (msgGroup.msgGroupID&&[msgGroup.msgGroupID longLongValue]>0)
    {
        [dbMsg setMsgGroupID:msgGroup.msgGroupID];
    }
    else
    {
        CPLogError(@"this msg not send,msgGroup.msgGroupID  is  %@",msgGroup.msgGroupID);
        //        if ([msgGroup.memberList count]>0)
        //        {
        //            CPDBModelMessageGroup *dbMsgGroup = [ModelConvertUtils uiMessageGroupToDb:msgGroup];
        //            if([msgGroup.memberList count]==1)
        //            {
        //                [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
        //            }else
        //            {
        //                [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_MULTI]];
        //            }
        //            NSNumber *newMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:dbMsgGroup];
        //            [dbMsg setMsgGroupID:newMsgGroupID];
        //        }
        //        else
        //        {
        //            CPLogError(@"send new msg,but member list is 0");
        //            return;
        //        }
        return nil;
    }
    //如果当前的隐藏的单聊，需要刷新下msg group的属性
    if ([msgGroup.type integerValue]==MSG_GROUP_TYPE_SINGLE_PRE)
    {
        CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:msgGroup.msgGroupID];
        [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
        NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
        [dbMsgGroup setUpdateDate:nowDate];
        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:dbMsgGroup.msgGroupID
                                                                             obj:dbMsgGroup];
        NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
        for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
        {
            if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroup.msgGroupID])
            {
                [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                [uiMsgGroup setUpdateDate:nowDate];
                [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                break;
            }
        }
        CPUIModelMessageGroup *currentMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        if (currentMsgGroup.msgGroupID&&[currentMsgGroup.msgGroupID isEqualToNumber:msgGroup.msgGroupID])
        {
            [currentMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroup];
        }
    }
    
    [dbMsg setMsgOwnerName:[[CPSystemEngine sharedInstance] getAccountName]];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
    [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
    [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DEFAULT]];
    NSNumber *newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
    //    [self refreshMsgListWithMsgGroupID:msgGroup.msgGroupID isCreated:NO];
    [self refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
    return newMsgID;
}

-(NSNumber *)sendAutoMsgWithMsgGroupID:(NSNumber *)msgGroupID newMsg:(CPDBModelMessage *)dbMsg
{
    if (!dbMsg)
    {
        return nil;
    }
//    if (msgGroupID&&[msgGroupID longLongValue]>0)
//    {
//    }
//    else 
//    {
//        CPLogError(@"this msg not send,msgGroup.msgGroupID  is  %@",msgGroupID);
//        return nil;
//    }
    [dbMsg setMsgGroupID:msgGroupID];
    [dbMsg setMsgSenderID:[[CPSystemEngine sharedInstance] getAccountName]];
    [dbMsg setMsgOwnerName:[[CPSystemEngine sharedInstance] getAccountName]];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_SEND]];
    [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
    [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DEFAULT]];
    [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_READ_STATUS_IS_NOT_READ]];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
    NSNumber *newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
    [self refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
    return newMsgID;
}
//自动生成的消息中，小双、系统消息、双双团队的欢迎语；用户和双双团队的自动回复当作IM中的文本消息
-(NSNumber *)sendAutoMsgTextWithMsgGroupID:(NSNumber *)msgGroupID newMsg:(CPDBModelMessage *)dbMsg
{
    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
    return [self sendAutoMsgWithMsgGroupID:msgGroupID newMsg:dbMsg];
}
//其余情况的消息都当作系统消息中的默认消息
-(NSNumber *)sendAutoMsgSysWithMsgGroupID:(NSNumber *)msgGroupID newMsg:(CPDBModelMessage *)dbMsg
{
    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_SYS]];
    return [self sendAutoMsgWithMsgGroupID:msgGroupID newMsg:dbMsg];
}
-(NSNumber *)sendAutoMsgByFriendApplyWithUserName:(NSString *)userName andApplyType:(NSInteger)applyType
{
    if (!userName)
    {
        return nil;
    }
    CPDBModelMessage *dbMsg = [[CPDBModelMessage alloc] init];
    NSString *msgText = nil;
    switch (applyType) 
    {
        case SYS_MSG_APPLY_TYPE_COMMON:
            msgText = NSLocalizedString(@"AutoMsgAddCommonFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_CLOSER:
            msgText = NSLocalizedString(@"AutoMsgAddCloserFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_LOVE:
            msgText = NSLocalizedString(@"AutoMsgAddLoverFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_COUPLE:
            msgText = NSLocalizedString(@"AutoMsgAddCoupleFriendRes",nil);
            [dbMsg setMobile:@"1"];
            break;
        case SYS_MSG_APPLY_TYPE_MARRIED:
            msgText = NSLocalizedString(@"AutoMsgAddMarriedFriendRes",nil);
            [dbMsg setMobile:@"1"];
            break;
    }
    if (!msgText)
    {
        return nil;
    }
    [dbMsg setMsgText:msgText];
    CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:userName];
    if (dbMsgGroup.msgGroupID&&[dbMsgGroup.msgGroupID longLongValue]>0)
    {
        [dbMsg setMsgGroupID:dbMsgGroup.msgGroupID];
    }
    [dbMsg setMsgSenderID:userName];
    [dbMsg setMsgOwnerName:userName];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_SEND]];
    [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
//    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_SYS]];
    [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DEFAULT]];
    [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_READ_STATUS_IS_NOT_READ]];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
    NSNumber *newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
    [self refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
    return newMsgID;
}
-(NSNumber *)sendAutoMsgByFriendApplyReqWithUserName:(NSString *)userName andApplyType:(NSInteger)applyType
{
    if (!userName)
    {
        return nil;
    }
    CPDBModelMessage *dbMsg = [[CPDBModelMessage alloc] init];
    NSString *msgText = nil;
    switch (applyType) 
    {
        case SYS_MSG_APPLY_TYPE_COMMON:
            msgText = NSLocalizedString(@"AutoMsgAddCommonFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_CLOSER:
            msgText = NSLocalizedString(@"AutoMsgAddCloserFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_LOVE:
            msgText = NSLocalizedString(@"AutoMsgAddLoverFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_COUPLE:
            msgText = NSLocalizedString(@"AutoMsgAddCoupleFriendRes",nil);
            break;
        case SYS_MSG_APPLY_TYPE_MARRIED:
            msgText = NSLocalizedString(@"AutoMsgAddMarriedFriendRes",nil);
            break;
    }
    if (!msgText)
    {
        return nil;
    }
    [dbMsg setMsgText:msgText];
    CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:userName];
    if (dbMsgGroup.msgGroupID&&[dbMsgGroup.msgGroupID longLongValue]>0)
    {
        [dbMsg setMsgGroupID:dbMsgGroup.msgGroupID];
    }
    [dbMsg setMsgSenderID:userName];
    [dbMsg setMsgOwnerName:userName];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_SEND]];
    [dbMsg setDate:[CoreUtils getLongFormatWithNowDate]];
    //    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
    [dbMsg setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_SYS]];
    [dbMsg setSendState:[NSNumber numberWithInt:MSG_SEND_STATE_DEFAULT]];
    [dbMsg setIsReaded:[NSNumber numberWithInt:MSG_READ_STATUS_IS_NOT_READ]];
    [dbMsg setFlag:[NSNumber numberWithInt:MSG_FLAG_RECEIVE]];
    NSNumber *newMsgID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessage:dbMsg];
    [self refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
    return newMsgID;
}
-(void)receiveMsgWithmsg:(NSObject *)msg
{
    [[CPSystemEngine sharedInstance] receiveMsgByOperationWithMsgs:[NSArray arrayWithObject:msg]];
}
-(void)receiveGroupMsgWithmsg:(NSObject *)msg
{
    [[CPSystemEngine sharedInstance] receiveMsgByOperationWithMsgs:[NSArray arrayWithObject:msg]];
}
-(void)updateMsgGroupByTypeWithGroupID:(NSNumber *)msgGroupID
{
    [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:msgGroupID andGroupType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
    NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
    for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
    {
        if (uiMsgGroup.msgGroupID&&msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
            [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
            break;
        }
    }
}
-(NSNumber *)getMsgGroupIdWithUserName:(NSString *)userName
{
    if (!userName||[@"" isEqualToString:userName]) 
    {
        return nil;
    }
#warning gaoyixia bijiao exin de chuli ,weishenm zheli de user name shi dai domain xinxi de 
    NSRange userNameRange = [userName rangeOfString:@"@"];
    if (userNameRange.length>0) 
    {
        userName = [userName substringToIndex:userNameRange.location];
    }
    CPLogInfo(@"=============userName is  %@",userName);
    NSNumber *currentMsgGroupID = nil;
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:userName];
    if (existMsgGroup)
    {
        currentMsgGroupID = existMsgGroup.msgGroupID;
        if ([existMsgGroup.type integerValue]==MSG_GROUP_TYPE_SINGLE_PRE) 
        {
            [existMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
            [self updateMsgGroupByTypeWithGroupID:existMsgGroup.msgGroupID];

        }
    }
    else 
    {
        CPDBModelUserInfo *existUserInfo = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:userName];
        if (existUserInfo)
        {
            CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
            NSMutableArray *memberList = [[NSMutableArray alloc] init];
            CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
            [dbGroupMember setUserName:existUserInfo.name];
            [memberList addObject:dbGroupMember];
            [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
            NSInteger userType = [existUserInfo.type integerValue];
            switch (userType)
            {
                case USER_RELATION_TYPE_CLOSED:
                    [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
                    break;
                case USER_RELATION_TYPE_COMMON:
                    [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
                    break;
                case USER_RELATION_TYPE_COUPLE:
                case USER_RELATION_TYPE_LOVER:
                case USER_RELATION_TYPE_MARRIED:
                    [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COUPLE]];
                    break;
                default:
                    [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
                    break;
            }
            [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
            currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
        }
    }
    return currentMsgGroupID;
}
-(NSNumber *)getMsgGroupIdWithServerID:(NSString *)serverID
{
    if (!serverID||[@"" isEqualToString:serverID]) 
    {
        return nil;
    }
    NSNumber *currentMsgGroupID = nil;
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithServerID:serverID];
    if (existMsgGroup)
    {
        currentMsgGroupID = existMsgGroup.msgGroupID;
    }
    else 
    {
        //发起获取对应群的指令
        [self getGroupInfoWithGroupJid:serverID];
    }
    return currentMsgGroupID;
}
-(void)createConversationWithUser:(CPUIModelUserInfo *)uiUserInfo
{
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupDbWithUserName:uiUserInfo.name];
    NSNumber *sysMsgGroupID = existMsgGroup.msgGroupID;
    if (!existMsgGroup)
    {
        CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
        [dbGroupMember setUserName: uiUserInfo.name];
        [memberList addObject:dbGroupMember];
        [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
        NSInteger userType = [uiUserInfo.type integerValue];
        switch (userType)
        {
            case USER_MANAGER_XIAOSHUANG:
                [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
                break;
            case USER_MANAGER_FANXER:
            case USER_MANAGER_SYSTEM:
                [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
                break;
            default:
                CPLogError(@"err create conver type");
                break;
        }
        [newMessageGroup setCreatorName:uiUserInfo.name];
        [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
        NSNumber *currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
        //create default msg
        if (currentMsgGroupID)
        {
            if (userType==USER_MANAGER_XIAOSHUANG) 
            {
                CPDBModelMessage *newDbMsg = [[CPDBModelMessage alloc] init];
                [newDbMsg setMsgText:NSLocalizedString(@"AutoMsgXiaoShuangReged",nil)];
                [self sendAutoMsgTextWithMsgGroupID:currentMsgGroupID newMsg:newDbMsg];
            }
            else if(userType==USER_MANAGER_FANXER)
            {
                CPDBModelMessage *newDbMsg = [[CPDBModelMessage alloc] init];
                [newDbMsg setMsgText:NSLocalizedString(@"AutoMsgCoupleTeamReg",nil)];
                [self sendAutoMsgTextWithMsgGroupID:currentMsgGroupID newMsg:newDbMsg];
            }
            else if(userType==USER_MANAGER_SYSTEM)
            {
                CPDBModelMessage *newDbMsg = [[CPDBModelMessage alloc] init];
                [newDbMsg setMsgText:NSLocalizedString(@"AutoMsgSystemReged",nil)];
                [self sendAutoMsgTextWithMsgGroupID:currentMsgGroupID newMsg:newDbMsg];
            } 
        }
        sysMsgGroupID = currentMsgGroupID;
//        [self refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:YES];
    }
    [[[CPSystemEngine sharedInstance] dbManagement] updateMessageWithGroupID:sysMsgGroupID
                                                                 andSendName:uiUserInfo.name];
}
-(void)refreshCoupleMsgGroupWithID:(NSNumber *)msgGroupID
{
    if (msgGroupID)
    {
        CPDBModelMessageGroup *newDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithID:msgGroupID];
        if (newDbMsgGroup)
        {
            CPUIModelMessageGroup *uiMsgGroup = [ModelConvertUtils dbMessageGroupToUi:newDbMsgGroup];
            NSArray *dbMsgList =  [[[CPSystemEngine sharedInstance] dbManagement] findAllMessagesWithGroupID:msgGroupID];
            if (dbMsgList) 
            {
                NSMutableArray *uiMsgList = [[NSMutableArray alloc] init];
                NSInteger dbMsgCount = [dbMsgList count];
                for(int i=0;i<dbMsgCount;i++)
                    //              for(int i=dbMsgCount-1;i>=0;i--)
                {
                    if (dbMsgCount-i>USER_MSG_INIT_MAX_COUNT)
                    {
                        continue;
                    }
                    CPDBModelMessage *dbMsg = [dbMsgList objectAtIndex:i];
                    [uiMsgList addObject:[self uiMsgConvertWithDbMsg:dbMsg]];
                }
                [uiMsgGroup setMsgList:uiMsgList];
                [uiMsgGroup setMsgGroupID:newDbMsgGroup.msgGroupID];
            }
            NSArray *msgGroupMemberList = [[[CPSystemEngine sharedInstance] dbManagement] findAllMessageGroupMembersWithGroupID:msgGroupID];
            if (msgGroupMemberList)
            {
                NSMutableArray *uiGroupMemberList = [[NSMutableArray alloc] init];
                for(CPDBModelMessageGroupMember *dbGroupMember in msgGroupMemberList)
                {
                    CPUIModelMessageGroupMember *uiGroupMember = [ModelConvertUtils dbMessageGroupMemberToUi:dbGroupMember];
                    CPUIModelUserInfo *userInfo = [ModelConvertUtils dbUserInfoToUi:[[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiGroupMember.userName]];
                    if (userInfo)
                    {
                        [uiGroupMember setUserInfo:userInfo];
                        [uiGroupMember setNickName:userInfo.nickName];
                        [uiGroupMember setHeaderPath:userInfo.headerPath];
                        [uiGroupMember setUserName:userInfo.name];
                        [uiGroupMember setDomain:userInfo.domain];
                    }
                    else 
                    {
                        CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithServerUrl:dbGroupMember.headerPath];
                        [uiGroupMember setHeaderPath:[[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes]];
                    }
                    
                    [uiGroupMemberList addObject:uiGroupMember];
                }
                [uiMsgGroup setMemberList:[uiGroupMemberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
            }   
            [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:uiMsgGroup];
            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
        }
    }
}
-(void)filterMessageGroupByDelUserName:(NSString *)delUserName
{
    //
}
-(void)filterMessageGroupByFriendArray
{
//    NSDictionary *cachedMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] msgGroupCachedByGroupID];
//    if ([cachedMsgGroup count]==0)
//    {
//        return;
//    }
    NSArray *allDbFriendArray = [[[[CPSystemEngine sharedInstance] dbManagement] userInfoCachedDicByID] allValues];
    NSMutableArray *updateMsgGroupArray = [[NSMutableArray alloc] init];
    BOOL hasCoupleData = NO;
    for(CPDBModelUserInfo *dbUserInfo in allDbFriendArray)
    {
        NSInteger userInfoRelation = [dbUserInfo.type integerValue];
        if (userInfoRelation<USER_RELATION_TYPE_COMMON||userInfoRelation>USER_RELATION_TYPE_MARRIED)
        {
            continue;
        }
        if (dbUserInfo.name)
        {
            NSInteger newRelationType = 0;
            NSInteger newMsgGroupType = 0;
            switch (userInfoRelation)
            {
                case USER_RELATION_COMMON:
                    newRelationType = MSG_GROUP_RELATION_TYPE_COMMON;
                    newMsgGroupType = MSG_GROUP_TYPE_SINGLE_PRE;
                    break;
                case USER_RELATION_CLOSED:
                    newRelationType = MSG_GROUP_RELATION_TYPE_CLOSER;
                    newMsgGroupType = MSG_GROUP_TYPE_SINGLE_PRE;
                    break;
                case USER_RELATION_LOVER:
                case USER_RELATION_COUPLE:
                case USER_RELATION_MARRIED:
                    newRelationType = MSG_GROUP_RELATION_TYPE_COUPLE;
                    newMsgGroupType = MSG_GROUP_TYPE_SINGLE;
                    hasCoupleData = YES;
                    break;    
                default:
                    break;
            }
            CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupDbWithUserName:dbUserInfo.name];
            if (dbMsgGroup&&dbMsgGroup.msgGroupID)//&&![dbMsgGroup isMsgMultiGroup])
            {
                if (newRelationType>0&&[dbMsgGroup.relationType integerValue]!=newRelationType)
                {
                    [dbMsgGroup setRelationType:[NSNumber numberWithInt:newRelationType]];
                    NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
                    [dbMsgGroup setUpdateDate:nowDate];
                    [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:dbMsgGroup.msgGroupID
                                                                                         obj:dbMsgGroup];
                    CPUIModelMessageGroup *newUpdateMsgGroup = [self uiMsgGroupConvertWithDbMsgGroup:dbMsgGroup];
                    if (newRelationType==MSG_GROUP_RELATION_TYPE_COUPLE)
                    {
                        [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:newUpdateMsgGroup];
                        [[CPUIModelManagement sharedInstance] setCoupleModel:[ModelConvertUtils dbUserInfoToUi:dbUserInfo]];
                        [[CPSystemEngine sharedInstance] updateTagByCouple];
                        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
                    }
                    else 
                    {
                        NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
                        for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
                        {
                            if (![uiMsgGroup isMsgMultiGroup]&&uiMsgGroup.msgGroupID&&dbMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:dbMsgGroup.msgGroupID])
                            {
                                [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                                [uiMsgGroup setRelationType:dbMsgGroup.relationType];
                                [uiMsgGroup setUpdateDate:nowDate];
                                [uiMsgGroup setMemberList:newUpdateMsgGroup.memberList];
                                [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
                                [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                                break;
                            }
                        }
                        CPUIModelMessageGroup *currentMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
                        if (currentMsgGroup.msgGroupID&&[currentMsgGroup.msgGroupID isEqualToNumber:dbMsgGroup.msgGroupID])
                        {
//                            [currentMsgGroup setRelationType:[NSNumber numberWithInt:newRelationType]];
                            [[CPUIModelManagement sharedInstance] setUserMsgGroup:newUpdateMsgGroup];
                            [[CPSystemEngine sharedInstance] updateTagByMsgGroup];
                        }
                        CPUIModelMessageGroup *currentCoupleMsgGroup = [[CPUIModelManagement sharedInstance] coupleMsgGroup];
                        if (currentCoupleMsgGroup.msgGroupID&&[currentCoupleMsgGroup.msgGroupID isEqualToNumber:dbMsgGroup.msgGroupID])
                        {
                            [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:nil];
                            [[CPUIModelManagement sharedInstance] setCoupleModel:nil];
                            [[CPSystemEngine sharedInstance] updateTagByCouple];
                            [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
                        }
                    }
                }
                [updateMsgGroupArray addObject:dbMsgGroup.msgGroupID];
            }
            else 
            {
                //create               
                CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
                NSMutableArray *memberList = [[NSMutableArray alloc] init];
                CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
                [dbGroupMember setUserName: dbUserInfo.name];
                [memberList addObject:dbGroupMember];
                [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
                [newMessageGroup setRelationType:[NSNumber numberWithInt:newRelationType]];
                [newMessageGroup setType:[NSNumber numberWithInt:newMsgGroupType]];
                NSNumber *currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
                [[[CPSystemEngine sharedInstance] dbManagement] updateMessageWithGroupID:currentMsgGroupID
                                                                             andSendName:dbUserInfo.name];
                if (newRelationType==MSG_GROUP_RELATION_TYPE_COUPLE)
                {
                    CPDBModelMessageGroup *newInsertMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:currentMsgGroupID];
                    CPUIModelMessageGroup *coupleMsgGroup = [self uiMsgGroupConvertWithDbMsgGroup:newInsertMsgGroup];
                    [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:coupleMsgGroup];
                    [[CPUIModelManagement sharedInstance] setCoupleModel:[ModelConvertUtils dbUserInfoToUi:dbUserInfo]];
                    [[CPSystemEngine sharedInstance] updateTagByCouple];
                    [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
                }
                else 
                {
                    [self refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:NO ];
                }
                [updateMsgGroupArray addObject:currentMsgGroupID];
            }
        }
    }
    if (!hasCoupleData)
    {
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:nil];
        [[CPUIModelManagement sharedInstance] setCoupleModel:nil];
        [[CPSystemEngine sharedInstance] updateTagByCouple];
        [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
    }
    NSArray *oldMsgGroupArray = [NSArray arrayWithArray:[[[[CPSystemEngine sharedInstance] dbManagement] msgGroupCachedByGroupID] allValues]];
    NSMutableArray *delMsgGroupIDs = [[NSMutableArray alloc] init];
    for(CPDBModelMessageGroup *dbMsgGroup in oldMsgGroupArray)
    {
        if (![dbMsgGroup isMsgMultiGroup]&&dbMsgGroup.msgGroupID&&![updateMsgGroupArray containsObject:dbMsgGroup.msgGroupID]&&![dbMsgGroup isSysMsgGroup])
        {
            [delMsgGroupIDs addObject:dbMsgGroup.msgGroupID];
        }
    }
    NSMutableArray *oldUiMsgGroups = [NSMutableArray arrayWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
    CPUIModelMessageGroup *currentMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
    for(NSNumber *delMsgGroupID in delMsgGroupIDs)
    {
        [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupWithID:delMsgGroupID];
        if (delMsgGroupID&&currentMsgGroup.msgGroupID&&[currentMsgGroup.msgGroupID isEqualToNumber:delMsgGroupID])
        {
            [[CPUIModelManagement sharedInstance] setUserMsgGroup:nil];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupDel];
        }
        for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
        {
            if (uiMsgGroup.msgGroupID&&[delMsgGroupIDs containsObject:uiMsgGroup.msgGroupID])
            {
                [oldUiMsgGroups removeObject:uiMsgGroup];
                break;
            }
        }
    }
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
}
-(void)createCoupleConversationWithUser:(CPUIModelUserInfo *)uiUserInfo
{
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:uiUserInfo.name];
    if (!existMsgGroup)
    {
        CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
        [dbGroupMember setUserName: uiUserInfo.name];
        [memberList addObject:dbGroupMember];
        [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COUPLE]];
        [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
        [newMessageGroup setCreatorName:uiUserInfo.name];
//        NSNumber *currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
//        [self refreshCoupleMsgGroupWithID:currentMsgGroupID];
    }
}
-(void)createDefaultConversationWithUser:(CPUIModelUserInfo *)uiUserInfo
{
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:uiUserInfo.name];
    if (!existMsgGroup)
    {
        CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
        NSMutableArray *memberList = [[NSMutableArray alloc] init];
        CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
        [dbGroupMember setUserName: uiUserInfo.name];
        [memberList addObject:dbGroupMember];
        [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
        if ([uiUserInfo.type integerValue]==USER_RELATION_TYPE_COMMON)
        {
            [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
        }
        else 
        {
            [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
        }
        [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE_PRE]];
        [newMessageGroup setCreatorName:uiUserInfo.name];
//        NSNumber *currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
//        [self refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:NO];
    }
}

-(void)createNewConversationWithUser:(CPUIModelUserInfo *)uiUserInfo
{
    if (uiUserInfo)
    {
        NSNumber *currentMsgGroupID = nil;

        
            NSNumber *newRelationType = [NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON];
            //            if (type==CREATE_CONVER_TYPE_CLOSED)
            if([uiUserInfo.type integerValue]==USER_RELATION_TYPE_CLOSED)
            {
                newRelationType = [NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER];
            }else if ([uiUserInfo.type integerValue]==USER_RELATION_TYPE_LOVER || [uiUserInfo.type integerValue]==USER_RELATION_TYPE_COUPLE ||[uiUserInfo.type integerValue]==USER_RELATION_TYPE_MARRIED)
            {
                newRelationType = [NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COUPLE];
            }else{
                newRelationType = [NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON];
            }
            CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:uiUserInfo.name];
            if (existMsgGroup)
            {
                currentMsgGroupID = existMsgGroup.msgGroupID;
                [existMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
//                if (![existMsgGroup isSysMsgGroup]&&[existMsgGroup.relationType integerValue]!=MSG_GROUP_RELATION_TYPE_COUPLE)
//                {
//                    [existMsgGroup setRelationType:newRelationType];
//                }
                [existMsgGroup setRelationType:newRelationType];
                NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
                [existMsgGroup setUpdateDate:nowDate];
                [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:existMsgGroup.msgGroupID
                                                                                     obj:existMsgGroup];
                NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
                for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
                {
                    if (uiMsgGroup.msgGroupID&&existMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:existMsgGroup.msgGroupID])
                    {
                        [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                        [uiMsgGroup setRelationType:existMsgGroup.relationType];
                        [uiMsgGroup setUpdateDate:nowDate];
                        [[CPUIModelManagement sharedInstance] setUserMsgGroup:uiMsgGroup];
                        //[[CPSystemEngine sharedInstance] updateTagByCreateMsgGroupWithCode:[NSNumber numberWithInt:RES_CODE_SUCESS]];
                        //[[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
                        //[[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                        break;
                    }
                }
            }
//            else
//            {
//                CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
//                NSMutableArray *memberList = [[NSMutableArray alloc] init];
//                CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
//                [dbGroupMember setUserName: uiUserInfo.name];
//                [memberList addObject:dbGroupMember];
//                [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
//                //                switch (type)
//                //                {
//                //                    case CREATE_CONVER_TYPE_CLOSED:
//                //                        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
//                //                        break;
//                //                    case CREATE_CONVER_TYPE_COMMON:
//                //                        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
//                //                        break;
//                //                    default:
//                //                        CPLogError(@"err create conver type");
//                //                        break;
//                //                }
//                [newMessageGroup setRelationType:newRelationType];
//                [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
//                currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
//                [self refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:YES];
//            }
        
    }
}

-(void)createConversationWithUsers:(NSArray *)userArray andMsgGroups:(NSArray *)msgGroups andType:(NSInteger)type
{
    if ([userArray count]>0)
    {
        NSNumber *currentMsgGroupID = nil;
        if ([userArray count]==1)
        {
            
            CPUIModelUserInfo *uiUserInfo = [userArray objectAtIndex:0];
            NSNumber *newRelationType = [NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON];
//            if (type==CREATE_CONVER_TYPE_CLOSED) 
            if([uiUserInfo.type integerValue]==USER_RELATION_TYPE_CLOSED)
            {
                newRelationType = [NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER];
            }
            CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserName:uiUserInfo.name];
            if (existMsgGroup)
            {
                currentMsgGroupID = existMsgGroup.msgGroupID;
                [existMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                if (![existMsgGroup isSysMsgGroup]&&[existMsgGroup.relationType integerValue]!=MSG_GROUP_RELATION_TYPE_COUPLE) 
                {
                    [existMsgGroup setRelationType:newRelationType];
                }
                NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
                [existMsgGroup setUpdateDate:nowDate];
                [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:existMsgGroup.msgGroupID
                                                                                     obj:existMsgGroup];
                NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
                for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
                {
                    if (uiMsgGroup.msgGroupID&&existMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:existMsgGroup.msgGroupID])
                    {
                        [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                        [uiMsgGroup setRelationType:existMsgGroup.relationType];
                        [uiMsgGroup setUpdateDate:nowDate];
                        [[CPUIModelManagement sharedInstance] setUserMsgGroup:uiMsgGroup];
                        [[CPSystemEngine sharedInstance] updateTagByCreateMsgGroupWithCode:[NSNumber numberWithInt:RES_CODE_SUCESS]];
                        [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[oldUiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
                        [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                        break;
                    }
                }
            }
            else 
            {
                CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
                NSMutableArray *memberList = [[NSMutableArray alloc] init];
                CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
                [dbGroupMember setUserName: uiUserInfo.name];
                [memberList addObject:dbGroupMember];
                [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
//                switch (type)
//                {
//                    case CREATE_CONVER_TYPE_CLOSED:
//                        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
//                        break;
//                    case CREATE_CONVER_TYPE_COMMON:
//                        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
//                        break;
//                    default:
//                        CPLogError(@"err create conver type");
//                        break;
//                }
                [newMessageGroup setRelationType:newRelationType];
                [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_SINGLE]];
                
                currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
                [self refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:YES];
            }
        }
        else 
        {
            //create multi users conversation
            CPDBModelMessageGroup *newMessageGroup = [[CPDBModelMessageGroup alloc] init];
            NSMutableArray *memberList = [[NSMutableArray alloc] init];
            NSMutableArray *userNamesList = [[NSMutableArray alloc] init];
            NSMutableArray *userNams = [[NSMutableArray alloc] init];
//            for(CPUIModelUserInfo *uiUserInfo in userArray)
            for(NSObject *userObj in userArray)
            {
                if ([userObj isKindOfClass:[CPUIModelUserInfo class]])
                {
                    CPUIModelUserInfo *uiUserInfo = (CPUIModelUserInfo *)userObj;
                    CPDBModelMessageGroupMember *dbGroupMember = [[CPDBModelMessageGroupMember alloc] init];
                    [dbGroupMember setUserName: uiUserInfo.name];
                    [memberList addObject:dbGroupMember];
                    
                    [userNamesList addObject:[NSString stringWithFormat:@"%@%@",uiUserInfo.name,uiUserInfo.domain]];
                    
                    [userNams addObject:uiUserInfo.name];
                }
                else if([userObj isKindOfClass:[CPUIModelMessageGroupMember class]])
                {
                    CPUIModelMessageGroupMember *uiMsgGroupMem = (CPUIModelMessageGroupMember *)userObj;
                    CPDBModelMessageGroupMember *dbGroupMember = [ModelConvertUtils uiMessageGroupMemberToDb:uiMsgGroupMem];
                    [memberList addObject:dbGroupMember];
                    
                    [userNamesList addObject:[NSString stringWithFormat:@"%@%@",dbGroupMember.userName,dbGroupMember.domain]];
                    
                    [userNams addObject:dbGroupMember.userName];
                }
            }
            CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithUserNames:userNams];
            if (existMsgGroup)
            {
                NSInteger msgType = [existMsgGroup.type integerValue];
                if (msgType==MSG_GROUP_UI_TYPE_CONVER_PRE)
                {
                    [self refreshMsgGroupConverTypeWithGroupID:existMsgGroup.msgGroupID
                                                    andNewType:MSG_GROUP_UI_TYPE_CONVER];
                }
                else if (msgType==MSG_GROUP_UI_TYPE_MULTI_PRE)
                {
                    [self refreshMsgGroupConverTypeWithGroupID:existMsgGroup.msgGroupID
                                                    andNewType:MSG_GROUP_UI_TYPE_MULTI];
                } 
                
                NSArray *oldUiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
                for(CPUIModelMessageGroup *uiMsgGroup in oldUiMsgGroups)
                {
                    if (uiMsgGroup.msgGroupID&&existMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:existMsgGroup.msgGroupID])
                    {
                        [[CPUIModelManagement sharedInstance] setUserMsgGroup:uiMsgGroup];
                        [[CPSystemEngine sharedInstance] updateTagByCreateMsgGroupWithCode:[NSNumber numberWithInt:RES_CODE_SUCESS]];
                        break;
                    }
                }
            }
            else 
            {
                [newMessageGroup setMemberList:memberList];//[memberList sortedArrayUsingSelector:@selector(orderNameWithGroupMember:)]];
//                switch (type)
//                {
//                    case CREATE_CONVER_TYPE_CLOSED:
//                        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
//                        break;
//                    case CREATE_CONVER_TYPE_COMMON:
//                        [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
//                        break;
//                    default:
//                        CPLogError(@"err create conver type");
//                        break;
//                }
                [newMessageGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
                [newMessageGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_MULTI]];
                
                [self createConversationWithUserNames:userNamesList andContextObj:newMessageGroup];
                //currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:newMessageGroup];
            }
        }
        //这里不考虑选择有user之外还有group的情况
        return;
    }
    if ([msgGroups count]==1)
    {
        CPUIModelMessageGroup *uiMsgGroup = [msgGroups objectAtIndex:0];
        if (uiMsgGroup.msgGroupID)
        {
            [[CPUIModelManagement sharedInstance] setUserMsgGroup:uiMsgGroup];
            NSInteger msgType = [uiMsgGroup.type integerValue];
            if (msgType==MSG_GROUP_UI_TYPE_CONVER_PRE)
            {
                [self refreshMsgGroupConverTypeWithGroupID:uiMsgGroup.msgGroupID
                                                andNewType:MSG_GROUP_UI_TYPE_CONVER];
            }
            else if (msgType==MSG_GROUP_UI_TYPE_MULTI_PRE)
            {
                [self refreshMsgGroupConverTypeWithGroupID:uiMsgGroup.msgGroupID
                                                andNewType:MSG_GROUP_UI_TYPE_MULTI];
            }            
            [[CPSystemEngine sharedInstance] updateTagByCreateMsgGroupWithCode:[NSNumber numberWithInt:RES_CODE_SUCESS]];
        }
    }
}
-(void)refreshMsgGroupConverTypeWithGroupID:(NSNumber *)msgGroupID andNewType:(NSInteger)newMsgType
{
    CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
    if (msgGroupID&&currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:msgGroupID])
    {
        [currMsgGroup setType:[NSNumber numberWithInt:newMsgType]];
        [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
    }
    [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:msgGroupID
                                                                andGroupType:[NSNumber numberWithInt:newMsgType]];
    CPDBModelMessageGroup *existDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:msgGroupID];
    [existDbMsgGroup setType:[NSNumber numberWithInt:newMsgType]];
    
    NSMutableArray *uiMsgGroups = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
    for(CPUIModelMessageGroup *msgGroup in uiMsgGroups)
    {
        if (msgGroupID&&msgGroup.msgGroupID&&[msgGroup.msgGroupID isEqualToNumber:msgGroupID])
        {
            [msgGroup setType:[NSNumber numberWithInt:newMsgType]];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
            break;
        }
    }
}
-(void)addGroupMemWithUserNames:(NSArray *)userNames andGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    if ([uiMsgGroup isMsgSingleGroup])
    {
        NSMutableArray *newGroupMems = [[NSMutableArray alloc] initWithArray:userNames];
        if ([uiMsgGroup.memberList count]>0) 
        {
            CPUIModelMessageGroupMember *msgGroupMem = [uiMsgGroup.memberList objectAtIndex:0];
            [newGroupMems addObject:msgGroupMem];
        }
        [[CPSystemEngine sharedInstance] createConversationWithUsers:newGroupMems andMsgGroups:nil andType:CREATE_CONVER_TYPE_COMMON];
    }else 
    {
        NSMutableArray *userNameArray = [[NSMutableArray alloc] init];
        for(CPUIModelUserInfo *uiUserInfo in userNames)
        {
            if (uiUserInfo.name)
            {
//                [userNameArray addObject:[NSString stringWithFormat:@"%@%@",uiUserInfo.name,uiUserInfo.domain]];
                [userNameArray addObject:uiUserInfo.name];
            }
        }
        if ([userNameArray count]>0)
        {
//            NSLog(@"uiMsgGroup.groupServerID  is %@",uiMsgGroup.groupServerID);
            [self addGroupMemWithUserNames:userNameArray andGroupJid:uiMsgGroup.groupServerID];
        }
    }
}
-(void)addNewMsgTipWithNickName:(NSString *)nickName andMsgText:(NSString *)msgText andUnReadCount:(NSNumber *)unReadedCount andGroupID:(NSNumber *)groupID andGroup:(CPUIModelMessageGroup *)group
{
    if ([CoreUtils stringIsNotNull:nickName]&&msgText&&unReadedCount&&groupID&&group)
    {
        NSMutableDictionary *tipsMsgDic = [[NSMutableDictionary alloc] init];
        [tipsMsgDic setObject:nickName forKey:new_msg_tip_nick_name];
        [tipsMsgDic setObject:msgText forKey:new_msg_tip_msg_text];
        [tipsMsgDic setObject:unReadedCount forKey:new_msg_tip_un_readed_count];
        [tipsMsgDic setObject:groupID forKey:new_msg_tip_msg_group_id];
        [tipsMsgDic setObject:group forKey:new_msg_tip_msg_group];
         
        [[CPSystemEngine sharedInstance] updateTagByTipsNewMsgWithDic:tipsMsgDic];
    }
    else 
    {
        CPLogInfo(@"nickname is %@,text is %@,unreaded count is %@,group id is %@",nickName,msgText,unReadedCount,groupID);
    }
}
-(void)addNewMsgTipWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    NSNumber *unReadedCount = uiMsgGroup.unReadedCount;
    NSString *msgText = @"";
    NSNumber *groupID = uiMsgGroup.msgGroupID;
    NSString *tipsNickName = uiMsgGroup.groupName;
    
    NSDictionary *tipsDic = [[CPUIModelManagement sharedInstance] tipsNewMsgDic];
    if (tipsDic)
    {
        NSNumber *tipsMsgGroupID = [tipsDic objectForKey:new_msg_tip_msg_group_id];
        NSNumber *tipsUnReadedCount = [tipsDic objectForKey:new_msg_tip_un_readed_count];
        if (tipsMsgGroupID&&tipsUnReadedCount&&[tipsMsgGroupID isEqualToNumber:groupID]&&[tipsUnReadedCount isEqualToNumber:unReadedCount])
        {
            return;
        }
    }

    
    if (![CoreUtils stringIsNotNull:tipsNickName])
    {
        NSArray *memberList = [uiMsgGroup memberList];
        if ([memberList count]>0)
        {
            CPUIModelMessageGroupMember *groupMem = [memberList objectAtIndex:0];
            CPDBModelUserInfo *userInfo = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:groupMem.userName];
            NSString *memNickName = userInfo.nickName;
            if (![CoreUtils stringIsNotNull:memNickName])
            {
                memNickName = groupMem.nickName;
            }
            if ([uiMsgGroup isMsgSingleGroup])
            {
                tipsNickName = memNickName;
            }
            else 
            {
                tipsNickName = [NSString stringWithFormat:@"%@(%d人)",memNickName,[memberList count]+1];
            }
        }    
    }
    [[[CPSystemEngine sharedInstance] msgManager] addNewMsgTipWithNickName:tipsNickName
                                                                andMsgText:msgText
                                                            andUnReadCount:unReadedCount 
                                                                andGroupID:groupID
                                                                  andGroup:uiMsgGroup];
}
#pragma mark receive sys msg
-(void)addFriendCommendWithSysMsg:(XMPPSystemMessage *)sysMsg
{
    //
}
-(void)excuteModifyFriendReqWithSysMsg:(XMPPSystemMessage *)sysMsg
{
    CPLogInfo(@"modify friend relation,req is %@",sysMsg.reqId);
//    [[[CPSystemEngine sharedInstance] userManager] answerRequestWithReqID:sysMsg.reqId andFlag:1];
}
-(void)excuteModifyFriendResWithSysMsg:(XMPPSystemMessage *)sysMsg
{
    [[[CPSystemEngine sharedInstance] sysManager] getFriendsByTimeStampCached];
}
#pragma mark protocol action method

-(void)createConversationWithUserNames:(NSArray *)userArray andContextObj:(NSObject *)obj
{
    [[[CPSystemEngine sharedInstance] httpEngine] createGroupForModule:[self class] withMembers:userArray andContextObj:obj];
}
-(void)getGroupInfoWithGroupJid:(NSString *)groupJid
{
    [[[CPSystemEngine sharedInstance] httpEngine] getGroupInfoForModule:[self class] ofGroup:groupJid];
}
-(void)addGroupMemWithUserNames:(NSArray *)userNames andGroupJid:(NSString *)groupJid
{
    //TODO:
    [[[CPSystemEngine sharedInstance] httpEngine] addGroupMembersForModule:[self class]
                                                                   ofGroup:groupJid
                                                               withMembers:userNames
                                                             andContextObj:userNames];
}
-(void)removeGroupMemWithUserNames:(NSArray *)userNames andGroupJid:(NSString *)groupJid
{
    NSMutableArray *userNameList = [[NSMutableArray alloc] init];
    for(CPUIModelMessageGroupMember *groupMem in userNames)
    {
        if (groupMem.userName)
        {
            [userNameList addObject:groupMem.userName];
        }
    }
    if ([userNameList count]>0)
    {
        [[[CPSystemEngine sharedInstance] httpEngine] removeGroupMembersForModule:[self class]
                                                                          ofGroup:groupJid
                                                                      withMembers:userNameList
                                                                    andContextObj:userNames];
    }
}
-(void)quitGroupWithGroupJid:(NSString *)groupJid
{
    [[[CPSystemEngine sharedInstance] httpEngine] quitGroupForModule:[self class] fromGroup:groupJid];
}
-(void)addFavoriteGroupWithGroupJid:(NSString *)groupJid andName:(NSString *)name
{
    //TODO:
    [[[CPSystemEngine sharedInstance] httpEngine] addFavoriteGroupForModule:[self class]
                                                                  withGroup:groupJid
                                                               andGroupName:name
                                                              andContextObj:name];
}
//登录之后获取最新的群－收藏的多人会话
-(void)getFavoriteGroupsWithTimeStamp:(NSString *)timeStamp
{
    [[[CPSystemEngine sharedInstance] httpEngine] getFavoriteGroupsForModule:[self class] withTimeStamp:timeStamp];
}
-(void)modifyFavoriteGroupNameWithGroupJid:(NSString *)groupJID withGroupName:(NSString *)groupName
{
    //TODO:
    [[[CPSystemEngine sharedInstance] httpEngine] modifyFavoriteGroupNameForModule:[self class]
                                                                           ofGroup:groupJID
                                                                     withGroupName:groupName
                                                                     andContextObj:groupName];
}
-(void)removeFavoriteGroupWithGroupJid:(NSString *)groupJID
{
    [[[CPSystemEngine sharedInstance] httpEngine] removeGroupFromFavoriteForModule:[self class] dstGroup:groupJID];
}

#pragma mark protocol delegate
- (void)XmppEngineStatusChanged:(NSInteger)status
{
#ifndef SYS_STATE_MIGR
    switch (status)
    {
        case STATE_XMPPENGINE_CONNECTING:
 //           [self removeAllWillSendXmppMsgs];
            break;
        case STATE_XMPPENGINE_CONNECTED:
            //连接成功，重置系统标识 STATE_XMPPENGINE_CONNECTED 
            [[CPSystemEngine sharedInstance] updateSysOnlineStatus];
            [[HPTopTipView shareInstance] showMessage:@"网络连接成功"];
            break;
        case STATE_XMPPENGINE_AUTHFAILED:
            [[CPSystemEngine sharedInstance] updateSysOfflineStatus];
            [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
            [[CPSystemEngine sharedInstance] autoLogin];
            break;
        case STATE_XMPPENGINE_DISCONNECTED:
            [[CPSystemEngine sharedInstance] updateSysOfflineStatus];
            [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
            [[CPSystemEngine sharedInstance] autoLogin];
            [[HPTopTipView shareInstance] showMessage:@"网络连接断开"];
            break;
        case STATE_XMPPENGINE_RECONNECTING:
            [[CPSystemEngine sharedInstance] updateSysOfflineStatus];
             [[HPTopTipView shareInstance] showMessage:@"网络重连"];
            break;
            //断开连接   a 重置系统标识 b自动登录 c断开xmpp连接
            //STATE_XMPPENGINE_AUTHFAILED，   a b c
            //STATE_XMPPENGINE_DISCONNECTED， a b c
            //STATE_XMPPENGINE_RECONNECTING   a
            //
        default:
            break;
    }
    CPLogInfo(@"%d",status);
#endif
}
- (void)xmppEngineMessageSendingStatusOf:(NSNumber *)messageID changedTo:(NSNumber *)status
{
    [[CPSystemEngine sharedInstance] updateMsgSendResponseByOperationWithID:messageID andStatus:status];
}
- (void)handleUserMessageReceived:(NSObject *)userMessage
{
    if (userMessage&&[userMessage isKindOfClass:[XMPPUserMessage class]])
    {
        [self receiveMsgWithmsg:userMessage];
    }
}
- (void)handleGroupMessageReceived:(NSObject *)groupMessage
{
    if (groupMessage&&[groupMessage isKindOfClass:[XMPPGroupMessage class]])
    {
        CPLogInfo(@"-4- %@",groupMessage);
        [self receiveGroupMsgWithmsg:groupMessage];
    }
}
- (void)handleSystemMessageReceived:(NSObject *)sysMsg
{
    if (sysMsg&&[sysMsg isKindOfClass:[XMPPSystemMessage class]])
    {
        XMPPSystemMessage *sys = (XMPPSystemMessage *)sysMsg;
        NSInteger sysType = [sys.type integerValue];
        switch (sysType)
        {
            case SystemMessageTypeLogoutNotify:
            {
                [[CPSystemEngine sharedInstance] sysLogoutAndGotoLoginWithDesc:@"此帐号已修改密码，请重新登录"];
            }
                break;
            case SystemMessageTypeFriendRecommend:
            case SystemMessageTypeAddFriendRequest:
            case SystemMessageTypeAddFriendResponse:
            case SystemMessageTypeRelationDown:
            case SYstemMessageTypeRelationMatchNotify:
            case SystemMessageTypeAck:
            case SystemMessageTypeUnknown:
                [[CPSystemEngine sharedInstance] receiveSysMsgByOperationWithXmppMsgs:[NSArray arrayWithObject:sysMsg]];
                break;
            
            default:
                [[CPSystemEngine sharedInstance] receiveSysMsgByOperationWithXmppMsgs:[NSArray arrayWithObject:sysMsg]];
                break;
        }
    }
}

- (void)handleCreateGroupResult:(NSNumber *)resultCode withObject:(NSObject *)obj andContextObject:(NSObject *)contextObj
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        NSString *groupJid = (NSString *)obj;
        CPDBModelMessageGroup *dbMsgGroup = (CPDBModelMessageGroup *)contextObj;
        [dbMsgGroup setGroupServerID:groupJid];
        [[CPSystemEngine sharedInstance] createConversationSelfByOperationWithObj:dbMsgGroup];
//        NSNumber *currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:dbMsgGroup];
//        [self refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:YES];
    }
    else 
    {
        [[CPUIModelManagement sharedInstance] setCreateMsgGroupDesc:[CoreUtils filterResponseDescWithCode:resultCode]];
        [[CPSystemEngine sharedInstance] updateTagByCreateMsgGroupWithCode:[NSNumber numberWithInt:RES_CODE_ERROR]];
    }
}
- (void)handleGetGroupInfoResult:(NSNumber *)resultCode withObject:(NSObject *)obj andOrignalGroupJID:(NSString *)groupJID
{
    //重新创建group或者修改
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (obj&&[obj isKindOfClass:[CPPTModelGroupInfo class]])
        {
            [[CPSystemEngine sharedInstance] createConversationByOperationWithObj:obj];
        }
    }
    else
    {
#if 1
        if( resultCode && ((1712 == [resultCode intValue]) || (1711 == [resultCode intValue])) )
        {
            CPLogInfo(@"groupJID:%@\n", groupJID);
            if( groupJID && [groupJID length] )
            {
                [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID];
            }
        }
#endif
        [[CPSystemEngine sharedInstance] updateTagByRemoveGroupMemWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [CoreUtils filterResponseDescWithCode:resultCode],group_manage_dic_res_desc,
          [NSNumber numberWithInt:RES_CODE_ERROR],group_manage_dic_res_code,nil]];
    }
}
- (void)handleAddGroupMembersResult:(NSNumber *)resultCode ofGroup:(NSString *)groupJID
                   andContextObject:(NSObject *)contextObj
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (contextObj&&[contextObj isKindOfClass:[NSArray class]])
        {
            [[CPSystemEngine sharedInstance] addGroupMemsByOperationWithGroupServerID:groupJID
                                                                        andUpdateNams:(NSArray *)contextObj];
        }
    }
    else 
    {
#if 1
      if( resultCode && ((1712 == [resultCode intValue]) || (1711 == [resultCode intValue])) )
      {
          [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID];
      }
#endif
        [[CPSystemEngine sharedInstance] updateTagByAddGroupMemWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [CoreUtils filterResponseDescWithCode:resultCode],group_manage_dic_res_desc,
          [NSNumber numberWithInt:RES_CODE_ERROR],group_manage_dic_res_code,nil]];
    }
}
- (void)handleRemoveGroupMembersResult:(NSNumber *)resultCode ofGroup:(NSString *)groupJID
                      andContextObject:(NSObject *)contextObj
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (contextObj&&[contextObj isKindOfClass:[NSArray class]])
        {
            [[CPSystemEngine sharedInstance] removeGroupMemsByOperationWithGroupServerID:groupJID
                                                                        andUpdateNams:(NSArray *)contextObj];
        }
        [[CPSystemEngine sharedInstance] updateTagByRemoveGroupMemWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt:RES_CODE_SUCESS],group_manage_dic_res_code,nil]];
    }
    else 
    {
#if 1
        if( resultCode && (1711 == [resultCode intValue]) )
      {
          [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID];
      }
#endif
        [[CPSystemEngine sharedInstance] updateTagByRemoveGroupMemWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [CoreUtils filterResponseDescWithCode:resultCode],group_manage_dic_res_desc,
          [NSNumber numberWithInt:RES_CODE_ERROR],group_manage_dic_res_code,nil]];
    }
}
- (void)handleQuitGroupResult:(NSNumber *)resultCode ofGroup:(NSString *)groupJID
{
    if ( resultCode && [resultCode intValue] == RES_CODE_SUCESS )
    {
        [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID];
    }
    else
    {
#if 1
        if( resultCode && ((1711 == [resultCode intValue]) || (1712 == [resultCode intValue])) )
        {
            [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID];
        }
#endif
        [[CPSystemEngine sharedInstance] updateTagByQuitGroupWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [CoreUtils filterResponseDescWithCode:resultCode],group_manage_dic_res_desc,
          [NSNumber numberWithInt:RES_CODE_ERROR],group_manage_dic_res_code,nil]];
    }
}
- (void)handleAddFavoriteGroupResult:(NSNumber *)resultCode ofGroup:(NSString *)groupJID
                    andContextObject:(NSObject *)contextObj
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (contextObj&&[contextObj isKindOfClass:[NSString class]])
        {
            [[CPSystemEngine sharedInstance] upgradeConversationNameByOperationWithObj:groupJID andGroupName:(NSString *)contextObj];
        }
    }
    else
    {
#if 1
      if( resultCode && ((1712 == [resultCode intValue]) || (1711 == [resultCode intValue])) )
      {
          [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID];
      }
#endif
        [[CPSystemEngine sharedInstance] updateTagByAddFavoriteGroupWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [CoreUtils filterResponseDescWithCode:resultCode],group_manage_dic_res_desc,
          [NSNumber numberWithInt:RES_CODE_ERROR],group_manage_dic_res_code,nil]];
    }
}
- (void)hanldeGetFavoriteGroupsResult:(NSNumber *)resultCode withObject:(NSObject *)obj andTimeStamp:(NSString *)timeStamp
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (obj&&[obj isKindOfClass:[NSArray class]])
        {
            [[CPSystemEngine sharedInstance] setCachedMyConverTimeStamp:timeStamp];
            [[CPSystemEngine sharedInstance] updateConversationWithPtModels:(NSArray *)obj];
        }
    }
}
- (void)handleModifyFavoriteGroupNameResult:(NSNumber *)resultCode ofGroup:(NSString *)groupJID
                           andContextObject:(NSObject *)contextObj
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (contextObj&&[contextObj isKindOfClass:[NSString class]])
        {
            [[CPSystemEngine sharedInstance] updateConversationNameByOperationWithObj:groupJID andGroupName:(NSString *)contextObj];
        }
        [[CPSystemEngine sharedInstance] updateTagByModifyGroupNameWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt:RES_CODE_SUCESS],group_manage_dic_res_code,nil]];
    }
    else 
    {
#if 1
      if( resultCode && ((1712 == [resultCode intValue]) || (1711 == [resultCode intValue])) )
      {
          [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:groupJID ];
      }
#endif
        [[CPSystemEngine sharedInstance] updateTagByModifyGroupNameWithDic:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [CoreUtils filterResponseDescWithCode:resultCode],group_manage_dic_res_desc,
          [NSNumber numberWithInt:RES_CODE_ERROR],group_manage_dic_res_code,nil]];
    }
}
- (void)handleRemoveGroupFromFavoriteResult:(NSNumber *)resultCode ofGroup:(NSString *)groupJID
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
    }
}

//gmcMessage:XMPPGroupMemberChangeMessage
- (void)handleGroupMemberChangeMessageReceived:(NSObject *)gmcMessage
{
    if (gmcMessage&&[gmcMessage isKindOfClass:[XMPPGroupMemberChangeMessage class]])
    {
        XMPPGroupMemberChangeMessage *changeMsg = (XMPPGroupMemberChangeMessage *)gmcMessage;
        NSInteger changeType = [changeMsg.type integerValue];
        switch (changeType)
        {
            case GroupMemberChangeTypeAdd:
                [self getGroupInfoWithGroupJid:changeMsg.from];
                [[CPSystemEngine sharedInstance] updateConversationMemByOperationWithObj:gmcMessage];
                break;
            case GroupMemberChangeTypeRemove:
            {
                NSArray *ptGroupMemArray = changeMsg.changedMembers;
                BOOL hasMe = NO;
                NSString *loginName = [[CPSystemEngine sharedInstance] getAccountName];
                for(CPPTModelGroupMember *ptGroupMemName in ptGroupMemArray)
                {
                    NSString *memName = [ModelConvertUtils getAccountNameWithName:ptGroupMemName.jid];
                    if (memName&&loginName&&[loginName isEqualToString:memName])
                    {
                        hasMe = YES;
                        break;
                    }
                }
                if (hasMe)
                {
                    [[CPSystemEngine sharedInstance] removeConversationByOperationWithObj:changeMsg.from];
                }
                else 
                {
                    [self getGroupInfoWithGroupJid:changeMsg.from];
                    [[CPSystemEngine sharedInstance] updateConversationMemByOperationWithObj:gmcMessage];
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
