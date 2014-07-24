//
//  CPDBManagement.h
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModelDefines.h"
#import "DBDaoDefines.h"

@interface CPDBManagement : NSObject
{
    NSArray *userList_;
    NSArray *msgGroupList_;
    NSArray *resList_;
    
    CPDAOBabyInfoData               *babyDAO;
    CPDAOMessage                    *msgDAO;
    CPDAOMessageGroup               *msgGroupDAO;
    CPDAOMessageGroupMember         *msgGroupMemberDAO;
    CPDAOPersonalInfo               *personalDAO;
    CPDAOPersonalInfoData           *personalDataDAO;
    CPDAOPersonalInfoDataAddition   *personalAdditionDAO;
    CPDAOResource                   *resDAO;
    CPDAOUserInfo                   *userDAO;
    CPDAOUserInfoData               *userInfoDAO;
    CPDAOUserInfoDataAddition       *userAdditionDAO;
    CPDAOContact                    *contactDAO;
    CPDAOContactWay                 *contactWayDAO;
    CPDAOPetInfo                    *petInfoDAO;
//notifyMessage change    
    CPDAONotifyMessage      *notifyMsgDAO;
//
    CPDataBaseManager               *dbManager;
    
    NSArray                         *contactArray_;
    NSDictionary             *userMobileArray_;
    NSDictionary             *resourceDictionary_;
    NSDictionary             *resourceCachedDicByServerID_;
    NSDictionary             *userInfoCachedDicByID_;
    NSDictionary             *userInfoCachedDicByAccount_;
    NSDictionary             *contactsCachedDicByMobile_;
    
    NSDictionary *msgGroupCachedByGroupID_;
    NSDictionary *msgGroupCachedByGroupServerID_;//只缓存属于群聊的
    NSDictionary *msgGroupCachedByUserName_;//只缓存单聊的
    
    NSMutableDictionary             *_petInfos;
    NSMutableDictionary             *_petDatas;
    
    BOOL                            isInited;
}
@property (nonatomic,assign) BOOL isInited;
@property (strong,nonatomic) NSArray *userList;
@property (strong,nonatomic) NSArray *msgGroupList;
@property (strong,nonatomic) NSArray *resList;

@property (strong,nonatomic) NSArray *contactArray;
@property (strong,nonatomic) NSDictionary *userMobileArray;
@property (strong,nonatomic) NSDictionary *resourceDictionary;
@property (strong,nonatomic) NSDictionary *resourceCachedDicByServerID;
@property (strong,nonatomic) NSDictionary *userInfoCachedDicByID;
@property (strong,nonatomic) NSDictionary *userInfoCachedDicByAccount;
@property (strong,nonatomic) NSDictionary *contactsCachedDicByMobile;
@property (strong,nonatomic) NSDictionary *msgGroupCachedByGroupID;
@property (strong,nonatomic) NSDictionary *msgGroupCachedByGroupServerID;
@property (strong,nonatomic) NSDictionary *msgGroupCachedByUserName;

@property (strong, nonatomic) NSMutableDictionary *petInfos;
@property (strong, nonatomic) NSMutableDictionary *petDatas;

-(NSArray *)findallContactsCachedWithUpdateTime:(NSNumber *)updateTime;


-(void)dbBeginTransaction;
-(void)dbCommit;
-(void)initializeWithLoginName:(NSString *)loginName;

-(void)dbBeginTransactionAbDb;
-(void)dbCommitAbDb;

-(void)clearDbCache;
-(void)closeAccountDB;


-(NSNumber *)insertContact:(CPDBModelContact *)dbContact;
-(NSArray *)findAllContactsWithUpdate:(NSNumber *)updateDate;
-(CPDBModelContact *)getContactWithMobile:(NSString *)mobile;

-(NSNumber *)insertBabyInfoData:(CPDBModelBabyInfoData *)dbBabyInfoData;
-(void)updateBabyInfoDataWithID:(NSNumber *)objID  obj:(CPDBModelBabyInfoData *)dbBabyInfoData;
-(CPDBModelBabyInfoData *)findBabyInfoDataWithID:(NSNumber *)id;
-(NSArray *)findAllBabyInfoDatas;

