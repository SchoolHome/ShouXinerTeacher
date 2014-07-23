//
//  XMPPUserMessage.h
//  iCouple
//
//  Created by yl s on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XMPP.h"
#import "XMPPMessage.h"
#import "NSXMLElement+XMPP.h"

typedef enum{
    
    UserMessageTypeUnknown = 0,
    UserMessageTypeText = 1,
    UserMessageTypeImage = 2,
    UserMessageTypeAudio = 3,
    UserMessageTypeVideo = 4,
    UserMessageTypeMagic = 5,
    UserMessageTypeFeeling = 6,
    UserMessageTypeSound = 7,
    UserMessageTypeAsk = 8,
    UserMessageTypeAnswer = 9,
    UserMessageTypeAlarm = 10,
    UserMessageTypeNotice = 11,
}UserMessageType;

@interface XMPPUserMessage : NSObject

@property (strong, nonatomic) NSNumber *messageID;

@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *to;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSNumber *xmppType;
@property (strong, nonatomic) NSString *message;            //only available if the msg is textMsg.
@property (strong, nonatomic) NSString *resource;           //avalible if the msg is not textMsg.
@property (strong, nonatomic) NSNumber *resContentLength;   //avalible if the msg is audio/video/sound/ask Msg.s
@property (strong, nonatomic) NSNumber *resContentSize;
@property (strong, nonatomic) NSString *resourceMimeType;   //N/A

@property (strong, nonatomic) NSString *resourceThumb;      //only available if the msg is videoMsg.
@property (strong, nonatomic) NSNumber *resourceWidth;      //only available if the msg is videoMsg.
@property (strong, nonatomic) NSNumber *resourceHeight;      //only available if the msg is videoMsg.

@property (strong, nonatomic) NSString *uuid;

@property (strong, nonatomic) NSString *petID;
@property (strong, nonatomic) NSString *resID;

@property (strong, nonatomic) NSNumber *delayedTime;

+ (XMPPUserMessage *) fromXMLElement:(XMPPMessage *)message;

- (NSString *)getXMPPType;
- (NSString *)getXMPPSubType;

- (NSString *)encodeBody;

- (NSMutableDictionary *)generateHttpSendDic;

@end
