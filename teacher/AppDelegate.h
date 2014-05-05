//
//  cn_ubox_schoolHomeAppDelegate.h
//  teacher
//
//  Created by singlew on 14-3-2.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomePageCheatView.h"
#import "BBUITabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>{
    UIImageView *loadingView;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) NSNumber *latestActiveTime;
@property (strong,nonatomic) UINavigationController * login_nav_c;
@property (strong,nonatomic) UINavigationController * verify_nav_c;
@property (strong,nonatomic) UINavigationController * ground_nav_c;
@property (strong,nonatomic) UINavigationController * guid_nav_c;

@property (nonatomic,strong) NSString *url;

-(void) launchLogin;
-(void) launchApp;

@end

