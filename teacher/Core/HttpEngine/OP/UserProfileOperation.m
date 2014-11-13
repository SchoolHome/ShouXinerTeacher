//
//  UserProfileOperation.m
//  teacher
//
//  Created by singlew on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "UserProfileOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"
#import "CoreUtils.h"
#import "NSString+MKNetworkKitAdditions.h"

@interface UserProfileOperation ()
@property (nonatomic) UserProfile type;
@property (nonatomic,strong) NSString* fileName;
-(void) getUserProfile;
-(void) getUserContacts;
-(void) updateUserHeader;
-(void) updateUserHeaderResult;
-(void) updateUserImageFile;
-(void) postTopic;
-(void) userLogin;
-(void) getUserProfileWithUID;
-(void) postUserInfo;
@end

@implementation UserProfileOperation


-(UserProfileOperation *) initGetUser{
    if ([self initOperation]) {
        self.type = kGetUserProfile;
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getUserInfo?uid=%@",K_HOST_NAME_OF_PALM_SERVER,account.uid];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(UserProfileOperation *) initGetUserInfoWithUID : (NSString *) UID{
    if ([self initOperation]) {
        self.type = kGetUserProfileWithUID;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getUserInfo?uid=%@",K_HOST_NAME_OF_PALM_SERVER,UID];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(UserProfileOperation *) initGetContacts{
    if ([self initOperation]) {
        self.type = kGetUserContacts;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/getContacts",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestGetWithUrl:urlStr];
    }
    return self;
}

-(UserProfileOperation *) initUpdateUserHeaderImage:(NSData *)imageData{
    if ([self initOperation]) {
        self.type = kUpdateUserHeaderImage;
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSString *writeFileName = [NSString stringWithFormat:@"%@.%@",[CoreUtils getUUID],@".jpg"];
        BOOL isSave = NO;
        NSString *filePath = [NSString stringWithFormat:@"%@/msg/",account.loginName];
        [CoreUtils createPath:filePath];
        isSave = [CoreUtils writeToFileWithData:imageData file_name:writeFileName andPath:filePath];
        self.fileName = [NSString stringWithFormat:@"%@/%@%@",[CoreUtils getDocumentPath],filePath,writeFileName];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/attachment/put/open/logo/%@",K_HOST_NAME_OF_PALM_UPLOAD,account.uid];
        [self setHttpRequestPostWithUrl:urlStr params:nil];
    }
    return self;
}

-(UserProfileOperation *) initUpdateUserHeader:(NSString *)imageUrlPath{
    if ([self initOperation]) {
        self.type = kUpdateUserHeader;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/setUserInfo",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:imageUrlPath,@"avatar", nil]];
    }
    return self;
}

-(UserProfileOperation *) initSetUserInfo:(NSString *)avatar withMobile:(NSString *)mobile withVerifyCode:(NSString *)verifyCode withPasswordOld:(NSString *)passwordOld withPasswordNew:(NSString *)passwordNew withSex:(int)sex withSign:(NSString *)sign{
    if ([self initOperation]) {
        self.type = kPostUserInfo;
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/setUserInfo",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       avatar == nil ? @"" : avatar , @"avatar",
                                                       mobile == nil ? @"" : mobile , @"mobile",
                                                       verifyCode == nil ? @"" : verifyCode , @"verifycode",
                                                       passwordOld == nil ? @"" : passwordOld , @"passwordOld",
                                                       passwordNew == nil ? @"" : passwordNew , @"passwordNew",
                                                       [NSNumber numberWithInt:sex],@"sex",
                                                       sign == nil ? @"" : sign , @"sign",
                                                       nil]];
    }
    return self;
}

-(UserProfileOperation *) initUpdateUserImageFile : (NSData *) imageData withGroupID : (int) groupID{
    if ([self initOperation]) {
        self.type = kUpdateUserImage;
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSString *writeFileName = [NSString stringWithFormat:@"%@.%@",[CoreUtils getUUID],@".jpg"];
        BOOL isSave = NO;
        NSString *filePath = [NSString stringWithFormat:@"%@/msg/",account.loginName];
        [CoreUtils createPath:filePath];
        isSave = [CoreUtils writeToFileWithData:imageData file_name:writeFileName andPath:filePath];
        self.fileName = [NSString stringWithFormat:@"%@/%@%@",[CoreUtils getDocumentPath],filePath,writeFileName];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/attachment/put/open/2/%@/%d",K_HOST_NAME_OF_PALM_UPLOAD,account.uid,groupID];
        [self setHttpRequestPostWithUrl:urlStr params:nil];
    }
    return self;
}

