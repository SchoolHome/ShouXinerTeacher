//
//  CPUIModelManagement.h
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    message_view_Status_up = 1,
    message_view_Status_Middle = 2,
    message_view_Status_Down = 3
}ViewStatus;

typedef enum
{
    IM_Chat_Type_Single = 1,
    IM_Chat_Type_Group = 2,
    IM_Chat_Type_Couple = 3
}IM_Chat_Type;

typedef enum
{
    SYS_STATUS_OFFLINE = 0,
    SYS_STATUS_ONLINE = 1,
    SYS_STATUS_LOGING = 2,   
    SYS_STATUS_NO_ACTIVE = 3,//登录过，但是未激活,到验证页面
    SYS_STATUS_NO_LOGINED = 4,//从未登录过，直接到登录界面
    SYS_STATUS_HTTP_LOGINED = 5//
}SYS_STATUS;

#ifdef SYS_STATE_MIGR
enum
{
    ACCOUNT_STATE_INACTIVE = 1,
    ACCOUNT_STATE_NEVER_LOGIN = 2,
    ACCOUNT_STATE_ACTIVATED = 3,
}ACC_STATE;

typedef enum ACC_STATE ACCOUNT_STATE;
#endif

typedef enum
{
    RESPONSE_CODE_ACTIVE_SUCCESS = 0,
    RESPONSE_CODE_ACTIVE_ERROR = -1,
}ResponseCodeActive;
typedef enum
{
    RESPONSE_CODE_SUCESS = 0,
    RESPONSE_CODE_ERROR   = 1
}ResponseCode;
typedef enum
{
    FRIEND_CATEGORY_NORMAL = 1,//朋友
    FRIEND_CATEGORY_LOVER = 5,//喜欢
    FRIEND_CATEGORY_CLOSER = 3,//密友
    FRIEND_CATEGORY_COUPLE = 2,//情侣
    FRIEND_CATEGORY_MARRIED = 4,//夫妻
}UpdateFriendType;
typedef enum
{
    REQ_FLAG_REFUSE = 0,//拒绝
    REQ_FLAG_ACCEPT = 1//同意
}ResponseFriReqFlag;
typedef enum
{
    CREATE_CONVER_TYPE_COMMON = 1,//从好友墙发起的会话
    CREATE_CONVER_TYPE_CLOSED = 2,//从密友墙发起的会话
}CreateConversationType;
typedef enum
{
    UPDATE_USER_GROUP_TAG_DEFAULT = 0,//全部刷新
    UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND = 1,//消息列表中有新消息
    UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT = 2,//消息列表中获取到历史消息
    UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END = 3,//消息列表中再也获取不到历史消息
    UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD = 4,//重新刷新消息状态
    UPDATE_USER_GROUP_TAG_MEM_LIST = 5,//群成员有改动
    UPDATE_USER_GROUP_TAG_MSG_GROUP = 6,//群信息有改动
    UPDATE_USER_GROUP_TAG_ONLY_REFRESH = 7,//只需刷新即可
    UPDATE_USER_GROUP_TAG_DEL = 8,//当前的Group已被删除

}UpdateCurrentUserGroupTagType;
typedef enum
{
    UPDATE_FRIEND_ARRAY_TAG_DEFAULT = 0,//全部刷新
    UPDATE_FRIEND_ARRAY_TAG_HEADER = 1,//头像的图片下载完成
}UpdateFriendArrayTagType;
typedef enum
{
    PET_DATACHANGE_TYPE_ADD_RES = 1,    //说明对应的资源是新增的，resultcode标记成功或失败
    PET_DATACHANGE_TYPE_UPDATE_RES = 2, //说明对应的资源是更新的，resultcode标记成功或失败
    PET_DATACHANGE_TYPE_DOWNLOADING = 3,    //说明对应的资源正在下载，此时resultcode无效，不用考虑resultcode。
    PET_DATACHANGE_TYPE_REFRESH_ALL = 4,
    PET_DATACHANGE_TYPE_PETSYS_INITIALIZED = 5,    //键盘在收到此通知时需要重新刷新所有魔法表情和小表情。
}PetDataChangeType;

typedef enum
{
    PET_DATACHANGE_RESULT_FAIL = -1,
    PET_DATACHANGE_RESULT_SUC = 0,
}PetDataChangeResult;


