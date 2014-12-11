//
//  CPOperationUserListInit.m
//  iCouple
//
//  Created by yong weiy on 12-4-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPOperationUserListInit.h"

#import "CPPTModelUserInfo.h"
#import "CPDBModelUserInfo.h"

#import "ModelConvertUtils.h"

#import "CPSystemEngine.h"
#import "CPDBManagement.h"
#import "CPUIModelManagement.h"
#import "CPUserManager.h"
#import "CPResManager.h"
#import "CPLGModelAccount.h"
#import "CPMsgManager.h"
@implementation CPOperationUserListInit


- (id) initWithType:(NSInteger)type withUserArray:(NSArray *)userArray
{
    self = [super init];
    if (self)
    {
        initType = type;
        ptUserInfoArray = userArray;
    }
    return self;
}
-(void)main
{
    @autoreleasepool 
    {
        switch (initType)
        {
            case INIT_USER_LIST_DEFAULT:
            {
                NSMutableArray *frisArray = [[NSMutableArray alloc] init];
                for(CPPTModelUserInfo *ptUserInfo in ptUserInfoArray)
                {
                    CPDBModelUserInfo *dbUserInfo = [ModelConvertUtils ptUserInfoToDb:ptUserInfo];
//                    CPLogInfo(@"%@",ptUserInfo.icon);
                    if (ptUserInfo.icon&&![@"" isEqualToString:ptUserInfo.icon]&&![ptUserInfo.icon isKindOfClass:[NSNull class]])
                    {
                        [dbUserInfo setHeaderPath:[NSString stringWithFormat:@"%@",ptUserInfo.icon]];
//                        [dbUserInfo setHeaderPath:[NSString stringWithFormat:@"%@%@",SERVER_IMG_URL_PREFIX,ptUserInfo.icon]];
                    }
                    [frisArray addObject:dbUserInfo];
                    NSLog(@"----PTuserName == %@,PTuid == %@\n---DBuserName == %@,DB uid == %@",ptUserInfo.nickName,ptUserInfo.lifeStatus,dbUserInfo.nickName,dbUserInfo.lifeStatus);
                }
                [[[CPSystemEngine sharedInstance] dbManagement] initUsersWithUserArray:frisArray 
                                                                        andAccountName:[[[CPSystemEngine sharedInstance] accountModel] loginName]];
                NSString *friendTimeStamp = [[CPSystemEngine sharedInstance] cachedMyFriendTimeStamp];
                if (friendTimeStamp)
                {
                    [[CPSystemEngine sharedInstance] backupSystemInfoWithFrisTimeStamp:friendTimeStamp];
                    [[CPSystemEngine sharedInstance] setCachedMyFriendTimeStamp:nil];
                }
                
                [[[CPSystemEngine sharedInstance] userManager] initUserList];
                [[[CPSystemEngine sharedInstance] msgManager] filterMessageGroupByFriendArray];
                [[[CPSystemEngine sharedInstance] userManager] initSysUserConver];
                
                NSArray *downloadList = [[[CPSystemEngine sharedInstance] dbManagement] findAllResourcesWillDownload];
                [[[CPSystemEngine sharedInstance] resManager] reloadDownloadCacheWithArray:downloadList];
            }
                break;
            case INIT_USER_LIST_COMMEND:
            {
                NSMutableArray *frisArray = [[NSMutableArray alloc] init];
                for(CPPTModelUserInfo *ptUserInfo in ptUserInfoArray)
                {
                    CPDBModelUserInfo *dbUserInfo = [ModelConvertUtils ptUserInfoToDb:ptUserInfo];
//                    CPLogInfo(@"%@",ptUserInfo.icon);
                    if (ptUserInfo.icon&&![@"" isEqualToString:ptUserInfo.icon]&&![ptUserInfo.icon isKindOfClass:[NSNull class]])
                    {
                        [dbUserInfo setHeaderPath:[NSString stringWithFormat:@"%@",ptUserInfo.icon]];
                        //                        [dbUserInfo setHeaderPath:[NSString stringWithFormat:@"%@%@",SERVER_IMG_URL_PREFIX,ptUserInfo.icon]];
                    }
                    [dbUserInfo setType:[NSNumber numberWithInt:USER_RELATION_COMMEND]];
                    [frisArray addObject:dbUserInfo];
                }
                [[[CPSystemEngine sharedInstance] dbManagement] initUsersCommendWithUserArray:frisArray 
                                                                               andAccountName:[[[CPSystemEngine sharedInstance] accountModel] loginName]];
                [[CPSystemEngine sharedInstance] backupSystemInfoWithHasCommendUsers:[NSNumber numberWithBool:YES]];
                [[[CPSystemEngine sharedInstance] userManager] initUserCommendList];
            }
                break;
            default:
                break;
        }
        
    }
}

@end
