//
//  BBRecordViewController.h
//  teacher
//
//  Created by ZhangQing on 14-11-3.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureOutput.h>
@interface BBRecordViewController : PalmViewController

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preViewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

@end
