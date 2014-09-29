//
//  VideoConfirmViewController.h
//  teacher
//
//  Created by ZhangQing on 14-9-27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
typedef enum
{
    VIDEO_TYPE_PHOTO = 1,
    VIDEO_TYPE_CARMER = 2
}VIDEO_CHOOSEN_TYPE;
@interface VideoConfirmViewController : PalmViewController
-(id)initWithVideoUrl:(NSURL *)url andType:(VIDEO_CHOOSEN_TYPE)type;
@end
