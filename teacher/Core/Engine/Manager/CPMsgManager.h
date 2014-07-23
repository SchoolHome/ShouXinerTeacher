//
//  CPMsgManager.h
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPHttpEngineObserver.h"
#import "CPXmppEngineObserver.h"

#define USER_MSG_INIT_MAX_COUNT 20
#define USER_MSG_LOAD_MAX_COUNT 20

@class CPDBModelUserInfo;
@class CPUIModelMessageGroup;
@class CPUIModelMessage;
@class XMPPUserMessage;
@class CPUIModelUserInfo;
@class CPDBModelMessage;
//2014-7
@class XMPPNoticeMessage;

@interface CPMsgManager : NSObject<CPHttpEngineObserver,CPXmppEngineObserver>
{
    NSMutableDictionary *willSendXmppMsg_;
}
@property (nonatomic,strong) NSMutableDictionary *willSendXmppMsg;

-(void)addWillSendMsg:(NSObject *)xmppMsg andMsgID:(NSNumber *)msgID;
-(XMPPUserMessage *)getWillSendMsgWithID:(NSNumber *)msgID;
-(void)removeWillSendXmppMsg:(NSNumber *)msgID;
-(void)updateXmppMsgWithThub:(NSString *)thubServerUrl andMsgID:(NSNumber *)msgID;
-(void)updateXmppMsgWithFileSize:(NSNumber *)fileSize andMsgID:(NSNumber *)msgID;
-(void)updateXmppMsgWithMediaTime:(NSNumber *)mediaTime andMsgID:(NSNumber *)msgID;
-(void)sendMsgByWillCachedWithID:(NSNumber *)msgID resUrl:(NSString *)resUrl;
-(void)removeAllWillSendXmppMsgs;

-(NSNumber *)sendMsgWithMsgGroup:(CPUIModelMessageGroup *)msgGroup newMsg:(CPUIModelMessage *)uiMsg;
-(NSNumber *)sendMsgAlarmWithMsgGroup:(CPUIModelMessageGroup *)msgGroup newMsg:(CPUIModelMessage *)uiMsg;
-(NSNumber *)sendAutoMsgWithMsgGroupID:(NSNumber *)msgGroupID newMsg:(CPDBModelMessage *)dbMsg;
-(NSNumber *)sendAutoMsgTextWithMsgGroupID:(NSNumber *)msgGroupID newMsg:(CPDBModelMessage *)dbMsg;
-(NSNumber *)sendAutoMsgSysWithMsgGroupID:(NSNumber *)msgGroupID newMsg:(CPDBModelMessage *)dbMsg;
-(NSNumber *)sendAutoMsgByFriendApplyWithUserName:(NSString *)userName andApplyType:(NSInteger)applyType;
-(NSNumber *)sendAutoMsgByFriendApplyReqWithUserName:(NSString *)userName andApplyType:(NSInteger)applyType;

-(void)createConversationWithUser:(CPUIModelUserInfo *)uiUserInfo;
-(void)createConversationWithUsers:(NSArray *)userArray andMsgGroups:(NSArray *)msgGroups andType:(NSInteger)type;
-(void)refreshMsgGroupList;
-(void)refreshMsgListWithMsgGroupID:(NSNumber *)msgGroupID isCreated:(BOOL)isCreatedConver;
-(NSNumber *)getMsgGroupIdWithUserName:(NSString *)userName;
-(NSNumber *)getMsgGroupIdWithServerID:(NSString *)serverID;

-(void)createNewConversationWithUser:(CPUIModelUserInfo *)uiUserInfo;
-(void)createCoupleConversationWithUser:(CPUIModelUserInfo *)uiUserInfo;
-(void)createDefaultConversationWithUser:(CPUIModelUserInfo *)uiUserInfo;
-(void)createConversationWithUserNames:(NSArray *)userArray andContextObj:(NSObject *)obj;
-(void)getGroupInfoWithGroupJid:(NSString *)groupJid;
-(void)addGroupMemWithUserNames:(NSArray *)userNames andGroupJid:(NSString *)groupJid;
-(void)removeGroupMemWithUserNames:(NSArray *)userNames andGroupJid:(NSString *)groupJid;
-(void)quitGroupWithGroupJid:(NSString *)groupJid;
-(void)addFavoriteGroupWithGroupJid:(NSString *)groupJid andName:(NSString *)name;
-(void)getFavoriteGroupsWithTimeStamp:(NSString *)timeStamp;
-(void)modifyFavoriteGroupNameWithGroupJid:(NSString *)groupJID withGroupName:(NSString *)groupName;
-(void)removeFavoriteGroupWithGroupJid:(NSString *)groupJID;
-(void)addGroupMemWithUserNames:(NSArray *)userNames andGroup:(CPUIModelMessageGroup *)uiMsgGroup;
-(void)refreshMsgGroupInfoWithMsgGroupID:(NSNumber *)msgGroupID;
-(void)refreshMsgGroupInfoReadedWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;
-(void)refreshMsgGroupConverTypeWithGroupID:(NSNumber *)msgGroupID andNewType:(NSInteger)newMsgType;
-(void)addNewMsgTipWithNickName:(NSString *)nickName andMsgText:(NSString *)msgText andUnReadCount:(NSNumber *)unReadedCount andGroupID:(NSNumber *)groupID andGroup:(CPUIModelMessageGroup *)group;
-(void)addNewMsgTipWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup;

-(void)filterMessageGroupByFriendArray;


-(void)refreshMsgGroupWithUserInfo:(CPDBModelUserInfo *)dbUserInfo;
-(void)refreshCurrentMsgGroupWithUserInfo:(CPDBModelUserInfo *)dbUserInfo;
-(void)refreshCoupleMsgGroupWithUserInfo:(CPDBModelUserInfo *)dbUserInfo;
-(NSArray *)getMsgListAskWithMsg:(CPUIModelMessage *)uiMsg;

-(void)refreshMsgGroupMemsWithMsgGroupID:(NSNumber *)msgGroupID;
-(void)refreshMsgGroupWithDelUserName:(NSString *)userName;

-(void)refreshCurrentConverGroupMsgListByHistoryWithGroup:(CPUIModelMessageGroup *)uiMsgGroup;
-(void)refreshMsgGroupByAppendMsgWithNewMsgID:(NSNumber *)newMsgID;
-(void)refreshMsgListWithMsgGroupID:(NSNumber *)msgGroupID;

-(void)refreshSysUnReadedCount;

@end
