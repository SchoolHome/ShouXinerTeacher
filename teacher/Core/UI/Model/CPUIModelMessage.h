#import <Foundation/Foundation.h>


/**
 * 消息表
 */
typedef enum
{
    MSG_CONTENT_TYPE_TEXT = 1,//文本消息
    MSG_CONTENT_TYPE_IMG = 2,//图片消息
    MSG_CONTENT_TYPE_AUDIO = 3,//音频消息
    MSG_CONTENT_TYPE_VIDEO = 4,//视频消息
    MSG_CONTENT_TYPE_MAGIC = 5,//魔法表情消息
    MSG_CONTENT_TYPE_CQ = 6,//传情消息
    MSG_CONTENT_TYPE_CS = 7,//传声消息
    MSG_CONTENT_TYPE_TTW = 8,//偷偷问消息
    MSG_CONTENT_TYPE_TTD = 9,//偷偷问的回答消息
    MSG_CONTENT_TYPE_ALARM_TEXT = 10,//文本的提醒
    MSG_CONTENT_TYPE_ALARMED_TEXT = 11,//文本的提醒过的
    MSG_CONTENT_TYPE_ALARM_AUDIO = 12,//语音的提醒
    MSG_CONTENT_TYPE_ALARMED_AUDIO = 13,//语音的提醒过的

    
    MSG_CONTENT_TYPE_UNKNOWN = 20,//未知的消息，需要处理为升级
    MSG_CONTENT_TYPE_ACK = 21,//回执消息

    MSG_CONTENT_TYPE_SYS = 1<<6,//普通系统消息
    MSG_CONTENT_TYPE_SYS_SPECIAL = 1<<(6+1),//可以点击的系统消息
    MSG_CONTENT_TYPE_SYS_RECOMMEND = 1<<7,//推荐的系统消息
    MSG_CONTENT_TYPE_SYS_ADD_REQ = 1<<8,//添加好友请求的系统消息
    MSG_CONTENT_TYPE_SYS_ADD_RES = 1<<9,//添加好友应答的系统消息
    MSG_CONTENT_TYPE_SYS_DOWNGRADE = 1<<10,//群降级的系统消息
    MSG_CONTENT_TYPE_SYS_ADD_REQ_ACCEPT = 1<<11,//添加好友请求的同意
    MSG_CONTENT_TYPE_SYS_ADD_REQ_IGNORE = 1<<12,//添加好友请求的忽略

}MsgContentType;
typedef enum
{
    MSG_SEND_STATE_DEFAULT = 0,//
    MSG_SEND_STATE_SENDING = 1,//发送中
    MSG_SEND_STATE_SEND_SUCESS = 2,//发送成功
    MSG_SEND_STATE_SEND_ERROR = 3,//发送失败
    MSG_SEND_STATE_DOWNING = 4,//下载中
    MSG_SEND_STATE_DOWN_SUCESS = 5,//下载成功
    MSG_SEND_STATE_DOWN_ERROR = 6,//下载失败
    MSG_SEND_STATE_AUDIO_READED = 7,//音频已读
}MsgSendState;
typedef enum
{
    MSG_FLAG_SEND = 1,//发送方
    MSG_FLAG_RECEIVE = 2,//接收方
}MsgFlag;
typedef enum
{
    MSG_READ_STATUS_IS_READED = 0,
    MSG_READ_STATUS_IS_NOT_READ = 1,
}MsgIsReaded;

@class CPUIModelSysMessageReq;
@class CPUIModelSysMessageFriCommend;
@interface CPUIModelMessage : NSObject
{

    NSNumber *msgID_;//消息主键
    NSNumber *msgGroupID_;//群ID
    NSString *msgSenderName_;//消息发送者的帐号name
    NSString *mobile_;//手机号
    NSString *userID_;//用户ID
    NSNumber *flag_;// 1 : 发送; 2 : 接收
    NSNumber *sendState_;// 0 :发送中 ;1发送成功 2发送失败 
    NSNumber *date_;//发送或者接受的时间
    NSNumber *isReaded_;//是否已读
    NSString *msgText_;//消息文本内容
    NSNumber *contentType_;//内容类型
    NSString *locationInfo_;//地理位置信息
    NSNumber *attachResID_;//附件对应的资源ID
    NSNumber *mediaTime_;//音频或者视频的时长s
    NSNumber *fileSize_;//文件大小k
    
