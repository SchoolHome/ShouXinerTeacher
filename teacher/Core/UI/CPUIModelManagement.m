//
//  CPUIModelManagement.m
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPUIModelManagement.h"
#import "CPSystemEngine.h"
#import "CPSystemManager.h"
#import "CPUserManager.h"
#import "CPMsgManager.h"
#import "CPUIModelPersonalInfo.h"
#import "CPUIModelUserInfo.h"
#import "CPUIModelMessageGroup.h"
#import "CPPetManager.h"
#import "CPUIModelPetActionAnim.h"
#import "CPUIModelPetMagicAnim.h"
#import "CPUIModelPetFeelingAnim.h"
#import "CPUIModelPetSmallAnim.h"
#import "CPUIModelMessageGroupMember.h"
#import "CoreUtils.h"
#import "CPDBManagement.h"
#import "HPTopTipView.h"
#import "CPResManager.h"
#import "CPUIModelMessage.h"
#import "AudioPlayerManager.h"
#import "CPXmppEngine.h"
#import "MusicPlayerManager.h"
#import "MessageSoundPlayer.h"
#import "CPLGModelAccount.h"

#import "MediaStatusManager.h"

@implementation CPUIModelManagement

@synthesize loginCode,loginDesc,registerCode,registerDesc,sysOnlineStatus,uiPersonalInfo,activeCode,activeDesc,
contactArray,contactUpdateTag,bindCode,bindDesc,coupleTag,friendTag,coupleModel,friendArray,friendClosedTag,
friendCommendTag,friendClosedArray,friendCommendArray,modifyFriendTypeDic,findMobileIsUserDic,findMutualFriendDic,deleteFriendDic,
userMsgGroup,sysMsgListTag,userMsgGroupTag,systemMessageList,userMsgGroupListTag,userMessageGroupList,createMsgGroupTag,createMsgGroupDesc,
coupleMsgGroup,coupleMsgGroupTag,quitGroupDic,addGroupMemDic,removeGroupMemDic,modifyGroupNameDic,addFavoriteGroupDic,uiPersonalInfoTag, 
petDataDict,closedMsgUnReadedCount,coupleMsgUnReadedCount,friendMsgUnReadedCount,responseActionDic,getFriendProfileDic,
resourceServerUrlDic,smallAnimImgArrayDic,smallAnimDefaultImgDic,changePwdResDic,resetPwdPostResDic,resetPwdGetCodeResDic,tipsNewMsgDic,checkUpdateResponseDic;

/********************add relationDel KVO by wang shuo*************************/
@synthesize userRelationDelTag , userRelationDelList;
/********************add relationDel KVO by wang shuo*************************/

#ifdef SYS_STATE_MIGR
@synthesize accountState;
#endif

static CPUIModelManagement *sharedInstance = nil;

#pragma mark CPSystemEngine Singleton Implementation

+ (CPUIModelManagement *) sharedInstance
{
    if (sharedInstance == nil)
    {
        //sharedInstance = [[super allocWithZone:NULL] init];
        sharedInstance = [[CPUIModelManagement alloc] init];
    }
    
    return sharedInstance;
}

-(void)videoRecordStartNotification:(NSNotification *)notify{
    
//    NSLog(@"videoRecordStartNotification");
    [MediaStatusManager sharedInstance].isVideoRecording = YES;
    
}

-(void)videoRecordStopNotification:(NSNotification *)notify{
    
//    NSLog(@"videoRecordStopNotification");
    
    [MediaStatusManager sharedInstance].isVideoRecording = NO;
}

-(id)init{
    self = [super init];
    if (self) {
        //
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(videoRecordStartNotification:) 
                                                     name:AVCaptureSessionDidStartRunningNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(videoRecordStopNotification:) 
                                                     name:AVCaptureSessionDidStopRunningNotification 
                                                   object:nil];
        
    }
    return self;
}

//+ (id) allocWithZone:(NSZone *)zone
//{
//    return [self sharedInstance];
//}
//
//- (id) copyWithZone:(NSZone*)zone
//{
//    return self;
//}
#pragma mark API

