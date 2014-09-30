//
//  VideoConfirmViewController.h
//  teacher
//
//  Created by ZhangQing on 14-9-27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBGroupModel.h"
#import "BBWSPViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoConfirmViewController : PalmViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
-(id)initWithVideoUrl:(NSURL *)url andType:(VIDEO_CHOOSEN_TYPE)type andGroupModel:(BBGroupModel *)groupModel;
@end