-(NSNumber *)insertMessageGroupByMemberList:(CPDBModelMessageGroup *)dbMessageGroup;
-(NSNumber *)insertMessage:(CPDBModelMessage *)dbMessage;
-(void)updateMessageWithID:(NSNumber *)objID  obj:(CPDBModelMessage *)dbMessage;
-(void)updateMessageWithGroupID:(NSNumber *)groupID andGroupServerID:(NSString *)groupServerID;
-(void)updateMessageWithGroupID:(NSNumber *)groupID andSendName:(NSString *)sendName;
-(CPDBModelMessage *)findMessageWithID:(NSNumber *)id;
-(NSArray *)findAllMessages;
-(NSArray *)findAllMessagesWithGroupID:(NSNumber *)msgGroupID;
-(void)updateMessageWithID:(NSNumber *)msgID andStatus:(NSNumber *)status;
-(void)resetMessageStateBySentError;
-(NSArray *)findMsgListByPageWithGroupID:(NSNumber *)msgGroupID last_msg_time:(NSNumber *)lastMsgTime max_msg_count:(NSInteger)maxMsgCount;
-(NSArray *)findMsgListByPageWithGroupID:(NSNumber *)msgGroupID max_msg_count:(NSInteger)maxMsgCount;
-(NSArray *)findMsgListByNewestTimeWithGroupID:(NSNumber *)msgGroupID newest_msg_time:(NSNumber *)newestMsgTime;
-(CPDBModelMessage *)findMessageWithSendID:(NSString *)sendName andContentType:(NSNumber *)contentType;


-(NSNumber *)insertMessageGroup:(CPDBModelMessageGroup *)dbMessageGroup;
-(void)updateMessageGroupWithID:(NSNumber *)objID  obj:(CPDBModelMessageGroup *)dbMessageGroup;
-(CPDBModelMessageGroup *)findMessageGroupWithID:(NSNumber *)id;
-(CPDBModelMessageGroup *)findMessageGroupWithServerID:(NSString *)serverID;
-(CPDBModelMessageGroup *)findMessageGroupWithCreatorName:(NSString *)creatorName;
-(NSArray *)findAllMessageGroups;
-(CPDBModelMessageGroup *)getExistMsgGroupWithUserName:(NSString *)userName;
-(CPDBModelMessageGroup *)getExistMsgGroupDbWithUserName:(NSString *)userName;
-(CPDBModelMessageGroup *)getExistMsgGroupWithUserNames:(NSArray *)userNames;
-(CPDBModelMessageGroup *)getExistMsgGroupWithGroupServerID:(NSString *)serverID;
-(CPDBModelMessageGroup *)getExistMsgGroupWithGroupID:(NSNumber *)msgGroupID;
-(void)updateMessageGroupWithID:(NSString *)serverID  andGroupName:(NSString *)name;
-(void)updateMessageGroupUnReadedCountWithID:(NSNumber *)msgGroupID andCount:(NSNumber *)unReadedCount;
-(void)updateMessageGroupWithID:(NSNumber *)msgGroupID  andGroupType:(NSNumber *)type;
-(void)deleteGroupWithID:(NSNumber *)msgGroupID;
-(void)deleteGroupMsgsWithID:(NSNumber *)msgGroupID;
-(NSArray *)findAllMessageConverGroup;
-(void)markMsgReadedWithGroupID:(NSNumber *)msgGroupID;
-(void)updateUpdateTimeWithGroupID:(NSNumber *)msgGroupID andNewstTime:(NSNumber *)newstTime;
-(void)updateNewestMsgWithGroupID:(NSNumber *)msgGroupID andNewstTime:(NSNumber *)newstTime;
-(void)markReadedWithMsg:(CPDBModelMessage *)dbMsg;


