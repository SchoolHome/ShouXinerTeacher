//
//  CPSystemManager.m
//  icouple
//
//  Created by yong wei on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  主要包含注册、登录、设置等接口

#import "UIDevice+IdentifierAddition.h"
#import "CPSystemManager.h"
#import "CPUIModelRegisterInfo.h"
#import "CPHttpEngine.h"
#import "CPSystemEngine.h"
#import "ModelConvertUtils.h"
#import "CPLGModelAccount.h"
#import "CPResManager.h"
#import "CPDBManagement.h"
#import "CPUserManager.h"
#import "CPXmppEngine.h"
#import "CPXmppEngineConst.h"

#import "CPPTModelLoginResult.h"
#import "CPUIModelManagement.h"
#import "CPMsgManager.h"
#import "CoreUtils.h"
#import "PalmUIManagement.h"
#define app_version         @"0.7.2"
#define app_version_number  3

#ifdef SYS_STATE_MIGR
@interface CPSystemManager (/*private api*/)
{
    SysState sysState;
}
@end
#endif

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation CPSystemManager
@synthesize uniqueDeviceIdentifier = _uniqueDeviceIdentifier;
-(id)init
{
    self = [super init];
    if (self) 
    {
#ifdef SYS_STATE_MIGR
        sysState = SYS_STATE_OFFLINE;
#endif
        NSString *macaddress = [[UIDevice currentDevice]uniqueDeviceMacaddress];
        if (macaddress) {
            [self setUniqueDeviceIdentifier:[macaddress stringByReplacingOccurrencesOfString:@":" withString:@""]];
        }
    }
    return self;
    
}

