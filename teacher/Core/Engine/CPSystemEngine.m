//
//  CPSystemEngine.m
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPSystemEngine.h"

#import "CPResManager.h"
#import "CPPersonalManager.h"
#import "CPMsgManager.h"
#import "CPUserManager.h"
#import "CPSystemManager.h"
#import "CPDBManagement.h"

#import "CPHttpEngine.h"
#import "CPXmppEngine.h"

#import "CPOperationDefines.h"

#import "CPLGModelAccount.h"
#import "CPUIModelPersonalInfo.h"

#import "CPUIModelManagement.h"

#import "ModelConvertUtils.h"

#import "CoreUtils.h"

#import "AbPersonModel.h"
#import "ABPersonMultiValueModel.h"
#import "AbDataManagement.h"

#import "CPPetManager.h"

#import "HPTopTipView.h"
#import "AppDelegate.h"

#import "CPKeyChain.h"

#import "CPOperationHttpMsgSend.h"
#import "CPOperationHttpMsgReSend.h"
#import "CPOperationReceiveYTZMessage.h"
#import "PalmUIManagement.h"
#define KEY_USERNAME_PASSWORD @"com.fanxer.iShuangShuang.usernamepassword"
#define KEY_USERNAME     @"com.fanxer.iShuangShuang.username"
#define KEY_PASSWORD     @"com.fanxer.iShuangShuang.password"

@interface CPSystemEngine ()
- (void) initialize;
@end

@implementation CPSystemEngine

@synthesize personalManager = personalManager_;
@synthesize msgManager = msgManager_;
@synthesize userManager = userManager_;
@synthesize resManager = resManager_;
@synthesize sysManager = sysManager_;

@synthesize httpEngine = httpEngine_;
@synthesize xmppEngine = xmppEngine_;

@synthesize dbManagement = dbManagement_;

@synthesize petManager = petManager_;
@synthesize deviceToken = deviceToken_;
@synthesize accountModel,dbPersonalInfo,queryAbTime;

@synthesize cachedMyConverTimeStamp = cachedMyConverTimeStamp_;
@synthesize cachedMyFriendTimeStamp = cachedMyFriendTimeStamp_;
@synthesize cachedPersonalTimeStamp = cachedPersonalTimeStamp_;

static CPSystemEngine *sharedInstance = nil;

- (void) initialize
{
    personalManager_ = [[CPPersonalManager alloc] init];
    msgManager_ = [[CPMsgManager alloc] init];
    userManager_ = [[CPUserManager alloc] init];
    resManager_ = [[CPResManager alloc] init];
    sysManager_ = [[CPSystemManager alloc] init];
    
    httpEngine_ = [[CPHttpEngine alloc] init];
    xmppEngine_ = [[CPXmppEngine alloc] init];
    
    dbManagement_ = [[CPDBManagement alloc] init];
    
    petManager_ = [[CPPetManager alloc] init];
    
    dbProcessingQueue = [[NSOperationQueue alloc] init];
    [dbProcessingQueue setMaxConcurrentOperationCount:OPERATION_QUEUE_DB_MAX_COUNT];
    
    accountModel = [[CPLGModelAccount alloc] init];
    
    [httpEngine_ addObserver:resManager_];
    [httpEngine_ addObserver:sysManager_];
    [httpEngine_ addObserver:userManager_];
    [httpEngine_ addObserver:msgManager_];
    [httpEngine_ addObserver:personalManager_];
    [httpEngine_ addObserver:petManager_];
    
    [xmppEngine_ addObserver:msgManager_];
#ifdef SYS_STATE_MIGR
    [xmppEngine_ addObserver:sysManager_];
#endif
    
    [xmppEngine_ setupStream];
}

#pragma mark -
#pragma mark CPSystemEngine Singleton Implementation

+ (CPSystemEngine *) sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance initialize];
    }
    
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
#pragma mark ab manager
-(BOOL)importAddrBookToDataBase
{
//    BOOL isImport = NO;
//    [AbDataManagement sharedInstance].delegate = self;
//    [[AbDataManagement sharedInstance] initAddressData];
//    NSArray *contactList = [[AbDataManagement sharedInstance] getContacts:queryAbTime];
//    CPLogInfo(@"begin import %@",queryAbTime);
//    if (contactList)
//    {
//        CPLogInfo(@"addr count is %d",[contactList count]);
//    }
//    [[[CPSystemEngine sharedInstance] dbManagement] dbBeginTransactionAbDb];
//    for(AbPersonModel *contactItem in contactList)
//    {
//        //CSLog(@"%@",contactItem.m_RecordId);
//        CPDBModelContact *dbContact = [[CPDBModelContact alloc] init];
//        [dbContact setAbPersonID:[contactItem recordID]];
//        [dbContact setHeaderPhotoPathWithData:contactItem.headerPhotoData];
//        NSString *firstName = [contactItem firstName];
//        NSString *lastName = [contactItem lastName];
//        if (!firstName)
//        {
//            firstName = @"";
//        }
//        if (!lastName)
//        {
//            lastName = @"";
//        }
//        
//        [dbContact setFullName:[NSString stringWithFormat:@"%@%@",lastName,firstName]];
//        [dbContact setFirstName:firstName];
//        [dbContact setLastName:lastName];
//        NSMutableArray *newWayList = [[NSMutableArray alloc] init];
//        NSArray *wayPhoneList = [contactItem phones];
//        for(ABPersonMultiValueModel *valueItem in wayPhoneList)
//        {
//            CPDBModelContactWay *contactWay = [[CPDBModelContactWay alloc] init];
//			[contactWay setName:[CoreUtils convertMobileLabelToAbLabel:[valueItem multiLabel]]];
//            [contactWay initMobileNumberWithData:[valueItem multiValue]];
//            if (contactWay.value&&![@"" isEqualToString:[contactWay.value stringByReplacingOccurrencesOfString:@" " withString:@""]])
//            {
//                [newWayList addObject:contactWay];
//            }
//        }
//        if ([newWayList count]>0)
//        {
//            [dbContact setContactWayList:newWayList];
//            [[[CPSystemEngine sharedInstance] dbManagement] insertContact:dbContact];
//        }
//        isImport = YES;
//    }
//    [[[CPSystemEngine sharedInstance] dbManagement] dbCommitAbDb];
//    CPLogInfo(@"end import ");
//    //取完通讯录的联系人之后，把当前的日期存储下来。
//    queryAbTime = [NSDate date];
//    [self backupSystemInfoByQueryAbTime];
//    return isImport;
    return YES;
}

