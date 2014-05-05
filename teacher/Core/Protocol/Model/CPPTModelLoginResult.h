//
//  CPPTModelLoginResult.h
//  iCouple
//
//  Created by yl s on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPPTModelLoginResult : NSObject
{
    NSNumber *bindPhone_;   //bool
    NSString *domain_;      //domain
}

@property (strong, nonatomic) NSNumber *bindPhone;
@property (strong, nonatomic) NSString *domain;
@property (strong, nonatomic) NSString *imserverIP;
@property (strong, nonatomic) NSString *serverPort;
@property (strong, nonatomic) NSString *suid;
@property (strong ,nonatomic) NSString *uid;

@property (nonatomic) BOOL activated;
@property (nonatomic) BOOL force;
@property (nonatomic) BOOL recommend;
@property (strong,nonatomic) NSString *url;
@property (strong,nonatomic) NSString *version;
+ (CPPTModelLoginResult *)fromJsonDict:(NSDictionary *)jsonDict;

@end
