//
//  PalmUIManagement.h
//  teacher
//
//  Created by singlew on 14-3-7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PalmNetWorkService.h"
#import "CPPTModelLoginResult.h"
#import "CropVideo.h"

#define TRANSFERVALUE @"TransferValue"
#define TRANSFERVCFROMCLASS @"TransferFromVCClass"
#define TRANSFERVCTOCLASS @"TransferToVCClass"
#import "BBGroupModel.h"

@interface PalmUIManagement : NSObject

+(PalmUIManagement *) sharedInstance;
// 登陆结果
@property(nonatomic,strong) CPPTModelLoginResult *loginResult;
// 当前选择的班级信息
@property(nonatomic,strong) BBGroupModel *currentGroupInfo;
// 客户端页面间传值KVO
@property(nonatomic,strong) NSDictionary *transferDic;
@property(nonatomic,strong) NSDictionary *userProfile;
@property(nonatomic,strong) NSDictionary *otherUserProfile;
@property(nonatomic,strong) NSDictionary *userContacts;
@property(nonatomic,strong) NSDictionary *userCredits;
@property(nonatomic,strong) NSDictionary *userGroupList;
@property(nonatomic,strong) NSDictionary *updateUserHeader;
@property(nonatomic,strong) NSDictionary *updateUserHeaderResult;

@property(nonatomic,strong) NSDictionary *checkVersion;
// 有指示
@property(nonatomic,strong) NSDictionary *notiList;

// 有指示未读数
@property(nonatomic,strong) NSDictionary *notiUnReadCount;
// 有指示根据分页获取数据
@property(nonatomic,strong) NSDictionary *notiWithSenderList;
// 转发有指示
@property(nonatomic,strong) NSDictionary *postForwardResult;

// 班级列表
@property(nonatomic,strong) NSDictionary *groupListResult;
@property(nonatomic,strong) NSArray *groupList;
// 班级Topic
@property(nonatomic,strong) NSDictionary *groupTopic;
// 点赞
@property(nonatomic,strong) NSDictionary *praiseResult;
// 发表评论
@property(nonatomic,strong) NSDictionary *commentResult;
// 学生列表
@property(nonatomic,strong) NSDictionary *groupStudents;
// 转发
@property(nonatomic,strong) NSDictionary *recommendResult;
// 新消息数量
@property(nonatomic,strong) NSDictionary *notifyCount;
// 新消息列表
@property(nonatomic,strong) NSArray *notifyList;

@property(nonatomic,strong) NSDictionary *groupTopicListResult;
//@property(nonatomic,strong) NSArray *groupTopicList;
// 上传图片结果
@property(nonatomic,strong) NSDictionary *updateImageResult;
// 发表Topic结果
@property(nonatomic,strong) NSDictionary *topicResult;
// 删除Topic
@property(nonatomic,strong) NSDictionary *deleteTopicResult;

@property(nonatomic,strong) NSHTTPCookie *php;
@property(nonatomic,strong) NSHTTPCookie *suid;
@property(nonatomic,strong) NSString *imServerIP;

// 广告
@property(nonatomic,strong) NSDictionary *advResult;

// 广告
@property(nonatomic,strong) NSDictionary *advWithGroupResult;

//班级圈banner
@property(nonatomic, strong) NSDictionary *advBannerInBJQ;

// 激活
@property(nonatomic,strong) NSDictionary *activateDic;

// 有通知
@property(nonatomic,strong) NSNumber *noticeArrayTag;
@property(nonatomic,strong) NSArray *noticeArray;

// 裁剪video状态
@property(nonatomic,strong) CropVideoModel *videoState;
// 压缩video状态
@property(nonatomic,strong) CropVideoModel *videoCompressionState;
// 上传视频结果
@property(nonatomic,strong) NSDictionary *uploadVideoResult;
// 下载视频结果
@property(nonatomic,strong) NSDictionary *downloadVideoResult;
@property(nonatomic,strong) NSString *downloadVideoPath;
// 发现
@property(nonatomic,strong) NSDictionary *discoverResult;

// postUserInfo
@property (nonatomic,strong) NSDictionary *postUserInfoResult;
// 短信验证码
@property (nonatomic,strong) NSDictionary *smsVerifyCode;
// 公共账号消息
@property (nonatomic,strong) NSDictionary *publicMessageResult;
// 公共账号消息转发
@property (nonatomic,strong) NSDictionary *publicMessageForwardResult;
// 客服电话
@property (nonatomic,strong) NSDictionary *customerServiceTel;
// 登陆前短信验证码
@property (nonatomic,strong) NSDictionary *resetSMSCode;
// 登陆前修改密码
@property (nonatomic,strong) NSDictionary *resetPassword;
// 获取公共账号
@property (nonatomic,strong) NSDictionary *publicAccountDic;
// 获取指定公众号历史消息
@property (nonatomic,strong) NSDictionary *publicAccountMessages;

