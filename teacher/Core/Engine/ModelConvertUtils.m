#import "ModelConvertUtils.h"

#import "CoreUtils.h"
#import "CPSystemEngine.h"
#import "CPResManager.h"
#import "CPDBManagement.h"
@implementation ModelConvertUtils

+(NSString *)getAccountNameWithName:(NSString *)name
{
    if (name)
    {
        NSRange rangeName= [name rangeOfString:@"@"];
        if (rangeName.length>0)
        {
            return [name substringToIndex:rangeName.location];
        }
    }
    return name;
}
+(NSString *)getDomainWithName:(NSString *)name
{
    if (name)
    {
        NSRange rangeName= [name rangeOfString:@"@"];
        if (rangeName.length>0)
        {
            return [name substringFromIndex:rangeName.location];
        }
    }
    return name;
}
//PT-->DB
+(CPDBModelContact *)ptContactToDb:(CPPTModelContact *)ptContact
{
    CPDBModelContact *dbContact = [[CPDBModelContact alloc] init];
#if 0
    [dbContact setAbPersonID:ptContact.abPersonID];
    [dbContact setUpdateTime:ptContact.updateTime];
    [dbContact setFirstName:ptContact.firstName];
    [dbContact setLastName:ptContact.lastName];
    [dbContact setFullName:ptContact.fullName];
    [dbContact setSyncTime:ptContact.syncTime];
    [dbContact setSyncMark:ptContact.syncMark];
//    [dbContact setHeaderPhotoPath:ptContact.headerPhotoRe];
#endif
    return dbContact;
}
+(CPDBModelContactWay *)ptContactWayToDb:(CPPTModelContactWay *)ptContactWay
{
    CPDBModelContactWay *dbContactWay = [[CPDBModelContactWay alloc] init];
#if 0
    [dbContactWay setContactID:ptContactWay.contactID];
    [dbContactWay setRegType:ptContactWay.regType];
    [dbContactWay setType:ptContactWay.type];
    [dbContactWay setName:ptContactWay.name];
    [dbContactWay setValue:ptContactWay.value];
#endif
    return dbContactWay;
}
+(CPDBModelUserInfo *)ptUserInfoToDb:(CPPTModelUserInfo *)ptUserInfo
{
    CPDBModelUserInfo *dbUserInfo = [[CPDBModelUserInfo alloc] init];
    [dbUserInfo setName:[self getAccountNameWithName:ptUserInfo.uName]];
    [dbUserInfo setDomain:[self getDomainWithName:ptUserInfo.uName]];
    [dbUserInfo setSex:ptUserInfo.gender];
    [dbUserInfo setLifeStatus:ptUserInfo.lifeStatus];
    [dbUserInfo setNickName:ptUserInfo.nickName];
    [dbUserInfo setType:ptUserInfo.relationType];
    [dbUserInfo setCoupleAccount:ptUserInfo.coupleAccount];
    [dbUserInfo setMobileNumber:ptUserInfo.mobileNumber];
    [dbUserInfo setBirthday:ptUserInfo.regionNumber];
    
#if 0
    [dbUserInfo setServerID:ptUserInfo.serverID];
    [dbUserInfo setUpdateTime:ptUserInfo.updateTime];
    [dbUserInfo setType:ptUserInfo.type];
    [dbUserInfo setName:ptUserInfo.name];
    [dbUserInfo setNickName:ptUserInfo.nickName];
    [dbUserInfo setMobileNumber:ptUserInfo.mobileNumber];
    [dbUserInfo setMobileIsBind:ptUserInfo.mobileIsBind];
    [dbUserInfo setEmailAddr:ptUserInfo.emailAddr];
    [dbUserInfo setEmailIsBind:ptUserInfo.emailIsBind];
    [dbUserInfo setSex:ptUserInfo.sex];
    [dbUserInfo setBirthday:ptUserInfo.birthday];
    [dbUserInfo setHeight:ptUserInfo.height];
    [dbUserInfo setWeight:ptUserInfo.weight];
    [dbUserInfo setThreeSizes:ptUserInfo.threeSizes];
    [dbUserInfo setCitys:ptUserInfo.citys];
    [dbUserInfo setAnniversaryMeet:ptUserInfo.anniversaryMeet];
    [dbUserInfo setAnniversaryMarry:ptUserInfo.anniversaryMarry];
    [dbUserInfo setAnniversaryDating:ptUserInfo.anniversaryDating];
    [dbUserInfo setBabyName:ptUserInfo.babyName];
#endif
    return dbUserInfo;
}
+(CPDBModelUserInfoData *)ptUserInfoDataToDb:(CPPTModelUserInfoData *)ptUserInfoData
{
    CPDBModelUserInfoData *dbUserInfoData = [[CPDBModelUserInfoData alloc] init];
    [dbUserInfoData setUserInfoID:ptUserInfoData.userInfoID];
    [dbUserInfoData setDataClassify:ptUserInfoData.dataClassify];
    [dbUserInfoData setDataType:ptUserInfoData.dataType];
    [dbUserInfoData setDataContent:ptUserInfoData.dataContent];
    [dbUserInfoData setResourceID:ptUserInfoData.resourceID];
    return dbUserInfoData;
}
+(CPDBModelUserInfoDataAddition *)ptUserInfoDataAdditionToDb:(CPPTModelUserInfoDataAddition *)ptUserInfoDataAddition
{
    CPDBModelUserInfoDataAddition *dbUserInfoDataAddition = [[CPDBModelUserInfoDataAddition alloc] init];
    [dbUserInfoDataAddition setUserInfoDataID:ptUserInfoDataAddition.userInfoDataID];
    [dbUserInfoDataAddition setUserInfoID:ptUserInfoDataAddition.userInfoID];
    [dbUserInfoDataAddition setDataClassify:ptUserInfoDataAddition.dataClassify];
    [dbUserInfoDataAddition setDataType:ptUserInfoDataAddition.dataType];
    [dbUserInfoDataAddition setDataContent:ptUserInfoDataAddition.dataContent];
    [dbUserInfoDataAddition setResourceID:ptUserInfoDataAddition.resourceID];
    return dbUserInfoDataAddition;
}
+(CPDBModelMessageGroup *)ptMessageGroupToDb:(CPPTModelMessageGroup *)ptMessageGroup
{
    CPDBModelMessageGroup *dbMessageGroup = [[CPDBModelMessageGroup alloc] init];
    [dbMessageGroup setType:ptMessageGroup.type];
    [dbMessageGroup setGroupServerID:ptMessageGroup.groupServerID];
    [dbMessageGroup setGroupName:ptMessageGroup.groupName];
    [dbMessageGroup setGroupHeaderResID:ptMessageGroup.groupHeaderResID];
    [dbMessageGroup setMemoID:ptMessageGroup.memoID];
    return dbMessageGroup;
}
+(CPDBModelMessageGroupMember *)ptMessageGroupMemberToDb:(CPPTModelMessageGroupMember *)ptMessageGroupMember
{
    CPDBModelMessageGroupMember *dbMessageGroupMember = [[CPDBModelMessageGroupMember alloc] init];
    [dbMessageGroupMember setMsgGroupID:ptMessageGroupMember.msgGroupID];
    [dbMessageGroupMember setMobileNumber:ptMessageGroupMember.mobileNumber];
//    [dbMessageGroupMember setUserName:ptMessageGroupMember.userID];
    [dbMessageGroupMember setNickName:ptMessageGroupMember.nickName];
    [dbMessageGroupMember setSign:ptMessageGroupMember.sign];
    [dbMessageGroupMember setHeaderResourceID:ptMessageGroupMember.headerResourceID];
    return dbMessageGroupMember;
}
+(CPDBModelMessage *)ptMessageToDb:(CPPTModelMessage *)ptMessage
{
    CPDBModelMessage *dbMessage = [[CPDBModelMessage alloc] init];
    [dbMessage setMsgGroupID:ptMessage.msgGroupID];
//    [dbMessage setMsgServerID:ptMessage.msgServerID];
    [dbMessage setMobile:ptMessage.mobile];
//    [dbMessage setUserID:ptMessage.userID];
    [dbMessage setFlag:ptMessage.flag];
    [dbMessage setSendState:ptMessage.sendState];
    [dbMessage setDate:ptMessage.date];
    [dbMessage setIsReaded:ptMessage.isReaded];
    [dbMessage setMsgText:ptMessage.msgText];
    [dbMessage setContentType:ptMessage.contentType];
    [dbMessage setLocationInfo:ptMessage.locationInfo];
    [dbMessage setAttachResID:ptMessage.attachResID];
    return dbMessage;
}
+(CPDBModelPersonalInfo *)ptPersonalInfoToDb:(CPPTModelPersonalInfo *)ptPersonalInfo
{
    CPDBModelPersonalInfo *dbPersonalInfo = [[CPDBModelPersonalInfo alloc] init];
    [dbPersonalInfo setServerID:ptPersonalInfo.serverID];
    [dbPersonalInfo setUpdateTime:ptPersonalInfo.updateTime];
    [dbPersonalInfo setName:ptPersonalInfo.name];
    [dbPersonalInfo setNickName:ptPersonalInfo.nickName];
    [dbPersonalInfo setMobileNumber:ptPersonalInfo.mobileNumber];
    [dbPersonalInfo setMobileIsBind:ptPersonalInfo.mobileIsBind];
    [dbPersonalInfo setEmailAddr:ptPersonalInfo.emailAddr];
    [dbPersonalInfo setEmailIsBind:ptPersonalInfo.emailIsBind];
    [dbPersonalInfo setSex:ptPersonalInfo.sex];
    [dbPersonalInfo setBirthday:ptPersonalInfo.birthday];
    [dbPersonalInfo setHeight:ptPersonalInfo.height];
    [dbPersonalInfo setWeight:ptPersonalInfo.weight];
    [dbPersonalInfo setThreeSizes:ptPersonalInfo.threeSizes];
    [dbPersonalInfo setCitys:ptPersonalInfo.citys];
    [dbPersonalInfo setAnniversaryMeet:ptPersonalInfo.anniversaryMeet];
    [dbPersonalInfo setAnniversaryMarry:ptPersonalInfo.anniversaryMarry];
    [dbPersonalInfo setAnniversaryDating:ptPersonalInfo.anniversaryDating];
    return dbPersonalInfo;
}
+(CPDBModelPersonalInfo *)ptUserProfileToDbPersonalInfo:(CPPTModelUserProfile *)ptUserProfile
{
    CPDBModelPersonalInfo *dbPersonalInfo = [[CPDBModelPersonalInfo alloc] init];
    [dbPersonalInfo setName:ptUserProfile.uName];
    [dbPersonalInfo setNickName:ptUserProfile.nickName];
    [dbPersonalInfo setLifeStatus:ptUserProfile.lifeStatus];
    [dbPersonalInfo setSex:ptUserProfile.gender];
    [dbPersonalInfo setHasBaby:ptUserProfile.hideBaby];
    [dbPersonalInfo setSingleTime:[CoreUtils getLongFormatWithDateString:ptUserProfile.relationDate]];
//    NSLog(@"%@",[ptUserProfile.relationDate class]);
//    [dbPersonalInfo setSingleTime:[CoreUtils getLongFormatWithDate:ptUserProfile.relationDate]];
    return dbPersonalInfo;
}

