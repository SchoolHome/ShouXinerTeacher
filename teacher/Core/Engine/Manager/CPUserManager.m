//
//  CPUserManager.m
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPUserManager.h"

#import "CoreUtils.h"

#import "CPSystemEngine.h"
#import "CPSystemManager.h"
#import "CPHttpEngine.h"
#import "ModelConvertUtils.h"
#import "CPDBManagement.h"
#import "CPUIModelManagement.h"
#import "CPMsgManager.h"
#import "CPLGModelAccount.h"

#import "CPPTModelUserProfile.h"
#import "CPResManager.h"
@implementation CPUserManager
@synthesize responseActionUserName = responseActionUserName_;
-(id)init
{
    self = [super init];
    if (self) 
    {
    }
    return self;
    
}
#pragma mark ui manamgement method
-(void)refreshUserInfosCachedUiWithUser:(CPDBModelUserInfo *)dbUserInfo
{
    NSArray *oldUiUserInfos = [[CPUIModelManagement sharedInstance] friendArray];
    for(CPUIModelUserInfo *uiUserInfo in oldUiUserInfos)
    {
        if (dbUserInfo.userInfoID&&uiUserInfo.userInfoID&&[dbUserInfo.userInfoID isEqualToNumber:uiUserInfo.userInfoID])
        {
            [ModelConvertUtils convertDbUserInfoToUi:dbUserInfo withUiUserInfo:uiUserInfo];
            [[CPSystemEngine sharedInstance] updateTagByUsers];
            break;
        }
    }
}
-(void)refreshCoupleModelWithUser:(CPDBModelUserInfo *)dbUserInfo
{
    CPUIModelUserInfo *coupleModel = [[CPUIModelManagement sharedInstance] coupleModel];
    if (dbUserInfo.userInfoID&&coupleModel.userInfoID&&[dbUserInfo.userInfoID isEqualToNumber:coupleModel.userInfoID])
    {
        [ModelConvertUtils convertDbUserInfoToUi:dbUserInfo withUiUserInfo:coupleModel];
        [[CPSystemEngine sharedInstance] updateTagByCouple];
    }
}

