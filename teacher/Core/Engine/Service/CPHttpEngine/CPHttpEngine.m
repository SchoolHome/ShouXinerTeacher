//
//  CPHttpEngine.m
//  Couple
//
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "MKNetworkKit.h"
#import "CPHttpEngineConst.h"
#import "MKNetworkEngine.h"
#import "CPHttpEngine.h"
#import "CPHttpEngineContextObject.h"
#import "CoreUtils.h"
#import "PalmUIManagement.h"
#import "CPDBModelMessage.h"
#import "CPSystemEngine.h"
#import "CPDBManagement.h"
#ifdef SYS_STATE_MIGR

#import "CPLGModelAccount.h"
#endif

#import "Reachability.h"
#import "ASIFormDataRequest.h"
///////////////////////////////////////////////////////////////////////////////////////////
//                                  ......
///////////////////////////////////////////////////////////////////////////////////////////
//http method ++
#define K_HTTP_METHOD_GET                   @"GET"
#define K_HTTP_METHOD_POST                  @"POST"
//http method --

//status code ++
#define K_ERROR_NONE                        0
#define K_RESPONSE_ERR                      -1
#define K_ERROR_UNAUTHENTICATED             401
#define K_ERROR_USER_NOT_EXIST              300
#define K_NOT_MODIFIED                      304
//status code --

//header fields ++
#define K_COOKIE_NAME                       @"uss"

#ifdef PM_TEST
#define K_COOKIE_DOMAIN                     @"192.168.50.8"
#else
#define K_COOKIE_DOMAIN                     @"192.168.50.0"
#endif

#define K_USER_AGENT_KEY                    @"User-Agent"
#define K_IF_MODIFIED_SINCE                 @"If-Modified-Since"
//#define K_TIMESTAMP                         @"Date"
#define K_TIMESTAMP                         @"Last-Modified"
#define K_USER_AGENT_VALUE                  @"FX iphone"
//header fields --

#define K_ERRORNO_STRING                    @"errno"

enum httpEngineState{
    
    HTTPENGINE_STATE_UNKNOWN = -1,
    HTTPENGINE_STATE_REGISTERING = 1,
    HTTPENGINE_STATE_REGISTER_FAILED = 2,
    HTTPENGINE_STATE_REGISTED = 3,
    
    HTTPENGINE_STATE_LOGOUT,
    HTTPENGINE_STATE_LOGINING,
    HTTPENGINE_STATE_LOGIN_SUC,
    HTTPENGINE_STATE_LOGIN_FAILED,
    HTTPENGINE_STATE_RE_LOGINING,
};

typedef enum httpEngineState HttpEngineState;

#ifdef SYS_STATE_MIGR
#define K_MAX_REC_TIMES         3
#define K_NETWORK_ERR           -3
#endif

#pragma -
#pragma mark private api

//---------------------------------------------------------------------------------------------------
//interface
//---------------------------------------------------------------------------------------------------

@interface CPHttpEngine (/*Private Methods*/)
{
#ifdef SYS_STATE_MIGR
    HttpEngineState state;
    NSInteger attemptTimes;
    NSTimer *reConnTimer;
#endif
}

@property (strong, nonatomic) Reachability *reachability;

@property (strong, nonatomic) MKNetworkEngine *mkPassportEngine;
@property (strong, nonatomic) MKNetworkEngine *mkRelationEngine;
@property (strong, nonatomic) MKNetworkEngine *mkContactEngine;
@property (strong, nonatomic) MKNetworkEngine *mkDownEngine;
@property (strong, nonatomic) MKNetworkEngine *mkUploadEngine;
@property (strong, nonatomic) MKNetworkEngine *mkGroupChatEngine;
@property (strong, nonatomic) MKNetworkEngine *mkProfileEngine;
@property (strong, nonatomic) MKNetworkEngine *mkOtherEngine;
@property (strong, nonatomic) MKNetworkEngine *mkHttpSendMsgEngine;
@property (strong, nonatomic) NSOperationQueue *asiHttpSendMsgQueue;

@property (strong, nonatomic) NSMutableDictionary *contextDict;
@property (strong, nonatomic) NSMutableDictionary *observerDict;

@property (strong, nonatomic) NSString* token;

#ifdef SYS_STATE_MIGR
- (void)mayBeAttemptRec;
- (BOOL)canPerformReq;
- (void)tearDownRec;
#endif

@end

//---------------------------------------------------------------------------------------------------
//implementation
//---------------------------------------------------------------------------------------------------

@implementation CPHttpEngine

@synthesize reachability = _reachability;

@synthesize mkPassportEngine = _mkPassportEngine;
@synthesize mkRelationEngine = _mkRelationEngine;
@synthesize mkContactEngine = _mkContactEngine;
@synthesize mkDownEngine = _mkDownEngine;
@synthesize mkUploadEngine = _mkUploadEngine;
@synthesize mkGroupChatEngine = _mkGroupChatEngine;
@synthesize mkProfileEngine = _mkProfileEngine;
@synthesize mkOtherEngine = _mkOtherEngine;
@synthesize mkHttpSendMsgEngine = _mkHttpSendMsgEngine;
@synthesize asiHttpSendMsgQueue = _asiHttpSendMsgQueue;
@synthesize contextDict = _contextDict;
@synthesize observerDict = _observerDict;

@synthesize token = _token;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -
#pragma mark init
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init
{
	if ((self = [super init]))
	{
#ifdef SYS_STATE_MIGR
        state = HTTPENGINE_STATE_LOGOUT;
        attemptTimes = 0;
        reConnTimer = nil;
#endif
        
        NSMutableDictionary *userAgentDict = [NSMutableDictionary dictionary];
        UIDevice* device = [UIDevice currentDevice];
        NSString *sysVersion = [NSString stringWithFormat:@"FX %@ %@",device.model,device.systemVersion];
        
        [userAgentDict setObject:sysVersion forKey:K_USER_AGENT_KEY];
#ifdef TEST
        [userAgentDict setObject:@"www.shouxiner.com" forKey:@"host"];
#endif
        NSMutableDictionary *userAgentDict1 = [NSMutableDictionary dictionary];
#ifdef TEST
        [userAgentDict1 setObject:@"att0.shouxiner.com" forKey:@"host"];
#endif
        NSMutableDictionary *userAgentDict2 = [NSMutableDictionary dictionary];
#ifdef TEST
        [userAgentDict2 setObject:@"att.shouxiner.com" forKey:@"host"];
#endif
        self.mkPassportEngine = [[MKNetworkEngine alloc] initWithHostName:K_HOST_NAME_OF_PALM_SERVER
                                                       customHeaderFields:userAgentDict];
        
        self.mkRelationEngine = [[MKNetworkEngine alloc] initWithHostName:K_HOST_NAME_OF_PALM_SERVER
                                                       customHeaderFields:userAgentDict];
        
        self.mkContactEngine = [[MKNetworkEngine alloc] initWithHostName:K_HOST_NAME_OF_CONTACT_SERVER
                                                      customHeaderFields:userAgentDict];
        
        self.mkDownEngine = [[MKNetworkEngine alloc] initWithHostName:nil
                                                   customHeaderFields:userAgentDict1];
        
        self.mkUploadEngine = [[MKNetworkEngine alloc] initWithHostName:K_HOST_NAME_OF_PALM_UPLOAD
                                                     customHeaderFields:userAgentDict2];
        
        self.mkGroupChatEngine = [[MKNetworkEngine alloc] initWithHostName:K_XMPP_SERVER
                                                        customHeaderFields:userAgentDict];
        
        self.mkProfileEngine = [[MKNetworkEngine alloc] initWithHostName:K_HOST_NAME_OF_PALM_SERVER
                                                      customHeaderFields:userAgentDict];
        
        self.mkOtherEngine = [[MKNetworkEngine alloc] initWithHostName:K_PATH_OTHER_SERVER
                                                    customHeaderFields:userAgentDict];
        
        self.mkHttpSendMsgEngine = [[MKNetworkEngine alloc] initWithHostName:K_XMPP_SERVER
                                                          customHeaderFields:userAgentDict];
        
        self.asiHttpSendMsgQueue = [[NSOperationQueue alloc] init];
        [self.asiHttpSendMsgQueue setMaxConcurrentOperationCount:1];
        
		self.contextDict = [NSMutableDictionary dictionary];
        self.observerDict = [NSMutableDictionary dictionary];
        
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
	}
    
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark -
#pragma mark Reachability related

-(void) reachabilityChanged:(NSNotification*) notification
{
    //    if([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    //    {
    //        DLog(@"Server [%@] is reachable via Wifi", self.hostName);
    //        [_sharedNetworkQueue setMaxConcurrentOperationCount:6];
    //
    //        [self checkAndRestoreFrozenOperations];
    //    }
    //    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    //    {
    //        DLog(@"Server [%@] is reachable only via cellular data", self.hostName);
    //        [_sharedNetworkQueue setMaxConcurrentOperationCount:2];
    //        [self checkAndRestoreFrozenOperations];
    //    }
    //    else if([self.reachability currentReachabilityStatus] == NotReachable)
    //    {
    //        DLog(@"Server [%@] is not reachable", self.hostName);
    //        [self freezeOperations];
    //    }
    //
    //    if(self.reachabilityChangedHandler) {
    //        self.reachabilityChangedHandler([self.reachability currentReachabilityStatus]);
    //    }
}

#ifdef SYS_STATE_MIGR
- (void)reLogin
{
    self.token = nil;
    //    state = HTTPENGINE_STATE_RE_LOGINING;
    
    NSString *u = [[[CPSystemEngine sharedInstance] accountModel] loginName];
    NSString *p = [[[CPSystemEngine sharedInstance] accountModel] pwdMD5];
    
    NSMutableDictionary *loginInfoDict = [NSMutableDictionary dictionary];
    [loginInfoDict setObject:u forKey:@"uname"];
    [loginInfoDict setObject:p forKey:@"passwd"];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_LOGIN
                                                               params:loginInfoDict
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            
            NSDictionary *rspJsonDict = [completedOperation responseJSON];
            NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
            
            self.token = [self tokenFromResponse:[completedOperation readonlyResponse]];
            
            CPPTModelLoginResult *loginResult = nil;
            if( K_ERROR_NONE == resultCode.intValue )
            {
                state = HTTPENGINE_STATE_LOGIN_SUC;
                
                loginResult = [CPPTModelLoginResult fromJsonDict:rspJsonDict];
            }
            else
            {
                state = HTTPENGINE_STATE_LOGIN_FAILED;
                state = HTTPENGINE_STATE_LOGOUT;
                
                //teardown rec.
            }
            
            [self tearDownRec];
            
            //notify rec suc!
            for( id<CPHttpEngineObserver> obsv in self.observerDict )
            {
                if( [obsv respondsToSelector:@selector(handleReLoginResult:withObject:andToken:)] )
                {
                    [obsv handleReLoginResult:resultCode withObject:loginResult andToken:self.token];
                }
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            
            self.token = nil;
            
            NSNumber *resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
            CPLogInfo(@"resultCode = %@\n", resultCode);
            
            //            if( state != HTTPENGINE_STATE_LOGIN_SUC )
            //            {
            if( reConnTimer == nil )
            {
                reConnTimer = [NSTimer scheduledTimerWithTimeInterval:arc4random()%10 + 10
                                                               target:self
                                                             selector:@selector(rec:)
                                                             userInfo:nil
                                                              repeats:YES];
            }
            //            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 3];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void)rec:(NSTimer *)timer
{
    CPLogInfo(@"attemptTimes:%d\n", attemptTimes);
    
    if( attemptTimes >= K_MAX_REC_TIMES )
    {
        attemptTimes = 0;
        
        if( reConnTimer )
        {
            [reConnTimer invalidate];
            reConnTimer = nil;
        }
        
        state = HTTPENGINE_STATE_LOGOUT;
        
        return;
    }
    
    attemptTimes++;
    
    [self reLogin];
}

- (void)mayBeAttemptRec
{
    CPLogInfo(@"state:%d, attemptTimes:%d\n", state, attemptTimes);
    
    if( state == HTTPENGINE_STATE_RE_LOGINING )
    {
        return;
    }
    
    if( attemptTimes >= K_MAX_REC_TIMES )
    {
        attemptTimes = 0;
        state = HTTPENGINE_STATE_LOGOUT;
        
        return;
    }
    
    state = HTTPENGINE_STATE_RE_LOGINING;
    
    if( attemptTimes == 0 )
    {
        if( reConnTimer )
        {
            [reConnTimer invalidate];
            reConnTimer = nil;
        }
        
        [self reLogin];
    }
    else
    {
        if( reConnTimer == nil )
        {
            reConnTimer = [NSTimer scheduledTimerWithTimeInterval:arc4random()%10 + 10
                                                           target:self
                                                         selector:@selector(rec:)
                                                         userInfo:nil
                                                          repeats:YES];
        }
    }
}

- (void)tearDownRec
{
    attemptTimes = 0;
    
    [reConnTimer invalidate];
    reConnTimer = nil;
}

- (BOOL)canPerformReq
{
    BOOL flag = YES;
    
    //    if( NO == [self.mkPassportEngine isReachable ])
    //    {
    //        CPLogInfo(@"reachable:%d\n", [self.mkPassportEngine isReachable]);
    //        return NO;
    //    }
    
    if( !([self.reachability isReachableViaWiFi] || [self.reachability isReachableViaWWAN]) )
    {
        CPLogInfo(@"reachability, NO!\n");
        flag = NO;
        return flag;
    }
    
    switch( state )
    {
        case HTTPENGINE_STATE_LOGIN_SUC:
            flag = YES;
            break;
            
        case HTTPENGINE_STATE_LOGIN_FAILED:
        case HTTPENGINE_STATE_LOGOUT:
            [self mayBeAttemptRec];
            flag = NO;
            break;
            
        case HTTPENGINE_STATE_LOGINING:
        case HTTPENGINE_STATE_RE_LOGINING:
            flag = NO;
            break;
            
        default:
            break;
    }
    
    return flag;
}

#endif

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -
#pragma mark Oberserver Register&Deregister
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) registerObserver:(id<CPHttpEngineObserver>) observer
{
    [self addObserver:observer];
}

- (void) deRegisterObserver:(id<CPHttpEngineObserver>) observer
{
    [self removeObserver: observer];
}

- (void) addObserver:(id<CPHttpEngineObserver>) observer
{
    NSString *className = NSStringFromClass([observer class]);
    id<CPHttpEngineObserver> obsv = [self.observerDict objectForKey:className];
    
    //    NSAssert(obsv == nil, @"invalid observer");
    
    //need more attension.
    if( nil == obsv )
    {
        [self.observerDict setObject:observer forKey:className];
    }
}

- (void) removeObserver:(id<CPHttpEngineObserver>) observer
{
    NSString *className = NSStringFromClass([observer class]);
    
    //need more attention.
    [self.observerDict removeObjectForKey:className];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -
#pragma mark private utils
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSArray *) cookiesArray
{
    NSMutableArray* cookies = [[NSMutableArray alloc] init];
    NSMutableDictionary * cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setValue:K_COOKIE_NAME forKey:NSHTTPCookieName];
#warning not null assert.
    [cookieProperties setValue:(self.token ? self.token : @" ") forKey:NSHTTPCookieValue];
    [cookieProperties setValue:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setValue:K_COOKIE_DOMAIN forKey:NSHTTPCookieDomain];
    
    NSHTTPCookie * cookie = [[NSHTTPCookie alloc] initWithProperties:cookieProperties];
    [cookies addObject:cookie];
    //    NSMutableDictionary *headerFields = [NSMutableDictionary dictionary];
    //    NSMutableString *token = [NSMutableString stringWithString:@"uss="];
    //    [token appendString:self.token];
    //    [headerFields setObject:token forKey:@"Cookie"];
    //    [op addHeaders:headerFields];
    
    return cookies;
}

- (NSInteger) resultCodeFromResponseError:(/*__weak*/ NSError *)error
{
    NSInteger resultCode = K_RESPONSE_ERR;
    switch(error.code)
    {
        case K_ERROR_UNAUTHENTICATED:
        {
            resultCode = K_ERROR_UNAUTHENTICATED;
#ifdef SYS_STATE_MIGR
            //                state = HTTPENGINE_STATE_LOGOUT;
            [self mayBeAttemptRec];
#endif
        }
            break;
            
        default:
        {
            resultCode = K_RESPONSE_ERR;
        }
            break;
    }
    
    return resultCode;
}

- (NSString *) tokenFromResponse:(NSHTTPURLResponse *)response
{
    NSString *tokenString = nil;
    NSArray *allCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields]
                                                                 forURL:[NSURL URLWithString:@"http://www.shouxiner.com/mapi/login"]];
    for (NSHTTPCookie *cookie in allCookies){
        if([cookie.name isEqualToString:@"PHPSESSID"]){
//            NSDictionary *properties = [[NSMutableDictionary alloc] init];
//            [properties setValue:cookie.value forKey:NSHTTPCookieValue];
//            [properties setValue:@"PHPSESSID" forKey:NSHTTPCookieName];
//            NSHTTPCookie *cd = [[NSHTTPCookie alloc] initWithProperties:properties];
            [PalmUIManagement sharedInstance].php =cookie;
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            
        }else if([cookie.name isEqualToString:@"SUID"]){
//            NSDictionary *properties = [[NSMutableDictionary alloc] init];
//            [properties setValue:cookie.value forKey:NSHTTPCookieValue];
//            [properties setValue:@"SUID" forKey:NSHTTPCookieName];
//            [properties setValue:@".shouxiner.com" forKey:NSHTTPCookieDomain];
            [PalmUIManagement sharedInstance].suid = cookie;
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            tokenString = cookie.value;
        }
        
        //another way++
        //we can use properties dict.
        //NSDictionary *cookieDict = [cookie properties];
        //another way--
    }
    
    return tokenString;
}