-(void)importAbData{
//    BOOL isImport = NO;
//    NSArray *contactList = [[AbDataManagement sharedInstance] getContacts:queryAbTime];
//    CPLogInfo(@"begin import %@",queryAbTime);
//    if (contactList)
//    {
////        CPLogInfo(@"addr count is %d",[contactList count]);
//    }
//    [[[CPSystemEngine sharedInstance] dbManagement] dbBeginTransactionAbDb];
//    for(AbPersonModel *contactItem in contactList)
//    {
//        //CSLog(@"%@",contactItem.m_RecordId);
//        CPDBModelContact *dbContact = [[CPDBModelContact alloc] init];
//        [dbContact setAbPersonID:[contactItem recordID]];
//        [dbContact setHeaderPhotoPathWithData:contactItem.headerPhotoData];
//        NSString *firstName = [contactItem firstName];
//        NSString *lastName = [contactItem lastName];
//        if (!firstName)
//        {
//            firstName = @"";
//        }
//        if (!lastName)
//        {
//            lastName = @"";
//        }
//        
//        [dbContact setFullName:[NSString stringWithFormat:@"%@%@",lastName,firstName]];
//        NSLog(@"%@",dbContact.fullName);
//        [dbContact setFirstName:firstName];
//        [dbContact setLastName:lastName];
//        NSMutableArray *newWayList = [[NSMutableArray alloc] init];
//        NSArray *wayPhoneList = [contactItem phones];
//        for(ABPersonMultiValueModel *valueItem in wayPhoneList)
//        {
//            CPDBModelContactWay *contactWay = [[CPDBModelContactWay alloc] init];
//			[contactWay setName:[CoreUtils convertMobileLabelToAbLabel:[valueItem multiLabel]]];
//            [contactWay initMobileNumberWithData:[valueItem multiValue]];
//            if (contactWay.value&&![@"" isEqualToString:[contactWay.value stringByReplacingOccurrencesOfString:@" " withString:@""]])
//            {
//                [newWayList addObject:contactWay];
//            }
//        }
//        if ([newWayList count]>0)
//        {
//            [dbContact setContactWayList:newWayList];
//            [[[CPSystemEngine sharedInstance] dbManagement] insertContact:dbContact];
//        }
////        isImport = YES;
//    }
//    [[[CPSystemEngine sharedInstance] dbManagement] dbCommitAbDb];
//    CPLogInfo(@"end import ");
//    //取完通讯录的联系人之后，把当前的日期存储下来。
//    queryAbTime = [NSDate date];
//    [self backupSystemInfoByQueryAbTime];
//    return isImport;
}