+(CPDBModelUserInfo *)ptUserProfileToDbUserInfo:(CPPTModelUserProfile *)ptUserProfile
{
    CPDBModelUserInfo *dbUserInfo = [[CPDBModelUserInfo alloc] init];
    [dbUserInfo setName:ptUserProfile.uName];
    [dbUserInfo setNickName:ptUserProfile.nickName];
    [dbUserInfo setLifeStatus:ptUserProfile.lifeStatus];
    [dbUserInfo setSex:ptUserProfile.gender];
    [dbUserInfo setCoupleAccount:ptUserProfile.couple_uName];
    [dbUserInfo setCoupleNickName:ptUserProfile.couple_nickName];
    [dbUserInfo setSingleTime:[CoreUtils getLongFormatWithDateString:ptUserProfile.relationDate]];
    [dbUserInfo setHasBaby:ptUserProfile.hideBaby];

    return dbUserInfo;
}
+(CPUIModelUserInfo *)ptUserProfileToUiUserInfo:(CPPTModelUserProfile *)ptUserProfile
{
    CPUIModelUserInfo *dbUserInfo = [[CPUIModelUserInfo alloc] init];
    [dbUserInfo setName:ptUserProfile.uName];
    [dbUserInfo setNickName:ptUserProfile.nickName];
    [dbUserInfo setLifeStatus:ptUserProfile.lifeStatus];
    [dbUserInfo setSex:ptUserProfile.gender];
    [dbUserInfo setCoupleAccount:ptUserProfile.couple_uName];
    [dbUserInfo setCoupleNickName:ptUserProfile.couple_nickName];
    [dbUserInfo setSingleTime:[CoreUtils getLongFormatWithDateString:ptUserProfile.relationDate]];
    [dbUserInfo setHasBaby:ptUserProfile.hideBaby];
    [dbUserInfo setHeaderPath:ptUserProfile.icon];
    [dbUserInfo setSelfBgImgPath:ptUserProfile.backgroundIcon];
    [dbUserInfo setSelfBabyHeaderImgPath:ptUserProfile.babyIcon];
    [dbUserInfo setSelfCoupleHeaderImgPath:ptUserProfile.couple_icon];
    return dbUserInfo;
}

+(CPDBModelBabyInfoData *)ptBabyInfoDataToDb:(CPPTModelBabyInfoData *)ptBabyInfoData
{
    CPDBModelBabyInfoData *dbBabyInfoData = [[CPDBModelBabyInfoData alloc] init];
    [dbBabyInfoData setUserInfoID:ptBabyInfoData.userInfoID];
    [dbBabyInfoData setName:ptBabyInfoData.name];
    [dbBabyInfoData setSex:ptBabyInfoData.sex];
    [dbBabyInfoData setHeaderResID:ptBabyInfoData.headerResID];
    [dbBabyInfoData setBirthday:ptBabyInfoData.birthday];
    return dbBabyInfoData;
}
+(CPDBModelPersonalInfoData *)ptPersonalInfoDataToDb:(CPPTModelPersonalInfoData *)ptPersonalInfoData
{
    CPDBModelPersonalInfoData *dbPersonalInfoData = [[CPDBModelPersonalInfoData alloc] init];
    [dbPersonalInfoData setPersonalInfoID:ptPersonalInfoData.personalInfoID];
    [dbPersonalInfoData setDataClassify:ptPersonalInfoData.dataClassify];
    [dbPersonalInfoData setDataType:ptPersonalInfoData.dataType];
    [dbPersonalInfoData setDataContent:ptPersonalInfoData.dataContent];
    [dbPersonalInfoData setResourceID:ptPersonalInfoData.resourceID];
    return dbPersonalInfoData;
}
+(CPDBModelPersonalInfoDataAddition *)ptPersonalInfoDataAdditionToDb:(CPPTModelPersonalInfoDataAddition *)ptPersonalInfoDataAddition
{
    CPDBModelPersonalInfoDataAddition *dbPersonalInfoDataAddition = [[CPDBModelPersonalInfoDataAddition alloc] init];
    [dbPersonalInfoDataAddition setPersonalInfoDataID:ptPersonalInfoDataAddition.personalInfoDataID];
    [dbPersonalInfoDataAddition setPersonalInfoID:ptPersonalInfoDataAddition.personalInfoID];
    [dbPersonalInfoDataAddition setDataClassify:ptPersonalInfoDataAddition.dataClassify];
    [dbPersonalInfoDataAddition setDataType:ptPersonalInfoDataAddition.dataType];
    [dbPersonalInfoDataAddition setDataContent:ptPersonalInfoDataAddition.dataContent];
    [dbPersonalInfoDataAddition setResourceID:ptPersonalInfoDataAddition.resourceID];
    return dbPersonalInfoDataAddition;
}
+(CPDBModelResource *)ptResourceToDb:(CPPTModelResource *)ptResource
{
    CPDBModelResource *dbResource = [[CPDBModelResource alloc] init];
    [dbResource setServerUrl:ptResource.serverUrl];
    [dbResource setCreateTime:ptResource.createTime];
    [dbResource setFileName:ptResource.fileName];
    [dbResource setFilePrefix:ptResource.filePrefix];
    [dbResource setType:ptResource.type];
    [dbResource setMimeType:ptResource.mimeType];
    [dbResource setMark:ptResource.mark];
    [dbResource setObjID:ptResource.objID];
    [dbResource setObjType:ptResource.objType];
    return dbResource;
}

