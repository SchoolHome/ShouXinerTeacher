//
//  BBSignModifyViewController.m
//  teacher
//
//  Created by mac on 14/11/14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBSignModifyViewController.h"
#import "BBProfileModel.h"
@interface BBSignModifyViewController ()
{
    UITextField *signField;
    BBProfileModel *userProfile;
}
@end

@implementation BBSignModifyViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"postUserInfoResult" options:0 context:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"postUserInfoResult"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
    [check setFrame:CGRectMake(0.f, 7.f, 44.f, 44.f)];
    [check setTitle:@"保存" forState:UIControlStateNormal];
    [check.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [check setTitleColor:[UIColor colorWithRed:0.984f green:0.392f blue:0.133f alpha:1.0f] forState:UIControlStateNormal];
    [check addTarget:self action:@selector(modifySign:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:check];
    
    userProfile = [BBProfileModel shareProfileModel];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 44)];
    [bgImageView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bgImageView];
    
    signField = [[UITextField alloc] initWithFrame:CGRectMake(10, 15, self.view.frame.size.width-20, 44)];
    [signField setTextColor:[UIColor colorWithRed:0.333f green:0.333f blue:0.333f alpha:1.0f]];
    if (userProfile.sign.length>0) {
        [signField setText:userProfile.sign];
    }else{
        [signField setPlaceholder:@"说点什么吧。"];
    }
    [signField setFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:signField];
}

-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)modifySign:(UIButton *)btn
{
    [self showProgressWithText:@"保存中，请稍后"];
    NSString *txtSign = @"";
    if (signField.text.length) {
        txtSign = signField.text;
    }
    [[PalmUIManagement sharedInstance] postUserInfo:nil withMobile:nil withVerifyCode:nil withPasswordOld:nil withPasswordNew:nil withSex:userProfile.sex withSign:txtSign];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"postUserInfoResult"]) {
        NSDictionary *resultDic = [[PalmUIManagement sharedInstance] postUserInfoResult];
        NSDictionary *errDic = resultDic[@"data"];
        if ([errDic[@"errno"] integerValue] == 0) {
            userProfile.sign = signField.text;
            [self showProgressWithText:@"保存成功" withDelayTime:2];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showProgressWithText:@"保存失败，请稍后再试" withDelayTime:2];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