- (NSString *) timeStampFromResponse:(NSHTTPURLResponse *)response
{
    NSString *timeStamp = nil;
    NSDictionary *headerFields = [response allHeaderFields];
    timeStamp = [headerFields objectForKey:K_TIMESTAMP];
    
    return timeStamp;
}

#pragma -
#pragma mark account op
//--------------------------------------------------------------------------------------------------
//account op.
//--------------------------------------------------------------------------------------------------

- (void) registerAccountForModule:(Class)clazz WithUserRegisterInfo:(CPPTModelUserRegisterInfo *)userInfo
{
    NSMutableDictionary *userInfoDict = [userInfo toJsonDict];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_REGISTER
                                                               params:userInfoDict
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRegisterAccountResult:)] )
                {
                    NSDictionary * rspJsonDict = [completedOperation responseJSON];
                    NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    
                    [observer handleRegisterAccountResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRegisterAccountResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleRegisterAccountResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) sendVerifyCodeForModule:(Class)clazz
                    withPhoneNum:(NSString *)phoneNum
                    andPhoneArea:(NSString *)phoneArea
                   andVerifyCode:(NSString *)verifyCode
{
    NSMutableDictionary *verifyCodeInfoDict = [NSMutableDictionary dictionary];
    [verifyCodeInfoDict setObject:phoneNum forKey:@"phnum"];
    [verifyCodeInfoDict setObject:phoneArea forKey:@"pharea"];
    [verifyCodeInfoDict setObject:verifyCode forKey:@"verifycode"];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_VERIFY_CODE
                                                               params:verifyCodeInfoDict
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
    
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookie ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookie --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleSendVerifyCodeResult:)] )
                {
                    NSDictionary *rspJsonDict = [completedOperation responseJSON];
                    NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    
                    [observer handleSendVerifyCodeResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleSendVerifyCodeResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleSendVerifyCodeResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) bindPhoneNumForModule:(Class)clazz
                  withPhoneNum:(NSString *)phoneNum
                  andPhoneArea:(NSString *)phoneArea
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleBindPhoneNumberResult:)] )
        {
            [observer handleBindPhoneNumberResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:phoneNum forKey:@"phnum"];
    [param setObject:phoneArea forKey:@"pharea"];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_BIND_PHONENUM
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookie ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookie --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleBindPhoneNumberResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleBindPhoneNumberResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleBindPhoneNumberResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleBindPhoneNumberResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

//--------------------------------------------------------------------------------------------------
//                                          account op.
//                                        loginForModule
//--------------------------------------------------------------------------------------------------
- (void)loginForModule:(Class)clazz WithUserName:(NSString *)userName andPassword:(NSString *)password
{
    
#ifdef SYS_STATE_MIGR
    state = HTTPENGINE_STATE_LOGINING;
    
    [self tearDownRec];
#endif
    
    isLogout = NO;
    
    if( [[MKNetworkEngine sharedQueue] operationCount] > 0 )
    {
        [[MKNetworkEngine sharedQueue] cancelAllOperations];
    }
    
    if( [[MKNetworkEngine sharedQueue] operationCount] > 0 )
    {
        [[MKNetworkEngine sharedQueue] waitUntilAllOperationsAreFinished];
    }
    
    self.token = nil; 
    
    NSMutableDictionary *loginInfoDict = [NSMutableDictionary dictionary];
    [loginInfoDict setObject:userName forKey:@"username"];
    [loginInfoDict setObject:password forKey:@"password"];
    [loginInfoDict setObject:@"IOS" forKey:@"device_type"];
    [loginInfoDict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"device_version"];
    [loginInfoDict setObject:@"ios_v2_teacher" forKey:@"app_platform"];
//    [loginInfoDict setObject:@"ios_v2" forKey:@"app_platform"];
    [loginInfoDict setObject:@"1.0.0.0" forKey:@"app_version"];
    
    NSNumber *first = [[NSUserDefaults standardUserDefaults] objectForKey:@"first_login"];
    if (nil == first) {
        [loginInfoDict setObject:[NSNumber numberWithInt:1] forKey:@"first_login"];
    }else{
        [loginInfoDict setObject:[NSNumber numberWithInt:0] forKey:@"first_login"];
    }
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_LOGIN
                                                               params:loginInfoDict
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                 ssl:NO
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                NSDictionary *rspJsonDict = [completedOperation responseJSON];
                NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                
                self.token = [self tokenFromResponse:[completedOperation readonlyResponse]];
                
                CPPTModelLoginResult *loginResult = nil;
                if( K_ERROR_NONE == resultCode.intValue )
                {
#ifdef SYS_STATE_MIGR
                    state = HTTPENGINE_STATE_LOGIN_SUC;
#endif
                    loginResult = [CPPTModelLoginResult fromJsonDict:rspJsonDict];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"first_login"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
#ifdef SYS_STATE_MIGR
                else
                {
                    state = HTTPENGINE_STATE_LOGIN_FAILED;
                    state = HTTPENGINE_STATE_LOGOUT;
                }
#endif
                [PalmUIManagement sharedInstance].imServerIP = loginResult.imserverIP;
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleLoginResult:withObject:andToken:)] )
                {
                    [observer handleLoginResult:resultCode withObject:loginResult andToken:self.token];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                //kCFErrorDomainCFNetwork
                //kCFURLErrorTimedOut
                NSNumber *resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                CPLogInfo(@"resultCode = %@\n", resultCode);
                
#ifdef SYS_STATE_MIGR
                state = HTTPENGINE_STATE_LOGIN_FAILED;
                state = HTTPENGINE_STATE_LOGOUT;
#endif
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleLoginResult:withObject:andToken:)] )
                {
                    [observer handleLoginResult:resultCode withObject:nil andToken:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }];
    [op setQueuePriority:NSOperationQueuePriorityVeryHigh];
    [self.mkPassportEngine enqueueOperation:op];
}

//--------------------------------------------------------------------------------------------------
//                                          account op.
//                                        logoutForModule
//--------------------------------------------------------------------------------------------------
- (void)logoutForModule:(Class)clazz withDeviceToken:(NSString *)deviceToken
{
    CPLogInfo(@"");
    
    isLogout = YES;
    
#ifdef SYS_STATE_MIGR
    state = HTTPENGINE_STATE_LOGOUT;
    
    [self tearDownRec];
#endif
    
    if( [[MKNetworkEngine sharedQueue] operationCount] > 0 )
    {
        [[MKNetworkEngine sharedQueue] cancelAllOperations];
    }
    
    if( [[MKNetworkEngine sharedQueue] operationCount] > 0 )
    {
        [[MKNetworkEngine sharedQueue] waitUntilAllOperationsAreFinished];
    }
    
    //temp++
    if(self.token == nil)
    {
        return;
    }
    //temp--
    
    // add token when logout
    //withDeviceToken:(NSString *)deviceToken
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if ( !deviceToken
        || [@"" isEqualToString:deviceToken]
        || [deviceToken isEqual:[NSNull null]]
        || [deviceToken isEqualToString:@"null"] )
    {
        param=nil;
    }else{
        
        [param setObject:deviceToken forKey:@"t"];
    }
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_LOGOUT
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_GET
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    self.token = nil;
    
#if 0
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        
        NSString *reqId = [completedOperation uniqueIdentifier];
        CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
        if(contextObj)
        {
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handleLogoutResult:withToken:)] )
            {
                NSDictionary *rspJsonDict = [completedOperation responseJSON];
                NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                
                self.token = [self tokenFromResponse:[completedOperation readonlyResponse]];
                
                [observer handleLogoutResult:resultCode withToken:self.token];
            }
            
            [self.contextDict removeObjectForKey:reqId];
        }
        
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        
        CPLogInfo(@"onError_V2\n");
        NSString *reqId = [completedOperation uniqueIdentifier];
        CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
        if(contextObj)
        {
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handleLogoutResult:withToken:)] )
            {
                NSNumber *resultCode = nil;
                resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                
                [observer handleLogoutResult:resultCode withToken:nil];
            }
            
            [self.contextDict removeObjectForKey:reqId];
        }
        
    }];
