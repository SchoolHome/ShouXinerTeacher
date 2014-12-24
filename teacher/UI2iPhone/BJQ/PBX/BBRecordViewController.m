//
//  BBRecordViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-3.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define MIN_VIDEO_DUR 2.0f
#define MAX_VIDEO_DUR 15.0f
#define VIDEO_FOLDER @"Video"
#define COUNT_DUR_TIMER_INTERVAL 0.05

#import "BBRecordViewController.h"
#import "BBPostPBXViewController.h"
#import "BBCameraViewController.h"
@interface BBRecordViewController ()<AVCaptureFileOutputRecordingDelegate>
{
    UIButton *recordBtn;
    UIButton *closeBtn;
    UIButton *flashBtn;
    UIButton *camerControl;
    UIButton *takePictureBtn;
    UIView *localView;
    
    UILabel *timeCountDisplay;
    
}
@property (strong, nonatomic) NSTimer *countDurTimer;
@property (assign, nonatomic) CGFloat currentVideoDur;
@property (assign, nonatomic) NSURL *currentFileURL;
@property (assign ,nonatomic) CGFloat totalVideoDur;


@property (assign, nonatomic) BOOL isFrontCameraSupported;
@property (assign, nonatomic) BOOL isCameraSupported;
@property (assign, nonatomic) BOOL isTorchSupported;
@property (assign, nonatomic) BOOL isTorchOn;
@property (assign, nonatomic) BOOL isUsingFrontCamera;

@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@end
@implementation BBRecordViewController
- (id)init
{
    self = [super init];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    

    CGFloat height = IOS7? 0.f:-20.f;
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(20.f, 18.f, 44.f, 32.f)];
    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setFrame:CGRectMake(self.screenWidth-100.f, 18.f, 44.f, 32.f)];
    [flashBtn setImage:[UIImage imageNamed:@"lamp_off"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateSelected];
    [flashBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [flashBtn addTarget:self action:@selector(controlFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:flashBtn];
    
    camerControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [camerControl setFrame:CGRectMake(self.screenWidth-50.f, 18.f, 44.f, 32.f)];
    [camerControl setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [camerControl setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [camerControl addTarget:self action:@selector(controlCarmerDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:camerControl];
    


    
    recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setFrame:CGRectMake(self.screenWidth/2-66/2, self.screenHeight-80.f+height,66.f , 66.f)];
//    [recordBtn setFrame:CGRectMake(100, 50.f , 66.f,66.f)];

    [recordBtn addTarget:self action:@selector(startVideoCapture:) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    [recordBtn setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:recordBtn];
    
    takePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePictureBtn setFrame:CGRectMake(30.f, CGRectGetMinY(recordBtn.frame)+(CGRectGetHeight(recordBtn.frame)-29)/2,40.f , 29.f)];
    [takePictureBtn setBackgroundImage:[UIImage imageNamed:@"small_camera"] forState:UIControlStateNormal];
    [takePictureBtn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [takePictureBtn setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:takePictureBtn];
    
    timeCountDisplay = [[UILabel alloc] initWithFrame:CGRectMake(self.screenWidth/2-50, 42.f, 100.f, 22.f)];
    timeCountDisplay.backgroundColor = [UIColor clearColor];
    timeCountDisplay.textAlignment = NSTextAlignmentCenter;
    timeCountDisplay.textColor = [UIColor whiteColor];
    timeCountDisplay.font = [UIFont boldSystemFontOfSize:20.f];
    [self.view addSubview:timeCountDisplay];
    timeCountDisplay.hidden = YES;
    
    localView= [[UIView alloc] initWithFrame:CGRectMake(0.f, self.screenHeight/2.f-120.f+height, 320.f, 240.f)];
    [self.view addSubview:localView];
    self.preViewLayer.frame = CGRectMake(0.f, 0.f, 320.f, 240.f);
    [localView.layer addSublayer:self.preViewLayer];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:NO];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)initalize
{
    [self initCapture];
    
    self.totalVideoDur = 0.0f;
}

- (void)initCapture
{
    //session---------------------------------
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //input
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isCameraSupported = NO;
        return;
    } else {
        self.isCameraSupported = YES;
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:nil];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession addInput:audioDeviceInput];
    
    //output
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [_captureSession addOutput:_movieFileOutput];
    
    //preset
    _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    //preview layer------------------
    self.preViewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    
    _preViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    
    [_captureSession startRunning];
}

- (void)startCountDurTimer
{
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    timeCountDisplay.hidden = NO;
    recordBtn.enabled = NO;
}

- (void)onTimer:(NSTimer *)timer
{
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    
    timeCountDisplay.text = [NSString stringWithFormat:@"%2.f",15.00-_currentVideoDur];
    if (_totalVideoDur + _currentVideoDur >= MAX_VIDEO_DUR) {
        timeCountDisplay.text = [NSString stringWithFormat:@"%2.f",0.00];
        [self stopCurrentVideoRecording];
    }
    
    if (self.currentVideoDur > 2.f) {
        recordBtn.enabled = YES;
    }
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
    

}

- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _preViewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.preViewLayer;
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        
        for(AVCaptureInputPort *port in [self.videoDeviceInput ports]) {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    //    NSLog(@"focus point: %f %f", point.x, point.y);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [_videoDeviceInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
            }
            
            if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"对焦错误:%@", error);
        }
    });
}

