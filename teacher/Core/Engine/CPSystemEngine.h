//
//  CPSystemEngine.h
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbDataManagement.h"

#define coupleConfigDataFilename      @"coupleConfig01.xml"
#define coupleConfigAbFilename        @"coupleConfigAb01.xml"

#define coupleConfigAccount           @"account"
#define coupleConfigLoginName         @"loginName"
#define coupleConfigRegistered        @"isRegistered"
#define coupleConfigActived           @"isActived"
#define coupleConfigPassword          @"password"
#define coupleConfigPhoneNumber       @"phoneNumber"
#define coupleConfigQueryABTime       @"queryABTime"
#define coupleConfigVerifiedCode      @"isVerifiedCode"
#define coupleConfigCanUploadAb       @"canUploadAb"
#define coupleConfigUploadAbTime      @"uploadAbTime"
#define coupleConfigFrisTimeStamp     @"frisTimeStamp"
#define coupleConfigConverTimeStamp   @"converTimeStamp"
#define coupleConfigHasCommendUsers   @"hasCommendUsers"
#define myProfileGetTimeStamp         @"myProfileStamp"
#define myDeviceToken                 @"deviceToken"
#define myisUploadDeviceToken         @"isUploadDeviceToken" 
#define hasSavePersonalName           @"hasSavePersonalName"  
#define willCoupleNameCached          @"willCoupleName"
#define willCoupleUserNameCached      @"willCoupleUserName"
#define willCoupleRelationTypeCached  @"willRelationType"

#define OPERATION_QUEUE_DB_MAX_COUNT   1


#define SERVER_IMG_URL_PREFIX         @"http://192.168.50.0:9000"
typedef enum 
{
    RES_CODE_SUCESS = 0,
    RES_CODE_ERROR  = 1
}NetworkResponseCode;

@class CPMsgManager;
@class CPResManager;
@class CPPersonalManager;
@class CPUserManager;
@class CPSystemManager;
@class CPDBManagement;

@class CPHttpEngine;
@class CPXmppEngine;

@class CPDBModelResource;

@class CPLGModelAccount;
@class CPDBModelPersonalInfo;
@class CPUIModelMessage;
@class CPUIModelMessageGroup;
@class CPDBModelPersonalInfoData;
@class CPPetManager;
@class CPDBModelUserInfoData;
@class CPUIModelPersonalInfo;

@interface CPSystemEngine : NSObject<addressBookDelegate>
{
    NSOperationQueue *dbProcessingQueue;//数据库操作的多任务队列

    
    CPMsgManager *msgManager_;
    CPResManager *resManager_;
    CPPersonalManager *personalManager_;
    CPUserManager *userManager_;
    CPSystemManager *sysManager_;
    
    CPHttpEngine *httpEngine_;
    CPXmppEngine *xmppEngine_;
    
    CPDBManagement *dbManagement_;
    
    CPLGModelAccount *accountModel;
    NSDate *queryAbTime;//查询本地通讯录的时间
    NSData *deviceToken_;//
    __strong NSObject *activedAccountKey;
    
    CPDBModelPersonalInfo *dbPersonalInfo;
    
    CPPetManager *petManager_;
    
    NSString *cachedMyFriendTimeStamp_;
    NSString *cachedMyConverTimeStamp_;
    NSString *cachedPersonalTimeStamp_;
}

@property (strong,nonatomic) CPMsgManager *msgManager;
@property (strong,nonatomic) CPResManager *resManager;
@property (strong,nonatomic) CPPersonalManager *personalManager;
@property (strong,nonatomic) CPUserManager *userManager;
@property (strong,nonatomic) CPSystemManager *sysManager;

@property (strong,nonatomic) CPHttpEngine *httpEngine;
@property (strong,nonatomic) CPXmppEngine *xmppEngine;

@property (strong,nonatomic) CPDBManagement *dbManagement;

@property (strong,nonatomic) CPDBModelPersonalInfo *dbPersonalInfo;

@property (strong,nonatomic) CPPetManager *petManager;
@property (strong,nonatomic) NSData *deviceToken;
@property (nonatomic,strong,getter = accountModel) CPLGModelAccount *accountModel;
@property (nonatomic,strong,getter = queryAbTime) NSDate *queryAbTime;

