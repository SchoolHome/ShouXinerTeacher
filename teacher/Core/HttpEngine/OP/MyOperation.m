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
        NSDictionary *pa = [[NSDictionary alloc] initWithObjectsAndKeys:@"ios_v2_teacher", @"platform", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"], @"version", nil];
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

-(void) main{
    switch (self.type) {
        case kGetCredits:
            [self getCredits];
            break;
        case kCheckVersion:
            [self checkVersion];
            break;
        default:
            break;
    }
}
@end
