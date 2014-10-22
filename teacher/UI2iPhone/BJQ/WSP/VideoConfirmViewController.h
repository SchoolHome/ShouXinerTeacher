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
//#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoConfirmViewController : PalmViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

-(id)initWithGroupModel:(BBGroupModel *)groupModel;

@end