-(BOOL) canConnectToNetwork
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);    
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) 
    {
        CPLogWarn("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

-(void)registerWithRegInfo:(CPUIModelRegisterInfo *)regInfo
{
    [[[CPSystemEngine sharedInstance] sysManager] registerWithRegInfo:regInfo];
}
-(void)loginWithName:(NSString *)loginName password:(NSString *)pwd
{
    if (loginName&&pwd)
    {
        [[[CPSystemEngine sharedInstance] sysManager] clearRegInfoData];
        [[[CPSystemEngine sharedInstance] sysManager] loginWithName:[loginName lowercaseString] password:pwd];
    }    
}
-(void)activeAccountWithCode:(NSString *)code
{
    [[[CPSystemEngine sharedInstance] sysManager] activeAccountWithCode:code];
}
-(void)bindMobileNumber:(NSString *)number region_number:(NSString *)regionNumber
{
    [[[CPSystemEngine sharedInstance] sysManager] bindMobileNumber:number region_number:regionNumber];
}
-(void)clearAccountTagData
{
    [[CPSystemEngine sharedInstance] clearAccountTagData];
    [[CPSystemEngine sharedInstance] sysLogout];
}
-(CPLGModelAccount *)getCurrentAccountModel
{
    return [[CPSystemEngine sharedInstance] accountModel];
}
-(void)logout
{
    //清空好友密友破冰记录
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"closeFriendIceBreak"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"friendIceBreak"];  
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groupPicNameDic"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groupIdDic"];
    
    [[CPSystemEngine sharedInstance] sysLogout];
}
-(void)uploadDeviceToken:(NSData *)deviceToken
{
    [[CPSystemEngine sharedInstance] setDeviceToken:deviceToken];
}

-(void)modifyUserPasswordWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd
{
    [[[CPSystemEngine sharedInstance] sysManager] modifyUserPasswordWithOldPwd:oldPwd andNewPwd:newPwd];
}
-(void)resetPasswordGetCodeWithUserName:(NSString *)userName andMobileNumber:(NSString *)mobileNumber
{
    [[[CPSystemEngine sharedInstance] sysManager] resetPasswordGetCodeWithUserName:userName
                                                                   andMobileNumber:mobileNumber
                                                                     andMobileArea:@"86"];
}
-(void)resetPasswordPostWithUserName:(NSString *)userName 
                     andMobileNumber:(NSString *)mobileNumber 
                              andPwd:(NSString *)password
                       andVerifyCode:(NSString *)verifyCode
{
    [[[CPSystemEngine sharedInstance] sysManager] resetPasswordPostWithUserName:userName
                                                                andMobileNumber:mobileNumber
                                                                  andMobileArea:@"86"
                                                                         andPwd:password 
                                                                  andVerifyCode:verifyCode];
}