#define modify_friend_dic_res_code      @"resCode"
#define modify_friend_dic_res_desc      @"resDesc"
#define modify_friend_dic_user_name     @"userName"

#define delete_friend_dic_res_code      @"resCode"
#define delete_friend_dic_res_desc      @"resDesc"
#define delete_friend_dic_user_name     @"userName"

#define find_mobile_is_user_res_code    @"resCode"
#define find_mobile_is_user_res_desc    @"resDesc"
#define find_mobile_is_user_mobiles     @"mobiles"
#define find_mobile_is_user_uname       @"uname"
#define find_mobile_is_user_data        @"data"

#define find_friend_mutual_res_code     @"resCode"
#define find_friend_mutual_res_desc     @"resDesc"
#define find_friend_mutual_data         @"mutualFris"
#define find_friend_mutual_user_name    @"userName"

#define response_action_res_code        @"resCode"
#define response_action_res_desc        @"resDesc"
#define response_action_msg_group       @"msgGroup"


#define group_manage_dic_res_code      @"resCode"
#define group_manage_dic_res_desc      @"resDesc"

#define get_friend_profile_res_code        @"resCode"
#define get_friend_profile_res_desc        @"resDesc"
#define get_friend_profile_user_profile    @"userProfile"
#define get_friend_profile_user_name       @"userName"

#define resource_server_url         @"serverUrl"

#define change_pwd_res_code             @"resCode"
#define change_pwd_res_desc             @"resDesc"

#define reset_pwd_get_code_res_code     @"resCode"
#define reset_pwd_get_code_res_desc     @"resDesc"

#define reset_pwd_post_res_code         @"resCode"
#define reset_pwd_post_res_desc         @"resDesc"

#define new_msg_tip_nick_name           @"nickName"
#define new_msg_tip_msg_text            @"msgText"
#define new_msg_tip_un_readed_count     @"unReadedCount"
#define new_msg_tip_msg_group_id        @"msgGroupID"
#define new_msg_tip_msg_group        @"msgGroup"

#define check_update_res_code           @"resCode"
#define check_update_subject            @"subject"
#define check_update_content            @"content"
#define check_update_version            @"version"
#define check_update_version_code       @"versionCode"
#define check_update_url                @"url"

//++++++++++++++++++++++++++++++++++++++++++++++++++++
//PetDataChangeType
#define pet_datachange_type             @"type"
//PetDataChangeResult
#define pet_datachange_result           @"resultCode"
//PetDataType
#define pet_datachange_category         @"category"
//宠物ID
#define pet_datachange_petid            @"petid"
//资源ID
#define pet_datachange_id               @"resid"
//-----------------------------------------------------


@class CPUIModelRegisterInfo;
@class CPUIModelPersonalInfo;
@class CPLGModelAccount;
@class CPUIModelUserInfo;
@class CPUIModelMessageGroup;
@class CPUIModelMessage;

@class CPUIModelPetActionAnim;
@class CPUIModelPetMagicAnim;
@class CPUIModelPetFeelingAnim;
@class CPUIModelPetSmallAnim;

@interface CPUIModelManagement : NSObject
{
    NSInteger registerCode;//0 成功 -1 显示默认的registerDesc信息
    NSString *registerDesc;//
    NSInteger loginCode;//0 成功 -1显示默认的loginDesc信息  
    NSString *loginDesc;//
    NSInteger activeCode;//激活手机号的返回值  0成功，否则直接显示desc的值
    NSString *activeDesc;//
    NSInteger bindCode;//0成功
    NSString *bindDesc;
    
    NSInteger sysOnlineStatus;//0离线；1登录成功；2登录中；3未激活
#ifdef SYS_STATE_MIGR
    NSInteger accountState;
#endif
    
    CPUIModelPersonalInfo *uiPersonalInfo;//缓存的当前用户信息
    NSInteger uiPersonalInfoTag;//当前用户信息的更新标记
    
    NSArray *contactArray;//缓存的本地联系人列表 CPUIModelContact-->CPUIModelContactWay
    NSInteger contactUpdateTag;//缓存的本地联系人是否有更新
    
    NSArray *friendCommendArray;//推荐的双双好友
    NSInteger friendCommendTag;//
    
    NSArray *friendArray;//好友列表-通过CPUIModelUserInfo中的type区分普通好友和密友等关系
    NSNumber *friendTag;
    
    NSArray *friendClosedArray;//密友列表
    NSInteger friendClosedTag;
    
