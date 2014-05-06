//
//  LoginViewController.m
//  iCouple
//
//  Created by 振杰 李 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "FanxerHeader.h"
#import "ForgetViewController.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"
#import "CPLGModelAccount.h"

//#import "VerifyViewCodeController.h"
//#import "GroundViewController.h"
#import "FXTopTipPanelDelegate.h"

#import "HomePageViewController.h"
#import "AppDelegate.h"

#define LEFT_X 4.0/2
#define LEFT_Y 6.0/2
#define LEFT_WIDTH 72.0/2
#define LEFT_HIGH 72.0/2

#define RIGHT_X 556.0/2.0
#define RIGHT_Y 6.0/2
#define RIGHT_WIDTH 72.0/2
#define RIGHT_HIGH  72.0/2


#define NAV_X 0.0
#define NAV_Y 0.0
#define NAV_WIDTH 640.0/2.0
#define NAV_HIGH  86.0/2

#define PR_X 216.0/2.0
#define PR_Y 30.0/2.0
#define PR_WIDTH 203/2
#define PR_HIGH 22/2
/*
 顶部背景
 */
#define FX_LOGIN_TOP_BG_X 0
#define FX_LOGIN_TOP_BG_Y 0
#define FX_LOGIN_TOP_BG_W 640/2
#define FX_LOGIN_TOP_BG_H 420/2
/*
 双双logo
 */
#define FX_LOGIN_LOGO_X 168/2
#define FX_LOGIN_LOGO_Y 102/2
#define FX_LOGIN_LOGO_W 139/2
#define FX_LOGIN_LOGO_H 70/2
/*
 小双人像
 */
#define FX_LOGIN_SHUANG_X 347/2
#define FX_LOGIN_SHUANG_Y 28/2
#define FX_LOGIN_SHUANG_W 184/2
#define FX_LOGIN_SHUANG_H 218/2
/*
    帐号输入
 */
#define FX_LOGIN_USERNAME_X 110/2
#define FX_LOGIN_USERNAME_Y 279/2
#define FX_LOGIN_USERNAME_WIDTH 421/2
#define FX_LOGIN_USERNAME_HEIGHT 73/2

/*
    密码输入
 */
#define FX_LOGIN_PASSWORD_X 110/2
#define FX_LOGIN_PASSWORD_Y 387/2
#define FX_LOGIN_PASSWORD_WIDTH 421/2
#define FX_LOGIN_PASSWORD_HEIGHT 73/2

#define FX_HELP_PWD_BUTTON_X 546/2
#define FX_HELP_PWD_BUTTON_Y 404/2
#define FX_HELP_PWD_BUTTON_WIDTH 20
#define FX_HELP_PWD_BUTTON_HEIGHT 32

#define FX_LOGIN_BUTTON_X 109/2
#define FX_LOGIN_BUTTON_Y 496/2
#define FX_LOGIN_BUTTON_WIDTH 215/2
#define FX_LOGIN_BUTTON_HEIGHT 74/2

#define FX_REGIST_BUTTON_X 341/2
#define FX_REGIST_BUTTON_Y 496/2
#define FX_REGIST_BUTTON_WIDTH 184/2
#define FX_REGIST_BUTTON_HEIGHT 74/2

#define FX_FORGET_PASSWORD_PANEL_X 58/2
#define FX_FORGET_PASSWORD_PANEL_Y 101/2
#define FX_FORGET_PASSWORD_PANEL_WIDTH 531/2
#define FX_FORGET_PASSWORD_PANEL_HEIGHT 399/2
#define FX_FORGET_PASSWORD_PANEL_SPEED 0.5
#define FX_LOGIN_STATUS_H 20
#import "RegistFirstViewController.h"
@implementation LoginViewController
@synthesize fnav;
@synthesize username_string = _username_string;
@synthesize password_string = _password_string;
- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
}