-(NSString *)getFilePathWithServerUrl:(NSString *)serverUrl
{
    CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] getResCachedWithServerID:serverUrl];
    if (dbRes)
    {
        return [[[CPSystemEngine sharedInstance] resManager] getResourcePathWithRes:dbRes];
    }
    return nil;
}
-(void)sysInActive
{
//    [[AudioPlayerManager sharedManager] stopBackgroundMusic];
    [[MessageSoundPlayer sharedInstance] stopSound];
    [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
}
-(void)sysActive
{
    [[CPSystemEngine sharedInstance] initAbData];
#ifndef SYS_STATE_MIGR
    if ( sysOnlineStatus==SYS_STATUS_HTTP_LOGINED || sysOnlineStatus==SYS_STATUS_OFFLINE || sysOnlineStatus==SYS_STATUS_LOGING ) 
    {
        [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
        [[CPSystemEngine sharedInstance] autoLogin];
    }
#else
    [[[CPSystemEngine sharedInstance] sysManager] activeSystem];
#endif
}
-(NSNumber *)getUpdateTimeWithFilePath:(NSString *)filePath
{
    if (!filePath)
    {
        return nil;
    }
    NSArray *resArray = [[[[CPSystemEngine sharedInstance] dbManagement] resourceCachedDicByServerID] allValues];
    for(CPDBModelResource *dbRes in resArray)
    {
        if (dbRes.fileName)
        {
            NSRange range = [filePath rangeOfString:dbRes.fileName];
            if (range.length>1)
            {
                return dbRes.createTime;
            }
        }
    }
    return nil;
}
-(void)playSoundWithName:(NSString *)soundName
{
    return;
    if ([[MediaStatusManager sharedInstance] canPlaySound]) {
        [[MusicPlayerManager sharedInstance] playSound:soundName];
    }
}

-(void)playSoundByReceiveNewMsg
{
    [self playSoundWithName:@"receive_new_msg.mp3"];
}
-(void)playSoundByPlayAudioEnd
{
    [self playSoundWithName:@"play_audio_end.mp3"];
}
-(NSString *)getAccountFilePath
{
    NSString *loginName = [[CPSystemEngine sharedInstance] getAccountName];
    NSString *documentPath = [CoreUtils getDocumentPath];
    if ([CoreUtils stringIsNotNull:loginName]) 
    {
        return [NSString stringWithFormat:@"%@/%@/",documentPath,loginName];
    }
    return documentPath;
}
-(BOOL)hasLoginUser
{
    return [[CPSystemEngine sharedInstance] hasLoginUser];
}
-(void)pushFanxerTeam
{
    if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
    [[[CPSystemEngine sharedInstance] sysManager] pushFanxerTeam];
}
-(void)checkUpdate
{
    if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
        [[[CPSystemEngine sharedInstance] sysManager] checkUpdate];
}
-(void)modifyFriendTypeWithCategory:(UpdateFriendType) category andUserName:(NSString *)userName andInviteString:(NSString *)inviteString andCouldExpose:(BOOL)couldExpose
{
    [[[CPSystemEngine sharedInstance] userManager] modifyFriendTypeWithCategory:category andUserName:userName andInviteString:inviteString andCouldExpose:couldExpose];
}
-(void)inviteFriendWithCategory:(UpdateFriendType) category andMobile:(NSString *)mobile andCouldExpose:(BOOL)couldExpose
{
    [[[CPSystemEngine sharedInstance] userManager] inviteFriendWithCategory:category andMobile:mobile andCouldExpose:couldExpose];
}
-(void)findMobileIsUserWithMobiles:(NSArray *)mobileArray
{
    [[[CPSystemEngine sharedInstance] userManager] getUserWithMobiles:mobileArray];
}
-(void)deleteFriendRelationWithUserName:(NSString *)userName
{
    [[[CPSystemEngine sharedInstance] userManager] breakFriendRelationWithUserName:userName];
}
-(void)findMutualFriendsWithUserName:(NSString *)userName
{
    [[[CPSystemEngine sharedInstance] userManager] getFriendsMutualWithFriName:userName];
}
-(void)responseActionWithReq:(NSString *)reqID actionFlag:(ResponseFriReqFlag)flag
{
//    [[[CPSystemEngine sharedInstance] userManager] answerRequestWithReqID:reqID andFlag:flag];
}
-(BOOL)hasCouple
{
    return self.coupleModel != nil;
//    return (self.coupleModel!=nil)&&uiPersonalInfo
//    &&([uiPersonalInfo.lifeStatus intValue]==PERSONAL_LIFE_STATUS_COUPLE||[uiPersonalInfo.lifeStatus intValue]==PERSONAL_LIFE_STATUS_COUPLE_MARRIED);
}
-(BOOL)hasLover
{
    return  self.coupleModel != nil;
//    return (self.coupleModel!=nil)&&uiPersonalInfo&&[uiPersonalInfo.lifeStatus intValue]==PERSONAL_LIFE_STATUS_CURSE;
}
-(BOOL)isMySelfWithUserName:(NSString *)userName
{
    NSString *selfAccount = [[CPSystemEngine sharedInstance] getAccountName];
    if (userName&&selfAccount&&[selfAccount isEqualToString:userName])
    {
        return YES;
    }
    return NO;
}
-(BOOL)isMyCoupleWithUserName:(NSString *)userName
{
    NSString *coupleAccount = self.coupleModel.name;
    if (userName&&coupleAccount&&[coupleAccount isEqualToString:userName])
    {
        return YES;
    }
    return NO;
}
-(void)sendMsgWithGroup:(CPUIModelMessageGroup *)msgGroup andMsg:(CPUIModelMessage *)uiMsg
{
    if (msgGroup&&uiMsg)
    {
        [[CPSystemEngine sharedInstance] sendMsgByOperationWithGroup:msgGroup andMsg:uiMsg];
    }
    else 
    {
        CPLogError(@"msg group is nil or msg is nil!");
    }
    if (self.sysOnlineStatus==SYS_STATUS_ONLINE) 
    {
        //
    }
    else
    {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
    }
}
-(void)sendMsgWithGroupID:(NSNumber *)msgGroupID andMsg:(CPUIModelMessage *)uiMsg
{
    if (msgGroupID&&uiMsg)
    {
        [[CPSystemEngine sharedInstance] sendMsgByOperationWithGroupID:msgGroupID andMsg:uiMsg];
    }
    else
    {
        CPLogError(@"msg group id is nil or msg is nil!");
    }
}
-(void)reSendMsg:(CPUIModelMessage *)uiMsg andMsgGroup:(CPUIModelMessageGroup *)msgGroup
{
    if (uiMsg)
    {
        [[CPSystemEngine sharedInstance] reSendMsgByOperationWithMsg:uiMsg andMsgGroup:msgGroup];
    }
    else 
    {
        CPLogError(@"this ui msg is nil!");
    }
}
-(NSArray *)getAllContacts
{
    return [[[CPSystemEngine sharedInstance] userManager] getAllContacts];
}
-(NSArray *)getAllContactsByFilter
{
    return [[[CPSystemEngine sharedInstance] userManager] getAllContactsByFilter];
}
-(NSArray *)getAllContactsByFriendsFilter
{
    return [[[CPSystemEngine sharedInstance] userManager] getAllContactsByFriendsFilter];
}
-(CPUIModelUserInfo *)getUserInfoWithUserName:(NSString *)userName
{
    if (!userName)
    {
        return nil;
    }
    NSArray *oldFriendArray = [NSArray arrayWithArray:self.friendArray];
    for(CPUIModelUserInfo *userInfo in oldFriendArray)
    {
        if (userInfo.name&&[userInfo.name isEqualToString:userName])
        {
            return userInfo;
        }
    }
    return nil;
}
-(CPUIModelUserInfo *)getCommendUserInfoWithUserName:(NSString *)userName
{
    if (!userName)
    {
        return nil;
    }
    NSArray *oldCommendFriendArray = [NSArray arrayWithArray:self.friendCommendArray];
    for(CPUIModelUserInfo *userInfo in oldCommendFriendArray)
    {
        if (userInfo.name&&[userInfo.name isEqualToString:userName])
        {
            return userInfo;
        }
    }
    return nil;
}
-(NSString *)getContactFullNameWithMobile:(NSString *)mobileNumber
{
    if (mobileNumber)
    {
        return [[[CPSystemEngine sharedInstance] dbManagement] getContactWithMobile:mobileNumber].fullName;
    }
    return nil;
}
-(NSDictionary *)getWillCoupleDictionary
{
    CPLGModelAccount *accountModelCached = [[CPSystemEngine sharedInstance] accountModel];
    if (accountModelCached.willCoupleName&&accountModelCached.willCoupleRealtionType)
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:accountModelCached.willCoupleName,@"coupleName",
                accountModelCached.willCoupleRealtionType,@"relationType",nil];
    }
    return nil;
}
-(void)createConversationWithUsers:(NSArray *)userArray andMsgGroups:(NSArray *)msgGroups  andType:(CreateConversationType)type
{
    [[CPSystemEngine sharedInstance] createConversationWithUsers:userArray andMsgGroups:msgGroups andType:type];
}
-(void)setCurrentMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    [self setUserMsgGroup:uiMsgGroup];
    if (uiMsgGroup)
    {
        if ([uiMsgGroup isMsgSingleGroup])
        {
            if ([uiMsgGroup.memberList count]==1)
            {
                CPUIModelUserInfo *uiUserInfo = [(CPUIModelMessageGroupMember *)[uiMsgGroup.memberList objectAtIndex:0] userInfo];
                if ([uiUserInfo.type integerValue]<USER_RELATION_TYPE_COMMEND)
                {
                    [self getUserProfileWithUser:uiUserInfo];
                    [self getUserRecentWithUser:uiUserInfo];
                }
            }
        }
        else if([uiMsgGroup isMsgMultiGroup])
        {
            if (sysOnlineStatus==SYS_STATUS_ONLINE&&uiMsgGroup.groupServerID)
            {
                [[[CPSystemEngine sharedInstance] msgManager] getGroupInfoWithGroupJid:uiMsgGroup.groupServerID];
            }
        }
    }    
}
-(void)markMsgGroupReadedWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    if ([uiMsgGroup.unReadedCount integerValue]<=0)
    {
        return;
    }
    NSNumber *markGroupID = uiMsgGroup.msgGroupID;
    BOOL hasUnReadedCount = NO;
    if (markGroupID)
    {
        NSArray *oldUserMsgGroupList = [self.userMessageGroupList copy];
        for(CPUIModelMessageGroup *uiMsgGroup in oldUserMsgGroupList)
        {
            if (uiMsgGroup.msgGroupID&&![uiMsgGroup.msgGroupID isEqualToNumber:markGroupID]&&[uiMsgGroup.unReadedCount integerValue]>0)
            {
                [[[CPSystemEngine sharedInstance] msgManager] addNewMsgTipWithMsgGroup:uiMsgGroup];
                hasUnReadedCount = YES;
                break;
            }
        }
    }
    if (!hasUnReadedCount)
    {
        [[[CPSystemEngine sharedInstance] msgManager] addNewMsgTipWithNickName:@"nickname"
                                                                    andMsgText:@""
                                                                andUnReadCount:[NSNumber numberWithInt:0] 
                                                                    andGroupID:[NSNumber numberWithInt:0]
                                                                      andGroup:uiMsgGroup];
    }
    [[CPSystemEngine sharedInstance] markMsgGroupReadedByOperationWithMsgGroup:uiMsgGroup];
}
-(void)markMsgAudioReadedWithMsg:(CPUIModelMessage *)uiMsg
{
    [[CPSystemEngine sharedInstance] updateMsgAudioReadedByOperationWithMsg:uiMsg];
}
-(void)getUserProfileWithUser:(CPUIModelUserInfo *)uiUserInfo
{
    if (uiUserInfo.name&&sysOnlineStatus==SYS_STATUS_ONLINE)
    {
        [[[CPSystemEngine sharedInstance] userManager] getUserProfileWithUserName:uiUserInfo.name];
    }
}
-(void)getUserRecentWithUser:(CPUIModelUserInfo *)uiUserInfo
{
    if (uiUserInfo.name&&sysOnlineStatus==SYS_STATUS_ONLINE)
    {
        [[[CPSystemEngine sharedInstance] userManager] getUserRecentWithUserName:uiUserInfo.name];
    }
}