#pragma mark key chain
-(void)saveKeyChainWithUserName:(NSString *)userName andPassword:(NSString *)password
{
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
//    [usernamepasswordKVPairs setObject:userName forKey:KEY_USERNAME];
    [usernamepasswordKVPairs setObject:password forKey:KEY_PASSWORD];
    [CPKeyChain save:KEY_USERNAME_PASSWORD data:usernamepasswordKVPairs];
}
-(NSString *)loadKeyChainWithUserPassword
{
    NSMutableDictionary *usernamepasswordKVPairs = (NSMutableDictionary *)[CPKeyChain load:KEY_USERNAME_PASSWORD];
//    NSString *userName = [usernamepasswordKVPairs objectForKey:KEY_USERNAME];
    return [usernamepasswordKVPairs objectForKey:KEY_PASSWORD];
}
#pragma mark config file API
-(NSString*) getDocumentFullName:(NSString*)fileName 
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	if (!documentsDirectory) 
    {
		return fileName;
	}
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}
-(BOOL)hasLoginUser
{
    NSString* path = [self getDocumentFullName:coupleConfigDataFilename];
    NSDictionary* communicateData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    //先判断出处于激活状态的account
    NSArray *allValues = [communicateData allValues];
    if (allValues&&[allValues count]>0)
    {
        return YES;
    }
    return NO;
}
//初始化之前登录成功的帐号信息
-(void)initAccountConfigInfo
{
    NSString* pathAb = [self getDocumentFullName:coupleConfigAbFilename];
    NSDictionary* communicateAbData = [NSMutableDictionary dictionaryWithContentsOfFile:pathAb];
    //查询本地通讯录的时候有一个就可以
    queryAbTime = [communicateAbData valueForKey:coupleConfigQueryABTime];
    CPLogInfo(@"queryAbTime   is  %@",queryAbTime);
    ///////////////////////////////////////////////////////////////////////
    NSString* path = [self getDocumentFullName:coupleConfigDataFilename];
    NSDictionary* communicateData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    //先判断出处于激活状态的account
    NSArray *allValues = [communicateData allValues];
    BOOL hasActived = NO;
    for(NSDictionary *valueDic in allValues)
    {
        NSNumber *isActived = [valueDic valueForKey:coupleConfigActived];
        if (isActived&&[isActived boolValue])
        {
            [accountModel setLoginName:[valueDic valueForKey:coupleConfigLoginName]];
            [accountModel setPwdMD5:[self loadKeyChainWithUserPassword]];
//            [accountModel setPwdMD5:[valueDic valueForKey:coupleConfigPassword]];
            [accountModel setIsAvtived:[valueDic valueForKey:coupleConfigActived]];
            [accountModel setIsVerifiedCode:[valueDic valueForKey:coupleConfigVerifiedCode]];
            [accountModel setMobileNumber:[valueDic valueForKey:coupleConfigPhoneNumber]];
            [accountModel setCanUploadAb:[valueDic valueForKey:coupleConfigCanUploadAb]];
            [accountModel setUploadAbTime:[valueDic valueForKey:coupleConfigUploadAbTime]];
            [accountModel setFriTimeStamp:[valueDic valueForKey:coupleConfigFrisTimeStamp]];
            [accountModel setConverTimeStamp:[valueDic valueForKey:coupleConfigConverTimeStamp]];
            [accountModel setMyProfileTimeStamp:[valueDic valueForKey:myProfileGetTimeStamp]];
            [accountModel setHasCommendUsers:[valueDic valueForKey:coupleConfigHasCommendUsers]];
            [accountModel setDeviceToken:[valueDic valueForKey:myDeviceToken]];
            [accountModel setIsUploadDeviceToken:[valueDic valueForKey:myisUploadDeviceToken]];
            [accountModel setHasSavePersonalInfoName:[valueDic valueForKey:hasSavePersonalName]];
            if (!accountModel.hasSavePersonalInfoName)
            {
                [accountModel setHasSavePersonalInfoName:[NSNumber numberWithBool:YES]];
            }
            activedAccountKey = [valueDic valueForKey:coupleConfigLoginName];
            hasActived = YES;
            break;
        }
    }
    if (!hasActived)
    {
        CPLogInfo(@"first user,has no actived account");
    }
}
//备份当前登录成功的帐号信息
-(void)backupSystemInfoWithAccount:(CPLGModelAccount *)account
{
    if (accountModel!=account)
    {
        accountModel = account;
    }
    if (account&&account.loginName&&![@"" isEqualToString:account.loginName])
    {
        NSString* path = [self getDocumentFullName:coupleConfigDataFilename];
        NSMutableDictionary* communicateData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if (!communicateData) 
        {
            communicateData = [NSMutableDictionary dictionaryWithCapacity:1];
        }
        else
        {
            if ([account.isAvtived boolValue])
            {
                NSArray *allValues = [communicateData allValues];
                for(NSDictionary *valueDic in allValues)
                {
                    NSString *loginName = [valueDic valueForKey:coupleConfigLoginName];
                    NSNumber *isActived = [valueDic valueForKey:coupleConfigActived];
                    
                    if (loginName){
                        if ([loginName isEqualToString:account.loginName]){
                            if ([valueDic objectForKey:coupleConfigUploadAbTime])
                                account.uploadAbTime = [valueDic valueForKey:coupleConfigUploadAbTime];
                        }else if(isActived&&[isActived boolValue]){
                            [valueDic setValue:[NSNumber numberWithBool:NO] forKey:coupleConfigActived];
                        }
                    }
                }
            }
        }
        NSMutableDictionary *activedDic = [[NSMutableDictionary alloc] init];
        [activedDic setValue:account.loginName forKey:coupleConfigLoginName];
        if (account.pwdMD5)
        {
            [self saveKeyChainWithUserName:account.loginName andPassword:account.pwdMD5];
//            [activedDic setValue:account.pwdMD5 forKey:coupleConfigPassword];
        }
        if (account.isAvtived)
        {
            [activedDic setValue:account.isAvtived forKey:coupleConfigActived];
        }
//        if (account.queryAbTime)
//        {
//            [activedDic setValue:account.queryAbTime forKey:coupleConfigQueryABTime];
//        }
        if (account.isVerifiedCode)
        {
            [activedDic setValue:account.isVerifiedCode forKey:coupleConfigVerifiedCode];
        }
        if (account.mobileNumber)
        {
            [activedDic setValue:account.mobileNumber forKey:coupleConfigPhoneNumber];
        }
//        if (account.canUploadAb)
        {
//warning init can upload ab
            [activedDic setValue:[NSNumber numberWithBool:YES] forKey:coupleConfigCanUploadAb];
//            [activedDic setValue:account.canUploadAb forKey:coupleConfigCanUploadAb];
        }
        if (account.friTimeStamp)
        {
            [activedDic setValue:account.friTimeStamp forKey:coupleConfigFrisTimeStamp];
        }
        if (account.converTimeStamp)
        {
            [activedDic setValue:account.converTimeStamp forKey:coupleConfigConverTimeStamp];
        }
        if (account.myProfileTimeStamp)
        {
            [activedDic setValue:account.myProfileTimeStamp forKey:myProfileGetTimeStamp];
        }
        if (account.uploadAbTime)
        {
            [activedDic setValue:account.uploadAbTime forKey:coupleConfigUploadAbTime];
        }
        if  (account.hasCommendUsers)
        {
            [activedDic setValue:account.hasCommendUsers forKey:coupleConfigHasCommendUsers];
        }
        if (account.deviceToken) 
        {
            [activedDic setValue:account.deviceToken forKey:myDeviceToken];
        }
        if (account.isUploadDeviceToken)
        {
            [activedDic setValue:account.isUploadDeviceToken forKey:myisUploadDeviceToken];
        }
        if (account.hasSavePersonalInfoName)
        {
            [activedDic setValue:account.hasSavePersonalInfoName forKey:hasSavePersonalName];
        }
        if (account.willCoupleName&&account.willCoupleRealtionType)
        {
            [activedDic setValue:account.willCoupleName forKey:willCoupleNameCached];
            if (account.willCoupleUserName)
            {
                [activedDic setValue:account.willCoupleUserName forKey:willCoupleUserNameCached];
            }
            [activedDic setValue:account.willCoupleRealtionType forKey:willCoupleRelationTypeCached];
        }
        else 
        {
            [activedDic removeObjectForKey:willCoupleNameCached];
            [activedDic removeObjectForKey:willCoupleRelationTypeCached];
            [activedDic removeObjectForKey:willCoupleUserNameCached];
        }
        [communicateData setValue:activedDic forKey:account.loginName];
        
        [communicateData writeToFile:path atomically:NO];
        
    }    
}
-(void)backupSystemInfoByQueryAbTime
{
    NSString* path = [self getDocumentFullName:coupleConfigAbFilename];
    NSMutableDictionary* communicateData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!communicateData) 
    {
        communicateData = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [communicateData setValue:queryAbTime forKey:coupleConfigQueryABTime];
    [communicateData writeToFile:path atomically:NO];
}
-(void)backupSystemInfoWithActived:(NSNumber *)isActived
{
    [accountModel setIsAvtived:isActived];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithFrisTimeStamp:(NSString *)friTimeStamp
{
    [accountModel setFriTimeStamp:friTimeStamp];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithConverTimeStamp:(NSString *)converTimeStamp
{
    [accountModel setConverTimeStamp:converTimeStamp];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithMyProfileTimeStamp:(NSString *)timeStamp
{
    [accountModel setMyProfileTimeStamp:timeStamp];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithAccountVerifiedCode:(NSNumber *)isVerifiedCode
{
    [accountModel setIsVerifiedCode:isVerifiedCode];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithHasCommendUsers:(NSNumber *)hasCommendUsers
{
    [accountModel setHasCommendUsers:hasCommendUsers];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithAccountUploadAb
{
    [accountModel setUploadAbTime:[CoreUtils getLongFormatWithNowDate]];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithIsUploadDeviceToken:(NSNumber *)isUpload
{
    [accountModel setIsUploadDeviceToken:isUpload];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithDeviceToken:(NSString *)deviceToken
{
    [accountModel setDeviceToken:deviceToken];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithHasSavePersonalName:(NSNumber *)hasSave
{
    [accountModel setHasSavePersonalInfoName:hasSave];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithPwd:(NSString *)pwd
{
    [accountModel setPwdMD5:pwd];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)backupSystemInfoWithCoupleName:(NSString *)coupleName 
                    andCoupleUserName:(NSString *)coupleUserName 
                      andRelationType:(NSNumber *)relationType
{
    [accountModel setWillCoupleName:coupleName];
    [accountModel setWillCoupleUserName:coupleUserName];
    [accountModel setWillCoupleRealtionType:relationType];
    [self backupSystemInfoWithAccount:accountModel];
}
-(void)initPetSysDir
{
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *accName = [accountModel loginName];
    NSString *accDir = [docDir stringByAppendingPathComponent:accName];
    
    NSString *actionDir = [accDir stringByAppendingPathComponent:@"pet/action/"];
    NSString *feelingDir = [accDir stringByAppendingPathComponent:@"pet/feeling/"];
    NSString *magicDir = [accDir stringByAppendingPathComponent:@"pet/magic/"];
    NSString *smallanimDir = [accDir stringByAppendingPathComponent:@"pet/smallanim/"];
    
    NSString *tempDir = [accDir stringByAppendingPathComponent:@"pet/temp/"];
    
    BOOL isDir = NO;
    BOOL dirExist = NO;
    dirExist = [fm fileExistsAtPath:actionDir isDirectory:&isDir];
    if( !dirExist || !isDir )
    {
        [fm createDirectoryAtPath:actionDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    dirExist = [fm fileExistsAtPath:feelingDir isDirectory:&isDir];
    if( !dirExist || !isDir )
    {
        [fm createDirectoryAtPath:feelingDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    dirExist = [fm fileExistsAtPath:magicDir isDirectory:&isDir];
    if( !dirExist || !isDir )
    {
        [fm createDirectoryAtPath:magicDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    dirExist = [fm fileExistsAtPath:smallanimDir isDirectory:&isDir];
    if( !dirExist || !isDir )
    {
        [fm createDirectoryAtPath:smallanimDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    dirExist = [fm fileExistsAtPath:tempDir isDirectory:&isDir];
    if( !dirExist || !isDir )
    {
        [fm createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
}
-(void)xmppReconnect{
    [xmppEngine_ manualReconnect];
}
-(NSString *)getAccountName
{
    return [accountModel loginName];
}
-(void)initAccountDbData
{
    if (accountModel.loginName&&![@"" isEqualToString:accountModel.loginName])
    {        
        [self initPetSysDir];
        [dbManagement_ initializeWithLoginName:accountModel.loginName];
    }
}
-(void)setAccountModelWithAutoLogin:(BOOL)isAutoLogin
{
    [accountModel setIsAutoLogin:isAutoLogin];
}
-(NSInteger)sysStatusCode
{
    return [[CPUIModelManagement sharedInstance] sysOnlineStatus];
}
//清除之前用户登录或者注册成功的标记
-(void)clearAccountTagData
{
    NSString* path = [self getDocumentFullName:coupleConfigDataFilename];
    NSMutableDictionary* communicateData = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!communicateData) 
    {
        communicateData = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    else
    {
        NSArray *allValues = [communicateData allValues];
        for(NSDictionary *valueDic in allValues)
        {
            NSNumber *isActived = [valueDic valueForKey:coupleConfigActived];
            if (isActived&&[isActived boolValue])
            {
                [valueDic setValue:[NSNumber numberWithBool:NO] forKey:coupleConfigActived];
            }
        }
        [communicateData writeToFile:path atomically:NO];
    }
}
#pragma mark tool method
-(BOOL)writeToFileWithData:(NSData *)data file_name:(NSString *)fileName account:(NSString *)accountName file_type:(NSString *)fileType
{
    BOOL isSucess = NO;
    if (data)
    {
        NSError *error;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *accountPath = [NSString stringWithFormat:@"%@/",accountName];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:accountPath];
        
        BOOL success = [fm createDirectoryAtPath:writableDBPath withIntermediateDirectories:YES attributes:nil error:&error];
        CPLogInfo(@"db's path is  %@",writableDBPath);
        if(!success)
        {
            CPLogError(@"error: %@", [error localizedDescription]);
        }
        NSString *path = [NSString stringWithFormat:@"%@/%@.%@",writableDBPath,fileName,fileType];
        isSucess = [data writeToFile:path atomically:YES];
    }
    return isSucess;
}
#pragma mark operation control
-(void)addDbQueueWithOperation:(NSOperation *)operation
{
    [dbProcessingQueue addOperation:operation];
}
-(void)clearAllOperationQueue
{
    [dbProcessingQueue cancelAllOperations];
}

-(void)inActiveAllOperationQueue
{
    [dbProcessingQueue setSuspended:YES];
}
-(void)activeAllOperationQueue
{
    [dbProcessingQueue setSuspended:NO];
}

#pragma mark add operation with resource API
-(void)downloadResWithID:(NSNumber *)localResID andResCode:(NSNumber *)resCode andTimeStamp:(NSString *)timeStamp
andTmpFilePath:(NSString *)filePath
{
    CPOperationResDownloadResponse *operation = [[CPOperationResDownloadResponse alloc] initWithResID:localResID 
                                                                                           andResCode:resCode 
                                                                                         andTimeStamp:timeStamp 
                                                                                       andTmpFilePath:filePath];
    [self addDbQueueWithOperation:operation];
}
-(void)uploadResWithResID:(NSNumber *)localResID andResCode:(NSNumber *)resCode url:(NSString *)url andTimeStamp:(NSString *)timeStamp
{
    CPOperationResUploadResponse *operation = [[CPOperationResUploadResponse alloc] initWithResID:localResID 
                                                                                       andResCode:resCode
                                                                                          res_url:url
                                                                                     andTimeStamp:timeStamp];
    [self addDbQueueWithOperation:operation];
}
-(void)downloadWithRes:(CPDBModelResource *)dbRes
{
    CPOperationResDownload *operation = [[CPOperationResDownload alloc] initWithRes:dbRes];
    [self addDbQueueWithOperation:operation];
}
-(void)uploadWithRes:(CPDBModelResource *)dbRes up_data:(NSData *)uploadData
{
    CPOperationResUpload *operation = [[CPOperationResUpload alloc] initWithRes:dbRes res_data:uploadData];
    [self addDbQueueWithOperation:operation];
}
#pragma mark add operation with sys init API
-(void)initAppDbData
{
    CPOperationSysInit *operationPersonal = [[CPOperationSysInit alloc] initWithType:SYS_INIT_TYPE_INIT_PERSONAL];
    [operationPersonal setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operationPersonal];
    CPOperationSysInit *operationUserList = [[CPOperationSysInit alloc] initWithType:SYS_INIT_TYPE_INIT_USER_LIST];
    [operationUserList setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operationUserList];
    CPOperationSysInit *operation = [[CPOperationSysInit alloc] initWithType:0];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)initAbData
{
    CPOperationSysInit *operation = [[CPOperationSysInit alloc] initWithType:SYS_INIT_TYPE_IMPORT_AB];
    [self addDbQueueWithOperation:operation];
}
-(void)initLoginedData
{
    CPOperationSysInit *operation = [[CPOperationSysInit alloc] initWithType:SYS_INIT_TYPE_LOGED_INIT];
    [self addDbQueueWithOperation:operation];
}
-(void)initSysPreInitData
{
    CPOperationSysInit *operation = [[CPOperationSysInit alloc] initWithType:SYS_INIT_TYPE_PRE_INIT];
    [self addDbQueueWithOperation:operation];
}
-(void)initSysPreInitData_V
{
    CPOperationSysInit *operation = [[CPOperationSysInit alloc] initWithType:SYS_INIT_TYPE_PRE_INIT_BG_DLD_PETRES];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoByOperation:(CPDBModelPersonalInfo *)personalInfo
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithInfo:personalInfo];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoByOperationWithObj:(NSObject *)personalInfoObj
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithObj:personalInfoObj];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoDataByOperation:(CPDBModelPersonalInfoData *)personalInfoData
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithPersonalInfoData:personalInfoData];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoNameUiByOperation:(CPUIModelPersonalInfo *)personalInfo
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithPersonalInfo:personalInfo 
                                                                                           andType:UPDATE_PERSONAL_TYPE_NAME];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoBabyUiByOperation:(CPUIModelPersonalInfo *)personalInfo
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithPersonalInfo:personalInfo 
                                                                                           andType:UPDATE_PERSONAL_TYPE_BABY];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoSingleTimeUiByOperation:(CPUIModelPersonalInfo *)personalInfo
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithPersonalInfo:personalInfo 
                                                                                           andType:UPDATE_PERSONAL_TYPE_SINGLE_TIME];
    [self addDbQueueWithOperation:operation];
}
-(void)updatePersonalInfoRecentUiByOperation:(CPUIModelPersonalInfo *)personalInfo
{
    CPOperationPersonalUpdate *operation = [[CPOperationPersonalUpdate alloc] initWithPersonalInfo:personalInfo 
                                                                                           andType:UPDATE_PERSONAL_TYPE_RECENT];
    [self addDbQueueWithOperation:operation];
}
-(void)updateUserInfoByOperationWithObj:(NSObject *)userInfoObj andUserName:(NSString *)userName
{
    CPOperationUserInfoUpdate *operation = [[CPOperationUserInfoUpdate alloc] initWithObj:userInfoObj withUserName:userName];
    [self addDbQueueWithOperation:operation];
}
-(void)updateUserInfoDataByOperation:(CPDBModelUserInfoData *)userInfoData andUserName:(NSString *)userName
{
    CPOperationUserInfoUpdate *operation = [[CPOperationUserInfoUpdate alloc] initWithUserInfoData:userInfoData withUserName:userName];
    [self addDbQueueWithOperation:operation];
}
-(void)uploadAbByOperation
{
    CPOperationUploadAb *operation = [[CPOperationUploadAb alloc] init];
    [self addDbQueueWithOperation:operation];
}
-(void)initUserListByOperationWithUsers:(NSArray *)userArray
{
    CPOperationUserListInit *operation = [[CPOperationUserListInit alloc] initWithType:INIT_USER_LIST_DEFAULT withUserArray:userArray];
    [self addDbQueueWithOperation:operation];
}
-(void)initUserCommendListByOperationWithUsers:(NSArray *)userArray
{
    CPOperationUserListInit *operation = [[CPOperationUserListInit alloc] initWithType:INIT_USER_LIST_COMMEND withUserArray:userArray];
    [self addDbQueueWithOperation:operation];
}
-(void)deleteUserRelationWithUserName:(NSString *)userName
{
    CPOperationUpdateUserRelation *operation = [[CPOperationUpdateUserRelation alloc] initWithType:UPDATE_USER_RELATION_DEL 
                                                                                      withUserName:userName 
                                                                                      relationType:0];
    [self addDbQueueWithOperation:operation];
}
-(void)updateUserRelationWithUserName:(NSString *)userName relationType:(NSInteger)relationType
{
    CPOperationUpdateUserRelation *operation = [[CPOperationUpdateUserRelation alloc] initWithType:UPDATE_USER_RELATION_UPDATE 
                                                                                      withUserName:userName 
                                                                                       relationType:relationType];
    [self addDbQueueWithOperation:operation];
}
-(void)sendMsgByOperationWithGroup:(CPUIModelMessageGroup *)uiMsgGroup andMsg:(CPUIModelMessage *)uiMsg
{
    CPOperationHttpMsgSend *operation = [[CPOperationHttpMsgSend alloc] initWithMsg:uiMsg andMsgGroup:uiMsgGroup];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)sendMsgByOperationWithGroupID:(NSNumber *)msgGroupID andMsg:(CPUIModelMessage *)uiMsg
{
    CPOperationHttpMsgSend *operation = [[CPOperationHttpMsgSend alloc] initWithMsg:uiMsg andMsgGroupID:msgGroupID];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)reSendMsgByOperationWithMsg:(CPUIModelMessage *)uiMsg andMsgGroup:(CPUIModelMessageGroup *)msgGroup
{
    CPOperationHttpMsgReSend *operation = [[CPOperationHttpMsgReSend alloc] initWithMsg:uiMsg andMsgGroup:msgGroup];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)createConversationWithUsers:(NSArray *)userArray andMsgGroups:(NSArray *)msgGroups andType:(NSInteger)type
{
    CPOperationConverInit *operation = [[CPOperationConverInit alloc] initWithUsers:userArray andMsgGroups:msgGroups andType:type];
    [self addDbQueueWithOperation:operation];
}
-(void)updateConversationWithPtModels:(NSArray *)ptModels
{
    CPOperationConverInit *operation = [[CPOperationConverInit alloc] initWithPtGroups:ptModels];
    [self addDbQueueWithOperation:operation];
}
-(void)receiveMsgByOperationWithMsgs:(NSArray *)msgs
{
    CPOperationMsgReceive *operation = [[CPOperationMsgReceive alloc] initWithMsgs:msgs];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}
//2014-7
-(void)receiveNoticeMsgByOperationWithNotices:(NSArray *)notices{
    CPOperationReceiveYTZMessage *operation = [[CPOperationReceiveYTZMessage alloc]initWithMsgs:notices];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}

-(void)updateMsgSendResponseByOperationWithID:(NSNumber *)msgID andStatus:(NSNumber *)status
{
    CPOperationMsgSendResponse *operation = [[CPOperationMsgSendResponse alloc] initWithMsgID:msgID andStatus:status];
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)removeWillSendMsgsByOperationWithIDs:(NSArray *)msgIDs
{
    CPOperationMsgDel *operation = [[CPOperationMsgDel alloc] initWithWillMsgIDs:msgIDs];
    [self addDbQueueWithOperation:operation];
}
-(void)createConversationByOperationWithObj:(NSObject *)obj
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithData:obj withType:UPDATE_CONVER_TYPE_INSERT];
    [self addDbQueueWithOperation:operation];
}
-(void)createConversationSelfByOperationWithObj:(NSObject *)obj
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithData:obj withType:UPDATE_CONVER_TYPE_CREATE];
    [self addDbQueueWithOperation:operation];
}
-(void)updateConversationMemByOperationWithObj:(NSObject *)obj
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithData:obj withType:UPDATE_CONVER_TYPE_UPDATE];
    [self addDbQueueWithOperation:operation];
}
-(void)updateConversationNameByOperationWithObj:(NSObject *)obj andGroupName:(NSString *)groupName
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithID:obj 
                                                                            withType:UPDATE_CONVER_TYPE_GROUP_NAME 
                                                                        andGroupName:groupName];
    [self addDbQueueWithOperation:operation];
}
-(void)upgradeConversationNameByOperationWithObj:(NSObject *)obj andGroupName:(NSString *)groupName
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithID:obj
                                                                            withType:UPDATE_CONVER_TYPE_UPGRADE 
                                                                        andGroupName:groupName];
    [self addDbQueueWithOperation:operation];
}
-(void)removeConversationByOperationWithObj:(NSObject *)obj
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithData:obj withType:UPDATE_CONVER_TYPE_REMOVE];
    [self addDbQueueWithOperation:operation];
}
-(void)deleteMessageGroupByOperationWithObj:(NSObject *)obj
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithData:obj withType:UPDATE_CONVER_TYPE_DELETE];
    [self addDbQueueWithOperation:operation];
}
//2014-7
-(void)deleteNotifyMessageGroupByOperationWithObj:(NSObject *)obj
{
    CPOperationConverUpdate *operation = [[CPOperationConverUpdate alloc] initWithData:obj withType:UPDATE_CONVER_TYPE_NOTIFY_DELETE];
    [self addDbQueueWithOperation:operation];
}
-(void)getMsgListPagedByOperationWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    CPOperationMsgListByPage *operation = [[CPOperationMsgListByPage alloc] initWithMsgGroup:uiMsgGroup];
    [self addDbQueueWithOperation:operation];
}
-(void)addGroupMemsByOperationWithGroupServerID:(NSString *)groupServerID andUpdateNams:(NSArray *)updateNames
{
    CPOperationConverMemberUpdate *operation = [[CPOperationConverMemberUpdate alloc] initWithGroupServerID:groupServerID
                                                                                                   withType:UPDATE_CONVER_MEM_TYPE_ADD 
                                                                                                   andUsers:updateNames];
    [self addDbQueueWithOperation:operation];
}
-(void)removeGroupMemsByOperationWithGroupServerID:(NSString *)groupServerID andUpdateNams:(NSArray *)updateNames
{
    CPOperationConverMemberUpdate *operation = [[CPOperationConverMemberUpdate alloc] initWithGroupServerID:groupServerID
                                                                                                   withType:UPDATE_CONVER_MEM_TYPE_REMOVE 
                                                                                                   andUsers:updateNames];
    [self addDbQueueWithOperation:operation];
}
-(void)receiveSysMsgByOperationWithXmppMsgs:(NSArray *)xmppMsgs
{
    CPOperationSysMsg *operation = [[CPOperationSysMsg alloc] initWithSys:xmppMsgs];
    [self addDbQueueWithOperation:operation];
}
-(void)updateMsgByOperationWithMsg:(CPUIModelMessage *)uiMsg
{
    CPOperationMsgUpdate *operation = [[CPOperationMsgUpdate alloc] initWithMsg:uiMsg andType:MSG_UPDATE_TYPE_DN_RES];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)updateMsgAudioReadedByOperationWithMsg:(CPUIModelMessage *)uiMsg
{
    CPOperationMsgUpdate *operation = [[CPOperationMsgUpdate alloc] initWithMsg:uiMsg andType:MSG_UPDATE_TYPE_AUDIO_READED];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)markMsgGroupReadedByOperationWithMsgGroup:(CPUIModelMessageGroup *)uiMsgGroup
{
    CPOperationMsgUpdate *operation = [[CPOperationMsgUpdate alloc] initWithMsgGroup:uiMsgGroup];
    [operation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self addDbQueueWithOperation:operation];
}
-(void)responseActionSysMsgByOperationWithMsg:(CPUIModelMessage *)uiMsg andActionType:(NSInteger)actionType
{
    CPOperationMsgUpdate *operation = [[CPOperationMsgUpdate alloc] initWithMsg:uiMsg 
                                                                        andType:MSG_UPDATE_TYPE_SYS_REQ_ACTION 
                                                                  andActionType:actionType];
    [self addDbQueueWithOperation:operation];
}
#pragma mark personal API

