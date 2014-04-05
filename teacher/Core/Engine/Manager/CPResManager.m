//
//  CPResManager.m
//  icouple
//
//  Created by yong wei on 12-3-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CPResManager.h"
#import "CPSystemEngine.h"
#import "CPHttpEngine.h"
#import "CoreUtils.h"
#import "CPDBManagement.h"
#import "CPDBModelPersonalInfo.h"
#import "CPDBModelPersonalInfoData.h"
#import "CPLGModelAccount.h"
@implementation CPResManager

-(id)init
{
    self = [super init];
    if (self) 
    {
        downloadDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        uploadDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        isExcuteResourceReq = NO;
        videoPicName = @"";
    }
    return self;

}
#pragma mark API

//用于初始化下载和上传的缓存列表
-(void)reloadDownloadCacheWithArray:(NSArray *)willDownArray
{
    @synchronized(self)
    {
    if(downloadResArray)
    {
        [downloadResArray removeAllObjects];
        [downloadResArray addObjectsFromArray:willDownArray];
    }
    else 
    {
        downloadResArray = [[NSMutableArray alloc] initWithArray:willDownArray];
    }
    if (downloadResArray&&[downloadResArray count]>0&&isExcuteResourceReq)
    {
        [self downloadRes];
    }
    }
}
-(void)reloadUploadCacheWithArray:(NSArray *)willUploadArray
{
    @synchronized(self)
    {
    if (uploadResArray)
    {
        [uploadResArray removeAllObjects];
        [uploadResArray addObjectsFromArray:willUploadArray];
    }
    uploadResArray = [[NSMutableArray alloc] initWithArray:willUploadArray];
 //   if (uploadResArray&&[uploadResArray count]>0&&[uploadDictionary count]==0&&isExcuteResourceReq)
    if (uploadResArray&&[uploadResArray count]>0&&[uploadDictionary count]==0)
    {
        [self uploadRes];
    }
    }
}
-(void)excuteResourceCached
{
    @synchronized(self)
    {
    isExcuteResourceReq = YES;
    if (uploadResArray&&[uploadResArray count]>0&&[uploadDictionary count]==0)
    {
        [self uploadRes];
    }
    if (downloadResArray&&[downloadResArray count]>0)
    {
        [self downloadRes];
    }
    }
}
-(void)clearResCachedData
{
    @synchronized(self)
    {
    isExcuteResourceReq = NO;
    downloadResArray = nil;
    uploadResArray = nil;
    downloadDictionary = nil;
    uploadDictionary = nil;
    }
}
//其他管理器调用的api，资源管理器处理需要下载/上传的资源
-(void)downloadWithRes:(CPDBModelResource *)dbRes
{
    [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
    [[CPSystemEngine sharedInstance] downloadWithRes:dbRes];
}
-(void)uploadWithRes:(CPDBModelResource *)dbRes up_data:(NSData *)uploadData
{
    [dbRes setMark:[NSNumber numberWithInt:MARK_UPLOAD]];
    [[CPSystemEngine sharedInstance] uploadWithRes:dbRes up_data:uploadData];
}

-(void)downloadResWithRes:(CPDBModelResource *)dbRes
{
    @synchronized(self)
    {
    if(downloadResArray)
    {
//        [downloadResArray removeAllObjects];
        [downloadResArray addObject:dbRes];
    }
    else 
    {
        downloadResArray = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:dbRes]];
    }
    if (downloadResArray&&[downloadResArray count]>0&&isExcuteResourceReq)
    {
        [self downloadRes];
    }
    }
}

