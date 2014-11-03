//
//  BBCameraViewController.m
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBCameraViewController.h"

#import "ZYQAssetPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "BBRecordViewController.h"
#import "ViewImageViewController.h"

@interface BBCameraViewController ()<ZYQAssetPickerControllerDelegate>
{
     UIButton *takePictureButton;
     UIButton *cancelButton;
    UIButton *recordButton;
    UIButton *flashBtn;
    UIButton *camerControl;
    UIButton *albumBtn;
}
@end

@implementation BBCameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    
    UIView *toolBarBG = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 52.f)];
    toolBarBG.backgroundColor = [UIColor blackColor];
    toolBarBG.alpha = 0.5f;
    [self.view addSubview:toolBarBG];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setFrame:CGRectMake(20.f, 10.f, 44.f, 32.f)];
    [close setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [close setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:close];
    
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setFrame:CGRectMake(self.screenWidth-100.f, 10.f, 44.f, 32.f)];
    [flashBtn setImage:[UIImage imageNamed:@"lamp_auto"] forState:UIControlStateNormal];
    [flashBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [flashBtn addTarget:self action:@selector(cameraTorchOn:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:flashBtn];
    
    camerControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [camerControl setFrame:CGRectMake(self.screenWidth-50.f, 10.f, 44.f, 32.f)];
    [camerControl setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [camerControl setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [camerControl addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
    [overlayView addSubview:camerControl];
    
    UIView *bottomBarBG = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.screenHeight-94.f, self.screenWidth, 94.f)];
    bottomBarBG.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomBarBG];
    
    takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePictureButton setFrame:CGRectMake(self.screenWidth/2-33, self.screenHeight-80.f,66.f , 66.f)];
    [takePictureButton setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [takePictureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [takePictureButton setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:takePictureButton];

    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setFrame:CGRectMake(30.f, CGRectGetMinY(takePictureButton.frame)+(CGRectGetHeight(takePictureButton.frame)-29)/2,40.f , 29.f)];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"small_record"] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:recordButton];
    
    albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn setFrame:CGRectMake(self.screenWidth-60.f, CGRectGetMinY(bottomBarBG.frame)+(CGRectGetHeight(bottomBarBG.frame)-40)/2,40.f , 40.f)];
    [albumBtn setBackgroundImage:[self getFirstImageInAlbum] forState:UIControlStateNormal];
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

- (UIImage *)getFirstImageInAlbum
{
    UIImage *image = nil;
    
    NSMutableArray *imageBox = [[NSMutableArray alloc] init];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        
        
        //NSLog(@"asset");
        CGImageRef iref;
        iref = [myasset thumbnail];

        //图片尺寸不能为0
        if(iref && CGImageGetWidth(iref) && CGImageGetHeight(iref))
        {
            [imageBox addObject:[UIImage imageWithCGImage:iref]];
            return ;
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror)
    {
        NSLog(@"failed");
        NSLog(@"cant get image -- %@",[myerror localizedDescription]);
    };
    
    image = [imageBox lastObject];
    return image;
}

#pragma mark -
#pragma mark Camera Actions
- (void)record
{
    BBRecordViewController *record = [[BBRecordViewController alloc] init];
    [self.navigationController pushViewController:record animated:NO];
}

//闪光灯
-(IBAction)cameraTorchOn:(id)sender{
    if (self.imagePickerController.cameraFlashMode ==UIImagePickerControllerCameraFlashModeAuto)
    {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [flashBtn setImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
    }else {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [flashBtn setImage:[UIImage imageNamed:@"lamp_off"] forState:UIControlStateNormal];
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
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 7;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

#pragma mark -
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    for (int i = 0; i<[assets count]; i++) {
        ALAsset *asset = [assets objectAtIndex:i];
        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
