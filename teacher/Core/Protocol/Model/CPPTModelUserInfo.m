#import "CPPTModelUserInfo.h"


#define K_USERINFO_KEY_USER_NAME        @"name"
#define K_USERINFO_KEY_UNAME            @"JID"
#define K_USERINFO_KEY_NICKNAME         @"nickname"
#define K_USERINFO_KEY_ICON             @"icon"
#define K_USERINFO_KEY_GENDER           @"gender"
#define K_USERINFO_KEY_LIFESTATUS       @"lifestatus"
#define K_USERINFO_KEY_REGION_NUMBER    @"pharea"
#define K_USERINFO_KEY_MOBILE_NUMBER    @"phnum"
#define K_USERINFO_KEY_RELATION_INFO    @"relationInfo"
#define K_USERINFO_KEY_COUPLE           @"coupleName"
#define K_USERINFO_KEY_RELATION         @"relation"

#define K_USERINFO_VALUE_NULL           @""

/**
 * 用户信息表
 */

@implementation CPPTModelUserInfo

#if 0
@synthesize userInfoID = userInfoID_;
@synthesize serverID = serverID_;
@synthesize updateTime = updateTime_;
@synthesize type = type_;
@synthesize name = name_;
@synthesize nickName = nickName_;
@synthesize mobileNumber = mobileNumber_;
@synthesize mobileIsBind = mobileIsBind_;
@synthesize emailAddr = emailAddr_;
@synthesize emailIsBind = emailIsBind_;
@synthesize sex = sex_;
@synthesize birthday = birthday_;
@synthesize height = height_;
@synthesize weight = weight_;
@synthesize threeSizes = threeSizes_;
@synthesize citys = citys_;
@synthesize anniversaryMeet = anniversaryMeet_;
@synthesize anniversaryMarry = anniversaryMarry_;
@synthesize anniversaryDating = anniversaryDating_;
@synthesize babyName = babyName_;

@synthesize dataList = dataList_;
#endif

@synthesize uName = uName_;
@synthesize nickName = nickName_;
@synthesize icon = icon_;
@synthesize gender = gender_;
@synthesize lifeStatus = lifeStatus_;
@synthesize regionNumber = regionNumber_;
@synthesize mobileNumber = mobileNumber_;
@synthesize coupleAccount = coupleAccount_;
@synthesize relationType = relationType_;
+ (CPPTModelUserInfo *)fromJsonDict:(NSDictionary *)jsonDict
{
    CPPTModelUserInfo *userInfo = nil;
    
    if(jsonDict)
    {
        userInfo = [[CPPTModelUserInfo alloc] init];
        if(userInfo)
        {
            userInfo.uName = [jsonDict objectForKey:@"jid"];
            userInfo.nickName = [jsonDict objectForKey:@"username"];
            userInfo.icon = [jsonDict objectForKey:@"avatar"];
            userInfo.gender = [jsonDict objectForKey:@"activated"];
            userInfo.lifeStatus = [jsonDict objectForKey:@"uid"];
            userInfo.regionNumber = [[jsonDict objectForKey:@"groups"] JSONString];
            userInfo.mobileNumber = [jsonDict objectForKey:@"mobile"];
            userInfo.relationType = [NSNumber numberWithInt:1];
            
            BOOL isTeacher = [[jsonDict objectForKey:@"isTeacher"] boolValue];
            BOOL isParent = [[jsonDict objectForKey:@"isParent"] boolValue];
            NSString *result = @"";
            if (isTeacher && isParent) {
                result = @"TeacherAndParent";
            }else if (isTeacher && !isParent){
                result = @"Teacher";
            }else{
                result = @"Parent";
            }
            
            userInfo.coupleAccount = result;
        }
    }
    
    return userInfo;
}

- (NSMutableDictionary *)toJsonDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.uName forKey:K_USERINFO_KEY_UNAME];
    [dict setObject:self.nickName forKey:K_USERINFO_KEY_NICKNAME];
    [dict setObject:self.icon forKey:K_USERINFO_KEY_ICON];
    [dict setObject:self.gender forKey:K_USERINFO_KEY_GENDER];
    [dict setObject:self.lifeStatus forKey:K_USERINFO_KEY_LIFESTATUS];
    
    return dict;
}

@end