#pragma mark user API

#pragma mark msg API

#pragma mark petsys API
-(void)downloadPetResWithContext:(NSObject *)contextObj
{
    CPOperationPetResDownload *op = [[CPOperationPetResDownload alloc] initWithContextObj:contextObj];
//    [op setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:op];
}

-(void)downloadPetRes:(NSObject *)resOjb ofType:(NSInteger)dldType
{
    CPOperationPetResDownload *op = [[CPOperationPetResDownload alloc] initWithObj:resOjb andType:dldType];
    //    [op setQueuePriority:NSOperationQueuePriorityHigh];
    [self addDbQueueWithOperation:op];
}

-(void)updatePetResourceDataWithResult:(NSNumber *)resultCode andResID:(NSString *)resID andObj:(NSObject *)obj
{
    CPOperationPetResDownloadResult *op = [[CPOperationPetResDownloadResult alloc] initWithResultCode:resultCode andRes:resID andContextObj:obj];
    [op setQueuePriority:NSOperationQueuePriorityLow];
    [self addDbQueueWithOperation:op];
}

#pragma mark system API
-(void)uploadDeviceToken
{
    if (accountModel.isUploadDeviceToken) 
    {
        return;
    }
    NSMutableString *deviceTokenStr = [[NSMutableString alloc] initWithFormat:@"%@",self.deviceToken];
    CPLogInfo(@"%@",deviceTokenStr);
    if([CoreUtils stringIsNotNull:deviceTokenStr])
    {
        [deviceTokenStr deleteCharactersInRange:NSMakeRange(0, 1)];
        [deviceTokenStr deleteCharactersInRange:NSMakeRange([deviceTokenStr length]-1, 1)];
        [sysManager_ uploadDeviceToken:[deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
}
-(void)autoLogin
{
    if (accountModel.loginName&&![@"" isEqualToString:accountModel.loginName])
    {
        if ( nil != accountModel.pwdMD5 && ![accountModel.pwdMD5 isEqualToString:@""]) {
            //auto login
            [sysManager_ autoLogin];
        }else{
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate launchLogin];
        }
    }
}
-(void)sysLogoutAndGotoLoginWithDesc:(NSString *)desc
{
    [[HPTopTipView shareInstance] showMessage:desc];
    [[CPSystemEngine sharedInstance] sysLogout];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate launchLogin];
}
-(void)clearCachedData
{
    //    [resManager_ clearResCachedData];
    CPLogInfo(@"cancelAllOperations------%d",[dbProcessingQueue operationCount]);
    [dbProcessingQueue cancelAllOperations];
    if([dbProcessingQueue operationCount]>0)
    [dbProcessingQueue waitUntilAllOperationsAreFinished];
    CPLogInfo(@"waitUntilAllOperationsAreFinished--------%d",[dbProcessingQueue operationCount]);
    accountModel = nil;
    dbPersonalInfo = nil;
    [[CPUIModelManagement sharedInstance] setFriendArray:nil];
    [[CPUIModelManagement sharedInstance] setUiPersonalInfo:nil];
    [[CPUIModelManagement sharedInstance] setUserMessageGroupList:nil];
    [[CPUIModelManagement sharedInstance] setUserMsgGroup:nil];
    [[CPUIModelManagement sharedInstance] setFriendCommendArray:nil];
    [[CPUIModelManagement sharedInstance] setFriendMsgUnReadedCount:0];
    [[CPUIModelManagement sharedInstance] setCoupleMsgUnReadedCount:0];
    [[CPUIModelManagement sharedInstance] setClosedMsgUnReadedCount:0];
    [[CPUIModelManagement sharedInstance] setCoupleMsgGroup:nil];
    [[CPUIModelManagement sharedInstance] setCoupleModel:nil];
    [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_NO_LOGINED];
    
    [[CPSystemEngine sharedInstance] updateTagByUsers];
    [[CPSystemEngine sharedInstance] updateTagByPersonalInfo];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroupList];
    [[CPSystemEngine sharedInstance] updateTagByFriendMsgUnReadedCount:0];
    [[CPSystemEngine sharedInstance] updateTagByClosedMsgUnReadedCount:0];
    [[CPSystemEngine sharedInstance] updateTagByCoupleMsgUnReadedCount:0];
    [[CPSystemEngine sharedInstance] updateTagByCoupleMsgGroup];
    [[CPSystemEngine sharedInstance] updateTagByMsgGroup];
    [[CPSystemEngine sharedInstance] updateTagByCouple];
    
    [[[CPSystemEngine sharedInstance] resManager] clearResCachedData];
    [[[CPSystemEngine sharedInstance] petManager] clearCache];
    
    [dbManagement_ clearDbCache];
    [dbManagement_ closeAccountDB];
}
-(void)closeConnection
{
    NSString * shortDeviceTokenStr = nil;
    NSMutableString *deviceTokenStr = [[NSMutableString alloc] initWithFormat:@"%@",self.deviceToken];
    CPLogInfo(@"%@",deviceTokenStr);
    if([CoreUtils stringIsNotNull:deviceTokenStr])
    {
        [deviceTokenStr deleteCharactersInRange:NSMakeRange(0, 1)];
        [deviceTokenStr deleteCharactersInRange:NSMakeRange([deviceTokenStr length]-1, 1)];
        shortDeviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    }

    [httpEngine_ logoutForModule:[self class] withDeviceToken:shortDeviceTokenStr];
    [xmppEngine_ disconnect];
}
-(void)sysLogout
{
    [self backupSystemInfoWithActived:[NSNumber numberWithInt:NO]];
    [self closeConnection];
    [self clearCachedData];
}
-(void)initSystem
{
    [self initAccountConfigInfo];
    [self initAbData];
    //init db manager
    [self initAccountDbData];
    if (accountModel.loginName&&![@"" isEqualToString:accountModel.loginName])
    {
        [self initAppDbData];
    }
#ifndef SYS_STATE_MIGR
    [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_NO_LOGINED];
    
    if (accountModel.isVerifiedCode) 
    {
        if (![accountModel.isVerifiedCode boolValue]) 
        {
            [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_NO_ACTIVE];
        }
        else 
        {
            [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_LOGING];
        }
    }
    CPLogInfo(@"account actived status is %d",[[CPUIModelManagement sharedInstance] sysOnlineStatus]);
#else
    if (accountModel.isVerifiedCode) 
    {
        if (![accountModel.isVerifiedCode boolValue]) 
        {
            [[CPUIModelManagement sharedInstance] setAccountState:ACCOUNT_STATE_INACTIVE];
        }
    }
    else
    {
        [[CPUIModelManagement sharedInstance] setAccountState:ACCOUNT_STATE_NEVER_LOGIN];
    }
    
    CPLogInfo(@"account actived status is %d",[[CPUIModelManagement sharedInstance] accountState]);
#endif
    
    //这里不做autoLogin
    if (accountModel)
    {
        CPUIModelPersonalInfo *uiPersonalInfo = [[CPUIModelPersonalInfo alloc] init];
        [uiPersonalInfo setMobileNumber:accountModel.mobileNumber];
//        [uiPersonalInfo set
        [[CPUIModelManagement sharedInstance] setUiPersonalInfo:uiPersonalInfo];
    }
    CPLogInfo(@"%@",accountModel.getSelfBgFilePath);
    CPLogInfo(@"%@",accountModel.getSelfHeaderFilePath);
    CPLogInfo(@"%@",accountModel.getSelfCoupleFilePath);
    CPLogInfo(@"%@",accountModel.getSelfBabyFilePath);

    //test system info
    /**
     CPLGModelAccount *testACcountModel = [[CPLGModelAccount alloc] init];
     [testACcountModel setLoginName:@"hahaha5"];
     [testACcountModel setIsAvtived:[NSNumber numberWithBool:YES]];
     [testACcountModel setQueryAbTime:[NSNumber numberWithLongLong:123123123]];
     [testACcountModel setPwdMD5:@"YUTUYTUYTUYTUYTY"];
     [self backupSystemInfoWithAccount:testACcountModel];
     **/
    //add download res test data
//    CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
//    [dbRes setFileName:@"112.png"];
//    [dbRes setFilePrefix:@"header/"];
//    [dbRes setMark:[NSNumber numberWithInt:MARK_UPLOAD]];
////    [dbRes setServerUrl:@"http://www.krazytech.com/wp-content/uploads/iphone-5-1.jpeg"];
//    [dbManagement_ insertResource:dbRes];
    
    
//    [self initSystemData];
}

