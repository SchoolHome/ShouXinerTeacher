//
//  BBUITabBarController.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBUITabBarController.h"
#import "CPUIModelManagement.h"
#import "CustomNavigationController.h"
@interface BBUITabBarController ()

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
            markYZS.frame = CGRectMake(215, -5, width, 20);
            [markYZS setNeedsDisplay];
        }
    }
    
    if ([keyPath isEqualToString:@"friendMsgUnReadedCount"]) {
        int count = [CPUIModelManagement sharedInstance].friendMsgUnReadedCount;
        
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
            markMessage.frame = CGRectMake(136, -5, width, 20);
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
    
    BBYZSViewController *c3 = [[BBYZSViewController alloc] init];
    CustomNavigationController *n3 = [[CustomNavigationController alloc] initWithRootViewController:c3];
    n3.tabBarItem.title = @"YZS";
    
    BBMeViewController *c4 = [[BBMeViewController alloc] init];
    CustomNavigationController *n4 = [[CustomNavigationController alloc] initWithRootViewController:c4];
    n4.tabBarItem.title = @"ME";
    
    NSArray *ctrls = [NSArray arrayWithObjects:n1,n2,n3,n4,nil];
    self.viewControllers = ctrls;
    self.tabBar.tintColor = [UIColor blackColor];
    self.selectedIndex = 0;
    self.delegate = (id<UITabBarControllerDelegate>)self;
    
    _imageTabBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
    _imageTabBar.image = [UIImage imageNamed:@"BBBottomBG"];
    _imageTabBar.backgroundColor = [UIColor clearColor];
    
    [self.tabBar addSubview:_imageTabBar];
    [self.tabBar bringSubviewToFront:_imageTabBar];
    
    _tapImages = [[NSArray alloc] initWithObjects:
                  [UIImage imageNamed:@"BBBottomIndexPress1"],
                  [UIImage imageNamed:@"BBBottomIndexPress2"],
                  [UIImage imageNamed:@"BBBottomIndexPress3"],
                  [UIImage imageNamed:@"BBBottomIndexPress4"],
                  nil];
    NSArray *backImages = [[NSArray alloc] initWithObjects:
                  [UIImage imageNamed:@"BBBottomIndex1"],
                  [UIImage imageNamed:@"BBBottomIndex2"],
                  [UIImage imageNamed:@"BBBottomIndex3"],
                  [UIImage imageNamed:@"BBBottomIndex4"],
                  nil];
    
    
    for (int i = 0 ; i<[_tapImages count]; i++) {
        
        UIImageView *backItem = [[UIImageView alloc] initWithFrame:CGRectMake(320/4.0f*i, 0, 320/4.0f, 49)];
        [_imageTabBar addSubview:backItem];
        backItem.image = [backImages objectAtIndex:i];
        
        _subTabItem[i] = [[UIImageView alloc] initWithFrame:CGRectMake(320/4.0f*i, 0, 320/4.0f, 49)];
        _subTabItem[i].backgroundColor = [UIColor clearColor];
        [_imageTabBar addSubview:_subTabItem[i]];
        
        if (0 == i) {
            _subTabItem[i].image = [_tapImages objectAtIndex:i];
        }else{
            _subTabItem[i].image = nil;
        }
    }
    
    markYZS = [[UILabel alloc] initWithFrame:CGRectMake(215, -5, 20, 20)];
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
    
    markMessage = [[UILabel alloc] initWithFrame:CGRectMake(136, -5, 20, 20)];
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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{

    for (int i = 0 ; i<[_tapImages count]; i++) {
        if (tabBarController.selectedIndex == i) {
            _subTabItem[i].image = [_tapImages objectAtIndex:i];
        }else{
            _subTabItem[i].image = nil;
        }
    }
    
    if (tabBarController.selectedIndex == 2) { // 点击消失
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
