//
//  CPPTModelLoginResult.m
//  iCouple
//
//  Created by yl s on 12-3-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPPTModelLoginResult.h"

#import "JSONKit.h"

#define K_BINDPHONE         @"bindPhone"
#define K_DOMAIN            @"domain"

@implementation CPPTModelLoginResult

@synthesize bindPhone = bindPhone_;
@synthesize domain = domain_;

+ (CPPTModelLoginResult *)fromJsonDict:(NSDictionary *)jsonDict
{
    CPPTModelLoginResult *result = nil;
    
    if(jsonDict)
    {
        result = [[CPPTModelLoginResult alloc] init];
        if(result)
        {
            result.bindPhone = [jsonDict objectForKey:@"K_BINDPHONE"];
            result.domain = [jsonDict objectForKey:@"im_server_domain"];
            result.imserverIP = [jsonDict objectForKey:@"im_server_ip"];
            result.serverPort = [jsonDict objectForKey:@"im_server_port"];
            result.suid = jsonDict[@"suid"];
            result.uid = jsonDict[@"uid"];
        }
    }
    
    return result;
}

@end
