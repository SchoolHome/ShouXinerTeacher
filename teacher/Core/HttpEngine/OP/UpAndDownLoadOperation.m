//
//  UpAndDownLoadOperation.m
//  teacher
//
//  Created by singlew on 14-10-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "UpAndDownLoadOperation.h"
#import "CPHttpEngineConst.h"
#import "PalmUIManagement.h"
#import "CoreUtils.h"
#import "NSString+MKNetworkKitAdditions.h"

@interface UpAndDownLoadOperation ()
@property (nonatomic) UpAndDownLoadType type;
@property (nonatomic,strong) NSString* filePath;
-(void) uploadVideo;
-(void) downloadVideo;
@end

@implementation UpAndDownLoadOperation
-(UpAndDownLoadOperation *) initUpdateUserVideoFile : (NSURL*) videoUrl withGroupID : (int) groupID{
    if ([self initOperation]) {
        self.type = kUploadVideo;
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        self.filePath = [videoUrl path];
//        NSString *writeFileName = [NSString stringWithFormat:@"%@.%@",[CoreUtils getUUID],@".mp4"];
//        BOOL isSave = NO;
//        NSString *filePath = [NSString stringWithFormat:@"%@/msg/",account.loginName];
//        [CoreUtils createPath:filePath];
//        isSave = [CoreUtils writeToFileWithData:imageData file_name:writeFileName andPath:filePath];
//        self.fileName = [NSString stringWithFormat:@"%@/%@%@",[CoreUtils getDocumentPath],filePath,writeFileName];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/attachment/put/open/2/%@/%d",K_HOST_NAME_OF_PALM_UPLOAD,account.uid,groupID];
        [self setHttpRequestPostWithUrl:urlStr params:nil];
    }
    return self;
}

-(UpAndDownLoadOperation *) initDownLoadUserVideoFile : (NSString *) videoUrl withKey : (NSString *) key{
    if ([self initOperation]) {
        self.type = kDownVideo;
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSString *writeFileName = [NSString stringWithFormat:@"%@.%@",key,@".mp4"];
        NSString *fileDir = [NSString stringWithFormat:@"%@/Video/",account.loginName];
        [CoreUtils createPath:fileDir];
        self.filePath = [NSString stringWithFormat:@"%@/%@%@",[CoreUtils getDocumentPath],fileDir,writeFileName];
        [self setHttpRequestGetWithUrl:videoUrl];
    }
    return self;
}

-(void) uploadVideo{
    [self.dataRequest setFile:self.filePath withFileName:[self.filePath lastPathComponent] andContentType:@"video/mp4" forKey:@"file"];
    self.dataRequest.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid,[PalmUIManagement sharedInstance].php, nil];
    [self.dataRequest setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].uploadVideoResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) downloadVideo{
    [self.request setDownloadDestinationPath:self.filePath];
    self.request.requestCookies = [[NSMutableArray alloc] initWithObjects:[PalmUIManagement sharedInstance].suid,[PalmUIManagement sharedInstance].php, nil];
    [self.request setRequestCompleted:^(NSDictionary *data){
        dispatch_block_t updateTagBlock = ^{
            [PalmUIManagement sharedInstance].downloadVideoResult = data;
        };
        dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    }];
    [self startAsynchronous];
}

-(void) main{
    switch (self.type) {
        case kUploadVideo:
            [self uploadVideo];
            break;
        case kDownVideo:
            [self downloadVideo];
            break;
        default:
            break;
    }
}
@end