    NSURL *videoUrl_;//UI录制完成的视频路径
    NSString *filePath_;//针对图片或者音视频的文件路径
    NSString *thubFilePath_;//视频的缩略图的路径
    NSData *msgData_;//类似图片、音频等消息的资源数据
 
    NSString *magicMsgID_;//魔法表情对应的ID
    NSString *petMsgID_;//pet对应的ID
    
    NSString *bodyContent_;
    NSString *uuidAsk_;

    NSNumber *isAlarmHidden_;//提醒是否隐藏
    NSNumber *alarmTime_;//提醒的时间
    NSNumber *linkMsgID_; // 闹钟提醒完成关联的msgID
}

@property (strong,nonatomic) NSNumber *msgID;
@property (strong,nonatomic) NSNumber *msgGroupID;
@property (strong,nonatomic) NSString *msgSenderName;
@property (strong,nonatomic) NSString *mobile;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSNumber *flag;
@property (strong,nonatomic) NSNumber *sendState;
@property (strong,nonatomic) NSNumber *date;
@property (strong,nonatomic) NSNumber *isReaded;
@property (strong,nonatomic) NSString *msgText;
@property (strong,nonatomic) NSNumber *contentType;
@property (strong,nonatomic) NSString *locationInfo;
@property (strong,nonatomic) NSNumber *attachResID;
@property (strong,nonatomic) NSString *filePath;
@property (strong,nonatomic) NSData   *msgData;
@property (strong,nonatomic) NSNumber *mediaTime;
@property (strong,nonatomic) NSNumber *fileSize;
@property (strong,nonatomic) NSString *thubFilePath;
@property (strong,nonatomic) NSURL *videoUrl;
@property (strong,nonatomic) NSString *magicMsgID;
@property (strong,nonatomic) NSString *petMsgID;
@property (strong,nonatomic) NSString *bodyContent;
@property (strong,nonatomic) NSString *uuidAsk;

@property (strong,nonatomic) NSNumber *isAlarmHidden;
@property (strong,nonatomic) NSNumber *alarmTime;
@property (strong,nonatomic) NSNumber *linkMsgID;
-(NSComparisonResult) orderMsgWithDate:(CPUIModelMessage *)userMsg;

-(BOOL)isSysFriendReq;//是否是添加好友请求的系统消息
-(BOOL)isSysFriendReqAccept;//是否是添加好友请求的系统消息 同意
-(BOOL)isSysFriendReqIgnore;//是否是添加好友请求的系统消息 忽略
-(BOOL)isSysDefault;//是否是不可点的系统消息
-(BOOL)isSysSpecial;//是否是可点的系统消息
-(BOOL)isSysFriendCommend;//是否是好友推荐的系统消息
-(BOOL)isSysFriendRes;//是否是好友应答的系统消息

-(CPUIModelSysMessageReq *)getSysMsgReq;//获取好友请求的系统消息扩展Model
-(CPUIModelSysMessageFriCommend *)getSysMsgFriCommend;//获取好友推荐的Model
-(BOOL)isMatchLoveMsg;//是否是互为喜欢的消息

-(BOOL)isAlarmMsg;

@end
/**1=普通好友
 2=密友
 3=喜欢
 4=恋人couple
 5=夫妻couple
 **/
typedef enum
{
    SYS_MSG_APPLY_TYPE_COMMON = 1,
    SYS_MSG_APPLY_TYPE_CLOSER = 2,
    SYS_MSG_APPLY_TYPE_LOVE = 3,
    SYS_MSG_APPLY_TYPE_COUPLE = 4,
    SYS_MSG_APPLY_TYPE_MARRIED = 5,
}SysMsgApplyType;

@interface CPUIModelSysMessageReq : NSObject
@property (strong,nonatomic) NSNumber *reqID;
@property (strong,nonatomic) NSNumber *applyType;
@property (strong,nonatomic) NSString *nickName;
@property (strong,nonatomic) NSString *content;
@property (strong,nonatomic) NSString *userName;
@property (strong,nonatomic) NSString *mobileNumber;
@property (strong,nonatomic) NSString *mobileRegion;
@end

@interface CPUIModelSysMessageFriCommend : NSObject
@property (strong,nonatomic) NSString *mobileNumber;
@property (strong,nonatomic) NSString *mobileRegion;
@property (strong,nonatomic) NSString *nickName;
@property (strong,nonatomic) NSString *content;
@property (strong,nonatomic) NSString *userName;
@end