#pragma mark open for operation
-(void)reInitContactsByCommendMobile
{
    return;
    NSArray *allContacts = [[[CPSystemEngine sharedInstance] dbManagement] contactArray];
    NSMutableArray *uiContactArray = [[NSMutableArray alloc] initWithCapacity:[allContacts count]];
    NSDictionary *userMobileDic = [[[CPSystemEngine sharedInstance] dbManagement] userMobileArray];
    for(CPDBModelContact *dbContact in allContacts)
    {
        CPUIModelContact *uiContact = [ModelConvertUtils dbContactToUi:dbContact];
        if (uiContact.contactWayList)
        {
            NSMutableArray *newContactWayList = [[NSMutableArray alloc] init];
            for(CPUIModelContactWay *uiContactWay in uiContact.contactWayList)
            {
                if (uiContactWay.value&&![userMobileDic objectForKey:uiContactWay.value])
                {
                    [newContactWayList addObject:uiContactWay];
                }
            }
            if ([newContactWayList count]>0)
            {
                [uiContact setContactWayList:newContactWayList];
                [uiContactArray addObject:uiContact];
            }
        }
    }
    [[CPSystemEngine sharedInstance] updateTagWithContacts:uiContactArray];
}
-(NSArray *)getAllContacts
{
    NSArray *allContacts = [[[CPSystemEngine sharedInstance] dbManagement] contactArray];
    NSMutableArray *uiContactArray = [[NSMutableArray alloc] initWithCapacity:[allContacts count]];
    for(CPDBModelContact *dbContact in allContacts)
    {
        CPUIModelContact *uiContact = [ModelConvertUtils dbContactToUi:dbContact];
        if (uiContact.contactWayList)
        {
            NSMutableArray *newContactWayList = [[NSMutableArray alloc] init];
            for(CPUIModelContactWay *uiContactWay in uiContact.contactWayList)
            {
                if (uiContactWay.value)
                {
                    [newContactWayList addObject:uiContactWay];
                }
            }
            if ([newContactWayList count]>0)
            {
                [uiContact setContactWayList:newContactWayList];
                [uiContactArray addObject:uiContact];
            }
        }
    }
    return uiContactArray;
}
-(NSArray *)getAllContactsByFilter
{
    NSArray *allContacts = [[[CPSystemEngine sharedInstance] dbManagement] contactArray];
    NSMutableArray *uiContactArray = [[NSMutableArray alloc] initWithCapacity:[allContacts count]];
    NSDictionary *userMobileDic = [[[CPSystemEngine sharedInstance] dbManagement] userMobileArray];
    for(CPDBModelContact *dbContact in allContacts)
    {
        CPUIModelContact *uiContact = [ModelConvertUtils dbContactToUi:dbContact];
        if (uiContact.contactWayList)
        {
            NSMutableArray *newContactWayList = [[NSMutableArray alloc] init];
            for(CPUIModelContactWay *uiContactWay in uiContact.contactWayList)
            {
                if (uiContactWay.value&&![userMobileDic objectForKey:uiContactWay.value])
                {
                    [newContactWayList addObject:uiContactWay];
                }
            }
            if ([newContactWayList count]>0)
            {
                [uiContact setContactWayList:newContactWayList];
                [uiContactArray addObject:uiContact];
            }
        }
    }
    return uiContactArray;
}
-(NSArray *)getAllContactsByFriendsFilter
{
    NSArray *allContacts = [[[CPSystemEngine sharedInstance] dbManagement] contactArray];
    NSMutableArray *uiContactArray = [[NSMutableArray alloc] initWithCapacity:[allContacts count]];
    NSDictionary *userMobileDic = [[[CPSystemEngine sharedInstance] dbManagement] userMobileArray];
    for(CPDBModelContact *dbContact in allContacts)
    {
        CPUIModelContact *uiContact = [ModelConvertUtils dbContactToUi:dbContact];
        if (uiContact.contactWayList)
        {
            NSMutableArray *newContactWayList = [[NSMutableArray alloc] init];
            for(CPUIModelContactWay *uiContactWay in uiContact.contactWayList)
            {
                CPDBModelUserInfo *dbUserInfo = [userMobileDic objectForKey:uiContactWay.value];
                if ((uiContactWay.value&&!dbUserInfo)||(dbUserInfo&&[dbUserInfo.type integerValue]==USER_RELATION_TYPE_COMMEND))
                {
                    [newContactWayList addObject:uiContactWay];
                }
            }
            if ([newContactWayList count]>0)
            {
                [uiContact setContactWayList:newContactWayList];
                [uiContactArray addObject:uiContact];
            }
        }
    }
    return uiContactArray;
}
-(void)initSysUserConver
{
    NSArray *dbUserList = [[[[CPSystemEngine sharedInstance] dbManagement] userInfoCachedDicByID] allValues];
    for(CPDBModelUserInfo *dbUserInfo in dbUserList)
    {
        switch ([dbUserInfo.type intValue]) 
        {
            case USER_RELATION_FANXER:
            case USER_RELATION_SYSTEM:
            case USER_RELATION_XIAOSHUANG:
            {
                CPUIModelUserInfo *uiUserInfo = [ModelConvertUtils dbUserInfoToUi:dbUserInfo];
                [[[CPSystemEngine sharedInstance] msgManager] createConversationWithUser:uiUserInfo];
            }
                break;
            case USER_RELATION_TYPE_COUPLE:
            case USER_RELATION_TYPE_LOVER:
            case USER_RELATION_TYPE_MARRIED:
            {
                CPUIModelUserInfo *uiUserInfo = [ModelConvertUtils dbUserInfoToUi:dbUserInfo];
                [[[CPSystemEngine sharedInstance] msgManager] createCoupleConversationWithUser:uiUserInfo];
            }
                break;
            case USER_RELATION_TYPE_COMMON:
            case USER_RELATION_TYPE_CLOSED:
            {
                CPUIModelUserInfo *uiUserInfo = [ModelConvertUtils dbUserInfoToUi:dbUserInfo];
                [[[CPSystemEngine sharedInstance] msgManager] createDefaultConversationWithUser:uiUserInfo];
            }
                break;
        }
    }
    [[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupList];
}
-(void)initUserList
{
    NSArray *allUserArray = [[[CPSystemEngine sharedInstance] dbManagement] findAllUserInfos];
    NSMutableArray *uiUserArray = [[NSMutableArray alloc] init];
    NSMutableArray *uiUserCommendArray = [[NSMutableArray alloc] init];
    for(CPDBModelUserInfo *dbUserInfo in allUserArray)
    {
        CPUIModelUserInfo *uiUserInfo = [ModelConvertUtils dbUserInfoToUi:dbUserInfo];
        NSLog(@"%@,%@",uiUserInfo.nickName,uiUserInfo.lifeStatus);
        // 王硕
        CPDBModelContact *dbContact = [[[CPSystemEngine sharedInstance] dbManagement] getContactWithMobile:uiUserInfo.mobileNumber];
        [uiUserInfo setFullName:dbContact.fullName];
        switch ([uiUserInfo.type intValue])
        {
            case USER_RELATION_TYPE_LOVER:
            case USER_RELATION_TYPE_COUPLE:
            case USER_RELATION_TYPE_MARRIED:{
                
                [uiUserArray addObject:uiUserInfo];
                [[CPUIModelManagement sharedInstance] setCoupleModel:uiUserInfo];
                if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
                {
                    [[[CPSystemEngine sharedInstance] userManager] getUserProfileWithUserName:uiUserInfo.name];
                    [[[CPSystemEngine sharedInstance] userManager] getUserRecentWithUserName:uiUserInfo.name];
                }
                [[CPSystemEngine sharedInstance] updateTagByCouple];
                //
                [[CPSystemEngine sharedInstance] backupSystemInfoWithCoupleName:nil
                                                              andCoupleUserName:nil
                                                                andRelationType:nil];
            }
                break;
                
            case USER_RELATION_TYPE_COMMEND:
            {
                CPDBModelContact *dbContact = [[[CPSystemEngine sharedInstance] dbManagement] getContactWithMobile:uiUserInfo.mobileNumber];
                if (dbContact)
                {
                    [uiUserInfo setFullName:dbContact.fullName];
                    [uiUserCommendArray addObject:uiUserInfo];
                }
            }
                break;
//            case USER_MANAGER_FANXER:
//            case USER_MANAGER_SYSTEM:
//            case USER_MANAGER_XIAOSHUANG:
//                [uiUserArray addObject:uiUserInfo];
//                [[[CPSystemEngine sharedInstance] msgManager] createConversationWithUser:uiUserInfo];
//                break;
            default:
            {
                if (uiUserInfo.coupleAccount)
                {
                    CPDBModelUserInfo *dbUserCouple = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiUserInfo.coupleAccount];
                    if (dbUserCouple)
                    {
                        [uiUserInfo setCoupleUserInfo:[ModelConvertUtils dbUserInfoToUi:dbUserCouple]];
                    }
                }
                [uiUserArray addObject:uiUserInfo];
            }
                break;
        }
    }
    [[CPUIModelManagement sharedInstance] setFriendArray:uiUserArray];
    [[CPSystemEngine sharedInstance] updateTagByUsers];

    [[CPUIModelManagement sharedInstance] setFriendCommendArray:uiUserCommendArray];
    CPLogInfo(@"uiUserCommendArray  is %@",uiUserCommendArray);
    [[CPSystemEngine sharedInstance] updateTagByUsersCommend];
    
    [self reInitContactsByCommendMobile];
}
-(void)initUserCommendList
{
    NSArray *allUserArray = [[[CPSystemEngine sharedInstance] dbManagement] findAllUserInfos];
    NSMutableArray *uiUserArray = [[NSMutableArray alloc] init];
    NSString *loginAccount = [[CPSystemEngine sharedInstance] getAccountName];
    for(CPDBModelUserInfo *dbUserInfo in allUserArray)
    {
        if ([dbUserInfo.type intValue]==USER_RELATION_TYPE_COMMEND) 
        {
            if (dbUserInfo.name&&loginAccount&&[dbUserInfo.name isEqualToString:loginAccount])
            {
                continue;
            }
            CPUIModelUserInfo *uiUserInfo = [ModelConvertUtils dbUserInfoToUi:dbUserInfo];
            CPDBModelContact *dbContact = [[[CPSystemEngine sharedInstance] dbManagement] getContactWithMobile:uiUserInfo.mobileNumber];
            if (dbContact)
            {
                [uiUserInfo setFullName:dbContact.fullName];
                [uiUserArray addObject:uiUserInfo];
            }
        }
    }
    [[CPUIModelManagement sharedInstance] setFriendCommendArray:uiUserArray];
    CPLogInfo(@"uiUserCommendArray count is %@",uiUserArray);
    [[CPSystemEngine sharedInstance] updateTagByUsersCommend];
    
    [self reInitContactsByCommendMobile];
}
-(void)addUserCommendListWithUserID:(NSNumber *)userID
{
    [self initUserCommendList];
}
-(void)deleteRelationWithUserName:(NSString *)userName
{
    if (!userName)
    {
        return;
    }
    [self getFriendsWithTimeStamp:[[[CPSystemEngine sharedInstance] accountModel] friTimeStamp]];
    [self getMyProfile];
    NSMutableArray *oldArray = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] friendArray]];
    for(CPUIModelUserInfo *uiUserInfo in oldArray)
    {
        if (uiUserInfo&&[userName isEqualToString:uiUserInfo.name])
        {
            [oldArray removeObject:uiUserInfo];
            break;
        }
    }
    [[CPUIModelManagement sharedInstance] setFriendArray:oldArray];
    [[CPSystemEngine sharedInstance] updateTagByUsers];
    [[CPSystemEngine sharedInstance] deleteUserRelationWithUserName:userName];
}
-(void)updateUserRelationWithUserName:(NSString *)userName relationType:(NSInteger)relationType
{
    if (!userName)
    {
        return;
    }
    CPDBModelUserInfo *dbUserInfo = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:userName];
    if (dbUserInfo)
    {
        //
    }
    NSMutableArray *oldArray = [[NSMutableArray alloc] initWithArray:[[CPUIModelManagement sharedInstance] friendArray]];
    for(CPUIModelUserInfo *uiUserInfo in oldArray)
    {
        if (uiUserInfo&&[userName isEqualToString:uiUserInfo.name])
        {
            [uiUserInfo setType:[NSNumber numberWithInt:relationType]];
            break;
        }
    }
    [[CPUIModelManagement sharedInstance] setFriendArray:oldArray];
    [[CPSystemEngine sharedInstance] updateTagByUsers];
    [[CPSystemEngine sharedInstance] updateUserRelationWithUserName:userName relationType:relationType];
}

