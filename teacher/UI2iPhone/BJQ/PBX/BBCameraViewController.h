//
//  BBCameraViewController.h
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

@interface BBCameraViewController : PalmViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
    
}


@end