-(UserProfileOperation *) initPostTopic : (int) groupid withTopicType : (int) topicType withSubject : (int) subject withTitle : (NSString *) title
                            withContent : (NSString *) content withAttach : (NSString *) attach{
    if ([self initOperation]) {
        self.type = kPostTopic;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:groupid],@"groupid",
                                [NSNumber numberWithInt:topicType],@"topictype",
                                [NSNumber numberWithInt:subject],@"subject",
                                title,@"title",content,@"content",attach,@"attach",nil];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/createTopic",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:params];
    }
    return self;
}

// 拍表现
-(UserProfileOperation *) initPostPBX : (int) groupid withTitle : (NSString *) title withContent : (NSString *) content withAttach : (NSString *) attach withAward : (NSString *) students withToHomePage : (BOOL) hasHomePage withToUpGroup : (BOOL) hasTopGroup{
    
    if ([self initOperation]) {
        self.type = kPostPBX;
        
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:groupid],@"groupid",
                                [NSNumber numberWithInt:4],@"topictype",
                                [NSNumber numberWithInt:1],@"subject",
                                title,@"title",content,@"content",attach,@"attach",
                                students, @"award",[NSNumber numberWithBool:hasHomePage],@"toHomePage",
                                [NSNumber numberWithBool:hasTopGroup],@"toUpGroup",nil];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/createTopic",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:params];
    }
    return self;
}

-(UserProfileOperation *) initUserLogin{
    if ([self initOperation]) {
        self.type = kUserLogin;
        
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSMutableDictionary *loginInfoDict = [NSMutableDictionary dictionary];
        if ([loginInfoDict count] == 0) {
            return nil;
        }
        [loginInfoDict setObject:account.loginName forKey:@"username"];
        [loginInfoDict setObject:account.pwdMD5 forKey:@"password"];
        [loginInfoDict setObject:@"IOS" forKey:@"device_type"];
        [loginInfoDict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"device_version"];
        [loginInfoDict setObject:@"ios_v2_teacher" forKey:@"app_platform"];
         //[loginInfoDict setObject:@"ios_v2" forKey:@"app_platform"];
        [loginInfoDict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"app_version"];
        [loginInfoDict setObject:[NSNumber numberWithInt:0] forKey:@"first_login"];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/mapi/login",K_HOST_NAME_OF_PALM_SERVER];
        [self setHttpRequestPostWithUrl:urlStr params:loginInfoDict];
    }
    return self;
    
}

-(void) userLogin{
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    __weak PalmFormDataRequest *weakRequest = self.dataRequest;
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            NSArray *cookies = weakRequest.responseCookies;
            for (NSHTTPCookie *cookie in cookies){
                if([cookie.name isEqualToString:@"PHPSESSID"]){
                    [PalmUIManagement sharedInstance].php =cookie;
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    
                }else if([cookie.name isEqualToString:@"SUID"]){
                    [PalmUIManagement sharedInstance].suid = cookie;
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                }
            }
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}


-(void) getUserProfile{
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].userProfile = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) getUserProfileWithUID{
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].otherUserProfile = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) getUserContacts{
#ifdef TEST
    [self.request addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].userContacts = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) updateUserHeader{
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setFile:self.fileName withFileName:[self.fileName lastPathComponent] andContentType:@"image/jpeg" forKey:@"file"];
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid,[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].updateUserHeader = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) updateUserHeaderResult{
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid,[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].updateUserHeaderResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) updateUserImageFile{
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    [self.dataRequest setFile:self.fileName withFileName:[self.fileName lastPathComponent] andContentType:@"image/jpeg" forKey:@"file"];
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid,[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].updateImageResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) postTopic{
#ifdef TEST
    [self.dataRequest addRequestHeader:@"Host" value:@"www.shouxiner.com"];
#endif
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].topicResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) postUserInfo{
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].postUserInfoResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) main{
    switch (self.type) {
        case kGetUserProfile:
            [self getUserProfile];
            break;
        case kGetUserContacts:
            [self getUserContacts];
            break;
        case kUpdateUserHeaderImage:
            [self updateUserHeader];
            break;
        case kUpdateUserHeader:
            [self updateUserHeaderResult];
            break;
        case kUpdateUserImage:
            [self updateUserImageFile];
            break;
        case kPostPBX:
        case kPostTopic:
            [self postTopic];
            break;
        case kUserLogin:
            [self userLogin];
            break;
        case kGetUserProfileWithUID:
            [self getUserProfileWithUID];
            break;
        case kPostUserInfo:
            [self postUserInfo];
            break;
        default:
            break;
    }
}
@end