-(void)getFriendsCommend
{
    [[[CPSystemEngine sharedInstance] httpEngine] getUsersKnowMeForModule:[self class]];
}
-(void)getFriendsWithTimeStamp:(NSString *)timeStamp
{
    CPLogInfo(@"----------------------%@",timeStamp);
    if (!timeStamp)
    {
        timeStamp = @"";
    }
    [[[CPSystemEngine sharedInstance] httpEngine] getMyFriendsForModule:[self class] withTimeStamp:timeStamp];
}
-(void)modifyFriendTypeWithCategory:(NSInteger) category andUserName:(NSString *)userName andInviteString:(NSString *)inviteString andCouldExpose:(BOOL)couldExpose
{
    [[[CPSystemEngine sharedInstance] httpEngine] addFriendForModule:[self class] 
                                                      friendCategory:category 
                                                        withUserName:userName 
                                                     andInviteString:inviteString 
                                                      andCouldExpose:[NSNumber numberWithBool:couldExpose]];
}
-(void)inviteFriendWithCategory:(NSInteger) category andMobile:(NSString *)mobile andCouldExpose:(BOOL)couldExpose
{
    [[[CPSystemEngine sharedInstance] httpEngine] inviteFriendForModule:[self class] 
                                                         friendCategory:category
                                                           withPhoneNum:mobile 
                                                           andPhoneArea:@"86"
                                                         andCouldExpose:[NSNumber numberWithBool:couldExpose]];
}
-(void)answerRequestWithReqID:(NSString *)reqID andFlag:(NSInteger)flag andContextObj:(NSObject *)contextObj
{
    [[[CPSystemEngine sharedInstance] httpEngine] answerRequestForModule:[self class] ofRequestId:reqID
                                                          withAcceptFlag:[NSNumber numberWithBool:flag] 
                                                           andContextObj:contextObj];
}
-(void)breakFriendRelationWithUserName:(NSString *)userName
{
    [[[CPSystemEngine sharedInstance] httpEngine] breakFriendRelationForModule:[self class] withUser:userName];
}
-(void)getFriendsMutualWithFriName:(NSString *)friUserName
{
    [[[CPSystemEngine sharedInstance] httpEngine] getMutualFriendsForModule:[self class] withUser:friUserName];
}

