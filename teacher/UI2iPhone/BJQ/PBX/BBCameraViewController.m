//
//  BBCameraViewController.m
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBCameraViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "VideoConfirmViewController.h"
#import "ViewImageViewController.h"
@interface BBCameraViewController ()
{
     UIButton *takePictureButton;
     UIButton *cancelButton;
    UIButton *recordButton;
    UIButton *flashBtn;
    UIButton *camerControl;
    UIButton *albumBtn;
}

@property (nonatomic, retain) NSTimer *tickTimer;
@property (nonatomic, retain) NSTimer *cameraTimer;

- (void)done:(id)sender;
- (void)takePhoto:(id)sender;
- (void)startStop:(id)sender;
- (void)timedTakePhoto:(id)sender;
@end

@implementation BBCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setFrame:CGRectMake(10.f, 10,50.f, 30.f)];
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [close setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:close];
    
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setFrame:CGRectMake(self.screenWidth-100.f, 10.f, 60.f, 30.f)];
    [flashBtn setTitle:@"闪光灯" forState:UIControlStateNormal];
    [flashBtn addTarget:self action:@selector(cameraTorchOn:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:flashBtn];
    
    camerControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [camerControl setFrame:CGRectMake(self.screenWidth-40.f, 10.f, 40.f, 30.f)];
    [camerControl setTitle:@"方向" forState:UIControlStateNormal];
    [camerControl addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:camerControl];
    
    takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePictureButton setFrame:CGRectMake(self.screenWidth/2-30, self.screenHeight-120.f,60.f , 30.f)];
    [takePictureButton setTitle:@"拍照" forState:UIControlStateNormal];
    [takePictureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [takePictureButton setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:takePictureButton];

    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setFrame:CGRectMake(20.f, self.screenHeight-120.f,60.f , 30.f)];
    [recordButton setTitle:@"录像" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:recordButton];
    
    albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn setFrame:CGRectMake(self.screenWidth-90.f, self.screenHeight-120.f,60.f , 30.f)];
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(enterPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [albumBtn setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:albumBtn];

    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.showsCameraControls = NO;
    self.imagePickerController.navigationBarHidden = YES;
    
    CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
    CGRect newFrame = CGRectMake(0.0,
                                 CGRectGetHeight(overlayViewFrame) -
                                 self.view.frame.size.height - 10.0,
                                 CGRectGetWidth(overlayViewFrame),
                                 self.view.frame.size.height + 10.0);
    self.view.frame = newFrame;
    self.imagePickerController.cameraOverlayView = overlayView;

    [self.view addSubview:self.imagePickerController.view];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark -
#pragma mark Camera Actions
- (void)record
{
    VideoConfirmViewController *videoConfirm = [[VideoConfirmViewController alloc] init];
    [self.navigationController pushViewController:videoConfirm animated:NO];
}

//闪光灯
-(IBAction)cameraTorchOn:(id)sender{
    if (self.imagePickerController.cameraFlashMode ==UIImagePickerControllerCameraFlashModeAuto) {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    }else {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }
}

//前后摄像头
- (void)swapFrontAndBackCameras:(id)sender {
    if (self.imagePickerController.cameraDevice ==UIImagePickerControllerCameraDeviceRear ) {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}


- (void)takePhoto:(id)sender
{
    [self.imagePickerController takePicture];
}
- (void)enterPhotoAlbum:(id)sender {

    
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    


}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
}


@end
