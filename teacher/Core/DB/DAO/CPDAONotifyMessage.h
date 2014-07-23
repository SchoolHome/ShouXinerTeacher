//
//  CPDAONotifyMessage.h
//  teacher
//
//  Created by ZhangQing on 14-7-22.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BaseDAO.h"

#import "CPDBModelNotifyMessage.h"
@interface CPDAONotifyMessage : BaseDAO
- (id)initWithStatusCode:(NSInteger)statusCode;
-(NSArray *)findAllUrlsByNotifyMessageID:(NSInteger )notifyMsgID;
-(NSNumber *)insertUrlsWithUrl:(NSString *)url andNotifyMessageID : (NSNumber *)notifyMsgID;

-(NSNumber *)insertMessage:(CPDBModelNotifyMessage *)dbMessage;
-(void)updateMessageReadedWithID:(NSNumber *)objID  obj:(NSNumber *)msgReaded;
-(void)updateMessageWithID:(NSNumber *)objID  obj:(CPDBModelNotifyMessage *)dbMessage;
-(CPDBModelNotifyMessage *)getMessageWithResultSet:(FMResultSet *)rs;
-(CPDBModelNotifyMessage *)findMessageWithID:(NSNumber *)id;
-(NSArray *)findAllMessages;
-(NSArray *)findAllMessagesByGroupID;
-(NSArray *)findAllMessagesWithGroupID:(NSNumber *)msgGroupID;
-(NSArray *)findAllMessagesWithFromName:(NSString *)fromName;

-(void)updateMessageWithID:(NSNumber *)msgID andStatus:(NSNumber *)status;
-(void)updateMessageWithGroupID:(NSNumber *)groupID andGroupServerID:(NSString *)groupServerID;
-(void)updateMessageWithGroupID:(NSNumber *)groupID andSendName:(NSString *)sendName;
-(void)resetMessageStateBySentError;

-(NSArray *)findMsgListByPageWithGroupID:(NSNumber *)msgGroupID last_msg_time:(NSNumber *)lastMsgTime max_msg_count:(NSInteger)maxMsgCount;
-(NSArray *)findMsgListByPageWithGroupID:(NSNumber *)msgGroupID max_msg_count:(NSInteger)maxMsgCount;
-(NSArray *)findMsgListByNewestTimeWithGroupID:(NSNumber *)msgGroupID newest_msg_time:(NSNumber *)newestMsgTime;
-(CPDBModelNotifyMessage *)findMessageWithSendID:(NSString *)sendName andContentType:(NSNumber *)contentType;
-(CPDBModelNotifyMessage *)findMessageWithResID:(NSNumber *)id;

-(NSInteger )getUnreadedNotifyMessageCount:(NSString *)fromName;
-(NSArray *)findAllNewMessages;
@end