#ifdef SYS_STATE_MIGR
- (void)XmppEngineStatusChanged:(NSInteger)status
{
    CPLogInfo(@"sysState:%d, status:%d\n", sysState, status);
    
    switch( status )
    {
        case STATE_XMPPENGINE_CONNECTING:
            [[[CPSystemEngine sharedInstance] msgManager] removeAllWillSendXmppMsgs];
            break;
        case STATE_XMPPENGINE_AUTHFAILED:
            {
                sysState = SYS_STATE_OFFLINE;
                
                [[CPSystemEngine sharedInstance] updateSysOfflineStatus];
                [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
                [[CPSystemEngine sharedInstance] autoLogin];
                [[[CPSystemEngine sharedInstance] msgManager] removeAllWillSendXmppMsgs];
            }
            break;
            
        case STATE_XMPPENGINE_CONNECTED:
            {
                sysState = SYS_STATE_ONLINE;

                [[CPSystemEngine sharedInstance] updateSysOnlineStatus];
                
                [[[CPSystemEngine sharedInstance] resManager] excuteResourceCached];
                
                [self initDataByXmppLoginSucess];
            }
            break;
            
        case STATE_XMPPENGINE_DISCONNECTED:
            {
                sysState = SYS_STATE_OFFLINE;
                
                [[CPSystemEngine sharedInstance] updateSysOfflineStatus];
                [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
                [[[CPSystemEngine sharedInstance] msgManager] removeAllWillSendXmppMsgs];
                [[CPSystemEngine sharedInstance] autoLogin];
            }
            break;
            
        case STATE_XMPPENGINE_RECONNECTING:
            {
                [[CPSystemEngine sharedInstance] updateSysOfflineStatus];
            }
            break;
            
        default:
            break;
    }
}

- (void) handleReLoginResult:(NSNumber *)resultCode withObject:(NSObject*)resutlObject andToken:(NSString *)token
{
    CPLogInfo(@"resultCode:%@, token:%@", resultCode, token);
    
    if( LOGIN_RESPONSE_CODE_SUCESS == [resultCode intValue] )
    {
        //attention.
//        sysState = SYS_STATE_ONLINE;
        sysState = SYS_STATE_HTTP_LOGIN_SUC;
        
        [[[CPSystemEngine sharedInstance] accountModel] setToken:token];
        
        BOOL accIsVerified = YES;
        
        CPPTModelLoginResult *loginRes = nil;
        if (resutlObject && [resutlObject isKindOfClass:[CPPTModelLoginResult class]])
        {            
            loginRes = (CPPTModelLoginResult *)resutlObject;
            
            [[[CPSystemEngine sharedInstance] accountModel] setDomain:loginRes.domain];
            
            if ( loginRes && [[loginRes bindPhone] intValue] == BIND_RESPONSE_CODE_SUCESS/*means not bind*/ )
            {
                accIsVerified = NO;
                
                [[CPSystemEngine sharedInstance] updateTagWithAccountSate:[NSNumber numberWithInt:ACCOUNT_STATE_INACTIVE] res_desc:nil];
            }
            else
            {
                [[CPSystemEngine sharedInstance] updateTagWithAccountSate:[NSNumber numberWithInt:ACCOUNT_STATE_ACTIVATED] res_desc:nil];
                
//                NSInteger accState = [[CPUIModelManagement sharedInstance] accountState];
//                if( ACCOUNT_STATE_INACTIVE != accState )
//                {
                    if( [[[CPSystemEngine sharedInstance] xmppEngine] isDisconnected] )
                    {
                        [self beginXmppConnect];
                    }
                    else if( [[[CPSystemEngine sharedInstance] xmppEngine] isConnected] )
                    {
                        sysState = SYS_STATE_ONLINE;
                    }
                    else
                    {
                        //.
                    }
//                }

                [[[CPSystemEngine sharedInstance] resManager] excuteResourceCached];
            }
        }
        
        [[CPSystemEngine sharedInstance] backupSystemInfoWithAccountVerifiedCode:[NSNumber numberWithBool:accIsVerified]];
        
        if (cachedRegInfo)
        {
            //insert personal data
            CPDBModelPersonalInfo *personalInfo = [[CPDBModelPersonalInfo alloc] init];
            [personalInfo setName:cachedRegInfo.accountName];
            [personalInfo setNickName:cachedRegInfo.nickName];
            [personalInfo setSex:[NSNumber numberWithInt:cachedRegInfo.sex]];
            [personalInfo setLifeStatus:[NSNumber numberWithInt:cachedRegInfo.lifeStatus]];
            [personalInfo setMobileNumber:cachedRegInfo.mobileNumber];
            
            [[CPSystemEngine sharedInstance] updatePersonalInfoByOperation:personalInfo];
            
            [self initSelfImgDataWithName:PERSONAL_BG_FILE type:RESOURCE_FILE_CP_TYPE_SELF_BG img_data:cachedRegInfo.selfBgImgData];
            [self initSelfImgDataWithName:PERSONAL_HEADER_FILE type:RESOURCE_FILE_CP_TYPE_SELF_HEADER img_data:cachedRegInfo.selfImgData];
            [self initSelfImgDataWithName:PERSONAL_BABY_FILE type:RESOURCE_FILE_CP_TYPE_SELF_BABY img_data:cachedRegInfo.babyImgData];
        }

        [[CPSystemEngine sharedInstance] updateSysOnlineStatus];
    }
    else
    {
        //1200,  1201,  etc.
        NSString *responseDesc = [CoreUtils filterResponseDescWithCode:resultCode];
        [[CPSystemEngine sharedInstance] sysLogoutAndGotoLoginWithDesc:responseDesc];
    }
}

- (void)activeSystem
{
    CPLogInfo(@"sysState:%d", sysState);
    if( sysState != SYS_STATE_ONLINE )
    {
        [[[CPSystemEngine sharedInstance] xmppEngine] disconnect];
        [[CPSystemEngine sharedInstance] autoLogin];
    }
}
#endif

#pragma mark login,reg,etc...
-(void)registerWithRegInfo:(CPUIModelRegisterInfo *)regInfo
{
    CPLogInfo(@"register info");
    cachedRegInfo = regInfo;
    if (cachedRegInfo.accountName)
    {
        [cachedRegInfo setAccountName:[cachedRegInfo.accountName lowercaseString]];
    }
    //先保存图片到本地，待注册成功之后再存入数据库;个人信息先存放在temp文件中
    [[[CPSystemEngine sharedInstance] httpEngine] registerAccountForModule:[self class] 
                                                      WithUserRegisterInfo:[ModelConvertUtils uiRegInfoToPt:regInfo]];
}
-(void)clearRegInfoData
{
    cachedRegInfo = nil;
}
-(void)loginWithName:(NSString *)loginName password:(NSString *)pwd
{
    [[CPSystemEngine sharedInstance] updateAccountModelWithName:loginName pwd:pwd];
    [[[CPSystemEngine sharedInstance] httpEngine] loginForModule:[self class] 
                                                    WithUserName:loginName 
                                                     andPassword:pwd];
#ifdef SYS_STATE_MIGR
    sysState = SYS_STATE_HTTP_LOGINING;
#endif
}

-(void)activeAccountWithCode:(NSString *)code
{
    NSString *phoneNumber = cachedRegInfo.mobileNumber;
    NSString *regionNumber = cachedRegInfo.regionNumber;
    if (!phoneNumber) 
    {
        phoneNumber = [[[CPSystemEngine sharedInstance] accountModel] mobileNumber];
    }
    if (!regionNumber)
    {
        regionNumber = @"86";
    }
    [[[CPSystemEngine sharedInstance] httpEngine] sendVerifyCodeForModule:[self class] 
                                                             withPhoneNum:phoneNumber
                                                             andPhoneArea:regionNumber
                                                            andVerifyCode:code];
}

-(void)bindMobileNumber:(NSString *)number region_number:(NSString *)regionNumber
{
    if (!cachedRegInfo)
    {
        cachedRegInfo = [[CPUIModelRegisterInfo alloc] init];
    }
    regionNumber = @"86";
    [cachedRegInfo setMobileNumber:number];
    [cachedRegInfo setRegionNumber:regionNumber];
    CPLogInfo(@"%@    %@",number,regionNumber);
    [[[CPSystemEngine sharedInstance] httpEngine] bindPhoneNumForModule:[self class] 
                                                           withPhoneNum:number 
                                                           andPhoneArea:regionNumber];
}
-(void)autoLogin
{
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    [[CPSystemEngine sharedInstance] setAccountModelWithAutoLogin:YES];
    [self loginWithName:account.loginName password:account.pwdMD5];
}
-(void)logout
{
    //
}
-(void)uploadDeviceInfo
{
    NSString *deviceID = [CoreUtils getGlobalDeviceIdentifier];
    NSString *mcc = [CoreUtils getMobileCountryCode];
    NSString *mnc = [CoreUtils getMobileNetworkCode];
    NSString *countryCode = [CoreUtils getCountryCode];
    NSString *languageCode = [CoreUtils getLanguageCode];
    BOOL isCracked = [CoreUtils isJailbroken];
    UIDevice* device = [UIDevice currentDevice];
    NSString *deviceModel = device.model;
    NSString *sysVersion = [NSString stringWithFormat:@"%@%@",device.systemName,device.systemVersion];
    NSString *wifiInfo = @"wifi";
    if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == NotReachable)
    {
        wifiInfo = @"other";
    }
    if (!mcc) 
    {
        mcc = @"";
    }
    if (!mnc)
    {
        mnc = @"";
    }
    [[[CPSystemEngine sharedInstance] httpEngine] uploadDeviceInfoForModule:[self class] 
                                                                        MCC:mcc 
                                                                        MNC:mnc 
                                                                      Model:deviceModel 
                                                                  PhoneLang:languageCode 
                                                                    Country:countryCode
                                                                        APN:wifiInfo 
                                                               SoftwareLang:@"zh_cn"
                                                                 PlatformID:sysVersion
                                                                  EditionID:app_version
                                                                  SubcoopId:@"AppStore" 
                                                                    Cracked:[NSNumber numberWithBool:isCracked]
                                                                   UniqueId:deviceID];
}
#pragma mark 
-(void)uploadAddressBook
{
    //    BOOL canUploadAb = [[[[CPSystemEngine sharedInstance] accountModel] canUploadAb] boolValue];
    BOOL isVerified = [[[[CPSystemEngine sharedInstance] accountModel] isVerifiedCode] boolValue];
    if (/**canUploadAb&&**/isVerified)
    {
        NSNumber *lastQueryDate = [[[CPSystemEngine sharedInstance] accountModel] uploadAbTime];
        NSArray *allContacts = [[[CPSystemEngine sharedInstance] dbManagement] contactArray];
        
        //upload address
        NSArray *uploadContactArray = nil;
        CPLGModelAccount *accountModel = [[CPSystemEngine sharedInstance] accountModel];
        CPLogInfo(@"%@    %@",lastQueryDate,accountModel);
        if (lastQueryDate&&[lastQueryDate longLongValue]>0)
        {
            uploadContactArray = [[[CPSystemEngine sharedInstance] dbManagement] findallContactsCachedWithUpdateTime:lastQueryDate];     
        }
        else 
        {
            uploadContactArray = allContacts;
        }
        CPLogInfo(@"%d",[uploadContactArray count]);
        if (uploadContactArray&&[uploadContactArray count]>0)
        {
            [[[CPSystemEngine sharedInstance] sysManager] uploadAbWithContacts:uploadContactArray];
        }
    }
}
#pragma mark response API
-(BOOL)writeToFileWithData:(NSData *)data file_name:(NSString *)fileName account:(NSString *)accountName
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
        NSString *path = [NSString stringWithFormat:@"%@/%@.jpg",writableDBPath,fileName];
        isSucess = [data writeToFile:path atomically:YES];
    }
    return isSucess;
}