#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self do_init_config];
    
    [self do_init_main_view];
    [self do_init_body_view];
    [self do_init_subviews];
    [self do_init_loading_view];
    [self do_init_toptip_view];
    [self do_init_forget_password_panel];
    
    [self loadNav];
    [self do_load_body_view];
    [self do_load_subviews];
    
    
}
-(void)dealloc
{
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
#pragma mark main_view
- (void)do_init_main_view{
    UIControl * view_temp = [[UIControl alloc] initWithFrame:FXRect(0.0, 0.0, 320, 460)];
    [view_temp setBackgroundColor:[UIColor colorWithHexString:@"#FFFEF6"]];
    [view_temp addTarget:self action:@selector(do_respond_tap_main_view) forControlEvents:UIControlEventTouchUpInside];
    self.view = view_temp;
    view_temp = nil;
}
- (void)do_rise_main_view{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, 0, 320,460);
        self.view.frame = CGRectMake(-0, -60, 320, 460);
    }completion:^(BOOL finished){
        
    } ];
}
- (void)do_drop_main_view{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(-0, -60, 320, 460);
        self.view.frame = CGRectMake(0, 0, 320,460);
    }completion:^(BOOL finished){
        
    } ];
}
- (void)do_respond_tap_main_view{
    [self do_hide_keyboard];
    if(rised_forget_panel == YES){
        [self do_hide_forget_password_panel];
        [self do_destory_forget_password_panel];
    }
}
#pragma mark body_view
- (void)do_init_body_view{
    body_view = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, 320, 460)];
    [body_view setBackgroundColor:[UIColor clearColor]];
    [body_view addTarget:self action:@selector(do_respond_tap_body_view) forControlEvents:UIControlEventTouchUpInside];
}
- (void)do_load_body_view{
    [self.view addSubview:body_view];
}
- (void)do_respond_tap_body_view{
    [self do_hide_keyboard];    
    if(rised_forget_panel == YES){
        [self do_hide_forget_password_panel];
        [self do_destory_forget_password_panel];
    }
}
-(void)loadNav{
    NavigationBothStyle *style=[[NavigationBothStyle alloc] initWithTitle:@"" Leftcontrol:nil Rightcontrol:nil];
    fnav =[[FanxerNavigationBarControl alloc] initWithFrame:FXRect(NAV_X, NAV_Y, NAV_WIDTH, NAV_HIGH) withStyle:style withDefinedUserControl:YES];
    fnav._delegate=self;
    [self.view addSubview:fnav];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self do_add_observer];
    [username_field do_hide_keyboard];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self do_remove_observer];
    [username_field do_hide_keyboard];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark config
- (void)do_init_config{
    rised_forget_panel = NO;
    rised_toptip = NO;
    rised_loading = NO;
    model_management = [CPUIModelManagement sharedInstance];
}
#pragma mark toptip_view
- (void)do_init_toptip_view{
    [super do_init_toptip_view];
    [toptippanel setDelegate:self];
}
#pragma mark FXTopTipViewDelegate
- (void)action_toptip_did_show{
    rised_toptip = YES;
}
- (void)action_toptip_did_hide{
    rised_toptip = NO;
}



#pragma mark -
#pragma mark FanxerNavigationBarDelegate method

-(void)doLeft{
    
    
    
}