#pragma mark conver group
-(void)addGroupMemWithUserNames:(NSArray *)userNames andGroup:(CPUIModelMessageGroup *)uiGroup
{
    [[[CPSystemEngine sharedInstance] msgManager] addGroupMemWithUserNames:userNames andGroup:uiGroup];
}
-(void)removeGroupMemWithUserNames:(NSArray *)userNames andGroup:(CPUIModelMessageGroup *)uiGroup
{
    [[[CPSystemEngine sharedInstance] msgManager] removeGroupMemWithUserNames:userNames andGroupJid:uiGroup.groupServerID];
}
-(void)quitGroupWithGroup:(CPUIModelMessageGroup *)uiGroup
{
    [[[CPSystemEngine sharedInstance] msgManager] quitGroupWithGroupJid:uiGroup.groupServerID];
}
-(void)addFavoriteGroupWithGroup:(CPUIModelMessageGroup *)uiGroup andName:(NSString *)name
{
    [[[CPSystemEngine sharedInstance] msgManager] addFavoriteGroupWithGroupJid:uiGroup.groupServerID andName:name];
}
-(void)modifyFavoriteGroupNameWithGroup:(CPUIModelMessageGroup *)uiGroup withGroupName:(NSString *)groupName
{
    [[[CPSystemEngine sharedInstance] msgManager] modifyFavoriteGroupNameWithGroupJid:uiGroup.groupServerID withGroupName:groupName];
}
-(void)deleteMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;
{
    [[CPSystemEngine sharedInstance] deleteMessageGroupByOperationWithObj:uiMsgGroup];
}
-(void)getMsgListByPageWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    [[CPSystemEngine sharedInstance] getMsgListPagedByOperationWithMsgGroup:uiMsgGroup];
}
-(void)downloadResourceWithMsg:(CPUIModelMessage *)uimsg
{
    [[CPSystemEngine sharedInstance] updateMsgByOperationWithMsg:uimsg];
}
-(CPUIModelMessageGroup *)getMsgGroupWithUserName:(NSString *)userName
{
    if (!userName) 
    {
        return nil;
    }
    NSArray *msgGroupArray = [NSArray arrayWithArray:self.userMessageGroupList];
    for(CPUIModelMessageGroup *uiMsgGroup in msgGroupArray)
    {
        if ([uiMsgGroup.type integerValue]==MSG_GROUP_UI_TYPE_SINGLE||[uiMsgGroup.type integerValue]==MSG_GROUP_UI_TYPE_SINGLE_PRE)
        {
            if ([uiMsgGroup.memberList count]>0)
            {
                CPUIModelMessageGroupMember *uiMsgGroupMem = [uiMsgGroup.memberList objectAtIndex:0];
                if (uiMsgGroupMem.userName&&[uiMsgGroupMem.userName isEqualToString:userName])
                {
                    return uiMsgGroup;
                }
            }
        }
    }
    return nil;
}
-(NSArray *)getMsgListAskWithMsg:(CPUIModelMessage *)uiMsg
{
    return [[[CPSystemEngine sharedInstance] msgManager] getMsgListAskWithMsg:uiMsg];
}
-(void)responseActionWithMsg:(CPUIModelMessage *)uiMsg actionFlag:(ResponseFriReqFlag)flag
{
    CPUIModelSysMessageReq *sysMsg = [uiMsg getSysMsgReq];
    if (sysMsg.reqID)
    {
        [[[CPSystemEngine sharedInstance] userManager] answerRequestWithReqID:[sysMsg.reqID stringValue] 
                                                                      andFlag:flag 
                                                                andContextObj:uiMsg];
        [[[CPSystemEngine sharedInstance] userManager] setResponseActionUserName:sysMsg.userName];
    }

//    [[CPSystemEngine sharedInstance] responseActionSysMsgByOperationWithMsg:uiMsg andActionType:flag];
}