-(void)initSelfImgDataWithName:(NSString *)fileName type:(NSInteger)type img_data:(NSData *)data
{
    NSString *accountName = cachedRegInfo.accountName;
    if (![CoreUtils stringIsNotNull:accountName]) 
    {
        accountName = [[CPSystemEngine sharedInstance] getAccountName];
    }
    BOOL isSelfBgFile = [self writeToFileWithData:data file_name:fileName account:accountName];
    if (isSelfBgFile)
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setMark:[NSNumber numberWithInt:MARK_UPLOAD]];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",fileName]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/",accountName]];
        [dbRes setObjType:[NSNumber numberWithInt:type]];
        [dbRes setObjID:[NSNumber numberWithInt:1]];
        [dbRes setType:[NSNumber numberWithInt:type]];
        [dbRes setMimeType:@"image/jpeg"];
        [[[CPSystemEngine sharedInstance] resManager] uploadWithRes:dbRes up_data:cachedRegInfo.selfBgImgData];
    }
    else 
    {
        CPLogError(@"save file error,of %@",fileName);
    }
}
-(void)registerResponseWithCode:(NSNumber *)resonseCode response_description:(NSString *)resDesc
{
    if (resonseCode)
    {
        if ([resonseCode intValue]==REG_RESPONSE_CODE_SUCESS) 
        {
            CPLGModelAccount *accountModel = [[CPLGModelAccount alloc] init];
            [accountModel setLoginName:cachedRegInfo.accountName];
            [accountModel setIsAvtived:[NSNumber numberWithBool:YES]];
            [accountModel setQueryAbTime:0];
            [accountModel setPwdMD5:cachedRegInfo.password];
            [accountModel setMobileNumber:cachedRegInfo.mobileNumber];
            [[CPSystemEngine sharedInstance] backupSystemInfoWithAccount:accountModel];
            
            //begin auto login
            [self autoLogin];
        }
        
        [[CPSystemEngine sharedInstance] updateTagWithRegResponseCode:resonseCode res_desc:resDesc];
    }
}
-(void)testLoginAction
{
    [[[CPSystemEngine sharedInstance] userManager] getFriendsWithTimeStamp:nil];
}
-(void)getFriendsByTimeStampCached
{
    [[[CPSystemEngine sharedInstance] userManager] getFriendsWithTimeStamp:[[[CPSystemEngine sharedInstance] accountModel] friTimeStamp]];
    [[[CPSystemEngine sharedInstance] msgManager] getFavoriteGroupsWithTimeStamp:[[[CPSystemEngine sharedInstance] accountModel] converTimeStamp]];
    [[[CPSystemEngine sharedInstance] userManager] getMyProfile];
}
-(void)initDataByXmppLoginSucess
{
    [self checkUpdate];
    //        [[CPSystemEngine sharedInstance] updateTagWithLoginResponseCode:[NSNumber numberWithInt:SYS_STATUS_ONLINE] res_desc:nil];
    [[CPSystemEngine sharedInstance] uploadAbByOperation];
    [[CPSystemEngine sharedInstance] uploadDeviceToken];
    //        [self activeAccountWithCode:@"9490"];
    //        [[CPSystemEngine sharedInstance] initAppDbData];
    //        [[[CPSystemEngine sharedInstance] dbManagement] insertPersonalInfo:personalInfo];
    NSNumber *hasCommendUsers = [[[CPSystemEngine sharedInstance] accountModel] hasCommendUsers];
    if ( !(hasCommendUsers && [hasCommendUsers boolValue]) )
    {
        CPLogInfo(@"get friends commend ,send http");
        [[[CPSystemEngine sharedInstance] userManager] getFriendsCommend];
    }
    
    [self getFriendsByTimeStampCached];
    //    [[[CPSystemEngine sharedInstance] userManager] getMyProfile];
    [[[CPSystemEngine sharedInstance] userManager] getMyRecentInfo];
    CPUIModelUserInfo *coupleModel = [[CPUIModelManagement sharedInstance] coupleModel];
    if (coupleModel.name)
    {
        [[[CPSystemEngine sharedInstance] userManager] getUserProfileWithUserName:coupleModel.name];
        [[[CPSystemEngine sharedInstance] userManager] getUserRecentWithUserName:coupleModel.name];
    }
    
    CPLGModelAccount *accountCached = [[CPSystemEngine sharedInstance] accountModel];
    if (![accountCached.hasSavePersonalInfoName boolValue])
    {
        CPUIModelPersonalInfo *uiPersonalInfo = [[CPUIModelManagement sharedInstance] uiPersonalInfo];
        if ( uiPersonalInfo.nickName && uiPersonalInfo.sex && uiPersonalInfo.hasBaby )
        {
            [[[CPSystemEngine sharedInstance] userManager] updatePersonalWithNickName:uiPersonalInfo.nickName
                                                                               andSex:uiPersonalInfo.sex
                                                                        andHiddenBaby:uiPersonalInfo.hasBaby];
        }
    }
    [self uploadDeviceInfo];
    //    [[[CPSystemEngine sharedInstance] userManager] getFriendsWithTimeStamp:[[[CPSystemEngine sharedInstance] accountModel] friTimeStamp]];
    //        [self testLoginAction];
    
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];//.applicationIconBadgeNumber=0;
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}
-(void)initDataByHttpLoginSucess
{
    [[CPSystemEngine sharedInstance] initAccountDbData];
    [[CPSystemEngine sharedInstance] initLoginedData];
    [[CPSystemEngine sharedInstance] backupSystemInfoWithActived:[NSNumber numberWithBool:YES]];
//    [[CPSystemEngine sharedInstance] initSysPreInitData];
//    [[CPSystemEngine sharedInstance] initSysPreInitData_V];
}

