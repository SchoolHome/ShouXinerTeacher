//
//  DiscoverOperation.m
//  teacher
//
//  Created by singlew on 14/11/6.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "DiscoverOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"

@interface DiscoverOperation ()
@property (nonatomic) DiscoverType type;
-(void) getDiscoverInfo;
@end

@implementation DiscoverOperation
-(DiscoverOperation *) initGetDiscoverInfo{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetDiscover;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/discover",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(void) getDiscoverInfo{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].discoverResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) main{
    @autoreleasepool {
        switch (self.type) {
            case kGetDiscover:
                [self getDiscoverInfo];
                break;
            default:
                break;
        }
    }
}
@end