-(void)getFriendsCommendByResponseWithUsers:(NSArray *)usersInfoArray
{
    [[CPSystemEngine sharedInstance] initUserCommendListByOperationWithUsers:usersInfoArray];
//    NSMutableArray *frisArray = [[NSMutableArray alloc] init];
//    for(CPPTModelUserInfo *ptUserInfo in usersInfoArray)
//    {
//        [frisArray addObject:[ModelConvertUtils ptUserInfoToUI:ptUserInfo]];
//    }
//    [[CPUIModelManagement sharedInstance] setFriendCommendArray:frisArray];
//    [[CPSystemEngine sharedInstance] updateTagByUsersCommend];
}
-(void)getFriendsByResponseWithUsers:(NSArray *)usersInfoArray
{
    [[CPSystemEngine sharedInstance] initUserListByOperationWithUsers:usersInfoArray];
//    NSMutableArray *frisArray = [[NSMutableArray alloc] init];
//    for(CPPTModelUserInfo *ptUserInfo in usersInfoArray)
//    {
//        [frisArray addObject:[ModelConvertUtils ptUserInfoToUI:ptUserInfo]];
//    }
    //
}
-(void)getFriendsMutualByResponseWithUsers:(NSArray *)usersInfoArray
{
    
}
-(void)getUserWithMobiles:(NSArray *)mobileArray
{
    CPPTModelContactWayList *ptContactWayList = [[CPPTModelContactWayList alloc] init];
    NSMutableArray *contactWays = [[NSMutableArray alloc] init];
    for(NSString *mobileNumber in mobileArray)
    {
        CPPTModelContactWay *ptContactWay = [[CPPTModelContactWay alloc] init];
        [ptContactWay setPhoneNum:mobileNumber];
        [ptContactWay setPhoneArea:@"86"];
        [contactWays addObject:ptContactWay];
    }
    [ptContactWayList setContactWayList:contactWays];
    [[[CPSystemEngine sharedInstance] httpEngine] getUsersByPhonesForModule:[self class] withContactWayList:ptContactWayList];
}
#pragma mark profile's api
-(void)getMyProfile
{
    CPLGModelAccount *cacheAccountModel = [[CPSystemEngine sharedInstance] accountModel];
    if (!cacheAccountModel.hasSavePersonalInfoName||[cacheAccountModel.hasSavePersonalInfoName boolValue])
    {
        [[[CPSystemEngine sharedInstance] httpEngine] getMyProfileForModule:[self class] 
                                                              withTimeStamp:[[[CPSystemEngine sharedInstance] accountModel] myProfileTimeStamp]];
    }
}
-(void)getUserProfileWithUserName:(NSString *)userName
{
//    if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
    {
        [[[CPSystemEngine sharedInstance] httpEngine] getUSerProfileForModule:[self class] ofUser:userName withTimeStamp:nil];
    }
}
-(void)getMyRecentInfo
{
    [[[CPSystemEngine sharedInstance] httpEngine] getMyRecentForModule:[self class]];
}
-(void)updateMyRecentInfoWithContent:(NSString *)content andType:(NSInteger)type
{
    [[[CPSystemEngine sharedInstance] httpEngine] updateRecentForModule:[self class] 
                                                            withContent:content 
                                                         andContentType:[NSNumber numberWithInt:type]];
}
-(void)getUserRecentWithUserName:(NSString *)userName
{
//    if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
    {
        [[[CPSystemEngine sharedInstance] httpEngine] getUserRecentForModule:[self class] ofUserName:userName];
    }
}
-(void)removeBaby
{
    [[[CPSystemEngine sharedInstance] httpEngine] removeBabyForModule:[self class]];
}
-(void)setSingleTimeWithDate:(NSDate *)singleTime andRelationType:(NSNumber *)relationType
{
    if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
    [[[CPSystemEngine sharedInstance] httpEngine] updateRelationTimeForModule:[self class]
                                                             withRelationType:relationType
                                                                      andTime:[CoreUtils getStringFormatWithDate:singleTime]];
}
-(void)updatePersonalWithNickName:(NSString *)nickName andSex:(NSNumber *)sex andHiddenBaby:(NSNumber *)isHiddenBaby
{
    if ([[CPSystemEngine sharedInstance] sysStatusCode]==SYS_STATUS_ONLINE)
    [[[CPSystemEngine sharedInstance] httpEngine] updateMyNicknameAndGenderForModule:[self class]
                                                                        withNickname:nickName
                                                                           andGender:sex
                                                                         andHideBaby:isHiddenBaby];
}
#pragma mark handle methods
- (void) handleGetUsersKnowMeResult:(NSNumber *)resultCode withObject:(NSObject *)obj
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (obj&&[obj isKindOfClass:[CPPTModelUserInfos class]])
        {
            CPPTModelUserInfos *userInfos = (CPPTModelUserInfos *)obj;
            if (userInfos.userInfoList&&[userInfos.userInfoList count]>0)
            {
                [self getFriendsCommendByResponseWithUsers:userInfos.userInfoList];
            }
        }
    }
}
- (void) handleGetMyFriendsResult:(NSNumber *)resultCode withObject:(NSObject *)obj  andTimeStamp:(NSString *)timeStamp
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (timeStamp&&![@"" isEqualToString:timeStamp])
        {
            [[CPSystemEngine sharedInstance] setCachedMyFriendTimeStamp:timeStamp];
        }
        if (obj&&[obj isKindOfClass:[CPPTModelUserInfos class]])
        {
            CPPTModelUserInfos *userInfos = (CPPTModelUserInfos *)obj;
            if (userInfos.userInfoList&&[userInfos.userInfoList count]>0)
            {
                [self getFriendsByResponseWithUsers:userInfos.userInfoList];
            }
            else 
            {
                NSString *responseActionUserName = [[[CPSystemEngine sharedInstance] userManager] responseActionUserName];
                if (responseActionUserName)
                {
                    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
                    [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:response_action_res_code];
                    [resDic setObject:@"服务器正在开小差，请退出应用重试" forKey:response_action_res_desc];
                    [[CPSystemEngine sharedInstance] updateTagByResponseActionWithDic:resDic];
                    [[[CPSystemEngine sharedInstance] userManager] setResponseActionUserName:nil];
                }
            }
        }
    }
}
- (void) handleRelationModifiedWithUserName:(NSString *)uName andCategory:(NSNumber *)category;
{
    if (uName &&category){
        CPDBModelUserInfo* dbModelUserInfo = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uName];
        if (dbModelUserInfo){
            NSInteger newRelationType = 0;
            switch ([category integerValue])
            {
                case K_FRIEND_CATEGORY_NORMAL://好友
                    newRelationType = USER_RELATION_TYPE_COMMON;
                    break;
                case K_FRIEND_CATEGORY_CLOSER://密友
                    newRelationType = USER_RELATION_TYPE_CLOSED;
                    break;
//                case K_FRIEND_CATEGORY_LOVER://情侣
//                    newRelationType = USER_RELATION_TYPE_COUPLE;
                    break;
                default:
                    break;
            }
            
            if (newRelationType > 0 ){
                [dbModelUserInfo setType:[NSNumber numberWithInt:newRelationType]];
                
                CPUIModelUserInfo* uiModelUserInfo = [ModelConvertUtils dbUserInfoToUi:dbModelUserInfo];
                [[[CPSystemEngine sharedInstance] userManager] refreshUserInfosCachedUiWithUser:dbModelUserInfo];
                [[[CPSystemEngine sharedInstance] msgManager] createNewConversationWithUser:uiModelUserInfo];
                //[[[CPSystemEngine sharedInstance] msgManager] createConversationWithUser:uiModelUserInfo];
            }
        }
    }
}
- (void) handleAddFriendResult:(NSNumber *)resultCode withUserName:(NSString *)uName andCategory:(NSNumber *)category;
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:modify_friend_dic_res_code];
        [resDic setObject:uName forKey:modify_friend_dic_user_name];
        [self handleRelationModifiedWithUserName:uName andCategory:category];
        //重新获取好友列表
        //[[[CPSystemEngine sharedInstance] sysManager] getFriendsByTimeStampCached];
        [[[CPSystemEngine sharedInstance] userManager] getFriendsWithTimeStamp:[[[CPSystemEngine sharedInstance] accountModel] friTimeStamp]];
        [[[CPSystemEngine sharedInstance] userManager] getMyProfile];