-(void)beginXmppConnect
{
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    CPLogInfo(@"%@--%@--%@", account.loginName, account.domain, account.token);
    
    if( account.token
            && ![@"" isEqualToString:account.token]
            && account.loginName
            && ![@"" isEqualToString:account.loginName]
            && account.domain
            && ![@"" isEqualToString:account.domain] )
    {
#ifndef SYS_STATE_MIGR
        [[CPUIModelManagement sharedInstance] setSysOnlineStatus:SYS_STATUS_HTTP_LOGINED];
#else
        sysState = SYS_STATE_XMPP_CONNECTING;
#endif
        [[[CPSystemEngine sharedInstance] xmppEngine] connectWithJID:[NSString stringWithFormat:@"%@@%@",account.uid,account.domain] Password:account.suid];
    }
}

-(void)loginResponseWithCode:(NSNumber *)resonseCode response_description:(NSString *)resDesc result:(CPPTModelLoginResult *)result
{
    if ( resonseCode && [resonseCode intValue] == LOGIN_RESPONSE_CODE_SUCESS )
    {
        [[[CPSystemEngine sharedInstance] accountModel] setDomain:result.domain];
        CPLogInfo(@"response domain is %@",[[[CPSystemEngine sharedInstance] accountModel] domain]);
                
        [self initDataByHttpLoginSucess];
        
        /**启动xmpp的链接，在xmpp登录成功之后，才会 登录成功，之前都是登录中； 
         如果当前状态是登录中或者离线的话，执行刚才描述的操作；如果是在线状态的话，则只是重新走几个协议 
         **/
        BOOL isVerifiedCode = YES;
//        if ( result && [[result bindPhone] intValue] == BIND_RESPONSE_CODE_SUCESS/*means not bind*/ )
//        {
//#ifndef SYS_STATE_MIGR
//            [[CPSystemEngine sharedInstance] updateTagWithAppStateCode:[NSNumber numberWithInt:SYS_STATUS_NO_ACTIVE ] res_desc:nil];
//#else
//            [[CPSystemEngine sharedInstance] updateTagWithAccountSate:[NSNumber numberWithInt:ACCOUNT_STATE_INACTIVE] res_desc:nil];
//#endif
//            isVerifiedCode = NO;
//        }
//        else
//        {
#ifndef SYS_STATE_MIGR
            NSInteger sysStatusCode = [[CPSystemEngine sharedInstance] sysStatusCode];
            [[CPSystemEngine sharedInstance] updateTagWithAppStateCode:[NSNumber numberWithInt:SYS_STATUS_ONLINE ] res_desc:nil];
            
            switch (sysStatusCode)
            {
                case SYS_STATUS_ONLINE:
                    [self initDataByXmppLoginSucess];
                    break;
//                case SYS_STATUS_NO_ACTIVE:
//                    //
//                    break;
                default:
                    [self beginXmppConnect];
                    //暂且先这么调用
                    [self initDataByXmppLoginSucess];
                    break;
            }
#else
            [[CPSystemEngine sharedInstance] updateTagWithAccountSate:[NSNumber numberWithInt:ACCOUNT_STATE_ACTIVATED] res_desc:nil];
                
            [self beginXmppConnect];
#endif
            
            [[[CPSystemEngine sharedInstance] resManager] excuteResourceCached];
//        }
        
//        [[CPSystemEngine sharedInstance] backupSystemInfoWithAccountVerifiedCode:[NSNumber numberWithBool:isVerifiedCode]];
        
        if (cachedRegInfo)
        {
            //insert personal data
            CPDBModelPersonalInfo *personalInfo = [[CPDBModelPersonalInfo alloc] init];
            [personalInfo setName:cachedRegInfo.accountName];
            [personalInfo setNickName:cachedRegInfo.nickName];
            [personalInfo setSex:[NSNumber numberWithInt:cachedRegInfo.sex]];
            [personalInfo setLifeStatus:[NSNumber numberWithInt:cachedRegInfo.lifeStatus]];
            [personalInfo setMobileNumber:cachedRegInfo.mobileNumber];
            
            [[CPSystemEngine sharedInstance] updatePersonalInfoByOperation:personalInfo];
            
            [self initSelfImgDataWithName:PERSONAL_BG_FILE type:RESOURCE_FILE_CP_TYPE_SELF_BG img_data:cachedRegInfo.selfBgImgData];
            [self initSelfImgDataWithName:PERSONAL_HEADER_FILE type:RESOURCE_FILE_CP_TYPE_SELF_HEADER img_data:cachedRegInfo.selfImgData];
            [self initSelfImgDataWithName:PERSONAL_BABY_FILE type:RESOURCE_FILE_CP_TYPE_SELF_BABY img_data:cachedRegInfo.babyImgData];
        }
    }

    //we will notify ui if current account was actived, otherwise ui should be notifyied after xmpp was connected.
    //or ?
//    [[CPSystemEngine sharedInstance] updateTagWithLoginResponseCode:resonseCode res_desc:resDesc];
}
-(void)uploadPersonalBgImgWithData:(NSData *)imgData
{
    [self initSelfImgDataWithName:PERSONAL_BG_FILE type:RESOURCE_FILE_CP_TYPE_SELF_BG img_data:imgData];
}
-(void)uploadPersonalHeaderImgWithData:(NSData *)imgData
{
    [self initSelfImgDataWithName:PERSONAL_HEADER_FILE type:RESOURCE_FILE_CP_TYPE_SELF_HEADER img_data:imgData];
}
-(void)uploadPersonalCoupleImgWithData:(NSData *)imgData
{
    [self initSelfImgDataWithName:PERSONAL_COUPLE_FILE type:RESOURCE_FILE_CP_TYPE_SELF_COUPLE img_data:imgData];
}
-(void)uploadPersonalBabyImgWithData:(NSData *)imgData
{
    [self initSelfImgDataWithName:PERSONAL_BABY_FILE type:RESOURCE_FILE_CP_TYPE_SELF_BABY img_data:imgData];
}

