//
//  MyOperation.h
//  teacher
//
//  Created by singlew on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmOperation.h"

typedef enum{
    kGetCredits,
    kCheckVersion,
    kActivate,
}MyType;

@interface MyOperation : PalmOperation
@property (nonatomic) MyType type;
-(MyOperation *) initGetCredits;
-(MyOperation *) initCheckVersion;
-(MyOperation *) initActivate : (NSString *) userName withTelPhone : (NSString *) telPhone withEmail : (NSString *) email withPassWord : (NSString *) password;
@end