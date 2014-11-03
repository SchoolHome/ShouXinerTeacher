//
//  BBCameraViewController.h
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//
// Transform values for full screen support:
#define CAMERA_TRANSFORM_X 1
// this works for iOS 4.x
#define CAMERA_TRANSFORM_Y 1.24299

#import "PalmViewController.h"



@interface BBCameraViewController : PalmViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    
    
    
}
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end
