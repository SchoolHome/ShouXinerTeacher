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
#import "CustomNavigationController.h"
#import <CoreLocation/CoreLocation.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>{
    UIImageView *loadingView;
    UIBackgroundTaskIdentifier taskID;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) NSNumber *latestActiveTime;
@property (strong,nonatomic) CustomNavigationController * login_nav_c;
@property (strong,nonatomic) CustomNavigationController * verify_nav_c;
@property (strong,nonatomic) CustomNavigationController * ground_nav_c;
@property (strong,nonatomic) CustomNavigationController * guid_nav_c;

@property (nonatomic,strong) NSString *url;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) NSInteger smsTime;
-(void) launchLogin;
-(void) launchApp;

@end