-(void)uploadPersonalBgImgWithData:(NSData *)imgData
{
    [[[CPSystemEngine sharedInstance] sysManager] uploadPersonalBgImgWithData:imgData];
}
-(void)uploadPersonalHeaderImgWithData:(NSData *)imgData
{
    [[[CPSystemEngine sharedInstance] sysManager] uploadPersonalHeaderImgWithData:imgData];
}
-(void)uploadPersonalCoupleImgWithData:(NSData *)imgData
{
    return;
    [[[CPSystemEngine sharedInstance] sysManager] uploadPersonalCoupleImgWithData:imgData];
}
-(void)uploadPersonalBabyImgWithData:(NSData *)imgData
{
    [[[CPSystemEngine sharedInstance] sysManager] uploadPersonalBabyImgWithData:imgData];
}
-(void)updateMyRecentInfoWithContent:(NSString *)content andType:(NSInteger)type
{
//    [[[CPSystemEngine sharedInstance] userManager] updateMyRecentInfoWithContent:content andType:type];
    CPUIModelPersonalInfo *oldPersonalInfo = self.uiPersonalInfo;
    [oldPersonalInfo setRecentType:type];
    [oldPersonalInfo setRecentContent:content];
    [[CPSystemEngine sharedInstance] updatePersonalInfoRecentUiByOperation:oldPersonalInfo];
}
-(void)setSingleTimeWithDate:(NSDate *)singleTime
{
//    [[[CPSystemEngine sharedInstance] userManager] setSingleTimeWithDate:singleTime];
    CPUIModelPersonalInfo *oldPersonalInfo = self.uiPersonalInfo;
    [oldPersonalInfo setSingleTime:[CoreUtils getLongFormatWithDate:singleTime]];
    [[CPSystemEngine sharedInstance] updatePersonalInfoSingleTimeUiByOperation:oldPersonalInfo];
}
-(void)updateBaby:(NSNumber *)isHiddenBaby
{
    CPUIModelPersonalInfo *oldPersonalInfo = self.uiPersonalInfo;
    [oldPersonalInfo setHasBaby:isHiddenBaby];
    [[CPSystemEngine sharedInstance] updatePersonalInfoBabyUiByOperation:oldPersonalInfo];
}
-(void)updatePersonalInfoWithNickName:(NSString *)nickName andSex:(NSInteger)sex andHiddenBaby:(NSNumber *)isHiddenBaby
{
    CPUIModelPersonalInfo *oldPersonalInfo = self.uiPersonalInfo;
    [oldPersonalInfo setNickName:nickName];
    [oldPersonalInfo setSex:[NSNumber numberWithInt:sex]];
    [oldPersonalInfo setHasBaby:isHiddenBaby];
    [[CPSystemEngine sharedInstance] updatePersonalInfoNameUiByOperation:oldPersonalInfo];

}
#pragma mark pet
- (NSArray *)allActionObjects
{
    return [[[CPSystemEngine sharedInstance] petManager] allActionObjects];
}

