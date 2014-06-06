//
//  GroupOperation.m
//  teacher
//
//  Created by singlew on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "GroupOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"

@interface GroupOperation ()
-(void) getGroupList;
-(void) getGroupStudents;
@end

@implementation GroupOperation
-(GroupOperation *) initGetGroupList{
    if ([self initOperation]) {
        self.type = kGetGroupList;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getGroupList",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(GroupOperation *) initGetGroupStudent : (NSString *) groupids{
    if ([self initOperation]) {
        self.type = kGetGroupStudent;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getGroupStudent?gids=%@",K_HOST_NAME_OF_PALM_SERVER,groupids];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(void) getGroupList{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            [PalmUIManagement sharedInstance].userGroupList = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getGroupStudents{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            [PalmUIManagement sharedInstance].groupStudents = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) main{
    switch (self.type) {
        case kGetGroupList:
            [self getGroupList];
            break;
        case kGetGroupStudent:
            [self getGroupStudents];
            break;
        default:
            break;
    }
}
@end
