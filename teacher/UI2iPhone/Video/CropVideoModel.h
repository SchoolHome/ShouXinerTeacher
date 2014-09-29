//
//  CropVideoModel.h
//  teacher
//
//  Created by singlew on 14-9-29.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kCropVideoCompleted,
    kCropingVideo,
    KCropVideoError,
}CropVideoState;

@interface CropVideoModel : NSObject
@property (nonatomic) CropVideoState state;
@property (nonatomic,strong) NSString *error;
@end