//        [[[CPSystemEngine sharedInstance] userManager] getMyProfile];
        
//        [[[CPSystemEngine sharedInstance] msgManager] sendAutoMsgByFriendApplyWithUserName:uName
//                                                                              andApplyType:[category integerValue]];
        //如果是另一半或者夫妻，会把成功的操作纪录下来
        NSInteger relationType = [category integerValue];
        NSInteger newRelationType = 0;
        switch (relationType)
        {
            case K_FRIEND_CATEGORY_LOVER://情侣
                newRelationType = USER_RELATION_COUPLE;
                break;
            case K_FRIEND_CATEGORY_CRUSH://喜欢
                newRelationType = USER_RELATION_LOVER;
                break;
            case K_FRIEND_CATEGORY_COUPLE://夫妻
                newRelationType = USER_RELATION_MARRIED;
                break;
            default:
                break;
        }
        if (newRelationType>0&&uName)
        {
            CPUIModelUserInfo *uiUserInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:uName];
            if (!uiUserInfo.nickName)
            {
                uiUserInfo = [[CPUIModelManagement sharedInstance] getCommendUserInfoWithUserName:uName];
            }
            if (uiUserInfo.nickName)
            {
                [[CPSystemEngine sharedInstance] backupSystemInfoWithCoupleName:uiUserInfo.nickName 
                                                              andCoupleUserName:uiUserInfo.name 
                                                                andRelationType:[NSNumber numberWithInt:newRelationType]];
            }
            else 
            {
                [[CPSystemEngine sharedInstance] backupSystemInfoWithCoupleName:uName 
                                                              andCoupleUserName:uName 
                                                                andRelationType:[NSNumber numberWithInt:newRelationType]];
            }
        }
    }
    else
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:modify_friend_dic_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:modify_friend_dic_res_desc];
    }
    if (uName)
    {
        [resDic setObject:uName forKey:modify_friend_dic_user_name];
    }
    [[CPSystemEngine sharedInstance] updateTagByModifyFriWithDic:resDic];
}
- (void) handleInviteFriendResult:(NSNumber *)resultCode 
                       withObject:(NSObject *)obj 
                      andPhoneNum:(NSString *)phoneNum 
                      andCategory:(NSNumber *)category
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        //如果是另一半或者夫妻，会把成功的操作纪录下来
        NSInteger relationType = [category integerValue];
        NSInteger newRelationType = 0;
        switch (relationType)
        {
            case K_FRIEND_CATEGORY_LOVER://情侣
                newRelationType = USER_RELATION_COUPLE;
                break;
            case K_FRIEND_CATEGORY_CRUSH://喜欢
                newRelationType = USER_RELATION_LOVER;
                break;
            case K_FRIEND_CATEGORY_COUPLE://夫妻
                newRelationType = USER_RELATION_MARRIED;
                break;
            default:
                break;
        }
        if (newRelationType>0&&phoneNum)
        {
            CPDBModelContact *contactModel = [[[CPSystemEngine sharedInstance] dbManagement] getContactWithMobile:phoneNum];
            if (contactModel.fullName)
            {
                [[CPSystemEngine sharedInstance] backupSystemInfoWithCoupleName:contactModel.fullName 
                                                              andCoupleUserName:phoneNum 
                                                                andRelationType:[NSNumber numberWithInt:newRelationType]];
            }
        }
    }
}
- (void) handleAnswerRequestResult:(NSNumber *)resultCode withAcceptFlag:(NSNumber *)acceptFlag andContextObject:(NSObject *)ctxObj
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (ctxObj&&[ctxObj isKindOfClass:[CPUIModelMessage class]])
        {
            [[CPSystemEngine sharedInstance] responseActionSysMsgByOperationWithMsg:(CPUIModelMessage *)ctxObj
                                                                      andActionType:[acceptFlag integerValue]];
        }

        [[[CPSystemEngine sharedInstance] sysManager] getFriendsByTimeStampCached];
    }
    else 
    {
        [resDic setObject:resultCode forKey:response_action_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:response_action_res_desc];
        [[CPSystemEngine sharedInstance] updateTagByResponseActionWithDic:resDic];
    }
}
- (void) handleBreakFriendRelationResult:(NSNumber *)resultCode withUserName:(NSString *)uName
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        //如果成功则不用修改标记
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:delete_friend_dic_res_code];
        if (uName)
        {
            [resDic setObject:uName forKey:delete_friend_dic_user_name];
            [self deleteRelationWithUserName:uName];
        }
    }
    else 
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:delete_friend_dic_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:delete_friend_dic_res_desc];
        if (uName)
        {
            [resDic setObject:uName forKey:delete_friend_dic_user_name];
        }
    }    
    [[CPSystemEngine sharedInstance] updateTagByDeleteFriendsWithDic:resDic];
}
- (void) handleGetMutualFriendsResult:(NSNumber *)resultCode forUser:(NSString *)uName withObject:(NSObject *)obj
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:find_friend_mutual_res_code];
        if (obj&&[obj isKindOfClass:[CPPTModelUserInfos class]])
        {
            CPPTModelUserInfos *userInfos = (CPPTModelUserInfos *)obj;
            if (userInfos.userInfoList&&[userInfos.userInfoList count]>0)
            {
                NSMutableArray *usersArray = [[NSMutableArray alloc] init];
                for(CPPTModelUserInfo *ptUserInfo in userInfos.userInfoList)
                {
                    CPDBModelUserInfo *dbUserInfo = [ModelConvertUtils ptUserInfoToDb:ptUserInfo];
                    if (dbUserInfo.name)
                    {
                        CPUIModelUserInfo *uiUserInfoCached = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:dbUserInfo.name];
                        //[[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:dbUserInfo.name];
                        if (uiUserInfoCached)
                        {
                            [usersArray addObject:uiUserInfoCached];
                        }
                    }
                }
                [resDic setObject:usersArray forKey:find_friend_mutual_data];
            }
        }
    }
    else 
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:find_friend_mutual_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:find_friend_mutual_res_desc];
    }
    if (uName)
    {
        [resDic setObject:uName forKey:find_friend_mutual_user_name];
    }
    [[CPSystemEngine sharedInstance] updateTagByFindMutualUsersWithDic:resDic];
}