//DB-->PT
+(CPPTModelContact *)dbContactToPt:(CPDBModelContact *)dbContact
{
    CPPTModelContact *ptContact = [[CPPTModelContact alloc] init];
    [ptContact setName:dbContact.fullName];
#if 0
    [ptContact setAbPersonID:dbContact.abPersonID];
    [ptContact setUpdateTime:dbContact.updateTime];
    [ptContact setFirstName:dbContact.firstName];
    [ptContact setLastName:dbContact.lastName];
    [ptContact setFullName:dbContact.fullName];
    [ptContact setSyncTime:dbContact.syncTime];
    [ptContact setSyncMark:dbContact.syncMark];
//    [ptContact setHeaderPhotoResID:dbContact.headerPhotoResID];
#endif
    return ptContact;
}
+(CPPTModelContactWay *)dbContactWayToPt:(CPDBModelContactWay *)dbContactWay
{
    CPPTModelContactWay *ptContactWay = [[CPPTModelContactWay alloc] init];
    [ptContactWay setPhoneNum:dbContactWay.value];
    [ptContactWay setPhoneArea:dbContactWay.regionNumber];
#if 0
    [ptContactWay setContactID:dbContactWay.contactID];
    [ptContactWay setRegType:dbContactWay.regType];
    [ptContactWay setType:dbContactWay.type];
    [ptContactWay setName:dbContactWay.name];
    [ptContactWay setValue:dbContactWay.value];
#endif
    return ptContactWay;
}
+(CPPTModelUserInfo *)dbUserInfoToPt:(CPDBModelUserInfo *)dbUserInfo
{
    CPPTModelUserInfo *ptUserInfo = [[CPPTModelUserInfo alloc] init];
#if 0
    [ptUserInfo setServerID:dbUserInfo.serverID];
    [ptUserInfo setUpdateTime:dbUserInfo.updateTime];
    [ptUserInfo setType:dbUserInfo.type];
    [ptUserInfo setName:dbUserInfo.name];
    [ptUserInfo setNickName:dbUserInfo.nickName];
    [ptUserInfo setMobileNumber:dbUserInfo.mobileNumber];
    [ptUserInfo setMobileIsBind:dbUserInfo.mobileIsBind];
    [ptUserInfo setEmailAddr:dbUserInfo.emailAddr];
    [ptUserInfo setEmailIsBind:dbUserInfo.emailIsBind];
    [ptUserInfo setSex:dbUserInfo.sex];
    [ptUserInfo setBirthday:dbUserInfo.birthday];
    [ptUserInfo setHeight:dbUserInfo.height];
    [ptUserInfo setWeight:dbUserInfo.weight];
    [ptUserInfo setThreeSizes:dbUserInfo.threeSizes];
    [ptUserInfo setCitys:dbUserInfo.citys];
    [ptUserInfo setAnniversaryMeet:dbUserInfo.anniversaryMeet];
    [ptUserInfo setAnniversaryMarry:dbUserInfo.anniversaryMarry];
    [ptUserInfo setAnniversaryDating:dbUserInfo.anniversaryDating];
    [ptUserInfo setBabyName:dbUserInfo.babyName];
#endif
    return ptUserInfo;
}
+(CPPTModelUserInfoData *)dbUserInfoDataToPt:(CPDBModelUserInfoData *)dbUserInfoData
{
    CPPTModelUserInfoData *ptUserInfoData = [[CPPTModelUserInfoData alloc] init];
    [ptUserInfoData setUserInfoID:dbUserInfoData.userInfoID];
    [ptUserInfoData setDataClassify:dbUserInfoData.dataClassify];
    [ptUserInfoData setDataType:dbUserInfoData.dataType];
    [ptUserInfoData setDataContent:dbUserInfoData.dataContent];
    [ptUserInfoData setResourceID:dbUserInfoData.resourceID];
    return ptUserInfoData;
}
+(CPPTModelUserInfoDataAddition *)dbUserInfoDataAdditionToPt:(CPDBModelUserInfoDataAddition *)dbUserInfoDataAddition
{
    CPPTModelUserInfoDataAddition *ptUserInfoDataAddition = [[CPPTModelUserInfoDataAddition alloc] init];
    [ptUserInfoDataAddition setUserInfoDataID:dbUserInfoDataAddition.userInfoDataID];
    [ptUserInfoDataAddition setUserInfoID:dbUserInfoDataAddition.userInfoID];
    [ptUserInfoDataAddition setDataClassify:dbUserInfoDataAddition.dataClassify];
    [ptUserInfoDataAddition setDataType:dbUserInfoDataAddition.dataType];
    [ptUserInfoDataAddition setDataContent:dbUserInfoDataAddition.dataContent];
    [ptUserInfoDataAddition setResourceID:dbUserInfoDataAddition.resourceID];
    return ptUserInfoDataAddition;
}
+(CPPTModelMessageGroup *)dbMessageGroupToPt:(CPDBModelMessageGroup *)dbMessageGroup
{
    CPPTModelMessageGroup *ptMessageGroup = [[CPPTModelMessageGroup alloc] init];
    [ptMessageGroup setType:dbMessageGroup.type];
    [ptMessageGroup setGroupServerID:dbMessageGroup.groupServerID];
    [ptMessageGroup setGroupName:dbMessageGroup.groupName];
    [ptMessageGroup setGroupHeaderResID:dbMessageGroup.groupHeaderResID];
    [ptMessageGroup setMemoID:dbMessageGroup.memoID];
    return ptMessageGroup;
}
+(CPPTModelMessageGroupMember *)dbMessageGroupMemberToPt:(CPDBModelMessageGroupMember *)dbMessageGroupMember
{
    CPPTModelMessageGroupMember *ptMessageGroupMember = [[CPPTModelMessageGroupMember alloc] init];
    [ptMessageGroupMember setMsgGroupID:dbMessageGroupMember.msgGroupID];
    [ptMessageGroupMember setMobileNumber:dbMessageGroupMember.mobileNumber];
//    [ptMessageGroupMember setUserID:dbMessageGroupMember.userID];
    [ptMessageGroupMember setNickName:dbMessageGroupMember.nickName];
    [ptMessageGroupMember setSign:dbMessageGroupMember.sign];
    [ptMessageGroupMember setHeaderResourceID:dbMessageGroupMember.headerResourceID];
    return ptMessageGroupMember;
}
+(CPPTModelMessage *)dbMessageToPt:(CPDBModelMessage *)dbMessage
{
    CPPTModelMessage *ptMessage = [[CPPTModelMessage alloc] init];
    [ptMessage setMsgGroupID:dbMessage.msgGroupID];
//    [ptMessage setMsgServerID:dbMessage.msgServerID];
    [ptMessage setMobile:dbMessage.mobile];
//    [ptMessage setUserID:dbMessage.userID];
    [ptMessage setFlag:dbMessage.flag];
    [ptMessage setSendState:dbMessage.sendState];
    [ptMessage setDate:dbMessage.date];
    [ptMessage setIsReaded:dbMessage.isReaded];
    [ptMessage setMsgText:dbMessage.msgText];
    [ptMessage setContentType:dbMessage.contentType];
    [ptMessage setLocationInfo:dbMessage.locationInfo];
    [ptMessage setAttachResID:dbMessage.attachResID];
    return ptMessage;
}
+(CPPTModelPersonalInfo *)dbPersonalInfoToPt:(CPDBModelPersonalInfo *)dbPersonalInfo
{
    CPPTModelPersonalInfo *ptPersonalInfo = [[CPPTModelPersonalInfo alloc] init];
    [ptPersonalInfo setServerID:dbPersonalInfo.serverID];
    [ptPersonalInfo setUpdateTime:dbPersonalInfo.updateTime];
    [ptPersonalInfo setName:dbPersonalInfo.name];
    [ptPersonalInfo setNickName:dbPersonalInfo.nickName];
    [ptPersonalInfo setMobileNumber:dbPersonalInfo.mobileNumber];
    [ptPersonalInfo setMobileIsBind:dbPersonalInfo.mobileIsBind];
    [ptPersonalInfo setEmailAddr:dbPersonalInfo.emailAddr];
    [ptPersonalInfo setEmailIsBind:dbPersonalInfo.emailIsBind];
    [ptPersonalInfo setSex:dbPersonalInfo.sex];
    [ptPersonalInfo setBirthday:dbPersonalInfo.birthday];
    [ptPersonalInfo setHeight:dbPersonalInfo.height];
    [ptPersonalInfo setWeight:dbPersonalInfo.weight];
    [ptPersonalInfo setThreeSizes:dbPersonalInfo.threeSizes];
    [ptPersonalInfo setCitys:dbPersonalInfo.citys];
    [ptPersonalInfo setAnniversaryMeet:dbPersonalInfo.anniversaryMeet];
    [ptPersonalInfo setAnniversaryMarry:dbPersonalInfo.anniversaryMarry];
    [ptPersonalInfo setAnniversaryDating:dbPersonalInfo.anniversaryDating];
    return ptPersonalInfo;
}
+(CPPTModelBabyInfoData *)dbBabyInfoDataToPt:(CPDBModelBabyInfoData *)dbBabyInfoData
{
    CPPTModelBabyInfoData *ptBabyInfoData = [[CPPTModelBabyInfoData alloc] init];
    [ptBabyInfoData setUserInfoID:dbBabyInfoData.userInfoID];
    [ptBabyInfoData setName:dbBabyInfoData.name];
    [ptBabyInfoData setSex:dbBabyInfoData.sex];
    [ptBabyInfoData setHeaderResID:dbBabyInfoData.headerResID];
    [ptBabyInfoData setBirthday:dbBabyInfoData.birthday];
    return ptBabyInfoData;
}
+(CPPTModelPersonalInfoData *)dbPersonalInfoDataToPt:(CPDBModelPersonalInfoData *)dbPersonalInfoData
{
    CPPTModelPersonalInfoData *ptPersonalInfoData = [[CPPTModelPersonalInfoData alloc] init];
    [ptPersonalInfoData setPersonalInfoID:dbPersonalInfoData.personalInfoID];
    [ptPersonalInfoData setDataClassify:dbPersonalInfoData.dataClassify];
    [ptPersonalInfoData setDataType:dbPersonalInfoData.dataType];
    [ptPersonalInfoData setDataContent:dbPersonalInfoData.dataContent];
    [ptPersonalInfoData setResourceID:dbPersonalInfoData.resourceID];
    return ptPersonalInfoData;
}
+(CPPTModelPersonalInfoDataAddition *)dbPersonalInfoDataAdditionToPt:(CPDBModelPersonalInfoDataAddition *)dbPersonalInfoDataAddition
{
    CPPTModelPersonalInfoDataAddition *ptPersonalInfoDataAddition = [[CPPTModelPersonalInfoDataAddition alloc] init];
    [ptPersonalInfoDataAddition setPersonalInfoDataID:dbPersonalInfoDataAddition.personalInfoDataID];
    [ptPersonalInfoDataAddition setPersonalInfoID:dbPersonalInfoDataAddition.personalInfoID];
    [ptPersonalInfoDataAddition setDataClassify:dbPersonalInfoDataAddition.dataClassify];
    [ptPersonalInfoDataAddition setDataType:dbPersonalInfoDataAddition.dataType];
    [ptPersonalInfoDataAddition setDataContent:dbPersonalInfoDataAddition.dataContent];
    [ptPersonalInfoDataAddition setResourceID:dbPersonalInfoDataAddition.resourceID];
    return ptPersonalInfoDataAddition;
}
+(CPPTModelResource *)dbResourceToPt:(CPDBModelResource *)dbResource
{
    CPPTModelResource *ptResource = [[CPPTModelResource alloc] init];
    [ptResource setServerUrl:dbResource.serverUrl];
    [ptResource setCreateTime:dbResource.createTime];
    [ptResource setFileName:dbResource.fileName];
    [ptResource setFilePrefix:dbResource.filePrefix];
    [ptResource setType:dbResource.type];
    [ptResource setMimeType:dbResource.mimeType];
    [ptResource setMark:dbResource.mark];
    [ptResource setObjID:dbResource.objID];
    [ptResource setObjType:dbResource.objType];
    return ptResource;
}
+(CPPTModelContactInfos *)dbContactsToPt:(NSArray *)dbContactArray
{
    CPPTModelContactInfos *ptContactInfos = [[CPPTModelContactInfos alloc] init];
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    for (CPDBModelContact *dbContact in dbContactArray)
    {
        CPPTModelContact *ptContact = [ModelConvertUtils dbContactToPt:dbContact];
        NSMutableArray *contactWayArray = [[NSMutableArray alloc] init];
        for(CPDBModelContactWay *dbContactWay in dbContact.contactWayList)
        {
            if (dbContactWay.value&&![@"" isEqualToString:dbContactWay.value])
            {
                [contactWayArray addObject:[ModelConvertUtils dbContactWayToPt:dbContactWay]];
            }
        }
        [ptContact setContactWayList:contactWayArray];
        [contactArray addObject:ptContact];
    }
    [ptContactInfos setContactList:contactArray];
    return ptContactInfos;
}

