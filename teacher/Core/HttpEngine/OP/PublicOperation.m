//
//  PubulicOperation.m
//  teacher
//
//  Created by singlew on 14/11/20.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PublicOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"

@interface PublicOperation ()
@property (nonatomic) PublicMessageType type;
-(void) getPublicMessage;
-(void) postPublicMessageForward;
@end

@implementation PublicOperation
-(PublicOperation *) initGetPublicMessage : (NSString *) mids{
    self = [self initOperation];
    if (nil != self) {
        self.type = kGetPublicMessage;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/pubMessageBatch?mids=%@",K_HOST_NAME_OF_PALM_SERVER,mids];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(PublicOperation *) initPostPublicMessageForward : (NSString *) mid withGroupID : (int) groupID withMessage : (NSString *) message{
    if ([self initOperation]) {
        self.type = kPostPublicMessage;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/pubMessageForward",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       mid == nil ? @"" : mid , @"mid",
                                                       [NSNumber numberWithInt:groupID], @"groupid",
                                                       message == nil ? @"" : message , @"message",
                                                       nil]];
    }
    return self;
}

-(void) getPublicMessage{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].publicMessageResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) postPublicMessageForward{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].publicMessageForwardResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}


-(void) main{
    @autoreleasepool {
        switch (self.type) {
            case kGetPublicMessage:
                [self getPublicMessage];
                break;
            case kPostPublicMessage:
                [self postPublicMessageForward];
                break;
            default:
                break;
        }
    }
}
@end
