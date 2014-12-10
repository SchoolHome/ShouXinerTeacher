//
//  ForgotPwdVC.m
//  teacher
//
//  Created by mac on 14/12/5.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ForgotPwdVC.h"

@interface ForgotPwdVC ()
{
    UITextField *phoneField;
    UITextField *verfyField;
    UITextField *newPwdField;
    UITextField *confirmPwd;
}
@end

@implementation ForgotPwdVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat height = 44;
    if (IOS7) {
        height = 64;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    headerView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    headerView.layer.shadowRadius = 1.f;
    headerView.layer.shadowOpacity = 0.5f;
    [headerView.layer setShadowOffset:CGSizeMake(0, 1)];
    [self.view addSubview:headerView];
    
    height = 0;
    if(IOS7)
    {
        height = 20;
    }
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, height, headerView.frame.size.width, 44)];
    [title setFont:[UIFont systemFontOfSize:20]];
    [title setBackgroundColor:[UIColor whiteColor]];
    [title setText:@"重置密码"];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[UIColor colorWithHexString:@"ff9632"]];
    [headerView addSubview:title];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(10.f, height + 11.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:back];
    
    
    height = 54;
    if (IOS7) {
        height = 74;
    }
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    phoneField = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 44)];
    [phoneField setPlaceholder:@"输入正确得手机号码"];
    [phoneField setFont:[UIFont systemFontOfSize:16]];
    [phoneField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [phoneField setBackgroundColor:[UIColor whiteColor]];
    [phoneField setDelegate:(id<UITextFieldDelegate>)self];
    [self.view addSubview:phoneField];
    
    height = height + 45;
    subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    verfyField = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-110, 44)];
    [verfyField setPlaceholder:@"输入验证码"];
    [verfyField setFont:[UIFont systemFontOfSize:16]];
    [verfyField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [verfyField setBackgroundColor:[UIColor whiteColor]];
    [verfyField setDelegate:(id<UITextFieldDelegate>)self];
    [self.view addSubview:verfyField];
    UIButton *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [codeBtn setFrame:CGRectMake(self.view.frame.size.width-100, height+5, 80, 30)];
    [codeBtn setImage:[UIImage imageNamed:@"GetSmsCode.png"] forState:UIControlStateNormal];
    [codeBtn addTarget:self action:@selector(getVerfyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:codeBtn];
    
    height = height + 55;
    subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    newPwdField = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 44)];
    [newPwdField setPlaceholder:@"新密码(6位以上字母和数字组合)"];
    [newPwdField setFont:[UIFont systemFontOfSize:16]];
    [newPwdField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [newPwdField setBackgroundColor:[UIColor whiteColor]];
    [newPwdField setDelegate:(id<UITextFieldDelegate>)self];
    [self.view addSubview:newPwdField];
    height = height + 45;
    subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    confirmPwd = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 44)];
    [confirmPwd setPlaceholder:@"确认新密码"];
    [confirmPwd setFont:[UIFont systemFontOfSize:16]];
    [confirmPwd setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [confirmPwd setBackgroundColor:[UIColor whiteColor]];
    [confirmPwd setDelegate:(id<UITextFieldDelegate>)self];
    [self.view addSubview:confirmPwd];
    height = height + 80;
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setFrame:CGRectMake(20, height, self.view.frame.size.width-40, 40)];
    
    [self.view addSubview:loginBtn];
}

-(void)getVerfyCode:(UIButton *)btn
{
    
}

-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