-(void)doRight{
    
    RegistFirstViewController *rvc=[[RegistFirstViewController alloc] init];
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark subviews
- (void)do_init_subviews{
    
    UIImage * topBgImage_ = [UIImage imageNamed:FX_LOGIN_IMG_TOP_BG];
    _topBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FX_LOGIN_TOP_BG_X, FX_LOGIN_TOP_BG_Y, topBgImage_.size.width/2, topBgImage_.size.height/2)];
    [_topBgImageView setImage:topBgImage_];
    [self.view addSubview:_topBgImageView];
    
    UIImage * logo_image = [UIImage imageNamed:FX_LOGIN_IMG_LOGO];
    _logo_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(FX_LOGIN_LOGO_X, FX_LOGIN_LOGO_Y+20, logo_image.size.width/2, logo_image.size.height/2)];
    [_logo_image_view setImage:logo_image];
    
    UIImage * shuangImage_ = [UIImage imageNamed:FX_LOGIN_IMG_SHUANG];
    _shuangImageView = [[UIImageView alloc] initWithFrame:CGRectMake(FX_LOGIN_SHUANG_X, FX_LOGIN_SHUANG_Y, shuangImage_.size.width/2, shuangImage_.size.height/2)];
    [_shuangImageView setImage:shuangImage_];
    [self.view addSubview:_shuangImageView];
   
    

    username_field = [[FXShakeField alloc] 
                      initWithFrame:FXRect(FX_LOGIN_USERNAME_X, 208/2+20, FX_LOGIN_USERNAME_WIDTH, FX_LOGIN_USERNAME_HEIGHT) 
                      ground_image:REGIST_TXT_INPUT_IMG icon_image:REGIST_TXT_MAN_IMG];
    [username_field do_set_placeholder_string:@"帐号"];
    [username_field do_set_keyboard_type:UIKeyboardTypeASCIICapable];
    [username_field do_set_return_type:UIReturnKeyNext];
    [username_field.shake_text_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [username_field do_set_background_editing_did_begin_image:REGIST_TEXT_BOX_WHITE_IMG editing_did_end_image:REGIST_TEXT_BOX_IMG];
    username_field.edit_limit_int = 30;
    username_field.last_limit_int = 30;
    [username_field setDelegate:self];
    
    password_field = [[FXShakeField alloc] initWithFrame:CGRectMake(FX_LOGIN_PASSWORD_X, FX_LOGIN_PASSWORD_Y-FX_LOGIN_STATUS_H+5, FX_LOGIN_PASSWORD_WIDTH, FX_LOGIN_PASSWORD_HEIGHT) ground_image:REGIST_TXT_INPUT_IMG icon_image:REGIST_TXT_KEY_IMG];
    [password_field do_set_placeholder_string:@"密码"];
    [password_field do_set_keyboard_type:UIKeyboardTypeAlphabet];
    [password_field setKeyBoardReturnType:UIReturnKeyDone];
    [password_field do_set_background_editing_did_begin_image:REGIST_TEXT_BOX_WHITE_IMG editing_did_end_image:REGIST_TEXT_BOX_IMG];
    [password_field do_set_text_secured:YES];
    password_field.edit_limit_int = 30;
    password_field.last_limit_int = 20;
    [password_field setDelegate:self];

    UIImage * forget_image = [UIImage imageNamed:FX_LOGIN_IMG_FORGET];
    UIImage * forget_image_hover = [UIImage imageNamed:FX_LOGIN_IMG_FORGET_HOVER];
    CGImageRef forget_image_ref = forget_image.CGImage;
    float forget_w = (float)CGImageGetWidth(forget_image_ref);
    float forget_h = (float)CGImageGetHeight(forget_image_ref);
    forget_password_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [forget_password_button setFrame:CGRectMake(FX_HELP_PWD_BUTTON_X, FX_HELP_PWD_BUTTON_Y-FX_LOGIN_STATUS_H+5, forget_w/2, forget_h/2)];
    [forget_password_button addTarget:self action:@selector(do_ui_action_find_password) forControlEvents:UIControlEventTouchUpInside];
    [forget_password_button setImage:forget_image forState:UIControlStateNormal];
    [forget_password_button setImage:forget_image_hover forState:UIControlStateHighlighted];
    //CGImageRelease(forget_image_ref);

    
    UIImage * image_login = [UIImage imageNamed:FX_LOGIN_IMG_LOGIN];
    UIImage * image_login_hover = [UIImage imageNamed:FX_LOGIN_IMG_LOGIN_HOVER];
    CGImageRef  image_login_ref = image_login.CGImage;
    CGFloat image_login_w = CGImageGetWidth(image_login_ref);
    CGFloat image_login_h = CGImageGetHeight(image_login_ref);
    login_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [login_button setFrame:CGRectMake(FX_LOGIN_BUTTON_X, FX_LOGIN_BUTTON_Y-FX_LOGIN_STATUS_H, image_login_w/2, image_login_h/2)];
    [login_button addTarget:self action:@selector(do_ui_action_login) forControlEvents:UIControlEventTouchUpInside];
    [login_button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [login_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [login_button setTitle:@"登录" forState:UIControlStateNormal];
    [login_button setBackgroundImage:image_login forState:UIControlStateNormal];
    [login_button setBackgroundImage:image_login_hover forState:UIControlStateHighlighted];
    //CGImageRelease(image_login_ref);

    
    UIImage * image_regist = [UIImage imageNamed:FX_LOGIN_IMG_SIGN];
    UIImage * image_regist_hover = [UIImage imageNamed:FX_LOGIN_IMG_SIGN_HOVER];
    CGImageRef image_regist_ref = image_regist.CGImage;
    CGFloat image_regist_w = CGImageGetWidth(image_regist_ref);
    CGFloat image_regist_h = CGImageGetHeight(image_regist_ref);
    regist_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [regist_button setFrame:CGRectMake(FX_REGIST_BUTTON_X, FX_REGIST_BUTTON_Y-FX_LOGIN_STATUS_H, image_regist_w/2, image_regist_h/2)];
    [regist_button addTarget:self action:@selector(do_ui_action_regist) forControlEvents:UIControlEventTouchUpInside];
    [regist_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [regist_button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [regist_button.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [regist_button setTitle:@"注册" forState:UIControlStateNormal];
    [regist_button setBackgroundImage:image_regist forState:UIControlStateNormal];
    [regist_button setBackgroundImage:image_regist_hover forState:UIControlStateHighlighted];
    //CGImageRelease(image_regist_ref);

}
- (void)do_load_subviews{
    [body_view addSubview:_logo_image_view];
    [body_view addSubview:username_field];
    [body_view addSubview:password_field];
    [body_view addSubview:forget_password_button];
    [body_view addSubview:login_button];
    [body_view addSubview:regist_button];
}

#pragma mark ForgetPasswordPanel
- (void)do_init_forget_password_panel{
    forget_password_panel = [[FXForgetPasswordPanel alloc] initWithFrame:CGRectMake(FX_FORGET_PASSWORD_PANEL_X, FX_FORGET_PASSWORD_PANEL_Y-FX_LOGIN_STATUS_H, FX_FORGET_PASSWORD_PANEL_WIDTH, FX_FORGET_PASSWORD_PANEL_HEIGHT)];
    [forget_password_panel setDelegate:self];
}
- (void)do_destory_forget_password_panel{
    forget_password_panel = nil;
}
- (void)do_show_forget_password_panel{
    if(forget_password_panel == nil){
        [self do_init_forget_password_panel];
    }
    rised_forget_panel = YES;
    /*
        找回密码面板监听
     */
    [forget_password_panel doAddObserver];
    [self.view addSubview:forget_password_panel];
    [UIView animateWithDuration:FX_FORGET_PASSWORD_PANEL_SPEED animations:^{
        forget_password_panel.alpha = 0;
        forget_password_panel.alpha = 1;
    }];
    
    [forget_password_panel.username_field do_show_keyboard];
}
- (void)do_hide_forget_password_panel{
    rised_forget_panel = NO;
    [UIView animateWithDuration:FX_FORGET_PASSWORD_PANEL_SPEED animations:^{
        forget_password_panel.alpha = 1;
        forget_password_panel.alpha = 0;
    }];
    [forget_password_panel do_hide_keyboard];
    [forget_password_panel removeFromSuperview];
    if(forget_password_panel != nil){
        [self do_destory_forget_password_panel];
    }
    [forget_password_panel doRemoveObserver];
}
#pragma mark Observer
- (void)do_add_observer{
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"loginCode" options:0 context:@"loginCode"];
}
- (void)do_remove_observer{
    [[CPUIModelManagement sharedInstance ] removeObserver:self forKeyPath:@"loginCode"];
}
#pragma mark Action

- (void)do_hide_keyboard{
    [username_field do_hide_keyboard];
    [password_field do_hide_keyboard];
}

- (void)do_lock_main_view{
    [login_button setEnabled:NO];
    [regist_button setEnabled:NO];
    [username_field do_lock_editing];
    [password_field do_lock_editing];
}
- (void)do_unlock_main_view{
    [login_button setEnabled:YES];
    [regist_button setEnabled:YES];
    [username_field do_unlock_editing];
    [password_field do_unlock_editing];
}

- (void)do_ui_action_login{
    if(rised_toptip == NO){
        if ([model_management canConnectToNetwork]==NO) {
            [self do_show_toptip_view_toptip_string:@"联网失败,请检查网络!"];
        }
        else{
            [self do_hide_keyboard];
            NSString * name_string = username_field.text;
            NSString * pwd_string = password_field.text;
            if([name_string length]<=0 && [pwd_string length]<=0){
                [username_field do_shake];
                [password_field do_shake];
                [self do_show_toptip_view_toptip_string:@"用户名不能为空"];
            }
            if([name_string length]<=0 && [pwd_string length] >0){
                [username_field do_shake];
                 [self do_show_toptip_view_toptip_string:@"用户名不能为空"];
            }
            if([pwd_string length]<=0 && [name_string length] >0){
                [password_field do_shake];
                [self do_show_toptip_view_toptip_string:@"密码不能为空"];
            }
            if([name_string length]>0&&[pwd_string length]>0){
                self.username_string = name_string;
                self.password_string = pwd_string;
                [self do_data_action_login];
                [self do_show_loading_view_content_string:@"稍等哦..."];
            }
        }
    }
    else{
        return;
    }
}
- (void)do_ui_action_regist{
    if(rised_forget_panel == NO){
        RegistHelper *helper=[RegistHelper defaultHelper];
        if ([helper getProerty:@"account"]!=nil) {
            [helper RemovePropertyForKey:@"account"];
            //account.shake_text_field.text = (NSString *)[helper getProerty:@"account"];
        }
        if ([helper getProerty:@"pwd"]!=nil) {
            [helper RemovePropertyForKey:@"pwd"];
            //password.shake_text_field.text=(NSString *)[helper getProerty:@"pwd"];
        }
        
        
        if ([helper getProerty:@"mobile"]!=nil) {
            [helper RemovePropertyForKey:@"mobile"];
            //mobilenumber.shake_text_field.text=(NSString *)[helper getProerty:@"mobile"];
        }
        RegistFirstViewController *rvc=[[RegistFirstViewController alloc] init];
        [self.navigationController pushViewController:rvc animated:YES];
        rvc = nil;
    }
    else{
        [self do_hide_forget_password_panel];
        RegistFirstViewController *rvc=[[RegistFirstViewController alloc] init];
        [self.navigationController pushViewController:rvc animated:YES];
        rvc = nil;
    }
}
- (void)do_ui_action_find_password{
    [self do_unlock_main_view];
    [self do_show_forget_password_panel];
}
- (void)do_goto_ground{
    
    /*
     GroundViewController * ground_c = [[GroundViewController alloc] initWithNibName:nil bundle:nil];
     [self.navigationController pushViewController:ground_c animated:YES];
     ground_c = nil;
     */
    [self.navigationController popViewControllerAnimated:NO];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate; 
    [appDelegate launchApp];
     
}

- (void)do_goto_verify{
    model_management = [CPUIModelManagement sharedInstance];
    CPLGModelAccount * model_account = [model_management getCurrentAccountModel];
    NSString * mobile_string = model_management.uiPersonalInfo.mobileNumber;
    NSString * image_path = [model_account getSelfBgFilePath];
    UIImage * bg_imge = [UIImage imageWithContentsOfFile:image_path];
    if(bg_imge == nil){
        bg_imge = REGIST_DEFAULT_IMG;
    }
//    VerifyViewCodeController * verify_c = [[VerifyViewCodeController alloc] initWithNibName:nil bundle:nil region_string:nil mobile_string:mobile_string top_image:bg_imge];
//    [self.navigationController pushViewController:verify_c animated:YES];
//    verify_c = nil;
}
- (void)do_goto_forget{
    
}
#pragma mark data_action
- (void)do_data_action_login{
    [model_management loginWithName:self.username_string password:self.password_string];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([@"loginCode" isEqualToString:keyPath])
    {
        
        NSInteger login_code_int = model_management.loginCode;
        NSString * loign_desc_string = model_management.loginDesc;
        
        if(login_code_int == 0){
#ifndef SYS_STATE_MIGR
            NSInteger sys_on_int = model_management.sysOnlineStatus;
            if(sys_on_int == SYS_STATUS_NO_ACTIVE){
                /*
                 激活
                 */
                [self do_hide_loading_view];
                [self do_show_toptip_view_toptip_string:@"去激活!"];
                [self do_goto_verify];
            }
            else{
                /*
                 已经登录
                 */
                [self do_hide_loading_view];
                [self do_show_toptip_view_toptip_string:@"成功登录"];
                [self do_goto_ground];
            }
#else
            NSInteger accState = model_management.accountState;
            if( ACCOUNT_STATE_INACTIVE == accState )
            {
                /*
                 激活
                 */
                [self do_hide_loading_view];
                [self do_show_toptip_view_toptip_string:@"去激活!"];
                [self do_goto_verify];
            }
            else
            {
                /*
                 已经登录
                 */
                [self do_hide_loading_view];
                [self do_show_toptip_view_toptip_string:@"成功登录"];
                [self do_goto_ground];
            }
#endif
        }
        else{
            /*
             登录失败
             */
            [self do_hide_loading_view];
            [username_field do_shake];
            [password_field do_shake];
            [self do_show_toptip_view_toptip_string:loign_desc_string];
        }
        
    }
}


#pragma mark ForgetPasswordDelegate
- (void)actionForgetPanelWillGetPassword{
    [self do_show_loading_view_content_string:@"正在重新获取密码"];
}
- (void)actionForgetPanelDidGetPasswordFailWithErrorString:(NSString *)errorString{
    [self do_hide_loading_view];
    [self do_show_toptip_view_toptip_string:errorString];
}
- (void)forget_password_did_send_username_string:(NSString *)username_string mobile_string:(NSString *)mobile_string{
    if(rised_forget_panel == YES){
        [self do_hide_loading_view];
        [self do_unlock_main_view];
        CPLogInfo(@"push_forget_c");
        ForgetViewController *  forget_c = [[ForgetViewController alloc] initWithNibName:nil bundle:nil username_string:username_string mobile_string:mobile_string];
        [self.navigationController pushViewController:forget_c animated:YES];
        rised_forget_panel = NO;
    }
    else{
        return;
    }

}
- (void)forget_password_panel_did_hide{
    [forget_password_panel do_clear_input_field];
    [self do_unlock_main_view];
    [self do_hide_forget_password_panel];
    rised_forget_panel = NO;
}
#pragma mark UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
#pragma mark FXShakeFieldDelegate
- (void)shake_field_did_begin_editing:(UITextField *)text_field{
    /*
    if(rised_main_view == NO){
        [self do_rise_main_view];
    }
    else{
        return;
    }
     */
}
- (void)shake_field_did_end_editing:(UITextField *)text_field{
    
}
- (void)shake_field_should_return:(UITextField *)text_field{
    if([text_field isEqual:username_field.shake_text_field]== YES){
        [password_field.shake_text_field becomeFirstResponder];
    }
    else{
        [self do_hide_keyboard];
        [self do_ui_action_login];
    }
}
- (void)shake_field_did_text_edit:(UITextField *)text_field{
    
}
@end
