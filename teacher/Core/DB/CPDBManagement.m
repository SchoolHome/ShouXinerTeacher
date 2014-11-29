//
//  CPDBManagement.m
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPDBManagement.h"
#import "CoreUtils.h"
#import "CPSystemEngine.h"
#import "CPLGModelAccount.h"
#import "AlarmClockHelper.h"
#import "CPMsgManager.h"
@implementation CPDBManagement

@synthesize userList = userList_;
@synthesize resList = resList_;
@synthesize msgGroupList = msgGroupList_;
@synthesize contactArray = contactArray_;
@synthesize userMobileArray = userMobileArray_;
@synthesize resourceDictionary = resourceDictionary_;
@synthesize resourceCachedDicByServerID = resourceCachedDicByServerID_;
@synthesize userInfoCachedDicByID = userInfoCachedDicByID_;
@synthesize userInfoCachedDicByAccount = userInfoCachedDicByAccount_;
@synthesize contactsCachedDicByMobile = contactsCachedDicByMobile_;
@synthesize msgGroupCachedByUserName = msgGroupCachedByUserName_;
@synthesize msgGroupCachedByGroupID = msgGroupCachedByGroupID_;
@synthesize msgGroupCachedByGroupServerID = msgGroupCachedByGroupServerID_;
@synthesize petInfos = _petInfos;
@synthesize petDatas = _petDatas;
@synthesize isInited;

