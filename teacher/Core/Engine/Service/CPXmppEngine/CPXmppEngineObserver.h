//
//  CPXmppEngineObserver.h
//  Couple
//
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPXmppEngineObserver <NSObject>

@optional

- (void)XmppEngineStatusChanged:(NSInteger)status;

//- (void)XmppEngineMessageSendingStatusChanged:(unsigned long)abc;

//status:intValueFrom XMPPEngineMessageSendingState.
- (void)xmppEngineMessageSendingStatusOf:(NSNumber *)messageID changedTo:(NSNumber *)status;

//- (void)xmppEngine

//userMsg:XMPPUserMessage
- (void)handleUserMessageReceived:(NSObject *)userMessage;

//groupMsg:XMPPGroupMEssage
- (void)handleGroupMessageReceived:(NSObject *)groupMessage;

//gmcMessage:XMPPGroupMemberChangeMessage
- (void)handleGroupMemberChangeMessageReceived:(NSObject *)gmcMessage;

//sysMsg: XMPPSystemMessage
- (void)handleSystemMessageReceived:(NSObject *)sysMessage;

//2014-7
-(void) handleNoticeMessageReceived:(NSObject *)noticeMessage;
@end
