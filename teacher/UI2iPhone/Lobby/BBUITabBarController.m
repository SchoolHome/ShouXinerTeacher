//
//  BBUITabBarController.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBUITabBarController.h"

#import "BBBasePostViewController.h"
#import "BBPostHomeworkViewController.h"
#import "BBPostPBXViewController.h"
#import "BBCameraViewController.h"

#import "CPUIModelManagement.h"
#import "CustomNavigationController.h"
#import "CPDBManagement.h"
#import "BBMenuView.h"

@interface BBUITabBarController ()<MenuDelegate>

@end

@implementation BBUITabBarController

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"notiUnReadCount"]) {
        NSDictionary *dict = [PalmUIManagement sharedInstance].notiUnReadCount;
        NSLog(@"%@",dict);
        
        NSNumber *ct = dict[@"data"][@"count"];
        
        if ([ct intValue] == 0) {
            markYZS.hidden = YES;
        }else{
            markYZS.hidden = NO;
            markYZS.text = [NSString stringWithFormat:@"%d",[ct intValue]];
            CGFloat width = [markYZS.text sizeWithFont:[UIFont systemFontOfSize:14]
                                  constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
            if (width<17) {
                width = 20;
            }else{
                width = width + 8;
            }
            markYZS.frame = CGRectMake(320/5*4-16.f, -5, width, 20);
            [markYZS setNeedsDisplay];
        }
    }
    
    if ([keyPath isEqualToString:@"friendMsgUnReadedCount"]) {
        int count = [CPUIModelManagement sharedInstance].friendMsgUnReadedCount;
        count += [[[CPSystemEngine sharedInstance] dbManagement] allNotiUnreadedMessageCount];
        if (count <= 0) {
            markMessage.hidden = YES;
        }else{
            markMessage.hidden = NO;
            markMessage.text = [NSString stringWithFormat:@"%d",count];
            CGFloat width = [markYZS.text sizeWithFont:[UIFont systemFontOfSize:14]
                                     constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
            if (width<17) {
                width = 20;
            }else{
                width = width + 8;
            }
            markMessage.frame = CGRectMake(320/5*4-16.f, -5, width, 20);
            [markMessage setNeedsDisplay];
        }
    }
}

-(id)init{
    self = [super init];
    if (self) {
        //
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"friendMsgUnReadedCount" options:0 context:NULL];
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"notiUnReadCount" options:0 context:NULL];
    }
    return self;
}