#endif
    
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) searchUserForModule:(Class)clazz
                withPhoneNum:(NSString *)phoneNum
                andPhoneArea:(NSString *)phoneArea;
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleSearchUserResult:withObject:)] )
        {
            [observer handleSearchUserResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                  withObject:nil];
        }
        
        return;
    }
#endif
    
#if 0
    //oneway ++
    NSString *param = [NSString stringWithFormat:@"%@?p=%@&a=%@", K_PATH_SEARCH_USER, phoneNum, phoneArea];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:param
                                                               params:nil
                                                           httpMethod:K_HTTP_METHOD_GET
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                  ssl:NO];
    //oneway --
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
#else
    //anotherway ++
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:phoneNum forKey:@"p"];
    [param setObject:phoneArea forKey:@"a"];
    CPLogInfo(@"param = %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_SEARCH_USER
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_GET
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
    //anotherway --
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleSearchUserResult:withObject:)] )
                {
                    NSInteger res;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        
                        res = K_ERROR_NONE;
                        CPPTModelSearchResultUserInfo *userInfo = [CPPTModelSearchResultUserInfo fromJsonDict:[completedOperation responseJSON]];
                        
                        obj = userInfo;
                    }
                    else
                    {
                        res = K_ERROR_USER_NOT_EXIST;
                        obj = nil;
                    }
                    
                    NSNumber *resultCode = [NSNumber numberWithInt:res];
                    
                    [observer handleSearchUserResult:resultCode withObject:obj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleSearchUserResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleSearchUserResult:resultCode withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) searchUserForModule:(Class)clazz
                withUserName:(NSString *)uName
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleSearchUserResult:withObject:)] )
        {
            [observer handleSearchUserResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                  withObject:nil];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"u"];
    CPLogInfo(@"param = %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_SEARCH_USER_BY_NAME
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_GET
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
    //anotherway --
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleSearchUserResult:withObject:)] )
                {
                    NSInteger res;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        
                        res = K_ERROR_NONE;
                        CPPTModelSearchResultUserInfo *userInfo = [CPPTModelSearchResultUserInfo fromJsonDict:[completedOperation responseJSON]];
                        
                        obj = userInfo;
                    }
                    else
                    {
                        res = K_ERROR_USER_NOT_EXIST;
                        obj = nil;
                    }
                    
                    NSNumber *resultCode = [NSNumber numberWithInt:res];
                    
                    [observer handleSearchUserResult:resultCode withObject:obj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleSearchUserResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleSearchUserResult:resultCode withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) bindCoupleForModule:(Class)clazz
                    withName:(NSString *)name
                 andPhoneNum:(NSString *)phoneNum
                andPhoneArea:(NSString *)phoneArea
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleBindCoupleResult:withObject:)] )
        {
            [observer handleBindCoupleResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                  withObject:nil];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:name forKey:@"name"];
    [param setObject:phoneNum forKey:@"phnum"];
    [param setObject:phoneArea forKey:@"pharea"];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_BIND_COUPLE
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleBindCoupleResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        
                        if( resultCode.intValue == K_ERROR_NONE )
                        {
                            CPPTModelBindCoupleResult *result = [CPPTModelBindCoupleResult fromJsonDict:[completedOperation responseJSON]];
                            obj = result;
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleBindCoupleResult:resultCode withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleBindCoupleResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleBindCoupleResult:resultCode withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) retrieveVerifyCodeForModule:(Class)clazz
                        withUserName:(NSString *)uName
                         andPhoneNum:(NSString *)phoneNum
                        andPhoneArea:(NSString *)phoneArea
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"uname"];
    [param setObject:phoneNum forKey:@"phnum"];
    [param setObject:phoneArea forKey:@"pharea"];
    CPLogInfo(@"param:%@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_RETRIEVE_PASSWORD
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    //    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRetrievePasswordResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleRetrievePasswordResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRetrievePasswordResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleRetrievePasswordResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void)resetPasswordForModule:(Class)clazz
                  withUserName:(NSString *)uName
                   andPhoneNum:(NSString *)phoneNum
                  andPhoneArea:(NSString *)phoneArea
                  andPasssword:(NSString *)passwd
                 andVerifyCode:(NSString *)verifyCode
{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"uname"];
    [param setObject:phoneNum forKey:@"phnum"];
    [param setObject:phoneArea forKey:@"pharea"];
    [param setObject:passwd forKey:@"passwd"];
    [param setObject:verifyCode forKey:@"verifycode"];
    CPLogInfo(@"param:%@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_RESET_PASSWORD
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    //    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = uName;
    ctxObj.ctxObj = passwd;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResetPasswordResult:withUserName:andOriginalPassword:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleResetPasswordResult:resultCode withUserName:contextObj.ctxString andOriginalPassword:(NSString *)contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResetPasswordResult:withUserName:andOriginalPassword:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleResetPasswordResult:resultCode withUserName:contextObj.ctxString andOriginalPassword:(NSString *)contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void)changePasswordForModule:(Class)clazz
                withOldPassword:(NSString *)oldPassword
                 andNewPassword:(NSString *)newPassword
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleChangePasswordResult:withNewPassword:)] )
        {
            [observer handleChangePasswordResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                 withNewPassword:newPassword];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:oldPassword forKey:@"passwd"];
    [param setObject:newPassword forKey:@"newpasswd"];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_CHANGE_PASSWORD
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = newPassword;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleChangePasswordResult:withNewPassword:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleChangePasswordResult:resultCode withNewPassword:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleChangePasswordResult:withNewPassword:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleChangePasswordResult:resultCode withNewPassword:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma -
#pragma mark resource operator
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void) downloadResourceOf:(NSNumber *)resourceID
                  forModule:(Class)clazz
                       from:(NSString *)remoteURL
                     toFile:(NSString *)filePath
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleResourceDownlaodErrorOf:withResultCode:)] )
        {
            [observer handleResourceDownlaodErrorOf:resourceID
                                     withResultCode:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    if(isLogout)
    {
        return;
    }
    
    NSMutableString *fullPath = [NSMutableString stringWithString:@""];
    //    [fullPath appendString:@"/res"];
    [fullPath appendString:remoteURL];
    
#ifdef TEST
    NSRange range = [fullPath rangeOfString:@"att0.shouxiner.com"];
    if (range.length>0) {
        [fullPath replaceCharactersInRange:range withString:@"115.29.224.151"];
    }
#endif
    
    MKNetworkOperation *op = [self.mkDownEngine operationWithURLString:fullPath
                                                                params:nil
                                                            httpMethod:K_HTTP_METHOD_GET];
    
    //cookies ++
    NSArray *cookies = [[NSArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php,[PalmUIManagement sharedInstance].suid, nil];
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:cookies]];
    //cookies --
    
    NSMutableString *localTempFile = [[NSMutableString alloc] initWithString:NSTemporaryDirectory()];
    [localTempFile appendString:[op uniqueIdentifier]];
    
//    NSRange dotRange = [remoteURL rangeOfString:@"." options:NSBackwardsSearch];
//    if( dotRange.length > 0 )
//    {
//        [localTempFile appendFormat:[NSString stringWithFormat:@".%@", [remoteURL substringFromIndex:dotRange.location + 1]]];
//    }
    
#if 0
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath append:YES]];
#else
#warning temp sltion.attention!
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:localTempFile append:NO/*YES*/]];
#endif
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxString = localTempFile;
    
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResourceDownloadCompleteOf:withResultCode:andLocalFile:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    NSString *timeStamp = nil;
                    
                    if(K_NOT_MODIFIED != [[completedOperation readonlyResponse] statusCode])
                    {
                        timeStamp = [self timeStampFromResponse: [completedOperation readonlyResponse]];
                        resultCode = [NSNumber numberWithInt:K_ERROR_NONE];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_NOT_MODIFIED];
                    }
                    
                    [observer handleResourceDownloadCompleteOf:contextObj.srcLocalID
                                                withResultCode:resultCode
                                                  andLocalFile:contextObj.ctxString
                                                  andTimeStamp:timeStamp];
                }
                
                //remove ctx;
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResourceDownlaodErrorOf:withResultCode:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    
                    [observer handleResourceDownlaodErrorOf:contextObj.srcLocalID withResultCode:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkDownEngine enqueueOperation:op];
}

- (void)downloadPetResOf:(NSString *)resID
               forModule:(Class)clazz
                    from:(NSString *)remoteURL
                  toFile:(NSString *)filePath
           andContextObj:(NSObject *)contextObj
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handlePetResDownloadResult:ofPetRes:andContextObj:)] )
        {
            [observer handlePetResDownloadResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                        ofPetRes:resID
                                   andContextObj:contextObj];
        }
        
        return;
    }
#endif
    
    if(isLogout)
    {
        return;
    }
    
    NSMutableString *fullPath = [NSMutableString stringWithString:
#ifdef WWAN_TEST
                                 K_HOST_NAME_OF_PRODUCT_FILE_DOWNLOAD_SERVER
#else
                                 K_HOST_NAME_OF_FILE_DOWNLOAD_SERVER
#endif
                                 ];
    //    [fullPath appendString:@"/res"];
    [fullPath appendString:remoteURL];
    CPLogInfo(@"fullPath:%@\n", fullPath);
    
    MKNetworkOperation *op = [self.mkDownEngine operationWithURLString:fullPath
                                                                params:nil
                                                            httpMethod:K_HTTP_METHOD_GET];
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath append:YES]];
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = resID;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onDownloadProgressChanged:^(double progress){
        @autoreleasepool
        {
            NSString *reqId = [op uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handlePetResDownloadProgress:)] )
            {
                [observer handlePetResDownloadProgress:progress];
            }
        }
    }];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handlePetResDownloadResult:ofPetRes:andContextObj:)] )
                {
                    NSNumber *resultCode = [NSNumber numberWithInt:K_ERROR_NONE];
                    
                    [observer handlePetResDownloadResult:resultCode
                                                ofPetRes:contextObj.ctxString
                                           andContextObj:contextObj.ctxObj];
                }
                
                //remove ctx;
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handlePetResDownloadResult:ofPetRes:andContextObj:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    
                    [observer handlePetResDownloadResult:resultCode
                                                ofPetRes:contextObj.ctxString
                                           andContextObj:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkDownEngine enqueueBackgroundOperation:op];
}

