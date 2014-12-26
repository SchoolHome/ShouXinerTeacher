//
//  SystemOperation.h
//  teacher
//
//  Created by singlew on 14-8-12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmOperation.h"

typedef enum{
    kGetAdvInfo,
    kGetAdvInfoWithGroup,
    kGetSmsVerifyCode,
    kGetCustomerServiceTel,
    // 登陆前获取短信验证码
    kGetResetPasswordSMS,
    // 登陆前重置密码
    kPostResetPassword,
    
}SystemType;

@interface SystemOperation : PalmOperation
-(SystemOperation *) initGetAdvInfo;
-(SystemOperation *) initGetAdvInfo : (int) groupID;
-(SystemOperation *) initGetSMSVerifyCode : (NSString *)mobile;
-(SystemOperation *) initGetCustomerServiceTel;

-(SystemOperation *) initGetResetPasswordSMS : (NSString *) mobileNumber;
-(SystemOperation *) initPostResetPassword : (NSString *) smsID withSmsCode : (NSString *) smsCode withNewPassword : (NSString *) newPassword;

@end
