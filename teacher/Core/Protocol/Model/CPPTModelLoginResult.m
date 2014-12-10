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
            result.activated = [[jsonDict objectForKey:@"activated"] boolValue];
            result.force = [[[jsonDict objectForKey:@"update"] objectForKey:@"force"] boolValue];
            result.recommend = [[[jsonDict objectForKey:@"update"] objectForKey:@"recommend"] boolValue];
            if([jsonDict objectForKey:@"setUserName"] != nil && [jsonDict objectForKey:@"setUserName"] != [NSNull null]){
                result.needSetUserName = [[jsonDict objectForKey:@"setUserName"] boolValue];
            }
            result.needSetUserName = NO;
            result.url = [[jsonDict objectForKey:@"update"] objectForKey:@"url"];
            result.version = [[jsonDict objectForKey:@"update"] objectForKey:@"version"];
            result.mobile = [jsonDict objectForKey:@"mobile"];
        }
    }
    
    return result;
}

@end
