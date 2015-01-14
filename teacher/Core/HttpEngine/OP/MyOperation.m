//
//  MyOperation.m
//  teacher
//
//  Created by singlew on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "MyOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"

@interface MyOperation ()
-(void) getCredits;
-(void) checkVersion;
-(void) postActivate;
@end

@implementation MyOperation

-(MyOperation *)initGetCredits{
    if ([self initOperation]) {
        self.type = kGetCredits;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/credits",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(MyOperation *) initCheckVersion{
    if ([self initOperation]) {
        self.type = kCheckVersion;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/checkUpdate",K_HOST_NAME_OF_PALM_SERVER];
#ifdef IS_TEACHER
        NSDictionary *pa = [[NSDictionary alloc] initWithObjectsAndKeys:@"ios_v2_teacher", @"platform", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil];
#else
        NSDictionary *pa = [[NSDictionary alloc] initWithObjectsAndKeys:@"ios_v2", @"platform", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil];
#endif
        [self setHttpRequestPostWithUrl:urlStr params:pa];
    }
    return self;

}

-(MyOperation *) initActivate : (NSString *) userName withTelPhone : (NSString *) telPhone withVerifyCode:(NSString *)verifyCode withEmail : (NSString *) email withPassWord : (NSString *) password{
    if ([self initOperation]) {
        self.type = kActivate;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/active",K_HOST_NAME_OF_PALM_SERVER];
        NSMutableDictionary *pa = [[NSMutableDictionary alloc] init];
        [pa setObject:userName forKey:@"username"];
        if (nil != telPhone && ![telPhone isEqualToString:@""]) {
            [pa setObject:telPhone forKey:@"mobile"];
        }
        if (nil != email && ![email isEqualToString:@""]) {
            [pa setObject:email forKey:@"email"];
        }
        if (nil != password && ![password isEqualToString:@""]) {
            [pa setObject:password forKey:@"password"];
        }
        if (nil!= verifyCode && ![verifyCode isEqualToString:@""]) {
            [pa setObject:verifyCode forKey:@"verifycode"];
        }
        [self setHttpRequestPostWithUrl:urlStr params:pa];
    }
    return self;
}

-(void) getCredits{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].userCredits = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) checkVersion{
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].checkVersion = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) postActivate{
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].activateDic = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) main{
    switch (self.type) {
        case kGetCredits:
            [self getCredits];
            break;
        case kCheckVersion:
            [self checkVersion];
            break;
        case kActivate:
            [self postActivate];
            break;
        default:
            break;
    }
}
@end
