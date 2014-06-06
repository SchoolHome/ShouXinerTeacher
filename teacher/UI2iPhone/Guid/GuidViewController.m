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
    UIImageView *bgImage = [[UIImageView alloc] init];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    
    if (isIPhone5) {
        bgImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, 568.0f);
        bgImage.image = [UIImage imageNamed:@"bgs"];
        scrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 568.0f);
        scrollView.contentSize = CGSizeMake(320.0f * 3, 568.0f);
        for (int i = 1 ; i<=3; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f + (i-1) * 320.0f, 0.0f, 320.0f, 568.0f)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ds",i]];
            [scrollView addSubview:image];
        }
    }else{
        bgImage.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
        bgImage.image = [UIImage imageNamed:@"bg"];
        scrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
        scrollView.contentSize = CGSizeMake(320.0f * 3, 480.0f);
        for (int i = 1 ; i<=3; i++) {
            UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f + (i-1) * 320.0f, 0.0f, 320.0f, 480.0f)];
            image.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
            [scrollView addSubview:image];
        }
    }
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(640.0f + 87.5, self.screenHeight - 120.0f, 145.0f, 32.0f)];
    [self.button setBackgroundImage:[UIImage imageNamed:@"begin"] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[UIImage imageNamed:@"begin"] forState:UIControlStateHighlighted];
    [self.button addTarget:self action:@selector(loadLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    bgImage.userInteractionEnabled = YES;
    scrollView.pagingEnabled = YES;
    [scrollView addSubview:self.button];
    [self.view addSubview:bgImage];
    [self.view addSubview:scrollView];
}

-(void) loadLogin:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
