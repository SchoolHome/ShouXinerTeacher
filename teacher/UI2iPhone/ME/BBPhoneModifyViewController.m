//
//  BBPhoneModifyViewController.m
//  teacher
//
//  Created by mac on 14/11/14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBPhoneModifyViewController.h"
#import "BBProfileModel.h"
#import "AppDelegate.h"
@interface BBPhoneModifyViewController ()
{
    UITextField *phoneField;
    UITextField *codeField;
    UIButton *getCodeBtn;
    NSTimer *restTimer;
}
@end

@implementation BBPhoneModifyViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"postUserInfoResult" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"smsVerifyCode" options:0 context:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"postUserInfoResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"smsVerifyCode"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:@"绑定手机"];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
    [check setFrame:CGRectMake(0.f, 7.f, 44.f, 44.f)];
    [check setTitle:@"确认" forState:UIControlStateNormal];
    [check.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [check setTitleColor:[UIColor colorWithRed:0.984f green:0.392f blue:0.133f alpha:1.0f] forState:UIControlStateNormal];
    [check addTarget:self action:@selector(modifySign:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:check];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, self.view.frame.size.width, 89)];
    [bgImageView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bgImageView];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 80, 44)];
    [title setTextAlignment:NSTextAlignmentRight];
    [title setText:@"手机号码"];
    [title setFont:[UIFont boldSystemFontOfSize:14]];
    [self.view addSubview:title];
    title = nil;
    phoneField = [[UITextField alloc] initWithFrame:CGRectMake(85, 15, self.view.frame.size.width-95, 44)];
    [phoneField setPlaceholder:[PalmUIManagement sharedInstance].loginResult.mobile];
    [phoneField setFont:[UIFont systemFontOfSize:14]];
    [phoneField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:phoneField];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 80, 44)];
    [title setTextAlignment:NSTextAlignmentRight];
    [title setText:@"验证码"];
    [title setFont:[UIFont boldSystemFontOfSize:14]];
    [self.view addSubview:title];
    title = nil;
    codeField = [[UITextField alloc] initWithFrame:CGRectMake(85, 60, self.view.frame.size.width-200, 44)];
    [codeField setPlaceholder:@"请输入验证码"];
    [codeField setFont:[UIFont systemFontOfSize:14]];
    [codeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.view addSubview:codeField];
    
    getCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeBtn setFrame:CGRectMake(self.view.frame.size.width-90, 67, 80, 30)];
    [getCodeBtn setImage:[UIImage imageNamed:@"obtain_code.png"] forState:UIControlStateNormal];
    [getCodeBtn.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
    [getCodeBtn addTarget:self action:@selector(getVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getCodeBtn];
}

-(void)getVerifyCode:(UIButton *)btn
{
    if (phoneField.text.length > 0) {
        if ([self verifyMobile:phoneField.text]) {
            [getCodeBtn setBackgroundColor:[UIColor grayColor]];
            [getCodeBtn setImage:nil forState:UIControlStateNormal];
            [getCodeBtn setUserInteractionEnabled:NO];
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            delegate.smsTime = 120;
            [getCodeBtn setTitle:[NSString stringWithFormat:@"%d秒后重试", delegate.smsTime] forState:UIControlStateNormal];
            restTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(restTime:) userInfo:nil repeats:YES];
            [[PalmUIManagement sharedInstance] getSMSVerifyCode:phoneField.text];
        }else{
            [self showProgressWithText:@"请输入正确的手机号" withDelayTime:2];
        }
    }else{
        [self showProgressWithText:@"请输入新手机号" withDelayTime:2];
    }
}

-(BOOL)verifyMobile:(NSString *)mobile
{
    NSString * MOBILE = @"^1\[0-9]{10}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if ([regextestmobile evaluateWithObject:mobile] == YES){
        return YES;
    }else{
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backViewController
{
    if (restTimer) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        delegate.smsTime = 120;
        [restTimer invalidate];
        restTimer = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)modifySign:(UIButton *)btn
{
    if (phoneField.text.length > 0 && codeField.text.length > 0 && [self verifyMobile:phoneField.text]) {
        [self showProgressWithText:@"更新中，请稍后"];
        BBProfileModel *userProfile = [BBProfileModel shareProfileModel];
        [[PalmUIManagement sharedInstance] postUserInfo:nil withMobile:phoneField.text withVerifyCode:codeField.text withPasswordOld:nil withPasswordNew:nil withSex:userProfile.sex withSign:nil];
    }else{
        if (!(phoneField.text.length > 0)) {
            [self showProgressWithText:@"请输入新手机号" withDelayTime:2];
            return;
        }
        if (!(codeField.text.length > 0)) {
            [self showProgressWithText:@"请输入验证码" withDelayTime:2];
            return;
        }
        if ([self verifyMobile:phoneField.text]) {
            [self showProgressWithText:@"请输入正确的手机号" withDelayTime:2];
            return;
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"postUserInfoResult"]) {
        NSDictionary *resultDic = [[PalmUIManagement sharedInstance] postUserInfoResult];
        NSDictionary *errDic = resultDic[@"data"];
        if ([errDic[@"errno"] integerValue] == 0) {
            [self showProgressWithText:@"更新成功" withDelayTime:2];
            [[CPSystemEngine sharedInstance] accountModel].loginName = phoneField.text;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showProgressWithText:resultDic[@"errorMessage"] withDelayTime:2];
        }
    }else{
        NSDictionary *resultDic = [[PalmUIManagement sharedInstance] smsVerifyCode];
        NSDictionary *errDic = resultDic[@"data"];
        if ([errDic[@"errno"] integerValue] == 0) {
            
        }else{
            [restTimer invalidate];
            restTimer = nil;
            [getCodeBtn setImage:[UIImage imageNamed:@"GetSmsCode.png"] forState:UIControlStateNormal];
            [getCodeBtn setUserInteractionEnabled:YES];
            [self showProgressWithText:resultDic[@"errorMessage"] withDelayTime:1];
        }
    }
}

-(void)restTime:(NSTimer *)timer
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.smsTime = delegate.smsTime - 1;
    if (delegate.smsTime == 0) {
        [restTimer invalidate];
        restTimer = nil;
        [getCodeBtn setImage:[UIImage imageNamed:@"GetSmsCode.png"] forState:UIControlStateNormal];
        [getCodeBtn setUserInteractionEnabled:YES];
    }else{
        [getCodeBtn setTitle:[NSString stringWithFormat:@"%d秒后重试", delegate.smsTime] forState:UIControlStateNormal];
    }
}

@end
