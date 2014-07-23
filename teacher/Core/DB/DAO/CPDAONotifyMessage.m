//
//  CPDAONotifyMessage.m
//  teacher
//
//  Created by ZhangQing on 14-7-22.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "CPDAONotifyMessage.h"

#import "CoreUtils.h"
@implementation CPDAONotifyMessage
- (id)initWithStatusCode:(NSInteger)statusCode
{
    self = [super init];
    if(self)
    {
        if (statusCode==1)
        {
            //[self createNotifyMessageTable];
            //[self createNotifyMessageUrlsTable];
        }else
        {
            if (![self isTableOK:@"notifyMessageUrl"]) {
                [self createNotifyMessageUrlsTable];
            }

            if (![self isTableOK:@"notifyMessage"]) {
                [self createNotifyMessageTable];
            }

        }
    }
    return self;
}
- (BOOL) isTableOK:(NSString *)tableName
{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        [rs close];
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    
    return NO;
}
-(void)createNotifyMessageTable
{
    [db executeUpdate:@"CREATE TABLE notifyMessage (id INTEGER PRIMARY KEY  AUTOINCREMENT,oaid INTEGER,bodyFrom INTEGER,title TEXT,content TEXT,link TEXT,from TEXT,to TEXT,type INTEGER ,xmppType INTEGER,fromUserName TEXT,fromUserAvatar TEXT,mobile TEXT,flag INTEGER,date INTEGER,is_readed INTEGER,msg_text TEXT,content_type INTEGER,location_info TEXT,attach_res_id INTEGER,body_content TEXT,msg_owner_name TEXT)"];
    if ([db hadError])
    {
        CPLogError(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}

-(void)createNotifyMessageUrlsTable
{
    [db executeUpdate:@"CREATE TABLE notifyMessageUrl (id INTEGER PRIMARY KEY  AUTOINCREMENT,messageID INTEGER,url TEXT)"];
    if ([db hadError])
    {
        CPLogError(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}
#pragma mark urlTable
-(NSArray *)findAllUrlsByNotifyMessageID:(NSInteger )notifyMsgID
{
    FMResultSet *rs = [db executeQuery:@"select * from notifyMessage where messageID = ?",notifyMsgID];
    NSMutableArray *urlList = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [urlList addObject:[rs stringForColumn:@"url"]];
    }
    [rs close];
    return urlList;
}
-(NSNumber *)insertUrlsWithUrl:(NSString *)url andNotifyMessageID : (NSNumber *)notifyMsgID
{

        NSString *sqlStr = [NSString stringWithFormat:@"insert into notifyMessageUrls(messageID,url) values (%@,%@)",notifyMsgID,url];
        [db executeUpdate:sqlStr];
        if ([db hadError])
        {
            CPLogError(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
    
    return [self lastRowID];
}
#pragma mark NotifyMessageTable
//需要数据：from to type xmppType delayedTime
-(NSNumber *)insertMessage:(CPDBModelNotifyMessage *)dbMessage
{
    CPLogInfo(@"msgText:%@",dbMessage.msgText);
    if (!dbMessage.isReaded)
    {
        [dbMessage setIsReaded:[NSNumber numberWithInt:MSG_STATUS_IS_READED]];
    }
    if (!dbMessage.date)
    {
        [dbMessage setDate:[CoreUtils getLongFormatWithNowDate]];
    }
    NSLog(@"-10- %@",dbMessage);
    NSString *sqlstr = [NSString stringWithFormat:@"insert into notifyMessage (mobile,flag,date,is_readed,msg_text,content_type,location_info,body_content,msg_owner_name,oaid ,bodyFrom,title,content ,link,from,to,type,xmppType,fromUserName,fromUserAvatar) values (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@)",
                        dbMessage.mobile,dbMessage.flag,dbMessage.date,dbMessage.isReaded,dbMessage.msgText,dbMessage.contentType,dbMessage.locationInfo,dbMessage.bodyContent,dbMessage.msgOwnerName,dbMessage.oaid,dbMessage.bodyFrom,dbMessage.title,dbMessage.content,dbMessage.link,dbMessage.from,dbMessage.to ,dbMessage.type,dbMessage.xmppType,dbMessage.fromUserName,dbMessage.fromUserAvatar];
    NSLog(@"-11- %@",sqlstr);
    [db executeUpdate:sqlstr];
    NSLog(@"-12- %@",dbMessage);
    if ([db hadError])
    {
        NSLog(@"-13- %@",dbMessage);
        CPLogError(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
    return [self lastRowID];
}
-(void)updateMessageReadedWithID:(NSNumber *)objID  obj:(NSNumber *)msgReaded
{
    [db executeUpdate:@"update notifyMessage set is_readed = ? where id = ?",msgReaded,objID];
    if ([db hadError])
    {
        CPLogError(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}
-(void)updateMessageWithID:(NSNumber *)objID  obj:(CPDBModelNotifyMessage *)dbMessage
{
    [db executeUpdate:@"update notifyMessage set group_id=?,msg_sender_id=?,msg_group_server_id=?,mobile=?,flag=?,send_state=?,date=?,is_readed=?,msg_text=?,content_type=?,location_info=?,attach_res_id=?,body_content=?,msg_owner_name=?,oaid=? ,bodyFrom=?,title=?,content=? ,link=?,headImagePath=? where id =?",
     dbMessage.msgGroupID,dbMessage.msgSenderID,dbMessage.msgGroupServerID,dbMessage.mobile,dbMessage.flag,dbMessage.sendState,dbMessage.date,dbMessage.isReaded,dbMessage.msgText,dbMessage.contentType,dbMessage.locationInfo,dbMessage.attachResID,dbMessage.bodyContent,dbMessage.msgOwnerName,dbMessage.oaid,dbMessage.bodyFrom,dbMessage.title,dbMessage.content,dbMessage.link,@"",objID];
    if ([db hadError])
    {
        CPLogError(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
    }
}
-(CPDBModelNotifyMessage *)getMessageWithResultSet:(FMResultSet *)rs
{
    CPDBModelNotifyMessage *dbMessage = [[CPDBModelNotifyMessage alloc] init];
    [dbMessage setMsgID:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"id"]]];
    [dbMessage setMsgGroupID:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"group_id"]]];
    [dbMessage setMsgSenderID:[rs stringForColumn:@"msg_sender_id"]];
    [dbMessage setMsgGroupServerID:[rs stringForColumn:@"msg_group_server_id"]];
    [dbMessage setMobile:[rs stringForColumn:@"mobile"]];
    [dbMessage setFlag:[NSNumber numberWithInt:[rs intForColumn:@"flag"]]];
    [dbMessage setSendState:[NSNumber numberWithInt:[rs intForColumn:@"send_state"]]];
    [dbMessage setDate:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"date"]]];
    [dbMessage setIsReaded:[NSNumber numberWithInt:[rs intForColumn:@"is_readed"]]];
    [dbMessage setMsgText:[rs stringForColumn:@"msg_text"]];
    [dbMessage setContentType:[NSNumber numberWithInt:[rs intForColumn:@"content_type"]]];
    [dbMessage setLocationInfo:[rs stringForColumn:@"location_info"]];
    [dbMessage setAttachResID:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"attach_res_id"]]];
    [dbMessage setOaid:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"oaid"]]];
    [dbMessage setBodyFrom:[NSNumber numberWithLongLong:[rs longLongIntForColumn:@"bodyFrom"]]];
    [dbMessage setTitle:[rs stringForColumn:@"title"]];
    [dbMessage setContent:[rs stringForColumn:@"content"]];
    [dbMessage setLink:[rs stringForColumn:@"link"]];
    [dbMessage setBodyContent:[rs stringForColumn:@"body_content"]];
    [dbMessage setMsgOwnerName:[rs stringForColumn:@"msg_owner_name"]];
    return dbMessage;
}
-(CPDBModelNotifyMessage *)findMessageWithID:(NSNumber *)id
{
    CPDBModelNotifyMessage *reMessage = nil;
    if (id)
    {
        FMResultSet *rs = [db executeQuery:@"select * from notifyMessage where id = ?",id];
        if ([rs next])
        {
            reMessage = [self getMessageWithResultSet:rs];
        }
        [rs close];
    }
    return reMessage;
}
-(NSArray *)findAllMessages
{
    FMResultSet *rs = [db executeQuery:@"select * from notifyMessage"];
    NSMutableArray *MessageList = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [MessageList addObject:[self getMessageWithResultSet:rs]];
    }
    [rs close];
    return MessageList;
}
-(NSArray *)findAllMessagesWithFromName:(NSString *)fromName
{
    FMResultSet *rs = [db executeQuery:@"select * from notifyMessage where from = ?",fromName];
    NSMutableArray *MessageList = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [MessageList addObject:[self getMessageWithResultSet:rs]];
    }
    [rs close];
    return MessageList;
}
//获取未读数
-(NSInteger )getUnreadedNotifyMessageCount:(NSString *)fromName
{
    FMResultSet *rs = [db executeQuery:@"select count(*) from notifyMessage where from = ? and is_readed=?",fromName,[NSNumber numberWithInt:0]];
    NSInteger unreadedCount = 0;
    while ([rs next])
    {
        unreadedCount = [rs intForColumnIndex:0];
    }
    [rs close];
    return unreadedCount;
}
//获取不同fromName最后一条数据
-(NSArray *)findAllNewMessages
{
    FMResultSet *rs = [db executeQuery:@"select top 1* from notifyMessage order by from desc group by from"];
    NSMutableArray *MessageList = [[NSMutableArray alloc] init];
    while ([rs next])
    {
        [MessageList addObject:[self getMessageWithResultSet:rs]];
    }
    [rs close];
    return MessageList;
}
@end
