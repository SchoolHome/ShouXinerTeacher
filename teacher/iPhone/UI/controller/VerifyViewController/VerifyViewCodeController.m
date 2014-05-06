//
//  VerifyViewCodeController.m
//  iCouple
//
//  Created by 振杰 李 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VerifyViewCodeController.h"
#import "FXVideoView.h"
#import "FXMobilePanel.h"
#import "FXCountDown.h"
#import "FanxerHeader.h"
#import "CPUIModelManagement.h"
#import "CPLGModelAccount.h"
#import "FXChangeMobilePanel.h"

//#import "GroundViewController.h"
#import "LoginViewController.h"
#import "RegistFirstViewController.h"

#import "HomePageViewController.h"
#import "RegistViewController.h"
#import "FXTopTipPanelDelegate.h"
#import "CPUIModelManagement.h"
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

#define FX_VERIFY_MAIN_VIEW_X 0
#define FX_VERIFY_MAIN_VIEW_Y 0
#define FX_VERIFY_MAIN_VIEW_W 320
#define FX_VERIFY_MAIN_VIEW_H 460

#define FX_VERIFY_BODY_VIEW_X 0
#define FX_VERIFY_BODY_VIEW_Y 86/2
#define FX_VERIFY_BODY_VIEW_W 320
#define FX_VERIFY_BODY_VIEW_H 920/2
#define FX_VERIFY_BODY_VIEW_L 200
#define FX_VERIFY_BODY_VIEW_ANIMATION_DURATION 0.6

#define FX_VERIFY_TOP_IMAGE_X 0
#define FX_VERIFY_TOP_IMAGE_Y 0
#define FX_VERIFY_TOP_IMAGE_W 640/2
#define FX_VERIFY_TOP_IMAGE_H 86/2



#define FX_VERIFY_CHANGE_MOBILE_BUTTON_X 9/2
#define FX_VERIFY_CHANGE_MOBILE_BUTTON_Y 47/2
#define FX_VERIFY_CHANGE_MOBILE_BUTTON_WIDTH 163/2
#define FX_VERIFY_CHANGE_MOBILE_BUTTON_HEIGHT 74/2

#define FX_VERIFY_CHANGE_MOBILE_PANEL_X 63/2
#define FX_VERIFY_CHANGE_MOBILE_PANEL_Y 144/2
#define FX_VERIFY_CHANGE_MOBILE_PANEL_W 515/2
#define FX_VERIFY_CHANGE_MOBILE_PANEL_H 355/2
#define FX_VERIFY_CHANGE_MOBILE_SHOW_ALPHA 1
#define FX_VERIFY_CHANGE_MOBILE_HIDE_ALPHA 0
#define FX_VERIFY_CHANGE_MOBILE_ANIMATION_DURATION 0.6

#define FX_VERIFY_VIDEO_VIEW_X 32/2
#define FX_VERIFY_VIDEO_VIEW_Y 23/2
#define FX_VERIFY_VIDEO_VIEW_WIDTH 575/2
#define FX_VERIFY_VIDEO_VIEW_HEIGHT 382/2

#define FX_VERIFY_MOBILE_PANEL_X 0
#define FX_VERIFY_MOBILE_PANEL_Y 555/2
#define FX_VERIFY_MOBILE_PANEL_WIDTH 320
#define FX_VERIFY_MOBILE_PANEL_HEIGHT 36/2

#define FX_VERIFY_CODE_FIELD_X 170/2
#define FX_VERIFY_CODE_FIELD_Y 602/2
#define FX_VERIFY_CODE_FIELD_WIDTH 276/2
#define FX_VERIFY_CODE_FIELD_HEIGHT 71/2

#define FX_VERIFY_COUNT_DOWN_X 240/2
#define FX_VERIFY_COUNT_DOWN_Y 702/2
#define FX_VERIFY_COUNT_DOWN_WIDTH 160/2
#define FX_VERIFY_COUNT_DOWN_HEIGHT 26/2

#define FX_RESEND_BUTTON_X 203/2
#define FX_RESEND_BUTTON_Y 691/2
#define FX_RESEND_BUTTON_W 230/2
#define FX_RESEND_BUTTON_H 60/2