//初始化队列之后，下载/上传资源开始的入口
-(void)downloadRes
{
    @synchronized(self)
    {
        if (!downloadDictionary) 
        {
            downloadDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        }
        for(CPDBModelResource *dbRes in downloadResArray)
        {
            if(dbRes.resID&&![downloadDictionary objectForKey:dbRes.resID])
            {
                NSString *filePath = dbRes.filePrefix;
                if (!filePath)
                {
                    filePath = @"";
                }
                NSString *fileName = dbRes.fileName;
                if (!fileName)
                {
                    fileName = @"";
                }
                
                NSError *error;
                NSFileManager *fm = [NSFileManager defaultManager];
                NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *writablePath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filePath];
                
                BOOL success = [fm createDirectoryAtPath:writablePath withIntermediateDirectories:YES attributes:nil error:&error];
                CPLogInfo(@"fileFullPath's path is  %@",writablePath);
                if(!success)
                {
                    CPLogError(@"error: %@", [error localizedDescription]);
                    continue;
                }

                NSString *fileFullPath = [NSString stringWithFormat:@"%@%@",writablePath,fileName];
                [downloadDictionary setObject:@"0" forKey:dbRes.resID];
                NSString *fileServerUrl = dbRes.serverUrl;
                NSInteger dbResObjType = [dbRes.objType integerValue];
                if (dbResObjType==RESOURCE_FILE_CP_TYPE_HEADER||dbResObjType==RESOURCE_FILE_CP_TYPE_GROUPP_MEM_HEADER)
                {
//                    NSRange fileTypeSpotIndex = [dbRes.serverUrl rangeOfString:@"."];
//                    if (fileTypeSpotIndex.length>0)
//                    {
//                        fileServerUrl = [NSString stringWithFormat:@"%@_120%@",[dbRes.serverUrl substringToIndex:fileTypeSpotIndex.location]
//                                                                            ,[dbRes.serverUrl substringFromIndex:fileTypeSpotIndex.location]];
//                    }
                }
                //begin add to http
                [[[CPSystemEngine sharedInstance] httpEngine] downloadResourceOf:dbRes.resID
                                                                       forModule:[self class]
                                                                            from:fileServerUrl
                                                                          toFile:fileFullPath];
                break;
            }
        }
    }
}
-(void)uploadRes
{
    @synchronized(self)
    {
        if (!uploadDictionary) 
        {
            uploadDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
        }
        CPLogInfo(@"uploadResArray  is  %@",uploadResArray);
        for(CPDBModelResource *dbRes in uploadResArray)
        {
            CPLogInfo(@"dbRes.resID   is  %@        %@",dbRes.resID,uploadDictionary);
            if(dbRes.resID&&![uploadDictionary objectForKey:dbRes.resID])
            {
//                NSString *filePath = dbRes.filePrefix;
//                if (!filePath)
//                {
//                    filePath = @"";
//                }
//                NSString *fileName = dbRes.fileName;
//                if (!fileName)
//                {
//                    fileName = @"";
//                }
//                
//                NSError *error;
//                NSFileManager *fm = [NSFileManager defaultManager];
//                NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                NSString *documentsDirectory = [paths objectAtIndex:0];
//                NSString *writablePath = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filePath];
//                
//                BOOL success = [fm createDirectoryAtPath:writablePath withIntermediateDirectories:YES attributes:nil error:&error];
//                CPLogInfo(@"fileFullPath's path is  %@",writablePath);
//                if(!success)
//                {
//                    CPLogError(@"error: %@", [error localizedDescription]);
//                    continue;
//                }
                
//                NSString *fileFullPath = [NSString stringWithFormat:@"%@%@",writablePath,fileName];
                NSString *fileFullPath = [self getResourcePathWithRes:dbRes];
                if (![CoreUtils fileIsExistWithPah:fileFullPath])
                {
                    CPLogWarn(@"file not exist,path is %@",fileFullPath);
                    continue;
                }
                [uploadDictionary setObject:@"0" forKey:dbRes.resID];
                //add http
//                NSInteger uploadType = [dbRes.type intValue];
                if ([dbRes.type intValue]==RESOURCE_FILE_TYPE_MSG_VIDEO)
                {
                    NSString *filePath = [fileFullPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
                    videoPicName = filePath;
                    [[[CPSystemEngine sharedInstance] httpEngine] uploadResourceOf:dbRes.resID 
                                                                         forModule:[self class] 
                                                                  resrouceCategory:K_RESOURCE_CATEGORY_MESSAGE_PIC
                                                                          fromFile:filePath
                                                                          mimeType:@"image/jpeg"];
                }
                else if ([dbRes.type intValue]==RESOURCE_FILE_GROUP_MSG_VIDEO)
                {
                    NSString *filePath = [fileFullPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
                    videoPicName = filePath;
                    [[[CPSystemEngine sharedInstance] httpEngine] uploadResourceOf:dbRes.resID 
                                                                         forModule:[self class] 
                                                                  resrouceCategory:K_RESOURCE_CATEGORY_GROUP_MESSAGE_PIC
                                                                          fromFile:filePath
                                                                          mimeType:@"image/jpeg"];
                }
                else 
                {
                    [[[CPSystemEngine sharedInstance] httpEngine] uploadResourceOf:dbRes.resID 
                                                                         forModule:[self class] 
                                                                  resrouceCategory:[dbRes.type intValue]
                                                                          fromFile:fileFullPath
                                                                          mimeType:dbRes.mimeType];
                }
                break;
            }
        }
    }
}
-(void)removeUploadResWithResID:(NSNumber *)resID
{
    @synchronized(self)
    {
        if (resID)
        {
            [uploadDictionary removeObjectForKey:resID];
        }
    }
}
-(void)uploadResourceOf:(NSNumber *)resID resrouceCategory:(NSNumber *)cate fromFile:(NSString *)filePath mimeType:(NSString *)mimeType
{
    [[[CPSystemEngine sharedInstance] httpEngine] uploadResourceOf:resID 
                                                         forModule:[self class] 
                                                  resrouceCategory:[cate intValue]
                                                          fromFile:filePath
                                                          mimeType:mimeType];
}
//用于http请求之后回调方法的接口
-(void)downloadResWithID:(NSNumber *)localResID andResCode:(NSNumber *)resCode andTimeStamp:(NSString *)timeStamp 
andTmpFilePath:(NSString *)filePath
{
    [[CPSystemEngine sharedInstance] downloadResWithID:localResID 
                                            andResCode:resCode
                                          andTimeStamp:timeStamp 
                                        andTmpFilePath:filePath];
    @synchronized(self)
    {
        for(CPDBModelResource *dbRes in downloadResArray)
        {
            if(dbRes.resID&&localResID&&[localResID isEqualToNumber:dbRes.resID])
            {
                [downloadDictionary removeObjectForKey:dbRes.resID];
                [downloadResArray removeObject:dbRes];
                break;
            }
        }
        //todo:
        [self downloadRes];
    }
}
-(void)uploadResWithResID:(NSNumber *)localResID andResCode:(NSNumber *)resCode url:(NSString *)url andTimeStamp:(NSString *)timeStamp
{
    NSLog(@"%@",[localResID stringValue]);
    [[CPSystemEngine sharedInstance] uploadResWithResID:localResID andResCode:resCode url:url andTimeStamp:timeStamp];
    @synchronized(self)
    {
//        if ([resCode integerValue]==RES_CODE_SUCESS)
        {
            for(CPDBModelResource *dbRes in uploadResArray)
            {
                if(dbRes.resID&&localResID&&[localResID isEqualToNumber:dbRes.resID])
                {
                    [uploadDictionary removeObjectForKey:dbRes.resID];
                    [uploadResArray removeObject:dbRes];
                    break;
                }
            }
        }
        //todo:
        [self uploadRes];
    }
}

#pragma mark CPHttpEngine protocol
- (void) handleResourceUploadCompleteOf:(NSNumber *)resourceID
                         withResultCode:(NSNumber *)resultCode
                      andResponseObject:(NSObject *)obj
{
    CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] getResWithID:resourceID];
    if ([videoPicName rangeOfString:@".jpg"].length > 1 && [dbRes isVideoMsg]) {
        [self uploadResWithResIDOfVideo:resourceID andResCode:resultCode url:(NSString *)obj andTimeStamp:nil];
    }else{
        [self uploadResWithResID:resourceID andResCode:resultCode url:(NSString *)obj andTimeStamp:nil];
    }
}