//UI-->DB
+(CPDBModelContact *)uiContactToDb:(CPUIModelContact *)uiContact
{
    CPDBModelContact *dbContact = [[CPDBModelContact alloc] init];
    [dbContact setContactID:uiContact.contactID];
    [dbContact setAbPersonID:uiContact.abPersonID];
    [dbContact setUpdateTime:uiContact.updateTime];
    [dbContact setFirstName:uiContact.firstName];
    [dbContact setLastName:uiContact.lastName];
    [dbContact setFullName:uiContact.fullName];
    [dbContact setSyncTime:uiContact.syncTime];
    [dbContact setSyncMark:uiContact.syncMark];
    [dbContact setHeaderPhotoPath:uiContact.headerPhotoPath];
    return dbContact;
}
+(CPDBModelContactWay *)uiContactWayToDb:(CPUIModelContactWay *)uiContactWay
{
    CPDBModelContactWay *dbContactWay = [[CPDBModelContactWay alloc] init];
    [dbContactWay setContactWayID:uiContactWay.contactWayID];
    [dbContactWay setContactID:uiContactWay.contactID];
    [dbContactWay setRegType:uiContactWay.regType];
    [dbContactWay setType:uiContactWay.type];
    [dbContactWay setName:uiContactWay.name];
    [dbContactWay setValue:uiContactWay.value];
    return dbContactWay;
}
+(CPDBModelUserInfo *)uiUserInfoToDb:(CPUIModelUserInfo *)uiUserInfo
{
    CPDBModelUserInfo *dbUserInfo = [[CPDBModelUserInfo alloc] init];
    [dbUserInfo setUserInfoID:uiUserInfo.userInfoID];
    [dbUserInfo setServerID:uiUserInfo.serverID];
    [dbUserInfo setUpdateTime:uiUserInfo.updateTime];
    [dbUserInfo setType:uiUserInfo.type];
    [dbUserInfo setName:uiUserInfo.name];
    [dbUserInfo setNickName:uiUserInfo.nickName];
    [dbUserInfo setMobileNumber:uiUserInfo.mobileNumber];
    [dbUserInfo setMobileIsBind:uiUserInfo.mobileIsBind];
    [dbUserInfo setEmailAddr:uiUserInfo.emailAddr];
    [dbUserInfo setEmailIsBind:uiUserInfo.emailIsBind];
    [dbUserInfo setSex:uiUserInfo.sex];
    [dbUserInfo setBirthday:uiUserInfo.birthday];
    [dbUserInfo setHeight:uiUserInfo.height];
    [dbUserInfo setWeight:uiUserInfo.weight];
    [dbUserInfo setThreeSizes:uiUserInfo.threeSizes];
    [dbUserInfo setCitys:uiUserInfo.citys];
    [dbUserInfo setAnniversaryMeet:uiUserInfo.anniversaryMeet];
    [dbUserInfo setAnniversaryMarry:uiUserInfo.anniversaryMarry];
    [dbUserInfo setAnniversaryDating:uiUserInfo.anniversaryDating];
    [dbUserInfo setBabyName:uiUserInfo.babyName];
    return dbUserInfo;
}
+(CPDBModelUserInfoData *)uiUserInfoDataToDb:(CPUIModelUserInfoData *)uiUserInfoData
{
    CPDBModelUserInfoData *dbUserInfoData = [[CPDBModelUserInfoData alloc] init];
    [dbUserInfoData setUserInfoDataID:uiUserInfoData.userInfoDataID];
    [dbUserInfoData setUserInfoID:uiUserInfoData.userInfoID];
    [dbUserInfoData setDataClassify:uiUserInfoData.dataClassify];
    [dbUserInfoData setDataType:uiUserInfoData.dataType];
    [dbUserInfoData setDataContent:uiUserInfoData.dataContent];
    [dbUserInfoData setResourceID:uiUserInfoData.resourceID];
    return dbUserInfoData;
}
+(CPDBModelUserInfoDataAddition *)uiUserInfoDataAdditionToDb:(CPUIModelUserInfoDataAddition *)uiUserInfoDataAddition
{
    CPDBModelUserInfoDataAddition *dbUserInfoDataAddition = [[CPDBModelUserInfoDataAddition alloc] init];
    [dbUserInfoDataAddition setUserInfoDataID:uiUserInfoDataAddition.userInfoDataID];
    [dbUserInfoDataAddition setUserInfoID:uiUserInfoDataAddition.userInfoID];
    [dbUserInfoDataAddition setDataClassify:uiUserInfoDataAddition.dataClassify];
    [dbUserInfoDataAddition setDataType:uiUserInfoDataAddition.dataType];
    [dbUserInfoDataAddition setDataContent:uiUserInfoDataAddition.dataContent];
    [dbUserInfoDataAddition setResourceID:uiUserInfoDataAddition.resourceID];
    return dbUserInfoDataAddition;
}
+(CPDBModelMessageGroup *)uiMessageGroupToDb:(CPUIModelMessageGroup *)uiMessageGroup
{
    CPDBModelMessageGroup *dbMessageGroup = [[CPDBModelMessageGroup alloc] init];
    [dbMessageGroup setMsgGroupID:uiMessageGroup.msgGroupID];
    [dbMessageGroup setType:uiMessageGroup.type];
    [dbMessageGroup setRelationType:uiMessageGroup.relationType];
    [dbMessageGroup setGroupServerID:uiMessageGroup.groupServerID];
    [dbMessageGroup setGroupName:uiMessageGroup.groupName];
    [dbMessageGroup setGroupHeaderResID:uiMessageGroup.groupHeaderResID];
    [dbMessageGroup setMemoID:uiMessageGroup.memoID];
    [dbMessageGroup setUpdateDate:uiMessageGroup.updateDate];
    [dbMessageGroup setCreatorName:uiMessageGroup.creatorName];
    //userInfo list to member list
    NSMutableArray *memberList = [[NSMutableArray alloc] init];
    for(CPUIModelMessageGroupMember *uiGroupMem in uiMessageGroup.memberList)
    {
        CPDBModelMessageGroupMember *dbGroupMem = [self uiMessageGroupMemberToDb:uiGroupMem];
        [dbGroupMem setMsgGroupID:dbMessageGroup.msgGroupID];
        if (uiGroupMem.userInfo.name&&![@"" isEqual:uiGroupMem.userInfo.name])
        {
            [dbGroupMem setUserName:uiGroupMem.userInfo.name];
        }
        [memberList addObject:dbGroupMem];
    }
    [dbMessageGroup setMemberList:memberList];
    return dbMessageGroup;
}
+(CPDBModelMessageGroupMember *)uiMessageGroupMemberToDb:(CPUIModelMessageGroupMember *)uiMessageGroupMember
{
    CPDBModelMessageGroupMember *dbMessageGroupMember = [[CPDBModelMessageGroupMember alloc] init];
    [dbMessageGroupMember setMsgGroupMemID:uiMessageGroupMember.msgGroupMemID];
    [dbMessageGroupMember setMsgGroupID:uiMessageGroupMember.msgGroupID];
    [dbMessageGroupMember setMobileNumber:uiMessageGroupMember.mobileNumber];
    [dbMessageGroupMember setUserName:uiMessageGroupMember.userName];
    [dbMessageGroupMember setNickName:uiMessageGroupMember.nickName];
    [dbMessageGroupMember setSign:uiMessageGroupMember.sign];
    [dbMessageGroupMember setHeaderResourceID:uiMessageGroupMember.headerResourceID];
    [dbMessageGroupMember setDomain:uiMessageGroupMember.domain];
    return dbMessageGroupMember;
}
+(CPDBModelMessage *)uiMessageToDb:(CPUIModelMessage *)uiMessage
{
    CPDBModelMessage *dbMessage = [[CPDBModelMessage alloc] init];
    [dbMessage setMsgID:uiMessage.msgID];
    [dbMessage setMsgGroupID:uiMessage.msgGroupID];
    [dbMessage setMsgSenderID:uiMessage.msgSenderName];
    [dbMessage setMobile:uiMessage.mobile];
    [dbMessage setUserID:uiMessage.userID];
    [dbMessage setFlag:uiMessage.flag];
    [dbMessage setSendState:uiMessage.sendState];
    [dbMessage setDate:uiMessage.date];
    [dbMessage setIsReaded:uiMessage.isReaded];
    [dbMessage setMsgText:uiMessage.msgText];
    [dbMessage setContentType:uiMessage.contentType];
    [dbMessage setLocationInfo:uiMessage.locationInfo];
    [dbMessage setAttachResID:uiMessage.attachResID];
    [dbMessage setMagicMsgID:uiMessage.magicMsgID];
    [dbMessage setPetMsgID:uiMessage.petMsgID];
    [dbMessage setUuidAsk:uiMessage.uuidAsk];
    if ([uiMessage isAlarmMsg])
    {
        [dbMessage setMobile:[uiMessage.alarmTime stringValue]];
        [dbMessage setLocationInfo:[uiMessage.isAlarmHidden stringValue]];
    }
    return dbMessage;
}
+(CPDBModelPersonalInfo *)uiPersonalInfoToDb:(CPUIModelPersonalInfo *)uiPersonalInfo
{
    CPDBModelPersonalInfo *dbPersonalInfo = [[CPDBModelPersonalInfo alloc] init];
    [dbPersonalInfo setPersonalInfoID:uiPersonalInfo.personalInfoID];
    [dbPersonalInfo setServerID:uiPersonalInfo.serverID];
    [dbPersonalInfo setUpdateTime:uiPersonalInfo.updateTime];
    [dbPersonalInfo setName:uiPersonalInfo.name];
    [dbPersonalInfo setNickName:uiPersonalInfo.nickName];
    [dbPersonalInfo setMobileNumber:uiPersonalInfo.mobileNumber];
    [dbPersonalInfo setMobileIsBind:uiPersonalInfo.mobileIsBind];
    [dbPersonalInfo setEmailAddr:uiPersonalInfo.emailAddr];
    [dbPersonalInfo setEmailIsBind:uiPersonalInfo.emailIsBind];
    [dbPersonalInfo setSex:uiPersonalInfo.sex];
    [dbPersonalInfo setBirthday:uiPersonalInfo.birthday];
    [dbPersonalInfo setHeight:uiPersonalInfo.height];
    [dbPersonalInfo setWeight:uiPersonalInfo.weight];
    [dbPersonalInfo setThreeSizes:uiPersonalInfo.threeSizes];
    [dbPersonalInfo setCitys:uiPersonalInfo.citys];
    [dbPersonalInfo setAnniversaryMeet:uiPersonalInfo.anniversaryMeet];
    [dbPersonalInfo setAnniversaryMarry:uiPersonalInfo.anniversaryMarry];
    [dbPersonalInfo setAnniversaryDating:uiPersonalInfo.anniversaryDating];
    return dbPersonalInfo;
}
+(CPDBModelBabyInfoData *)uiBabyInfoDataToDb:(CPUIModelBabyInfoData *)uiBabyInfoData
{
    CPDBModelBabyInfoData *dbBabyInfoData = [[CPDBModelBabyInfoData alloc] init];
    [dbBabyInfoData setUserInfoID:uiBabyInfoData.userInfoID];
    [dbBabyInfoData setName:uiBabyInfoData.name];
    [dbBabyInfoData setSex:uiBabyInfoData.sex];
    [dbBabyInfoData setHeaderResID:uiBabyInfoData.headerResID];
    [dbBabyInfoData setBirthday:uiBabyInfoData.birthday];
    return dbBabyInfoData;
}
+(CPDBModelPersonalInfoData *)uiPersonalInfoDataToDb:(CPUIModelPersonalInfoData *)uiPersonalInfoData
{
    CPDBModelPersonalInfoData *dbPersonalInfoData = [[CPDBModelPersonalInfoData alloc] init];
    [dbPersonalInfoData setPersonalInfoDataID:uiPersonalInfoData.personalInfoDataID];
    [dbPersonalInfoData setPersonalInfoID:uiPersonalInfoData.personalInfoID];
    [dbPersonalInfoData setDataClassify:uiPersonalInfoData.dataClassify];
    [dbPersonalInfoData setDataType:uiPersonalInfoData.dataType];
    [dbPersonalInfoData setDataContent:uiPersonalInfoData.dataContent];
    [dbPersonalInfoData setResourceID:uiPersonalInfoData.resourceID];
    return dbPersonalInfoData;
}
+(CPDBModelPersonalInfoDataAddition *)uiPersonalInfoDataAdditionToDb:(CPUIModelPersonalInfoDataAddition *)uiPersonalInfoDataAddition
{
    CPDBModelPersonalInfoDataAddition *dbPersonalInfoDataAddition = [[CPDBModelPersonalInfoDataAddition alloc] init];
    [dbPersonalInfoDataAddition setPersonalInfoDataID:uiPersonalInfoDataAddition.personalInfoDataID];
    [dbPersonalInfoDataAddition setPersonalInfoID:uiPersonalInfoDataAddition.personalInfoID];
    [dbPersonalInfoDataAddition setDataClassify:uiPersonalInfoDataAddition.dataClassify];
    [dbPersonalInfoDataAddition setDataType:uiPersonalInfoDataAddition.dataType];
    [dbPersonalInfoDataAddition setDataContent:uiPersonalInfoDataAddition.dataContent];
    [dbPersonalInfoDataAddition setResourceID:uiPersonalInfoDataAddition.resourceID];
    return dbPersonalInfoDataAddition;
}
+(CPDBModelResource *)uiResourceToDb:(CPUIModelResource *)uiResource
{
    CPDBModelResource *dbResource = [[CPDBModelResource alloc] init];
    [dbResource setResID:uiResource.resID];
    [dbResource setServerUrl:uiResource.serverUrl];
    [dbResource setCreateTime:uiResource.createTime];
    [dbResource setFileName:uiResource.fileName];
    [dbResource setFilePrefix:uiResource.filePrefix];
    [dbResource setType:uiResource.type];
    [dbResource setMimeType:uiResource.mimeType];
    [dbResource setMark:uiResource.mark];
    [dbResource setObjID:uiResource.objID];
    [dbResource setObjType:uiResource.objType];
    return dbResource;
}

