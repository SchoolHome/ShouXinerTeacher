////
////  cn_ubox_schoolHomeAppDelegate.m
////  teacher
////
////  Created by singlew on 14-3-2.
////  Copyright (c) 2014年 ws. All rights reserved.
////


#import "AppDelegate.h"
#import "CPSystemEngine.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"
#import "CPLGModelAccount.h"

#import "LoginViewController.h"
#import "Login.h"
#import "RegistFirstViewController.h"
#import "RegistViewController.h"
//#import "VerifyViewCodeController.h"
#import "Guid07ViewController.h"
#import "FanxerHeader.h"

#import "HomePageViewController.h"
#import "AudioRouteChange.h"
#import "AlarmClockHelper.h"
#import "HPStatusBarTipView.h"
#import "MediaStatusManager.h"
#import "CoreUtils.h"
#import <Crashlytics/Crashlytics.h>
#import "GuidViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize login_nav_c = _login_nav_c;
@synthesize verify_nav_c = _verify_nav_c;
@synthesize ground_nav_c = _ground_nav_c;
@synthesize guid_nav_c = _guid_nav_c;
@synthesize latestActiveTime = _latestActiveTime;

- (void)do_clear_controllers{     // 清除多余的controller，用于退出登录。。。
    for (UIView *aView in [self.window subviews]) {
        [aView removeFromSuperview];
    }
    self.ground_nav_c = nil;
}

- (void)launchLogin{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self do_clear_controllers];
    Login * login_c_temp = [[Login alloc] init];
    UINavigationController * login_nav_c_temp = [[UINavigationController alloc] initWithRootViewController:login_c_temp];
    [login_nav_c_temp setNavigationBarHidden:YES];
    self.login_nav_c = login_nav_c_temp;
    login_nav_c_temp = nil;
    login_c_temp = nil;
    [self.window addSubview:self.login_nav_c.view];
}

- (void)launchApp{
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self do_clear_controllers];
    for (UIView *aView in [self.window subviews]) {
        [aView removeFromSuperview];
    }
    BBUITabBarController *tab = [[BBUITabBarController alloc] init];
    self.window.rootViewController = tab;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    CPLogInfo(@"launchOptions %@",launchOptions);
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"checkVersion" options:0 context:nil];
    [Crashlytics startWithAPIKey:@"fb92e12c5ee94966ce5c9aaaa0376675d7f4ca07"];
    UIImage *image = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        image = [UIImage imageNamed:@"navbar_back"];
    }else{
        image = [UIImage imageNamed:@"navBarBg44"];
    }
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,[UIFont boldSystemFontOfSize:18],UITextAttributeFont, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Configure logging framework
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[CPSystemEngine sharedInstance] initSystem];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSString *guidVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"guidVersion"];
    if (guidVersion == nil || ![guidVersion isEqualToString:GuidVersion]) {
        [self do_clear_controllers];
        GuidViewController * guid = [[GuidViewController alloc] init];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:guid];
        [nav setNavigationBarHidden:YES];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
        [[NSUserDefaults standardUserDefaults] setObject:GuidVersion forKey:@"guidVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    
    CPUIModelManagement * model_management = [CPUIModelManagement sharedInstance];
    NSInteger sys_status_int = [model_management sysOnlineStatus];
    if(sys_status_int == SYS_STATUS_NO_ACTIVE){
//        [self do_launch_verify];
    }else if(sys_status_int == SYS_STATUS_NO_LOGINED){
        //
        if ([[CPUIModelManagement sharedInstance] hasLoginUser]) {
            [self launchLogin]; // 非第一次登录
        }else{
            [self launchLogin];
        }
    }else{
        [self launchApp];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"checkVersion"]) {
        NSDictionary *result = [PalmUIManagement sharedInstance].checkVersion;
        result = result[@"data"];
        if (result != nil) {
            BOOL recommend = [result[@"recommend"] boolValue];
            BOOL force = [result[@"force"] boolValue];
//            NSString *version = result[@"version"];
            self.url = result[@"url"];
            
            if (!recommend && !force) {
                return;
            }else if(recommend && !force){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有更新" message:@"有新版本更新" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [alert show];
            }else if(recommend && force){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有更新" message:@"有新版本更新" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (![self.url isEqualToString:@""] && self.url != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application{
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [[CPUIModelManagement sharedInstance] sysInActive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    [self setLatestActiveTime:[CoreUtils getLongFormatWithNowDate]];
    [[CPUIModelManagement sharedInstance] sysActive];
    [[PalmUIManagement sharedInstance] userLoginToken];
//    [[PalmUIManagement sharedInstance] postCheckVersion];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [self setLatestActiveTime:[CoreUtils getLongFormatWithNowDate]];
    // 还原播放控制
    [[MediaStatusManager sharedInstance] resetStatus];
    [[CPSystemEngine sharedInstance] xmppReconnect];
    [[PalmUIManagement sharedInstance] postCheckVersion];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    [[CPUIModelManagement sharedInstance] sysInActive];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken{
    [[CPUIModelManagement sharedInstance] uploadDeviceToken:devToken];
	CPLogInfo(@"devToken[%@], len=%d", devToken, [devToken length]);
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    CPLogInfo(@"userInfo  %@",userInfo);
    NSNumber *nowTime = [CoreUtils getLongFormatWithNowDate];
    int gap = [nowTime integerValue] - [self.latestActiveTime integerValue];
    if (gap <=1000){
        [self.ground_nav_c popToRootViewControllerAnimated:YES]; //统一到首页
    }
    application.applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    CPLogInfo(@"%@",error);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    CPLogInfo(@"");
}
@end
