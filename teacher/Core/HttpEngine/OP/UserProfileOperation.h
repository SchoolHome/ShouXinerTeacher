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
}UserProfile;

#import "PalmOperation.h"

@interface UserProfileOperation : PalmOperation
-(UserProfileOperation *) initUserLogin;

-(UserProfileOperation *) initGetUser;

-(UserProfileOperation *) initGetContacts;

-(UserProfileOperation *) initUpdateUserHeaderImage : (NSData*)imageData;

-(UserProfileOperation *) initUpdateUserHeader:(NSString *)imageUrlPath;

-(UserProfileOperation *) initUpdateUserImageFile : (NSData *) imageData withGroupID : (int) groupID;

-(UserProfileOperation *) initPostTopic : (int) groupid withTopicType : (int) topicType withSubject : (int) subject withTitle : (NSString *) title
                            withContent : (NSString *) content withAttach : (NSString *) attach;
@end