-(NSNumber *)insertMessageGroupMember:(CPDBModelMessageGroupMember *)dbMessageGroupMember;
-(void)updateMessageGroupMemberWithID:(NSNumber *)objID  obj:(CPDBModelMessageGroupMember *)dbMessageGroupMember;
-(CPDBModelMessageGroupMember *)findMessageGroupMemberWithID:(NSNumber *)id;
-(NSArray *)findAllMessageGroupMembers;
-(NSArray *)findAllMessageGroupMembersWithGroupID:(NSNumber *)msgGroupID;
-(void)addMsgGroupCachedWithGroup:(CPDBModelMessageGroup *)dbMsgGroup;
-(void)deleteAllGroupMemsWithGroupID:(NSNumber *)msgGroupID;
-(void)deleteGroupMemWithMemName:(NSString *)memName andGroupID:(NSNumber *)msgGroupID;

-(NSNumber *)insertPersonalInfo:(CPDBModelPersonalInfo *)dbPersonalInfo;
-(void)updatePersonalInfoWithID:(NSNumber *)objID  obj:(CPDBModelPersonalInfo *)dbPersonalInfo;
-(CPDBModelPersonalInfo *)findPersonalInfoWithID:(NSNumber *)id;
-(NSArray *)findAllPersonalInfos;
-(CPDBModelPersonalInfo *)findPersonalInfo;
-(void)deletePersonalInfos;
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andName:(NSString *)nickName andSex:(NSNumber *)sex andHiddenBaby:(NSNumber *)isHiddenBaby;
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andName:(NSString *)nickName andSex:(NSNumber *)sex andLifeStatus:(NSNumber *)lifeStatus;
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andSingleTime:(NSNumber *)singleTime;
-(void)updatePersonalInfoWithID:(NSNumber *)objID  andHasBaby:(NSNumber *)hasBaby;

-(NSNumber *)insertPersonalInfoData:(CPDBModelPersonalInfoData *)dbPersonalInfoData;
-(void)updatePersonalInfoDataWithID:(NSNumber *)objID  obj:(CPDBModelPersonalInfoData *)dbPersonalInfoData;
-(CPDBModelPersonalInfoData *)findPersonalInfoDataWithID:(NSNumber *)id;
-(NSArray *)findAllPersonalInfoDatas;
-(CPDBModelPersonalInfoData *)findPersonalInfoDataWithPersonalID:(NSNumber *)personalID andClassify:(NSNumber *)classify;

-(NSNumber *)insertPersonalInfoDataAddition:(CPDBModelPersonalInfoDataAddition *)dbPersonalInfoDataAddition;
-(void)updatePersonalInfoDataAdditionWithID:(NSNumber *)objID  obj:(CPDBModelPersonalInfoDataAddition *)dbPersonalInfoDataAddition;
-(CPDBModelPersonalInfoDataAddition *)findPersonalInfoDataAdditionWithID:(NSNumber *)id;
-(NSArray *)findAllPersonalInfoDataAdditions;

-(NSNumber *)insertResource:(CPDBModelResource *)dbResource;
-(CPDBModelResource *)findResourceWithServerUrl:(NSString *)serverUrl;
-(void)updateResourceWithID:(NSNumber *)objID  obj:(CPDBModelResource *)dbResource;
-(CPDBModelResource *)findResourceWithID:(NSNumber *)id;
-(NSArray *)findAllResources;
-(NSArray *)findAllResourcesWillDownload;
-(NSArray *)findAllResourcesWillUpload;
-(CPDBModelResource *)getResWithID:(NSNumber *)resID;
-(CPDBModelResource *)getResCachedWithID:(NSNumber *)resID;
-(CPDBModelResource *)getResCachedWithServerID:(NSString *)serverUrl;
-(CPDBModelResource *)findResourceVideoThumbImgWithObjID:(NSNumber *)objID;
-(void)addResCachedWithRes:(CPDBModelResource *)dbRes;
-(void)initResources;
-(void)updateResourceDownloadedWithID:(NSNumber *)objID;
-(void)updateResourceUpdateTimeWithID:(NSNumber *)objID andTime:(NSNumber *)updateTime;
-(void)updateResourceWillDownloadWithID:(NSNumber *)objID;
-(void)updateResourceUploadedWithID:(NSNumber *)objID;
-(void)updateResourceWithID:(NSNumber *)objID url:(NSString *)url;
-(void)updateResourceObjIDWithResID:(NSNumber *)resID obj_id:(NSNumber *)objID;