- (void) uploadResourceOf:(NSNumber *)resourceID
                forModule:(Class)clazz
         resrouceCategory:(CPResourceCategory)resCategory
                 fromFile:(NSString *)fileName
                 mimeType:(NSString *)mimeType
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleResrouceUploadErrorOf:withResultCode:)] )
        {
            [observer handleResrouceUploadErrorOf:resourceID
                                   withResultCode:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    if(isLogout)
    {
        return;
    }
    
    CPLogInfo(@"resCategory:%d; fileName:%@\n resourceID is %@", resCategory, fileName,resourceID);
    
    NSString *path = nil;
    NSString *fileMimeType = nil;
    
    switch(resCategory)
    {
        case K_RESOURCE_CATEGORY_SELFICON:
        {
            path = K_PATH_OF_SELFICON;
            fileMimeType = @"image/jpeg";
        }
            break;
            
        case K_RESOURCE_CATEGORY_COUPLEICON:
        {
            path = K_PATH_OF_COUPLEICON;
            fileMimeType = @"image/jpeg";
        }
            break;
            
        case K_RESOURCE_CATEGORY_BABYICON:
        {
            path = K_PATH_OF_BABYICON;
            fileMimeType = @"image/jpeg";
        }
            break;
            
        case K_RESOURCE_CATEGORY_BACKGROUND:
        {
            path = K_PATH_OF_BACKGROUND;
            fileMimeType = @"image/jpeg";
        }
            break;
            
        case K_RESOURCE_CATEGORY_MESSAGE_PIC:
        {
            path = K_PATH_OF_MESSAGE_PIC;
            fileMimeType = @"image/jpeg";
        }
            break;
            
        case K_RESOURCE_CATEGORY_MESSAGE_AUDIO:
        {
            path = K_PATH_OF_MESSAGE_AUDIO;
            fileMimeType = @"audio/amr";
        }
            break;
            
        case K_RESOURCE_CATEGORY_MESSAGE_VIDEO:
        {
            path = K_PATH_OF_MESSAGE_VIDEO;
            fileMimeType = @"video/mp4";
        }
            break;
            
        case K_RESOURCE_CATEGORY_MESSAGE_OTHER:
        {
            path = K_PATH_OF_MESSAGE_OTHER;
            fileMimeType = @"application/octet-stream";
        }
            break;
            
        case K_RESOURCE_CATEGORY_GROUP_MESSAGE_PIC:
        {
            path = K_PATH_OF_GROUP_MESSAGE_PIC;
            fileMimeType = @"image/jpeg";
        }
            break;
            
        case K_RESOURCE_CATEGORY_GROUP_MESSAGE_AUDIO:
        {
            path = K_PATH_OF_GROUP_MESSAGE_AUDIO;
            fileMimeType = @"audio/amr";
        }
            break;
            
        case K_RESOURCE_CATEGORY_GROUP_MESSAGE_VIDEO:
        {
            path = K_PATH_OF_GROUP_MESSAGE_VIDEO;
            fileMimeType = @"video/mp4";
        }
            break;
            
        case K_RESOURCE_CATEGORY_RECENT_AUDIO:
        {
            path = K_PATH_UPDATE_RECENT_AUDIO;
            fileMimeType = @"audio/amr";
        }
            break;
            
        default:
        {
            CPLogError(@"ERROR: res category must be specified!");
            //                return;
        }
            break;
    }
    CPDBModelMessage *dbMsg = [[[CPSystemEngine sharedInstance] dbManagement] findMessageWithResID:resourceID];
    /////////////////////////////////////
    NSString *urlString = [NSString stringWithFormat:@"http://%@/attachment/put/im/im/%@",K_HOST_NAME_OF_PALM_SERVER,[[CPSystemEngine sharedInstance] accountModel].uid];
    // url
    NSURL *url = [NSURL URLWithString:urlString];
    // req
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:url];
    // method
    [req setRequestMethod:@"POST"];
    // header
    [req addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
    [req addRequestHeader:@"Content-Type" value:fileMimeType];
    [req addRequestHeader:@"host" value:@"att.shouxiner.com"];
    // cookies
//    [req setRequestCookies:(NSMutableArray *)[self cookiesArray]];
    req.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid, nil];
    // body

    [req addFile:fileName withFileName:[fileName lastPathComponent] andContentType:fileMimeType forKey:@"file" ];
    //
    [req setUserInfo:[NSDictionary dictionaryWithObject:[[NSString uniqueString] md5] forKey:@"uniqueIdentifier"]];
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.srcLocalID = resourceID;
    
    NSString *uniqueId = [req.userInfo valueForKey:@"uniqueIdentifier"];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [req setCompletionBlock:^{
        
        NSLog(@"upload setCompletionBlock");
        //
        @autoreleasepool
        {
            NSString *reqId = [req.userInfo valueForKey:@"uniqueIdentifier"];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            CPLogInfo(@"onCompletion; contextObj.srcLocalID = %@    reqId is %@  self.contextDict is  %@", contextObj.srcLocalID,reqId,self.contextDict);
            [self.contextDict removeObjectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResourceUploadCompleteOf:withResultCode:andResponseObject:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    if( [req responseData].length )
                    {
                        
                        NSDictionary *rspJsonDict = (NSDictionary *)[[req responseData] objectFromJSONData];
                        if (rspJsonDict == nil) {
                            resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                        }else{
                            NSArray *array = [rspJsonDict objectForKey:@"data"];
                            array = array[0];
                            if ([array[1] integerValue] == YES) {
                                resultCode = [NSNumber numberWithInt:0];
                            }else{
                                resultCode = [NSNumber numberWithInt:-1];
                            }
                        
                            NSString *path = array[5];
                            if ([array[7] isEqualToString:@"amr"]) {
                                obj = [NSString stringWithFormat:@"%@/amr",path];
                            }else{
                                obj = [NSString stringWithFormat:@"%@/middle",path];
                            }
                        }
                    }
                    else
                    {
                        resultCode  = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleResourceUploadCompleteOf:contextObj.srcLocalID
                                              withResultCode:resultCode
                                           andResponseObject:obj];
                }else{
                    CPLog(@"noncontext==============");
                }
                
                //                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    [req setFailedBlock:^{
        //
        NSLog(@"upload setFailedBlock");
        NSLog(@"req.error %@",req.error);
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2------------------------------%@",fileName);
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", req.error.code, req.error.userInfo);
            NSString *reqId = [req.userInfo valueForKey:@"uniqueIdentifier"];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            CPLogInfo(@"onError_V2; contextObj.srcLocalID = %@    reqId is %@", contextObj.srcLocalID,reqId);
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResrouceUploadErrorOf:withResultCode:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:req.error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleResrouceUploadErrorOf:contextObj.srcLocalID
                                           withResultCode:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    [req startAsynchronous];
/*
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkUploadEngine operationWithPath:path
                                                             params:nil
                                                         httpMethod:K_HTTP_METHOD_POST
                                                   postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    [op addFile:fileName forKey:@"file" mimeType:fileMimeType];
    NSLog(@"%@",fileName);
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.srcLocalID = resourceID;
    
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    [op onCompletion:^(MKNetworkOperation* completedOperation){
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            CPLogInfo(@"onCompletion; contextObj.srcLocalID = %@    reqId is %@  self.contextDict is  %@", contextObj.srcLocalID,reqId,self.contextDict);
            [self.contextDict removeObjectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResourceUploadCompleteOf:withResultCode:andResponseObject:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        NSString *path = [rspJsonDict objectForKey:@"path"];
                        
                        obj = path;
                    }
                    else
                    {
                        resultCode  = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleResourceUploadCompleteOf:contextObj.srcLocalID
                                              withResultCode:resultCode
                                           andResponseObject:obj];
                }else{
                    CPLog(@"noncontext==============");
                }
                
                //                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2------------------------------%@",fileName);
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            CPLogInfo(@"onError_V2; contextObj.srcLocalID = %@    reqId is %@", contextObj.srcLocalID,reqId);
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleResrouceUploadErrorOf:withResultCode:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleResrouceUploadErrorOf:contextObj.srcLocalID
                                           withResultCode:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    //如果是发送video，则走queue
//    if (resCategory == K_RESOURCE_CATEGORY_MESSAGE_VIDEO
//        || resCategory == K_RESOURCE_CATEGORY_GROUP_MESSAGE_VIDEO)
//        [self.mkUploadEngine enqueueSoundResOperation:op];
//    else
        [self.mkUploadEngine enqueueOperation:op];
 */
}

- (void)uploadContactInfosForModule:(Class)clazz
                   withContactInfos:(CPPTModelContactInfos *)contactInfos
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleUploadContactInfosResult:)] )
        {
            [observer handleUploadContactInfosResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *contactInfosDict = [contactInfos toJsonDict];
    CPLogInfo(@"contactInfosDict = %@\n", contactInfosDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkContactEngine operationWithPath:K_PATH_OF_UPLOAD_CONTACT_INFO
                                                              params:contactInfosDict
                                                          httpMethod:K_HTTP_METHOD_POST
                                                    postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                 ssl:YES
#else
                                                                 ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUploadContactInfosResult:)] )
                {
                    NSDictionary * rspJsonDict = [completedOperation responseJSON];
                    NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleUploadContactInfosResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUploadContactInfosResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleUploadContactInfosResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkRelationEngine enqueueOperation:op];
}

- (void)getUsersKnowMeForModule:(Class)clazz
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetUsersKnowMeResult:withObject:)] )
        {
            [observer handleGetUsersKnowMeResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                      withObject:nil];
        }
        
        return;
    }
#endif
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkContactEngine operationWithPath:K_PATH_OF_GET_USERS_KNOW_ME
                                                              params:nil
                                                          httpMethod:K_HTTP_METHOD_GET
                                                    postDataEncoding:MKNKPostDataEncodingTypeURL
#ifdef WWAN_TEST
                                                                 ssl:YES
#else
                                                                 ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUsersKnowMeResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    //
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        CPLogInfo(@"resultCode = %@\n", resultCode);
                        
                        CPPTModelUserInfos *userInfos = [CPPTModelUserInfos fromJsonDict:[completedOperation responseJSON]];
                        obj = userInfos;
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                        obj = nil;
                    }
                    
                    [observer handleGetUsersKnowMeResult:resultCode withObject:obj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUsersKnowMeResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetUsersKnowMeResult:resultCode withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
//    [self.mkRelationEngine enqueueOperation:op];
}

- (void)getMyFriendsForModule:(Class)clazz
                withTimeStamp:(NSString *)timeStamp
{
    CPLogInfo(@"timeStamp:%@\n", timeStamp);
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetMyFriendsResult:withObject:andTimeStamp:)] )
        {
            [observer handleGetMyFriendsResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                    withObject:nil
                                  andTimeStamp:nil];
        }
        
        return;
    }
#endif
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkRelationEngine operationWithPath:K_PATH_OF_GET_MY_FRIENDS
                                                               params:nil
                                                           httpMethod:K_HTTP_METHOD_GET
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                  ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif

    //if-modified-since ++
    if(timeStamp)
    {
        NSMutableDictionary *ifModifiedSinceDict = [NSMutableDictionary dictionary];
        [ifModifiedSinceDict setObject:timeStamp forKey:K_IF_MODIFIED_SINCE];
        [op addHeaders:ifModifiedSinceDict];
    }
    //if-modified-since --
    
    //cookies ++
    NSArray *cookie = [[NSArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:cookie]];
    //cookies --
    
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMyFriendsResult:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    NSString *timeStamp = nil;
                    
                    if(K_NOT_MODIFIED != [[completedOperation readonlyResponse] statusCode])
                    {
                        timeStamp = [self timeStampFromResponse: [completedOperation readonlyResponse]];
                        
                        if( [completedOperation responseData].length )
                        {
                            NSDictionary *rspJsonDict = [completedOperation responseJSON];
                            CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                            resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                            CPLogInfo(@"resultCode = %@\n", resultCode);
                            
                            CPPTModelUserInfos *userInfos = [CPPTModelUserInfos fromJsonDict:[completedOperation responseJSON]];
                            obj = userInfos;
                        }
                        else
                        {
                            resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                            obj = nil;
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_NOT_MODIFIED];
                    }
                    
                    [observer handleGetMyFriendsResult:resultCode withObject:obj andTimeStamp:timeStamp];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMyFriendsResult:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetMyFriendsResult:resultCode withObject:nil andTimeStamp:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkRelationEngine enqueueOperation:op];
}

- (void) addFriendForModule:(Class)clazz
             friendCategory:(CPFriendCategory)frdCategory
               withUserName:(NSString *)uName
            andInviteString:(NSString *)inviteString
             andCouldExpose:(NSNumber *)couldExpose
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleAddFriendResult:withUserName:andCategory:)] )
        {
            [observer handleAddFriendResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                               withUserName:uName
                                andCategory:[NSNumber numberWithInt:frdCategory]];
        }
        
        return;
    }
#endif
    
    NSString *path = nil;
    
    switch(frdCategory)
    {
        case K_FRIEND_CATEGORY_NORMAL:
        {
            path = K_PATH_OF_ADD_NORMAL_FRIEND;
        }
            break;
            
        case K_FRIEND_CATEGORY_LOVER:
        {
            path = K_PATH_OF_ADD_LOVER;
        }
            break;
            
        case K_FRIEND_CATEGORY_CLOSER:
        {
            path = K_PATH_OF_ADD_CLOSER;
        }
            break;
            
        case K_FRIEND_CATEGORY_COUPLE:
        {
            path = K_PATH_OF_ADD_COUPLE;
        }
            break;
            
        case K_FRIEND_CATEGORY_CRUSH:
        {
            path = K_PATH_OF_ADD_CRUSH;
        }
            break;
            
        default:
        {
            CPLogError(@"ERROR: res category must be specified!");
            //                return;
        }
            break;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"uname"];
    [param setObject:inviteString forKey:@"content"];
    [param setObject:couldExpose forKey:@"couldExposed"];
    
    CPLogInfo(@"param:%@\n", param);
    CPLogInfo(@"path:%@\n", path);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkRelationEngine operationWithPath:path
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                  ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookie ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookie --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = uName;
    ctxObj.srcLocalID = [NSNumber numberWithInt:frdCategory];
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAddFriendResult:withUserName:andCategory:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleAddFriendResult:resultCode withUserName:contextObj.ctxString andCategory:ctxObj.srcLocalID];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAddFriendResult:withUserName:andCategory:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleAddFriendResult:resultCode withUserName:contextObj.ctxString andCategory:ctxObj.srcLocalID];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkRelationEngine enqueueOperation:op];
}

