//
//  CPOperationConverUpdate.m
//  iCouple
//
//  Created by yong wei on 12-4-28.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "CPOperationConverUpdate.h"

#import "CPPTModelGroupInfo.h"
#import "CPPTModelGroupMember.h"
#import "CPDBModelMessageGroup.h"
#import "CPUIModelMessageGroup.h"

#import "CPUIModelManagement.h"
#import "CPSystemEngine.h"
#import "CPDBManagement.h"
#import "CPMsgManager.h"
#import "ModelConvertUtils.h"
#import "XMPPGroupMemberChangeMessage.h"
#import "CPResManager.h"
#import "CoreUtils.h"

#import "PalmUIManagement.h"
@implementation CPOperationConverUpdate
- (id) initWithData:(NSObject *)obj withType:(NSInteger)type
{
    self = [super init];
    if (self)
    {
        groupObj = obj;
        updateType = type;
    }
    return self;
}

- (id) initWithID:(NSObject *)obj withType:(NSInteger)type andGroupName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        groupObj = obj;
        updateType = type;
        groupName = name;
    }
    return self;
}

-(void)createNewConverGroup
{
    CPPTModelGroupInfo *ptModelGroup = (CPPTModelGroupInfo *)groupObj;
//    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupServerID:ptModelGroup.jid];
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithServerID:ptModelGroup.jid];

    NSString *creatorName = [ModelConvertUtils getAccountNameWithName:ptModelGroup.ownerJID];
    NSNumber *msgGroupID = nil;
    NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
    if (existMsgGroup)
    {
        [existMsgGroup setGroupName:ptModelGroup.name];
        [existMsgGroup setCreatorName:creatorName];
//        [existMsgGroup setUpdateDate:nowDate];
        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:existMsgGroup.msgGroupID obj:existMsgGroup];
        msgGroupID = existMsgGroup.msgGroupID;
    }
    else 
    {
        CPDBModelMessageGroup *dbMsgGroup = [[CPDBModelMessageGroup alloc] init];
        if([CoreUtils stringIsNotNull:ptModelGroup.name])
        {
            [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_CONVER]];
        }
        else 
        {
            [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_MULTI]];
        }
        [dbMsgGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_COMMON]];
        [dbMsgGroup setGroupName:ptModelGroup.name];
        [dbMsgGroup setCreatorName:creatorName];
        [dbMsgGroup setGroupServerID:ptModelGroup.jid];
        [dbMsgGroup setUpdateDate:nowDate];
        msgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroup:dbMsgGroup];
    }
    if (msgGroupID)
    {
        [[[CPSystemEngine sharedInstance] dbManagement] deleteAllGroupMemsWithGroupID:msgGroupID];
        for(CPPTModelGroupMember *ptGroupMem in ptModelGroup.memberList)
        {
            CPDBModelMessageGroupMember *dbGroupMem = [[CPDBModelMessageGroupMember alloc] init];
            [dbGroupMem setUserName:[ModelConvertUtils getAccountNameWithName:ptGroupMem.jid]];
            [dbGroupMem setDomain:[ModelConvertUtils getDomainWithName:ptGroupMem.jid]];
            [dbGroupMem setNickName:ptGroupMem.nickName];
            [dbGroupMem setMsgGroupID:msgGroupID];
            [dbGroupMem setHeaderPath:ptGroupMem.icon];
            NSNumber *newGroupMemID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupMember:dbGroupMem];
            [[[CPSystemEngine sharedInstance] resManager] addResourceByGroupMemHeaderWithServerUrl:ptGroupMem.icon
                                                                                        andGroupID:msgGroupID];
        }
        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageWithGroupID:msgGroupID andGroupServerID:ptModelGroup.jid];
        [[[CPSystemEngine sharedInstance] msgManager] refreshMsgListWithMsgGroupID:msgGroupID isCreated:NO];
    }
}
-(void)updateConverMembers
{
    XMPPGroupMemberChangeMessage *ptGroupMemberChange = (XMPPGroupMemberChangeMessage *)groupObj;
    NSString *groupServerID = ptGroupMemberChange.from;
//    NSString *actorName = ptGroupMemberChange.actor;//@dd.com
    CPDBModelMessageGroup *existMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] findMessageGroupWithServerID:groupServerID];
    NSNumber *msgGroupID = nil;
    if (existMsgGroup)
    {
        msgGroupID = existMsgGroup.msgGroupID;
    }
    else 
    {
        //
    }
    CPDBModelMessage *newDbMsg = [[CPDBModelMessage alloc] init];
    [newDbMsg setMsgGroupServerID:groupServerID];
    [newDbMsg setMsgText:ptGroupMemberChange.content];
    [[[CPSystemEngine sharedInstance] msgManager] sendAutoMsgSysWithMsgGroupID:msgGroupID
                                                                        newMsg:newDbMsg];
