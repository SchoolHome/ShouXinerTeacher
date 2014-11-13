//
//  UserProfileOperation.h
//  teacher
//
//  Created by singlew on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

typedef enum{
    kGetUserProfile,
    kGetUserContacts,
    kUpdateUserHeaderImage,
    kUpdateUserHeader,
    kUpdateUserImage,
    kPostTopic,
    kUserLogin,
    kPostPBX,
    kGetUserProfileWithUID,
    kPostUserInfo,
}UserProfile;

#import "PalmOperation.h"

@interface UserProfileOperation : PalmOperation
-(UserProfileOperation *) initUserLogin;

-(UserProfileOperation *) initGetUser;

-(UserProfileOperation *) initGetUserInfoWithUID : (NSString *) UID;

-(UserProfileOperation *) initGetContacts;

-(UserProfileOperation *) initUpdateUserHeaderImage : (NSData*)imageData;

-(UserProfileOperation *) initUpdateUserHeader:(NSString *)imageUrlPath;

-(UserProfileOperation *) initSetUserInfo : (NSString *) avatar withMobile : (NSString *) mobile withVerifyCode : (NSString *) verifyCode
                          withPasswordOld : (NSString *) passwordOld withPasswordNew : (NSString *) passwordNew withSex : (int) sex withSign : (NSString *) sign;

-(UserProfileOperation *) initUpdateUserImageFile : (NSData *) imageData withGroupID : (int) groupID;

-(UserProfileOperation *) initPostTopic : (int) groupid withTopicType : (int) topicType withSubject : (int) subject withTitle : (NSString *) title
                            withContent : (NSString *) content withAttach : (NSString *) attach;

// 拍表现
-(UserProfileOperation *) initPostPBX : (int) groupid withTitle : (NSString *) title withContent : (NSString *) content
                            withAttach : (NSString *) attach withAward : (NSString *) students withToHomePage : (BOOL) hasHomePage
                          withToUpGroup : (BOOL) hasTopGroup;
@end
