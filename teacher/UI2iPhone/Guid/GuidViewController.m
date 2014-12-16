//
//  GuidViewController.m
//  teacher
//
//  Created by singlew on 14-6-6.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "GuidViewController.h"
#import "AppDelegate.h"
#import "CPUIModelManagement.h"

@interface GuidViewController ()
@property (nonatomic,strong) UIButton *button;
-(void) loadLogin:(id)sender;
@end

@implementation GuidViewController

-(id)init{
    self = [super init];
    if (self) {

    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0.0f, 0.0f, rx.size.width, rx.size.height);
    scrollView.contentSize = CGSizeMake(rx.size.width*3, rx.size.height);
    if(isIPhone6plus){
        for (int i = 1 ; i<=3; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f + (i-1) * rx.size.width, 0.0f, rx.size.width, rx.size.height)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d_6p",i]];
            [scrollView addSubview:image];
        }
    }else if(isIPhone6){
        for (int i = 1 ; i<=3; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f + (i-1) * rx.size.width, 0.0f, rx.size.width, rx.size.height)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d_6",i]];
            [scrollView addSubview:image];
        }
    }else if (isIPhone5) {
        for (int i = 1 ; i<=3; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f + (i-1) * rx.size.width, 0.0f, rx.size.width, rx.size.height)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d_5",i]];
            [scrollView addSubview:image];
        }
    }else{
        for (int i = 1 ; i<=3; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f + (i-1) * rx.size.width, 0.0f, 320.0f, 480.0f)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d_4",i]];
            [scrollView addSubview:image];
        }
    }
    
    float height = 70.0f;
    if (!isIPhone5) {
        height = 50.0f;
    }
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(rx.size.width*2.5-34, self.screenHeight - height, 68.f, 24.f)];
    [self.button setBackgroundImage:[UIImage imageNamed:@"begin"] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[UIImage imageNamed:@"begin"] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(loadLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:self.button];
    [self.view addSubview:scrollView];
}

-(void) loadLogin:(id)sender{
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view setAlpha:0.5f];
    }completion:^(BOOL finished){
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[CPSystemEngine sharedInstance] initSystem];
        CPUIModelManagement * model_management = [CPUIModelManagement sharedInstance];
        NSInteger sys_status_int = [model_management sysOnlineStatus];
        if(sys_status_int == SYS_STATUS_NO_ACTIVE){
            //        [self do_launch_verify];
        }else if(sys_status_int == SYS_STATUS_NO_LOGINED){
            //
            if ([[CPUIModelManagement sharedInstance] hasLoginUser]) {
                [appDelegate launchLogin]; // 非第一次登录
            }else{
                [appDelegate launchLogin];
            }
        }else{
            [appDelegate launchApp];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
