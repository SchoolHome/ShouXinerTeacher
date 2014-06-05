//
//  PalmUIManagement.m
//  teacher
//
//  Created by singlew on 14-3-7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmUIManagement.h"
#import "UserProfileOperation.h"
#import "MyOperation.h"
#import "GroupOperation.h"
#import "ClassOperation.h"

@implementation PalmUIManagement
static PalmUIManagement *sharedInstance = nil;

+(PalmUIManagement *) sharedInstance{
    @synchronized(sharedInstance){
        if (nil == sharedInstance){
            sharedInstance = [[PalmUIManagement alloc] init];
        }
    }
    return sharedInstance;
}

-(void) getUserProfile{
    UserProfileOperation *operation = [[UserProfileOperation alloc] initGetUser];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) getuserContacts{
    UserProfileOperation *operation = [[UserProfileOperation alloc] initGetContacts];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) getUserCredits{
    MyOperation *operation = [[MyOperation alloc] initGetCredits];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) getUserGroupList{
    GroupOperation *operation = [[GroupOperation alloc] initGetGroupList];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 更新用户头像
-(void) updateUserHeader : (NSData *) imageData{
    UserProfileOperation *operation = [[UserProfileOperation alloc] initUpdateUserHeaderImage:imageData];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) updateuserHeaderResult : (NSString *) urlPath{
    UserProfileOperation *operation = [[UserProfileOperation alloc] initUpdateUserHeader:urlPath];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 获取有指示
-(void) getNotiData : (int) timeStamp{
    ClassOperation *operation = [[ClassOperation alloc] initNotiList:timeStamp];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) getGroupList{
    ClassOperation *operation = [[ClassOperation alloc] initGroupList];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) getGroupTopic:(int)groupID withTimeStamp:(int)timeStamp withOffset:(int)offset withLimit:(int)limit{
    ClassOperation *operation = [[ClassOperation alloc] initGroupTopic:groupID withTimeStamp:timeStamp withOffset:offset withLimit:limit];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 点赞
-(void) postPraise : (long long) topicID{
    ClassOperation *operation = [[ClassOperation alloc] initPraise:topicID];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 发表评论
-(void) postComment : (NSString *) commentContent withReplyToUid : (int) uid withTopicID : (long long) topicID{
    ClassOperation *operation = [[ClassOperation alloc] initComment:commentContent withReplyToUid:uid withTopicID:topicID];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 获取新消息数量
-(void) getNotiCount{
    ClassOperation *operation = [[ClassOperation alloc] initGetNotiCount];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 获取新消息列
-(void) getNotiList : (int) offset withLimit : (int) limit{
    ClassOperation *operation = [[ClassOperation alloc] initGetNotiList:offset withLimit:limit];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 上传图片
-(void) updateUserImageFile : (NSData *) imageData withGroupID : (int) groupID{
    UserProfileOperation *operation =[[UserProfileOperation alloc] initUpdateUserImageFile:imageData withGroupID:groupID];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 发表Topic
-(void) postTopic : (int) groupid withTopicType : (int) topicType withSubject : (int) subject withTitle : (NSString *) title
      withContent : (NSString *) content withAttach : (NSString *) attach{
    UserProfileOperation *operation =[[UserProfileOperation alloc] initPostTopic:groupid withTopicType:topicType withSubject:subject withTitle:title withContent:content withAttach:attach];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) postCheckVersion{
    MyOperation *operation = [[MyOperation alloc] initCheckVersion];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 有指示未读
-(void) getUnReadNotiCount : (long long) timeStamp{
    ClassOperation *operation = [[ClassOperation alloc] initUnReadNotiCount:timeStamp];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 获取有指示列表
-(void) getNotiListWithSender : (int) sender withOffset : (int) offset withLimit : (int) limit{
    ClassOperation *operation = [[ClassOperation alloc] initNotiListWithSender:sender withOffset:offset withLimit:limit];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 转发有指示
-(void) postForwardNoti : (int) oaid withGroupID : (int) groupID withMessage : (NSString *) message{
    ClassOperation *operation = [[ClassOperation alloc] initForwardNoti:oaid withGroupID:groupID withMessage:message];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 激活
-(void) activate : (NSString *) userName withTelPhone : (NSString *) telPhone withEmail : (NSString *) email withPassWord : (NSString *) password{
    MyOperation *operation = [[MyOperation alloc] initActivate:userName withTelPhone:telPhone withEmail:email withPassWord:password];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 获取学生列表
-(void) getGroupStudents : (NSString *) groupids{
    GroupOperation *operation = [[GroupOperation alloc] initGetGroupStudent:groupids];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

// 推荐话题
-(void) postRecommend : (long long) topicID withToHomePage : (BOOL) hasHomePage withToUpGroup : (BOOL) hasUpGroup{
    ClassOperation *operation = [[ClassOperation alloc] initPostRecommend:topicID withToHomePage:hasHomePage withToUpGroup:hasUpGroup];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

-(void) userLoginToken{
    UserProfileOperation *operation = [[UserProfileOperation alloc] initUserLogin];
    [[PalmNetWorkService sharedInstance] networkEngine:operation];
}

@end
