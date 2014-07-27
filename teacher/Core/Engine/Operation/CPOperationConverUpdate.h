//
//  CPOperationConverUpdate.h
//  iCouple
//
//  Created by yong wei on 12-4-28.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "CPOperation.h"
typedef enum
{
    UPDATE_CONVER_TYPE_DEFAULT = 0,
    UPDATE_CONVER_TYPE_CREATE = 1,
    UPDATE_CONVER_TYPE_INSERT = 2,
    UPDATE_CONVER_TYPE_UPDATE = 3,
    UPDATE_CONVER_TYPE_GROUP_NAME = 4,
    UPDATE_CONVER_TYPE_REMOVE = 5,
    UPDATE_CONVER_TYPE_UPGRADE = 6,
    UPDATE_CONVER_TYPE_DELETE = 7,
    //notifyMessage change
    UPDATE_CONVER_TYPE_NOTIFY_DELETE = 8,
    UPDATE_CONVER_TYPE_NOTIFY_UPDATE = 9
    //notifyMessage change
}UpdateConverType;

@interface CPOperationConverUpdate : CPOperation
{
    NSInteger updateType;
    NSObject *groupObj;
    NSString *groupName;
}
- (id) initWithData:(NSObject *)obj withType:(NSInteger)type;
- (id) initWithID:(NSObject *)obj withType:(NSInteger)type andGroupName:(NSString *)name;

@end
