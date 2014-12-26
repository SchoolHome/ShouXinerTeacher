//
//  Login.m
//  teacher
//
//  Created by singlew on 14-3-3.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "Login.h"
#import "CPUIModelManagement.h"
#import "PalmUIManagement.h"
#import "activateViewController.h"
#import "ForgotPwdVC.h"

@interface Login ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UIImageView *bgImage;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UIView *loginView;
@property (nonatomic,strong) UITextField *userName;
@property (nonatomic,strong) UITextField *password;
@property (nonatomic,strong) UIButton *LoginButton;

-(void) clickBG : (UIGestureRecognizer *) recognizer;
-(void) login:(UIButton *) sender;
@end

@implementation Login

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(id) init{
    return [super init];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"customerServiceTel" options:0 context:nil];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"loginCode" options:0 context:@"loginCode"];
    
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
    [[CPUIModelManagement sharedInstance ] removeObserver:self forKeyPath:@"loginCode"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"customerServiceTel"];
}

-(void) keyboardWillShow : (NSNotification *)not{
    CGRect keyboardBounds;
    [[not.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self.iconImage setFrame:CGRectMake((self.view.frame.size.width-165.f)/2, 0.f, 165.f, 138.f)];
    [self.loginView setFrame:CGRectMake((self.view.frame.size.width-297.f)/2, 120.f, 297.f, 195.f)];
    [UIView commitAnimations];
}

-(void) keyboardWillHide : (NSNotification *)not{
    NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [self.iconImage setFrame:CGRectMake((self.view.frame.size.width-197.f)/2, 33.f, 197.f, 165.f)];
    [self.loginView setFrame:CGRectMake((self.view.frame.size.width-297.f)/2, 208.f, 297.f, 195.f)];
    [UIView commitAnimations];
}


- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.screenHeight)];
    self.bgImage.image = [UIImage imageNamed:@"login_bg.png"];
    self.bgImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBG:)];
    [self.bgImage addGestureRecognizer:tap];
    [self.view addSubview:self.bgImage];
    
    self.iconImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-197.f)/2, 33.f, 197.f, 165.f)];
    [self.iconImage setImage:[UIImage imageNamed:@"login_img.png"]];
    [self.bgImage addSubview:self.iconImage];
    
    self.loginView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-297.f)/2, 208.f, 297.f, 195.f)];
    [self.loginView setUserInteractionEnabled:YES];
    [self.bgImage addSubview:self.loginView];
    
    UIImageView *inputBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.loginView.frame.size.width, 125.f)];
    [inputBg setImage:[UIImage imageNamed:@"login_input.png"]];
    [self.loginView addSubview:inputBg];
    inputBg = nil;
    
    float height = 18.f;
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(65.f, height, 205.f, 40.f)];
    self.userName.placeholder = @"用户名/邮箱/手机";
    self.userName.returnKeyType = UIReturnKeyDone;
    self.userName.delegate = self;
    [self.userName setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.userName setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.userName setTextAlignment:NSTextAlignmentCenter];
    [self.userName setFont:[UIFont systemFontOfSize:16]];
    [self.userName setBackgroundColor:[UIColor whiteColor]];
    [self.loginView addSubview:self.userName];

    height = 68.f;
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(65.f, height, 205.f, 40.f)];
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.delegate = self;
    self.password.placeholder = @"密码";
    [self.password setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.password setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self.password setFont:[UIFont systemFontOfSize:16]];
    [self.password setTextAlignment:NSTextAlignmentCenter];
    [self.password setBackgroundColor:[UIColor whiteColor]];
    [self.loginView addSubview:self.password];

    height = 124.f;
    self.LoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.LoginButton.frame = CGRectMake((self.loginView.frame.size.width - 245.f)/2.0f, height, 245.f, 39.f);
    [self.LoginButton setImage:[UIImage imageNamed:@"login_btn.png"] forState:UIControlStateNormal];
    [self.LoginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:self.LoginButton];
    height = 170.f;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(self.loginView.frame.size.width-90, height, 80, 30)];
    [btn setTitle:@"无法登录？" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [btn addTarget:self action:@selector(cantLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView addSubview:btn];
    
    height = 0.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0){
        height = 20.0f;
    }
    UILabel *label = [[UILabel alloc] init];
#ifdef IS_TEACHER
    label.text = @"手心网 V4.0 教师版";
#else
    label.text = @"手心网 V4.0 家长版";
#endif
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake((self.view.frame.size.width-150.f)/2, self.screenHeight - 27.0f - height, 150.0f, 20.0f);
    label.font = [UIFont systemFontOfSize:14.0f];
    [self.bgImage addSubview:label];
    
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    if ( nil != account.pwdMD5 && ![account.pwdMD5 isEqualToString:@""]) {
        [self.userName setText:account.loginName];
        [self.password setSecureTextEntry:YES];
        [self.password setText:account.pwdMD5];
        [self showProgressWithText:@"正在登录"];
    }
}