- (void) inviteFriendForModule:(Class)clazz
                friendCategory:(CPFriendCategory)frdCategory
                  withPhoneNum:(NSString *)phoneNum
                  andPhoneArea:(NSString *)phoneArea
                andCouldExpose:(NSNumber *)couldExpose
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleInviteFriendResult:withObject:andPhoneNum:andCategory:)] )
        {
            [observer handleInviteFriendResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                    withObject:nil
                                   andPhoneNum:phoneNum
                                   andCategory:[NSNumber numberWithInt:frdCategory]];
        }
        
        return;
    }
#endif
    
    NSString *path = nil;
    
    switch(frdCategory)
    {
        case K_FRIEND_CATEGORY_NORMAL:
        {
            path = K_PATH_OF_INVITE_NORMAL_FRIEND;
        }
            break;
            
        case K_FRIEND_CATEGORY_LOVER:
        {
            path = K_PATH_OF_INVITE_LOVER;
        }
            break;
            
        case K_FRIEND_CATEGORY_CLOSER:
        {
            path = K_PATH_OF_INVITE_CLOSER;
        }
            break;
            
        case K_FRIEND_CATEGORY_COUPLE:
        {
            path = K_PATH_OF_INVITE_COUPLE;
        }
            break;
            
        case K_FRIEND_CATEGORY_CRUSH:
        {
            path = K_PATH_OF_INVITE_CRUSH;
        }
            break;
            
            
        default:
        {
            CPLogError(@"ERROR: res category must be specified!");
            //                return;
        }
            break;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:phoneNum forKey:@"phnum"];
    [param setObject:phoneArea forKey:@"pharea"];
    [param setObject:couldExpose forKey:@"couldExposed"];
    
    CPLogInfo(@"param:%@\n", param);
    CPLogInfo(@"path:%@\n", path);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkRelationEngine operationWithPath:path
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                  ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookie ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookie --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = phoneNum;
    ctxObj.srcLocalID = [NSNumber numberWithInt:frdCategory];
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleInviteFriendResult:withObject:andPhoneNum:andCategory:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        
                        //only for lover&couple inviting++
                        if([ctxObj.srcLocalID intValue] == K_FRIEND_CATEGORY_LOVER
                           || [ctxObj.srcLocalID intValue] == K_FRIEND_CATEGORY_COUPLE)
                        {
                            CPPTModelInviteFriendResult *reuslt = nil;
                            reuslt = [CPPTModelInviteFriendResult fromJsonDict:[completedOperation responseJSON]];
                            obj = reuslt;
                        }
                        //only for lover&couple inviting--
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleInviteFriendResult:resultCode
                                            withObject:obj
                                           andPhoneNum:contextObj.ctxString
                                           andCategory:contextObj.srcLocalID];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleInviteFriendResult:withObject:andPhoneNum:andCategory:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleInviteFriendResult:resultCode
                                            withObject:nil
                                           andPhoneNum:contextObj.ctxString
                                           andCategory:contextObj.srcLocalID];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkRelationEngine enqueueOperation:op];
}

- (void) answerRequestForModule:(Class)clazz
                    ofRequestId:(NSString *)reqId
                 withAcceptFlag:(NSNumber *)accept
                  andContextObj:(NSObject *)contextObj
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleAnswerRequestResult:withAcceptFlag:andContextObject:)] )
        {
            [observer handleAnswerRequestResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                 withAcceptFlag:accept
                               andContextObject:contextObj];
        }
        
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:reqId forKey:@"reqid"];
    [param setObject:accept forKey:@"isAccept"];
    CPLogInfo(@"param: %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkRelationEngine operationWithPath:K_PATH_OF_ANSWER_REQUEST
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                  ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookie ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookie --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.srcLocalID = accept;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAnswerRequestResult:withAcceptFlag:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleAnswerRequestResult:resultCode withAcceptFlag:contextObj.srcLocalID andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAnswerRequestResult:withAcceptFlag:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleAnswerRequestResult:resultCode withAcceptFlag:contextObj.srcLocalID andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkRelationEngine enqueueOperation:op];
}

- (void) breakFriendRelationForModule:(Class)clazz
                             withUser:(NSString *)uName
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleBreakFriendRelationResult:)] )
        {
            [observer handleBreakFriendRelationResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                         withUserName:uName];
        }
        
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"uname"];
    CPLogInfo(@"param: %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkRelationEngine operationWithPath:K_PATH_OF_BREAK_FRIEND_RELATION
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                  ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookie ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookie --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = uName;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleBreakFriendRelationResult:withUserName:)])
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleBreakFriendRelationResult:resultCode withUserName:ctxObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleBreakFriendRelationResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleBreakFriendRelationResult:resultCode withUserName:ctxObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkRelationEngine enqueueOperation:op];
}

- (void) getMutualFriendsForModule:(Class)clazz
                          withUser:(NSString *)uName
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetMutualFriendsResult:forUser:withObject:)] )
        {
            [observer handleGetMutualFriendsResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                           forUser:uName
                                        withObject:nil];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"u"];
    CPLogInfo(@"param = %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkRelationEngine operationWithPath:K_PATH_OF_GET_MUTUAL_FRIENDS
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_GET
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                  ssl:NO];
    //anotherway --
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = uName;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMutualFriendsResult:forUser:withObject:)] )
                {
                    NSInteger res;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        
                        res = K_ERROR_NONE;
                        CPPTModelUserInfos *userInfos = [CPPTModelUserInfos fromJsonDict:[completedOperation responseJSON]];
                        obj = userInfos;
                    }
                    else
                    {
                        res = K_ERROR_USER_NOT_EXIST;
                        obj = nil;
                    }
                    
                    NSNumber *resultCode = [NSNumber numberWithInt:res];
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleGetMutualFriendsResult:resultCode forUser:contextObj.ctxString withObject:obj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMutualFriendsResult:forUser:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetMutualFriendsResult:resultCode forUser:contextObj.ctxString withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkRelationEngine enqueueOperation:op];
}

- (void) getUsersByPhonesForModule:(Class)clazz
                withContactWayList:(CPPTModelContactWayList *)contactWays
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetUsersByPhonesResult:withObject:)] )
        {
            [observer handleGetUsersByPhonesResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                        withObject:nil];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *contactWaysDict = [contactWays toJsonDict];
    CPLogInfo(@"contactInfosDict = %@\n", contactWaysDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_GET_USERS_BY_PHONES
                                                               params:contactWaysDict
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeJSON
#ifdef WWAN_TEST
                                                                  ssl:YES
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUsersByPhonesResult:withObject:)] )
                {
                    NSInteger res;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        
                        res = K_ERROR_NONE;
                        CPPTModelGetUsersResultList *gur = [CPPTModelGetUsersResultList fromJsonDict:[completedOperation responseJSON]];
                        obj = gur;
                    }
                    else
                    {
                        res = K_ERROR_USER_NOT_EXIST;
                        obj = nil;
                    }
                    
                    NSNumber *resultCode = [NSNumber numberWithInt:res];
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleGetUsersByPhonesResult:resultCode withObject:obj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUsersByPhonesResult:withObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetUsersByPhonesResult:resultCode withObject:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkPassportEngine enqueueOperation:op];
}

- (void) updateDeviceTokenForModule:(Class)clazz
                    withDeviceToken:(NSString *)deviceToken
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleUPdateDeviceTokenResult:)] )
        {
            [observer handleUPdateDeviceTokenResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    if ( !deviceToken
        || [@"" isEqualToString:deviceToken]
        || [deviceToken isEqual:[NSNull null]]
        || [deviceToken isEqualToString:@"null"] )
    {
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:deviceToken forKey:@"token"];
    CPLogInfo(@"param:%@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkPassportEngine operationWithPath:K_PATH_UPDATE_DEVICE_TOKEN
                                                               params:param
                                                           httpMethod:K_HTTP_METHOD_POST
                                                     postDataEncoding:MKNKPostDataEncodingTypeURL
#ifdef WWAN_TEST
                                                                  ssl:NO
#else
                                                                  ssl:NO
#endif
                              ];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
//    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUPdateDeviceTokenResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleUPdateDeviceTokenResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUPdateDeviceTokenResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleUPdateDeviceTokenResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkPassportEngine enqueueOperation:op];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//another way++
#if 0
-(MKNetworkOperation*) uploadImageFromFile:(NSString*) file
                              onCompletion:(PicOpCompletionBlock) completionBlock
                                   onError:(MKNKErrorBlock) errorBlock {
    
    MKNetworkOperation *op = [self operationWithPath:@"api/upload"
                                              params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      kTwitterUserName, @"username",
                                                      kTwitterPassword, @"password",
                                                      nil]
                                          httpMethod:@"POST"];
    
    [op addFile:file forKey:@"media"];
    
    // setFreezable uploads your images after connection is restored!
    [op setFreezable:YES];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        
        NSString *xmlString = [completedOperation responseString];
        NSUInteger start = [xmlString rangeOfString:@"<mediaurl>"].location;
        xmlString = [xmlString substringFromIndex:start + @"<mediaurl>".length];
        NSUInteger end = [xmlString rangeOfString:@"</mediaurl>"].location;
        xmlString = [xmlString substringToIndex:end];
        completionBlock(xmlString);
    }
             onError:^(NSError* error) {
                 
                 errorBlock(error);
             }];
    
    [self enqueueOperation:op];
    
    return op;
}
#endif
//another way--

#pragma -
#pragma mark groupChat op
//--------------------------------------------------------------------------------------------------
//groupChat op.
//--------------------------------------------------------------------------------------------------

- (void)createGroupForModule:(Class)clazz withMembers:(NSArray *)membersArray andContextObj:(NSObject *)contextObj
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleCreateGroupResult:withObject:andContextObject:)] )
        {
            [observer handleCreateGroupResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                   withObject:nil
                             andContextObject:contextObj];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *membersDict = [NSMutableDictionary dictionary];
    [membersDict setObject:membersArray forKey:@"members"];
    CPLogInfo(@"contactInfosDict = %@\n", membersDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_CREATE_GROUP
                                                                params:membersDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
//    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid, nil]]];
    
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleCreateGroupResult:withObject:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        
                        obj = [rspJsonDict objectForKey:@"groupJID"];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleCreateGroupResult:resultCode withObject:obj andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleCreateGroupResult:withObject:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleCreateGroupResult:resultCode withObject:nil andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)getGroupInfoForModule:(Class)clazz ofGroup:(NSString *)groupJID
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetGroupInfoResult:withObject:)] )
        {
            [observer handleGetGroupInfoResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                    withObject:nil
                            andOrignalGroupJID:groupJID];
        }
        
        return;
    }