-(void)initializeWithLoginName:(NSString *)loginName
{    
    if (isInited)
    {
        
        
        return;
    }
    BOOL isSucess = [dbManager initDatabaseWithLoginName:loginName];
    NSInteger initDbStatusCode = [dbManager statusCode];
    
    babyDAO = [[CPDAOBabyInfoData alloc] initWithStatusCode:initDbStatusCode];
    msgDAO = [[CPDAOMessage alloc] initWithStatusCode:initDbStatusCode];
    msgGroupDAO = [[CPDAOMessageGroup alloc] initWithStatusCode:initDbStatusCode];
    msgGroupMemberDAO = [[CPDAOMessageGroupMember alloc] initWithStatusCode:initDbStatusCode];
    personalDAO = [[CPDAOPersonalInfo alloc] initWithStatusCode:initDbStatusCode];
    personalDataDAO = [[CPDAOPersonalInfoData alloc] initWithStatusCode:initDbStatusCode];
    personalAdditionDAO = [[CPDAOPersonalInfoDataAddition alloc] initWithStatusCode:initDbStatusCode];
    resDAO = [[CPDAOResource alloc] initWithStatusCode:initDbStatusCode];
    userDAO = [[CPDAOUserInfo alloc] initWithStatusCode:initDbStatusCode];
    userInfoDAO = [[CPDAOUserInfoData alloc] initWithStatusCode:initDbStatusCode];
    userAdditionDAO = [[CPDAOUserInfoDataAddition alloc] initWithStatusCode:initDbStatusCode];
    //notifyMessage change
    notifyMsgDAO = [[CPDAONotifyMessage alloc] initWithStatusCode:initDbStatusCode];
    //
    petInfoDAO = [[CPDAOPetInfo alloc] initWithStatusCode:initDbStatusCode];
    
    [[[CPSystemEngine sharedInstance] dbManagement] findAllUserInfos];
    [[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupList];
//    if( initDbStatusCode == 1 )
//    {
//        [self dbBeginTransaction];
//        [petInfoDAO initDefautlData];
//        [self dbCommit];
//    }
    isInited = YES;
    
}
-(void)initialize
{
    contactDAO = [[CPDAOContact alloc] init];
    contactWayDAO = [[CPDAOContactWay alloc] init];
    
    self.petInfos = [NSMutableDictionary dictionary];
    self.petDatas = [NSMutableDictionary dictionary];
}
-(id)init
{
    self = [super init];
    if (self) 
    {
        dbManager = [[CPDataBaseManager alloc] init];
        [self initialize];
    }
    return self;
    
}

-(void)dbBeginTransaction
{
    [dbManager beginTransaction];
}
-(void)dbCommit
{
    [dbManager commit];
}

-(void)dbBeginTransactionAbDb
{
    [dbManager beginTransactionAbDB];
}
-(void)dbCommitAbDb
{
    [dbManager commitAbDB];
}
-(void)closeAccountDB
{
    [dbManager closeDatabase];
    [self setIsInited:NO];
    babyDAO = nil;
    msgDAO = nil;
    msgGroupDAO = nil;
    msgGroupMemberDAO = nil;
    personalDAO = nil;
    personalDataDAO = nil;
    personalAdditionDAO = nil;
    resDAO = nil;
    userDAO = nil;
    userAdditionDAO = nil;
    userInfoDAO = nil;
    petInfoDAO = nil;
}
-(void)clearDbCache
{
    [self setUserList:nil];
    [self setResList:nil];
    [self setMsgGroupList:nil];
    [self setResourceDictionary:nil];
    [self setResourceCachedDicByServerID:nil];
    [self setUserInfoCachedDicByAccount:nil];
    [self setUserInfoCachedDicByID:nil];
    [self setUserMobileArray:nil];
    [self setMsgGroupCachedByGroupID:nil];
    [self setMsgGroupCachedByGroupServerID:nil];
    [self setMsgGroupCachedByUserName:nil];
    [self setPetDatas:nil];
    [self setPetInfos:nil];
}
#pragma mark contact API 

-(NSNumber *)insertContact:(CPDBModelContact *)dbContact
{
    CPDBModelContact *oldDbContact = [contactDAO findContactWithAbPersonID:dbContact.abPersonID];
    NSNumber *contactID  = nil;
    if (oldDbContact&&[[oldDbContact contactID] longLongValue]>0)
    {
        contactID = oldDbContact.contactID;
        [contactDAO updateContactWithID:contactID obj:dbContact];
        [contactWayDAO deleteContactWayWithContactID:contactID];
    }
    else 
    {
        contactID = [contactDAO insertContact:dbContact];
    }
    if (dbContact.contactWayList)
    {
        for(CPDBModelContactWay *dbContactWay in dbContact.contactWayList)
        {
            [dbContactWay setContactID:contactID];
            [contactWayDAO insertContactWay:dbContactWay];
        }
    }
    return contactID;
}
-(NSArray *)findallContactsCachedWithUpdateTime:(NSNumber *)updateTime
{
    if ([self.contactArray count]>0)
    {
        NSMutableArray *updateContacts = [[NSMutableArray alloc] init];
        for(CPDBModelContact *dbContact in self.contactArray)
        {
            if ([dbContact.updateTime longLongValue]>=[updateTime longLongValue])
            {
                [updateContacts addObject:dbContact];
            }
        }
        return updateContacts;
    }
    return nil;
}
-(NSArray *)findAllContactsWithUpdate:(NSNumber *)updateDate
{
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    NSArray *allContacts = nil;
    if (updateDate&&[updateDate longLongValue]>0)
    {
        allContacts = [contactDAO findAllContactsAscWithUpdateDate:updateDate];
    }
    else 
    {
        allContacts = [contactDAO findAllContactsAsc];
    }
    NSMutableDictionary *contactsMobileDic = [[NSMutableDictionary alloc] init];
    NSArray *allContactWays = [contactWayDAO findAllContactWaysByContactIDAsc];
    NSInteger wayIndex = 0;
    NSInteger wayCount = [allContactWays count];
    for(CPDBModelContact *dbContact in allContacts)
    {
        NSMutableArray *dbContactWayList = [[NSMutableArray alloc] init];
        for (; wayIndex<wayCount;)
        {
            CPDBModelContactWay *dbContactWay = [allContactWays objectAtIndex:wayIndex];
            if ([dbContactWay.contactID longLongValue]==0)
            {
                wayIndex ++;
            }
            if ([dbContactWay.contactID compare:dbContact.contactID]==NSOrderedSame)
            {
                [dbContactWayList addObject:dbContactWay];
                //add mobile to contactsCachedDicByMobile
                NSString *mobileValue = dbContactWay.value;
//                NSString *mobileValue = [NSString stringWithFormat:@"%@%@",dbContactWay.regionNumber,dbContactWay.value];
                if (mobileValue&&![@"" isEqualToString:mobileValue])
                {
                    [contactsMobileDic setObject:dbContact forKey:mobileValue];
                }
                wayIndex ++;
            }
            else if ([dbContactWay.contactID compare:dbContact.contactID]==NSOrderedAscending)
            {
                wayIndex ++;
            }
            else
            {
                break;
            }
        }
        [dbContact setContactWayList:dbContactWayList];
        [contactList addObject:dbContact];
    }

    if (!updateDate) 
    {
        [self setContactsCachedDicByMobile:contactsMobileDic];
        [self setContactArray:contactList];
    }
    return contactList;
}
-(CPDBModelContact *)getContactWithMobile:(NSString *)mobile
{
    return [self.contactsCachedDicByMobile objectForKey:mobile];
}

#pragma mark dao API


-(NSNumber *)insertBabyInfoData:(CPDBModelBabyInfoData *)dbBabyInfoData
{
    [self dbBeginTransaction];
    NSNumber *objID = [babyDAO insertBabyInfoData:dbBabyInfoData];
    [self dbCommit];
    return objID;
}
-(void)updateBabyInfoDataWithID:(NSNumber *)objID  obj:(CPDBModelBabyInfoData *)dbBabyInfoData
{
    [self dbBeginTransaction];
    [babyDAO updateBabyInfoDataWithID:objID obj:dbBabyInfoData];
    [self dbCommit];
}
-(CPDBModelBabyInfoData *)findBabyInfoDataWithID:(NSNumber *)objID
{
    return [babyDAO findBabyInfoDataWithID:objID];
}
-(NSArray *)findAllBabyInfoDatas
{
    return [babyDAO findAllBabyInfoDatas];
}
#pragma mark message's api
-(CPDBModelMessageGroup *)getMessageGroupFilledWithID:(NSNumber *)msgGroupID
{
    CPDBModelMessageGroup *msgGroup = [self findMessageGroupWithID:msgGroupID];
    if (msgGroup)
    {
        [msgGroup setMemberList:[msgGroupMemberDAO findAllMessageGroupMembersWithGroupID:msgGroupID]];
        [msgGroup setMsgList:[msgDAO findAllMessagesWithGroupID:msgGroupID]];
    }
    return msgGroup;
}
-(NSNumber *)insertMessageGroupByMemberList:(CPDBModelMessageGroup *)dbMessageGroup
{
    NSNumber *newMsgGroupID = [self insertMessageGroup:dbMessageGroup];
    if (newMsgGroupID)
    {
//        [self dbBeginTransaction];
        for(CPDBModelMessageGroupMember *dbMsgGroupMem in dbMessageGroup.memberList)
        {
            [dbMsgGroupMem setMsgGroupID:newMsgGroupID];
            [self insertMessageGroupMember:dbMsgGroupMem];
//            CPLogInfo(@" %@    %@",newMsgGroupID,dbMsgGroupMem.userName);
//            NSNumber *newMemID = [msgGroupMemberDAO insertMessageGroupMember:dbMsgGroupMem];
//            CPLogInfo(@" %@ ",newMemID);
        }
//        [self dbCommit];
    }
    CPDBModelMessageGroup *newMsgGroup = [self getMessageGroupFilledWithID:newMsgGroupID];
    if (newMsgGroup)
    {
        [self addMsgGroupCachedWithGroup:newMsgGroup];
    }
    return newMsgGroupID;
}
-(NSNumber *)insertMessage:(CPDBModelMessage *)dbMessage
{
    CPLogInfo(@"-8- %@",dbMessage);
    [self dbBeginTransaction];
    CPLogInfo(@"-9- %@",dbMessage);
    NSNumber *objID = [msgDAO insertMessage:dbMessage];
    [self dbCommit];
    CPDBModelMessage *dbMsg = [msgDAO findMessageWithID:objID];
    if ([dbMessage.isReaded integerValue]==MSG_STATUS_IS_NOT_READ)
    {
        [self updateNewestMsgWithGroupID:dbMessage.msgGroupID andNewstTime:dbMsg.date];
    }
    if ([dbMessage.flag integerValue]==1)
    {
        [self updateUpdateTimeWithGroupID:dbMessage.msgGroupID andNewstTime:dbMsg.date];
    }
    //add db msg to cached
    CPDBModelMessageGroup *dbMsgGroup = [self getExistMsgGroupWithGroupID:dbMsg.msgGroupID];
    if (dbMsgGroup)
    {
        NSMutableArray *newMsgList = [NSMutableArray arrayWithArray:dbMsgGroup.msgList];
        [newMsgList addObject:dbMsg];
        [dbMsgGroup setMsgList:newMsgList];
    }
    return objID;
}
-(void)updateMessageWithID:(NSNumber *)objID  obj:(CPDBModelMessage *)dbMessage
{
    [self dbBeginTransaction];
    [msgDAO updateMessageWithID:objID obj:dbMessage];
    [self dbCommit];
}
-(void)updateMessageWithGroupID:(NSNumber *)groupID andGroupServerID:(NSString *)groupServerID
{
    [self dbBeginTransaction];
    [msgDAO updateMessageWithGroupID:groupID andGroupServerID:groupServerID];
    [self dbCommit];
}
-(void)updateMessageWithGroupID:(NSNumber *)groupID andSendName:(NSString *)sendName
{
    [self dbBeginTransaction];
    [msgDAO updateMessageWithGroupID:groupID andSendName:sendName];
    [self dbCommit];
}
-(CPDBModelMessage *)findMessageWithID:(NSNumber *)objID
{
    return [msgDAO findMessageWithID:objID];
}

-(CPDBModelMessage *)findMessageWithResID:(NSNumber *)objID{
    return [msgDAO findMessageWithResID:objID];
}

-(NSArray *)findAllMessages
{
    return [msgDAO findAllMessages];
}
-(NSArray *)findAllMessagesWithGroupID:(NSNumber *)msgGroupID
{
    return [msgDAO findAllMessagesWithGroupID:msgGroupID];
}
-(void)updateMessageWithID:(NSNumber *)msgID andStatus:(NSNumber *)status
{
    [self dbBeginTransaction];
    [msgDAO updateMessageWithID:msgID andStatus:status];
    [self dbCommit];
}
-(void)resetMessageStateBySentError
{
    [self dbBeginTransaction];
    [msgDAO resetMessageStateBySentError];
    [self dbCommit];
}
-(NSArray *)findMsgListByPageWithGroupID:(NSNumber *)msgGroupID last_msg_time:(NSNumber *)lastMsgTime max_msg_count:(NSInteger)maxMsgCount
{
    return [msgDAO findMsgListByPageWithGroupID:msgGroupID last_msg_time:lastMsgTime max_msg_count:maxMsgCount];
}
-(NSArray *)findMsgListByPageWithGroupID:(NSNumber *)msgGroupID max_msg_count:(NSInteger)maxMsgCount
{
    return [msgDAO findMsgListByPageWithGroupID:msgGroupID max_msg_count:maxMsgCount];
}
-(NSArray *)findMsgListByNewestTimeWithGroupID:(NSNumber *)msgGroupID newest_msg_time:(NSNumber *)newestMsgTime
{
    return [msgDAO findMsgListByNewestTimeWithGroupID:msgGroupID newest_msg_time:newestMsgTime];
}
-(CPDBModelMessage *)findMessageWithSendID:(NSString *)sendName andContentType:(NSNumber *)contentType
{
    return [msgDAO findMessageWithSendID:sendName andContentType:contentType];
}
#pragma mark msg group API 
-(NSNumber *)insertMessageGroup:(CPDBModelMessageGroup *)dbMessageGroup
{
    [self dbBeginTransaction];
    NSNumber *objID = [msgGroupDAO insertMessageGroup:dbMessageGroup];
    [self dbCommit];
    CPDBModelMessageGroup *newMsgGroup = [self getMessageGroupFilledWithID:objID];
    if (newMsgGroup)
    {
        [self addMsgGroupCachedWithGroup:newMsgGroup];
    }
    return objID;
}
-(void)updateMessageGroupWithID:(NSNumber *)objID  obj:(CPDBModelMessageGroup *)dbMessageGroup
{
    [self dbBeginTransaction];
    [msgGroupDAO updateMessageGroupWithID:objID obj:dbMessageGroup];
    [self dbCommit];
}
-(CPDBModelMessageGroup *)findMessageGroupWithID:(NSNumber *)objID
{
    return [msgGroupDAO findMessageGroupWithID:objID];
}
-(CPDBModelMessageGroup *)findMessageGroupWithServerID:(NSString *)serverID
{
    return [msgGroupDAO findMessageGroupWithServerID:serverID];
}
-(CPDBModelMessageGroup *)findMessageGroupWithCreatorName:(NSString *)creatorName
{
    return [msgGroupDAO findMessageGroupWithCreatorName:creatorName];
}
-(NSArray *)findAllMessageGroups
{
    NSMutableArray *msgGroupArray = [[NSMutableArray alloc] init];
    NSArray *allMsgGroups = [msgGroupDAO findAllMessageGroupsByID];
    NSArray *allMsgs = [msgDAO findAllMessagesByGroupID];
    NSArray *allMsgMembers = [msgGroupMemberDAO findAllMessageGroupMembersByOrderByGroupID];
    NSInteger msgIndex = 0;
    NSInteger msgMemberIndex = 0;
    NSInteger msgCount = [allMsgs count];
    NSInteger msgMemberCount = [allMsgMembers count];
    
    NSMutableDictionary *msgGroupCachedTempByGroupID = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *msgGroupCachedTempByUserName = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *msgGroupCachedTempByGroupServerID = [[NSMutableDictionary alloc] init];
    for(CPDBModelMessageGroup *dbMsgGroup in allMsgGroups)
    {
        NSMutableArray *dbMsgList = [[NSMutableArray alloc] init];
        for (; msgIndex<msgCount;)
        {
            CPDBModelMessage *dbMsg = [allMsgs objectAtIndex:msgIndex];
            if ([dbMsg.msgGroupID longLongValue]==0)
            {
                msgIndex ++;
            }
            if ([dbMsg.msgGroupID compare:dbMsgGroup.msgGroupID]==NSOrderedSame)
            {
                [dbMsgList addObject:dbMsg];
                msgIndex ++;
            }
            else if ([dbMsg.msgGroupID compare:dbMsgGroup.msgGroupID]==NSOrderedAscending)
            {
                msgIndex ++;
            }
            else
            {
                break;
            }
        }
        [dbMsgGroup setMsgList:[dbMsgList sortedArrayUsingSelector:@selector(orderMsgWithDate:)]];
        
        NSMutableArray *dbGroupMemList = [[NSMutableArray alloc] init];
        for (; msgMemberIndex<msgMemberCount;)
        {
            CPDBModelMessageGroupMember *dbMsgMem = [allMsgMembers objectAtIndex:msgMemberIndex];
            if ([dbMsgMem.msgGroupID longLongValue]==0)
            {
                msgMemberIndex ++;
            }
            if ([dbMsgMem.msgGroupID compare:dbMsgGroup.msgGroupID]==NSOrderedSame)
            {
                [dbGroupMemList addObject:dbMsgMem];
                msgMemberIndex ++;
            }
            else if ([dbMsgMem.msgGroupID compare:dbMsgGroup.msgGroupID]==NSOrderedAscending)
            {
                msgMemberIndex ++;
            }
            else
            {
                break;
            }
        }
        [dbMsgGroup setMemberList:dbGroupMemList];
        if (dbMsgGroup.msgGroupID)
        {
            [msgGroupCachedTempByGroupID setObject:dbMsgGroup forKey:dbMsgGroup.msgGroupID];
            if ([dbMsgGroup isMsgSingleGroup]&&dbGroupMemList&&[dbGroupMemList count]==1) 
            {
                CPDBModelMessageGroupMember *firstGroupMember = [dbGroupMemList objectAtIndex:0];
                if (firstGroupMember.userName)
                {
//                    CPLogInfo(@"msgGroupCachedByUserName    user name is  %@",firstGroupMember.userName);
                    [msgGroupCachedTempByUserName setObject:dbMsgGroup forKey:firstGroupMember.userName];
                }
            }
            if (dbMsgGroup.groupServerID)
            {
                [msgGroupCachedTempByGroupServerID setObject:dbMsgGroup forKey:dbMsgGroup.groupServerID];
            }
        }
        [msgGroupArray addObject:dbMsgGroup];
    }
    [self setMsgGroupCachedByGroupID:msgGroupCachedTempByGroupID];
    [self setMsgGroupCachedByUserName:msgGroupCachedTempByUserName];
    [self setMsgGroupCachedByGroupServerID:msgGroupCachedTempByGroupServerID];
    return msgGroupArray;
}
-(void)addMsgGroupCachedWithGroup:(CPDBModelMessageGroup *)dbMsgGroup
{
    if (dbMsgGroup&&dbMsgGroup&&dbMsgGroup.msgGroupID)
    {
        NSMutableDictionary *msgGroupCachedTempByGroupID = [[NSMutableDictionary alloc] initWithDictionary:self.msgGroupCachedByGroupID];
        [msgGroupCachedTempByGroupID setObject:dbMsgGroup forKey:dbMsgGroup.msgGroupID];
        [self setMsgGroupCachedByGroupID:msgGroupCachedTempByGroupID];
        NSArray *dbGroupMemList = dbMsgGroup.memberList;
        if ([dbMsgGroup isMsgSingleGroup]&&dbGroupMemList&&[dbGroupMemList count]==1) 
        {
            CPDBModelMessageGroupMember *firstGroupMember = [dbGroupMemList objectAtIndex:0];
            if (firstGroupMember.userName)
            {
                NSMutableDictionary *msgGroupCachedTempByUserName = [[NSMutableDictionary alloc] initWithDictionary:self.msgGroupCachedByUserName];
                [msgGroupCachedTempByUserName setObject:dbMsgGroup forKey:firstGroupMember.userName];
                [self setMsgGroupCachedByUserName:msgGroupCachedTempByUserName];
            }
        }
        if (dbMsgGroup.groupServerID)
        {
            NSMutableDictionary *msgGroupCachedTempByServerID = [[NSMutableDictionary alloc] init];
            [msgGroupCachedTempByServerID setObject:dbMsgGroup forKey:dbMsgGroup.groupServerID];
            [self setMsgGroupCachedByGroupServerID:msgGroupCachedTempByServerID];
        }
    }
}
-(void)delMsgGroupCachedWithGroup:(CPDBModelMessageGroup *)dbMsgGroup
{
    if (dbMsgGroup&&dbMsgGroup&&dbMsgGroup.msgGroupID)
    {
        NSMutableDictionary *msgGroupCachedTempByGroupID = [[NSMutableDictionary alloc] initWithDictionary:self.msgGroupCachedByGroupID];
        [msgGroupCachedTempByGroupID removeObjectForKey:dbMsgGroup.msgGroupID];
        [self setMsgGroupCachedByGroupID:msgGroupCachedTempByGroupID];
        NSArray *dbGroupMemList = dbMsgGroup.memberList;
        if ([dbMsgGroup isMsgSingleGroup]&&dbGroupMemList&&[dbGroupMemList count]==1) 
        {
            CPDBModelMessageGroupMember *firstGroupMember = [dbGroupMemList objectAtIndex:0];
            if (firstGroupMember.userName)
            {
                NSMutableDictionary *msgGroupCachedTempByUserName = [[NSMutableDictionary alloc] initWithDictionary:self.msgGroupCachedByUserName];
                [msgGroupCachedTempByUserName removeObjectForKey:firstGroupMember.userName];
                [self setMsgGroupCachedByUserName:msgGroupCachedTempByUserName];
            }
        }
        if (dbMsgGroup.groupServerID)
        {
            NSMutableDictionary *msgGroupCachedTempByServerID = [[NSMutableDictionary alloc] init];
            [msgGroupCachedTempByServerID removeObjectForKey:dbMsgGroup.groupServerID];
            [self setMsgGroupCachedByGroupServerID:msgGroupCachedTempByServerID];
        }
    }
}
-(BOOL)hasExistMsgGroupWithUserName:(NSString *)userName
{
    if (userName&&[self.msgGroupCachedByUserName objectForKey:userName])
    {
        return YES;
    }
    return NO;
}
-(CPDBModelMessageGroup *)getExistMsgGroupWithUserName:(NSString *)userName
{
    if (userName)
    {
        if (self.msgGroupCachedByUserName&&[self.msgGroupCachedByUserName count]>0)
        {
            return [self.msgGroupCachedByUserName objectForKey:userName];
        }
        else 
        {
            NSArray *userMsgGroups = [msgGroupDAO findMessageGroupWithMemName:userName];
            if ([userMsgGroups count]>0)
            {
                return [userMsgGroups objectAtIndex:0];
            }
        }
    }
    return nil;
}
-(CPDBModelMessageGroup *)getExistMsgGroupDbWithUserName:(NSString *)userName
{
    if (userName)
    {
        NSArray *userMsgGroups = [msgGroupDAO findMessageGroupWithMemName:userName];
        if ([userMsgGroups count]>0)
        {
            CPDBModelMessageGroup *msgGroup = [userMsgGroups objectAtIndex:0];
            if (msgGroup.msgGroupID)
            {
                [msgGroup setMemberList:[msgGroupMemberDAO findAllMessageGroupMembersWithGroupID:msgGroup.msgGroupID]];
                [msgGroup setMsgList:[msgDAO findAllMessagesWithGroupID:msgGroup.msgGroupID]];
            }
            return msgGroup;
        }
    }
    return nil;
}
-(CPDBModelMessageGroup *)getExistMsgGroupWithGroupServerID:(NSString *)serverID
{
    if (serverID)
    {
        if (self.msgGroupCachedByGroupServerID&&[self.msgGroupCachedByGroupServerID count]>0)
        {
            return [self.msgGroupCachedByGroupServerID objectForKey:serverID];
        }
        else 
        {
            return [msgGroupDAO findMessageGroupWithServerID:serverID];
        }
    }
    return nil;
}
-(CPDBModelMessageGroup *)getExistMsgGroupWithGroupID:(NSNumber *)msgGroupID
{
    if (msgGroupID)
    {
        return [self.msgGroupCachedByGroupID objectForKey:msgGroupID];
    }
    return nil;
}
-(CPDBModelMessageGroup *)getExistMsgGroupWithUserNames:(NSArray *)userNames
{
    if (userNames&&[userNames count]>1)
    {
        NSInteger userNamesCount = [userNames count];
        NSMutableString *userNamesString = [[NSMutableString alloc] init];
        for(NSString *userName in userNames)
        {
            [userNamesString appendFormat:@",%@,",userName];
        }
        NSArray *oldMsgGroups = [self.msgGroupCachedByGroupID allValues];
        for(CPDBModelMessageGroup *dbMsgGroup in oldMsgGroups)
        {
            if ([dbMsgGroup.memberList count]==userNamesCount) 
            {
                BOOL hasNoCompare = NO;
                for(CPDBModelMessageGroupMember *groupMem in dbMsgGroup.memberList)
                {
                    NSString *userAccount = [NSString stringWithFormat:@",%@,",groupMem.userName];
                    if ([userNamesString rangeOfString:userAccount].length==0)
                    {
                        hasNoCompare = YES;
                        break;
                    }
                }
                if (!hasNoCompare)
                {
                    return dbMsgGroup;
                }
            }
        }
    }
    return nil;
}
-(void)updateMessageGroupWithID:(NSString *)serverID  andGroupName:(NSString *)name
{
    CPDBModelMessageGroup *dbMsgGroup = [self getExistMsgGroupWithGroupServerID:serverID];
    if (dbMsgGroup)
    {
        [dbMsgGroup setGroupName:name];
    }
    [self dbBeginTransaction];
    [msgGroupDAO updateMessageGroupWithID:serverID andGroupName:name];
    [self dbCommit];
}
-(void)updateMessageGroupUnReadedCountWithID:(NSNumber *)msgGroupID andCount:(NSNumber *)unReadedCount
{
    [self dbBeginTransaction];
    [msgGroupDAO updateMessageGroupUnReadedCountWithID:msgGroupID andCount:unReadedCount];
    [self dbCommit];
}
-(void)updateMessageGroupWithID:(NSNumber *)msgGroupID  andGroupType:(NSNumber *)type
{
    CPDBModelMessageGroup *dbMsgGroup = [self getExistMsgGroupWithGroupID:msgGroupID];
    if (dbMsgGroup)
    {
        [dbMsgGroup setType:type];
    }
    [self dbBeginTransaction];
    [msgGroupDAO updateMessageGroupWithID:msgGroupID andGroupType:type];
    [self dbCommit];
}
-(void)deleteGroupWithID:(NSNumber *)msgGroupID
{
    CPLogInfo(@"-90-");
    [[AlarmClockHelper sharedInstance] removeAlarmClockObjectWithGroupID:msgGroupID];
    CPDBModelMessageGroup *dbMsgGroup = [self getExistMsgGroupWithGroupID:msgGroupID];
    if (dbMsgGroup)
    {
        CPLogInfo(@"-91-");
        [self delMsgGroupCachedWithGroup:dbMsgGroup];
    }
    [self dbBeginTransaction];
    CPLogInfo(@"-92-");
    [msgGroupDAO deleteGroupWithID:msgGroupID];
    [self dbCommit];
}
-(void)deleteGroupMsgsWithID:(NSNumber *)msgGroupID
{
    [self dbBeginTransaction];
    CPLogInfo(@"-93-");
    [msgGroupDAO deleteGroupMsgsWithID:msgGroupID];
    [self dbCommit];
}
-(NSArray *)findAllMessageConverGroup
{
    return [msgGroupDAO findAllMessageGroupsWithType:[NSNumber numberWithInt:MSG_GROUP_TYPE_CONVER]];
}
-(void)markMsgReadedWithGroupID:(NSNumber *)msgGroupID
{
    [self dbBeginTransaction];
    [msgGroupDAO markMsgReadedWithGroupID:msgGroupID];
    [self dbCommit];
}
-(void)updateUpdateTimeWithGroupID:(NSNumber *)msgGroupID andNewstTime:(NSNumber *)newstTime
{
    [self dbBeginTransaction];
    [msgGroupDAO updateUpdateTimeWithGroupID:msgGroupID andNewstTime:newstTime];
    [self dbCommit];
}
-(void)updateNewestMsgWithGroupID:(NSNumber *)msgGroupID andNewstTime:(NSNumber *)newstTime
{
    [self dbBeginTransaction];
    [msgGroupDAO updateNewestMsgWithGroupID:msgGroupID andNewstTime:newstTime];
    [self dbCommit];
}
-(void)markReadedWithMsg:(CPDBModelMessage *)dbMsg
{
    [self dbBeginTransaction];
    [msgGroupDAO markMsgReadTagWithMsgID:dbMsg.msgID];
    [msgGroupDAO markMsgGroupReadedWithGroupID:dbMsg.msgGroupID];
    [self dbCommit];
}
#pragma mark msg group member API 
-(NSNumber *)insertMessageGroupMember:(CPDBModelMessageGroupMember *)dbMessageGroupMember
{
    NSString *loginName = [[[CPSystemEngine sharedInstance] accountModel] loginName];
    if (loginName&&dbMessageGroupMember.userName&&[dbMessageGroupMember.userName isEqualToString:loginName])
    {
        return nil;
    }
    CPDBModelMessageGroupMember *exisetGroupMember = [msgGroupMemberDAO findMessageGroupMemberWithID:dbMessageGroupMember.msgGroupID
                                                                                         andUserName:dbMessageGroupMember.userName];
    if (exisetGroupMember)
    {
        [dbMessageGroupMember setMsgGroupMemID:exisetGroupMember.msgGroupMemID];
        [dbMessageGroupMember setHeaderResourceID:nil];
        [msgGroupMemberDAO updateMessageGroupMemberWithID:dbMessageGroupMember.msgGroupMemID
                                                      obj:dbMessageGroupMember];
        return dbMessageGroupMember.msgGroupMemID;
    }
    else
    {
        [self dbBeginTransaction];
        NSNumber *objID = [msgGroupMemberDAO insertMessageGroupMember:dbMessageGroupMember];
        [self dbCommit];
        return objID;
    }
}
-(void)updateMessageGroupMemberWithID:(NSNumber *)objID  obj:(CPDBModelMessageGroupMember *)dbMessageGroupMember
{
    [self dbBeginTransaction];
    [msgGroupMemberDAO updateMessageGroupMemberWithID:objID obj:dbMessageGroupMember];
    [self dbCommit];
}
-(CPDBModelMessageGroupMember *)findMessageGroupMemberWithID:(NSNumber *)objID
{
    return [msgGroupMemberDAO findMessageGroupMemberWithID:objID];
}
-(NSArray *)findAllMessageGroupMembers
{
    return [msgGroupMemberDAO findAllMessageGroupMembers];
}
-(NSArray *)findAllMessageGroupMembersWithGroupID:(NSNumber *)msgGroupID
{
    return [msgGroupMemberDAO findAllMessageGroupMembersWithGroupID:msgGroupID];
}
-(void)deleteAllGroupMemsWithGroupID:(NSNumber *)msgGroupID
{
    [self dbBeginTransaction];
    [msgGroupMemberDAO deleteAllGroupMemsWithGroupID:msgGroupID];
    [self dbCommit];
}
-(void)deleteGroupMemWithMemName:(NSString *)memName andGroupID:(NSNumber *)msgGroupID
{
    [self dbBeginTransaction];
    [msgGroupMemberDAO deleteGroupMemWithMemName:memName andGroupID:msgGroupID];
    [self dbCommit];
}
#pragma mark personal API 
-(NSNumber *)insertPersonalInfo:(CPDBModelPersonalInfo *)dbPersonalInfo
{
    [self dbBeginTransaction];
    NSNumber *objID = [personalDAO insertPersonalInfo:dbPersonalInfo];
    [self dbCommit];
    return objID;
}
-(void)deletePersonalInfos
{
    [self dbBeginTransaction];
    [personalDAO deletePersonalInfos];
    [self dbCommit];
}
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andName:(NSString *)nickName andSex:(NSNumber *)sex andHiddenBaby:(NSNumber *)isHiddenBaby
{
    [self dbBeginTransaction];
    [personalDAO updatePersonalInfoWithID:objID andName:nickName andSex:sex andHiddenBaby:isHiddenBaby];
    [self dbCommit];
}
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andName:(NSString *)nickName andSex:(NSNumber *)sex andLifeStatus:(NSNumber *)lifeStatus
{
    [self dbBeginTransaction];
    [personalDAO updatePersonalInfoWithID:objID andName:nickName andSex:sex andLifeStatus:lifeStatus];
    [self dbCommit];
}
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andSingleTime:(NSNumber *)singleTime
{
    [self dbBeginTransaction];
    [personalDAO updatePersonalInfoWithID:objID andSingleTime:singleTime];
    [self dbCommit];
}
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andHasBaby:(NSNumber *)hasBaby
{
    [self dbBeginTransaction];
    [personalDAO updatePersonalInfoWithID:objID andHasBaby:hasBaby];
    [self dbCommit];
}
-(void)updatePersonalInfoWithID:(NSNumber *)objID  obj:(CPDBModelPersonalInfo *)dbPersonalInfo
{
    [self dbBeginTransaction];
    [personalDAO updatePersonalInfoWithID:objID obj:dbPersonalInfo];
    [self dbCommit];
}
-(CPDBModelPersonalInfo *)findPersonalInfoWithID:(NSNumber *)objID
{
    return [personalDAO findPersonalInfoWithID:objID];
}
-(NSArray *)findAllPersonalInfos
{
    NSArray *allPersonalInfos = [personalDAO findAllPersonalInfos];
    for(CPDBModelPersonalInfo *dbPersonalInfo in allPersonalInfos)
    {
        if (dbPersonalInfo.personalInfoID)
        {
            NSArray *personalDatas = [personalDataDAO findAllPersonalInfoDatasWithPersonalID:dbPersonalInfo.personalInfoID];
            [dbPersonalInfo setDataList:personalDatas];
        }
    }
    return allPersonalInfos;
}
-(CPDBModelPersonalInfo *)findPersonalInfo
{
    NSArray *allPersonalInfos = [self findAllPersonalInfos];
    if ([allPersonalInfos count]>0)
    {
        return [allPersonalInfos objectAtIndex:0];
    }    
    return nil;
}

-(NSNumber *)insertPersonalInfoData:(CPDBModelPersonalInfoData *)dbPersonalInfoData
{
    [self dbBeginTransaction];
    NSNumber *objID = [personalDataDAO insertPersonalInfoData:dbPersonalInfoData];
    [self dbCommit];
    return objID;
}
-(void)updatePersonalInfoDataWithID:(NSNumber *)objID  obj:(CPDBModelPersonalInfoData *)dbPersonalInfoData
{
    [self dbBeginTransaction];
    [personalDataDAO updatePersonalInfoDataWithID:objID obj:dbPersonalInfoData];
    [self dbCommit];
}
-(CPDBModelPersonalInfoData *)findPersonalInfoDataWithID:(NSNumber *)objID
{
    return [personalDataDAO findPersonalInfoDataWithID:objID];
}
-(NSArray *)findAllPersonalInfoDatas
{
    return [personalDataDAO findAllPersonalInfoDatas];
}
-(CPDBModelPersonalInfoData *)findPersonalInfoDataWithPersonalID:(NSNumber *)personalID andClassify:(NSNumber *)classify
{
    return [personalDataDAO findPersonalInfoDataWithPersonalID:personalID andClassify:classify];
}

-(NSNumber *)insertPersonalInfoDataAddition:(CPDBModelPersonalInfoDataAddition *)dbPersonalInfoDataAddition
{
    [self dbBeginTransaction];
    NSNumber *objID = [personalAdditionDAO insertPersonalInfoDataAddition:dbPersonalInfoDataAddition];
    [self dbCommit];
    return objID;
}
-(void)updatePersonalInfoDataAdditionWithID:(NSNumber *)objID  obj:(CPDBModelPersonalInfoDataAddition *)dbPersonalInfoDataAddition
{
    [self dbBeginTransaction];
    [personalAdditionDAO updatePersonalInfoDataAdditionWithID:objID obj:dbPersonalInfoDataAddition];
    [self dbCommit];
}
-(CPDBModelPersonalInfoDataAddition *)findPersonalInfoDataAdditionWithID:(NSNumber *)objID
{
    return [personalAdditionDAO findPersonalInfoDataAdditionWithID:objID];
}
-(NSArray *)findAllPersonalInfoDataAdditions
{
    return [personalAdditionDAO findAllPersonalInfoDataAdditions];
}
#pragma mark resource API 
-(NSNumber *)insertResource:(CPDBModelResource *)dbResource
{
    if (!dbResource.createTime) 
    {
        [dbResource setCreateTime:[CoreUtils getLongFormatWithNowDate]];
    }
//    NSLog(@"ababaaaaaaa%@",dbResource.serverUrl);
    //if the server url has exist,modify the file name
    if ([dbResource.mark integerValue]==MARK_DOWNLOAD||[dbResource.mark integerValue]==MARK_PRE_DOWNLOAD)
    {
        if (!dbResource.serverUrl) 
        {
            return nil;
        }
    }
    CPDBModelResource *dbOldRes = [resDAO findResourceWithServerUrl:dbResource.serverUrl];
//    CPLogInfo(@"new res url is:%@,old res url is %@",dbResource.serverUrl,dbOldRes.serverUrl);
    if (dbOldRes.resID)
    {
        if ([dbResource.mark integerValue]!=MARK_UPLOAD&&
            dbOldRes.objType&&dbResource.objType&&[dbOldRes.objType isEqualToNumber:dbResource.objType]&&
            ((!dbOldRes.objID&&!dbResource.objID)||(dbOldRes.objID&&dbResource.objID&&[dbOldRes.objID isEqualToNumber:dbResource.objID]))) 
        {
            return dbOldRes.resID;
        }
        [dbResource setFileName:dbOldRes.fileName];
        [dbResource setFilePrefix:dbOldRes.filePrefix];
        [dbResource setMark:[NSNumber numberWithInt:MARK_DEFAULT]];
    }
    [self dbBeginTransaction];
    NSNumber *objID = [resDAO insertResource:dbResource];
    [self dbCommit];
    CPDBModelResource *newDbRes = [self findResourceWithID:objID];
//    CPLogInfo(@"new res url is:%@,save mark is %@",newDbRes.serverUrl,newDbRes.mark);
    [self addResCachedWithRes:newDbRes];
    return objID;
}
-(CPDBModelResource *)findResourceWithServerUrl:(NSString *)serverUrl
{
    return [resDAO findResourceWithServerUrl:serverUrl];
}
-(void)updateResourceWithID:(NSNumber *)objID  obj:(CPDBModelResource *)dbResource
{
    [self dbBeginTransaction];
    [resDAO updateResourceWithID:objID obj:dbResource];
    [self dbCommit];
}
-(CPDBModelResource *)findResourceWithID:(NSNumber *)objID
{
    return [resDAO findResourceWithID:objID];
}
-(void)initResources
{
    NSArray *allRes = [self findAllResources];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *resByServerUrlDic = [[NSMutableDictionary alloc] init];
    for(CPDBModelResource *dbRes in allRes)
    {
        if (dbRes.resID)
        {
            [resDic setObject:dbRes forKey:dbRes.resID];
        }
        if (dbRes.serverUrl)
        {
            [resByServerUrlDic setObject:dbRes forKey:dbRes.serverUrl];
        }
    }
    [self setResourceDictionary:resDic];
    [self setResourceCachedDicByServerID:resByServerUrlDic];
}
-(CPDBModelResource *)getResWithID:(NSNumber *)resID
{
    return [self findResourceWithID:resID];
//    return [self.resourceDictionary objectForKey:resID];
}
-(CPDBModelResource *)getResCachedWithID:(NSNumber *)resID
{
    return [self.resourceDictionary objectForKey:resID];
}
-(CPDBModelResource *)getResCachedWithServerID:(NSString *)serverUrl
{
    return [self.resourceCachedDicByServerID objectForKey:serverUrl];
}
-(CPDBModelResource *)findResourceVideoThumbImgWithObjID:(NSNumber *)objID
{
    return [resDAO findResourceWithObjID:objID 
                              andObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_MSG] 
                                 andType:[NSNumber numberWithInt:RESOURCE_FILE_TYPE_MSG_IMG]];
}
-(void)addResCachedWithRes:(CPDBModelResource *)dbRes
{
    if (dbRes&&dbRes.resID)
    {
        NSMutableDictionary *resDic = [[NSMutableDictionary alloc] initWithDictionary:self.resourceDictionary];
        if (dbRes.resID)
        {
            [resDic setObject:dbRes forKey:dbRes.resID];
            [self setResourceDictionary:resDic];
        }
        
        NSMutableDictionary *resByServerUrlDic = [[NSMutableDictionary alloc] initWithDictionary:self.resourceCachedDicByServerID];
        if (dbRes.serverUrl)
        {
            [resByServerUrlDic setObject:dbRes forKey:dbRes.serverUrl];
            [self setResourceCachedDicByServerID:resByServerUrlDic];
        }
    }
}
-(NSArray *)findAllResources
{
    return [resDAO findAllResources];
}
-(NSArray *)findAllResourcesWillDownload
{
    return [resDAO findAllResourcesWithMark:MARK_DOWNLOAD];
}
-(NSArray *)findAllResourcesWillUpload
{
    return [resDAO findAllResourcesWithMark:MARK_UPLOAD];
}
-(void)updateResourceDownloadedWithID:(NSNumber *)objID
{
    [self dbBeginTransaction];
    [resDAO updateResourceWithID:objID mark:MARK_DEFAULT];
    [self dbCommit];
}
-(void)updateResourceUpdateTimeWithID:(NSNumber *)objID andTime:(NSNumber *)updateTime
{
    CPDBModelResource *dbRes = [self getResCachedWithID:objID];
    [dbRes setCreateTime:updateTime];
    [self dbBeginTransaction];
    [resDAO updateResourceWithID:objID updateTime:updateTime];
    [self dbCommit];
}
-(void)updateResourceWillDownloadWithID:(NSNumber *)objID
{
    [self dbBeginTransaction];
    [resDAO updateResourceWithID:objID mark:MARK_DOWNLOAD];
    [self dbCommit];
}
-(void)updateResourceUploadedWithID:(NSNumber *)objID
{
    [self dbBeginTransaction];
    [resDAO updateResourceWithID:objID mark:MARK_DEFAULT];
    [self dbCommit];
}
-(void)updateResourceWithID:(NSNumber *)objID url:(NSString *)url
{
    CPDBModelResource *dbOldRes = [resDAO findResourceWithServerUrl:url];
    CPDBModelResource *dbNewRes = [resDAO findResourceWithID:objID];
    if (dbOldRes&&dbNewRes)
    {
        if ([dbOldRes.resID isEqualToNumber:dbNewRes.resID]) 
        {
            return;
        }
        if (dbOldRes.objType&&dbNewRes.objType&&[dbOldRes.objType isEqualToNumber:dbNewRes.objType]&&
            dbOldRes.objID&&dbNewRes.objID&&[dbOldRes.objID isEqualToNumber:dbNewRes.objID]) 
        {
            [self dbBeginTransaction];
            [resDAO delResourceWithResID:dbOldRes.resID];
            [self dbCommit];
        }
    }

    [self dbBeginTransaction];
    [resDAO updateResourceWithID:objID url:url];
    [self dbCommit];
}
-(void)updateResourceObjIDWithResID:(NSNumber *)resID obj_id:(NSNumber *)objID
{
    [self dbBeginTransaction];
    [resDAO updateObjIDWithResID:resID obj_id:objID];
    [self dbCommit];
}