-(void)updateAccountModelWithName:(NSString *)account pwd:(NSString *)password
{
    BOOL oldIsAutoLogin = NO;
    if (accountModel.loginName&&[accountModel.loginName isEqualToString:account])
    {
        [accountModel setPwdMD5:password];
        return;
    }
    if (accountModel)
    {
        oldIsAutoLogin = accountModel.isAutoLogin;
        accountModel = nil;
    }
    accountModel = [[CPLGModelAccount alloc] init];
    [accountModel setLoginName:account];
    [accountModel setPwdMD5:password];
    [accountModel setIsAutoLogin:oldIsAutoLogin];
}
-(void)initPersonalData:(CPDBModelPersonalInfo *)dbPersonal
{
    self.dbPersonalInfo = dbPersonal;
    __block CPUIModelPersonalInfo * uiPersonal = [ModelConvertUtils dbPersonalInfoToUi:self.dbPersonalInfo];
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUiPersonalInfo:uiPersonal];
        [[CPUIModelManagement sharedInstance] setUiPersonalInfoTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
//    [self performSelectorOnMainThread:@selector(notifyPersonalUpdateWithModel:) withObject:dbPersonal waitUntilDone:YES];
}
-(void)initPersonalDataMainThread:(CPDBModelPersonalInfo *)dbPersonal
{
    self.dbPersonalInfo = dbPersonal;
    __block CPUIModelPersonalInfo * uiPersonal = [ModelConvertUtils dbPersonalInfoToUi:self.dbPersonalInfo];
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUiPersonalInfo:uiPersonal];
        [[CPUIModelManagement sharedInstance] setUiPersonalInfoTag:0];
    };
    dispatch_sync(dispatch_get_main_queue(), updateTagBlock);
    //    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    //    [self performSelectorOnMainThread:@selector(notifyPersonalUpdateWithModel:) withObject:dbPersonal waitUntilDone:YES];
}
-(void)notifyPersonalUpdateWithModel:(CPDBModelPersonalInfo *)dbPersonal
{
    CPUIModelPersonalInfo * uiPersonal = [ModelConvertUtils dbPersonalInfoToUi:self.dbPersonalInfo];
    [[CPUIModelManagement sharedInstance] setUiPersonalInfo:uiPersonal];
    [[CPUIModelManagement sharedInstance] setUiPersonalInfoTag:0];
}
#pragma mark get sys app status
-(BOOL)isSysOnline
{
    return [[CPUIModelManagement sharedInstance] sysOnlineStatus]==SYS_STATUS_ONLINE;
}
#pragma mark refresh tag
-(void)updateTagWithLoginResponseCode:(NSNumber *)code res_desc:(NSString *)desc
{
    [[CPUIModelManagement sharedInstance] setLoginDesc:desc];
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setLoginCode:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagWithRegResponseCode:(NSNumber *)code res_desc:(NSString *)desc
{
    [[CPUIModelManagement sharedInstance] setRegisterDesc:desc];
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setRegisterCode:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagWithActiveResponseCode:(NSNumber *)code res_desc:(NSString *)desc
{
    [[CPUIModelManagement sharedInstance] setActiveDesc:desc];
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setActiveCode:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagWithBindResponseCode:(NSNumber *)code  res_desc:(NSString *)desc
{
    [[CPUIModelManagement sharedInstance] setBindDesc:desc];
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setBindCode:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagWithAppStateCode:(NSNumber *)code res_desc:(NSString *)desc
{
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setSysOnlineStatus:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}

#ifdef SYS_STATE_MIGR
-(void)updateTagWithAccountSate:(NSNumber *)code res_desc:(NSString *)desc
{
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setAccountState:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
#endif

-(void)updateTagWithContacts:(NSArray *)contacts
{
    CPLogInfo(@"begin refresh contact array with UI Model %d",[contacts count]);
    [[CPUIModelManagement sharedInstance] setContactArray:contacts];
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setContactUpdateTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByUsers
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFriendTag:[NSNumber numberWithInt:UPDATE_FRIEND_ARRAY_TAG_DEFAULT]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}

//2014-7
-(void)updateTagByNoticeMsg{
    dispatch_block_t updateTagBlock = ^{
        [[PalmUIManagement sharedInstance] setNoticeArrayTag:[NSNumber numberWithInt:0]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByFriendMsgUnReadedCount{
    __block NSInteger count = [CPUIModelManagement sharedInstance].friendMsgUnReadedCount;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFriendMsgUnReadedCount:count];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}


-(void)updateTagByUsersHeaderImgWithUserID:(NSNumber *)userID
{
    __block NSNumber * updateUserID = userID;
    dispatch_block_t updateTagBlock = ^{
        if (!updateUserID) 
        {
            updateUserID = [NSNumber numberWithInt:0];
        }
        [[CPUIModelManagement sharedInstance] setFriendTag:updateUserID];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByCouple
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleModelWithTag:) 
                           withObject:[NSNumber numberWithInt:0]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByUsersCommend
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFriendCommendTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByPersonalInfo
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUiPersonalInfoTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
//    [self performSelectorOnMainThread:@selector(notifyPersonalUpdate) withObject:nil waitUntilDone:YES];
}
-(void)updateTagByModifyFriWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setModifyFriendTypeDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByResponseActionWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setResponseActionDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByFindMobileIsUserWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFindMobileIsUserDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByGetFriendProfileWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setGetFriendProfileDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByGetTempResServerUrlWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setResourceServerUrlDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByFindMutualUsersWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFindMutualFriendDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByDeleteFriendsWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setDeleteFriendDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByMsgGroupList
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupListTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupListWithTag:) 
                           withObject:[NSNumber numberWithInt:0]
                        waitUntilDone:YES];
     **/
}

/********************add relationDel KVO by wang shuo*************************/
-(void)updateTagByUserRelationDel
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserRelationDelTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
/********************add relationDel KVO by wang shuo*************************/

-(void)updateTagByMsgGroup
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:0]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroup
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:0]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroupData
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_GROUP];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_GROUP]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupData
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_GROUP];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_GROUP]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupDel
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_DEL];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_DEL]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupMsgAppend
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroupMsgAppend
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupMsgInsert
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroupMsgInsert
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupMsgInsertEnd
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroupMsgInsertEnd
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupMsgReload
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroupMsgReload
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupMemList
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_MEM_LIST];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MEM_LIST]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByCoupleMsgGroupMemList
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:UPDATE_USER_GROUP_TAG_MEM_LIST];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyCoupleMsgGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_MEM_LIST]
                        waitUntilDone:YES];
     **/
}
-(void)updateTagByMsgGroupOnly
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:UPDATE_USER_GROUP_TAG_ONLY_REFRESH];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    /**
    [self performSelectorOnMainThread:@selector(notifyMessageGroupWithTag:) 
                           withObject:[NSNumber numberWithInt:UPDATE_USER_GROUP_TAG_ONLY_REFRESH]
                        waitUntilDone:YES];
     **/
}


