//
//  BBMeProfileController.h
//  teacher
//
//  Created by mac on 14-3-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PalmViewController.h"
#import "BBProfileModel.h"

@interface BBMeProfileController : PalmViewController
{
    UITableView *profileTableView;
    NSArray *listData;
}
@end
