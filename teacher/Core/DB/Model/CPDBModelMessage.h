#import <Foundation/Foundation.h>


/**
 * 消息表
 */
typedef enum
{
    MSG_STATE_DEFAULT = 0,//
    MSG_STATE_SENDING = 1,//发送中
    MSG_STATE_SEND_SUCESS = 2,//发送成功
    MSG_STATE_SEND_ERROR = 3,//发送失败
    MSG_STATE_DOWNING = 4,//下载中
    MSG_STATE_DOWN_SUCESS = 5,//下载成功
    MSG_STATE_DOWN_ERROR = 6,//下载失败
    MSG_STATE_AUDIO_READED = 7,//音频已读
}DbMsgSendState;

typedef enum
{
    MSG_STATUS_IS_READED = 0,
    MSG_STATUS_IS_NOT_READ = 1,

}DbMsgIsReaded;
@interface CPDBModelMessage : NSObject
{

    NSNumber *msgID_;//消息主键
    NSNumber *msgGroupID_;//群ID
    NSString *msgSenderID_;//消息发送者的ID
    NSString *msgGroupServerID_;//消息所在群的服务器ID
    NSString *mobile_;//手机号
    NSString *userID_;//用户ID
    NSNumber *flag_;// 1 : 发送; 2 : 接收
    NSNumber *sendState_;// 0 :发送中 ;1发送成功 2发送失败 
    NSNumber *date_;//发送或者接受的时间
    NSNumber *isReaded_;//是否已读  0已读  1未读
    NSString *msgText_;//消息文本内容
    NSNumber *contentType_;//内容类型
    NSString *locationInfo_;//mid
    NSNumber *attachResID_;//附件对应的资源ID
    NSString *magicMsgID_;//魔法表情对应的ID
    NSString *petMsgID_;//pet对应的ID
    NSString *bodyContent_;
    NSString *uuidAsk_;
    NSString *msgOwnerName_;
}

@property (strong,nonatomic) NSNumber *msgID;
@property (strong,nonatomic) NSNumber *msgGroupID;
@property (strong,nonatomic) NSString *msgSenderID;
@property (strong,nonatomic) NSString *msgGroupServerID;
@property (strong,nonatomic) NSString *mobile;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSNumber *flag;
@property (strong,nonatomic) NSNumber *sendState;
@property (strong,nonatomic) NSNumber *date;
@property (strong,nonatomic) NSNumber *isReaded;
@property (strong,nonatomic) NSString *msgText;
@property (strong,nonatomic) NSNumber *contentType;
@property (strong,nonatomic) NSString *locationInfo;//mid
@property (strong,nonatomic) NSNumber *attachResID;
@property (strong,nonatomic) NSString *magicMsgID;
@property (strong,nonatomic) NSString *petMsgID;
@property (strong,nonatomic) NSString *bodyContent;
@property (strong,nonatomic) NSString *uuidAsk;
@property (strong,nonatomic) NSString *msgOwnerName;
@end
