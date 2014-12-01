//
//  FXStringUtil.m
//  iCouple
//
//  Created by lixiaosong on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FXStringUtil.h"
#import "RegexKitLite.h"
@implementation FXStringUtil
+ (BOOL)do_check_is_mobile_string:(NSString *)string{
    /*
    NSString * regex_string_cm = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    NSString * regex_string_cu = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    NSString * regex_string_ct = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
     */
    NSString * regex_string = @"^[0-9]{11}$";
    BOOL result_bool = [string isMatchedByRegex:regex_string];
    return result_bool;
}

+ (NSString *)fliterStringIsNull:(NSString *)str
{
    if (![str isKindOfClass:[NSNull class]] && str.length>0) {
        return str;
    }
    return @"";
}
@end