    CPUIModelUserInfo *coupleModel;//couple数据
    NSInteger coupleTag;
    
    NSArray* userMessageGroupList;//会话的列表
    NSInteger userMsgGroupListTag;
	NSArray* systemMessageList;//系统消息列表
    NSInteger sysMsgListTag;
    CPUIModelMessageGroup *userMsgGroup;//当前显示的消息
    NSInteger userMsgGroupTag;
    NSInteger createMsgGroupTag;//发起新会话的标记
    NSString *createMsgGroupDesc;//发起会话失败的描述
    
    /********************add relationDel KVO by wang shuo*************************/
    NSInteger userRelationDelTag;
	NSArray *userRelationDelList;
    /********************add relationDel KVO by wang shuo*************************/
    
    CPUIModelMessageGroup *coupleMsgGroup;//couple的MsgGroup
    NSInteger coupleMsgGroupTag;
    
    NSDictionary *modifyFriendTypeDic;//修改好友关系之后的返回结果 key:modify_friend_dic_res_code/modify_friend_dic_user_name
    NSDictionary *findMobileIsUserDic;//查询手机号是否用户之后的结果 key:find_mobile_is_user_res_code/find_mobile_is_user_mobiles
    NSDictionary *findMutualFriendDic;//查询某个帐号的共同好友的结果 key:find_friend_mutual_res_code/find_friend_mutual_data
    NSDictionary *getFriendProfileDic;//查询某个帐号的profile的结果 key:get_friend_profile_res_code ...
    NSDictionary *resourceServerUrlDic;//即时获取某个server url的结果 key: resource_server_url...

    NSDictionary *deleteFriendDic;//删除好友之后的错误返回，如果成果则无变化 key：delete_friend_dic_res_desc/delete_friend_dic_user_name
    
    NSDictionary *responseActionDic;//对于好友请求回应的返回  response_action_res_code...
    
    //以下是群管理操作返回的信息，分别对应group_manage_dic_res_code，group_manage_dic_res_desc
    NSDictionary *addGroupMemDic;
    NSDictionary *removeGroupMemDic;
    NSDictionary *quitGroupDic;
    NSDictionary *addFavoriteGroupDic;
    NSDictionary *modifyGroupNameDic;
    
    NSInteger friendMsgUnReadedCount;//好友消息的未读数
    NSInteger coupleMsgUnReadedCount;//couple消息的未读数
    NSInteger closedMsgUnReadedCount;//密友消息的未读数

    NSDictionary *changePwdResDic;//修改密码的返回  key:change_pwd_res_code&change_pwd_res_desc
    NSDictionary *resetPwdGetCodeResDic;//重置密码第一步的返回 key:reset_pwd_get_code_res_code&reset_pwd_get_code_res_desc
    NSDictionary *resetPwdPostResDic;//重置密码第二步的返回 key:reset_pwd_post_res_code&reset_pwd_post_res_desc
    
    NSDictionary *tipsNewMsgDic;//新消息提示的数据 key new_msg_tip_nick_name,etc...
    
    NSDictionary *checkUpdateResponseDic;//查询更新返回的数据
    //宠物系统数据
    NSDictionary *petDataDict;
    
    
    NSDictionary *smallAnimDefaultImgDic;
    NSDictionary *smallAnimImgArrayDic;
    

}

@property (nonatomic,strong) NSDictionary *checkUpdateResponseDic;
@property (nonatomic,strong) NSDictionary *tipsNewMsgDic;
@property (nonatomic,strong) NSDictionary *changePwdResDic;
@property (nonatomic,strong) NSDictionary *resetPwdGetCodeResDic;
@property (nonatomic,strong) NSDictionary *resetPwdPostResDic;

@property (nonatomic,strong) NSDictionary *smallAnimDefaultImgDic;
@property (nonatomic,strong) NSDictionary *smallAnimImgArrayDic;


@property (nonatomic,assign) NSInteger registerCode;
@property (nonatomic,retain) NSString *registerDesc;
@property (nonatomic,assign) NSInteger loginCode;
@property (nonatomic,retain) NSString *loginDesc;
@property (nonatomic,assign) NSInteger activeCode;
@property (nonatomic,strong) NSString *activeDesc;
@property (nonatomic,assign) NSInteger bindCode;
@property (nonatomic,strong) NSString *bindDesc;

