//
//  CPOperationReceiveYTZMessage.m
//  teacher
//
//  Created by ZhangQing on 14-7-21.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "CPOperationReceiveYTZMessage.h"

#import "CPSystemEngine.h"
#import "XMPPNoticeMessage.h"

@implementation CPOperationReceiveYTZMessage
- (id) initWithMsgs:(NSArray *) receiveMsgs
{
    self = [super init];
    if (self)
    {
        YTZMsgs = receiveMsgs;
    }
    return self;
}
-(NSNumber *)excuteUserMsgWithMsg:(XMPPNoticeMessage *)msg
{
    
    return [NSNumber numberWithInteger:1];
}
-(void)main
{
    @autoreleasepool
    {
        for(NSObject *receiveMsg in YTZMsgs)
        {
            NSNumber *newMsgID = nil;
            if (receiveMsg&&[receiveMsg isKindOfClass:[XMPPNoticeMessage class]])
            {
                newMsgID = [self excuteUserMsgWithMsg:(XMPPNoticeMessage *)receiveMsg];
            }
            if (newMsgID)
            {
                //[[[CPSystemEngine sharedInstance] msgManager] refreshMsgGroupByAppendMsgWithNewMsgID:newMsgID];
            }
        }
    }
}
@end