-(void)uploadResWithResIDOfVideo:(NSNumber *)localResID andResCode:(NSNumber *)resCode url:(NSString *)url andTimeStamp:(NSString *)timeStamp{
    
    //[[CPSystemEngine sharedInstance] uploadResWithResID:localResID andResCode:resCode url:url andTimeStamp:timeStamp];
    
//    @synchronized(self)
//    {
//        for(CPDBModelResource *dbRes in uploadResArray)
//        {
//            if(dbRes.resID&&localResID&&[localResID isEqualToNumber:dbRes.resID])
//            {
//                [uploadDictionary removeObjectForKey:dbRes.resID];
//                [uploadResArray removeObject:dbRes];
//                break;
//            }
//        }
//    }
    videoPicName = @"";
//    [uploadDictionary setObject:@"0" forKey:localResID];
//    NSLog(@"%@",[localResID stringValue]);
    [[CPSystemEngine sharedInstance] uploadResWithResID:localResID andResCode:resCode url:url andTimeStamp:timeStamp];
}

- (void) handleResourceUploadCompleteOfVideo:(NSNumber *)resourceID
                              withResultCode:(NSNumber *)resultCode
                           andResponseObject:(NSObject *)obj{
    
    [self uploadResWithResID:resourceID andResCode:resultCode url:(NSString *)obj andTimeStamp:nil];
}