-(void)activeCodeResponseWithCode:(NSNumber *)resonseCode response_description:(NSString *)resDesc
{
    if (resonseCode)
    {
        if ([resonseCode intValue]==ACTIVE_RESPONSE_CODE_SUCESS)
        {
            [self beginXmppConnect];
#ifndef SYS_STATE_MIGR
            [self initDataByXmppLoginSucess];
#endif
            [[[CPSystemEngine sharedInstance] resManager] excuteResourceCached];
            
            [[CPSystemEngine sharedInstance] backupSystemInfoWithAccountVerifiedCode:[NSNumber numberWithBool:YES]];
#ifdef SYS_STATE_MIGR
            [[CPSystemEngine sharedInstance] updateTagWithAccountSate:[NSNumber numberWithInt:ACCOUNT_STATE_ACTIVATED] res_desc:nil];
#endif
        }
        
        [[CPSystemEngine sharedInstance] updateTagWithActiveResponseCode:resonseCode res_desc:resDesc];
    }
}
-(void)bindCodeResponseWithCode:(NSNumber *)resonseCode response_description:(NSString *)resDesc
{
    if (resonseCode)
    {
        [[CPSystemEngine sharedInstance] updateTagWithBindResponseCode:resonseCode res_desc:resDesc];
    }
}
-(void)uploadAbWithContacts:(NSArray *)contacts
{
    [[[CPSystemEngine sharedInstance] httpEngine] uploadContactInfosForModule:[self class] 
                                                             withContactInfos:[ModelConvertUtils dbContactsToPt:contacts]];
}
-(void)uploadDeviceToken:(NSString *)deviceToken
{
    [[[CPSystemEngine sharedInstance] httpEngine] updateDeviceTokenForModule:[self class] withDeviceToken:deviceToken];
}
-(void)modifyUserPasswordWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd
{
    [[[CPSystemEngine sharedInstance] httpEngine] changePasswordForModule:[self class]
                                                          withOldPassword:oldPwd
                                                           andNewPassword:newPwd];
}
-(void)resetPasswordGetCodeWithUserName:(NSString *)userName andMobileNumber:(NSString *)mobileNumber andMobileArea:(NSString *)mobileArea
{
    [[[CPSystemEngine sharedInstance] httpEngine] retrieveVerifyCodeForModule:[self class]
                                                                 withUserName:userName
                                                                  andPhoneNum:mobileNumber
                                                                 andPhoneArea:mobileArea];
}
-(void)resetPasswordPostWithUserName:(NSString *)userName 
                     andMobileNumber:(NSString *)mobileNumber 
                       andMobileArea:(NSString *)mobileArea
                              andPwd:(NSString *)password
                       andVerifyCode:(NSString *)verifyCode
{
    [[[CPSystemEngine sharedInstance] httpEngine] resetPasswordForModule:[self class]
                                                            withUserName:userName
                                                             andPhoneNum:mobileNumber
                                                            andPhoneArea:mobileArea
                                                            andPasssword:password 
                                                           andVerifyCode:verifyCode];
}
-(void)pushFanxerTeam
{
    [[[CPSystemEngine sharedInstance] httpEngine] pushMeForModule:[self class]];
}
-(void)checkUpdate
{
    [[[CPSystemEngine sharedInstance] httpEngine] checkUpdate:[self class]];
}
#pragma mark http delegate methods