#define FX_VERIFY_BOTTOM_VIEW_X 0
#define FX_VERIFY_BOTTOM_VIEW_Y 774/2
#define FX_VERIFY_BOTTOM_VIEW_WIDTH 640/2
#define FX_VERIFY_BOTTOM_VIEW_HEIGHT 186/2

#define FX_VERIFY_LAUNCH_BUTTON_X 150/2
#define FX_VERIFY_LAUNCH_BUTTON_Y 819/2
#define FX_VERIFY_LAUNCH_BUTTON_WIDTH 341/2
#define FX_VERIFY_LAUNCH_BUTTON_HEIGHT 101/2

#define FX_VERIFY_REGIST_BUTTON_X 240
#define FX_VERIFY_REGIST_BUTTON_Y 310
#define FX_VERIFY_REGIST_BUTTON_W 100
#define FX_VERIFY_REGIST_BUTTON_H 50

#define FX_VERIFY_TOP_H 86/2
#define FX_VERIFY_STATUS_H 40/2
#define FX_VERIFY_COUNT_DOWN_INTERVAL 60


#import "AppDelegate.h"
@implementation VerifyViewCodeController
@synthesize end_region_string = _end_region_string;
@synthesize end_mobile_string = _end_mobile_string;
@synthesize end_verify_string = _end_verify_string;
@synthesize end_top_image = _end_top_image;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil region_string:(NSString *)region_string mobile_string:(NSString *)mobile_string top_image:(UIImage *)top_image{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
  
        self.end_region_string= @"+86";
        
        if(mobile_string != nil){
            self.end_mobile_string = mobile_string;
            have_mobile = YES;
        }
        else{
            have_mobile = NO;
        }
        
        
        CGRect crop_frame = CGRectMake(FX_VERIFY_TOP_IMAGE_X, FX_VERIFY_TOP_IMAGE_Y, FX_VERIFY_TOP_IMAGE_W, FX_VERIFY_TOP_IMAGE_H);
        CGImageRef crop_image_ref = CGImageCreateWithImageInRect(top_image.CGImage, crop_frame);
        self.end_top_image = [UIImage imageWithCGImage:crop_image_ref];
        CGImageRelease(crop_image_ref);
        
    }
    return self;
}
- (void)dealloc{
    
    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
     进入填写验证码绑定手机页面的用户数 调用（1）
     */
    
    [self do_add_observer];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self do_remove_observer];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

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
    [self do_init_body_subview];
    [self do_init_top_image_view];
    [self do_init_top_control_view];
    [self do_init_loading_view];
    [self do_init_toptip_view];
    
    [self do_load_body_view];
    [self do_load_body_subview];
    [self do_load_top_image_view];
    [self loadNav];
    [self do_load_top_control_view];
    [self do_set_subview_align_center];
        
    if(have_mobile == NO){
        [self do_show_change_mobile_panel];
    }
    else{
        [self do_show_mobile_info_panel];
        [self do_active_count_down];
    }
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark Config
- (void)do_init_config{
    rised_main_view = NO;
    rised_change_mobile = NO;
    rised_count_down = NO;
    rised_mobile_info_panel = NO;
    model_management = [CPUIModelManagement sharedInstance];
}
#pragma mark init_view
- (void)do_init_main_view{
    UIView * main_view_temp = [[UIView alloc] initWithFrame:FXRect(FX_VERIFY_MAIN_VIEW_X, FX_VERIFY_MAIN_VIEW_Y, FX_VERIFY_MAIN_VIEW_W, FX_VERIFY_MAIN_VIEW_H)];
    [main_view_temp setBackgroundColor:[UIColor blackColor]];
    self.view = main_view_temp;
    main_view_temp = nil;
}
- (void)do_init_top_image_view{
    top_image_view = [[UIImageView alloc] initWithImage:self.end_top_image];
    [top_image_view setFrame:CGRectMake(FX_VERIFY_TOP_IMAGE_X, FX_VERIFY_TOP_IMAGE_Y, FX_VERIFY_TOP_IMAGE_W, FX_VERIFY_TOP_IMAGE_H)];
    [top_image_view setUserInteractionEnabled:YES];
}
- (void)do_init_top_control_view{
    change_mobile_number_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [change_mobile_number_button setFrame:CGRectMake(FX_VERIFY_CHANGE_MOBILE_BUTTON_X , FX_VERIFY_CHANGE_MOBILE_BUTTON_Y-FX_VERIFY_STATUS_H , FX_VERIFY_CHANGE_MOBILE_BUTTON_WIDTH, FX_VERIFY_CHANGE_MOBILE_BUTTON_HEIGHT)];
    [change_mobile_number_button setTitle:@"修改手机号" forState:UIControlStateNormal];
    [change_mobile_number_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [change_mobile_number_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [change_mobile_number_button setBackgroundImage:[UIImage imageNamed:FX_VERIFY_CHANGE_MOBILE] forState:UIControlStateNormal];
    [change_mobile_number_button setBackgroundImage:[UIImage imageNamed:FX_VERIFY_CHANGE_MOBILE] forState:UIControlStateDisabled];
    [change_mobile_number_button setBackgroundImage:[UIImage imageNamed:FX_VERIFY_CHANGE_MOBILE_HOVER] forState:UIControlStateHighlighted];
    [change_mobile_number_button addTarget:self action:@selector(do_ui_action_change_mobile_number) forControlEvents:UIControlEventTouchUpInside];
}
- (void)do_init_body_view{
    body_view = [[UIView alloc] initWithFrame:FXRect(FX_VERIFY_BODY_VIEW_X, FX_VERIFY_BODY_VIEW_Y, FX_VERIFY_BODY_VIEW_W, FX_VERIFY_BODY_VIEW_H)];
    [body_view setBackgroundColor:[UIColor colorWithHexString:@"#FFFEF6"]];
}
- (void)do_init_body_subview{
    video_view = [[FXVideoView alloc] initWithFrame:CGRectMake(FX_VERIFY_VIDEO_VIEW_X, FX_VERIFY_VIDEO_VIEW_Y, FX_VERIFY_VIDEO_VIEW_WIDTH, FX_VERIFY_VIDEO_VIEW_HEIGHT)];
    [video_view do_set_background_image:[UIImage imageNamed:FX_VERIFY_VIDEO_BG]];
    
    mobile_panel = [[FXMobilePanel alloc] initWithFrame:CGRectMake(FX_VERIFY_MOBILE_PANEL_X, FX_VERIFY_MOBILE_PANEL_Y-FX_VERIFY_TOP_H-FX_VERIFY_STATUS_H, FX_VERIFY_MOBILE_PANEL_WIDTH, FX_VERIFY_MOBILE_PANEL_HEIGHT)];
    [mobile_panel.info_label_left setText:@"已向手机号码"];
    NSString * end_number_string = [NSString stringWithFormat:@"%@ %@",self.end_region_string,self.end_mobile_string];
    [mobile_panel.info_label_number setText:end_number_string];
    [mobile_panel.info_label_right setText:@"发送验证码短信"];
    
    code_field = [[FXShakeField alloc] initWithFrame:CGRectMake(FX_VERIFY_CODE_FIELD_X, FX_VERIFY_CODE_FIELD_Y-FX_VERIFY_TOP_H-FX_VERIFY_STATUS_H, FX_VERIFY_CODE_FIELD_WIDTH, FX_VERIFY_CODE_FIELD_HEIGHT) ground_image:REGIST_TXT_INPUT_IMG];
    [code_field.shake_text_field setCenter:CGPointMake(code_field.shake_text_field.center.x, code_field.shake_text_field.center.y-5)];
    [code_field do_set_text_alignment:UITextAlignmentCenter];
    [code_field.shake_text_field setKeyboardType:UIKeyboardTypeNumberPad];
    [code_field.shake_text_field setReturnKeyType:UIReturnKeyDone];
    [code_field.shake_text_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [code_field.shake_text_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [code_field do_set_placeholder_string:@"填写验证码"];
   // [code_field do_set_text_length_limit_int:4];
    code_field.edit_limit_int = 4;
    code_field.last_limit_int = 4;
    [code_field do_set_background_editing_did_begin_image:REGIST_TEXT_PHONE_WHITE_IMG editing_did_end_image:REGIST_TEXT_PHONE_IMG];
    [code_field setDelegate:self];
    
    
    count_down = [[FXCountDown alloc] initWithFrame:CGRectMake(FX_VERIFY_COUNT_DOWN_X, FX_VERIFY_COUNT_DOWN_Y-FX_VERIFY_TOP_H-FX_VERIFY_STATUS_H, FX_VERIFY_COUNT_DOWN_WIDTH, FX_VERIFY_COUNT_DOWN_HEIGHT) beginNum:FX_VERIFY_COUNT_DOWN_INTERVAL interval:1 txtColor:[UIColor blackColor] disKey:@"s"];
    [count_down setDelegate:self];
    
    
    UIImage * resend_image = [UIImage imageNamed:FX_VERIFY_SENDSMS];
    UIImage * resend_image_hover = [UIImage imageNamed:FX_VERIFY_SENDSMS_HOVER];
    CGImageRef resend_image_ref = [resend_image CGImage];
    CGFloat resend_image_w = CGImageGetWidth(resend_image_ref);
    CGFloat resend_image_h = CGImageGetHeight(resend_image_ref);
    resend_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [resend_button setFrame:CGRectMake(FX_RESEND_BUTTON_X, FX_RESEND_BUTTON_Y-FX_VERIFY_TOP_H-FX_VERIFY_STATUS_H, resend_image_w/2, resend_image_h/2)];
    [resend_button setBackgroundImage:resend_image forState:UIControlStateNormal];
    [resend_button setBackgroundImage:resend_image forState:UIControlStateDisabled];
    [resend_button setBackgroundImage:resend_image_hover forState:UIControlStateHighlighted];
    [resend_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [resend_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [resend_button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [resend_button setTitle:@"重新获取验证码" forState:UIControlStateNormal];
    [resend_button setTitle:@"重新获取验证码" forState:UIControlStateHighlighted];
    [resend_button addTarget:self action:@selector(do_ui_action_resend_verify_code) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage * bottom_image = [UIImage imageNamed:FX_VERIFY_BOTTOM_IMG];
    CGImageRef bottom_image_ref = [bottom_image CGImage];
    CGFloat bottom_image_w = CGImageGetWidth(bottom_image_ref);
    CGFloat bottom_image_h = CGImageGetHeight(bottom_image_ref);
    bottom_view = [[UIImageView alloc] initWithFrame:CGRectMake(FX_VERIFY_BOTTOM_VIEW_X, FX_VERIFY_BOTTOM_VIEW_Y-FX_VERIFY_TOP_H-FX_VERIFY_STATUS_H, bottom_image_w/2, bottom_image_h/2)];
    [bottom_view setImage:bottom_image];
    [bottom_view setUserInteractionEnabled:YES];
    
    
    UIImage * launch_image = [UIImage imageNamed:FX_VERIFY_USE];
    UIImage * launch_image_hover = [UIImage imageNamed:FX_VERIFY_USE_HOVER];
    CGImageRef launch_image_ref = [launch_image CGImage];
    CGFloat launch_image_w = CGImageGetWidth(launch_image_ref);
    CGFloat launch_image_h = CGImageGetHeight(launch_image_ref);
    launch_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [launch_button setFrame:CGRectMake(FX_VERIFY_LAUNCH_BUTTON_X, FX_VERIFY_LAUNCH_BUTTON_Y-FX_VERIFY_TOP_H-FX_VERIFY_STATUS_H, launch_image_w/2, launch_image_h/2)];
    [launch_button setBackgroundImage:launch_image forState:UIControlStateNormal];
    [launch_button setBackgroundImage:launch_image forState:UIControlStateDisabled];
    [launch_button setBackgroundImage:launch_image_hover forState:UIControlStateHighlighted];
    [launch_button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [launch_button setTitle:@"开始使用双双" forState:UIControlStateNormal];
    [launch_button addTarget:self action:@selector(do_ui_action_launch) forControlEvents:UIControlEventTouchUpInside];
    
    

    regist_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [regist_button setFrame:CGRectMake(FX_VERIFY_REGIST_BUTTON_X, FX_VERIFY_REGIST_BUTTON_Y, FX_VERIFY_REGIST_BUTTON_W, FX_VERIFY_REGIST_BUTTON_H)];
    [regist_button setTitle:@"重新注册" forState:UIControlStateNormal];
    [regist_button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [regist_button setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [regist_button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [regist_button addTarget:self action:@selector(do_ui_action_regist) forControlEvents:UIControlEventTouchUpInside];
    
}
#pragma mark load_view
- (void)do_load_top_image_view{
    [self.view addSubview:top_image_view];
}
- (void)do_load_top_control_view{
    [self.view addSubview:change_mobile_number_button];
}
- (void)do_load_body_view{
    [self.view addSubview:body_view];
}
- (void)do_load_body_subview{
    [body_view addSubview:video_view];
    [body_view addSubview:code_field];
    [body_view addSubview:count_down];
    [body_view addSubview:bottom_view];
    [body_view addSubview:launch_button];
    [body_view addSubview:regist_button];
    
}
-(void)loadNav{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NavigationBothStyle *style=[[NavigationBothStyle alloc] initWithTitle:@"" Leftcontrol:nil Rightcontrol:nil];
    process=[[FxProcessFixed alloc] initWithFrame:FXRect(PR_X, PR_Y, PR_WIDTH, PR_HIGH) withstep:2 withtitle:@"进入双双"];
    fnav =[[FanxerNavigationBarControl alloc] initWithFrame:FXRect(NAV_X, NAV_Y, NAV_WIDTH, NAV_HIGH) withStyle:style withDefinedUserControl:YES];
    fnav._delegate=self;
    [fnav addSubview:process];
    [self.view addSubview:fnav];
}
- (void)do_set_subview_align_center{
    CGPoint video_view_center = video_view.center;
    [video_view setCenter:CGPointMake(160, video_view_center.y)];
    
    CGPoint mobile_panel_center = mobile_panel.center;
    [mobile_panel setCenter:CGPointMake(160, mobile_panel_center.y)];
    
    CGPoint code_field_center = code_field.center;
    [code_field setCenter:CGPointMake(160, code_field_center.y)];
    
    CGPoint resend_button_center = resend_button.center;
    [resend_button setCenter:CGPointMake(160, resend_button_center.y)];
    
    CGPoint launch_button_center = launch_button.center;
    [launch_button setCenter:CGPointMake(160, launch_button_center.y)];
}


#pragma mark -
#pragma mark FanxerNavigationBarDelegate method

-(void)doLeft{
    
}

-(void)doRight{
    
    
}
#pragma mark FXTopTipPanel
- (void)do_init_toptip_view{
    [super do_init_toptip_view];
    [toptippanel setDelegate:self];
}
- (void)action_toptip_did_show{
    [self do_lock_main_view];
}
- (void)action_toptip_did_hide{
    [self do_unlock_main_view];
}
#pragma mark FXShakeFieldDelegate
- (void)shake_field_did_begin_editing:(UITextField *)text_field{
    //[code_field.shake_text_field  setText:@" "];
    if(rised_main_view == NO){
        [self do_rise_body_view];
    }
    else{
        return;
    }
}
- (void)shake_field_did_end_editing:(UITextField *)text_field{
    if(rised_main_view == YES){
        [self do_drop_body_view];
    }
    else{
        return;
    }
}
- (void)shake_field_should_return:(UITextField *)text_field{
    
}
- (void)shake_field_did_text_edit:(UITextField *)text_field{
    
}
#pragma mark count_down
- (void)do_active_count_down{
    if(resend_button.superview == body_view){
        [resend_button removeFromSuperview];
    }
    count_down.number = FX_VERIFY_COUNT_DOWN_INTERVAL;
    [count_down StartCountDown];
    rised_count_down = YES;
}
- (void)do_unactive_count_down{
    count_down.number = FX_VERIFY_COUNT_DOWN_INTERVAL;
    [count_down StopCountDown];
    [body_view addSubview:resend_button];
    rised_count_down = NO;
}
- (void)do_reset_count_down{
    count_down.number = FX_VERIFY_COUNT_DOWN_INTERVAL;
}
#pragma mark CountDownDelegate
-(void)endNotify{
    [self do_unactive_count_down];
}
#pragma mark body_view_rise
- (void)do_rise_body_view{
    [UIView animateWithDuration:FX_VERIFY_BODY_VIEW_ANIMATION_DURATION animations:^{
        body_view.frame = CGRectMake(FX_VERIFY_BODY_VIEW_X, FX_VERIFY_BODY_VIEW_Y, FX_VERIFY_BODY_VIEW_W,FX_VERIFY_BODY_VIEW_H);
        body_view.frame = CGRectMake(FX_VERIFY_BODY_VIEW_X, FX_VERIFY_BODY_VIEW_Y-FX_VERIFY_BODY_VIEW_L, FX_VERIFY_BODY_VIEW_W, FX_VERIFY_BODY_VIEW_H);
    }completion:^(BOOL finished){
        rised_main_view = YES;
    } ];
}
- (void)do_drop_body_view{
    [UIView animateWithDuration:FX_VERIFY_BODY_VIEW_ANIMATION_DURATION animations:^{
        body_view.frame = CGRectMake(FX_VERIFY_BODY_VIEW_X, FX_VERIFY_BODY_VIEW_Y-FX_VERIFY_BODY_VIEW_L, FX_VERIFY_BODY_VIEW_W,FX_VERIFY_BODY_VIEW_H);
        body_view.frame = CGRectMake(FX_VERIFY_BODY_VIEW_X, FX_VERIFY_BODY_VIEW_Y, FX_VERIFY_BODY_VIEW_W, FX_VERIFY_BODY_VIEW_H);
    }completion:^(BOOL finished){
        rised_main_view = NO;
    } ];
}
#pragma mark ChangeMobilePanel
- (void)do_init_change_mobile_panel{
    if(change_mobile_panel == nil){
        change_mobile_panel = [[FXChangeMobilePanel alloc] initWithFrame:CGRectMake(FX_VERIFY_CHANGE_MOBILE_PANEL_X, FX_VERIFY_CHANGE_MOBILE_PANEL_Y-FX_VERIFY_STATUS_H, FX_VERIFY_CHANGE_MOBILE_PANEL_W, FX_VERIFY_CHANGE_MOBILE_PANEL_H) region_string:self.end_region_string mobile_string:self.end_mobile_string];
        [change_mobile_panel setDelegate:self];
    }  
}
- (void)do_destory_change_mobile_panel{
    change_mobile_panel = nil;
}
- (void)do_show_change_mobile_panel{
    [self do_init_change_mobile_panel];
    [self.view addSubview:change_mobile_panel];
    [UIView animateWithDuration:FX_VERIFY_CHANGE_MOBILE_ANIMATION_DURATION animations:^{
        change_mobile_panel.alpha = FX_VERIFY_CHANGE_MOBILE_HIDE_ALPHA;
        change_mobile_panel.alpha = FX_VERIFY_CHANGE_MOBILE_SHOW_ALPHA;
    } completion:^(BOOL finished){
        rised_change_mobile = YES;
        [self do_lock_main_view];
    }];
}
- (void)do_hide_change_mobile_panel{
    [UIView animateWithDuration:FX_VERIFY_CHANGE_MOBILE_ANIMATION_DURATION animations:^{
        change_mobile_panel.alpha = FX_VERIFY_CHANGE_MOBILE_SHOW_ALPHA;
        change_mobile_panel.alpha = FX_VERIFY_CHANGE_MOBILE_HIDE_ALPHA;
    } completion:^(BOOL finished){
        [change_mobile_panel removeFromSuperview];
        rised_change_mobile = NO;
        [self do_unlock_main_view];
    }];
    [change_mobile_panel removeFromSuperview];
    [self do_destory_change_mobile_panel];
}
#pragma mark Mobile_Info_Panel
- (void)do_show_mobile_info_panel{
    [body_view addSubview:mobile_panel];
    rised_mobile_info_panel = YES;
}
- (void)do_hide_mobile_info_panel{
    [mobile_panel removeFromSuperview];
    rised_mobile_info_panel = NO;
}
- (void)do_set_mobile_info_panel{
    NSString * end_number_string = [NSString stringWithFormat:@"+86 %@",self.end_mobile_string];
    [mobile_panel.info_label_number setText:end_number_string];
}
#pragma mark Action
- (void)do_ui_action_change_mobile_number{
    [self do_show_change_mobile_panel];
}
- (void)do_ui_action_resend_verify_code{
    [self do_data_action_bind_user];
}
- (void)do_ui_action_launch{
    NSString * code_field_string = code_field.text;
    if([code_field_string length]<=0){
        [code_field do_shake];
        /*
         点击开始使用双双时，验证码为空 调用（2）
         */
        [self do_show_toptip_view_toptip_string:@"验证码不能为空"];
    }
    else{
        if([[CPUIModelManagement sharedInstance] canConnectToNetwork] == YES){
            [self do_data_action_active_user];
        }
        else{
            /*
             点击开始使用双双时，网络连接错误 调用（2）
             */
            [self do_show_toptip_view_toptip_string:@"网络连接失败!"];
        }
        
         
    }
}

- (void)do_ui_action_regist{
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
    [[CPUIModelManagement sharedInstance] clearAccountTagData];
    AppDelegate * app_delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [app_delegate do_launch_login];

    
}
#pragma mark DataAction

- (void)do_data_action_active_user{
    if([model_management canConnectToNetwork] == NO){
        [self do_show_toptip_view_toptip_string:@"联网失败，请检查网络！"];
    }
    else{
        NSString * verify_code_string = code_field.text;
        if([verify_code_string length]>0&&verify_code_string!=nil){
            [model_management activeAccountWithCode:verify_code_string];
        }else{
            
        }
        [self do_show_loading_view_content_string:@"稍等哦..."];
    }

}
- (void)do_data_action_bind_user{
    if([model_management canConnectToNetwork] == NO){
        [self do_show_toptip_view_toptip_string:@"联网失败，请检查网络！"];
    }
    else{
        /*
         点击重新获取验证码时，调用（1）
         */
        [model_management bindMobileNumber:self.end_mobile_string region_number:@"86"];
        [self do_show_loading_view_content_string:@"正在获得验证码"];
        [self do_active_count_down];
    }
}
#pragma mark Observer
- (void)do_add_observer{
    CPLogInfo("add observer");
    [model_management addObserver:self forKeyPath:@"activeCode" options:0 context:@"activeCode"];
    [model_management addObserver:self forKeyPath:@"bindCode" options:0 context:@"bindCode"];
}
- (void)do_remove_observer{
    CPLogInfo("remove observer");
    [model_management removeObserver:self forKeyPath:@"activeCode"];
    [model_management removeObserver:self forKeyPath:@"bindCode"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    /*
     激活用户
     */
    if([keyPath isEqualToString:@"activeCode"]){
        NSInteger result_code_active_int = model_management.activeCode;
        NSString * result_desc_string = model_management.activeDesc;
        CPLogInfo("active desc:%@", result_desc_string);
        if(result_code_active_int == 0){
            CPLogInfo("active success");
            [self do_hide_loading_view];
            [self do_show_toptip_view_toptip_string:@"激活用户成功!"];
            [code_field do_clear_text];
            have_mobile = YES;
            /*
             顺利完成填写验证码绑定手机页面 调用（1）
             */
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate do_launch_app];
        }
        else{
            CPLogInfo("active failure");
            /*
                点击开始使用双双时，验证码错误 调用（2）
             */
            [self do_hide_loading_view];
            [code_field do_shake];
            [self do_show_toptip_view_toptip_string:result_desc_string];
        }
    }
    /*
     重新发送验证码   绑定用户
     */
    else if([keyPath isEqualToString:@"bindCode"]){
        NSInteger result_code_bind_int = model_management.bindCode;
        NSString * result_desc_string = model_management.bindDesc;
        if(result_code_bind_int == 0){
            [self do_hide_change_mobile_panel];
            [self do_hide_loading_view];
            [self do_reset_count_down];
            [self do_set_mobile_info_panel];
            [self do_show_toptip_view_toptip_string:@"验证码已发送"];
        }
        else{
            [self do_hide_loading_view];
            [change_mobile_panel.mobile_field do_shake];
            [change_mobile_panel do_shake_country_button];
            [change_mobile_panel.mobile_field do_show_tip_info_string:result_desc_string];
        }
    }
}

#pragma mark Lock
- (void)do_lock_main_view{
    [code_field do_lock_editing];
    [launch_button setEnabled:NO];
    [regist_button setEnabled:NO];
    [resend_button setEnabled:NO];
    [change_mobile_number_button setEnabled:NO];
}
- (void)do_unlock_main_view{
    [code_field do_unlock_editing];
    [launch_button setEnabled:YES];
    [regist_button setEnabled:YES];
    [resend_button setEnabled:YES];
    [change_mobile_number_button setEnabled:YES];
}
#pragma mark UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [code_field do_hide_keyboard];
}
#pragma mark FXChangeMobilePanelDelegate
- (void)action_change_mobile_panel_did_close{
    [self do_hide_change_mobile_panel];
}
- (void)action_change_mobile_panel_did_pass_region_string:(NSString *)region_string mobile_string:(NSString *)mobile_string{
    self.end_region_string = region_string;
    self.end_mobile_string = mobile_string;
    [self do_data_action_bind_user];
}
@end