-(void) clickBG : (UIGestureRecognizer *) recognizer{
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void) login:(UIButton *)sender{
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
    
//    self.userName.text = @"13940231890";
//    self.password.text = @"231890";
    
    NSString *userName  = [self.userName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( nil == userName || [userName isEqualToString:@""] ) {
        [self showProgressWithText:@"请填写用户名" withDelayTime:1.5f];
        return;
    }
    NSString *password = [self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (nil == password || [password isEqualToString:@""]) {
        [self showProgressWithText:@"请填写密码" withDelayTime:1.5f];
        return;
    }
    
    [self showProgressWithText:@"正在登录"];
    [[CPUIModelManagement sharedInstance] loginWithName:userName password:password];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"customerServiceTel"]) {
        NSDictionary *resultDic = [[PalmUIManagement sharedInstance] customerServiceTel];
        if ([resultDic[@"hasError"] integerValue] == 0) {
            [self closeProgress];
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",resultDic[@"data"][@"number"]];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self.view addSubview:callWebview];
        }else{
            [self showProgressWithText:resultDic[@"errorMessage"] withDelayTime:2];
        }
    }else if ([@"loginCode" isEqualToString:keyPath]){
        NSInteger login_code_int = [CPUIModelManagement sharedInstance].loginCode;
        if(login_code_int == 0){
            if (![PalmUIManagement sharedInstance].loginResult.recommend && ![PalmUIManagement sharedInstance].loginResult.force) {
                if ([PalmUIManagement sharedInstance].loginResult.needSetUserName) {
                    [self closeProgress];
                    activateViewController *activate = [[activateViewController alloc] initActivateViewController:YES];
                    [self.navigationController pushViewController:activate animated:YES];
                }else{
                    if (![PalmUIManagement sharedInstance].loginResult.activated) {
                        [self closeProgress];
                        activateViewController *activate = [[activateViewController alloc] initActivateViewController:NO];
                        [self.navigationController pushViewController:activate animated:YES];
                    }else{
                        [self closeProgress];
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate launchApp];
                    }
                }
            }else if([PalmUIManagement sharedInstance].loginResult.recommend && ![PalmUIManagement sharedInstance].loginResult.force){
                [self closeProgress];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有更新" message:@"有新版本更新" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                [alert show];
            }else if([PalmUIManagement sharedInstance].loginResult.recommend && [PalmUIManagement sharedInstance].loginResult.force){
                [self closeProgress];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"有更新" message:@"有新版本更新" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }else{
            /*登录失败*/
            NSLog(@"登录失败");
            if ([CPUIModelManagement sharedInstance].loginErrorMsg == nil || [[CPUIModelManagement sharedInstance].loginErrorMsg isEqualToString:@""]) {
                [self showProgressWithText:@"登录失败" withDelayTime:2.0f];
            }else{
                [self showProgressWithText:[CPUIModelManagement sharedInstance].loginErrorMsg withDelayTime:2.0f];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (![[PalmUIManagement sharedInstance].loginResult.url isEqualToString:@""] && [PalmUIManagement sharedInstance].loginResult.url != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[PalmUIManagement sharedInstance].loginResult.url]];
        }
    }else{
        if ([PalmUIManagement sharedInstance].loginResult.needSetUserName) {
            activateViewController *activate = [[activateViewController alloc] initActivateViewController:YES];
            [self.navigationController pushViewController:activate animated:YES];
        }else{
            if (![PalmUIManagement sharedInstance].loginResult.activated) {
                activateViewController *activate = [[activateViewController alloc] initActivateViewController:NO];
                [self.navigationController pushViewController:activate animated:YES];
            }else{
                [self closeProgress];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                [appDelegate launchApp];
            }
        }
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.password) {
        [self.password setSecureTextEntry:YES];
    }
    return YES;
}

-(void)cantLogin:(UIButton *)btn
{
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重置密码", @"联系客服",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        ForgotPwdVC *forgotVC = [[ForgotPwdVC alloc] init];
        [self.navigationController pushViewController:forgotVC animated:YES];
    }else if(buttonIndex == 1){
        //拨打电话
        [self showProgressWithText:@"正在为您联系空闲客服..."];
        [[PalmUIManagement sharedInstance] getCustomerServiceTelNumber];
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

-(void) dealloc{
    
}

@end