-(void)updateTagByCreateMsgGroupWithCode:(NSNumber *)code
{
    __block NSNumber * resCode = code;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCreateMsgGroupTag:[resCode intValue]];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagBySysMsgList
{
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setSysMsgListTag:0];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByAddGroupMemWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setAddGroupMemDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByRemoveGroupMemWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setRemoveGroupMemDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByQuitGroupWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setQuitGroupDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByAddFavoriteGroupWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setAddFavoriteGroupDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByModifyGroupNameWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setModifyGroupNameDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByChangePwdWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setChangePwdResDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByResetPwdGetCodeWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setResetPwdGetCodeResDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByResetPwdPostWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setResetPwdPostResDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByFriendMsgUnReadedCount:(NSInteger )unReadedCount
{
    __block NSInteger count = unReadedCount;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFriendMsgUnReadedCount:count];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByCoupleMsgUnReadedCount:(NSInteger )unReadedCount
{
    __block NSInteger count = unReadedCount;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCoupleMsgUnReadedCount:count];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByClosedMsgUnReadedCount:(NSInteger )unReadedCount
{
    __block NSInteger count = unReadedCount;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setClosedMsgUnReadedCount:count];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}

-(void)updateTagForPetDataChange:(NSDictionary *)dict
{
    __block NSDictionary * bDict = dict;
    
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setPetDataDict:bDict];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByTipsNewMsgWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setTipsNewMsgDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
-(void)updateTagByCheckUpdateWithDic:(NSDictionary *)dicData
{
    __block NSDictionary *dic = dicData;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setCheckUpdateResponseDic:dic];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
}
#pragma mark notify method
-(void)notifyMessageGroupWithTag:(NSNumber *)tag
{
    [[CPUIModelManagement sharedInstance] setUserMsgGroupTag:[tag integerValue]];
}
-(void)notifyMessageGroupListWithTag:(NSNumber *)tag
{
    [[CPUIModelManagement sharedInstance] setUserMsgGroupListTag:[tag integerValue]];
}
-(void)notifyCoupleMsgGroupWithTag:(NSNumber *)tag
{
    [[CPUIModelManagement sharedInstance] setCoupleMsgGroupTag:[tag integerValue]];
}
-(void)notifyCoupleModelWithTag:(NSNumber *)tag
{
    [[CPUIModelManagement sharedInstance] setCoupleTag:[tag integerValue]];
}
-(void)notifyPersonalUpdate
{
    [[CPUIModelManagement sharedInstance] setUiPersonalInfoTag:0];
}
#pragma mark
-(void)updateSysOnlineStatus
{
    [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_ONLINE];
}
-(void)updateSysOfflineStatus
{
    [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_OFFLINE];
}

-(void)dealloc
{
    [httpEngine_ removeObserver:resManager_];
    [httpEngine_ removeObserver:sysManager_];
    [httpEngine_ removeObserver:userManager_];
    [httpEngine_ removeObserver:msgManager_];
    [httpEngine_ removeObserver:personalManager_];
    [httpEngine_ removeObserver:petManager_];
    
    [xmppEngine_ removeObserver:msgManager_];

}

@end