- (void) handleRegisterAccountResult:(NSNumber *)resultCode
{
    CPLogInfo(@"%@",resultCode);
    NSString *responseDesc = nil;
    NSInteger resCode ;
    if ([resultCode intValue]!=REG_RESPONSE_CODE_SUCESS)
    {
        responseDesc = [CoreUtils filterResponseDescWithCode:resultCode];
        resCode = [resultCode intValue];
    }
    else 
    {
        resCode = REG_RESPONSE_CODE_SUCESS;
    }
    
    [self registerResponseWithCode:[NSNumber numberWithInt:resCode] response_description:responseDesc];
}

- (void) handleLoginResult:(NSNumber *)resultCode withObject:(NSObject*)resultObject andToken:(NSString *)token;
{
    NSString *responseDesc = nil;
    NSInteger resCode;
    if ([resultCode intValue] != LOGIN_RESPONSE_CODE_SUCESS)
    {
        CPPTModelLoginResult *errorResult = nil;
        if (resultObject && [resultObject isKindOfClass:[CPPTModelLoginResult class]])
        {
            errorResult = (CPPTModelLoginResult *)resultObject;
        }
        responseDesc = errorResult.loginErrorMsg;
        resCode = LOGIN_RESPONSE_CODE_SERVER_ERROR;
        
#ifdef SYS_STATE_MIGR
//        sysState = SYS_STATE_HTTP_LOGIN_FAILED;
        sysState = SYS_STATE_OFFLINE;
#endif
        //在自动登录的情况下，如果登录失败，除了弹出浮层之外，还可能到登录页面；
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        if ([account isAutoLogin])
        {
            NSInteger errorCode = [resultCode integerValue];
            //如果是密码错误或者账号被禁用
            if (errorCode==1200||errorCode==1201)
            {
                [[CPSystemEngine sharedInstance] sysLogoutAndGotoLoginWithDesc:responseDesc];
                
                return;
            }
        }
    }
    else 
    {
        resCode = LOGIN_RESPONSE_CODE_SUCESS;
        
#ifdef SYS_STATE_MIGR
        sysState = SYS_STATE_HTTP_LOGIN_SUC;
#endif  
    }
    
    [[[CPSystemEngine sharedInstance] accountModel] setToken:token];
    
    
    CPPTModelLoginResult *result = nil;
    if (resultObject && [resultObject isKindOfClass:[CPPTModelLoginResult class]])
    {
        result = (CPPTModelLoginResult *)resultObject;
    }
    [[[CPSystemEngine sharedInstance] accountModel] setSuid:result.suid];
    [[[CPSystemEngine sharedInstance] accountModel] setUid:result.uid];
    
    [PalmUIManagement sharedInstance].loginResult = result;
    
    [self loginResponseWithCode:[NSNumber numberWithInt:resCode] response_description:responseDesc result:result];
    
    [[CPSystemEngine sharedInstance] updateTagWithLoginResponseCode:[NSNumber numberWithInt:resCode] res_desc:responseDesc];
}

