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
}SystemType;

@interface SystemOperation : PalmOperation
-(SystemOperation *) initGetAdvInfo;
-(SystemOperation *) initGetAdvInfo : (int) groupID;
-(SystemOperation *) initGetSMSVerifyCode : (NSString *)mobile;
@end
