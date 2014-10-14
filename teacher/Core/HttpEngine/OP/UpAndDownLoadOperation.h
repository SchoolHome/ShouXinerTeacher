//
//  UpAndDownLoadOperation.h
//  teacher
//
//  Created by singlew on 14-10-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//


typedef enum{
    kUploadVideo,
    kDownVideo,
}UpAndDownLoadType;


#import "PalmOperation.h"

@interface UpAndDownLoadOperation : PalmOperation
-(UpAndDownLoadOperation *) initUpdateUserVideoFile : (NSURL *) videoUrl withGroupID : (int) groupID;
-(UpAndDownLoadOperation *) initDownLoadUserVideoFile : (NSString *) videoUrl withKey : (NSString *) key;
@end
