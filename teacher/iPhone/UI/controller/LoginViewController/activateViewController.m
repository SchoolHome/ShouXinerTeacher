//
//  activateViewController.m
//  teacher
//
//  Created by singlew on 14-5-8.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "activateViewController.h"
#import "AppDelegate.h"
#import "CPSystemEngine.h"

@interface activateViewController ()<UITextFieldDelegate>
{
    NSTimer *restTimer;
}
@property (nonatomic) BOOL needSetUserName;
@property (nonatomic,strong) UITextField *smsCode;
@property (nonatomic,strong) UITextField *telPhone;
@property (nonatomic,strong) UITextField *userName;
@property (nonatomic,strong) UITextField *password;
@property (nonatomic,strong) UITextField *confrimPassWord;
@property (nonatomic,strong) UIButton *smsButton;
-(void) getsmsCode;
@end

@implementation activateViewController

-(activateViewController *) initActivateViewController:(BOOL)needSetUserName{
    if (nil != [self init]) {
        self.needSetUserName = needSetUserName;
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"activateDic" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"smsVerifyCode" options:0 context:nil];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];;
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"activateDic"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"smsVerifyCode"];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"账号激活";
    [self.navigationController setNavigationBarHidden:NO];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    CPPTModelLoginResult *loginModel = [PalmUIManagement sharedInstance].loginResult;
    CGFloat height = 10.f;
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44.f)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    self.telPhone = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 44.0f)];
    self.telPhone.backgroundColor = [UIColor whiteColor];
    self.telPhone.returnKeyType = UIReturnKeyNext;
    [self.telPhone setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.telPhone.keyboardType = UIKeyboardTypeNumberPad;
    self.telPhone.delegate = self;
    [self.view addSubview:self.telPhone];
    height = height + 45.f;
    subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44.f)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    self.smsCode = [[UITextField alloc] initWithFrame:CGRectMake(10.f, height, self.view.frame.size.width-120, 44.0f)];
    self.smsCode.backgroundColor = [UIColor whiteColor];
    self.smsCode.returnKeyType = UIReturnKeyNext;
    self.smsCode.placeholder = @"输入验证码";
    self.smsCode.keyboardType = UIKeyboardTypeNumberPad;
    [self.smsCode setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.smsCode.delegate = self;
    [self.view addSubview:self.smsCode];
    self.smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.smsButton setImage:[UIImage imageNamed:@"GetSmsCode"] forState:UIControlStateNormal];
    self.smsButton.frame = CGRectMake(self.view.frame.size.width-100, height+7.f, 80.0f, 30.0f);
    [self.smsButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.smsButton addTarget:self action:@selector(getsmsCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.smsButton];
    
    if (self.needSetUserName) {
        height = height + 55.f;
        subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44.f)];
        [subView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:subView];
        subView = nil;
        self.userName = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 44.f)];
        self.userName.backgroundColor = [UIColor whiteColor];
        self.userName.returnKeyType = UIReturnKeyNext;
        [self.userName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.userName.delegate = self;
        self.userName.placeholder = @"输入用户名";
        [self.view addSubview:self.userName];
    }
    height = height + 55.f;
    subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44.f)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(10.f, height, self.view.frame.size.width-20, 44.f)];
    self.password.backgroundColor = [UIColor whiteColor];
    self.password.returnKeyType = UIReturnKeyNext;
    [self.password setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.password.secureTextEntry = YES;
    self.password.delegate = self;
    self.password.placeholder = @"新密码(6位以上字母和数字组合)";
    [self.view addSubview:self.password];
    height = height + 45.f;
    subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44.f)];
    [subView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:subView];
    subView = nil;
    self.confrimPassWord = [[UITextField alloc] initWithFrame:CGRectMake(10.f, height, self.view.frame.size.width-20, 44.f)];
    self.confrimPassWord.backgroundColor = [UIColor whiteColor];
    self.confrimPassWord.returnKeyType = UIReturnKeyDone;
    self.confrimPassWord.secureTextEntry = YES;
    [self.confrimPassWord setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    self.confrimPassWord.delegate = self;
    self.confrimPassWord.placeholder = @"确认密码";
    [self.view addSubview:self.confrimPassWord];
    
    if([loginModel.mobile length] == 11){
        [self.telPhone setText:loginModel.mobile];
        [self.telPhone setUserInteractionEnabled:NO];
    }else{
        [self.telPhone setPlaceholder:@"输入手机号"];
        [self.telPhone setUserInteractionEnabled:YES];
    }
    height = height + 60.f;
    UIButton *activateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    activateButton.frame = CGRectMake((self.view.frame.size.width - 272.0f)/2.0f, height, 272.0f, 45.0f);
    [activateButton setImage:[UIImage imageNamed:@"ActivateButton"] forState:UIControlStateNormal];
    [activateButton setImage:[UIImage imageNamed:@"ActivateButtonPress"] forState:UIControlStateHighlighted];
    [activateButton addTarget:self action:@selector(clickActivate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:activateButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBG:)];
    [self.view addGestureRecognizer:tap];
}

-(void)keyBoardWillDisappear
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (self.currentVersion == kIOS6) {
        [self.view setFrame:CGRectMake(0, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    }else{
        [self.view setFrame:CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height)];
    }
    [UIView commitAnimations];
}