@property (nonatomic,assign) NSInteger sysOnlineStatus;
#ifdef SYS_STATE_MIGR
@property (nonatomic,assign) NSInteger accountState;
#endif

@property (nonatomic,strong) CPUIModelPersonalInfo *uiPersonalInfo;
@property (nonatomic,assign) NSInteger uiPersonalInfoTag;

@property (nonatomic,strong) NSArray *contactArray;
@property (nonatomic,assign) NSInteger contactUpdateTag;

@property (nonatomic,strong) NSArray *friendCommendArray;
@property (nonatomic,assign) NSInteger friendCommendTag;
@property (nonatomic,strong) NSArray *friendArray;
@property (nonatomic,strong) NSNumber *friendTag;
@property (nonatomic,strong) NSArray *friendClosedArray;
@property (nonatomic,assign) NSInteger friendClosedTag;
@property (nonatomic,strong) CPUIModelUserInfo *coupleModel;
@property (nonatomic,assign) NSInteger coupleTag;

@property (nonatomic,strong) NSDictionary *modifyFriendTypeDic;
@property (nonatomic,strong) NSDictionary *findMobileIsUserDic;
@property (nonatomic,strong) NSDictionary *findMutualFriendDic;
@property (nonatomic,strong) NSDictionary *responseActionDic;
@property (nonatomic,strong) NSDictionary *deleteFriendDic;
@property (nonatomic,strong) NSDictionary *getFriendProfileDic;
@property (nonatomic,strong) NSDictionary *resourceServerUrlDic;

@property (nonatomic,strong) NSArray* userMessageGroupList;
@property (nonatomic,assign) NSInteger userMsgGroupListTag;
@property (nonatomic,strong) NSArray* systemMessageList;
@property (nonatomic,assign) NSInteger sysMsgListTag;
@property (nonatomic,strong) CPUIModelMessageGroup *userMsgGroup;
@property (nonatomic,assign) NSInteger userMsgGroupTag;
@property (nonatomic,assign) NSInteger createMsgGroupTag;
@property (nonatomic,strong) NSString *createMsgGroupDesc;

@property (nonatomic,strong) CPUIModelMessageGroup *coupleMsgGroup;
@property (nonatomic,assign) NSInteger coupleMsgGroupTag;

@property (nonatomic,strong) NSDictionary *addGroupMemDic;
@property (nonatomic,strong) NSDictionary *removeGroupMemDic;
@property (nonatomic,strong) NSDictionary *quitGroupDic;
@property (nonatomic,strong) NSDictionary *addFavoriteGroupDic;
@property (nonatomic,strong) NSDictionary *modifyGroupNameDic;

@property (nonatomic, strong) NSDictionary *petDataDict;

@property (nonatomic,assign) NSInteger friendMsgUnReadedCount;
@property (nonatomic,assign) NSInteger coupleMsgUnReadedCount;
@property (nonatomic,assign) NSInteger closedMsgUnReadedCount;

/********************add relationDel KVO by wang shuo*************************/
@property (nonatomic,assign) NSInteger userRelationDelTag;
@property (nonatomic,strong) NSArray *userRelationDelList;
/********************add relationDel KVO by wang shuo*************************/
@property (nonatomic,strong) NSString *loginErrorMsg;
+ (CPUIModelManagement *) sharedInstance;

#pragma mark 系统相关
//判断当前的网络状态是否可用，仅在UI发起某些请求时候用到
-(BOOL) canConnectToNetwork;

//用户注册
-(void)registerWithRegInfo:(CPUIModelRegisterInfo *)regInfo;
//用户登录
-(void)loginWithName:(NSString *)loginName password:(NSString *)pwd;
//输入验证码激活app
-(void)activeAccountWithCode:(NSString *)code;
//重新绑定手机时候用的接口
-(void)bindMobileNumber:(NSString *)number region_number:(NSString *)regionNumber;
//清除上次登录或者注册成功的标记，在点击“重新注册”时候需要触发此方法
-(void)clearAccountTagData;

//获取当前的帐号信息
-(CPLGModelAccount *)getCurrentAccountModel;

//系统注销的操作
-(void)logout;

-(void)uploadDeviceToken:(NSData *)deviceToken;

//修改密码的API，需要旧密码和新密码
-(void)modifyUserPasswordWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd;

