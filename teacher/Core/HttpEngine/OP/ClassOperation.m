//
//  ClassOperation.m
//  teacher
//
//  Created by singlew on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ClassOperation.h"
#import "PalmUIManagement.h"
#import "CPHttpEngineConst.h"

@interface ClassOperation ()
@property (nonatomic) ClassData type;
-(void) getNotiList;
-(void) getGroupList;
-(void) getGroupTopic;
-(void) postPraise;
-(void) postComment;
-(void) getNotiCount;
-(void) getNewNotiList;
-(void) getUnReadCount;
-(void) getNotiSenderList;
-(void) postForwardNoti;
-(void) postRecommend;
-(void) getDeleteTopic;
@end

@implementation ClassOperation

-(ClassOperation *) initNotiList : (int) timeStamp{
    if ([self initOperation]) {
        self.type = kClassNotification;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/OAList?ts=%d",K_HOST_NAME_OF_PALM_SERVER,timeStamp];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(ClassOperation *) initGroupList{
    if ([self initOperation]) {
        self.type = kGetGroupListData;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getGroupList",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(ClassOperation *) initGroupTopic : (int) groupID withTimeStamp : (int) timeStamp withOffset : (int) offset withLimit : (int) limit{
    if ([self initOperation]) {
        self.type = kGetGroupTopic;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getTopicInfoList?groupid=%d&ts=%d&offset=%d&size=%d",K_HOST_NAME_OF_PALM_SERVER,groupID,timeStamp,offset,limit];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 点赞
-(ClassOperation *) initPraise : (long long) topicID{
    if ([self initOperation]) {
        self.type = kPostPraise;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/praise/%lli",K_HOST_NAME_OF_PALM_SERVER,topicID];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 发表评论
-(ClassOperation *) initComment : (NSString *) commentContent withReplyToUid : (int) uid withTopicID : (long long) topicID{
    if ([self initOperation]) {
        self.type = kPostComment;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/comment/%lli",K_HOST_NAME_OF_PALM_SERVER,topicID];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:commentContent,@"comment",
                                                       [NSNumber numberWithInt:uid],@"replyto",nil]];
    }
    return self;
}

// 推荐话题
-(ClassOperation *) initPostRecommend : (long long) topicID withToHomePage : (BOOL) hasHomePage withToUpGroup : (BOOL) hasUpGroup{
    if ([self initOperation]) {
        self.type = kPostRecommend;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/recommend",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:topicID],@"topicid",
                                                       [NSNumber numberWithBool:hasHomePage],@"toHomePage",
                                                       [NSNumber numberWithBool:hasUpGroup],@"toUpGroup",nil]];
    }
    return self;
}

-(ClassOperation *) initDeleteTopic : (long long) topicID{
    if ([self initOperation]) {
        self.type = kGetDeleteTopicID;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/deleteTopic/%lli",K_HOST_NAME_OF_PALM_SERVER,topicID];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 获取新消息数量
-(ClassOperation *) initGetNotiCount{
    if ([self initOperation]) {
        self.type = kGetNotiCount;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getNotifyCount",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 获取新消息列
-(ClassOperation *) initGetNotiList : (int) offset withLimit : (int) limit{
    if ([self initOperation]) {
        self.type = kGetNotiList;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getNotifyList?offset=%d&size=%d",K_HOST_NAME_OF_PALM_SERVER,offset,limit];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 根据topicID获取
-(ClassOperation *) initGetNotiWithTopicID : (long long) topicID{
    if ([self initOperation]) {
        self.type = kPostPraise;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getTopicInfo?topic=%lli",K_HOST_NAME_OF_PALM_SERVER,topicID];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}


// 有指示未读
-(ClassOperation *) initUnReadNotiCount : (long long) timeStamp{
    if ([self initOperation]) {
        self.type = kGetNotiUnReadCount;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/OAListCount?ts=%lli",K_HOST_NAME_OF_PALM_SERVER,timeStamp];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 获取有指示列表
-(ClassOperation *) initNotiListWithSender : (int) sender withOffset : (int) offset withLimit : (int) limit{
    if ([self initOperation]) {
        self.type = kGetNotiSenderList;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/OAListHistory?sender=%d&start=%d&size=%d",K_HOST_NAME_OF_PALM_SERVER,sender,offset,limit];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

// 转发有指示
-(ClassOperation *) initForwardNoti : (int) oaid withGroupID : (int) groupID withMessage : (NSString *) message{
    if ([self initOperation]) {
        self.type = kPostForwardNoti;
        
       NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:oaid],@"oaid",
         [NSNumber numberWithInt:groupID],@"groupid",
                             message,@"message",nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/OAForward",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:params];
    }
    return self;
}


-(void) getNotiList{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].notiList = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getGroupList{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            
            NSLog(@"%@",data);
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            NSArray *list = data[@"data"][@"list"];
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBGroupModel *model = [BBGroupModel fromJson:obj];
                if (model) {
                    [arr addObject:model];
                }
            }];
            //[PalmUIManagement sharedInstance].groupList = arr;
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:data[@"hasError"] forKey:@"hasError"];
            if ([arr count]>0) {
                [dic setObject:arr forKey:@"data"];
            }
            
            [PalmUIManagement sharedInstance].groupListResult = dic;
            
            
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getGroupTopic{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            NSArray *list = data[@"data"][@"list"];
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBTopicModel *model = [BBTopicModel fromJson:obj];
                if (model) {
                    [arr addObject:model];
                }
            }];
            //[PalmUIManagement sharedInstance].groupTopicList = arr;
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:data[@"hasError"] forKey:@"hasError"];
            if ([arr count]>0) {
                [dic setObject:arr forKey:@"data"];
            }
            
            [PalmUIManagement sharedInstance].groupTopicListResult = dic;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) postPraise{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].praiseResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) postRecommend{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].recommendResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) postComment{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].commentResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getNotiCount{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].notifyCount = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getNewNotiList{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            
//            BBNotifyModel
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            NSArray *list = data[@"data"][@"list"];
            [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBNotifyModel *model = [BBNotifyModel fromJson:obj];
                if (model) {
                    [arr addObject:model];
                }
            }];
            
            [PalmUIManagement sharedInstance].notifyList = arr;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getUnReadCount{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].notiUnReadCount = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getNotiSenderList{
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].notiWithSenderList = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) postForwardNoti{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].postForwardResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) getDeleteTopic{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t t = ^{
            DDLogCInfo(@"%@",data);
            [PalmUIManagement sharedInstance].deleteTopicResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), t);
    }];
    [self startAsynchronous];
}

-(void) main{
    switch (self.type) {
        case kClassNotification:
            [self getNotiList];
            break;
        case kGetGroupListData:
            [self getGroupList];
            break;
        case kGetGroupTopic:
            [self getGroupTopic];
            break;
        case kPostPraise:
            [self postPraise];
            break;
        case kPostComment:
            [self postComment];
            break;
        case kGetNotiCount:
            [self getNotiCount];
            break;
        case kGetNotiList:
            [self getNewNotiList];
            break;
        case kGetNotiUnReadCount:
            [self getUnReadCount];
            break;
        case kGetNotiSenderList:
            [self getNotiSenderList];
            break;
        case kPostForwardNoti:
            [self postForwardNoti];
            break;
        case kPostRecommend:
            [self postRecommend];
            break;
        case kGetDeleteTopicID:
            [self getDeleteTopic];
            break;
        default:
            break;
    }
}

@end