// 获取用户信息
-(void) getUserProfile;
-(void) getUserProfileWithUID : (NSString *) UID;
// 获取用户通讯录
-(void) getuserContacts;
// 获取教师得分
-(void) getUserCredits;
// 获取班级信息
-(void) getUserGroupList;
// 更新用户头像
-(void) updateUserHeader : (NSData *) imageData;
-(void) updateuserHeaderResult : (NSString *) urlPath;

// 获取有指示
-(void) getNotiData : (int) timeStamp;
// 获取班级列表
-(void) getGroupList;
// 获取班级Topic
-(void) getGroupTopic : (int) groupID withTimeStamp : (int) timeStamp withOffset : (int) offset withLimit : (int) limit withType : (int) type;
// 点赞
-(void) postPraise : (long long) topicID;
// 发表评论
-(void) postComment : (NSString *) commentContent withReplyToUid : (int) uid withTopicID : (long long) topicID;

// 获取新消息数量
-(void) getNotiCount;
// 获取新消息列
-(void) getNotiList : (int) offset withLimit : (int) limit;

// 上传图片
-(void) updateUserImageFile : (NSData *) imageData withGroupID : (int) groupID;
// 发表Topic
-(void) postTopic : (int) groupid withTopicType : (int) topicType withSubject : (int) subject withTitle : (NSString *) title
      withContent : (NSString *) content withAttach : (NSString *) attach activityid:(NSString *)activityID;

-(void) postCheckVersion;

// 有指示未读
-(void) getUnReadNotiCount : (long long) timeStamp;
// 获取有指示列表
-(void) getNotiListWithSender : (int) sender withOffset : (int) offset withLimit : (int) limit;
// 转发有指示
-(void) postForwardNoti : (int) oaid withGroupID : (int) groupID withMessage : (NSString *) message;

// 激活
-(void) activate : (NSString *) userName withTelPhone : (NSString *) telPhone withVerifyCode:(NSString *)verfyCode withEmail : (NSString *) email withPassWord : (NSString *) password;

-(void) userLoginToken;
// 获取学生列表
-(void) getGroupStudents : (NSString *) groupids;

// 推荐话题
-(void) postRecommend : (long long) topicID withToHomePage : (BOOL) hasHomePage withToUpGroup : (BOOL) hasUpGroup;
// 拍表现
-(void) postPBX : (int) groupid withTitle : (NSString *) title withContent : (NSString *) content withAttach : (NSString *) attach
      withAward : (NSString *) students withToHomePage : (BOOL) hasHomePage withToUpGroup : (BOOL) hasTopGroup;

// 切换回前台
-(void) foreground;

//获取班级圈广告
-(void) getAdvWithGroupID : (int) groupID;
//获取班级圈banner广告
-(void)getAdvBannerInBJQ;

// 上传视频
-(void) updateUserVideoFile : (NSURL *) videoUrl withGroupID : (int) groupID;
// 下载视频
-(void) downLoadUserVideoFile : (NSString *) videoUrl withKey : (NSString *) key;
// 删除topic
-(void) deleteTopic : (long long) topicID;
// 获取发现数据
-(void) getDiscoverData;

// postUserInfo
-(void) postUserInfo : (NSString *) avatar withMobile : (NSString *) mobile withVerifyCode : (NSString *) verifyCode withPasswordOld : (NSString *) passwordOld withPasswordNew : (NSString *) passwordNew withSex : (int) sex withSign : (NSString *) sign;

// 获取短信验证码
-(void) getSMSVerifyCode : (NSString *)mobile;
// 获取公共账号消息
-(void) getPublicMessage : (NSString *) mids;
// 转发公共账号消息
-(void) postPublicMessageForward : (NSString *) mid withGroupID : (int) groupID withMessage : (NSString *) message;
// 客服电话
-(void) getCustomerServiceTelNumber;

// 登陆前短信验证码
-(void) getResetPasswordSMS : (NSString *) mobileNumber;
// 登陆前修改密码
-(void) postResetPassword : (NSString *) smsID withSmsCode : (NSString *) smsCode withNewPassword : (NSString *) newPassword;
// 获取公共账号信息
-(void) getPublicAccount;
// 获取指定公众号历史消息
-(void) getPublicAccountMessages : (int) accountID withMid : (NSString *) mid withSize : (int) size;
@end