//重置密码时的第一步，根据用户名和手机号获取验证码
-(void)resetPasswordGetCodeWithUserName:(NSString *)userName andMobileNumber:(NSString *)mobileNumber;
//重置密码的第二步，需要用户名、手机号、新密码、验证码
-(void)resetPasswordPostWithUserName:(NSString *)userName 
                     andMobileNumber:(NSString *)mobileNumber 
                              andPwd:(NSString *)password
                       andVerifyCode:(NSString *)verifyCode;

//系统处于非激活状态的处理
-(void)sysInActive;
-(void)sysActive;

//根据server url获取本地资源的存储路径
-(NSString *)getFilePathWithServerUrl:(NSString *)serverUrl;

//根据文件路径获取资源的更新时间
-(NSNumber *)getUpdateTimeWithFilePath:(NSString *)filePath;

//收到新消息时，播放的声音效果
-(void)playSoundByReceiveNewMsg;
//播放完音频消息之后的效果
-(void)playSoundByPlayAudioEnd;

//获取当前登录帐号的路径，如果当前帐号没有取到，则返回Documents的根目录
-(NSString *)getAccountFilePath;

//是否有登录过的用户
-(BOOL)hasLoginUser;

//催促双双团队
-(void)pushFanxerTeam;
//检查新版本
-(void)checkUpdate;
#pragma mark 好友相关
//添加好友  好友的降升级关系都可以调用
-(void)modifyFriendTypeWithCategory:(UpdateFriendType) category andUserName:(NSString *)userName andInviteString:(NSString *)inviteString andCouldExpose:(BOOL)couldExpose;
//通过短信邀请某人的时候，需要调用此方法
-(void)inviteFriendWithCategory:(UpdateFriendType) category andMobile:(NSString *)mobile andCouldExpose:(BOOL)couldExpose;
//查找号码里面的产品用户
-(void)findMobileIsUserWithMobiles:(NSArray *)mobileArray;
//删除好友关系
-(void)deleteFriendRelationWithUserName:(NSString *)userName;
//查找与某个帐号的共同好友
-(void)findMutualFriendsWithUserName:(NSString *)userName;

//对于某个添加好友响应后的操作
-(void)responseActionWithReq:(NSString *)reqID actionFlag:(ResponseFriReqFlag)flag;
//判断当前用户是否有couple
-(BOOL)hasCouple;
//判断是否有喜欢的人
-(BOOL)hasLover;

//根据name判断是否是自己的帐号
-(BOOL)isMySelfWithUserName:(NSString *)userName;
//根据name判断是否是自己Couple的帐号
-(BOOL)isMyCoupleWithUserName:(NSString *)userName;

//获取全部的联系人
-(NSArray *)getAllContacts;
//获取过滤后的联系人
-(NSArray *)getAllContactsByFilter;
//获取过滤的非好友的联系人
-(NSArray *)getAllContactsByFriendsFilter;
//根据userName帐号获取用户信息，若为nil 则说明不是好友
-(CPUIModelUserInfo *)getUserInfoWithUserName:(NSString *)userName;
-(CPUIModelUserInfo *)getCommendUserInfoWithUserName:(NSString *)userName;
//根据手机号获取本地通讯录中的用户名
-(NSString *)getContactFullNameWithMobile:(NSString *)mobileNumber;

//获取缓存的couple请求信息 coupleName,relationType
-(NSDictionary *)getWillCoupleDictionary;
#pragma mark 消息和群组（多人会话）相关
//发送消息的接口，msgGroup为当前的msg group对象；msg需要重新构造，其中的消息类型和内容是必需的
-(void)sendMsgWithGroup:(CPUIModelMessageGroup *)msgGroup andMsg:(CPUIModelMessage *)uiMsg;

//发送提醒完成类型消息的接口
-(void)sendMsgWithGroupID:(NSNumber *)msgGroupID andMsg:(CPUIModelMessage *)uiMsg;

//重发消息
-(void)reSendMsg:(CPUIModelMessage *)uiMsg andMsgGroup:(CPUIModelMessageGroup *)msgGroup;

//发起会话的接口，分别是选择的userInfos和msgGroups
-(void)createConversationWithUsers:(NSArray *)userArray andMsgGroups:(NSArray *)msgGroups andType:(CreateConversationType)type;

//设置当前的聊天明细页面
-(void)setCurrentMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;

//把某个msg group 标记为已读状态
-(void)markMsgGroupReadedWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;