-(NSNumber *)insertUserInfo:(CPDBModelUserInfo *)dbUserInfo;
-(void)updateUserInfoWithID:(NSNumber *)objID  obj:(CPDBModelUserInfo *)dbUserInfo;
-(CPDBModelUserInfo *)findUserInfoWithID:(NSNumber *)id;
-(NSArray *)findAllUserInfos;
-(NSArray *)findAllUserCommendInfos;
-(void)initUsersWithUserArray:(NSArray *)userArray andAccountName:(NSString *)accountName;
-(void)initUsersCommendWithUserArray:(NSArray *)userArray andAccountName:(NSString *)accountName;
-(CPDBModelUserInfo *)findUserInfoWithAccount:(NSString *)account;
-(void)deleteRelationWithUserAccount:(NSString *)accountName;
-(void)deleteUserWithAccount:(NSString *)accountName;
-(void)deleteAllUserInfos;
-(void)deleteFriendUserInfos;
-(void)deleteUserInfoWithAccount:(NSString *)account;
-(void)addRelationWithUserAccount:(NSString *)userAccount relation_account:(NSString *)relationAccount relation_type:(NSInteger)type;
-(CPDBModelUserInfo *)getUserInfoByCachedWithID:(NSNumber *)userID;
-(CPDBModelUserInfo *)getUserInfoByCachedWithName:(NSString *)userName;
-(void)updateUserRelationWithUserName:(NSString *)accountName relationType:(NSNumber *)type;
-(void)refreshUserCachedWithUser:(CPDBModelUserInfo *)dbUserInfo;

-(NSNumber *)insertUserInfoData:(CPDBModelUserInfoData *)dbUserInfoData;
-(void)updateUserInfoDataWithID:(NSNumber *)objID  obj:(CPDBModelUserInfoData *)dbUserInfoData;
-(CPDBModelUserInfoData *)findUserInfoDataWithID:(NSNumber *)id;
-(NSArray *)findAllUserInfoDatas;
-(CPDBModelUserInfoData *)findUserInfoDataWithUserID:(NSNumber *)userID andClassify:(NSNumber *)classify;

-(NSNumber *)insertUserInfoDataAddition:(CPDBModelUserInfoDataAddition *)dbUserInfoDataAddition;
-(void)updateUserInfoDataAdditionWithID:(NSNumber *)objID  obj:(CPDBModelUserInfoDataAddition *)dbUserInfoDataAddition;
-(CPDBModelUserInfoDataAddition *)findUserInfoDataAdditionWithID:(NSNumber *)id;
-(NSArray *)findAllUserInfoDataAdditions;

-(NSArray *)findAllPetInfo;
-(NSArray *)findAllPetData;
- (CPDBModelPetInfo *)getPetInfo:(NSString *)petID;
- (CPDBModelPetData *)getPetData:(NSString *)resID;

- (NSNumber *)insertPetInfo:(CPDBModelPetInfo *)dbPetInfo;
- (NSNumber *)insertPetData:(CPDBModelPetData *)dbPetData;

- (void)updatePetInfoWithID:(NSNumber *)objID obj:(CPDBModelPetInfo *)dbPetInfo;
- (void)updatePetDataWithID:(NSNumber *)objID obj:(CPDBModelPetData *)dbPetData;

-(CPDBModelMessage *)findMessageWithResID:(NSNumber *)objID;

//notifyMessage change
-(NSNumber *)insertNotifyMessage:(CPDBModelNotifyMessage *)dbMessage;

-(NSArray *)findAllNewNotiyfMessages;

-(NSArray *)findNotifyMessagesOfCurrentFromJID:(NSString *)currentFromJID;
-(NSInteger)allNotiUnreadedMessageCount;
//-(NSNumber *)insertUrlsWithUrl:(NSString *)url andNotifyMessageID : (NSNumber *)notifyMsgID;
@end