- (void) handleGetUsersByPhonesResult:(NSNumber *)resultCode withObject:(NSObject *)obj
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:find_mobile_is_user_res_code];
        if (obj&&[obj isKindOfClass:[CPPTModelGetUsersResultList class]])
        {
            CPPTModelGetUsersResultList *ptUserInfos = (CPPTModelGetUsersResultList *)obj;
            NSMutableArray *dataIsUserArray = [[NSMutableArray alloc] init];
            for(CPPTModelGetUsersResult *ptUserInfo in ptUserInfos.resutlList)
            {
                NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
                if (ptUserInfo.phNum)
                {
                    [dicData setObject:ptUserInfo.phNum forKey:find_mobile_is_user_mobiles];
                }
                if (ptUserInfo.uName)
                {
                    [dicData setObject:ptUserInfo.uName forKey:find_mobile_is_user_uname];
                }
                [dataIsUserArray addObject:dicData];
            }
            [resDic setObject:dataIsUserArray forKey:find_mobile_is_user_data];
        }
    }
    else 
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:find_mobile_is_user_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:find_mobile_is_user_res_desc];
    }
    [[CPSystemEngine sharedInstance] updateTagByFindMobileIsUserWithDic:resDic];
}
#pragma mark profile handle method
- (void)handleGetMyFrofileResult:(NSNumber *)resultCode withObject:(NSObject *)obj andTimeStamp:(NSString *)timeStamp
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (obj&&[obj isKindOfClass:[CPPTModelUserProfile class]])
        {
            [[CPSystemEngine sharedInstance] setCachedPersonalTimeStamp:timeStamp];
            [[CPSystemEngine sharedInstance] updatePersonalInfoByOperationWithObj:obj];
        }
    }
}
- (void)handleGetUserFrofileResult:(NSNumber *)resultCode ofUser:(NSString *)uName withObject:(NSObject *)obj andTimeStamp:(NSString *)timeStamp
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        if (obj&&[obj isKindOfClass:[CPPTModelUserProfile class]])
        {
            [[CPSystemEngine sharedInstance] updateUserInfoByOperationWithObj:obj andUserName:uName];
            
            NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
            if (uName)
            {
                [resDic setObject:uName forKey:get_friend_profile_user_name];
            }
            CPUIModelUserInfo *resUserInfo = [ModelConvertUtils ptUserProfileToUiUserInfo:(CPPTModelUserProfile*)obj];
            if (resUserInfo)
            {
                [resDic setObject:resUserInfo forKey:get_friend_profile_user_profile];
            }
            [[CPSystemEngine sharedInstance] updateTagByGetFriendProfileWithDic:resDic];
        }
    }
}
- (void)handleRemoveBabyResult:(NSNumber *)resultCode
{
    CPLogInfo(@"resultCode is %@",resultCode);
}
- (void)handleUpdateRecentResult:(NSNumber *)resultCode
{
    CPLogInfo(@"resultCode is %@",resultCode);
}

