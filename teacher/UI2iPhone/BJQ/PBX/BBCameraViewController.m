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
#import "BBPostPBXViewController.h"
#import "BBImagePreviewVIewController.h"

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

    
    _flashStatus = 0;
    
    //self.view.backgroundColor = [UIColor clearColor];
    CGFloat height = -20.f;
    if (IOS7) {
        height = 0.f;
    }
    
    UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
    
    UIView *toolBarBG = [[UIView alloc] initWithFrame:CGRectMake(0.f, height, self.screenWidth, 60.f)];
    toolBarBG.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5f];
    [overlayView addSubview:toolBarBG];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setFrame:CGRectMake(20.f, 18.f, 44.f, 32.f)];
    [close setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [close setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [toolBarBG addSubview:close];
    
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setFrame:CGRectMake(self.screenWidth-100.f, 18.f, 44.f, 32.f)];
    [flashBtn setImage:[UIImage imageNamed:@"lamp_auto"] forState:UIControlStateNormal];
    [flashBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [flashBtn addTarget:self action:@selector(cameraTorchOn:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarBG addSubview:flashBtn];
    
    camerControl = [UIButton buttonWithType:UIButtonTypeCustom];
    [camerControl setFrame:CGRectMake(self.screenWidth-50.f, 18.f, 44.f, 32.f)];
    [camerControl setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
    [camerControl setImageEdgeInsets:UIEdgeInsetsMake(5.f, 10.f, 5.f, 10.f)];
    [camerControl addTarget:self action:@selector(swapFrontAndBackCameras:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarBG addSubview:camerControl];
    
    UIView *bottomBarBG = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.screenHeight-100.f, self.screenWidth, 100.f)];
    bottomBarBG.backgroundColor = [UIColor blackColor];
    [overlayView addSubview:bottomBarBG];
    
    takePictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takePictureButton setFrame:CGRectMake(self.screenWidth/2-33,(CGRectGetHeight(bottomBarBG.frame)-74)/2 ,66.f , 66.f)];
    [takePictureButton setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [takePictureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarBG addSubview:takePictureButton];

    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setFrame:CGRectMake(30.f, CGRectGetMinY(takePictureButton.frame)+(CGRectGetHeight(takePictureButton.frame)-32)/2,40.f , 29.f)];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"small_record"] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton setBackgroundColor:[UIColor blackColor]];
    [bottomBarBG addSubview:recordButton];
    
    albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn setFrame:CGRectMake(self.screenWidth-60.f, CGRectGetMinY(bottomBarBG.frame)+(CGRectGetHeight(bottomBarBG.frame)-42)/2,40.f , 40.f)];
    [albumBtn addTarget:self action:@selector(enterPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [albumBtn setBackgroundColor:[UIColor blackColor]];
    [overlayView addSubview:albumBtn];

    [self getFirstImageInAlbum];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    self.imagePickerController.showsCameraControls = NO;
    self.imagePickerController.navigationBarHidden = YES;
    self.imagePickerController.cameraFlashMode = (UIImagePickerControllerCameraFlashMode)self.flashStatus;
    
    CGRect overlayViewFrame = self.imagePickerController.cameraOverlayView.frame;
    //CGRectGetHeight(overlayViewFrame) -self.view.frame.size.height
    CGRect newFrame = CGRectMake(0.0,
                                  0,
                                 CGRectGetWidth(overlayViewFrame),
                                 self.view.frame.size.height);
    self.view.frame = newFrame;
    self.imagePickerController.cameraOverlayView = overlayView;

    [self.view addSubview:self.imagePickerController.view];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    BOOL pbxVCExist = NO;
    for (id controller in self.navigationController.viewControllers ) {
        if ([controller isKindOfClass:[BBPostPBXViewController class]]) {
            pbxVCExist = YES;
        }
    }
    
    if (!pbxVCExist) {
        NSMutableArray *tempNavViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        
        BBPostPBXViewController *postPBX = [[BBPostPBXViewController alloc] initWithImages:nil];
        postPBX.hidesBottomBarWhenPushed = YES;
        [tempNavViewControllers insertObject:postPBX atIndex:self.navigationController.viewControllers.count-1];
        self.navigationController.viewControllers = tempNavViewControllers;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES];
    
    recordButton.enabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //[self.navigationController setNavigationBarHidden:NO];
    
    
}

- (void )getFirstImageInAlbum
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *assetsLibrary;
        NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:1];
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result && index == group.numberOfAssets-1) {
                        NSLog(@"%@",result);
                        [imageArray addObject:[UIImage imageWithCGImage: result.thumbnail]];
                        *stop = YES;
                    }
                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageArray.count) {
                        *stop = YES;
                        [albumBtn setBackgroundImage:imageArray[0] forState:UIControlStateNormal];
                    }
                });

                
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Group not found!\n");
        }];
    });
 
    
}