-(void)checkUnreadCount{
    
    int time = 0;

    
    
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSString *key = [NSString stringWithFormat:@"check_yzs_unread_time_%@",account.uid];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSNumber *ts = [def objectForKey:key];
    if ([ts intValue]>0) {
        time = [ts intValue];
    }
    [[PalmUIManagement sharedInstance] getUnReadNotiCount:time];
    [self performSelector:@selector(checkUnreadCount) withObject:nil afterDelay:35.0f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    BBBJQViewController *c1 = [[BBBJQViewController alloc] init];
    CustomNavigationController *n1 = [[CustomNavigationController alloc] initWithRootViewController:c1];
    n1.tabBarItem.title = @"BJQ";
    
    BBZJZViewController *c2 = [[BBZJZViewController alloc] init];
    CustomNavigationController *n2 = [[CustomNavigationController alloc] initWithRootViewController:c2];
    n2.tabBarItem.title = @"ZJZ";

    UIViewController *c3 = [[UIViewController  alloc] init];
    CustomNavigationController *n3 = [[CustomNavigationController alloc] initWithRootViewController:c3];
    n3.tabBarItem.title = @"YZSS";
    
    BBYZSViewController *c4 = [[BBYZSViewController alloc] init];
    CustomNavigationController *n4 = [[CustomNavigationController alloc] initWithRootViewController:c4];
    n4.tabBarItem.title = @"YZS";
    
    BBMeViewController *c5 = [[BBMeViewController alloc] init];
    CustomNavigationController *n5 = [[CustomNavigationController alloc] initWithRootViewController:c5];
    n5.tabBarItem.title = @"ME";
    
    NSArray *ctrls = [NSArray arrayWithObjects:n1,n2,n3,n4,n5,nil];
    self.viewControllers = ctrls;
    self.tabBar.tintColor = [UIColor blackColor];
    self.selectedIndex = 0;
    self.delegate = (id<UITabBarControllerDelegate>)self;
    
    _imageTabBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
    _imageTabBar.image = [UIImage imageNamed:@"label_bg"];
    _imageTabBar.backgroundColor = [UIColor clearColor];
    
    [self.tabBar addSubview:_imageTabBar];
    [self.tabBar bringSubviewToFront:_imageTabBar];
    
    _tapImages = [[NSArray alloc] initWithObjects:
                  [UIImage imageNamed:@"class"],
                  [UIImage imageNamed:@"mes"],
                  [UIImage imageNamed:@"plus_bg"],
                  [UIImage imageNamed:@"find"],
                  [UIImage imageNamed:@"me"],
                  nil];
    NSArray *backImages = [[NSArray alloc] initWithObjects:
                  [UIImage imageNamed:@"class_gray"],
                  [UIImage imageNamed:@"mes_gray"],
                  [UIImage imageNamed:@"plus_bg"],
                  [UIImage imageNamed:@"find_gray"],
                  [UIImage imageNamed:@"me_gray"],
                  nil];
    
    NSInteger itemCount = [_tapImages count];
    for (int i = 0 ; i<itemCount; i++) {
        
        UIImageView *backItem = [[UIImageView alloc] initWithFrame:CGRectMake(320/itemCount*i, 0, 320/itemCount, 49)];
        [_imageTabBar addSubview:backItem];
        backItem.image = [backImages objectAtIndex:i];
        
        _subTabItem[i] = [[UIImageView alloc] initWithFrame:CGRectMake(320/itemCount*i, 0, 320/itemCount, 49)];
        _subTabItem[i].backgroundColor = [UIColor clearColor];
        [_imageTabBar addSubview:_subTabItem[i]];
        
        if (0 == i) {
            _subTabItem[i].image = [_tapImages objectAtIndex:i];
        }else{
            _subTabItem[i].image = nil;
        }
    }
    
    markYZS = [[UILabel alloc] initWithFrame:CGRectMake(320/itemCount*4-16.f, -5, 20, 20)];
    markYZS.font = [UIFont systemFontOfSize:14];
    [_imageTabBar addSubview:markYZS];
    markYZS.backgroundColor = [UIColor colorWithRed:252/255.0 green:79/255.0 blue:6/255.0 alpha:1.0];
    markYZS.textAlignment = NSTextAlignmentCenter;
    markYZS.textColor = [UIColor whiteColor];
    CALayer *roundedLayer1= [markYZS layer];
    [roundedLayer1 setMasksToBounds:YES];
    roundedLayer1.cornerRadius = 10.0;
    roundedLayer1.borderWidth = 0.5;
    roundedLayer1.borderColor = [[UIColor grayColor] CGColor];
    markYZS.text = @"";
    markYZS.hidden = YES;
    
    [self checkUnreadCount];
    
    markMessage = [[UILabel alloc] initWithFrame:CGRectMake(320/itemCount*2-16.f, -5, 20, 20)];
    markMessage.font = [UIFont systemFontOfSize:14];
    [_imageTabBar addSubview:markMessage];
    markMessage.backgroundColor = [UIColor colorWithRed:252/255.0 green:79/255.0 blue:6/255.0 alpha:1.0];
    markMessage.textAlignment = NSTextAlignmentCenter;
    markMessage.textColor = [UIColor whiteColor];
    CALayer *roundedLayer2= [markMessage layer];
    [roundedLayer2 setMasksToBounds:YES];
    roundedLayer2.cornerRadius = 10.0;
    roundedLayer2.borderWidth = 0.5;
    roundedLayer2.borderColor = [[UIColor grayColor] CGColor];
    markMessage.text = @"";
    markMessage.hidden = YES;
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController.tabBarItem.title isEqualToString:@"YZSS"]) {
        //展开view
        BBMenuView *menu = [[BBMenuView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height)];
        menu.delegate = self;
        [[UIApplication sharedApplication].keyWindow addSubview:menu];
        return NO;
    }
    return YES;
}

-(void) clickItemIndex : (ClickMenuItem) item{
    NSLog(@"%d",item);
    if (item == kPBXItem) {
//        BBPostPBXViewController *postPBX = [[BBPostPBXViewController alloc] initWithPostType:POST_TYPE_PBX];
        BBCameraViewController *camera = [[BBCameraViewController alloc] init];
        camera.hidesBottomBarWhenPushed = YES;
        [(UINavigationController *)self.selectedViewController pushViewController:camera animated:YES];
    }else
    {
        if (item == kHomeWorkItem) {
            BBPostHomeworkViewController *postHomeWork = [[BBPostHomeworkViewController alloc] initWithPostType:POST_TYPE_FZY];
            postHomeWork.hidesBottomBarWhenPushed = YES;
            [(UINavigationController *)self.selectedViewController pushViewController:postHomeWork animated:YES];
        }else{
            BBBasePostViewController *post = [[BBBasePostViewController alloc] initWithPostType:item == kNoticeItem ? POST_TYPE_FTZ : POST_TYPE_SBS];
            post.hidesBottomBarWhenPushed = YES;
            [(UINavigationController *)self.selectedViewController pushViewController:post animated:YES];
        }
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    for (int i = 0 ; i<[_tapImages count]; i++) {
        if (tabBarController.selectedIndex == i) {
            _subTabItem[i].image = [_tapImages objectAtIndex:i];
        }else{
            _subTabItem[i].image = nil;
        }
    }
    
    if (tabBarController.selectedIndex == 3) { // 点击消失
        markYZS.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{

    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"friendMsgUnReadedCount"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"notiUnReadCount"];
}

@end