@property (nonatomic,strong) NSString *cachedMyFriendTimeStamp;
@property (nonatomic,strong) NSString *cachedMyConverTimeStamp;
@property (nonatomic,strong) NSString *cachedPersonalTimeStamp;

+ (CPSystemEngine *) sharedInstance;

-(void)autoLogin;
-(void)clearCachedData;
-(void)closeConnection;
-(void)sysLogout;
-(void)uploadDeviceToken;
-(void)sysLogoutAndGotoLoginWithDesc:(NSString *)desc;

-(void)initSystem;
-(void)initAbData;
-(void)initAppDbData;
-(void)initAccountDbData;//
-(void)initLoginedData;
-(void)initSysPreInitData;
-(void)initSysPreInitData_V;
-(void)initPersonalData:(CPDBModelPersonalInfo *)dbPersonal;
-(void)initPersonalDataMainThread:(CPDBModelPersonalInfo *)dbPersonal;

-(void)xmppReconnect;
-(BOOL)hasLoginUser;

-(NSString *)getAccountName;

-(NSInteger)sysStatusCode;

-(BOOL)importAddrBookToDataBase;

-(void)updateAccountModelWithName:(NSString *)account pwd:(NSString *)password;
-(void)setAccountModelWithAutoLogin:(BOOL)isAutoLogin;


-(void)clearAccountTagData;

-(void)updatePersonalInfoByOperation:(CPDBModelPersonalInfo *)dbPersonalInfo;
-(void)updatePersonalInfoByOperationWithObj:(NSObject *)personalInfoObj;
-(void)updatePersonalInfoDataByOperation:(CPDBModelPersonalInfoData *)personalInfoData;
-(void)updatePersonalInfoNameUiByOperation:(CPUIModelPersonalInfo *)personalInfo;
-(void)updatePersonalInfoBabyUiByOperation:(CPUIModelPersonalInfo *)personalInfo;
-(void)updatePersonalInfoSingleTimeUiByOperation:(CPUIModelPersonalInfo *)personalInfo;
-(void)updatePersonalInfoRecentUiByOperation:(CPUIModelPersonalInfo *)personalInfo;

-(void)updateUserInfoByOperationWithObj:(NSObject *)userInfoObj andUserName:(NSString *)userName;
-(void)updateUserInfoDataByOperation:(CPDBModelUserInfoData *)userInfoData andUserName:(NSString *)userName;

-(void)backupSystemInfoWithAccount:(CPLGModelAccount *)account;
-(void)backupSystemInfoWithAccountVerifiedCode:(NSNumber *)isVerifiedCode;
-(void)backupSystemInfoWithActived:(NSNumber *)isActived;
-(void)backupSystemInfoWithFrisTimeStamp:(NSString *)friTimeStamp;
-(void)backupSystemInfoWithConverTimeStamp:(NSString *)converTimeStamp;
-(void)backupSystemInfoWithMyProfileTimeStamp:(NSString *)timeStamp;
-(void)backupSystemInfoByQueryAbTime;
-(void)backupSystemInfoWithHasCommendUsers:(NSNumber *)hasCommendUsers;
-(void)backupSystemInfoWithAccountUploadAb;
-(void)backupSystemInfoWithIsUploadDeviceToken:(NSNumber *)isUpload;
-(void)backupSystemInfoWithDeviceToken:(NSString *)deviceToken;
-(void)backupSystemInfoWithHasSavePersonalName:(NSNumber *)hasSave;
-(void)backupSystemInfoWithPwd:(NSString *)pwd;
-(void)backupSystemInfoWithCoupleName:(NSString *)coupleName 
                    andCoupleUserName:(NSString *)coupleUserName 
                      andRelationType:(NSNumber *)relationType;

-(BOOL)writeToFileWithData:(NSData *)data file_name:(NSString *)fileName account:(NSString *)accountName file_type:(NSString *)fileType;

