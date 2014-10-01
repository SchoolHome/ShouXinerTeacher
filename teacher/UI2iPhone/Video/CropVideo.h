//
//  CropVideo.h
//  teacher
//
//  Created by singlew on 14-9-26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CropVideoModel.h"
#import "PalmUIManagement.h"

#define convertMpeg4IsSucess @"isSucess"
#define convertMpeg4FileSize @"fileSize"
#define convertMpeg4MediaTime @"mediaTime"

@interface CropVideo : NSObject
+(NSDictionary *) cropVideoByPath:(NSURL *) videoPath andSavePath:(NSString*) videoSavePath;
+(NSDictionary *)convertMpeg4WithUrl:(NSURL *)url andDstFilePath:(NSString *)dstFilePath;
+(NSNumber *)getFileSizeWithName:(NSString *)fileName;
@end