#endif
    
    //anotherway ++
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:groupJID forKey:@"groupJID"];
    CPLogInfo(@"param = %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_GET_GROUP_INFO
                                                                params:param
                                                            httpMethod:K_HTTP_METHOD_GET
                                                      postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                   ssl:NO];
    //anotherway --
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
//    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid, nil]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = groupJID;
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetGroupInfoResult:withObject:andOrignalGroupJID:)] )
                {
                    //                NSInteger res;
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        
                        //                    res = K_ERROR_NONE;
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        //                    CPPTModelGroupInfo *groupInfo = [CPPTModelGroupInfo fromJsonDict:[completedOperation responseJSON]];
                        CPPTModelGroupInfo *groupInfo = [CPPTModelGroupInfo fromJsonDict:[rspJsonDict objectForKey:@"group"]];
                        
                        obj = groupInfo;
                    }
                    else
                    {
                        //                    res = K_ERROR_USER_NOT_EXIST;
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                        obj = nil;
                    }
                    
                    //                NSNumber *resultCode = [NSNumber numberWithInt:res];
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleGetGroupInfoResult:resultCode withObject:obj andOrignalGroupJID:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetGroupInfoResult:withObject:andOrignalGroupJID:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetGroupInfoResult:resultCode withObject:nil andOrignalGroupJID:ctxObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)addGroupMembersForModule:(Class)clazz
                         ofGroup:(NSString *)groupJID
                     withMembers:(NSArray *)membersArray
                   andContextObj:(NSObject *)contextObj;
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleAddGroupMembersResult:ofGroup:andContextObject:)] )
        {
            [observer handleAddGroupMembersResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                          ofGroup:groupJID
                                 andContextObject:contextObj];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupJID forKey:@"groupJID"];
    [paramDict setObject:membersArray forKey:@"members"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_ADD_GROUP_MEMEBER
                                                                params:paramDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObjects:[PalmUIManagement sharedInstance].suid, nil]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxString = groupJID;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAddGroupMembersResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleAddGroupMembersResult:resultCode ofGroup:contextObj.ctxString andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAddGroupMembersResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleAddGroupMembersResult:resultCode ofGroup:contextObj.ctxString andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)removeGroupMembersForModule:(Class)clazz
                            ofGroup:(NSString *)groupJID
                        withMembers:(NSArray *)membersArray
                      andContextObj:(NSObject *)contextObj
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleRemoveGroupMembersResult:ofGroup:andContextObject:)] )
        {
            [observer handleRemoveGroupMembersResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                             ofGroup:groupJID
                                    andContextObject:contextObj];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupJID forKey:@"groupJID"];
    [paramDict setObject:membersArray forKey:@"members"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_REMOVE_GROUP_MEMEBER
                                                                params:paramDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxString = groupJID;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRemoveGroupMembersResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleRemoveGroupMembersResult:resultCode ofGroup:contextObj.ctxString andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRemoveGroupMembersResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleRemoveGroupMembersResult:resultCode ofGroup:contextObj.ctxString andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)quitGroupForModule:(Class)clazz fromGroup:(NSString *)groupJID
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleQuitGroupResult:ofGroup:)] )
        {
            [observer handleQuitGroupResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                    ofGroup:groupJID];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupJID forKey:@"groupJID"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_QUITGROUP
                                                                params:paramDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = groupJID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleQuitGroupResult:ofGroup:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleQuitGroupResult:resultCode ofGroup:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleQuitGroupResult:ofGroup:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleQuitGroupResult:resultCode ofGroup:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)addFavoriteGroupForModule:(Class)clazz
                        withGroup:(NSString *)groupJID
                     andGroupName:(NSString *)groupName
                    andContextObj:(NSObject *)contextObj;
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleAddFavoriteGroupResult:ofGroup:andContextObject:)] )
        {
            [observer handleAddFavoriteGroupResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                           ofGroup:groupJID
                                  andContextObject:contextObj];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupJID forKey:@"groupJID"];
    [paramDict setObject:groupName forKey:@"groupName"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_ADD_FAVORITE_GROUP
                                                                params:paramDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxString = groupJID;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAddFavoriteGroupResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        CPLogInfo(@"resultCode = %@\n", resultCode);
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleAddFavoriteGroupResult:resultCode ofGroup:contextObj.ctxString andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleAddFavoriteGroupResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleAddFavoriteGroupResult:resultCode ofGroup:contextObj.ctxString andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)getFavoriteGroupsForModule:(Class)clazz withTimeStamp:(NSString *)timeStamp
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(hanldeGetFavoriteGroupsResult:withObject:andTimeStamp:)] )
        {
            [observer hanldeGetFavoriteGroupsResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                         withObject:nil
                                       andTimeStamp:nil];
        }
        
        return;
    }
#endif
    
    CPLogInfo(@"timeStamp:%@\n", timeStamp);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_GET_FAVORITE_GROUPS
                                                                params:nil
                                                            httpMethod:K_HTTP_METHOD_GET
                                                      postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //if-modified-since ++
    if(timeStamp)
    {
        NSMutableDictionary *ifModifiedSinceDict = [NSMutableDictionary dictionary];
        [ifModifiedSinceDict setObject:timeStamp forKey:K_IF_MODIFIED_SINCE];
        [op addHeaders:ifModifiedSinceDict];
    }
    //if-modified-since --
    
    //cookies ++
//    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[NSArray arrayWithObjects:[PalmUIManagement sharedInstance].suid, nil]]];
    //cookies --
    
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(hanldeGetFavoriteGroupsResult:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    NSString *timeStamp = nil;
                    
                    if(K_NOT_MODIFIED != [[completedOperation readonlyResponse] statusCode])
                    {
                        timeStamp = [self timeStampFromResponse: [completedOperation readonlyResponse]];
                        
                        if( [completedOperation responseData].length )
                        {
                            NSDictionary *rspJsonDict = [completedOperation responseJSON];
                            CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                            resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                            CPLogInfo(@"resultCode = %@\n", resultCode);
                            
                            CPPTModelGroupInfoList *groupInfos = [CPPTModelGroupInfoList fromJsonDict:[completedOperation responseJSON]];
                            
                            if(groupInfos.groupInfos && [groupInfos.groupInfos count] > 0)
                            {
                                obj = [NSArray arrayWithArray:groupInfos.groupInfos];
                            }
                            
                            groupInfos = nil;
                        }
                        else
                        {
                            resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                            obj = nil;
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_NOT_MODIFIED];
                    }
                    
                    [observer hanldeGetFavoriteGroupsResult:resultCode withObject:obj andTimeStamp:timeStamp];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(hanldeGetFavoriteGroupsResult:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer hanldeGetFavoriteGroupsResult:resultCode withObject:nil andTimeStamp:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }];
    
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)modifyFavoriteGroupNameForModule:(Class)clazz
                                 ofGroup:(NSString *)groupJID
                           withGroupName:(NSString *)groupName
                           andContextObj:(NSObject *)contextObj
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleModifyFavoriteGroupNameResult:ofGroup:andContextObject:)] )
        {
            [observer handleModifyFavoriteGroupNameResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                                  ofGroup:groupJID
                                         andContextObject:contextObj];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupJID forKey:@"groupJID"];
    [paramDict setObject:groupName forKey:@"groupName"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_UPDATE_FAVORITE_GROUP_INFO
                                                                params:paramDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxString = groupJID;
    ctxObj.ctxObj = contextObj;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleModifyFavoriteGroupNameResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleModifyFavoriteGroupNameResult:resultCode
                                                          ofGroup:contextObj.ctxString
                                                 andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleModifyFavoriteGroupNameResult:ofGroup:andContextObject:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleModifyFavoriteGroupNameResult:resultCode
                                                          ofGroup:contextObj.ctxString
                                                 andContextObject:contextObj.ctxObj];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)removeGroupFromFavoriteForModule:(Class)clazz dstGroup:(NSString *)groupJID
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleRemoveGroupFromFavoriteResult:ofGroup:)] )
        {
            [observer handleRemoveGroupFromFavoriteResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                                  ofGroup:groupJID];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupJID forKey:@"groupJID"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkGroupChatEngine operationWithPath:K_PATH_OF_REMOVE_GROUP_FROM_FAVORITE
                                                                params:paramDict
                                                            httpMethod:K_HTTP_METHOD_POST
                                                      postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                   ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    ctxObj.ctxString = groupJID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRemoveGroupFromFavoriteResult:ofGroup:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleRemoveGroupFromFavoriteResult:resultCode ofGroup:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRemoveGroupFromFavoriteResult:ofGroup:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleRemoveGroupFromFavoriteResult:resultCode ofGroup:contextObj.ctxString];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

#pragma -
#pragma mark profile op
//--------------------------------------------------------------------------------------------------
//profile op.
//--------------------------------------------------------------------------------------------------
- (void)getMyProfileForModule:(Class)clazz withTimeStamp:(NSString *)timeStamp
{
    CPLogInfo(@"timeStamp:%@\n", timeStamp);
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetMyFrofileResult:withObject:andTimeStamp:)] )
        {
            [observer handleGetMyFrofileResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                    withObject:nil
                                  andTimeStamp:nil];
        }
        
        return;
    }
#endif
    
#ifdef MKNETWORKKIT_NEW_FTR
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:[NSString stringWithFormat:K_PATH_OF_GET_MY_FOFILE,account.uid]
                                                              params:nil
                                                          httpMethod:K_HTTP_METHOD_GET
                                                    postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //if-modified-since ++
    if(timeStamp)
    {
        NSMutableDictionary *ifModifiedSinceDict = [NSMutableDictionary dictionary];
        [ifModifiedSinceDict setObject:timeStamp forKey:K_IF_MODIFIED_SINCE];
        [op addHeaders:ifModifiedSinceDict];
    }
    //if-modified-since --
    
    //cookies ++
    NSArray *cookie = [[NSArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:cookie]];
    //cookies --
    
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMyFrofileResult:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    NSString *timeStamp = nil;
                    
                    if(K_NOT_MODIFIED != [[completedOperation readonlyResponse] statusCode])
                    {
                        timeStamp = [self timeStampFromResponse: [completedOperation readonlyResponse]];
                        
                        if( [completedOperation responseData].length )
                        {
                            NSDictionary *rspJsonDict = [completedOperation responseJSON];
                            CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                            resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                            CPLogInfo(@"resultCode = %@\n", resultCode);
                            
                            CPPTModelUserProfile *groupInfos = [CPPTModelUserProfile fromJsonDict:[completedOperation responseJSON]];
                            obj = groupInfos;
                        }
                        else
                        {
                            resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                            obj = nil;
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_NOT_MODIFIED];
                    }
                    
                    [observer handleGetMyFrofileResult:resultCode withObject:obj andTimeStamp:timeStamp];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMyFrofileResult:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetMyFrofileResult:resultCode withObject:nil andTimeStamp:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 2];
    [self.mkProfileEngine enqueueOperation:op];
}

- (void) updateMyNicknameAndGenderForModule:(Class)clazz
                               withNickname:(NSString *)nickname
                                  andGender:(NSNumber *)gender
                                andHideBaby:(NSNumber *)hideBaby
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleUpdateMyNicknameAndGenderResult:)] )
        {
            [observer handleUpdateMyNicknameAndGenderResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:nickname forKey:@"nickname"];
    [param setObject:gender forKey:@"gender"];
    [param setObject:hideBaby forKey:@"hidebaby"];
    CPLogInfo(@"param:%@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_UPDATA_NICKNAME_AND_GENDER
                                                              params:param
                                                          httpMethod:K_HTTP_METHOD_POST
                                                    postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUpdateMyNicknameAndGenderResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    CPLogInfo(@"resultCode = %@\n", [resultCode description]);
                    
                    [observer handleUpdateMyNicknameAndGenderResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUpdateMyNicknameAndGenderResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleUpdateMyNicknameAndGenderResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkPassportEngine enqueueOperation:op];
}

- (void)getUSerProfileForModule:(Class)clazz ofUser:(NSString *)uName withTimeStamp:(NSString *)timeStamp
{
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetUserFrofileResult:ofUser:withObject:andTimeStamp:)] )
        {
            [observer handleGetUserFrofileResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                          ofUser:uName
                                      withObject:nil
                                    andTimeStamp:nil];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"u"];
    CPLogInfo(@"param = %@\n", param);
    
    CPLogInfo(@"timeStamp:%@\n", timeStamp);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_OF_GET_USER_FOFILE
                                                              params:param
                                                          httpMethod:K_HTTP_METHOD_GET
                                                    postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //if-modified-since ++
    if(timeStamp)
    {
        NSMutableDictionary *ifModifiedSinceDict = [NSMutableDictionary dictionary];
        [ifModifiedSinceDict setObject:timeStamp forKey:K_IF_MODIFIED_SINCE];
        [op addHeaders:ifModifiedSinceDict];
    }
    //if-modified-since --
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = uName;
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUserFrofileResult:ofUser:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    NSObject *obj = nil;
                    
                    NSString *timeStamp = nil;
                    
                    if(K_NOT_MODIFIED != [[completedOperation readonlyResponse] statusCode])
                    {
                        timeStamp = [self timeStampFromResponse: [completedOperation readonlyResponse]];
                        
                        if( [completedOperation responseData].length )
                        {
                            NSDictionary *rspJsonDict = [completedOperation responseJSON];
                            CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                            resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                            CPLogInfo(@"resultCode = %@\n", resultCode);
                            
                            CPPTModelUserProfile *groupInfos = [CPPTModelUserProfile fromJsonDict:[completedOperation responseJSON]];
                            obj = groupInfos;
                        }
                        else
                        {
                            resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                            obj = nil;
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_NOT_MODIFIED];
                    }
                    
                    [observer handleGetUserFrofileResult:resultCode ofUser:ctxObj.ctxString withObject:obj andTimeStamp:timeStamp];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }//if(contextObj)
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUserFrofileResult:ofUser:withObject:andTimeStamp:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetUserFrofileResult:resultCode ofUser:ctxObj.ctxString withObject:nil andTimeStamp:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }//if(contextObj)
        }//@autoreleasepool
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
//    [self.mkProfileEngine enqueueOperation:op];
}

- (void)updateRelationTimeForModule:(Class)clazz
                   withRelationType:(NSNumber *)relationType
                            andTime:(NSString *)relationTime
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleUpdateRelationTimeResult:)] )
        {
            [observer handleUpdateRelationTimeResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:relationType forKey:@"type"];
    [paramDict setObject:relationTime forKey:@"date"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_OF_SET_RELATION_TIME
                                                              params:paramDict
                                                          httpMethod:K_HTTP_METHOD_POST
                                                    postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUpdateRelationTimeResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleUpdateRelationTimeResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUpdateRelationTimeResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleUpdateRelationTimeResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkProfileEngine enqueueOperation:op];
}