//标记某个音频消息为已播放状态
-(void)markMsgAudioReadedWithMsg:(CPUIModelMessage *)uiMsg;

//获取某个用户的Profile信息
-(void)getUserProfileWithUser:(CPUIModelUserInfo *)uiUserInfo;
//获取某个用户的近况信息
-(void)getUserRecentWithUser:(CPUIModelUserInfo *)uiUserInfo;

//给某个多人会话添加成员
-(void)addGroupMemWithUserNames:(NSArray *)userNames andGroup:(CPUIModelMessageGroup *)uiGroup;
//删除某个多人会话的成员
-(void)removeGroupMemWithUserNames:(NSArray *)userNames andGroup:(CPUIModelMessageGroup *)uiGroup;
//退出某个多人会话
-(void)quitGroupWithGroup:(CPUIModelMessageGroup *)uiGroup;
//升级某个多人会话为群，name是指定的群名称
-(void)addFavoriteGroupWithGroup:(CPUIModelMessageGroup *)uiGroup andName:(NSString *)name;
//修改某个群的名称
-(void)modifyFavoriteGroupNameWithGroup:(CPUIModelMessageGroup *)uiGroup withGroupName:(NSString *)groupName;
//删除某个MessageGroup-包括单人会话和多人会话
-(void)deleteMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;
//获取某个msgGroup的历史信息
-(void)getMsgListByPageWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;

//下载某个消息的资源
-(void)downloadResourceWithMsg:(CPUIModelMessage *)uimsg;

//根据用户名获取对应的MessageGroup，只针对于单聊的
-(CPUIModelMessageGroup *)getMsgGroupWithUserName:(NSString *)userName;

//获取某个偷偷问或者偷偷答消息的所有相关消息
-(NSArray *)getMsgListAskWithMsg:(CPUIModelMessage *)uiMsg;

//对某个添加好友请求的系统消息的操作：同意或者拒绝
-(void)responseActionWithMsg:(CPUIModelMessage *)uiMsg actionFlag:(ResponseFriReqFlag)flag;
#pragma mark 个人相关
-(void)uploadPersonalBgImgWithData:(NSData *)imgData;
-(void)uploadPersonalHeaderImgWithData:(NSData *)imgData;
-(void)uploadPersonalCoupleImgWithData:(NSData *)imgData;//这个方法不能被调用了，自己不能修改couple的头像
-(void)uploadPersonalBabyImgWithData:(NSData *)imgData;

//更新自己的近况
-(void)updateMyRecentInfoWithContent:(NSString *)content andType:(NSInteger)type;
//设置＊＊时间
-(void)setSingleTimeWithDate:(NSDate *)singleTime;
//隐藏baby  isHiddenBaby yes:隐藏baby
-(void)updateBaby:(NSNumber *)isHiddenBaby;
//修改性别 昵称 隐藏宝宝
-(void)updatePersonalInfoWithNickName:(NSString *)nickName andSex:(NSInteger)sex andHiddenBaby:(NSNumber *)isHiddenBaby;

#pragma mark   pet 相关
- (NSArray *)allActionObjects;
//deprecated.
- (CPUIModelPetActionAnim *)actionObjectOfID:(NSString *)resID;
- (CPUIModelPetActionAnim *)actionObjectOfID:(NSString *)resID fromPet:(NSString *)petID;

- (NSArray *)allMagicObjects;
- (CPUIModelPetMagicAnim *)magicObjectOfID:(NSString *)resID fromPet:(NSString *)petID;

//- (NSArray *)allFeelingObjects;
- (NSDictionary *)allFeelingObjects;
- (CPUIModelPetFeelingAnim *)feelingObjectOfID:(NSString *)resID fromPet:(NSString *)petID;

- (NSArray *)allSmallAnimObjects;
- (CPUIModelPetSmallAnim *)smallAnimObectOfID:(NSString *)resID;
- (CPUIModelPetSmallAnim *)smallAnimObectOfEscapeChar:(NSString *)escChar;

- (void)downloadPetRes:(NSString *)resID ofPet:(NSString *)petID;
- (void)updatePetResOfPet:(NSString *)petID;
- (BOOL)isAllFeelingResAvailable;
- (void)downloadAllFeelingResOfPet:(NSString *)petID;

- (void)downloadPetRes:(NSString *)resID andResType:(NSNumber *)resType ofPet:(NSString *)petID;

@end