- (void)hideToolsWhenRecording
{
//    flashBtn.hidden = YES;
//    camerControl.hidden = YES;
//    takePictureBtn.hidden = YES;
//    closeBtn.hidden = YES;
    camerControl.alpha = takePictureBtn.alpha = closeBtn.alpha = flashBtn.alpha = 0.f;
}

- (void)recoverToolWhenEndRecording
{
//    flashBtn.hidden = NO;
//    camerControl.hidden = NO;
//    takePictureBtn.hidden = NO;
//    closeBtn.hidden = NO;
    camerControl.alpha = takePictureBtn.alpha = closeBtn.alpha = flashBtn.alpha = 1.f;
}
#pragma mark - Orientation
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[self preViewLayer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - ButtonMethod
-(void)controlFlash:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self openTorch:sender.selected];
}

-(void)controlCarmerDirection:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {//换成前摄像头
        if (flashBtn.selected) {
            [self openTorch:NO];
            flashBtn.selected = NO;
            flashBtn.enabled = NO;
        } else {
            flashBtn.enabled = NO;
        }
    } else {
        flashBtn.enabled = [self isFrontCameraSupported];
    }
    
    [self switchCamera];
}

-(void)close
{
    [self.navigationController setNavigationBarHidden:NO];
    
    for (id controller in self.navigationController.viewControllers ) {
        if ([controller isKindOfClass:[BBPostPBXViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)startVideoCapture:(UIButton *)sender
{

    if (sender.selected) {
        [recordBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [self stopCurrentVideoRecording];
    }else
    {
        [recordBtn setBackgroundImage:[UIImage imageNamed:@"record_on"] forState:UIControlStateNormal];
        //[[self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[self.preViewLayer connection] videoOrientation]];
        [[self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:(AVCaptureVideoOrientation)[UIDevice currentDevice].orientation];
        
        //NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
        [self startRecordingToOutputFileURL:[NSURL fileURLWithPath:[self getTempSaveVideoPath]]];
        [self.view bringSubviewToFront:localView];
    }
    sender.selected = !sender.selected;
}

- (void)takePicture
{
    NSLog(@"%@",self.navigationController.viewControllers);
    for (id viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[BBCameraViewController class]]) {
            [self.navigationController popToViewController:(BBCameraViewController *)viewController animated:NO];
            return;
        }
    }
    
    BBCameraViewController *camera = [[BBCameraViewController alloc] init];
    [self.navigationController pushViewController:camera animated:NO];
}

#pragma mark - Method
- (void)focusInPoint:(CGPoint)touchPoint
{
    CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:touchPoint];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}



- (void)openTorch:(BOOL)open
{
    self.isTorchOn = open;
    if (!_isTorchSupported) {
        return;
    }
    
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

- (void)switchCamera
{
    if (!_isFrontCameraSupported || !_isCameraSupported || !_videoDeviceInput) {
        return;
    }
    
    if (_isTorchOn) {
        [self openTorch:NO];
    }
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *device = [self getCameraDevice:_isUsingFrontCamera];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    [_captureSession addInput:_videoDeviceInput];
    [_captureSession commitConfiguration];
}

- (BOOL)isTorchSupported
{
    return _isTorchSupported;
}

- (BOOL)isFrontCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported
{
    return _isFrontCameraSupported;
}



//总时长
- (CGFloat)getTotalVideoDuration
{
    return _totalVideoDur;
}


- (void)startRecordingToOutputFileURL:(NSURL *)fileURL
{
    if (_totalVideoDur >= MAX_VIDEO_DUR) {
        NSLog(@"视频总长达到最大");
        return;
    }
    //隐藏多余控制
    [UIView animateWithDuration:0.3f animations:^{
        [self hideToolsWhenRecording];
    }];
    
    [_movieFileOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
}

- (void)stopCurrentVideoRecording
{
    [self stopCountDurTimer];
    //[self recoverToolWhenEndRecording];
    [_movieFileOutput stopRecording];
}


#pragma mark - AVCaptureFileOutputRecordignDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    self.currentFileURL = fileURL;
    
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    self.totalVideoDur += _currentVideoDur;
    NSLog(@"本段视频长度: %f", _currentVideoDur);
    NSLog(@"现在的视频总长度: %f", _totalVideoDur);
    
    //    BBWSPViewController *wsp = [[BBWSPViewController alloc] initWithVideoUrl:outputFileURL andType:VIDEO_TYPE_CARMER andGroupModel:model];
    //    [self.navigationController pushViewController:wsp animated:YES];
    NSMutableArray *navControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (id controller in navControllers) {
        if ([controller isKindOfClass:[BBPostPBXViewController class]]) {
            [navControllers removeObject:controller];
            [self.navigationController setViewControllers:[NSArray arrayWithArray:navControllers] animated:NO];
            break;
        }
    }
    
    BBPostPBXViewController *postVideoPBX = [[BBPostPBXViewController alloc] initWithPostType:POST_TYPE_PBX];
    postVideoPBX.videoUrl = outputFileURL;
    [self.navigationController pushViewController:postVideoPBX animated:YES];
    [postVideoPBX showProgressWithText:@"正在压缩"];
}

-(NSString *)getTempSaveVideoPath
{
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *savePath = [documentsDirectory stringByAppendingFormat:@"/%@/temp.mp4",account.loginName];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:savePath]) {
        [filemanager removeItemAtPath:savePath error:nil];
    }
    return savePath;
}

#pragma mark - AppDelegate
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"DidBecomeActive");
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"WillResignActive");
}
@end