- (void)handleGetMyRecentResult:(NSNumber *)resultCode
                    withContent:(NSString *)content
                 andContentType:(NSNumber *)contentType
                  andCreateTime:(NSString *)createTime
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        CPDBModelPersonalInfoData *dbPersonalData = [[CPDBModelPersonalInfoData alloc] init];
        [dbPersonalData setUpdateTime:[CoreUtils getLongFormatWithDateString:createTime]];
        [dbPersonalData setDataType:contentType];
        [dbPersonalData setDataContent:content];
        [dbPersonalData setDataClassify:[NSNumber numberWithInt:DATA_CLASSIFY_RECENT]];
        [[CPSystemEngine sharedInstance] updatePersonalInfoDataByOperation:dbPersonalData];
    }
}

- (void)handleGetUserRecentResult:(NSNumber *)resultCode
                           ofUser:(NSString *)uName
                      withContent:(NSString *)content
                   andContentType:(NSNumber *)contentType
                    andCreateTime:(NSString *)createTime
{
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        CPDBModelUserInfoData *dbUserData = [[CPDBModelUserInfoData alloc] init];
        [dbUserData setUpdateTime:[CoreUtils getLongFormatWithDateString:createTime]];
        [dbUserData setDataType:contentType];
        [dbUserData setDataContent:content];
        [dbUserData setDataClassify:[NSNumber numberWithInt:DATA_CLASSIFY_RECENT]];
        [[CPSystemEngine sharedInstance] updateUserInfoDataByOperation:dbUserData andUserName:uName];
    }
}
- (void) handleUpdateMyNicknameAndGenderResult:(NSNumber *)resultCode
{
    CPLogInfo(@"resultCode is %@",resultCode);
    if (resultCode&&[resultCode intValue] == RES_CODE_SUCESS)
    {
        [[CPSystemEngine sharedInstance] backupSystemInfoWithHasSavePersonalName:[NSNumber numberWithBool:YES]];
    }
}
@end
