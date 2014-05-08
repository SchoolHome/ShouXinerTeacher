//
//  activateViewController.m
//  teacher
//
//  Created by singlew on 14-5-8.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "activateViewController.h"

@interface activateViewController ()<UITextFieldDelegate>
@property (nonatomic) BOOL needSetUserName;
@property (nonatomic,strong) UITextField *userName;
@property (nonatomic,strong) UITextField *telPhone;
@property (nonatomic,strong) UITextField *email;
@property (nonatomic,strong) UITextField *password;
@property (nonatomic,strong) UITextField *confrimPassWord;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, 40.0f, 242.5f, 33.5f)];
    descLabel.text = @"用户名长度4-25个字符，一个中文占两个字符 主要用于登录使用，可使用汉字，字母或者两者组合。";
    descLabel.numberOfLines = 0;
    descLabel.textColor = [UIColor redColor];
    descLabel.font = [UIFont systemFontOfSize:11.0f];
    descLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:descLabel];
    
    if (self.needSetUserName) {
        UIImageView *fromImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ActivateBigFrom"]];
        fromImage.frame = CGRectMake((320.0f-283.0f)/2.0f, 110.0f, 283.0f, 211.0f);
        fromImage.userInteractionEnabled = YES;
        [self.view addSubview:fromImage];
        
        self.userName = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 12.0f, 180.0f, 24.0f)];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.textAlignment = NSTextAlignmentRight;
        self.userName.returnKeyType = UIReturnKeyDone;
        self.userName.delegate = self;
        [fromImage addSubview:self.userName];
        
        self.telPhone = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 52.0f, 180.0f, 24.0f)];
        self.telPhone.backgroundColor = [UIColor clearColor];
        self.telPhone.textAlignment = NSTextAlignmentRight;
        self.telPhone.returnKeyType = UIReturnKeyDone;
        self.telPhone.delegate = self;
        [fromImage addSubview:self.telPhone];
        
        self.email = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 92.0f, 180.0f, 24.0f)];
        self.email.backgroundColor = [UIColor clearColor];
        self.email.textAlignment = NSTextAlignmentRight;
        self.email.returnKeyType = UIReturnKeyDone;
        self.email.delegate = self;
        [fromImage addSubview:self.email];
        
        self.password = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 132.0f, 180.0f, 24.0f)];
        self.password.backgroundColor = [UIColor clearColor];
        self.password.textAlignment = NSTextAlignmentRight;
        self.password.returnKeyType = UIReturnKeyDone;
        self.password.secureTextEntry = YES;
        self.password.delegate = self;
        [fromImage addSubview:self.password];
        
        self.confrimPassWord = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 172.0f, 180.0f, 24.0f)];
        self.confrimPassWord.backgroundColor = [UIColor clearColor];
        self.confrimPassWord.returnKeyType = UIReturnKeyDone;
        self.confrimPassWord.secureTextEntry = YES;
        self.confrimPassWord.textAlignment = NSTextAlignmentRight;
        self.confrimPassWord.delegate = self;
        [fromImage addSubview:self.confrimPassWord];
    }else{
        UIImageView *fromImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ActivateSmallFrom"]];
        fromImage.frame = CGRectMake((320.0f-283.0f)/2.0f, 110.0f, 283.0f, 173.0f);
        fromImage.userInteractionEnabled = YES;
        [self.view addSubview:fromImage];
        
        self.userName = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 12.0f, 180.0f, 24.0f)];
        self.userName.backgroundColor = [UIColor clearColor];
        self.userName.textAlignment = NSTextAlignmentRight;
        self.userName.returnKeyType = UIReturnKeyDone;
        self.userName.delegate = self;
        [fromImage addSubview:self.userName];
        
        self.email = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 52.0f, 180.0f, 24.0f)];
        self.email.backgroundColor = [UIColor clearColor];
        self.email.textAlignment = NSTextAlignmentRight;
        self.email.returnKeyType = UIReturnKeyDone;
        self.email.delegate = self;
        [fromImage addSubview:self.email];
        
        self.password = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 92.0f, 180.0f, 24.0f)];
        self.password.backgroundColor = [UIColor clearColor];
        self.password.textAlignment = NSTextAlignmentRight;
        self.password.returnKeyType = UIReturnKeyDone;
        self.password.secureTextEntry = YES;
        self.password.delegate = self;
        [fromImage addSubview:self.password];
        
        self.confrimPassWord = [[UITextField alloc] initWithFrame:CGRectMake(85.0f, 132.0f, 180.0f, 24.0f)];
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
    [self.userName resignFirstResponder];
    [self.telPhone resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [self.confrimPassWord resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void) clickActivate{
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