-(void)downloadResWithID:(NSNumber *)localResID andResCode:(NSNumber *)resCode andTimeStamp:(NSString *)timeStamp andTmpFilePath:(NSString *)filePath;
-(void)uploadResWithResID:(NSNumber *)localResID andResCode:(NSNumber *)resCode url:(NSString *)url andTimeStamp:(NSString *)timeStamp;
-(void)downloadWithRes:(CPDBModelResource *)dbRes;
-(void)uploadWithRes:(CPDBModelResource *)dbRes up_data:(NSData *)uploadData;
-(void)uploadAbByOperation;
-(void)initUserListByOperationWithUsers:(NSArray *)userArray;
-(void)initUserCommendListByOperationWithUsers:(NSArray *)userArray;
-(void)deleteUserRelationWithUserName:(NSString *)userName;
-(void)updateUserRelationWithUserName:(NSString *)userName relationType:(NSInteger)relationType;
-(void)sendMsgByOperationWithGroup:(CPUIModelMessageGroup *)uiMsgGroup andMsg:(CPUIModelMessage *)uiMsg;
-(void)sendMsgByOperationWithGroupID:(NSNumber *)msgGroupID andMsg:(CPUIModelMessage *)uiMsg;
-(void)reSendMsgByOperationWithMsg:(CPUIModelMessage *)uiMsg andMsgGroup:(CPUIModelMessageGroup *)msgGroup;
-(void)createConversationWithUsers:(NSArray *)userArray andMsgGroups:(NSArray *)msgGroups andType:(NSInteger)type;
-(void)updateConversationWithPtModels:(NSArray *)ptModels;
-(void)receiveMsgByOperationWithMsgs:(NSArray *)msgs;
//2014-7
-(void)receiveNoticeMsgByOperationWithNotices:(NSArray *)notices;
//
-(void)updateMsgSendResponseByOperationWithID:(NSNumber *)msgID andStatus:(NSNumber *)status;
-(void)removeWillSendMsgsByOperationWithIDs:(NSArray *)msgIDs;
-(void)createConversationByOperationWithObj:(NSObject *)obj;
-(void)createConversationSelfByOperationWithObj:(NSObject *)obj;
-(void)updateConversationMemByOperationWithObj:(NSObject *)obj;
-(void)updateConversationNameByOperationWithObj:(NSObject *)obj andGroupName:(NSString *)groupName;
-(void)upgradeConversationNameByOperationWithObj:(NSObject *)obj andGroupName:(NSString *)groupName;
-(void)removeConversationByOperationWithObj:(NSObject *)obj;
-(void)deleteMessageGroupByOperationWithObj:(NSObject *)obj;
-(void)getMsgListPagedByOperationWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;
-(void)addGroupMemsByOperationWithGroupServerID:(NSString *)groupServerID andUpdateNams:(NSArray *)updateNames;
-(void)removeGroupMemsByOperationWithGroupServerID:(NSString *)groupServerID andUpdateNams:(NSArray *)updateNames;
-(void)receiveSysMsgByOperationWithXmppMsgs:(NSArray *)xmppMsgs;
-(void)updateMsgByOperationWithMsg:(CPUIModelMessage *)uiMsg;
-(void)updateMsgAudioReadedByOperationWithMsg:(CPUIModelMessage *)uiMsg;
-(void)markMsgGroupReadedByOperationWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;
-(void)responseActionSysMsgByOperationWithMsg:(CPUIModelMessage *)uiMsg andActionType:(NSInteger)actionType;

-(void)downloadPetResWithContext:(NSObject *)contextObj;
//type:PetResDownloadType
-(void)downloadPetRes:(NSObject *)resOjb ofType:(NSInteger)dldType;
-(void)updatePetResourceDataWithResult:(NSNumber *)resultCode andResID:(NSString *)resID andObj:(NSObject *)obj;

-(BOOL)isSysOnline;