//warning 待处理，目前返回的信息不足
//    if (msgGroupID)
//    {
//        [[[CPSystemEngine sharedInstance] dbManagement] deleteAllGroupMemsWithGroupID:msgGroupID];
//        for(CPPTModelGroupMember *ptGroupMem in ptModelGroup.memberList)
//        {
//            CPDBModelMessageGroupMember *dbGroupMem = [[CPDBModelMessageGroupMember alloc] init];
//            [dbGroupMem setUserName:ptGroupMem.jid];
//            [dbGroupMem setNickName:ptGroupMem.nickName];
//            [dbGroupMem setMobileNumber:ptGroupMem.icon];
//            [dbGroupMem setMsgGroupID:msgGroupID];
//            [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupMember:dbGroupMem];
//        }
//        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageWithGroupID:msgGroupID andGroupServerID:ptModelGroup.jid];
//        [[[CPSystemEngine sharedInstance] msgManager] refreshMsgListWithMsgGroupID:msgGroupID isCreated:NO];
//    }
    //这里是服务器对于群成员变更的通知，增加或者删除
}
-(void)updateGroupName
{
    NSString *groupServerID = (NSString *)groupObj;
    [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:groupServerID andGroupName:groupName];
    
    CPDBModelMessageGroup *existDbModelMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupServerID:groupServerID];
    NSArray *uiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
    if (existDbModelMsgGroup&&existDbModelMsgGroup.msgGroupID)
    {
//        NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
        CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:existDbModelMsgGroup.msgGroupID])
        {
            [currMsgGroup setGroupName:groupName];
//            [currMsgGroup setUpdateDate:nowDate];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
        }
        for(CPUIModelMessageGroup *uiMsgGroup in uiMsgGroups)
        {
            if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:existDbModelMsgGroup.msgGroupID])
            {
                [uiMsgGroup setGroupName:groupName];
//                [uiMsgGroup setUpdateDate:nowDate];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                break;
            }
        }
    }    
}
-(void)removeGroup
{
    NSString *groupServerID = (NSString *)groupObj;
    CPDBModelMessageGroup *existDbModelMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupServerID:groupServerID];
    if (existDbModelMsgGroup.msgGroupID)
    {
        [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupWithID:existDbModelMsgGroup.msgGroupID];
        
        NSMutableArray *uiMsgGroups = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
        for(CPUIModelMessageGroup *uiMsgGroup in uiMsgGroups)
        {
            if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:existDbModelMsgGroup.msgGroupID])
            {
                [uiMsgGroups removeObject:uiMsgGroup];
                [[CPUIModelManagement sharedInstance] setUserMessageGroupList:uiMsgGroups];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                break;
            }
        }
        
        CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        if(!currMsgGroup){// 从独立profile退群和从大家墙删群
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupDel];
        }else if(currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:existDbModelMsgGroup.msgGroupID])// multi chat
        {
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupDel];
        }
        


    }
}
-(void)deleteMsgGroup
{
    CPUIModelMessageGroup *uiMsgGroup = (CPUIModelMessageGroup *)groupObj;
    NSInteger groupType = [uiMsgGroup.type integerValue];
    switch (groupType)
    {
        case MSG_GROUP_UI_TYPE_SINGLE:
        {
            [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:uiMsgGroup.msgGroupID
                                                                        andGroupType:[NSNumber numberWithInt:MSG_GROUP_UI_TYPE_SINGLE_PRE]];
            if (uiMsgGroup.msgGroupID)
            {
                [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupMsgsWithID:uiMsgGroup.msgGroupID];
                CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
                if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
                {
                    [[CPSystemEngine sharedInstance] updateTagByMsgGroupDel];
                }
                CPDBModelMessageGroup *dbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:uiMsgGroup.msgGroupID];
                if (dbMsgGroup)
                {
                    [dbMsgGroup setMsgList:nil];
                    [dbMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_UI_TYPE_SINGLE_PRE]];
                    [dbMsgGroup setUnReadedCount:[NSNumber numberWithInt:0]];
                }
                NSArray *uiMsgGroups = [[NSArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
                for(CPUIModelMessageGroup *msgGroup in uiMsgGroups)
                {
                    if (msgGroup.msgGroupID&&[msgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
                    {
                        [msgGroup setMsgList:nil];
                        [msgGroup setType:[NSNumber numberWithInt:MSG_GROUP_UI_TYPE_SINGLE_PRE]];
                        [msgGroup setUnReadedCount:[NSNumber numberWithInt:0]];
                        [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                        break;
                    }
                }
                [[[CPSystemEngine sharedInstance] msgManager] refreshSysUnReadedCount];
            }
        }
            break;
        case MSG_GROUP_UI_TYPE_MULTI:
            if (uiMsgGroup.msgGroupID)
            {
                [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupMsgsWithID:uiMsgGroup.msgGroupID];
                [[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupConverTypeWithGroupID:uiMsgGroup.msgGroupID
                                                                                        andNewType:MSG_GROUP_UI_TYPE_MULTI_PRE];
//                [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupWithID:uiMsgGroup.msgGroupID];
//                CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
//                if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
//                {
//                    [[CPSystemEngine sharedInstance] updateTagByMsgGroupDel];
//                }
//                
//                NSMutableArray *uiMsgGroups = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
//                for(CPUIModelMessageGroup *msgGroup in uiMsgGroups)
//                {
//                    if (msgGroup.msgGroupID&&[msgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
//                    {
//                        [uiMsgGroups removeObject:msgGroup];
//                        [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[uiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
//                        [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
//                        break;
//                    }
//                }
                
            }
            break;
        case MSG_GROUP_UI_TYPE_CONVER:
            if (uiMsgGroup.msgGroupID)
            {
                [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupMsgsWithID:uiMsgGroup.msgGroupID];
                [[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupConverTypeWithGroupID:uiMsgGroup.msgGroupID
                                                                                        andNewType:MSG_GROUP_UI_TYPE_CONVER_PRE];
//                NSInteger newMsgType = MSG_GROUP_UI_TYPE_CONVER_PRE;
//                [[[CPSystemEngine sharedInstance] dbManagement] deleteGroupMsgsWithID:uiMsgGroup.msgGroupID];
//                CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
//                if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
//                {
//                    [currMsgGroup setType:[NSNumber numberWithInt:newMsgType]];
//                    [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
//                }
//                [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:uiMsgGroup.msgGroupID
//                                                                            andGroupType:[NSNumber numberWithInt:newMsgType]];
//                CPDBModelMessageGroup *existDbMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupID:uiMsgGroup.msgGroupID];
//                [existDbMsgGroup setType:[NSNumber numberWithInt:newMsgType]];
//                 
//                NSMutableArray *uiMsgGroups = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] userMessageGroupList]];
//                for(CPUIModelMessageGroup *msgGroup in uiMsgGroups)
//                {
//                    if (msgGroup.msgGroupID&&[msgGroup.msgGroupID isEqualToNumber:uiMsgGroup.msgGroupID])
//                    {
//                        [msgGroup setType:[NSNumber numberWithInt:newMsgType]];
////                        [uiMsgGroups removeObject:msgGroup];
////                        [[CPUIModelManagement sharedInstance] setUserMessageGroupList:[uiMsgGroups sortedArrayUsingSelector:@selector(orderMsgGroupWithDate:)]];
//                        [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
//                        break;
//                    }
//                }
                
            }
            break;
    }
}
-(void)upgradeGroup
{
    NSString *groupServerID = (NSString *)groupObj;    
    CPDBModelMessageGroup *existDbModelMsgGroup = [[[CPSystemEngine sharedInstance] dbManagement] getExistMsgGroupWithGroupServerID:groupServerID];
    if (existDbModelMsgGroup&&existDbModelMsgGroup.msgGroupID)
    {
//        NSNumber *nowDate = [CoreUtils getLongFormatWithNowDate];
        [existDbModelMsgGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
        [existDbModelMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_CONVER]];
        [existDbModelMsgGroup setGroupName:groupName];
//        [existDbModelMsgGroup setUpdateDate:nowDate];
        [[[CPSystemEngine sharedInstance] dbManagement] updateMessageGroupWithID:existDbModelMsgGroup.msgGroupID
                                                                             obj:existDbModelMsgGroup];
        
        CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
        if (currMsgGroup.msgGroupID&&[currMsgGroup.msgGroupID isEqualToNumber:existDbModelMsgGroup.msgGroupID])
        {
            [currMsgGroup setGroupName:groupName];
            [currMsgGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
            [currMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_CONVER]];
//            [currMsgGroup setUpdateDate:nowDate];
            [[CPSystemEngine sharedInstance] updateTagByMsgGroupData];
        }
        NSArray *uiMsgGroups = [[CPUIModelManagement sharedInstance] userMessageGroupList];
        for(CPUIModelMessageGroup *uiMsgGroup in uiMsgGroups)
        {
            if (uiMsgGroup.msgGroupID&&[uiMsgGroup.msgGroupID isEqualToNumber:existDbModelMsgGroup.msgGroupID])
            {
                [uiMsgGroup setGroupName:groupName];
                [uiMsgGroup setType:[NSNumber numberWithInt:MSG_GROUP_TYPE_CONVER]];
                [uiMsgGroup setRelationType:[NSNumber numberWithInt:MSG_GROUP_RELATION_TYPE_CLOSER]];
//                [uiMsgGroup setUpdateDate:nowDate];
                [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
                break;
            }
        }
    }    
}
-(void)createNewConverGroupBySelf
{
    NSNumber *currentMsgGroupID = [[[CPSystemEngine sharedInstance] dbManagement] insertMessageGroupByMemberList:(CPDBModelMessageGroup *)groupObj];
    [[[CPSystemEngine sharedInstance] msgManager] refreshMsgListWithMsgGroupID:currentMsgGroupID isCreated:YES];
}
//notifyMessage change
-(void)deleteNotifyMsgGroup
{
    CPDBModelNotifyMessage *msgGroup = (CPDBModelNotifyMessage *)groupObj;
    [[[CPSystemEngine sharedInstance] dbManagement] deleteMsgGroupByFrom:msgGroup.from];
    //更新缓存
    [[PalmUIManagement sharedInstance] setNoticeArray:[[[CPSystemEngine sharedInstance] dbManagement] findAllNewNotiyfMessages]];
    //通知ui
    [[CPSystemEngine sharedInstance] updateTagByNoticeMsg];
}
-(void)updateNotifyMsgGroup
{
    CPDBModelNotifyMessage *msgGroup = (CPDBModelNotifyMessage *)groupObj;
    //更改数据库未读数
    [[[CPSystemEngine sharedInstance] dbManagement] updateMessageReadedWithID:msgGroup.from obj:[NSNumber numberWithInteger:0]];
    
    //设置未读数
    __block NSInteger count = [CPUIModelManagement sharedInstance].friendMsgUnReadedCount;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFriendMsgUnReadedCount:count];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    //刷新缓存
    [[PalmUIManagement sharedInstance] setNoticeArray:[[[CPSystemEngine sharedInstance] dbManagement] findAllNewNotiyfMessages]];
    //更新ui
    [[CPSystemEngine sharedInstance] updateTagByNoticeMsg];
}
//notifyMessage change
-(void)main
{
    @autoreleasepool
    {
        switch (updateType)
        {
            case UPDATE_CONVER_TYPE_CREATE:
                [self createNewConverGroupBySelf];
                break;
            case UPDATE_CONVER_TYPE_INSERT:
                [self createNewConverGroup];
                break;
            case UPDATE_CONVER_TYPE_UPDATE:
                [self updateConverMembers];
                break;
            case UPDATE_CONVER_TYPE_GROUP_NAME:
                [self updateGroupName];
                break;
            case UPDATE_CONVER_TYPE_REMOVE:
                [self removeGroup];
                break;
            case UPDATE_CONVER_TYPE_UPGRADE:
                [self upgradeGroup];
                break;
            case UPDATE_CONVER_TYPE_DELETE:
                [self deleteMsgGroup];
                break;
            case UPDATE_CONVER_TYPE_NOTIFY_DELETE:
                [self deleteNotifyMsgGroup];
                break;
            case UPDATE_CONVER_TYPE_NOTIFY_UPDATE:
                [self updateNotifyMsgGroup];
                break;
        }
    }
}
@end