- (void) handleResrouceUploadErrorOf:(NSNumber *)resourceID
                      withResultCode:(NSNumber *)resultCode
{
    CPLogError(@"upload error %@",resourceID);
    [self uploadResWithResID:resourceID andResCode:resultCode url:nil andTimeStamp:nil];
}

- (void) handleResourceDownloadCompleteOf:(NSNumber *)resourceID
                           withResultCode:(NSNumber *)resultCode
                             andLocalFile:(NSString *)localFile
                             andTimeStamp:(NSString *)timeStamp
{
    [self downloadResWithID:resourceID andResCode:resultCode andTimeStamp:timeStamp andTmpFilePath:localFile];
}
- (void) handleResourceDownlaodErrorOf:(NSNumber *)resourceID
                        withResultCode:(NSNumber *)resultCode
{
    CPLogError(@"download error %@",resourceID);
//    if ([resultCode integerValue]==404)
    {
        [self downloadResWithID:resourceID andResCode:resultCode andTimeStamp:nil andTmpFilePath:nil];
    }
}


#pragma mark excute db and res cached
-(void)addResourceByPersonalImgWithUrl:(NSString *)url andDataType:(NSNumber *)dataType
{
    NSNumber *dbResID = nil;
    if (url&&![@"" isEqualToString:url]&&![url isEqual:[NSNull null]])
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",[CoreUtils getUUID]]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/",[[[CPSystemEngine sharedInstance] accountModel] loginName]]];
        [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
        [dbRes setServerUrl:url];
        [dbRes setObjID:[NSNumber numberWithInt:1]];
        [dbRes setObjType:dataType];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
    }
    if (dbResID)
    {
        CPDBModelPersonalInfo *dbPersalInfo = [[[CPSystemEngine sharedInstance] dbManagement] findPersonalInfo];
        if (dbPersalInfo)
        {
            CPDBModelPersonalInfoData *oldDbPersonalData = [[[CPSystemEngine sharedInstance] dbManagement] findPersonalInfoDataWithPersonalID:dbPersalInfo.personalInfoID andClassify:dataType];
            if (oldDbPersonalData)
            {
                [oldDbPersonalData setResourceID:dbResID];
                [[[CPSystemEngine sharedInstance] dbManagement] updatePersonalInfoDataWithID:oldDbPersonalData.personalInfoDataID
                                                                                         obj:oldDbPersonalData];
            }
            else 
            {
                CPDBModelPersonalInfoData *dbPersonalData = [[CPDBModelPersonalInfoData alloc] init];
                [dbPersonalData setDataClassify:dataType];
                [dbPersonalData setPersonalInfoID:dbPersalInfo.personalInfoID];
                [dbPersonalData setResourceID:dbResID];
                [dbPersonalData setDataType:[NSNumber numberWithInt:USER_DATA_TYPE_IMG]];
                [[[CPSystemEngine sharedInstance] dbManagement] insertPersonalInfoData:dbPersonalData];
            }
        }
    }
}
-(CPDBModelResource *)getResPersonalDataWithCalssify:(NSInteger)classifyType
{
    CPDBModelPersonalInfoData *dbPersonalData = [[[CPSystemEngine sharedInstance] dbManagement] 
                                                 findPersonalInfoDataWithPersonalID:[NSNumber numberWithInt:1]
                                                                        andClassify:[NSNumber numberWithInt:classifyType]];
    if (dbPersonalData.resourceID)
    {
        return [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithID:dbPersonalData.resourceID];
    }
    return nil;
}
-(NSNumber *)addResourceByRecentWithUrl:(NSString *)url andDataType:(NSNumber *)dataType
{
    NSNumber *dbResID = nil;
    if (url&&![@"" isEqualToString:url]&&![url isEqual:[NSNull null]])
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.amr",[CoreUtils getUUID]]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/",[[[CPSystemEngine sharedInstance] accountModel] loginName]]];
        [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
        [dbRes setServerUrl:url];
        [dbRes setObjType:dataType];
        [dbRes setObjID:[NSNumber numberWithInt:1]];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
    }
    return dbResID;
}
-(NSNumber *)addResourceByRecentWithFilePath:(NSString *)filePath andDataType:(NSNumber *)dataType
{
    NSNumber *dbResID = nil;
    if (filePath&&![@"" isEqualToString:filePath]&&![filePath isEqual:[NSNull null]])
    {
        NSString *writeFileName = [NSString stringWithFormat:@"%@.amr",[CoreUtils getUUID]];
        BOOL isSave = NO;
        NSString *filePrefixPath = [NSString stringWithFormat:@"%@/",[[[CPSystemEngine sharedInstance] accountModel] loginName]];
        NSString *audioFilePath = [NSString stringWithFormat:@"%@/%@%@",[CoreUtils getDocumentPath],filePrefixPath,writeFileName];
        if ([audioFilePath length]>4)
        {
            NSString *filePrePath = [audioFilePath substringToIndex:audioFilePath.length-4];
            NSString *fileCafPath = [NSString stringWithFormat:@"%@.caf",filePrePath];
            isSave = [CoreUtils copyFileWithSrcPath:filePath andDstPath:fileCafPath];
            //cq bs   cs&ttw bbs
//            BOOL isTrans = NO;
            isSave = [CoreUtils convertPCM:fileCafPath toAMR:audioFilePath transType:CONVERT_PCM_TYPE_NO];
        }

        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:writeFileName];
        [dbRes setFilePrefix:filePrefixPath];
        [dbRes setMark:[NSNumber numberWithInt:MARK_UPLOAD]];
        [dbRes setType:dataType];
//        NSString *fileDstPath = [self getResourcePathWithRes:dbRes];
//        [CoreUtils copyFileWithSrcPath:filePath andDstPath:fileDstPath];
        [dbRes setObjType:dataType];
        [dbRes setObjID:[NSNumber numberWithInt:1]];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
    }
    return dbResID;
}
-(NSNumber *)addResourceByGroupMemHeaderWithServerUrl:(NSString *)serverUrl andGroupID:(NSNumber *)groupID
{
    NSNumber *dbResID = nil;
    if (serverUrl&&![@"" isEqualToString:serverUrl]&&![serverUrl isEqual:[NSNull null]])
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",[CoreUtils getUUID]]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/header/",[[[CPSystemEngine sharedInstance] accountModel] loginName]]];
        [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
        [dbRes setServerUrl:serverUrl];
        [dbRes setType:[NSNumber numberWithInt:RESOURCE_FILE_TYPE_IMG]];
        [dbRes setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_GROUPP_MEM_HEADER]];
        [dbRes setObjID:groupID];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
        
        CPDBModelResource *newDbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithID:dbResID];
        if ([newDbRes.mark integerValue]==MARK_DOWNLOAD)
        {
            [self downloadResWithRes:newDbRes];
        }
    }
    return dbResID;
}
-(NSNumber *)addResourceByTempHeaderWithServerUrl:(NSString *)serverUrl 
{
    NSNumber *dbResID = nil;
    if (serverUrl&&![@"" isEqualToString:serverUrl]&&![serverUrl isEqual:[NSNull null]])
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",[CoreUtils getUUID]]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/header/",[[[CPSystemEngine sharedInstance] accountModel] loginName]]];
        [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
        [dbRes setServerUrl:serverUrl];
        [dbRes setType:[NSNumber numberWithInt:RESOURCE_FILE_TYPE_IMG]];
        [dbRes setObjType:[NSNumber numberWithInt:RESOURCE_FILE_CP_TYPE_TEMP_IMG]];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
        
        CPDBModelResource *newDbRes = [[[CPSystemEngine sharedInstance] dbManagement] findResourceWithID:dbResID];
        if ([newDbRes.mark integerValue]==MARK_DOWNLOAD)
        {
            [self downloadResWithRes:newDbRes];
        }
    }
    return dbResID;
}
-(NSString *)getResourcePathWithPersonalData:(CPDBModelPersonalInfoData *)dbPersonalData
{
    if (dbPersonalData.resourceID)
    {
        CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] getResWithID:dbPersonalData.resourceID];
        if (dbRes&&dbRes.filePrefix&&dbRes.fileName)
        {
            NSString *documentPath = [NSString stringWithFormat:@"%@",[CoreUtils getDocumentPath]];
            return [NSString stringWithFormat:@"%@/%@%@",documentPath,dbRes.filePrefix,dbRes.fileName];
        }
    }
    return nil;
}
-(NSString *)getResourcePathWithResID:(NSNumber *)resID
{
    if (resID)
    {
        CPDBModelResource *dbRes = [[[CPSystemEngine sharedInstance] dbManagement] getResWithID:resID];
        if (dbRes&&dbRes.filePrefix&&dbRes.fileName)
        {
            NSString *documentPath = [NSString stringWithFormat:@"%@",[CoreUtils getDocumentPath]];
            return [NSString stringWithFormat:@"%@/%@%@",documentPath,dbRes.filePrefix,dbRes.fileName];
        }
    }
    return nil;
}
-(NSString *)getResourcePathWithRes:(CPDBModelResource *)dbRes
{
    if (dbRes&&dbRes.filePrefix&&dbRes.fileName)
    {
        NSString *documentPath = [NSString stringWithFormat:@"%@",[CoreUtils getDocumentPath]];
        return [NSString stringWithFormat:@"%@/%@%@",documentPath,dbRes.filePrefix,dbRes.fileName];
    }
    return nil;
}
-(void)updateResourceByFileSizeWithRes:(CPDBModelResource *)dbRes
{
    if (!dbRes)
    {
        return;
    }
    if (!dbRes.fileSize||[dbRes.fileSize intValue]==0)
    {
        NSString *filePath = [self getResourcePathWithRes:dbRes];
        NSNumber *fileSize = [CoreUtils getFileSizeWithName:filePath];
        [dbRes setFileSize:fileSize];
        [[[CPSystemEngine sharedInstance] dbManagement] updateResourceWithID:dbRes.resID obj:dbRes];
    }
}
-(void)addResourceByUserImgWithUrl:(NSString *)url andDataType:(NSNumber *)dataType andUserID:(NSNumber *)userID
{
    NSNumber *dbResID = nil;
    if (url&&![@"" isEqualToString:url]&&![url isEqual:[NSNull null]])
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.jpg",[CoreUtils getUUID]]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/header/",[[[CPSystemEngine sharedInstance] accountModel] loginName]]];
        [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
        [dbRes setServerUrl:url];
        [dbRes setObjID:userID];
        [dbRes setObjType:dataType];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
    }
    if (dbResID)
    {
        CPDBModelUserInfo *dbUserInfo = [[[CPSystemEngine sharedInstance] dbManagement] getUserInfoByCachedWithID:userID];
        if (dbUserInfo)
        {
            CPDBModelUserInfoData *oldDbUserData = [[[CPSystemEngine sharedInstance] dbManagement] findUserInfoDataWithUserID:dbUserInfo.userInfoID andClassify:dataType];
            if (oldDbUserData)
            {
                [oldDbUserData setResourceID:dbResID];
                [[[CPSystemEngine sharedInstance] dbManagement] updateUserInfoDataWithID:oldDbUserData.userInfoDataID obj:oldDbUserData];
            }
            else 
            {
                CPDBModelUserInfoData *dbUserData = [[CPDBModelUserInfoData alloc] init];
                [dbUserData setDataClassify:dataType];
                [dbUserData setUserInfoID:userID];
                [dbUserData setResourceID:dbResID];
                [dbUserData setDataType:[NSNumber numberWithInt:USER_DATA_TYPE_IMG]];
                [[[CPSystemEngine sharedInstance] dbManagement] insertUserInfoData:dbUserData];
            }
        }
    }
}
-(NSNumber *)addResourceByUserRecentWithUrl:(NSString *)url andDataType:(NSNumber *)dataType andUserID:(NSNumber *)userID
{
    NSNumber *dbResID = nil;
    if (url&&![@"" isEqualToString:url]&&![url isEqual:[NSNull null]])
    {
        CPDBModelResource *dbRes = [[CPDBModelResource alloc] init];
        [dbRes setFileName:[NSString stringWithFormat:@"%@.amr",[CoreUtils getUUID]]];
        [dbRes setFilePrefix:[NSString stringWithFormat:@"%@/header/",[[[CPSystemEngine sharedInstance] accountModel] loginName]]];
        [dbRes setMark:[NSNumber numberWithInt:MARK_DOWNLOAD]];
        [dbRes setServerUrl:url];
        [dbRes setObjType:dataType];
        [dbRes setObjID:userID];
        dbResID = [[[CPSystemEngine sharedInstance] dbManagement] insertResource:dbRes];
    }
    return dbResID;
}
@end
