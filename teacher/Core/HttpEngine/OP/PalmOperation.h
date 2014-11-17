//
//  PalmOperation.h
//  teacher
//
//  Created by singlew on 14-3-7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PalmHTTPRequest.h"
#import "PalmFormDataRequest.h"
#import "CPLGModelAccount.h"
#import "CPSystemEngine.h"

//连接服务器超时时间
#define TimeOutSeconds 30
#define CachePath @"/%@/cachetemp/"
#define UserDefaults_UserToken @"UserToken"

// 定义返回Dictionary Key
#define ASI_REQUEST_HAS_ERROR @"hasError"
#define ASI_REQUEST_ERROR_MESSAGE @"errorMessage"
#define ASI_REQUEST_DATA @"data"
#define ASI_REQUEST_CONTEXT @"context"

@interface PalmOperation : NSOperation
@property(nonatomic,strong) id delegate;
@property(nonatomic) SEL action;
@property (nonatomic,strong) NSString *signKey;
@property (nonatomic,strong) NSString *signFormatString;
//Request
@property (nonatomic,strong) PalmHTTPRequest *request;
@property (nonatomic,strong) PalmFormDataRequest *dataRequest;

-(PalmOperation *) initOperation;
-(PalmOperation *) initOperation : (id) delegate withActon : (SEL) action;
-(NSString*)GetUserAgent;

//Get方法
-(void) setHttpRequestGetWithUrl:(NSString *)urlStr;
//Post方法
-(void) setHttpRequestPostWithUrl:(NSString *)urlStr params:(NSDictionary*)params;
-(void) setHttpRequestPostWithUrl:(NSString *)urlStr params:(NSDictionary*)params files:(NSDictionary*)files;
-(void) setHttpRequestPostWithUrl:(NSString *)urlStr params:(NSDictionary*)params imgDataDict:(NSDictionary*)filesDict;
// 开始异步请求
-(void) startAsynchronous;
// 开始同步请求
-(void) startSynchronous;

-(NSString *) getToken;

@end