- (void) handleSendVerifyCodeResult:(NSNumber *)resultCode
{
    CPLogInfo(@"%@",resultCode);
    NSString *responseDesc = nil;
    NSInteger resCode;
    if ([resultCode intValue]!=ACTIVE_RESPONSE_CODE_SUCESS)
    {
        responseDesc = [CoreUtils filterResponseDescWithCode:resultCode];
        resCode = ACTIVE_RESPONSE_CODE_SERVER_ERROR;
    }
    else 
    {
        resCode = ACTIVE_RESPONSE_CODE_SUCESS;
    }
    
    CPLogInfo(@"%@",responseDesc);
    [self activeCodeResponseWithCode:[NSNumber numberWithInt:resCode] response_description:responseDesc];
}
- (void) handleUploadContactInfosResult:(NSNumber *)resultCode
{
    CPLogInfo(@"%@",resultCode);
    if ([resultCode intValue]==ACTIVE_RESPONSE_CODE_SUCESS)
    {
        [[CPSystemEngine sharedInstance] backupSystemInfoWithAccountUploadAb];
    }
}
- (void) handleBindPhoneNumberResult:(NSNumber *)resultCode
{
    CPLogInfo(@"%@",resultCode);
    NSString *responseDesc = nil;
    NSInteger resCode;
    if ([resultCode intValue]!=BIND_RESPONSE_CODE_SUCESS)
    {
        responseDesc = [CoreUtils filterResponseDescWithCode:resultCode];
        resCode = BIND_RESPONSE_CODE_SERVER_ERROR;
    }
    else 
    {
        resCode = BIND_RESPONSE_CODE_SUCESS;
    }
    
    [self bindCodeResponseWithCode:[NSNumber numberWithInt:resCode] response_description:responseDesc];
}
- (void) handleUPdateDeviceTokenResult:(NSNumber *)resultCode
{
    if ([resultCode intValue]==RESPONSE_CODE_SUCESS)
    {
        [[CPSystemEngine sharedInstance] backupSystemInfoWithIsUploadDeviceToken:[NSNumber numberWithBool:YES]];
    }
}
- (void) handleRetrievePasswordResult:(NSNumber *)resultCode
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if ([resultCode intValue]==RESPONSE_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:reset_pwd_get_code_res_code];
    }
    else 
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:reset_pwd_get_code_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:reset_pwd_get_code_res_desc];
    }
    [[CPSystemEngine sharedInstance] updateTagByResetPwdGetCodeWithDic:resDic];
}
- (void) handleResetPasswordResult:(NSNumber *)resultCode withUserName:(NSString *)uName andOriginalPassword:(NSString *)pwd
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if ([resultCode intValue]==RESPONSE_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:reset_pwd_post_res_code];
        //auto login
        [[CPSystemEngine sharedInstance] updateAccountModelWithName:uName pwd:pwd];
        [self autoLogin];
    }
    else 
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:reset_pwd_post_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:reset_pwd_post_res_desc];
    }
    [[CPSystemEngine sharedInstance] updateTagByResetPwdPostWithDic:resDic];
}
- (void) handleChangePasswordResult:(NSNumber *)resultCode withNewPassword:(NSString *)newPwd
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if ([resultCode intValue]==RESPONSE_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:change_pwd_res_code];
        //chongzhi mima
        [[CPSystemEngine sharedInstance] backupSystemInfoWithPwd:newPwd];
    }
    else 
    {
//        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:change_pwd_res_code];
        [resDic setObject:resultCode forKey:change_pwd_res_code];
        [resDic setObject:[CoreUtils filterResponseDescWithCode:resultCode] forKey:change_pwd_res_desc];
    }
    [[CPSystemEngine sharedInstance] updateTagByChangePwdWithDic:resDic];
}
- (void)handlePushMeResult:(NSNumber *)resultCode
{
    CPLogInfo(@"response code is %@",resultCode);
}
- (void)handleCheckUpdateResult:(NSNumber *)resultCode
                    withSubject:(NSString *)subject
                     andContent:(NSString *)content
                     andVersion:(NSString *)version
                 andVersionCode:(NSNumber *)versionCode
                         andUrl:(NSString *)url
{
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    if ([resultCode intValue]==RESPONSE_CODE_SUCESS)
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_SUCESS] forKey:check_update_res_code];
        if (version&&versionCode) 
        {
            NSInteger newVersionCode = [versionCode integerValue];
            if (/**[@"0.6.0" isEqualToString:version]&&**/newVersionCode>app_version_number)
                [resDic setObject:version forKey:check_update_version];
                if (subject) 
                {
                    [resDic setObject:subject forKey:check_update_subject];
                }
                if (content) 
                {
                    [resDic setObject:content forKey:check_update_content];
                }
                if (url) 
                {
                    [resDic setObject:url forKey:check_update_url];
                }
            
        }
    }
    else 
    {
        [resDic setObject:[NSNumber numberWithInt:RES_CODE_ERROR] forKey:check_update_res_code];
    }
    [[CPSystemEngine sharedInstance] updateTagByCheckUpdateWithDic:resDic];
}

- (void) handleHTTPSendMsg:(NSNumber*) messageID withResult:(BOOL)result
{
    if (messageID){
        if(result)
            [[CPSystemEngine sharedInstance] updateMsgSendResponseByOperationWithID:messageID andStatus:[NSNumber numberWithInt:MESSAGE_SENDING_STATE_SEND_SUCCESSFUL]];
        else
            [[CPSystemEngine sharedInstance] updateMsgSendResponseByOperationWithID:messageID andStatus:[NSNumber numberWithInt:MESSAGE_SENDING_STATE_SEND_FAILED]];
    }
    
}

-(void)sendXMPPMsg:(XMPPUserMessage*) xmppMsg
{
    [[[CPSystemEngine sharedInstance] httpEngine] sendXMPPMsg:[self class] withMsg:xmppMsg];
}

-(void)sendXMPPGroupMsg:(XMPPGroupMessage*) xmppMsg
{
    [[[CPSystemEngine sharedInstance] httpEngine] sendXMPPGroupMsg:[self class] withMsg:xmppMsg];
}
@end
