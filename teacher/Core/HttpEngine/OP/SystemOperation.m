//
//  SystemOperation.m
//  teacher
//
//  Created by singlew on 14-8-12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "SystemOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"

@interface SystemOperation ()
@property (nonatomic) SystemType type;
-(void) getAdvInfo;
-(void) getAdvInfoWithGroupID;
-(void) getSmsVerifyCode;
-(void) getCustomerServiceTel;
-(void) getResetPasswordSMS;
-(void) postResetPassword;
@end

@implementation SystemOperation
-(SystemOperation *) initGetAdvInfo{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetAdvInfo;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/adv/login",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(SystemOperation *) initGetAdvInfo : (int) groupID{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetAdvInfoWithGroup;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/adv/login?groupid=%d",K_HOST_NAME_OF_PALM_SERVER,groupID];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(SystemOperation *) initGetCustomerServiceTel{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetCustomerServiceTel;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/cs400",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(SystemOperation *) initGetSMSVerifyCode : (NSString *)mobile{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetSmsVerifyCode;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getSMSVerifyCode",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:mobile,@"mobile", nil]];
    }
    return self;
}

-(SystemOperation *) initGetResetPasswordSMS : (NSString *) mobileNumber{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetResetPasswordSMS;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/resetPasswordSMS",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(SystemOperation *) initPostResetPassword : (NSString *) smsID withSmsCode : (NSString *) smsCode withNewPassword : (NSString *) newPassword{
    if ([self initOperation]) {
        self.type = kPostResetPassword;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/resetPassword",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       smsID == nil ? @"" : smsID , @"id",
                                                       smsCode == nil ? @"" : smsCode , @"code",
                                                       newPassword == nil ? @"" : newPassword , @"newPassword",
                                                       nil]];
    }
    return self;
}

-(void) getAdvInfo{
    __weak PalmHTTPRequest *weakRequest = self.request;
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            NSArray *cookies = weakRequest.responseCookies;
            for (NSHTTPCookie *cookie in cookies){
                if([cookie.name isEqualToString:@"SUID"]){
                    [PalmUIManagement sharedInstance].suid = cookie;
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                }
            }
            [PalmUIManagement sharedInstance].advResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) getAdvInfoWithGroupID{
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].advWithGroupResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) getSmsVerifyCode{
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].smsVerifyCode = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) getCustomerServiceTel{
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].customerServiceTel = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) getResetPasswordSMS{
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].resetSMSCode = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) postResetPassword{
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].resetPassword = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}


-(void) main{
    @autoreleasepool {
        switch (self.type) {
            case kGetAdvInfo:
                [self getAdvInfo];
                break;
            case kGetAdvInfoWithGroup:
                [self getAdvInfoWithGroupID];
                break;
            case kGetSmsVerifyCode:
                [self getSmsVerifyCode];
                break;
            case kGetCustomerServiceTel:
                [self getCustomerServiceTel];
                break;
            case kGetResetPasswordSMS:
                [self getResetPasswordSMS];
                return;
            case kPostResetPassword:
                [self postResetPassword];
                return;
            default:
                break;
        }
    }
}
@end