- (void)removeBabyForModule:(Class)clazz
{
    CPLogInfo(@"\n");
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleRemoveBabyResult:)] )
        {
            [observer handleRemoveBabyResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_OF_REMOVE_BABY
                                                              params:nil
                                                          httpMethod:K_HTTP_METHOD_GET
                                                    postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRemoveBabyResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleRemoveBabyResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleRemoveBabyResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleRemoveBabyResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [self.mkProfileEngine enqueueOperation:op];
}

- (void)updateRecentForModule:(Class)clazz withContent:(NSString *)content andContentType:(NSNumber *)contentType
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleUpdateRecentResult:)] )
        {
            [observer handleUpdateRecentResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:contentType forKey:@"type"];
    [paramDict setObject:content forKey:@"content"];
    CPLogInfo(@"contactInfosDict = %@\n", paramDict);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_OF_UPDATE_RECENT
                                                              params:paramDict
                                                          httpMethod:K_HTTP_METHOD_POST
                                                    postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUpdateRecentResult:)] )
                {
                    NSNumber *resultCode = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleUpdateRecentResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleUpdateRecentResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleUpdateRecentResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
    [self.mkGroupChatEngine enqueueOperation:op];
}

- (void)getMyRecentForModule:(Class)clazz
{
    CPLogInfo(@"\n");
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetMyRecentResult:withContent:andContentType:andCreateTime:)] )
        {
            [observer handleGetMyRecentResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                  withContent:nil
                               andContentType:nil
                                andCreateTime:nil];
        }
        return;
    }
#endif
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_OF_GET_MY_RECENT
                                                              params:nil
                                                          httpMethod:K_HTTP_METHOD_GET
                                                    postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                 ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMyRecentResult:withContent:andContentType:andCreateTime:)] )
                {
                    NSNumber *resultCode = nil;
                    NSString *content = nil;
                    NSNumber *contentType = nil;
                    NSString *createTime = nil;
                    
                    if(K_NOT_MODIFIED != [[completedOperation readonlyResponse] statusCode])
                    {
                        if( [completedOperation responseData].length )
                        {
                            NSDictionary *rspJsonDict = [completedOperation responseJSON];
                            CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                            resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                            CPLogInfo(@"resultCode = %@\n", resultCode);
                            
                            if([resultCode intValue] == 0)
                            {
                                content = [rspJsonDict objectForKey:@"content"];
                                contentType = [rspJsonDict objectForKey:@"type"];
                                createTime = [rspJsonDict objectForKey:@"createTime"];
                            }
                        }
                        else
                        {
                            resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_NOT_MODIFIED];
                    }
                    
                    [observer handleGetMyRecentResult:resultCode withContent:content andContentType:contentType andCreateTime:createTime];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetMyRecentResult:withContent:andContentType:andCreateTime:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetMyRecentResult:resultCode withContent:nil andContentType:nil andCreateTime:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
//    [self.mkProfileEngine enqueueOperation:op];
}

- (void)getUserRecentForModule:(Class)clazz ofUserName:(NSString *)uName
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleGetUserRecentResult:ofUser:withContent:andContentType:andCreateTime:)] )
        {
            [observer handleGetUserRecentResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                         ofUser:uName
                                    withContent:nil
                                 andContentType:nil
                                  andCreateTime:nil];
        }
        
        return;
    }
#endif
    
    //anotherway ++
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:uName forKey:@"u"];
    CPLogInfo(@"param = %@\n", param);
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkProfileEngine operationWithPath:K_PATH_OF_GET_USER_RECENT
                                                              params:param
                                                          httpMethod:K_HTTP_METHOD_GET
                                                    postDataEncoding:MKNKPostDataEncodingTypeURL
                                                                 ssl:NO];
    //anotherway --
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //    op.postDataEncoding = MKNKPostDataEncodingTypeJSON;
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    ctxObj.ctxString = uName;
    //    ctxObj.srcLocalID = resourceID;
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUserRecentResult:ofUser:withContent:andContentType:andCreateTime:)] )
                {
                    NSNumber *resultCode = nil;
                    NSString *content = nil;
                    NSNumber *contentType = nil;
                    NSString *createTime = nil;
                    
                    if( [completedOperation responseData].length )
                    {
                        NSDictionary *rspJsonDict = [completedOperation responseJSON];
                        CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                        resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                        CPLogInfo(@"resultCode = %@\n", resultCode);
                        
                        if([resultCode intValue] == 0)
                        {
                            content = [rspJsonDict objectForKey:@"content"];
                            contentType = [rspJsonDict objectForKey:@"type"];
                            createTime = [rspJsonDict objectForKey:@"createTime"];
                        }
                    }
                    else
                    {
                        resultCode = [NSNumber numberWithInt:K_RESPONSE_ERR];
                    }
                    
                    [observer handleGetUserRecentResult:resultCode ofUser:ctxObj.ctxString withContent:content andContentType:contentType andCreateTime:createTime];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleGetUserRecentResult:ofUser:withContent:andContentType:andCreateTime:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    [observer handleGetUserRecentResult:resultCode ofUser:ctxObj.ctxString withContent:nil andContentType:nil andCreateTime:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }
    }];
    
    [op setQueuePriority:NSOperationQueuePriorityNormal + 1];
//    [self.mkGroupChatEngine enqueueOperation:op];
}

//otehr
- (void)pushMeForModule:(Class)clazz
{
    CPLogInfo(@"");
    
    if(isLogout)
    {
        return;
    }
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handlePushMeResult:)] )
        {
            [observer handlePushMeResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkOtherEngine operationWithPath:K_PATH_OTHER_PUSHME
                                                            params:nil
                                                        httpMethod:K_HTTP_METHOD_GET
                                                  postDataEncoding:MKNKPostDataEncodingTypeURL
                                                               ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    //    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
#if 0
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    CPLogInfo(@"opID:%@\n", uniqueId);
#endif
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
#if 0
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handlePushMeResult:)] )
                {
                    NSNumber *resultCode = [NSNumber numberWithInt:K_ERROR_NONE];
                    
                    [observer handlePushMeResult:resultCode];
                }
                
                //remove ctx;
                [self.contextDict removeObjectForKey:reqId];
            }
#endif
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
#if 0
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handlePushMeResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    
                    [observer handlePushMeResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
#endif
        }//@autoreleasepool
    }];
    
    [self.mkDownEngine enqueueOperation:op];
}

- (void)uploadDeviceInfoForModule:(Class)clazz
                              MCC:(NSString *)mcc
                              MNC:(NSString *)mnc
                            Model:(NSString *)model
                        PhoneLang:(NSString *)lan
                          Country:(NSString *)country
                              APN:(NSString *)apn
                     SoftwareLang:(NSString *)sftLan
                       PlatformID:(NSString *)pId
                        EditionID:(NSString *)eId
                        SubcoopId:(NSString *)subcId
                          Cracked:(NSNumber *)crced
                         UniqueId:(NSString *)uId
{
    CPLogInfo(@"");
    
    if(isLogout)
    {
        return;
    }
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handlePushMeResult:)] )
        {
            [observer handlePushMeResult:[NSNumber numberWithInt:K_NETWORK_ERR]];
        }
        
        return;
    }
#endif
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:mcc forKey:@"mcc"];
    [param setObject:mnc forKey:@"mnc"];
    [param setObject:model forKey:@"model"];
    [param setObject:lan forKey:@"phoneLang"];
    [param setObject:country forKey:@"country"];
    [param setObject:apn forKey:@"apn"];
    [param setObject:sftLan forKey:@"softwareLang"];
    [param setObject:pId forKey:@"platformId"];
    [param setObject:eId forKey:@"editionId"];
    [param setObject:subcId forKey:@"subcoopId"];
    [param setObject:crced forKey:@"cracked"];
    [param setObject:uId forKey:@"uniqueId"];
    
#ifdef MKNETWORKKIT_NEW_FTR
    MKNetworkOperation *op = [self.mkOtherEngine operationWithPath:K_PATH_OTHER_DEVICE_INFO
                                                            params:param
                                                        httpMethod:K_HTTP_METHOD_POST
                                                  postDataEncoding:MKNKPostDataEncodingTypeJSON
                                                               ssl:NO];
#else
    NSAssert(NO, @"new feature must be used!\n");
#endif
    
    //cookies ++
    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
#if 0
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    CPLogInfo(@"opID:%@\n", uniqueId);
#endif
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
#if 0
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handlePushMeResult:)] )
                {
                    NSNumber *resultCode = [NSNumber numberWithInt:K_ERROR_NONE];
                    
                    [observer handlePushMeResult:resultCode];
                }
                
                //remove ctx;
                [self.contextDict removeObjectForKey:reqId];
            }
#endif
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
#if 0
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handlePushMeResult:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    
                    [observer handlePushMeResult:resultCode];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
#endif
        }//@autoreleasepool
    }];
    
//    [self.mkDownEngine enqueueOperation:op];
}

- (void)checkUpdate:(Class)clazz
{
    CPLogInfo(@"");
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleCheckUpdateResult:
                                                     withSubject:
                                                     andContent:
                                                     andVersion:
                                                     andVersionCode:
                                                     andUrl:)] )
        {
            [observer handleCheckUpdateResult:[NSNumber numberWithInt:K_NETWORK_ERR]
                                  withSubject:nil
                                   andContent:nil
                                   andVersion:nil
                               andVersionCode:nil
                                       andUrl:nil];
        }
        
        return;
    }
#endif
    
    MKNetworkOperation *op = [self.mkDownEngine operationWithURLString:K_PATH_CHECK_UPDATE
                                                                params:nil
                                                            httpMethod:K_HTTP_METHOD_GET];
    
    //cookies ++
    //    [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
    //cookies --
    
    
    CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
    ctxObj.srcModuleName = NSStringFromClass(clazz);
    NSString *uniqueId = [op uniqueIdentifier];
    [self.contextDict setObject:ctxObj forKey:uniqueId];
    CPLogInfo(@"opID:%@\n", uniqueId);
    
    [op onCompletion:^(MKNetworkOperation* completedOperation) {
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleCheckUpdateResult:withSubject:andContent:andVersion:andVersionCode:andUrl:)] )
                {
                    NSNumber *resultCode = [NSNumber numberWithInt:K_ERROR_NONE];
                    
                    NSDictionary *rspJsonDict = [completedOperation responseJSON];
                    CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                    NSString *subject = [rspJsonDict objectForKey:@"subject"];
                    NSString *content = [rspJsonDict objectForKey:@"content"];
                    NSString *version = [rspJsonDict objectForKey:@"version"];
                    NSNumber *versionCode = [rspJsonDict objectForKey:@"version_code"];
                    NSString *url = [rspJsonDict objectForKey:@"url"];
                    
                    
                    [observer handleCheckUpdateResult:resultCode
                                          withSubject:subject
                                           andContent:content
                                           andVersion:version
                                       andVersionCode:versionCode
                                               andUrl:url];
                }
                
                //remove ctx;
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
        @autoreleasepool
        {
            CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
            NSString *reqId = [completedOperation uniqueIdentifier];
            CPLogInfo(@"opID:%@\n", reqId);
            CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
            if(contextObj)
            {
                id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
                
                if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
                   && [observer respondsToSelector:@selector(handleCheckUpdateResult:withSubject:andContent:andVersion:andVersionCode:andUrl:)] )
                {
                    NSNumber *resultCode = nil;
                    resultCode = [NSNumber numberWithInt:[self resultCodeFromResponseError:error]];
                    
                    [observer handleCheckUpdateResult:resultCode
                                          withSubject:nil
                                           andContent:nil
                                           andVersion:nil
                                       andVersionCode:nil
                                               andUrl:nil];
                }
                
                [self.contextDict removeObjectForKey:reqId];
            }
        }//@autoreleasepool
    }];
    
