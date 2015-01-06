//
//  BBRecordViewController.m
//  teacher
//
//  Created by ZhangQing on 15/1/5.
//  Copyright (c) 2015年 ws. All rights reserved.
//

#define MIN_VIDEO_DUR 2.0f
#define MAX_VIDEO_DUR 15.0f
#define COUNT_DUR_TIMER_INTERVAL 0.2

#import "BBRecordViewController.h"
#import "BBPostPBXViewController.h"
#import "BBCameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVCaptureSession.h>

#import "BBRecordPreviewView.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface BBRecordViewController ()<AVCaptureFileOutputRecordingDelegate>
{
    NSInteger flashStatus;
    BOOL isEnteredBackground;
}

//UI
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *flashBtn;
@property (nonatomic, strong) UIButton *camerControl;
@property (nonatomic, strong) UIButton *takePictureBtn;
@property (nonatomic, strong) UILabel *timeCountDisplay;
@property (nonatomic, strong) BBRecordPreviewView *previewView;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (strong, nonatomic) NSTimer *countDurTimer;
@property (assign, nonatomic) CGFloat currentVideoDur;
@property (assign ,nonatomic) CGFloat totalVideoDur;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation BBRecordViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
    return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    flashStatus = 0;
    
    CGFloat height = IOS7? 0.f:-20.f;
    

    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setFrame:CGRectMake(20.f, 18.f, 44.f, 32.f)];
    [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [_closeBtn setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeBtn];
    
    _flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashBtn setFrame:CGRectMake(self.screenWidth-100.f, 18.f, 44.f, 32.f)];
    [_flashBtn setImage:[UIImage imageNamed:@"lamp_off"] forState:UIControlStateNormal];
    [_flashBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [_flashBtn addTarget:self action:@selector(controlFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashBtn];
    
    _camerControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [_camerControl setFrame:CGRectMake(self.screenWidth-50.f, 18.f, 44.f, 32.f)];
    [_camerControl setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [_camerControl setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [_camerControl addTarget:self action:@selector(controlCarmerDirection:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_camerControl];
    
    
    
    
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_recordBtn setFrame:CGRectMake(self.screenWidth/2-66/2, self.screenHeight-80.f+height,66.f , 66.f)];
    //    [recordBtn setFrame:CGRectMake(100, 50.f , 66.f,66.f)];
    
    [_recordBtn addTarget:self action:@selector(startVideoCapture:) forControlEvents:UIControlEventTouchUpInside];
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
    [_recordBtn setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_recordBtn];
    
    _takePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_takePictureBtn setFrame:CGRectMake(30.f, CGRectGetMinY(_recordBtn.frame)+(CGRectGetHeight(_recordBtn.frame)-29)/2,40.f , 29.f)];
    [_takePictureBtn setBackgroundImage:[UIImage imageNamed:@"small_camera"] forState:UIControlStateNormal];
    [_takePictureBtn addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    [_takePictureBtn setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_takePictureBtn];
    
    _timeCountDisplay = [[UILabel alloc] initWithFrame:CGRectMake(self.screenWidth/2-50, 42.f, 100.f, 22.f)];
    _timeCountDisplay.backgroundColor = [UIColor clearColor];
    _timeCountDisplay.textAlignment = NSTextAlignmentCenter;
    _timeCountDisplay.textColor = [UIColor whiteColor];
    _timeCountDisplay.font = [UIFont boldSystemFontOfSize:20.f];
    [self.view addSubview:_timeCountDisplay];
    _timeCountDisplay.hidden = YES;
    
    _previewView= [[BBRecordPreviewView alloc] initWithFrame:CGRectMake(0.f, self.screenHeight/2.f-120.f+height, 320.f, 240.f)];
    //_previewView.backgroundColor = [UIColor redColor];
    //_previewView= [[BBRecordPreviewView alloc] initWithFrame:.];
    //_previewView.layer.frame = CGRectMake(0.f, self.screenHeight/2.f-120.f+height, 320.f, 240.f);
    [self.view addSubview:_previewView];

    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    // Setup the preview view
    [[self previewView] setSession:session];
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)[self.previewView layer];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //[[self previewView].session setSessionPreset:AVCaptureSessionPreset640x480];
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [BBRecordViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                //setPreferredVideoStabilizationMode
                if (IOS8) {
                    [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
                }else
                {
                    if (IOS6)  [connection setEnablesVideoStabilizationWhenAvailable:YES];
                }
            [self setMovieFileOutput:movieFileOutput];
        }
        /*
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([session canAddOutput:stillImageOutput])
        {
            [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
            [session addOutput:stillImageOutput];
            [self setStillImageOutput:stillImageOutput];
        }
         */
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak BBRecordViewController *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            BBRecordViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                [[strongSelf recordBtn] setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
            });
        }]];
        [[self session] startRunning];
    });
    
    //[self.navigationController setNavigationBarHidden:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                [[self camerControl] setEnabled:NO];
                //[[self recordBtn] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
                [[self recordBtn] setBackgroundImage:[UIImage imageNamed:@"record_on"] forState:UIControlStateNormal];
                [[self recordBtn] setEnabled:NO];
            }
            else
            {
                [[self camerControl] setEnabled:YES];
                [[self recordBtn] setBackgroundImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
                [[self recordBtn] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
                [[self camerControl] setEnabled:YES];
                [[self recordBtn] setEnabled:YES];

            }
            else
            {
                [[self camerControl] setEnabled:NO];
                [[self recordBtn] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)startCountDurTimer
{
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    _timeCountDisplay.hidden = NO;
    
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}

- (void)onTimer:(NSTimer *)timer
{
    self.currentVideoDur += COUNT_DUR_TIMER_INTERVAL;
    
    self.timeCountDisplay.text = [NSString stringWithFormat:@"%2.f",15.00-_currentVideoDur];
    if (_totalVideoDur + _currentVideoDur >= MAX_VIDEO_DUR) {
        self.timeCountDisplay.text = [NSString stringWithFormat:@"%2.f",0.00];
        [[self movieFileOutput] stopRecording];
    }
    
    if (self.currentVideoDur > 2.f) {
        self.recordBtn.enabled = YES;
    }
}

- (void)receiveDidEnterBackground
{
    if ([[self movieFileOutput] isRecording]) {
        isEnteredBackground = YES;
    }
}

#pragma mark Actions
- (void)close
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)controlFlash:(UIButton *)sender
{
    NSInteger tempStatus = flashStatus;
    if (tempStatus != 2) {
        tempStatus++;
    }else tempStatus = 0;
    
    AVCaptureDevice *device = [[self videoDeviceInput] device];
    if ([device hasFlash] && [device isFlashModeSupported:tempStatus])
    {
        flashStatus = tempStatus;
        
        switch (flashStatus) {
            case 0:
                [_flashBtn setImage:[UIImage imageNamed:@"lamp_off"] forState:UIControlStateNormal];
                break;
            case 1:
                [_flashBtn setImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
                break;
            case 2:
                [_flashBtn setImage:[UIImage imageNamed:@"lamp_auto"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }

        [BBRecordViewController setFlashMode:AVCaptureFlashModeOn forDevice:device];
    }
}



- (void)startVideoCapture:(id)sender
{
    
    
    dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            //[[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            [[self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:(AVCaptureVideoOrientation)[UIDevice currentDevice].orientation];
            // Turning OFF flash for video recording
            [BBRecordViewController setFlashMode:flashStatus forDevice:[[self videoDeviceInput] device]];
            
            // Start recording to a temporary file.
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else
        {
            [self stopCountDurTimer];
            [[self movieFileOutput] stopRecording];
        }
    });
    
    [[self recordBtn] setEnabled:NO];
}

- (void)controlCarmerDirection:(id)sender
{
    [[self camerControl] setEnabled:NO];
    [[self recordBtn] setEnabled:NO];

    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [BBRecordViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [BBRecordViewController setFlashMode:flashStatus forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self camerControl] setEnabled:YES];
            [[self recordBtn] setEnabled:YES];
        });
    });
}