#pragma mark -
#pragma mark Camera Actions
- (void)record: (UIButton *)sender
{
    sender.enabled = NO;
    
    for (id viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[BBRecordViewController class]]) {
            NSMutableArray *tempNavViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [tempNavViewControllers removeObject:viewController];
            self.navigationController.viewControllers = tempNavViewControllers;
            break;
        }
    }
   
    [self.imagePickerController.view removeFromSuperview];
    //sleep(1.f);
    BBRecordViewController *record = [[BBRecordViewController alloc] init];
    [self.navigationController pushViewController:record animated:NO];

}

//闪光灯
-(IBAction)cameraTorchOn:(id)sender{
    if (![UIImagePickerController isFlashAvailableForCameraDevice:self.imagePickerController.cameraDevice]) {
        return;
    }
    
    if (_flashStatus != 1) {
        _flashStatus++;
    }else _flashStatus = -1;

    switch (_flashStatus) {
        case UIImagePickerControllerCameraFlashModeOff:
            [flashBtn setImage:[UIImage imageNamed:@"lamp_off"] forState:UIControlStateNormal];\
            _flashStatus = UIImagePickerControllerCameraFlashModeOff;
            break;
        case UIImagePickerControllerCameraFlashModeAuto:
            [flashBtn setImage:[UIImage imageNamed:@"lamp_auto"] forState:UIControlStateNormal];
            _flashStatus = UIImagePickerControllerCameraFlashModeAuto;
            break;
        case UIImagePickerControllerCameraFlashModeOn:
            [flashBtn setImage:[UIImage imageNamed:@"lamp"] forState:UIControlStateNormal];
            _flashStatus = UIImagePickerControllerCameraFlashModeOn;
            break;
        default:
            break;
    }
    self.imagePickerController.cameraFlashMode = (UIImagePickerControllerCameraFlashMode)self.flashStatus;
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
    picker.maximumNumberOfSelection = 9;
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

-(void)close
{
    for (id controller in self.navigationController.viewControllers ) {
        if ([controller isKindOfClass:[BBPostPBXViewController class]]) {
            [self.navigationController popToViewController:controller animated:YES];
            return;
        }
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    NSMutableArray *tempImages = [[NSMutableArray alloc] initWithCapacity:7];
    for (int i = 0; i<[assets count]; i++) {
        ALAsset *asset = [assets objectAtIndex:i];
        UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        [tempImages addObject:image];
    }
    
    if (tempImages.count > 0) {
        BBPostPBXViewController  *postPBX = [[BBPostPBXViewController alloc] initWithImages:tempImages];
        [self.navigationController pushViewController:postPBX animated:YES];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self dismissModalViewControllerAnimated:YES];
    
    BBImagePreviewVIewController *imagePreview = [[BBImagePreviewVIewController  alloc] initWithPreviewImage:image];
    [self.navigationController pushViewController:imagePreview animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    
}


@end
