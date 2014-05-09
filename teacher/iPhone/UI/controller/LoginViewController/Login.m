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

@interface Login ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) UIImageView *bgImage;
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
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    if ([account isAutoLogin]){
        [self showProgressWithText:@"正在登陆"];
    }
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[CPUIModelManagement sharedInstance ] removeObserver:self forKeyPath:@"loginCode"];
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
    self.view.frame = CGRectMake(0, -keyboardBounds.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

-(void) keyboardWillHide : (NSNotification *)not{
//    if ([textView isFirstResponder]) {  // 过滤
        NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        self.view.frame = CGRectMake(0, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        [UIView commitAnimations];
//    }
}


- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.screenHeight)];
    if (self.screenHeight == 568.0f) {
        self.bgImage.image = [UIImage imageNamed:@"Login568.jpg"];
    }else{
        self.bgImage.image = [UIImage imageNamed:@"Login"];
    }
    self.bgImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBG:)];
    [self.bgImage addGestureRecognizer:tap];
    [self.view addSubview:self.bgImage];
    
    float height = 370.0f;
    if (self.screenHeight != 568.0f) {
        height = 370.0f - (568.0f - 480.0f);
    }
    
    self.userName = [[UITextField alloc] initWithFrame:CGRectMake(60.0f, height, 200.0f, 20.0f)];
    self.userName.placeholder = @"用户名/邮箱/手机";
    self.userName.returnKeyType = UIReturnKeyDone;
    self.userName.delegate = self;
    [self.bgImage addSubview:self.userName];
    
    height = 415.0f;
    if (self.screenHeight != 568.0f) {
        height = 415.0f - (568.0f - 480.0f);
    }
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(60.0f, height, 200.0f, 20.0f)];
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    [self.bgImage addSubview:self.password];
    
    self.LoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.LoginButton.frame = CGRectMake((320.0f - 271.0f)/2.0f, self.screenHeight - 43.0f*2, 271.0f, 43.0f);
    [self.LoginButton setImage:[UIImage imageNamed:@"LoginButton"] forState:UIControlStateNormal];
    [self.LoginButton setImage:[UIImage imageNamed:@"LoginButtonPress"] forState:UIControlStateHighlighted];
    [self.LoginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgImage addSubview:self.LoginButton];
    
    UILabel *label = [[UILabel alloc] init];
#ifdef IS_TEACHER
    label.text = @"手心网 v1.0 教师版";
#else
    label.text = @"手心网 v1.0 家长版";
#endif
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.alpha = 0.6f;
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(115.0f, self.screenHeight - 27.0f, 150.0f, 20.0f);
    label.font = [UIFont systemFontOfSize:12.0f];
    [self.view addSubview:label];
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
    
//    self.userName.text = @"13709832805";
//    self.password.text = @"123456";
    
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
    
    [self showProgressWithText:@"正在登陆"];
    [[CPUIModelManagement sharedInstance] loginWithName:userName password:password];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([@"loginCode" isEqualToString:keyPath]){
        NSInteger login_code_int = [CPUIModelManagement sharedInstance].loginCode;
        
        if(login_code_int == 0){
            if (![PalmUIManagement sharedInstance].loginResult.recommend && ![PalmUIManagement sharedInstance].loginResult.force) {
                if (![PalmUIManagement sharedInstance].loginResult.activated) {
                    [self closeProgress];
                    activateViewController *activate = [[activateViewController alloc] initActivateViewController:[PalmUIManagement sharedInstance].loginResult.needSetUserName];
                    [self.navigationController pushViewController:activate animated:YES];
                }else{
                    [self closeProgress];
                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    [appDelegate launchApp];
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
            [self showProgressWithText:@"登陆失败" withDelayTime:2.0f];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (![[PalmUIManagement sharedInstance].loginResult.url isEqualToString:@""] && [PalmUIManagement sharedInstance].loginResult.url != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[PalmUIManagement sharedInstance].loginResult.url]];
        }
    }else{
        if (![PalmUIManagement sharedInstance].loginResult.activated) {
            NSLog(@"激活");
        }else{
            [self closeProgress];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate launchApp];
        }
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    
}

@end