- (void)takePicture: (UIButton *)sender
{
    sender.enabled = NO;
    sleep(1.f);
    
    for (id viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[BBCameraViewController class]]) {
//            NSMutableArray *tempNavViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//            [tempNavViewControllers removeObject:viewController];
//            self.navigationController.viewControllers = tempNavViewControllers;
            [self.navigationController popToViewController:viewController animated:NO];
        }
    }
    
    BBCameraViewController *camera = [[BBCameraViewController alloc] init];
    camera.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:camera animated:NO];
}

- (void)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

#pragma mark File Output Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    
    self.currentVideoDur = 0.0f;
    [self startCountDurTimer];
    
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (error)
        NSLog(@"%@", error);
    
    NSMutableArray *navControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (id controller in navControllers) {
        if ([controller isKindOfClass:[BBPostPBXViewController class]]) {
            [navControllers removeObject:controller];
            [self.navigationController setViewControllers:[NSArray arrayWithArray:navControllers] animated:NO];
            break;
        }
    }
    
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    if (backgroundRecordingID != UIBackgroundTaskInvalid) [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    
    if (isEnteredBackground) {
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        BBPostPBXViewController *postVideoPBX = [[BBPostPBXViewController alloc] initWithPostType:POST_TYPE_PBX];
        postVideoPBX.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:postVideoPBX animated:YES];
        return;
    }
    
    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.

    
    BBPostPBXViewController *postVideoPBX = [[BBPostPBXViewController alloc] initWithPostType:POST_TYPE_PBX];
    postVideoPBX.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:postVideoPBX animated:YES];
    postVideoPBX.videoUrl = outputFileURL;
    [postVideoPBX showProgressWithText:@"正在压缩"];
    
    
    /*
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error)
            NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
     */
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}


#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"注意"
                                            message:@"手心没有权限使用你的相机, 请去隐私设置里更改"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}


@end