#pragma mark user API 
-(NSNumber *)insertUserInfo:(CPDBModelUserInfo *)dbUserInfo
{
    [self dbBeginTransaction];
    NSNumber *objID = [userDAO insertUserInfo:dbUserInfo];
    [self dbCommit];
    return objID;
}

-(void)updateUserInfoWithID:(NSNumber *)objID  obj:(CPDBModelUserInfo *)dbUserInfo
{
    [self dbBeginTransaction];
    
    NSInteger relationType = [dbUserInfo.type intValue];
    if (relationType>USER_RELATION_DEFAULT&&relationType<USER_RELATION_COMMEND)
    {
        [userDAO addRelationWithUserAccount:dbUserInfo.name relation_account:dbUserInfo.coupleAccount relation_type:[dbUserInfo.type intValue]];
        [userDAO addRelationWithUserAccount:dbUserInfo.coupleAccount relation_account:dbUserInfo.name relation_type:[dbUserInfo.type intValue]];
    }

    [userDAO updateUserInfoWithID:objID obj:dbUserInfo];
    [self dbCommit];
}
-(CPDBModelUserInfo *)findUserInfoWithID:(NSNumber *)objID
{
    CPDBModelUserInfo *dbUserInfo = [userDAO findUserInfoWithID:objID];
    [dbUserInfo setDataList:[userInfoDAO findUserInfoDatasWithUserID:objID]];
//    NSLog(@"findUserInfoWithID     %@",dbUserInfo.dataList);
    return dbUserInfo;
}
-(NSArray *)findAllUserInfosBySubModel
{
    NSMutableArray *allUserArray = [[NSMutableArray alloc] init];
    NSArray *allUserInfos = [userDAO findAllUserInfosOrderByID];
    NSArray *allUserInfoDatas = [userInfoDAO findAllUserInfoDatasOrderByInfoID];
    NSInteger dataIndex = 0;
    NSInteger dataCount = [allUserInfoDatas count];
//    NSString *documentPath = [CoreUtils getDocumentPath];
    for(CPDBModelUserInfo *dbUserInfo in allUserInfos)
    {
        NSMutableArray *dbUserDataList = [[NSMutableArray alloc] init];
        for (; dataIndex<dataCount;)
        {
            CPDBModelUserInfoData *dbUserData = [allUserInfoDatas objectAtIndex:dataIndex];
            if ([dbUserData.userInfoID longLongValue]==0)
            {
                dataIndex ++;
            }
            if ([dbUserData.userInfoID compare:dbUserInfo.userInfoID]==NSOrderedSame)
            {
                [dbUserDataList addObject:dbUserData];
                dataIndex ++;
            }
            else if ([dbUserData.userInfoID compare:dbUserInfo.userInfoID]==NSOrderedAscending)
            {
                dataIndex ++;
            }
            else
            {
                break;
            }
        }
        [dbUserInfo setDataList:dbUserDataList];
        [allUserArray addObject:dbUserInfo];
    }
    return allUserArray;
}
-(NSArray *)findAllUserInfos
{
    NSArray *allUserInfos = [self findAllUserInfosBySubModel];
    NSMutableDictionary *usersDicByID = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *usersDicByAccount = [[NSMutableDictionary alloc] init];
//    NSArray *allUserInfos = [userDAO findAllUserInfos];
    NSMutableArray *friendArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *allUserMobileArray = [[NSMutableDictionary alloc] init];
    for(CPDBModelUserInfo *dbUserInfo in allUserInfos)
    {
        NSInteger type = [dbUserInfo.type intValue];
        if (type>USER_RELATION_DEFAULT)//&&type<=USER_RELATION_COMMEND)
        {
            [friendArray addObject:dbUserInfo];
//            if (dbUserInfo.userInfoID)
//            {
//                [usersDicByID setObject:dbUserInfo forKey:dbUserInfo.userInfoID];
//            }
//            if (dbUserInfo.name&&type!=USER_RELATION_COMMEND)
//            {
//                [usersDicByID setObject:dbUserInfo forKey:dbUserInfo.name];
//            }
            if(dbUserInfo.mobileNumber&&![@"" isEqualToString:dbUserInfo.mobileNumber])
            {
                [allUserMobileArray setObject:dbUserInfo forKey:dbUserInfo.mobileNumber];
            }
            if (dbUserInfo.name&&type!=USER_RELATION_COMMEND)
            {
                [usersDicByAccount setObject:dbUserInfo forKey:dbUserInfo.name];
            }
            if (dbUserInfo.userInfoID)
            {
                [usersDicByID setObject:dbUserInfo forKey:dbUserInfo.userInfoID];
            }
        }
    }
    [self setUserInfoCachedDicByID:usersDicByID];
    [self setUserInfoCachedDicByAccount:usersDicByAccount];
    [self setUserMobileArray:allUserMobileArray];
    return friendArray;
}
-(CPDBModelUserInfo *)getUserInfoByCachedWithID:(NSNumber *)userID
{
    if (self.userInfoCachedDicByID)
    {
        return [self.userInfoCachedDicByID objectForKey:userID];
    }
    return nil;
}
-(CPDBModelUserInfo *)getUserInfoByCachedWithName:(NSString *)userName
{
    if (self.userInfoCachedDicByAccount)
    {
        return [self.userInfoCachedDicByAccount objectForKey:userName];
    }
    return nil;
}
-(NSArray *)findAllUserCommendInfos
{
    return [userDAO findAllUserCommendInfos];
}
-(void)refreshUserCachedWithUser:(CPDBModelUserInfo *)dbUserInfo
{
    if (dbUserInfo.userInfoID)
    {
        NSMutableDictionary *tempUserInfoDic = [[NSMutableDictionary alloc] initWithDictionary:self.userInfoCachedDicByID];
        [tempUserInfoDic setObject:dbUserInfo forKey:dbUserInfo.userInfoID];
        [self setUserInfoCachedDicByID:tempUserInfoDic];
    }
    if (dbUserInfo.name)
    {
        NSMutableDictionary *tempUserInfoDic = [[NSMutableDictionary alloc] initWithDictionary:self.userInfoCachedDicByAccount];
        [tempUserInfoDic setObject:dbUserInfo forKey:dbUserInfo.name];
        [self setUserInfoCachedDicByAccount:tempUserInfoDic];
    }
}
-(void)initUsersWithUserArray:(NSArray *)userArray andAccountName:(NSString *)accountName
{
    [self deleteFriendUserInfos];
    [self dbBeginTransaction];
    for(CPDBModelUserInfo *dbUserInfo in userArray)
    {
        NSString *userNickName = nil;
        switch ([dbUserInfo.type integerValue])
        {
            case USER_RELATION_SYSTEM:
                userNickName = NSLocalizedString(@"SysUserSysMsg",nil);
                break;
            case USER_RELATION_XIAOSHUANG:
                userNickName = NSLocalizedString(@"SysUserXiaoShuang",nil);
                break;
            case USER_RELATION_FANXER:
                userNickName = NSLocalizedString(@"SysUserCoupleTeam",nil);
                break;   
            default:
                break;
        }
        if (userNickName)
        {
            [dbUserInfo setNickName:userNickName];
        }
        NSNumber *dbUserID = [userDAO insertUserInfo:dbUserInfo];
        NSInteger relationType = [dbUserInfo.type intValue];
        if (relationType>USER_RELATION_DEFAULT&&relationType<USER_RELATION_COMMEND)
        {
            [userDAO addRelationWithUserAccount:dbUserInfo.name relation_account:dbUserInfo.coupleAccount relation_type:[dbUserInfo.type intValue]];
            [userDAO addRelationWithUserAccount:dbUserInfo.coupleAccount relation_account:dbUserInfo.name relation_type:[dbUserInfo.type intValue]];
        }
        NSNumber *dbResID = nil;
        if (dbUserInfo.headerPath&&![@"" isEqualToString:dbUserInfo.headerPath]&&![dbUserInfo.headerPath isEqual:[NSNull null]])
        {
            CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
            [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",[CoreUtils getUUID]]];
            [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/header/",accountName]];
            [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
            [dbRes setServerUrl:dbUserInfo.headerPath];
            [dbRes setObjID:dbUserID];
            [dbRes setType:[NSNumber numberWithInt:USER_DATA_CLASSIFY_HEADER]];
            [dbRes setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_HEADER]];
            dbResID = [self insertResource:dbRes];
        }
        if (dbResID)
        {
            CPDBModelUserInfoData *dbUserInfoData = [[CPDBModelUserInfoData alloc] init];
            [dbUserInfoData setDataClassify:[NSNumber numberWithInt:USER_DATA_CLASSIFY_HEADER]];
            [dbUserInfoData setUserInfoID:dbUserID];
            [dbUserInfoData setResourceID:dbResID];
            [dbUserInfoData setDataType:[NSNumber numberWithInt:USER_DATA_TYPE_IMG]];
            [userInfoDAO insertUserInfoData:dbUserInfoData];
        }
        else 
        {
//            CPLogError(@"dbuser name is %@,header path is %@",dbUserInfo.name,dbUserInfo.headerPath);
        }
        //    CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        //    [dbRes setFileName:@"112.png"];
        //    [dbRes setFilePrefix:@"header/"];
        //    [dbRes setMark:[NSNumber numberWithInt:MARK_UPLOAD]];
        ////    [dbRes setServerUrl:@"http://www.krazytech.com/wp-content/uploads/iphone-5-1.jpeg"];
        //    [dbManagement_ insertResource:dbRes];

        
    }
    [self dbCommit];
    [self initResources];
}
-(CPDBModelUserInfo *)findUserInfoWithAccount:(NSString *)account
{
    return [userDAO findUserInfoWithAccount:account];
}
-(void)initUsersCommendWithUserArray:(NSArray *)userArray andAccountName:(NSString *)accountName
{
    [self dbBeginTransaction];
    for(CPDBModelUserInfo *dbUserInfo in userArray)
    {
        CPDBModelUserInfo *oldUserInfo = [userDAO findUserInfoWithAccount:dbUserInfo.name];
        if (oldUserInfo&&oldUserInfo.userInfoID)
        {
            continue;
        }
        NSNumber *dbUserID = [userDAO insertUserInfo:dbUserInfo];  
        NSNumber *dbResID = nil;
        if (dbUserInfo.headerPath&&![@"" isEqualToString:dbUserInfo.headerPath]&&![dbUserInfo.headerPath isEqual:[NSNull null]])
        {
            CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
            [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",[CoreUtils getUUID]]];
            [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/header/",accountName]];
            [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
            [dbRes setServerUrl:dbUserInfo.headerPath];
            [dbRes setObjID:dbUserID];
            [dbRes setType:[NSNumber numberWithInt:USER_DATA_CLASSIFY_HEADER]];
            [dbRes setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_HEADER]];
            dbResID = [self insertResource:dbRes];
        }
        if (dbResID)
        {
            CPDBModelUserInfoData *dbUserInfoData = [[CPDBModelUserInfoData alloc] init];
            [dbUserInfoData setDataClassify:[NSNumber numberWithInt:USER_DATA_CLASSIFY_HEADER]];
            [dbUserInfoData setUserInfoID:dbUserID];
            [dbUserInfoData setResourceID:dbResID];
            [dbUserInfoData setDataType:[NSNumber numberWithInt:USER_DATA_TYPE_IMG]];
            [userInfoDAO insertUserInfoData:dbUserInfoData];
        }
    }
    [self dbCommit];
    [self initResources];
}
-(void)deleteRelationWithUserAccount:(NSString *)accountName
{
    [self dbBeginTransaction];
    [userDAO deleteRelationWithUserAccount:accountName];
    [self dbCommit];
}
-(void)deleteUserWithAccount:(NSString *)accountName
{
    [self dbBeginTransaction];
    [userInfoDAO deleteUserDataWithUserName:accountName];
    [userDAO deleteUserWithAccount:accountName];
    [self dbCommit];
}
-(void)updateUserRelationWithUserName:(NSString *)accountName relationType:(NSNumber *)type
{
    [self dbBeginTransaction];
    [userDAO updateUserRelationWithUserName:accountName relationType:type];
    [self dbCommit];
}
-(void)deleteAllUserInfos
{
    [self dbBeginTransaction];
    [userDAO deleteAllUserInfos];
    [self dbCommit];
}
-(void)deleteFriendUserInfos
{
    [self dbBeginTransaction];
    [userDAO deleteFriendUserInfos];
    [userInfoDAO deleteAllUserDatas];
    [self dbCommit];
}
-(void)deleteUserInfoWithAccount:(NSString *)account
{
    [self dbBeginTransaction];
    [userDAO deleteUserInfoWithAccount:account];
    [self dbCommit];
}
-(void)addRelationWithUserAccount:(NSString *)userAccount relation_account:(NSString *)relationAccount relation_type:(NSInteger)type
{
    [self dbBeginTransaction];
    [userDAO addRelationWithUserAccount:userAccount relation_account:relationAccount relation_type:type];
    [self dbCommit];
}


-(NSNumber *)insertUserInfoData:(CPDBModelUserInfoData *)dbUserInfoData
{
    [self dbBeginTransaction];
    NSNumber *objID = [userInfoDAO insertUserInfoData:dbUserInfoData];
    [self dbCommit];
    return objID;
}
-(void)updateUserInfoDataWithID:(NSNumber *)objID  obj:(CPDBModelUserInfoData *)dbUserInfoData
{
    [self dbBeginTransaction];
    [userInfoDAO updateUserInfoDataWithID:objID obj:dbUserInfoData];
    [self dbCommit];
}
-(CPDBModelUserInfoData *)findUserInfoDataWithID:(NSNumber *)objID
{
    return [userInfoDAO findUserInfoDataWithID:objID];
}
-(NSArray *)findAllUserInfoDatas
{
    return [userInfoDAO findAllUserInfoDatas];
}
-(CPDBModelUserInfoData *)findUserInfoDataWithUserID:(NSNumber *)userID andClassify:(NSNumber *)classify
{
    return [userInfoDAO findUserInfoDataWithUserID:userID andClassify:classify];
}

-(NSNumber *)insertUserInfoDataAddition:(CPDBModelUserInfoDataAddition *)dbUserInfoDataAddition
{
    [self dbBeginTransaction];
    NSNumber *objID = [userAdditionDAO insertUserInfoDataAddition:dbUserInfoDataAddition];
    [self dbCommit];
    return objID;
}
-(void)updateUserInfoDataAdditionWithID:(NSNumber *)objID  obj:(CPDBModelUserInfoDataAddition *)dbUserInfoDataAddition
{
    [self dbBeginTransaction];
    [userAdditionDAO updateUserInfoDataAdditionWithID:objID obj:dbUserInfoDataAddition];
    [self dbCommit];
}
-(CPDBModelUserInfoDataAddition *)findUserInfoDataAdditionWithID:(NSNumber *)objID
{
    return [userAdditionDAO findUserInfoDataAdditionWithID:objID];
}
-(NSArray *)findAllUserInfoDataAdditions
{
    return [userAdditionDAO findAllUserInfoDataAdditions];
}
#pragma mark pet API 
-(NSArray *)findAllPetInfo
{
//    return [petInfoDAO findAllPetInfo];
    if( nil == self.petInfos )
    {
        self.petInfos = [NSMutableDictionary dictionary];
    }
    
    if( 0 == [self.petInfos count] )
    {
        NSArray *tmp = [petInfoDAO findAllPetInfo];
        for(CPDBModelPetInfo *pInfo in tmp)
        {
            [self.petInfos setObject:pInfo forKey:pInfo.petID];
        }
    }
    
//    CPLogInfo(@"findAllPetInfo---self.petInfos:%@\n", self.petInfos);

    return [self.petInfos allValues];
}

-(NSArray *)findAllPetData
{
//    return [petInfoDAO findAllPetData];
    if( nil == self.petDatas )
    {
        self.petDatas = [NSMutableDictionary dictionary];
    }
    
    if( 0 == [self.petDatas count] )
    {
        NSArray *tmp = [petInfoDAO findAllPetData];
        for( CPDBModelPetData *pData in tmp )
        {
            [self.petDatas setObject:pData forKey:pData.dataID];
        }
    }
    
//    CPLogInfo(@"findAllPetInfo---self.petDatas:%@\n", self.petDatas);
    
    return [self.petDatas allValues];
}

- (CPDBModelPetInfo *)getPetInfo:(NSString *)petID
{
    return [self.petInfos objectForKey:petID];
}

- (CPDBModelPetData *)getPetData:(NSString *)resID
{
    return [self.petDatas objectForKey:resID];
}

- (NSNumber *)insertPetInfo:(CPDBModelPetInfo *)dbPetInfo
{
    NSNumber *localID = nil;
    
    [self dbBeginTransaction];
    localID = [petInfoDAO insertPetInfo:dbPetInfo];
    [self dbCommit];
    
    dbPetInfo.localID = localID;
    
    [self.petInfos setObject:dbPetInfo forKey:dbPetInfo.petID];
    
    return localID;
}

- (NSNumber *)insertPetData:(CPDBModelPetData *)dbPetData
{
    NSNumber *localID = nil;
    
    [self dbBeginTransaction];
    localID = [petInfoDAO insertPetData:dbPetData];
    [self dbCommit];
    
    dbPetData.localID = localID;
    
    [self.petDatas setObject:dbPetData forKey:dbPetData.dataID];
    
    return localID;
}

- (void)updatePetDataWithID:(NSNumber *)objID obj:(CPDBModelPetData *)dbPetData
{
    dbPetData.localID = objID;
    
    [self dbBeginTransaction];
    [petInfoDAO updatePetDataWithID:objID obj:dbPetData];
    [self dbCommit];
    
    //warning more attention!!!!!
    //TODO : update buffer.
    //temp++
    [self.petDatas setObject:dbPetData forKey:dbPetData.dataID];
    //temp--
}
//notifyMessage change
-(NSNumber *)insertNotifyMessage:(CPDBModelNotifyMessage *)dbMessage
{
    CPLogInfo(@"-8- %@",dbMessage);
    [self dbBeginTransaction];
    CPLogInfo(@"-9- %@",dbMessage);
    NSNumber *objID = [notifyMsgDAO insertMessage:dbMessage];
    [self dbCommit];
    
    //insert urls
    for (NSString *url in dbMessage.imageUrl) {
        [self insertUrl:url andNotifyMessageID:objID];
    }
    //CPDBModelNotifyMessage *dbMsg = [notifyMsgDAO findMessageWithID:objID];
    /*
    if ([dbMessage.isReaded integerValue]==MSG_STATUS_IS_NOT_READ)
    {
        [self updateNewestMsgWithGroupID:dbMessage.msgGroupID andNewstTime:dbMsg.date];
    }
    if ([dbMessage.flag integerValue]==1)
    {
        [self updateUpdateTimeWithGroupID:dbMessage.msgGroupID andNewstTime:dbMsg.date];
    }
    //add db msg to cached
    CPDBModelMessageGroup *dbMsgGroup = [self getExistMsgGroupWithGroupID:dbMsg.msgGroupID];
    if (dbMsgGroup)
    {
        NSMutableArray *newMsgList = [NSMutableArray arrayWithArray:dbMsgGroup.msgList];
        [newMsgList addObject:dbMsg];
        [dbMsgGroup setMsgList:newMsgList];
    }
     */
    return objID;
}
-(NSNumber *)insertUrl:(NSString *)url andNotifyMessageID : (NSNumber *)notifyMsgID
{
    [self dbBeginTransaction];
    NSNumber *objID = [notifyMsgDAO insertUrlsWithUrl:url andNotifyMessageID:notifyMsgID];
    [self dbCommit];
    
    return objID;
}
-(NSArray *)findAllNewNotiyfMessages
{
    return   [notifyMsgDAO findAllNewMessages];
}
-(NSArray *)findNotifyMessagesOfCurrentFromJID:(NSString *)currentFromJID
{
    [self dbBeginTransaction];
    return [notifyMsgDAO findAllMessagesOfFromJID:currentFromJID];
}
-(NSInteger)allNotiUnreadedMessageCount
{
    return [notifyMsgDAO getAllNotiUnreadedMessageCount];
}
-(void)updateMessageReadedWithID:(NSString *)fromJID  obj:(NSNumber *)msgReaded
{
    [self dbBeginTransaction];
    [notifyMsgDAO updateMessageReadedWithID:fromJID obj:msgReaded];
    [self dbCommit];
}
-(void)deleteMsgGroupByFrom:(NSString *)fromJID
{
    [self dbBeginTransaction];
    [notifyMsgDAO deleteMsgGroupByFrom:fromJID];
    [self dbCommit];
}
@end