//DB-->UI
+(CPUIModelContact *)dbContactToUi:(CPDBModelContact *)dbContact
{
    CPUIModelContact *uiContact = [[CPUIModelContact alloc] init];
    [uiContact setContactID:dbContact.contactID];
    [uiContact setAbPersonID:dbContact.abPersonID];
    [uiContact setUpdateTime:dbContact.updateTime];
    [uiContact setFirstName:dbContact.firstName];
    [uiContact setLastName:dbContact.lastName];
    [uiContact setFullName:dbContact.fullName];
    [uiContact setSyncTime:dbContact.syncTime];
    [uiContact setSyncMark:dbContact.syncMark];
    if (dbContact.headerPhotoPath)
    {
        [uiContact setHeaderPhotoPath:[NSString stringWithFormat:@"%@%@",[CoreUtils getDocumentPath],dbContact.headerPhotoPath]];
    }
    NSMutableArray *uiContactWays = [[NSMutableArray alloc] init];
    for(CPDBModelContactWay *dbContactWay in dbContact.contactWayList)
    {
        [uiContactWays addObject:[ModelConvertUtils dbContactWayToUi:dbContactWay]];
    }
    [uiContact setContactWayList:uiContactWays];
    return uiContact;
}
+(CPUIModelContactWay *)dbContactWayToUi:(CPDBModelContactWay *)dbContactWay
{
    CPUIModelContactWay *uiContactWay = [[CPUIModelContactWay alloc] init];
    [uiContactWay setContactWayID:dbContactWay.contactWayID];
    [uiContactWay setContactID:dbContactWay.contactID];
    [uiContactWay setRegType:dbContactWay.regType];
    [uiContactWay setType:dbContactWay.type];
    [uiContactWay setName:dbContactWay.name];
    [uiContactWay setValue:dbContactWay.value];
    return uiContactWay;
}
+(CPUIModelUserInfo *)dbUserInfoToUi:(CPDBModelUserInfo *)dbUserInfo
{
    if (!dbUserInfo) 
    {
        return nil;
    }
    CPUIModelUserInfo *uiUserInfo = [[CPUIModelUserInfo alloc] init];
    [uiUserInfo setUserInfoID:dbUserInfo.userInfoID];
    [uiUserInfo setServerID:dbUserInfo.serverID];
    [uiUserInfo setUpdateTime:dbUserInfo.updateTime];
    [uiUserInfo setType:dbUserInfo.type];
    [uiUserInfo setName:dbUserInfo.name];
    [uiUserInfo setNickName:dbUserInfo.nickName];
    [uiUserInfo setMobileNumber:dbUserInfo.mobileNumber];
    [uiUserInfo setMobileIsBind:dbUserInfo.mobileIsBind];
    [uiUserInfo setEmailAddr:dbUserInfo.emailAddr];
    [uiUserInfo setEmailIsBind:dbUserInfo.emailIsBind];
    [uiUserInfo setSex:dbUserInfo.sex];
    [uiUserInfo setBirthday:dbUserInfo.birthday];
    [uiUserInfo setHeight:dbUserInfo.height];
    [uiUserInfo setWeight:dbUserInfo.weight];
    [uiUserInfo setThreeSizes:dbUserInfo.threeSizes];
    [uiUserInfo setCitys:dbUserInfo.citys];
    [uiUserInfo setAnniversaryMeet:dbUserInfo.anniversaryMeet];
    [uiUserInfo setAnniversaryMarry:dbUserInfo.anniversaryMarry];
    [uiUserInfo setAnniversaryDating:dbUserInfo.anniversaryDating];
    [uiUserInfo setBabyName:dbUserInfo.babyName];
    [uiUserInfo setCoupleAccount:dbUserInfo.coupleAccount];
    [uiUserInfo setDomain:dbUserInfo.domain];
    NSInteger dbLifeStatus = [dbUserInfo.lifeStatus integerValue];
    if (dbLifeStatus>128)
    {
        [uiUserInfo setLifeStatus:[NSNumber numberWithInt:(dbLifeStatus-128)]];
        [uiUserInfo setHasBaby:[NSNumber numberWithBool:NO]];
    }
    else 
    {
        [uiUserInfo setLifeStatus:[NSNumber numberWithInt:dbLifeStatus]];
        [uiUserInfo setHasBaby:[NSNumber numberWithBool:YES]];
    }

    for(CPDBModelUserInfoData *dbUserData in dbUserInfo.dataList)
    {
        NSString *resPath = [[[CPSystemEngine sharedInstance] resManager] getResourcePathWithResID:dbUserData.resourceID];
//        CPLogInfo(@"classify is %@,resPath is %@  ",dbUserData.dataClassify,resPath);
        switch ([dbUserData.dataClassify integerValue])
        {
            case DATA_CLASSIFY_SELF_HEADER:
            case DATA_CLASSIFY_HEADER:
                [uiUserInfo setHeaderPath:resPath];
                [uiUserInfo setSelfHeaderImgPath:resPath];
                break;
            case DATA_CLASSIFY_SELF_BG:
                [uiUserInfo setSelfBgImgPath:resPath];
                break;
            case DATA_CLASSIFY_SELF_COUPLE:
                [uiUserInfo setSelfCoupleHeaderImgPath:resPath];
                break;
            case DATA_CLASSIFY_SELF_BABY:
                [uiUserInfo setSelfBabyHeaderImgPath:resPath];
                break;
            case DATA_CLASSIFY_RECENT:
                [uiUserInfo setRecentType:[dbUserData.dataType integerValue]];
                [uiUserInfo setRecentUpdateTime:dbUserData.updateTime];
                if (uiUserInfo.recentType==PERSONAL_RECENT_TYPE_AUDIO)
                {
                    [uiUserInfo setRecentContent:resPath];
                }
                else 
                {
                    [uiUserInfo setRecentContent:dbUserData.dataContent];
                }
                break;
            default:
                break;
        }
    }
//    CPLogInfo(@"%@  ",uiUserInfo.headerPath);
    return uiUserInfo;
}
+(void)convertDbUserInfoToUi:(CPDBModelUserInfo *)dbUserInfo withUiUserInfo:(CPUIModelUserInfo *)uiUserInfo
{
//    [uiUserInfo setUserInfoID:dbUserInfo.userInfoID];
    [uiUserInfo setServerID:dbUserInfo.serverID];
    [uiUserInfo setUpdateTime:dbUserInfo.updateTime];
    [uiUserInfo setType:dbUserInfo.type];
    [uiUserInfo setName:dbUserInfo.name];
    [uiUserInfo setNickName:dbUserInfo.nickName];
//    [uiUserInfo setLifeStatus:dbUserInfo.lifeStatus];
    [uiUserInfo setMobileNumber:dbUserInfo.mobileNumber];
    [uiUserInfo setMobileIsBind:dbUserInfo.mobileIsBind];
    [uiUserInfo setEmailAddr:dbUserInfo.emailAddr];
    [uiUserInfo setEmailIsBind:dbUserInfo.emailIsBind];
    [uiUserInfo setSex:dbUserInfo.sex];
    [uiUserInfo setBirthday:dbUserInfo.birthday];
    [uiUserInfo setHeight:dbUserInfo.height];
    [uiUserInfo setWeight:dbUserInfo.weight];
    [uiUserInfo setThreeSizes:dbUserInfo.threeSizes];
    [uiUserInfo setCitys:dbUserInfo.citys];
    [uiUserInfo setAnniversaryMeet:dbUserInfo.anniversaryMeet];
    [uiUserInfo setAnniversaryMarry:dbUserInfo.anniversaryMarry];
    [uiUserInfo setAnniversaryDating:dbUserInfo.anniversaryDating];
    [uiUserInfo setBabyName:dbUserInfo.babyName];
    [uiUserInfo setCoupleAccount:dbUserInfo.coupleAccount];
    [uiUserInfo setDomain:dbUserInfo.domain];
    [uiUserInfo setCoupleNickName:dbUserInfo.coupleNickName];
    [uiUserInfo setSingleTime:dbUserInfo.singleTime];
//    [uiUserInfo setHasBaby:dbUserInfo.hasBaby];
    NSInteger dbLifeStatus = [dbUserInfo.lifeStatus integerValue];
    if (dbLifeStatus>128)
    {
        [uiUserInfo setLifeStatus:[NSNumber numberWithInt:(dbLifeStatus-128)]];
        [uiUserInfo setHasBaby:[NSNumber numberWithBool:NO]];
    }
    else 
    {
        [uiUserInfo setLifeStatus:[NSNumber numberWithInt:dbLifeStatus]];
        [uiUserInfo setHasBaby:[NSNumber numberWithBool:YES]];
    }
    if (uiUserInfo.coupleAccount)
    {
        CPDBModelUserInfo *dbUserCouple = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithName:uiUserInfo.coupleAccount];
        if (dbUserCouple)
        {
            [uiUserInfo setCoupleUserInfo:[self dbUserInfoToUi:dbUserCouple]];
        }
    }
    for(CPDBModelUserInfoData *dbUserData in dbUserInfo.dataList)
    {
        NSString *resPath = [[[CPSystemEngine sharedInstance] resManager] getResourcePathWithResID:dbUserData.resourceID];
//        CPLogInfo(@"classify is %@,resPath is %@  ",dbUserData.dataClassify,resPath);
        switch ([dbUserData.dataClassify integerValue])
        {
            case DATA_CLASSIFY_SELF_HEADER:
            case DATA_CLASSIFY_HEADER:
                [uiUserInfo setHeaderPath:resPath];
                [uiUserInfo setSelfHeaderImgPath:resPath];
                break;
            case DATA_CLASSIFY_SELF_BG:
                [uiUserInfo setSelfBgImgPath:resPath];
                break;
            case DATA_CLASSIFY_SELF_COUPLE:
                [uiUserInfo setSelfCoupleHeaderImgPath:resPath];
                break;
            case DATA_CLASSIFY_SELF_BABY:
                [uiUserInfo setSelfBabyHeaderImgPath:resPath];
                break;
            case DATA_CLASSIFY_RECENT:
                [uiUserInfo setRecentType:[dbUserData.dataType integerValue]];
                [uiUserInfo setRecentUpdateTime:dbUserData.updateTime];
                if (uiUserInfo.recentType==PERSONAL_RECENT_TYPE_AUDIO)
                {
                    [uiUserInfo setRecentContent:resPath];
                }
                else 
                {
                    [uiUserInfo setRecentContent:dbUserData.dataContent];
                }
                break;
            default:
                break;
        }
    }
}
+(CPUIModelUserInfoData *)dbUserInfoDataToUi:(CPDBModelUserInfoData *)dbUserInfoData
{
    CPUIModelUserInfoData *uiUserInfoData = [[CPUIModelUserInfoData alloc] init];
    [uiUserInfoData setUserInfoDataID:dbUserInfoData.userInfoDataID];
    [uiUserInfoData setUserInfoID:dbUserInfoData.userInfoID];
    [uiUserInfoData setDataClassify:dbUserInfoData.dataClassify];
    [uiUserInfoData setDataType:dbUserInfoData.dataType];
    [uiUserInfoData setDataContent:dbUserInfoData.dataContent];
    [uiUserInfoData setResourceID:dbUserInfoData.resourceID];
    return uiUserInfoData;
}
+(CPUIModelUserInfoDataAddition *)dbUserInfoDataAdditionToUi:(CPDBModelUserInfoDataAddition *)dbUserInfoDataAddition
{
    CPUIModelUserInfoDataAddition *uiUserInfoDataAddition = [[CPUIModelUserInfoDataAddition alloc] init];
    [uiUserInfoDataAddition setUserInfoDataID:dbUserInfoDataAddition.userInfoDataID];
    [uiUserInfoDataAddition setUserInfoID:dbUserInfoDataAddition.userInfoID];
    [uiUserInfoDataAddition setDataClassify:dbUserInfoDataAddition.dataClassify];
    [uiUserInfoDataAddition setDataType:dbUserInfoDataAddition.dataType];
    [uiUserInfoDataAddition setDataContent:dbUserInfoDataAddition.dataContent];
    [uiUserInfoDataAddition setResourceID:dbUserInfoDataAddition.resourceID];
    return uiUserInfoDataAddition;
}
+(CPUIModelMessageGroup *)dbMessageGroupToUi:(CPDBModelMessageGroup *)dbMessageGroup
{
    CPUIModelMessageGroup *uiMessageGroup = [[CPUIModelMessageGroup alloc] init];
    [uiMessageGroup setMsgGroupID:dbMessageGroup.msgGroupID];
    [uiMessageGroup setType:dbMessageGroup.type];
    [uiMessageGroup setRelationType:dbMessageGroup.relationType];
    [uiMessageGroup setGroupServerID:dbMessageGroup.groupServerID];
    [uiMessageGroup setGroupName:dbMessageGroup.groupName];
    [uiMessageGroup setGroupHeaderResID:dbMessageGroup.groupHeaderResID];
    [uiMessageGroup setMemoID:dbMessageGroup.memoID];
    [uiMessageGroup setUpdateDate:dbMessageGroup.updateDate];
    [uiMessageGroup setCreatorName:dbMessageGroup.creatorName];
    [uiMessageGroup setUnReadedCount:dbMessageGroup.unReadedCount];
    return uiMessageGroup;
}
+(CPUIModelMessageGroupMember *)dbMessageGroupMemberToUi:(CPDBModelMessageGroupMember *)dbMessageGroupMember
{
    CPUIModelMessageGroupMember *uiMessageGroupMember = [[CPUIModelMessageGroupMember alloc] init];
    [uiMessageGroupMember setMsgGroupMemID:dbMessageGroupMember.msgGroupMemID];
    [uiMessageGroupMember setMsgGroupID:dbMessageGroupMember.msgGroupID];
    [uiMessageGroupMember setMobileNumber:dbMessageGroupMember.mobileNumber];
    [uiMessageGroupMember setUserName:dbMessageGroupMember.userName];
    [uiMessageGroupMember setNickName:dbMessageGroupMember.nickName];
    [uiMessageGroupMember setSign:dbMessageGroupMember.sign];
    [uiMessageGroupMember setHeaderResourceID:dbMessageGroupMember.headerResourceID];
    [uiMessageGroupMember setDomain:dbMessageGroupMember.domain];
    return uiMessageGroupMember;
}
+(CPUIModelMessage *)dbMessageToUi:(CPDBModelMessage *)dbMessage
{
    CPUIModelMessage *uiMessage = [[CPUIModelMessage alloc] init];
    [uiMessage setMsgID:dbMessage.msgID];
    [uiMessage setMsgGroupID:dbMessage.msgGroupID];
    [uiMessage setMsgSenderName:dbMessage.msgSenderID];
    [uiMessage setMobile:dbMessage.mobile];
    [uiMessage setUserID:dbMessage.userID];
    [uiMessage setFlag:dbMessage.flag];
    [uiMessage setSendState:dbMessage.sendState];
    [uiMessage setDate:dbMessage.date];
    [uiMessage setIsReaded:dbMessage.isReaded];
    [uiMessage setMsgText:dbMessage.msgText];
    [uiMessage setContentType:dbMessage.contentType];
    [uiMessage setLocationInfo:dbMessage.locationInfo];
    [uiMessage setAttachResID:dbMessage.attachResID];
    [uiMessage setMagicMsgID:dbMessage.magicMsgID];
    [uiMessage setPetMsgID:dbMessage.petMsgID];
    [uiMessage setUuidAsk:dbMessage.uuidAsk];
    [uiMessage setBodyContent:dbMessage.bodyContent];
    if ([uiMessage isAlarmMsg])
    {
        [uiMessage setAlarmTime:[NSNumber numberWithLongLong:[dbMessage.mobile longLongValue]]];
        [uiMessage setIsAlarmHidden:[NSNumber numberWithBool:[dbMessage.locationInfo boolValue]]];
    }
    return uiMessage;
}
+(CPUIModelPersonalInfo *)dbPersonalInfoToUi:(CPDBModelPersonalInfo *)dbPersonalInfo
{
    CPUIModelPersonalInfo *uiPersonalInfo = [[CPUIModelPersonalInfo alloc] init];
    [uiPersonalInfo setPersonalInfoID:dbPersonalInfo.personalInfoID];
    [uiPersonalInfo setServerID:dbPersonalInfo.serverID];
    [uiPersonalInfo setUpdateTime:dbPersonalInfo.updateTime];
    [uiPersonalInfo setName:dbPersonalInfo.name];
    [uiPersonalInfo setNickName:dbPersonalInfo.nickName];
    [uiPersonalInfo setMobileNumber:dbPersonalInfo.mobileNumber];
    [uiPersonalInfo setMobileIsBind:dbPersonalInfo.mobileIsBind];
    [uiPersonalInfo setEmailAddr:dbPersonalInfo.emailAddr];
    [uiPersonalInfo setEmailIsBind:dbPersonalInfo.emailIsBind];
    [uiPersonalInfo setSex:dbPersonalInfo.sex];
    [uiPersonalInfo setBirthday:dbPersonalInfo.birthday];
    [uiPersonalInfo setHeight:dbPersonalInfo.height];
    [uiPersonalInfo setWeight:dbPersonalInfo.weight];
    [uiPersonalInfo setThreeSizes:dbPersonalInfo.threeSizes];
    [uiPersonalInfo setCitys:dbPersonalInfo.citys];
    [uiPersonalInfo setAnniversaryMeet:dbPersonalInfo.anniversaryMeet];
    [uiPersonalInfo setAnniversaryMarry:dbPersonalInfo.anniversaryMarry];
    [uiPersonalInfo setAnniversaryDating:dbPersonalInfo.anniversaryDating];
    NSInteger dbLifeStatus = [dbPersonalInfo.lifeStatus integerValue];
    if (dbLifeStatus>128)
    {
        [uiPersonalInfo setLifeStatus:[NSNumber numberWithInt:(dbLifeStatus-128)]];
        [uiPersonalInfo setHasBaby:[NSNumber numberWithBool:NO]];
    }
    else 
    {
        [uiPersonalInfo setLifeStatus:[NSNumber numberWithInt:dbLifeStatus]];
        [uiPersonalInfo setHasBaby:[NSNumber numberWithBool:YES]];
    }
    [uiPersonalInfo setSingleTime:dbPersonalInfo.singleTime];
    if (dbPersonalInfo.dataList)
    {
        for(CPDBModelPersonalInfoData *dbPersonalData in dbPersonalInfo.dataList)
        {
            NSString *resPath = [[[CPSystemEngine sharedInstance] resManager] getResourcePathWithPersonalData:dbPersonalData];
            switch ([dbPersonalData.dataClassify integerValue])
            {
                case DATA_CLASSIFY_SELF_HEADER:
                case DATA_CLASSIFY_HEADER:
                    [uiPersonalInfo setSelfHeaderImgPath:resPath];
                    break;
                case DATA_CLASSIFY_SELF_BG:
                    [uiPersonalInfo setSelfBgImgPath:resPath];
                    break;
                case DATA_CLASSIFY_SELF_COUPLE:
                    [uiPersonalInfo setSelfCoupleHeaderImgPath:resPath];
                    break;
                case DATA_CLASSIFY_SELF_BABY:
                    [uiPersonalInfo setSelfBabyHeaderImgPath:resPath];
                    break;
                case DATA_CLASSIFY_RECENT:
                    [uiPersonalInfo setRecentType:[dbPersonalData.dataType integerValue]];
                    [uiPersonalInfo setRecentUpdateTime:dbPersonalData.updateTime];
                    if (uiPersonalInfo.recentType==PERSONAL_RECENT_TYPE_AUDIO)
                    {
                        [uiPersonalInfo setRecentContent:resPath];
                    }
                    else 
                    {
                        [uiPersonalInfo setRecentContent:dbPersonalData.dataContent];
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return uiPersonalInfo;
}
+(CPUIModelBabyInfoData *)dbBabyInfoDataToUi:(CPDBModelBabyInfoData *)dbBabyInfoData
{
    CPUIModelBabyInfoData *uiBabyInfoData = [[CPUIModelBabyInfoData alloc] init];
    [uiBabyInfoData setUserInfoID:dbBabyInfoData.userInfoID];
    [uiBabyInfoData setName:dbBabyInfoData.name];
    [uiBabyInfoData setSex:dbBabyInfoData.sex];
    [uiBabyInfoData setHeaderResID:dbBabyInfoData.headerResID];
    [uiBabyInfoData setBirthday:dbBabyInfoData.birthday];
    return uiBabyInfoData;
}
+(CPUIModelPersonalInfoData *)dbPersonalInfoDataToUi:(CPDBModelPersonalInfoData *)dbPersonalInfoData
{
    CPUIModelPersonalInfoData *uiPersonalInfoData = [[CPUIModelPersonalInfoData alloc] init];
    [uiPersonalInfoData setPersonalInfoID:dbPersonalInfoData.personalInfoID];
    [uiPersonalInfoData setDataClassify:dbPersonalInfoData.dataClassify];
    [uiPersonalInfoData setDataType:dbPersonalInfoData.dataType];
    [uiPersonalInfoData setDataContent:dbPersonalInfoData.dataContent];
    [uiPersonalInfoData setResourceID:dbPersonalInfoData.resourceID];
    return uiPersonalInfoData;
}
+(CPUIModelPersonalInfoDataAddition *)dbPersonalInfoDataAdditionToUi:(CPDBModelPersonalInfoDataAddition *)dbPersonalInfoDataAddition
{
    CPUIModelPersonalInfoDataAddition *uiPersonalInfoDataAddition = [[CPUIModelPersonalInfoDataAddition alloc] init];
    [uiPersonalInfoDataAddition setPersonalInfoDataID:dbPersonalInfoDataAddition.personalInfoDataID];
    [uiPersonalInfoDataAddition setPersonalInfoID:dbPersonalInfoDataAddition.personalInfoID];
    [uiPersonalInfoDataAddition setDataClassify:dbPersonalInfoDataAddition.dataClassify];
    [uiPersonalInfoDataAddition setDataType:dbPersonalInfoDataAddition.dataType];
    [uiPersonalInfoDataAddition setDataContent:dbPersonalInfoDataAddition.dataContent];
    [uiPersonalInfoDataAddition setResourceID:dbPersonalInfoDataAddition.resourceID];
    return uiPersonalInfoDataAddition;
}
+(CPUIModelResource *)dbResourceToUi:(CPDBModelResource *)dbResource
{
    CPUIModelResource *uiResource = [[CPUIModelResource alloc] init];
    [uiResource setServerUrl:dbResource.serverUrl];
    [uiResource setCreateTime:dbResource.createTime];
    [uiResource setFileName:dbResource.fileName];
    [uiResource setFilePrefix:dbResource.filePrefix];
    [uiResource setType:dbResource.type];
    [uiResource setMimeType:dbResource.mimeType];
    [uiResource setMark:dbResource.mark];
    [uiResource setObjID:dbResource.objID];
    [uiResource setObjType:dbResource.objType];
    return uiResource;
}

//UI-->PT
+(CPPTModelContact *)uiContactToPt:(CPPTModelContact *)uiContact
{
    CPPTModelContact *ptContact = [[CPPTModelContact alloc] init];
#if 0
    [ptContact setAbPersonID:uiContact.abPersonID];
    [ptContact setUpdateTime:uiContact.updateTime];
    [ptContact setFirstName:uiContact.firstName];
    [ptContact setLastName:uiContact.lastName];
    [ptContact setFullName:uiContact.fullName];
    [ptContact setSyncTime:uiContact.syncTime];
    [ptContact setSyncMark:uiContact.syncMark];
    [ptContact setHeaderPhotoResID:uiContact.headerPhotoResID];
#endif
    return ptContact;
}
+(CPPTModelContactWay *)uiContactWayToPt:(CPPTModelContactWay *)uiContactWay
{
    CPPTModelContactWay *ptContactWay = [[CPPTModelContactWay alloc] init];
#if 0
    [ptContactWay setContactID:uiContactWay.contactID];
    [ptContactWay setRegType:uiContactWay.regType];
    [ptContactWay setType:uiContactWay.type];
    [ptContactWay setName:uiContactWay.name];
    [ptContactWay setValue:uiContactWay.value];
#endif
    return ptContactWay;
}
+(CPPTModelUserInfo *)uiUserInfoToPt:(CPPTModelUserInfo *)uiUserInfo
{
    CPPTModelUserInfo *ptUserInfo = [[CPPTModelUserInfo alloc] init];
#if 0
    [ptUserInfo setServerID:uiUserInfo.serverID];
    [ptUserInfo setUpdateTime:uiUserInfo.updateTime];
    [ptUserInfo setType:uiUserInfo.type];
    [ptUserInfo setName:uiUserInfo.name];
    [ptUserInfo setNickName:uiUserInfo.nickName];
    [ptUserInfo setMobileNumber:uiUserInfo.mobileNumber];
    [ptUserInfo setMobileIsBind:uiUserInfo.mobileIsBind];
    [ptUserInfo setEmailAddr:uiUserInfo.emailAddr];
    [ptUserInfo setEmailIsBind:uiUserInfo.emailIsBind];
    [ptUserInfo setSex:uiUserInfo.sex];
    [ptUserInfo setBirthday:uiUserInfo.birthday];
    [ptUserInfo setHeight:uiUserInfo.height];
    [ptUserInfo setWeight:uiUserInfo.weight];
    [ptUserInfo setThreeSizes:uiUserInfo.threeSizes];
    [ptUserInfo setCitys:uiUserInfo.citys];
    [ptUserInfo setAnniversaryMeet:uiUserInfo.anniversaryMeet];
    [ptUserInfo setAnniversaryMarry:uiUserInfo.anniversaryMarry];
    [ptUserInfo setAnniversaryDating:uiUserInfo.anniversaryDating];
    [ptUserInfo setBabyName:uiUserInfo.babyName];
#endif
    return ptUserInfo;
}
+(CPPTModelUserInfoData *)uiUserInfoDataToPt:(CPPTModelUserInfoData *)uiUserInfoData
{
    CPPTModelUserInfoData *ptUserInfoData = [[CPPTModelUserInfoData alloc] init];
    [ptUserInfoData setUserInfoID:uiUserInfoData.userInfoID];
    [ptUserInfoData setDataClassify:uiUserInfoData.dataClassify];
    [ptUserInfoData setDataType:uiUserInfoData.dataType];
    [ptUserInfoData setDataContent:uiUserInfoData.dataContent];
    [ptUserInfoData setResourceID:uiUserInfoData.resourceID];
    return ptUserInfoData;
}
+(CPPTModelUserInfoDataAddition *)uiUserInfoDataAdditionToPt:(CPPTModelUserInfoDataAddition *)uiUserInfoDataAddition
{
    CPPTModelUserInfoDataAddition *ptUserInfoDataAddition = [[CPPTModelUserInfoDataAddition alloc] init];
    [ptUserInfoDataAddition setUserInfoDataID:uiUserInfoDataAddition.userInfoDataID];
    [ptUserInfoDataAddition setUserInfoID:uiUserInfoDataAddition.userInfoID];
    [ptUserInfoDataAddition setDataClassify:uiUserInfoDataAddition.dataClassify];
    [ptUserInfoDataAddition setDataType:uiUserInfoDataAddition.dataType];
    [ptUserInfoDataAddition setDataContent:uiUserInfoDataAddition.dataContent];
    [ptUserInfoDataAddition setResourceID:uiUserInfoDataAddition.resourceID];
    return ptUserInfoDataAddition;
}
+(CPPTModelMessageGroup *)uiMessageGroupToPt:(CPPTModelMessageGroup *)uiMessageGroup
{
    CPPTModelMessageGroup *ptMessageGroup = [[CPPTModelMessageGroup alloc] init];
    [ptMessageGroup setType:uiMessageGroup.type];
    [ptMessageGroup setGroupServerID:uiMessageGroup.groupServerID];
    [ptMessageGroup setGroupName:uiMessageGroup.groupName];
    [ptMessageGroup setGroupHeaderResID:uiMessageGroup.groupHeaderResID];
    [ptMessageGroup setMemoID:uiMessageGroup.memoID];
    return ptMessageGroup;
}
+(CPPTModelMessageGroupMember *)uiMessageGroupMemberToPt:(CPPTModelMessageGroupMember *)uiMessageGroupMember
{
    CPPTModelMessageGroupMember *ptMessageGroupMember = [[CPPTModelMessageGroupMember alloc] init];
    [ptMessageGroupMember setMsgGroupID:uiMessageGroupMember.msgGroupID];
    [ptMessageGroupMember setMobileNumber:uiMessageGroupMember.mobileNumber];
    [ptMessageGroupMember setUserID:uiMessageGroupMember.userID];
    [ptMessageGroupMember setNickName:uiMessageGroupMember.nickName];
    [ptMessageGroupMember setSign:uiMessageGroupMember.sign];
    [ptMessageGroupMember setHeaderResourceID:uiMessageGroupMember.headerResourceID];
    return ptMessageGroupMember;
}
+(CPPTModelMessage *)uiMessageToPt:(CPPTModelMessage *)uiMessage
{
    CPPTModelMessage *ptMessage = [[CPPTModelMessage alloc] init];
    [ptMessage setMsgGroupID:uiMessage.msgGroupID];
    [ptMessage setMsgServerID:uiMessage.msgServerID];
    [ptMessage setMobile:uiMessage.mobile];
    [ptMessage setUserID:uiMessage.userID];
    [ptMessage setFlag:uiMessage.flag];
    [ptMessage setSendState:uiMessage.sendState];
    [ptMessage setDate:uiMessage.date];
    [ptMessage setIsReaded:uiMessage.isReaded];
    [ptMessage setMsgText:uiMessage.msgText];
    [ptMessage setContentType:uiMessage.contentType];
    [ptMessage setLocationInfo:uiMessage.locationInfo];
    [ptMessage setAttachResID:uiMessage.attachResID];
    return ptMessage;
}
+(CPPTModelPersonalInfo *)uiPersonalInfoToPt:(CPPTModelPersonalInfo *)uiPersonalInfo
{
    CPPTModelPersonalInfo *ptPersonalInfo = [[CPPTModelPersonalInfo alloc] init];
    [ptPersonalInfo setServerID:uiPersonalInfo.serverID];
    [ptPersonalInfo setUpdateTime:uiPersonalInfo.updateTime];
    [ptPersonalInfo setName:uiPersonalInfo.name];
    [ptPersonalInfo setNickName:uiPersonalInfo.nickName];
    [ptPersonalInfo setMobileNumber:uiPersonalInfo.mobileNumber];
    [ptPersonalInfo setMobileIsBind:uiPersonalInfo.mobileIsBind];
    [ptPersonalInfo setEmailAddr:uiPersonalInfo.emailAddr];
    [ptPersonalInfo setEmailIsBind:uiPersonalInfo.emailIsBind];
    [ptPersonalInfo setSex:uiPersonalInfo.sex];
    [ptPersonalInfo setBirthday:uiPersonalInfo.birthday];
    [ptPersonalInfo setHeight:uiPersonalInfo.height];
    [ptPersonalInfo setWeight:uiPersonalInfo.weight];
    [ptPersonalInfo setThreeSizes:uiPersonalInfo.threeSizes];
    [ptPersonalInfo setCitys:uiPersonalInfo.citys];
    [ptPersonalInfo setAnniversaryMeet:uiPersonalInfo.anniversaryMeet];
    [ptPersonalInfo setAnniversaryMarry:uiPersonalInfo.anniversaryMarry];
    [ptPersonalInfo setAnniversaryDating:uiPersonalInfo.anniversaryDating];
    return ptPersonalInfo;
}
+(CPPTModelBabyInfoData *)uiBabyInfoDataToPt:(CPPTModelBabyInfoData *)uiBabyInfoData
{
    CPPTModelBabyInfoData *ptBabyInfoData = [[CPPTModelBabyInfoData alloc] init];
    [ptBabyInfoData setUserInfoID:uiBabyInfoData.userInfoID];
    [ptBabyInfoData setName:uiBabyInfoData.name];
    [ptBabyInfoData setSex:uiBabyInfoData.sex];
    [ptBabyInfoData setHeaderResID:uiBabyInfoData.headerResID];
    [ptBabyInfoData setBirthday:uiBabyInfoData.birthday];
    return ptBabyInfoData;
}
+(CPPTModelPersonalInfoData *)uiPersonalInfoDataToPt:(CPPTModelPersonalInfoData *)uiPersonalInfoData
{
    CPPTModelPersonalInfoData *ptPersonalInfoData = [[CPPTModelPersonalInfoData alloc] init];
    [ptPersonalInfoData setPersonalInfoID:uiPersonalInfoData.personalInfoID];
    [ptPersonalInfoData setDataClassify:uiPersonalInfoData.dataClassify];
    [ptPersonalInfoData setDataType:uiPersonalInfoData.dataType];
    [ptPersonalInfoData setDataContent:uiPersonalInfoData.dataContent];
    [ptPersonalInfoData setResourceID:uiPersonalInfoData.resourceID];
    return ptPersonalInfoData;
}
+(CPPTModelPersonalInfoDataAddition *)uiPersonalInfoDataAdditionToPt:(CPPTModelPersonalInfoDataAddition *)uiPersonalInfoDataAddition
{
    CPPTModelPersonalInfoDataAddition *ptPersonalInfoDataAddition = [[CPPTModelPersonalInfoDataAddition alloc] init];
    [ptPersonalInfoDataAddition setPersonalInfoDataID:uiPersonalInfoDataAddition.personalInfoDataID];
    [ptPersonalInfoDataAddition setPersonalInfoID:uiPersonalInfoDataAddition.personalInfoID];
    [ptPersonalInfoDataAddition setDataClassify:uiPersonalInfoDataAddition.dataClassify];
    [ptPersonalInfoDataAddition setDataType:uiPersonalInfoDataAddition.dataType];
    [ptPersonalInfoDataAddition setDataContent:uiPersonalInfoDataAddition.dataContent];
    [ptPersonalInfoDataAddition setResourceID:uiPersonalInfoDataAddition.resourceID];
    return ptPersonalInfoDataAddition;
}
+(CPPTModelResource *)uiResourceToPt:(CPPTModelResource *)uiResource
{
    CPPTModelResource *ptResource = [[CPPTModelResource alloc] init];
    [ptResource setServerUrl:uiResource.serverUrl];
    [ptResource setCreateTime:uiResource.createTime];
    [ptResource setFileName:uiResource.fileName];
    [ptResource setFilePrefix:uiResource.filePrefix];
    [ptResource setType:uiResource.type];
    [ptResource setMimeType:uiResource.mimeType];
    [ptResource setMark:uiResource.mark];
    [ptResource setObjID:uiResource.objID];
    [ptResource setObjType:uiResource.objType];
    return ptResource;
}

+(CPPTModelUserRegisterInfo *)uiRegInfoToPt:(CPUIModelRegisterInfo *)regInfo
{
    CPPTModelUserRegisterInfo *ptRegInfo = [[CPPTModelUserRegisterInfo alloc] init];
    [ptRegInfo setNickName:regInfo.nickName];
    [ptRegInfo setUName:regInfo.accountName];
    [ptRegInfo setPassword:regInfo.password];
    [ptRegInfo setRelationShip:[NSNumber numberWithInt:regInfo.lifeStatus]];
    [ptRegInfo setGender:[NSNumber numberWithInt:regInfo.sex]];
    [ptRegInfo setPhoneNum:regInfo.mobileNumber];
    [ptRegInfo setPhoneArea:regInfo.regionNumber];
    return ptRegInfo;
}


//PT-->UI
+(CPUIModelUserInfo *)ptUserInfoToUI:(CPPTModelUserInfo *)ptUserInfo
{
    CPUIModelUserInfo *uiUserInfo = [[CPUIModelUserInfo alloc] init];
    [uiUserInfo setName:[self getAccountNameWithName:ptUserInfo.uName]];
    [uiUserInfo setDomain:[self getDomainWithName:ptUserInfo.uName]];
    [uiUserInfo setNickName:ptUserInfo.nickName];
    [uiUserInfo setSex:ptUserInfo.gender];
    [uiUserInfo setLifeStatus:ptUserInfo.lifeStatus];
    [uiUserInfo setMobileNumber:ptUserInfo.mobileNumber];
    return uiUserInfo;
}
@end