- (CPUIModelPetActionAnim *)actionObjectOfID:(NSString *)resID
{
    return [[[CPSystemEngine sharedInstance] petManager] actionObjectOfID:resID];
}

- (CPUIModelPetActionAnim *)actionObjectOfID:(NSString *)resID fromPet:(NSString *)petID
{
    return [self actionObjectOfID:resID];
}

- (NSArray *)allMagicObjects
{
    CPLogInfo(@"\n");
    
    return [[[CPSystemEngine sharedInstance] petManager] allMagicObjects];
}

- (CPUIModelPetMagicAnim *)magicObjectOfID:(NSString *)resID fromPet:(NSString *)petID
{
    return [[[CPSystemEngine sharedInstance] petManager] magicObject:resID ofPet:petID];
}

//- (NSArray *)allFeelingObjects
- (NSDictionary *)allFeelingObjects;
{
    return [[[CPSystemEngine sharedInstance] petManager] allFeelingObjects];
}

- (CPUIModelPetFeelingAnim *)feelingObjectOfID:(NSString *)resID fromPet:(NSString *)petID
{
    return [[[CPSystemEngine sharedInstance] petManager] feelingObject:resID ofPet:petID];
}

- (NSArray *)allSmallAnimObjects
{
    return [[[CPSystemEngine sharedInstance] petManager] allSmallAnimObjects];
}

