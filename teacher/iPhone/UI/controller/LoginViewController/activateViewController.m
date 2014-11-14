//
//  activateViewController.m
//  teacher
//
//  Created by singlew on 14-5-8.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "activateViewController.h"
#import "AppDelegate.h"

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
            self.view.frame = CGRectMake(0, -80.0f, self.view.frame.size.width, self.view.frame.size.height);
        }else{
            self.view.frame = CGRectMake(0, -40.0f, self.view.frame.size.width, self.view.frame.size.height);
        }
    }else{
        self.view.frame = CGRectMake(0, -60.0f, self.view.frame.size.width, self.view.frame.size.height);
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
    
    if (self.needSetUserName) {
        UIImageView *fromImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ActivateBigFrom"]];
        fromImage.frame = CGRectMake(0.0f, 29.0f, 320.0f, 224.0f);
        fromImage.userInteractionEnabled = YES;
        [self.view addSubview:fromImage];
        
        self.telPhone = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 12.0f, 180.0f, 24.0f)];
        self.telPhone.backgroundColor = [UIColor clearColor];
        self.telPhone.textAlignment = NSTextAlignmentLeft;
        self.telPhone.returnKeyType = UIReturnKeyDone;
        self.telPhone.keyboardType = UIKeyboardTypeNumberPad;
        self.telPhone.delegate = self;
        [fromImage addSubview:self.telPhone];
        
        self.smsCode = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 55.0f, 90.0f, 24.0f)];
        self.smsCode.backgroundColor = [UIColor clearColor];
        self.smsCode.textAlignment = NSTextAlignmentLeft;
        self.smsCode.returnKeyType = UIReturnKeyDone;
        self.smsCode.keyboardType = UIKeyboardTypeNumberPad;
        self.smsCode.delegate = self;
        [fromImage addSubview:self.smsCode];
        
        self.smsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.smsButton setBackgroundImage:[UIImage imageNamed:@"GetSmsCode"] forState:UIControlStateNormal];
        [self.smsButton setBackgroundImage:[UIImage imageNamed:@"GetSmsCode"] forState:UIControlStateHighlighted];
        self.smsButton.frame = CGRectMake(210.0f, 52.0f, 80.0f, 30.0f);
        [self.smsButton addTarget:self action:@selector(getsmsCode) forControlEvents:UIControlEventTouchUpInside];
        [fromImage addSubview:self.smsButton];
        
        self.passwordOld = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 98.0f, 180.0f, 24.0f)];
        self.passwordOld.backgroundColor = [UIColor clearColor];
        self.passwordOld.textAlignment = NSTextAlignmentLeft;
        self.passwordOld.returnKeyType = UIReturnKeyDone;
        self.passwordOld.secureTextEntry = YES;
        self.passwordOld.delegate = self;
        [fromImage addSubview:self.passwordOld];
        
        self.password = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 144.0f, 180.0f, 24.0f)];
        self.password.backgroundColor = [UIColor clearColor];
        self.password.textAlignment = NSTextAlignmentLeft;
        self.password.returnKeyType = UIReturnKeyDone;
        self.password.secureTextEntry = YES;
        self.password.delegate = self;
        [fromImage addSubview:self.password];
        
        self.confrimPassWord = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 190.0f, 180.0f, 24.0f)];
        self.confrimPassWord.backgroundColor = [UIColor clearColor];
        self.confrimPassWord.returnKeyType = UIReturnKeyDone;
        self.confrimPassWord.secureTextEntry = YES;
        self.confrimPassWord.textAlignment = NSTextAlignmentLeft;
        self.confrimPassWord.delegate = self;
        [fromImage addSubview:self.confrimPassWord];
    }else{
        UIImageView *fromImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ActivateSmallFrom2"]];
        fromImage.frame = CGRectMake((320.0f-285.0f)/2.0f, 20.0f, 285.0f, 130.0f);
        fromImage.userInteractionEnabled = YES;
        [self.view addSubview:fromImage];
        
        self.telPhone = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 12.0f, 170.0f, 24.0f)];
        self.telPhone.backgroundColor = [UIColor clearColor];
        self.telPhone.textAlignment = NSTextAlignmentRight;
        self.telPhone.returnKeyType = UIReturnKeyDone;
        self.telPhone.delegate = self;
        [fromImage addSubview:self.telPhone];
        
        self.password = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 52.0f, 170.0f, 24.0f)];
        self.password.backgroundColor = [UIColor clearColor];
        self.password.textAlignment = NSTextAlignmentRight;
        self.password.returnKeyType = UIReturnKeyDone;
        self.password.secureTextEntry = YES;
        self.password.delegate = self;
        [fromImage addSubview:self.password];
        
        self.confrimPassWord = [[UITextField alloc] initWithFrame:CGRectMake(95.0f, 92.0f, 170.0f, 24.0f)];
        self.confrimPassWord.backgroundColor = [UIColor clearColor];
        self.confrimPassWord.secureTextEntry = YES;
        self.confrimPassWord.textAlignment = NSTextAlignmentRight;
        self.confrimPassWord.returnKeyType = UIReturnKeyDone;
        self.confrimPassWord.delegate = self;
        [fromImage addSubview:self.confrimPassWord];
    }
    
    UIButton *activateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    activateButton.frame = CGRectMake((320.0f - 272.0f)/2.0f, self.screenHeight - 70.0f *2, 272.0f, 45.0f);
    [activateButton setImage:[UIImage imageNamed:@"ActivateButton"] forState:UIControlStateNormal];
    [activateButton setImage:[UIImage imageNamed:@"ActivateButtonPress"] forState:UIControlStateHighlighted];
    [activateButton addTarget:self action:@selector(clickActivate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:activateButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBG:)];
    [self.view addGestureRecognizer:tap];
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