//    [self.mkDownEngine enqueueOperation:op];
}
/*
 - (void) sendXMPPMsg:(Class)clazz
 withMsg:(XMPPUserMessage *) xmppMsg
 {
 
 #ifdef SYS_STATE_MIGR
 if( ![self canPerformReq] )
 {
 id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
 
 if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
 && [observer respondsToSelector:@selector(handleHTTPSendMsg:)] )
 {
 [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
 }
 
 return;
 }
 #endif
 
 NSString *path = K_PATH_HTTP_SEND_MSG;
 [xmppMsg setUuid: [[CoreUtils getLongFormatWithNowDate]stringValue]];
 
 NSMutableDictionary *param = [xmppMsg generateHttpSendDic];
 
 CPLogInfo(@"param:%@\n", param);
 CPLogInfo(@"path:%@\n", path);
 
 #ifdef MKNETWORKKIT_NEW_FTR
 MKNetworkOperation *op = [self.mkHttpSendMsgEngine operationWithPath:path
 params:param
 httpMethod:K_HTTP_METHOD_POST
 postDataEncoding:MKNKPostDataEncodingTypeJSON
 ssl:NO];
 #else
 NSAssert(NO, @"new feature must be used!\n");
 #endif
 
 //cookie ++
 [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
 //cookie --
 
 CPHttpEngineContextObject *ctxObj = [[CPHttpEngineContextObject alloc] init];
 ctxObj.srcModuleName = NSStringFromClass(clazz);
 ctxObj.ctxDict = [NSMutableDictionary dictionary];
 [ctxObj.ctxDict setObject:xmppMsg.messageID forKey:@"MSGID"];
 
 NSString *uniqueId = [op uniqueIdentifier];
 
 [self.contextDict setObject:ctxObj forKey:uniqueId];
 
 [op onCompletion:^(MKNetworkOperation* completedOperation) {
 @autoreleasepool
 {
 CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
 NSString *reqId = [completedOperation uniqueIdentifier];
 CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
 if(contextObj)
 {
 id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
 CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
 
 
 if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
 && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
 {
 NSNumber *messageID = [contextObj.ctxDict objectForKey:@"MSGID"];
 
 if( [completedOperation responseData].length )
 {
 NSDictionary *rspJsonDict = [completedOperation responseJSON];
 CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
 NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
 CPLogInfo(@"resultCode = %@\n", resultCode);
 
 if([resultCode intValue] == K_ERROR_NONE)
 {
 [observer handleHTTPSendMsg:messageID withResult:YES];
 }
 }
 else
 {
 [observer handleHTTPSendMsg:messageID withResult:NO];
 }
 }
 
 [self.contextDict removeObjectForKey:reqId];
 }
 }
 }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
 @autoreleasepool
 {
 CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
 NSString *reqId = [completedOperation uniqueIdentifier];
 CPHttpEngineContextObject *contextObj = [self.contextDict objectForKey:reqId];
 if(contextObj)
 {
 id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:contextObj.srcModuleName];
 CPLogInfo(@"srcModuleName = %@\n", contextObj.srcModuleName);
 
 if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
 && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
 {
 NSNumber *messageID = [contextObj.ctxDict objectForKey:@"MSGID"];
 
 [observer handleHTTPSendMsg:messageID withResult:NO];
 }
 
 [self.contextDict removeObjectForKey:reqId];
 }
 }
 }];
 
 [op setQueuePriority:NSOperationQueuePriorityHigh];
 [self.mkHttpSendMsgEngine enqueueHttpMsgOperation:op];
 }
 */
- (void) sendXMPPMsg:(Class)clazz
             withMsg:(XMPPUserMessage *) xmppMsg
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleHTTPSendMsg:)] )
        {
            [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
        }
        
        return;
    }
#endif
    
    NSString *path = K_PATH_HTTP_SEND_MSG;
    if(!xmppMsg.uuid)
        [xmppMsg setUuid: [[CoreUtils getLongFormatWithNowDate]stringValue]];
    
    NSMutableDictionary *param = [xmppMsg generateHttpSendDic];
    
    CPLogInfo(@"param:%@\n", param);
    CPLogInfo(@"path:%@\n", path);
    
    /////////////////////////////////////
    
    NSString *urlString = nil;
#ifdef WWAN_TEST
    urlString = [NSString stringWithFormat:@"http://%@/%@",K_XMPP_SERVER,path];
#else
    urlString = [NSString stringWithFormat:@"http://%@/%@",K_XMPP_SERVER,path];
#endif
    
    // url
    NSURL *url = [NSURL URLWithString:urlString];
    // req
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:url];
    // method
    [req setRequestMethod:@"POST"];
    // header
    [req addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
    [req addRequestHeader:@"Content-Type" value:@"application/json"];
#ifdef TEST
    [req addRequestHeader:@"host" value:@"www.shouxiner.com"];
#endif
    // cookies
    [req setRequestCookies:[[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid, nil]];
    // body
    NSMutableData *postData =(NSMutableData *)[[param JSONString] dataUsingEncoding:NSUTF8StringEncoding] ;
    [req setPostBody:postData];
    CPLogInfo(@"%@",param);
    // userinfo
    //[req setUserInfo:[NSDictionary dictionaryWithObject:[[NSString uniqueString] md5] forKey:@"uniqueIdentifier"]];
    
    
    NSLog(@"%d",[req.requestID intValue]);
    
    // finish
    [req setCompletionBlock:^{
        //
        NSLog(@"single setCompletionBlock");
        @autoreleasepool
        {
            CPLogInfo(@"onCompletion; statusCode = %d\n", req.responseStatusCode);
            
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
            
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
            {
                if( [req responseString].length )
                {
                    NSLog(@"[req responseString]  %@", [req responseString]);
                    NSDictionary *rspJsonDict = (NSDictionary *)[[req responseData] objectFromJSONData];
                    CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                    NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    if([resultCode intValue] == K_ERROR_NONE)
                    {
                        [observer handleHTTPSendMsg:xmppMsg.messageID withResult:YES];
                    }else{
                        [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
                    }
                }
                else
                {
                    [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
                }
            }
            
            
        }
    }];
    
    // fail
    [req setFailedBlock:^{
        //
        NSLog(@"single setFailedBlock");
        CPLogInfo(@"req.error %@",req.error);
        @autoreleasepool
        {
            CPLogInfo(@"onFail; statusCode = %d\n", req.responseStatusCode);
            //CPLogInfo(@"req.error %@",req.error);
            
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
            {
                
                [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
            }
            
            
        }
    }];
    
    [req setQueuePriority:NSOperationQueuePriorityHigh];
    //[req startAsynchronous];
    [self.asiHttpSendMsgQueue addOperation:req];
    /////////////////////////////////////
    /*
     #ifdef MKNETWORKKIT_NEW_FTR
     MKNetworkOperation *op = [self.mkHttpSendMsgEngine operationWithPath:path
     params:param
     httpMethod:K_HTTP_METHOD_POST
     postDataEncoding:MKNKPostDataEncodingTypeJSON
     #ifdef WWAN_TEST
     ssl:YES
     #else
     ssl:NO
     #endif
     ];
     #else
     NSAssert(NO, @"new feature must be used!\n");
     #endif
     
     //cookie ++
     [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
     //cookie --
     
     [op onCompletion:^(MKNetworkOperation* completedOperation) {
     @autoreleasepool
     {
     CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
     
     id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
     
     
     if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
     && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
     {
     if( [completedOperation responseData].length )
     {
     NSDictionary *rspJsonDict = [completedOperation responseJSON];
     CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
     NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
     CPLogInfo(@"resultCode = %@\n", resultCode);
     
     if([resultCode intValue] == K_ERROR_NONE)
     {
     [observer handleHTTPSendMsg:xmppMsg.messageID withResult:YES];
     }
     }
     else
     {
     [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
     }
     }
     
     
     }
     }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
     @autoreleasepool
     {
     CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
     
     id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
     
     if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
     && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
     {
     
     [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
     }
     
     
     }
     }];
     
     [op setQueuePriority:NSOperationQueuePriorityHigh];
     [self.mkHttpSendMsgEngine enqueueHttpMsgOperation:op];
     */
}


- (void) sendXMPPGroupMsg:(Class)clazz
                  withMsg:(XMPPGroupMessage *) xmppMsg
{
    
#ifdef SYS_STATE_MIGR
    if( ![self canPerformReq] )
    {
        id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:NSStringFromClass(clazz)];
        
        if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
           && [observer respondsToSelector:@selector(handleHTTPSendMsg:)] )
        {
            [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
        }
        
        return;
    }
#endif
    
    NSString *path = K_PATH_HTTP_SEND_MSG;
    [xmppMsg setUuid: [[CoreUtils getLongFormatWithNowDate]stringValue]];
    NSMutableDictionary *param = [xmppMsg generateHttpSendDic];
    
    
    /////////////////////////////////////
    
    NSString *urlString = nil;
#ifdef WWAN_TEST
    urlString = [NSString stringWithFormat:@"https://%@/%@",K_XMPP_SERVER,path];
#else
    urlString = [NSString stringWithFormat:@"http://%@/%@",K_XMPP_SERVER,path];
#endif
    
    // url
    NSURL *url = [NSURL URLWithString:urlString];
    // req
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:url];
    // method
    [req setRequestMethod:@"POST"];
    // header
    [req addRequestHeader:@"User-Agent" value:@"ASIHTTPRequest"];
    [req addRequestHeader:@"Content-Type" value:@"application/json"];
    // cookies
    [req setRequestCookies:(NSMutableArray *)[self cookiesArray]];
    // body
    NSMutableData *postData =(NSMutableData *)[[param JSONString] dataUsingEncoding:NSUTF8StringEncoding] ;
    [req setPostBody:postData];
    CPLogInfo(@"%@",param);
    // finish
    [req setCompletionBlock:^{
        //
        CPLogInfo(@"group setCompletionBlock");
        @autoreleasepool
        {
            
            CPLogInfo(@"onCompletion; statusCode = %d\n", req.responseStatusCode);
            
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
            
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
            {
                if( [req responseString].length )
                {
                    NSLog(@"[req responseString]  %@", [req responseString]);
                    NSDictionary *rspJsonDict = (NSDictionary *)[[req responseData] objectFromJSONData];
                    CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
                    NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
                    CPLogInfo(@"resultCode = %@\n", resultCode);
                    
                    if([resultCode intValue] == K_ERROR_NONE)
                    {
                        [observer handleHTTPSendMsg:xmppMsg.messageID withResult:YES];
                    }else{
                        [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
                    }
                }
                else
                {
                    [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
                }
            }
        }
    }];
    
    // fail
    [req setFailedBlock:^{
        //
        NSLog(@"group setFailedBlock");
        @autoreleasepool
        {
            CPLogInfo(@"onFail; statusCode = %d\n", req.responseStatusCode);
            CPLogInfo(@"req.error %@",req.error);
            
            id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
            
            if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
               && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
            {
                
                [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
            }
        }
    }];
    
    [req setQueuePriority:NSOperationQueuePriorityHigh];
    [self.asiHttpSendMsgQueue addOperation:req];
    //[req startAsynchronous];
    
    /*
     #ifdef MKNETWORKKIT_NEW_FTR
     MKNetworkOperation *op = [self.mkHttpSendMsgEngine operationWithPath:path
     params:param
     httpMethod:K_HTTP_METHOD_POST
     postDataEncoding:MKNKPostDataEncodingTypeJSON
     #ifdef WWAN_TEST
     ssl:YES
     #else
     ssl:NO
     #endif
     ];
     #else
     NSAssert(NO, @"new feature must be used!\n");
     #endif
     
     //cookie ++
     [op addHeaders:[NSHTTPCookie requestHeaderFieldsWithCookies:[self cookiesArray]]];
     //cookie --
     
     [op onCompletion:^(MKNetworkOperation* completedOperation) {
     @autoreleasepool
     {
     CPLogInfo(@"onCompletion; statusCode = %d\n", [[completedOperation readonlyResponse] statusCode]);
     
     id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
     
     
     if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
     && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
     {
     if( [completedOperation responseData].length )
     {
     NSDictionary *rspJsonDict = [completedOperation responseJSON];
     CPLogInfo(@"rspJsonDict = %@\n", rspJsonDict);
     NSNumber *resultCode = [rspJsonDict objectForKey:K_ERRORNO_STRING];
     CPLogInfo(@"resultCode = %@\n", resultCode);
     
     if([resultCode intValue] == K_ERROR_NONE)
     {
     [observer handleHTTPSendMsg:xmppMsg.messageID withResult:YES];
     }
     }
     else
     {
     [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
     }
     }
     }
     }onError_V2:^(MKNetworkOperation* completedOperation, NSError* error) {
     @autoreleasepool
     {
     CPLogInfo(@"onError_V2; errorCode = %d; userinfo = %@\n", error.code, error.userInfo);
     id<CPHttpEngineObserver> observer = [self.observerDict objectForKey:@"CPSystemManager"];
     
     if( [observer conformsToProtocol:@protocol(CPHttpEngineObserver)]
     && [observer respondsToSelector:@selector(handleHTTPSendMsg:withResult:)] )
     {
     
     [observer handleHTTPSendMsg:xmppMsg.messageID withResult:NO];
     }
     
     }
     }];
     
     [op setQueuePriority:NSOperationQueuePriorityHigh];
     [self.mkHttpSendMsgEngine enqueueHttpMsgOperation:op];
     */
}



@end












