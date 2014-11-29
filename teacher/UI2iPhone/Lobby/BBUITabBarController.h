//
//  BBUITabBarController.h
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBJQViewController.h"
#import "BBYZSViewController.h"
#import "BBMeViewController.h"
#import "BBZJZViewController.h"
#import "BBFXViewController.h"
@interface BBUITabBarController : UITabBarController
{

    UIImageView *_imageTabBar;
    UIImageView *_subTabItem[5];
    
    NSArray *_tapImages;
    
    
    UILabel *markMessage;
    UILabel *markYZS;
}

- (void)selectedItem:(NSInteger)itemIndex;

@end