-(void)updateTagWithLoginResponseCode:(NSNumber *)code res_desc:(NSString *)desc;
-(void)updateTagWithRegResponseCode:(NSNumber *)code res_desc:(NSString *)desc;
-(void)updateTagWithAppStateCode:(NSNumber *)code res_desc:(NSString *)desc;
#ifdef SYS_STATE_MIGR
-(void)updateTagWithAccountSate:(NSNumber *)code res_desc:(NSString *)desc;
#endif
-(void)updateTagWithActiveResponseCode:(NSNumber *)code res_desc:(NSString *)desc;
-(void)updateTagWithBindResponseCode:(NSNumber *)code  res_desc:(NSString *)desc;
-(void)updateTagWithContacts:(NSArray *)contacts;
-(void)updateTagByUsers;
-(void)updateTagByUsersHeaderImgWithUserID:(NSNumber *)userID;
-(void)updateTagByCouple;
-(void)updateTagByUsersCommend;
-(void)updateTagByPersonalInfo;
-(void)updateTagByModifyFriWithDic:(NSDictionary *)dicData;
-(void)updateTagByResponseActionWithDic:(NSDictionary *)dicData;
-(void)updateTagByFindMobileIsUserWithDic:(NSDictionary *)dicData;
-(void)updateTagByGetFriendProfileWithDic:(NSDictionary *)dicData;
-(void)updateTagByGetTempResServerUrlWithDic:(NSDictionary *)dicData;
-(void)updateTagByFindMutualUsersWithDic:(NSDictionary *)dicData;
-(void)updateTagByDeleteFriendsWithDic:(NSDictionary *)dicData;
-(void)updateTagByMsgGroupList;
-(void)updateTagByMsgGroup;
-(void)updateTagByCoupleMsgGroup;
-(void)updateTagByCoupleMsgGroupData;
-(void)updateTagByCoupleMsgGroupMsgAppend;
-(void)updateTagByCoupleMsgGroupMsgInsert;
-(void)updateTagByCoupleMsgGroupMsgInsertEnd;
-(void)updateTagByCoupleMsgGroupMsgReload;
-(void)updateTagByCoupleMsgGroupMemList;
-(void)updateTagByMsgGroupData;
-(void)updateTagByMsgGroupDel;
-(void)updateTagByMsgGroupMsgAppend;
-(void)updateTagByMsgGroupMsgInsert;
-(void)updateTagByMsgGroupMsgInsertEnd;
-(void)updateTagByMsgGroupMsgReload;
-(void)updateTagByMsgGroupMemList;
-(void)updateTagByMsgGroupOnly;
-(void)updateTagByCreateMsgGroupWithCode:(NSNumber *)code;
-(void)updateTagBySysMsgList;
-(void)updateTagByAddGroupMemWithDic:(NSDictionary *)dicData;
-(void)updateTagByRemoveGroupMemWithDic:(NSDictionary *)dicData;
-(void)updateTagByQuitGroupWithDic:(NSDictionary *)dicData;
-(void)updateTagByAddFavoriteGroupWithDic:(NSDictionary *)dicData;
-(void)updateTagByModifyGroupNameWithDic:(NSDictionary *)dicData;
-(void)updateTagByFriendMsgUnReadedCount:(NSInteger )unReadedCount;
-(void)updateTagByCoupleMsgUnReadedCount:(NSInteger )unReadedCount;
-(void)updateTagByClosedMsgUnReadedCount:(NSInteger )unReadedCount;
-(void)updateTagByChangePwdWithDic:(NSDictionary *)dicData;
-(void)updateTagByResetPwdGetCodeWithDic:(NSDictionary *)dicData;
-(void)updateTagByResetPwdPostWithDic:(NSDictionary *)dicData;
-(void)updateTagByTipsNewMsgWithDic:(NSDictionary *)dicData;
-(void)updateTagByCheckUpdateWithDic:(NSDictionary *)dicData;
//2014-7
-(void)updateTagByNoticeMsg;
-(void)updateTagByFriendMsgUnReadedCount;
-(void)deleteNotifyMessageGroupByOperationWithObj:(NSObject *)obj;
-(void)updateUnreadedMessageStatusChanged:(NSObject *)obj;

-(void)updateTagForPetDataChange:(NSDictionary *)dict;
/********************add relationDel KVO by wang shuo*************************/
-(void)updateTagByUserRelationDel;
/********************add relationDel KVO by wang shuo*************************/
//-(void)updateTagForAddNewFeeling:(NSString *)resID;
//-(void)updateTagForUpdateFeeling:(NSString *)resID;
//-(void)updateTagForAddNewMagic:(NSString *)resID;
//-(void)updateTagForupdateMagic:(NSString *)resID;
-(void)updateSysOnlineStatus;
-(void)updateSysOfflineStatus;

@end
