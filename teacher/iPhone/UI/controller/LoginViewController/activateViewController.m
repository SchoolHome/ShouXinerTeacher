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
@property (nonatomic) BOOL needSetUserName;
@property (nonatomic,strong) UITextField *smsCode;
@property (nonatomic,strong) UITextField *telPhone;
@property (nonatomic,strong) UITextField *passwordOld;
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
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"postUserInfoResult" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"smsVerifyCode" options:0 context:nil];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];;
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"postUserInfoResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"smsVerifyCode"];
}

-(void) keyboardWillShow : (NSNotification *)not{
    
    CGRect keyboardBounds;
    [[not.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    if (!self.needSetUserName) {
        if (self.currentVersion == kIOS6) {
            self.view.frame = CGRectMake(0, 20.0f, self.view.frame.size.width, self.view.frame.size.height);
        }else{
            self.view.frame = CGRectMake(0, 20.0f, self.view.frame.size.width, self.view.frame.size.height);
        }
    }else{
        self.view.frame = CGRectMake(0, 20.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    [UIView commitAnimations];
}

-(void) keyboardWillHide : (NSNotification *)not{

    NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    if (self.currentVersion == kIOS6) {
        self.view.frame = CGRectMake(0, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    }else{
        self.view.frame = CGRectMake(0, 64.0f, self.view.frame.size.width, self.view.frame.size.height);
    }
    [UIView commitAnimations];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"账号激活";
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.hidesBackButton = YES;
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
    [self.smsButton setBackgroundImage:[UIImage imageNamed:@"GetSmsCode"] forState:UIControlStateNormal];
    [self.smsButton setBackgroundImage:[UIImage imageNamed:@"GetSmsCode"] forState:UIControlStateHighlighted];
    self.smsButton.frame = CGRectMake(self.view.frame.size.width-100, height+7.f, 80.0f, 30.0f);
    [self.smsButton addTarget:self action:@selector(getsmsCode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.smsButton];
    
    if (loginModel.needSetUserName) {
        height = height + 55.f;
        subView = [[UIView alloc] initWithFrame:CGRectMake(0, height, self.view.frame.size.width, 44.f)];
        [subView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:subView];
        subView = nil;
        self.passwordOld = [[UITextField alloc] initWithFrame:CGRectMake(10, height, self.view.frame.size.width-20, 44.f)];
        self.passwordOld.backgroundColor = [UIColor whiteColor];
        self.passwordOld.returnKeyType = UIReturnKeyNext;
        [self.passwordOld setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        self.passwordOld.delegate = self;
        self.passwordOld.placeholder = @"输入用户名";
        [self.view addSubview:self.passwordOld];
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
    
    if([loginModel.mobile length]>0){
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) clickBG : (UIGestureRecognizer *) recognizer{
    [self.smsCode resignFirstResponder];
    [self.telPhone resignFirstResponder];
    [self.passwordOld resignFirstResponder];
    [self.password resignFirstResponder];
    [self.confrimPassWord resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
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
    
    NSString *passwordOld = nil;
    if (nil != self.passwordOld) {
        passwordOld = [self.passwordOld.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if (nil == passwordOld || [passwordOld isEqualToString:@""]) {
        [self showProgressWithText:@"旧密码不能为空" withDelayTime:1.0f];
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

    [[PalmUIManagement sharedInstance] postUserInfo:@"" withMobile:telPhoneText withVerifyCode:smsCode withPasswordOld:passwordOld withPasswordNew:passwordText withSex:0 withSign:@""];
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
    [[PalmUIManagement sharedInstance] getSMSVerifyCode:telPhoneText];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"postUserInfoResult"]) {
        if ([[PalmUIManagement sharedInstance].postUserInfoResult[ASI_REQUEST_HAS_ERROR] boolValue]) {
            [self showProgressWithText:[PalmUIManagement sharedInstance].postUserInfoResult[ASI_REQUEST_ERROR_MESSAGE] withDelayTime:1.0f];
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
            [self showProgressWithText:[PalmUIManagement sharedInstance].smsVerifyCode[ASI_REQUEST_ERROR_MESSAGE] withDelayTime:1.0f];
            return;
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