-(void)keyBoardWillAppear:(UITextField *)textField
{
    CGFloat fix = -10;
    if (self.needSetUserName) {
        fix = 54;
    }
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (self.currentVersion == kIOS6) {
        if (textField == self.telPhone || textField == self.smsCode) {
            [self.view setFrame:CGRectMake(0, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
        }else if(textField == self.userName){
            [self.view setFrame:CGRectMake(0, -50.f, self.view.frame.size.width, self.view.frame.size.height)];
        }else if(textField == self.password || textField == self.confrimPassWord){
            [self.view setFrame:CGRectMake(0, -(40+fix), self.view.frame.size.width, self.view.frame.size.height)];
        }
    }else{
        if (textField == self.telPhone || textField == self.smsCode) {
            [self.view setFrame:CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height)];
        }else if(textField == self.userName){
            [self.view setFrame:CGRectMake(0, 10.f, self.view.frame.size.width, self.view.frame.size.height)];
        }else if(textField == self.password || textField == self.confrimPassWord){
            [self.view setFrame:CGRectMake(0, -fix, self.view.frame.size.width, self.view.frame.size.height)];
        }
    }
    [UIView commitAnimations];
}

-(void) clickBG : (UIGestureRecognizer *) recognizer{
    [self.smsCode resignFirstResponder];
    [self.telPhone resignFirstResponder];
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
    [self.confrimPassWord resignFirstResponder];
    [self keyBoardWillDisappear];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self keyBoardWillDisappear];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self keyBoardWillAppear:textField];
}

-(void) clickActivate{

    NSString *telPhoneText = nil;
    if (nil != self.telPhone) {
        telPhoneText = [self.telPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if (nil != self.telPhone) {
        if (nil == telPhoneText || [telPhoneText isEqualToString:@""]) {
            [self showProgressWithText:@"手机号不能为空" withDelayTime:1.0f];
            return;
        }
    }
    
    NSString *smsCode = nil;
    if (nil != self.smsCode) {
        smsCode = [self.smsCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if (nil == smsCode || [smsCode isEqualToString:@""]) {
        [self showProgressWithText:@"验证码不能为空" withDelayTime:1.0f];
        return;
    }
    
    NSString *passwordText = [self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *confrimPassWordText = [self.confrimPassWord.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ((nil != passwordText && ![passwordText isEqualToString:@""]) || (nil != confrimPassWordText && ![confrimPassWordText isEqualToString:@""])) {
        if (![passwordText isEqualToString:confrimPassWordText]) {
            [self showProgressWithText:@"两次密码填写不一致" withDelayTime:1.0f];
            return;
        }
    }
    if(self.needSetUserName)
    {
        NSString *username = nil;
        if (nil != self.userName) {
            username = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        if (nil == username || [username isEqualToString:@""]) {
            [self showProgressWithText:@"用户名不能为空" withDelayTime:1.0f];
            return;
        }
        [[PalmUIManagement sharedInstance] activate:username withTelPhone:telPhoneText withEmail:@"" withPassWord:passwordText];
    }else{
        [[PalmUIManagement sharedInstance] activate:@"" withTelPhone:telPhoneText withEmail:@"" withPassWord:passwordText];
    }
}

-(void) getsmsCode{
    NSString *telPhoneText = nil;
    if (nil != self.telPhone) {
        telPhoneText = [self.telPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if (nil != self.telPhone) {
        if (nil == telPhoneText || [telPhoneText isEqualToString:@""]) {
            [self showProgressWithText:@"手机号不能为空" withDelayTime:1.0f];
            return;
        }
    }
    [self.smsButton setBackgroundColor:[UIColor grayColor]];
    [self.smsButton setImage:nil forState:UIControlStateNormal];
    [self.smsButton setUserInteractionEnabled:NO];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.smsTime = 120;
    [self.smsButton setTitle:[NSString stringWithFormat:@"%d秒后重试", delegate.smsTime] forState:UIControlStateNormal];
    restTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(restTime:) userInfo:nil repeats:YES];
    [[PalmUIManagement sharedInstance] getSMSVerifyCode:telPhoneText];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"activateDic"]) {
        if ([[PalmUIManagement sharedInstance].activateDic[ASI_REQUEST_HAS_ERROR] boolValue]) {
            [self showProgressWithText:[PalmUIManagement sharedInstance].activateDic[ASI_REQUEST_ERROR_MESSAGE] withDelayTime:1.0f];
            return;
        }
        NSString *telPhoneText = [self.telPhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *passwordText = [self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        account.loginName = telPhoneText;
        account.pwdMD5 = passwordText;
        [[CPSystemEngine sharedInstance] backupSystemInfoWithAccount:account];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate launchApp];
    }else if ([keyPath isEqualToString:@"smsVerifyCode"]){
        if ([[PalmUIManagement sharedInstance].smsVerifyCode[ASI_REQUEST_HAS_ERROR] boolValue]) {
            [restTimer invalidate];
            restTimer = nil;
            [self.smsButton setImage:[UIImage imageNamed:@"GetSmsCode.png"] forState:UIControlStateNormal];
            [self.smsButton setUserInteractionEnabled:YES];
            [self showProgressWithText:[PalmUIManagement sharedInstance].smsVerifyCode[ASI_REQUEST_ERROR_MESSAGE] withDelayTime:1.0f];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning{
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
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)restTime:(NSTimer *)timer
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.smsTime = delegate.smsTime - 1;
    if (delegate.smsTime == 0) {
        [restTimer invalidate];
        restTimer = nil;
        [self.smsButton setImage:[UIImage imageNamed:@"GetSmsCode.png"] forState:UIControlStateNormal];
        [self.smsButton setUserInteractionEnabled:YES];
    }else{
        [self.smsButton setTitle:[NSString stringWithFormat:@"%d秒后重试", delegate.smsTime] forState:UIControlStateNormal];
    }
}
@end