- (CPUIModelPetSmallAnim *)smallAnimObectOfID:(NSString *)resID
{
    return [[[CPSystemEngine sharedInstance] petManager] smallAnimObectOfID:resID];
}

- (CPUIModelPetSmallAnim *)smallAnimObectOfEscapeChar:(NSString *)escChar
{
    
    CPUIModelPetSmallAnim *smallAnim = [[[CPSystemEngine sharedInstance] petManager] smallAnimObectOfEscapeChar:escChar];
    
    if ([self.smallAnimDefaultImgDic objectForKey:escChar])
    {
        //
    }
    else 
    {
        NSData *defaultData = [NSData dataWithContentsOfFile:[smallAnim thumbNail]];
        UIImage *aImage = [[UIImage alloc] initWithData:defaultData];
        if (aImage)
        {
            NSMutableDictionary *tempDefaultDic = [[NSMutableDictionary alloc] initWithDictionary:self.smallAnimDefaultImgDic];
            [tempDefaultDic setObject:aImage forKey:escChar];
            [self setSmallAnimDefaultImgDic:tempDefaultDic];
        }
    }
    if ([self.smallAnimImgArrayDic objectForKey:escChar])
    {
        //
    }
    else 
    {
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (CPUIModelAnimSlideInfo *info in [smallAnim allAnimSlides]) {
            
            NSData *data = [NSData dataWithContentsOfFile:info.fileName];
            UIImage *image = [[UIImage alloc] initWithData:data];
            if (image)
            {
                [imagesArray addObject:image];
            }
            data = nil;
            image = nil;
        }
        NSMutableDictionary *tempImgArrayDic = [[NSMutableDictionary alloc] initWithDictionary:self.smallAnimImgArrayDic];
        [tempImgArrayDic setObject:imagesArray forKey:escChar];
        [self setSmallAnimImgArrayDic:tempImgArrayDic];
    }
    [smallAnim setDefaultImg:[self.smallAnimDefaultImgDic objectForKey:escChar]];
    [smallAnim setAnimImgArray:[self.smallAnimImgArrayDic objectForKey:escChar]];
    return smallAnim;
}

- (void)downloadPetRes:(NSString *)resID ofPet:(NSString *)petID
{
    [[[CPSystemEngine sharedInstance] petManager] downloadPetRes:resID ofPet:petID];
}

- (void)updatePetResOfPet:(NSString *)petID
{
//TODO:
    [[[CPSystemEngine sharedInstance] petManager] downloadAllPetResForV06:@"pet_default"];
}

- (BOOL)isAllFeelingResAvailable
{
    return [[[CPSystemEngine sharedInstance] petManager] isAllFeelingResAvailable];
}

- (void)downloadAllFeelingResOfPet:(NSString *)petID
{
    [[[CPSystemEngine sharedInstance] petManager] downloadAllFeelingResForV06:@"pet_default"];
}

- (void)downloadPetRes:(NSString *)resID andResType:(NSNumber *)resType ofPet:(NSString *)petID
{
    [self downloadPetRes:resID ofPet:petID];
}

@end
