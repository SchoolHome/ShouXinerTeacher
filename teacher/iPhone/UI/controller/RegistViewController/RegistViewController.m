//
//  RegistViewController.m
//  iCouple
//
//  Created by 振杰 李 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RegistViewController.h"

#import "FXShakeField.h"

#import "CPUIModelManagement.h"

#import "CPUIModelRegisterInfo.h"

#import "RegexKitLite.h"
#import "ProtocolController.h"

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


#define PART_ONE_X 0.0
#define PART_ONE_Y 0.0
#define PART_ONE_WIDTH 320
#define PART_ONE_HIGH 230

#define INPUT_ACCOUNT_X 105.0/2.0
#define INPUT_ACCOUNT_Y 45.0/2.0

#define INPUT_ACCOUNT_WIDTH 419.0/2.0
#define INPUT_ACCOUNT_HIGH 73.0/2.0

#define CHECK_BOX_WIDTH 23.0/2.0
#define CHECK_BOX_HIGH  21.0/2.0

#define FX_SHAKE_DURATION 0.05
#define FX_SHAKE_REPEATE 3
#define FX_SHAKE_LENGTH 20.0f

#define FX_SHAKE_ALERT_WIDTH 30
#define FX_SHAKE_ALERT_HEIGHT 30

#define MAX_COUNT 30
@interface RegistViewController (Private)

-(BOOL)doValidate;

-(void)DoCheck;


-(void)ChangeInputBg:(id)sender;


-(void)do_ShakeWithView:(UIView *)view;

-(void)WarnningTipShow;

-(void)WarnningTipHide;

- (void)doAddObserver;
- (void)doRemoveObserver;

@end

@implementation RegistViewController
//@synthesize verifycodecontroller;
@synthesize fnav;

-(id)initWithRegistInfo:(RegistInfo *)registinfo{
    
    self=[super init];
    if (self) {
        regist=registinfo;       
        bgdict=[regist imgdict];
       
    }
    return self;
}
-(void)dealoc
{
}
- (void)doAddObserver{
    [[CPUIModelManagement sharedInstance] addObserver: self forKeyPath: @"registerCode" options: 0 context: @"registerCode" ];
}
- (void)doRemoveObserver{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"registerCode"];
}
- (void)do_ShakeWithView:(UIView *)view{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:FX_SHAKE_DURATION];
    [animation setRepeatCount:FX_SHAKE_REPEATE];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([view center].x - FX_SHAKE_LENGTH, [view center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([view center].x + FX_SHAKE_LENGTH, [view center].y)]];
    [[view layer] addAnimation:animation forKey:@"position"];
}

-(void)ChangeInputBg:(id)sender{
    
    FXShakeField *shakefield=(FXShakeField *)sender;
    if (shakefield.tag==201) {
        accountwarning.hidden=YES;
        accountwarninglabel.hidden=YES;
        account.shake_image_view.image=REGIST_TEXT_BOX_WHITE_IMG;
        account.shake_text_field.textColor=[UIColor blackColor];
    }
    if (shakefield.tag==202) {
        passwordwarning.hidden=YES;
        passwordwarninglabel.hidden=YES;
        password.shake_image_view.image=REGIST_TEXT_BOX_WHITE_IMG;
        password.shake_text_field.textColor=[UIColor blackColor];
    }
    if (shakefield.tag==203) {
        mobilewarring.hidden=YES;
        mobilewarringlabel.hidden=YES;
        mobilenumber.shake_image_view.image=REGIST_TEXT_PHONE_WHITE_IMG;
        mobilenumber.shake_text_field.textColor=[UIColor blackColor];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
     进入填写用户名密码页面 调用（1）
     */
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self doAddObserver];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self doRemoveObserver];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self initPartOne];
    [self loadNav];
}


-(void)loadNav{
    UIButton *leftbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftbutton.frame=FXRect(10, LEFT_Y, LEFT_WIDTH, LEFT_HIGH);
    [leftbutton setImage:REGIST_GOLEFT_NORMAL forState:UIControlStateNormal];
    [leftbutton setImage:REGIST_GOlEFT_HIGHLIGHT forState:UIControlStateHighlighted];
    UIButton *rightbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightbutton.frame=FXRect(RIGHT_X, RIGHT_Y, RIGHT_WIDTH, RIGHT_HIGH);
    [rightbutton setImage:REGIST_GORIGHT_NORMAL forState:UIControlStateNormal];
    [rightbutton setImage:REGIST_GORIGHT_HIGHTLIGHT forState:UIControlStateHighlighted];
    NavigationBothStyle *style=[[NavigationBothStyle alloc] initWithTitle:@"" Leftcontrol:leftbutton Rightcontrol:rightbutton];
    process=[[FxProcessFixed alloc] initWithFrame:FXRect(PR_X, PR_Y, PR_WIDTH, PR_HIGH) withstep:1 withtitle:@"完成注册"];
    fnav =[[FanxerNavigationBarControl alloc] initWithFrame:FXRect(NAV_X, NAV_Y, NAV_WIDTH, NAV_HIGH) withStyle:style withDefinedUserControl:YES];
    fnav._delegate=self;
    _topImage = fnav.backImage;
    //_topImage = [[UIImage alloc] initWithCGImage:fnav.backImage.CGImage];
    [fnav addSubview:process];
    [self.view addSubview:fnav];
    
    
    
    
    
    blockview=[[UIView alloc] initWithFrame:FXRect(0.0, 0.0, 320.0, 480.0)];
    

    
    blockview.alpha=0.0;
     
     
    fxind =[[FanxerIndicatorControl alloc] initWithFrame:FXRect(200.0/2.0, 181.0/2.0, 239.0/2.0, 175.0/2.0) message:@"稍等哦..."title:@"" bgimg:INDICATOR_BG];
    
    [blockview addSubview:fxind];
    toptippanel=[[FXTopTipPanel alloc] initWithFrame:FXRect(35.0, -46.0, 250, 46) message:@"联网失败，请检查网络！"];
    toptippanel.alpha=0.0;
    
    [self.view addSubview:toptippanel];
    [self.view addSubview:blockview];
    

}


-(void)initPartOne{
    
    
    
    helper=[RegistHelper defaultHelper];
    
    ischeck=YES;
    
    accountwarning=[[UIImageView alloc] initWithFrame:FXRect(487/2, INPUT_ACCOUNT_Y-17/2-5+4.0, 17, 17)];
    
    accountwarning.image=WARING_PNG;
    
    accountwarning.hidden=YES;
    
    accountwarninglabel=[[UILabel alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X, 110.0/2.0+1.0, 200, 17)];
    
    [accountwarninglabel setBackgroundColor:[UIColor clearColor]];
    
    [accountwarninglabel setTextColor:[UIColor colorWithHexString:@"#EA5032"]];
    
    [accountwarninglabel setTextAlignment:UITextAlignmentCenter];
    
    accountwarninglabel.hidden=YES;
    
    accountwarninglabel.font=[UIFont systemFontOfSize:10.0];
    
    
    passwordwarning=[[UIImageView alloc] initWithFrame:FXRect(487/2, (INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH+20-17/-2)-22+4.0, 17, 17)];
    
    passwordwarning.image=WARING_PNG;
    
    passwordwarning.hidden=YES;
    
    
    passwordwarninglabel=[[UILabel alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X, 220.0/2.0, INPUT_ACCOUNT_WIDTH, 17)];
    
    [passwordwarninglabel setBackgroundColor:[UIColor clearColor]];
    
    [passwordwarninglabel setFont:[UIFont systemFontOfSize:10.0]];
    
    [passwordwarninglabel setTextAlignment:UITextAlignmentCenter];
    
    [passwordwarninglabel setTextColor:[UIColor colorWithHexString:@"#EA5032"]];
    
    passwordwarninglabel.hidden=YES;
    
    mobilewarring=[[UIImageView alloc] initWithFrame:FXRect(487/2, (INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH*2+20*2-17/2)-5, 17, 17)];
    
    mobilewarring.image=WARING_PNG;
    
    mobilewarring.hidden=YES;
    
    mobilewarringlabel=[[UILabel alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X+129.0/2.0+5, 333.0/2-2, 279.0/2.0, 17)];
    
    [mobilewarringlabel setBackgroundColor:[UIColor clearColor]];
    
    [mobilewarringlabel setTextColor:[UIColor colorWithHexString:@"#EA5032"]];
    
    [mobilewarringlabel setTextAlignment:UITextAlignmentCenter];
    
    [mobilewarringlabel setFont:[UIFont systemFontOfSize:10.0]];
    
    mobilewarringlabel.hidden=YES;
    
    
    partoneview =[[UIView alloc] initWithFrame:FXRect(PART_ONE_X, NAV_HIGH, 320, 440)];
    

    
    
//    account =[[FXShakeField alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X,INPUT_ACCOUNT_Y-5,INPUT_ACCOUNT_WIDTH,INPUT_ACCOUNT_HIGH)
//                                    ground_image:REGIST_TEXT_BOX_IMG 
//                                      icon_image:REGIST_TXT_MAN_IMG];
    UIImageView *accountview=[[UIImageView alloc] initWithFrame:FXRect(11, 6, 25, 25)];
    
    accountview.image=REGIST_TXT_MAN_IMG;

    account =[[FXShakeField alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X,INPUT_ACCOUNT_Y-1,INPUT_ACCOUNT_WIDTH,INPUT_ACCOUNT_HIGH)
                                    ground_image:REGIST_TEXT_BOX_IMG
                                  icon_imageview:accountview];
    
    [account do_set_placeholder_string:@"账号  6－30个字母/数字"];
    
    if ([helper getProerty:@"account"]!=nil) {
        account.shake_text_field.text = (NSString *)[helper getProerty:@"account"];
    }
    
    [account.shake_text_field setKeyboardType:UIKeyboardTypeAlphabet];
    [account.shake_text_field setReturnKeyType:UIReturnKeyNext];
    [account.shake_text_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [account.shake_text_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    account.edit_limit_int = 30;
    account.last_limit_int = 30;
    //[account.shake_text_field addTarget:self action:@selector(LengthValidate:) forControlEvents:UIControlEventEditingChanged];
    [account.shake_text_field addTarget:self action:@selector(ChangeInputBg:) forControlEvents:UIControlEventEditingDidBegin];
    [account.shake_text_field addTarget:self action:@selector(SelfValidate:) forControlEvents:UIControlEventEditingDidEnd];
    
    
    account.shake_text_field.tag=201;
    
    [partoneview addSubview:account];
    
    
//    password =[[FXShakeField alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X, INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH+20-5, INPUT_ACCOUNT_WIDTH, INPUT_ACCOUNT_HIGH)
//                                     ground_image:REGIST_TEXT_BOX_IMG
//                                       icon_image:REGIST_TXT_KEY_IMG];

    UIImageView *passwordview=[[UIImageView alloc] initWithFrame:FXRect(11, 6, 25,25)];
    passwordview.image=REGIST_TXT_KEY_IMG;
    password =[[FXShakeField alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X, INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH+20-5+1, INPUT_ACCOUNT_WIDTH, INPUT_ACCOUNT_HIGH)
                                     ground_image:REGIST_TEXT_BOX_IMG
                                   icon_imageview:passwordview];
    [password do_set_placeholder_string:@"密码  6－30个字母/数字"];
    password.edit_limit_int = 30;
    password.last_limit_int = 30;
    
    if ([helper getProerty:@"pwd"]!=nil) {
        password.shake_text_field.text=(NSString *)[helper getProerty:@"pwd"];
    }
    
    [password.shake_text_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [password.shake_text_field addTarget:self action:@selector(LengthValidate:) forControlEvents:UIControlEventEditingChanged];
    [password.shake_text_field addTarget:self action:@selector(ChangeInputBg:) forControlEvents:UIControlEventEditingDidBegin];
    [password.shake_text_field addTarget:self action:@selector(SelfValidate:) forControlEvents:UIControlEventEditingDidEnd];
 
    
    
    password.shake_text_field.tag=202;
    
    [password.shake_text_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [password.shake_text_field setKeyboardType:UIKeyboardTypeAlphabet];
    
    [password.shake_text_field setReturnKeyType:UIReturnKeyNext];
    
    [partoneview addSubview:password];
    
    
    
    
    countrycode =[UIButton buttonWithType:UIButtonTypeCustom];
    
    
    
    countrycode.frame=FXRect(INPUT_ACCOUNT_X, INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH*2+20*2-8+1, 129.0/2.0, 73.0/2.0);
    
  
    
    [countrycode setTitle:@"+86" forState:UIControlStateNormal];
    
    [countrycode setTitle:@"+86" forState:UIControlStateHighlighted];
    
    [countrycode.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [countrycode setTitleColor:[UIColor colorWithHexString:@"#B8B8B8"] forState:UIControlStateNormal];
    [countrycode setTitleColor:[UIColor colorWithHexString:@"#B8B8B8"] forState:UIControlStateHighlighted];
      countrycode.userInteractionEnabled=NO;

    
//    [countrycode addTarget:self action:@selector(doTest) forControlEvents:UIControlEventTouchUpInside];
      
    [countrycode setBackgroundImage:FX_COUNTRY_CODE forState:UIControlStateNormal];
    
    [partoneview addSubview:countrycode];
    
//    mobilenumber =[[FXShakeField alloc] 
//                   initWithFrame:FXRect(INPUT_ACCOUNT_X+129.0/2.0+5, (INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH*2+20*2)-5, 279.0/2.0, 74.0/2.0) 
//                   ground_image:REGIST_TEXT_PHONE_IMG 
//                   icon_image:REGIST_TXT_PHONE_IMG];
    
    UIImageView  *mobile=[[UIImageView alloc] initWithFrame:FXRect(9, 6, 25, 25)];
    mobile.image=REGIST_TXT_PHONE_IMG;
    mobilenumber =[[FXShakeField alloc] initWithFrame:FXRect(INPUT_ACCOUNT_X+129.0/2.0+5, (INPUT_ACCOUNT_Y+INPUT_ACCOUNT_HIGH*2+20*2)-8+1, 279.0/2.0, 74.0/2.0) 
                                         ground_image:REGIST_TEXT_PHONE_IMG 
                                       icon_imageview:mobile];
    [mobilenumber do_set_placeholder_string:@"手机号码"];
    mobilenumber.shake_text_field.tag=203;
    mobilenumber.edit_limit_int = 11;
    mobilenumber.last_limit_int = 11;
    
    
    [mobilenumber.shake_text_field addTarget:self action:@selector(LengthValidate:) forControlEvents:UIControlEventEditingChanged];
    
    [mobilenumber.shake_text_field addTarget:self action:@selector(ChangeInputBg:) forControlEvents:UIControlEventEditingDidBegin];
    
    [mobilenumber.shake_text_field addTarget:self action:@selector(SelfValidate:) forControlEvents:UIControlEventEditingDidEnd];
    
    
    
    
    
    if ([helper getProerty:@"mobile"]!=nil) {
        mobilenumber.shake_text_field.text=(NSString *)[helper getProerty:@"mobile"];
    }
    
    
    
    [mobilenumber.shake_text_field setKeyboardType:UIKeyboardTypeNumberPad];
    
    
    [partoneview addSubview:mobilenumber];
    
    [partoneview addSubview:mobilewarringlabel];
    
    [partoneview addSubview:passwordwarning];   
    
    [partoneview addSubview:passwordwarninglabel];
    
    [partoneview addSubview:accountwarning];
    
    [partoneview addSubview:accountwarninglabel];
    
    [partoneview addSubview:mobilewarring];
    
    checkbox=[[FXCheckBox alloc] initWithFrame:FXRect(167.0/2.0, 375/2.0-7+5, CHECK_BOX_WIDTH, CHECK_BOX_HIGH) isCheck:YES];
  

    [checkbox addTarget:self action:@selector(DoCheck) forControlEvents:UIControlEventTouchUpInside];
    
    [partoneview addSubview:checkbox];
    
    
    label =[[UILabel alloc] initWithFrame:FXRect(checkbox.frame.origin.x+CHECK_BOX_HIGH+4,  375/2.0-7+5, 170/2, 24/2)];
    [label setFont:[UIFont systemFontOfSize:12.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithHexString:@"#B6B6B6"]];
    [label setText:@"我已阅读并遵守"];
    
    
    [partoneview addSubview:label];
    
    linkbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    
    linkbtn.frame=FXRect(checkbox.frame.origin.x+CHECK_BOX_HIGH*2+170/2-8, 375/2.0-9+5, 95.0/2.0, 30.0/2.0);
    
    [linkbtn setImage:USER_PROTOCOL_IMG forState:UIControlStateNormal];
    
    [linkbtn setImage:USER_PROTOCOL_HOVER_IMG forState:UIControlStateHighlighted];
    [linkbtn addTarget:self action:@selector(doReadProtocol) forControlEvents:UIControlEventTouchUpInside];
    
    [partoneview addSubview:linkbtn];
    
    backgroundimg =[[UIImageView alloc] initWithFrame:FXRect(PART_ONE_X, PART_ONE_Y, PART_ONE_WIDTH, PART_ONE_HIGH+100)];
    
    [backgroundimg setUserInteractionEnabled:YES];
    
    [backgroundimg setBackgroundColor:[UIColor clearColor]];
    
    [backgroundimg setImage:[bgdict valueForKey:@"capturebg"]];
    
    
    [self.view addSubview:backgroundimg];
    
    
    partoneview.backgroundColor=[UIColor colorWithHexString:@"#FFFEF6"];
    
    [backgroundimg addSubview:partoneview];
    
    [account.shake_text_field  becomeFirstResponder];
    
    [account setDelegate:self];
    [password setDelegate: self];
}
- (void)doReadProtocol{
    UIImage *mybackgroundimg=[bgdict valueForKey:@"capturebg"];
    ProtocolController * protoC = [[ProtocolController alloc] initWithTopImage:mybackgroundimg];
    [self presentModalViewController:protoC animated:YES];
    
}
-(void)SelfValidate:(id)sender{
    
    UITextField *ut=(UITextField *)sender;
                                            
    if (ut.tag==201) {
        
        
        account.shake_image_view.image=REGIST_TEXT_BOX_IMG;
        account.shake_text_field.textColor=[UIColor grayColor];
        if ([ut.text length]<=0) {
            accountwarning.hidden=NO;
            accountwarninglabel.hidden=NO;
            accountwarninglabel.text=@"请您输入账号";
            [self do_ShakeWithView:accountwarning];
            [self do_ShakeWithView:accountwarninglabel];
            [account do_shake];
        }else {
            if ([ut.text length]<6 || [ut.text length]>30) {
                accountwarning.hidden=NO;
                accountwarninglabel.hidden=NO;
                accountwarninglabel.text=@"账号为6－30位字母／数字";
                [self do_ShakeWithView:accountwarning];
                [self do_ShakeWithView:accountwarninglabel];
                [account do_shake];
            }else {
                accountwarning.hidden=YES;
                accountwarninglabel.hidden=YES;
                accountwarninglabel.text=@"";
            }
        }
       
    }
    if (ut.tag==202) {
       
        password.shake_image_view.image=REGIST_TEXT_BOX_IMG;
        password.shake_text_field.textColor=[UIColor grayColor];
        
        if ([ut.text length]<=0) {
            passwordwarning.hidden=NO;
            passwordwarninglabel.hidden=NO;
            passwordwarninglabel.text=@"请您输入密码";
            
            [self do_ShakeWithView:passwordwarning];
            [self do_ShakeWithView:passwordwarninglabel];
            [password do_shake];
        }else {
            if ([ut.text length]<6 || [ut.text length]>30) {
                passwordwarning.hidden=NO;
                passwordwarninglabel.hidden=NO;
                passwordwarninglabel.text=@"密码为6－30位字符";
                [self do_ShakeWithView:passwordwarning];
                [self do_ShakeWithView:passwordwarninglabel];
                [password do_shake];
                
            }else{
                passwordwarning.hidden=YES;
                passwordwarninglabel.hidden=YES;
                passwordwarninglabel.text=@"";
            }
        }
        
    }
    if (ut.tag==203) {
        
        mobilenumber.shake_image_view.image=REGIST_TEXT_PHONE_IMG;
        mobilenumber.shake_text_field.textColor=[UIColor grayColor];
        
        
        if ([ut.text length]<=0) {
            mobilewarring.hidden=NO;
            mobilewarringlabel.hidden=NO;
            mobilewarringlabel.text=@"请输入11位手机号码";
            
            [self do_ShakeWithView:mobilewarring];
            [self do_ShakeWithView:mobilewarringlabel];
            [mobilenumber do_shake];
            [self do_ShakeWithView:countrycode];

        }else {
            NSString *regxstr=@"^[0-9]{11}$";
            
            if ([ut.text isMatchedByRegex:regxstr]) {
                mobilewarring.hidden=YES;
                mobilewarringlabel.hidden=YES;
                mobilewarringlabel.text=@"";
              
            }else {
                mobilewarring.hidden=NO;
                mobilewarringlabel.hidden=NO;
                mobilewarringlabel.text=@"请输入11位手机号码";
                
                [self do_ShakeWithView:mobilewarring];
                [self do_ShakeWithView:mobilewarringlabel];
                [mobilenumber do_shake];
                [self do_ShakeWithView:countrycode];
            }
        }
    }
}


-(void)LengthValidate:(id)sender{
    
    UITextField *ut=(UITextField *)sender;
    NSString *str;
    if (ut.tag==201) {
        if ([ut.text length]>30) {
            str=[ut.text substringToIndex:30];
            ut.text=str;
        }
    }
    if (ut.tag==202) {
        if ([ut.text length]>30) {
            str=[ut.text substringToIndex:30];
            ut.text=str;
        }
    }
    if (ut.tag==203) {
        if ([ut.text length]>11) {
            str=[ut.text substringToIndex:11];
            ut.text=str;
        }
    }
}
-(void)doTest{

    NSLog(@"Run here");
}
- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)doValidate{
    
    
    if ([account.shake_text_field.text length]<=0 && [password.shake_text_field.text length]<=0 && [mobilenumber.shake_text_field.text length]<=0) {
        [account do_shake];
        accountwarning.hidden=NO;
        accountwarninglabel.hidden=NO;
        accountwarninglabel.text=@"请输入您的账号";
        [self do_ShakeWithView:accountwarning];
        [self do_ShakeWithView:accountwarninglabel];
        [password do_shake];
        passwordwarning.hidden=NO;
        passwordwarninglabel.hidden=NO;
        passwordwarninglabel.text=@"请输入您的密码";
        [self do_ShakeWithView:passwordwarning];
        [self do_ShakeWithView:passwordwarninglabel];
        [mobilenumber do_shake];
        mobilewarring.hidden=NO;
        mobilewarringlabel.hidden=NO;
        mobilewarringlabel.text=@"请输入11位手机号码";
        [self do_ShakeWithView:mobilewarring];
        [self do_ShakeWithView:mobilewarringlabel];
        [self do_ShakeWithView:countrycode];
        return NO;
    }
    
    if ([account.shake_text_field.text length]<=0) {
        
        [account do_shake];
        accountwarning.hidden=NO;
        accountwarninglabel.hidden=NO;
        accountwarninglabel.text=@"请输入您的账号";
        [self do_ShakeWithView:accountwarning];
        [self do_ShakeWithView:accountwarninglabel];
    }else {
        if ([account.shake_text_field.text length]<6 || [account.shake_text_field.text length]>30) {
            
            accountwarning.hidden=NO;
            
            accountwarninglabel.hidden=NO;
            
            accountwarninglabel.text=@"账号为6－30位字母／数字";
            [self do_ShakeWithView:account];
            [self do_ShakeWithView:accountwarning];
            [self do_ShakeWithView:accountwarninglabel];
            if ([account.shake_text_field.text length]>30) {
                NSString *text=[account.shake_text_field.text substringToIndex:30];
                account.shake_text_field.text=text;
                accountwarning.hidden=YES;
                accountwarninglabel.hidden=YES;
                accountwarninglabel.text=@"";
            }
        }

    }
    if ([password.shake_text_field.text length]<=0) {
        [password do_shake];
        passwordwarning.hidden=NO;
        passwordwarninglabel.hidden=NO;
        passwordwarninglabel.text=@"请输入您的密码";
        [self do_ShakeWithView:passwordwarning];
        [self do_ShakeWithView:passwordwarninglabel];
    }else {
        if ([password.shake_text_field.text length]<6 || [password.shake_text_field.text length]>30) {
            passwordwarning.hidden=NO;
            passwordwarninglabel.hidden=NO;
            passwordwarninglabel.text=@"密码为6－30位字符";
            [password do_shake];
            [self do_ShakeWithView:passwordwarninglabel];
            [self do_ShakeWithView:passwordwarning];
            if ([password.shake_text_field.text length]>30) {
                NSString *text=[password.shake_text_field.text substringToIndex:30];
                password.shake_text_field.text=text;
                passwordwarning.hidden=YES;
                passwordwarninglabel.hidden=YES;
                passwordwarninglabel.text=@"";
            } 
            
          
        }       
    }
        
        
    if ([mobilenumber.shake_text_field.text length]<=0) {
        
        [mobilenumber do_shake];
        mobilewarringlabel.hidden=NO;
        mobilewarring.hidden=NO;
        mobilewarringlabel.text=@"请输入11位手机号码";
        [self do_ShakeWithView:mobilewarring];
        [self do_ShakeWithView:mobilewarringlabel];
        [self do_ShakeWithView:countrycode];
        
        
    }else {
        NSString *regxstr=@"^[0-9]{11}$";
        if ([mobilenumber.shake_text_field.text isMatchedByRegex:regxstr]==NO) {
            mobilewarring.hidden=NO;
            mobilewarringlabel.hidden=NO;
            mobilewarringlabel.text=@"请输入11位手机号";
            [self do_ShakeWithView:mobilewarring];
            [self do_ShakeWithView:mobilewarringlabel];
            [self do_ShakeWithView:countrycode];
            [mobilenumber do_shake];
            if ([mobilenumber.shake_text_field.text length]>11) {
                NSString *text=[mobilenumber.shake_text_field.text substringToIndex:11];
                mobilenumber.shake_text_field.text=text;
                mobilewarring.hidden=YES;
                mobilewarringlabel.hidden=YES; 
            }
    
        }

    }
     
    if ([account.shake_text_field.text length]<=0) {
        
        [account do_shake];
        accountwarninglabel.hidden=NO;
        accountwarning.hidden=NO;
        accountwarninglabel.text=@"请输入您的账号";
        
        [self do_ShakeWithView:accountwarning];
        [self do_ShakeWithView:accountwarninglabel];
        
        return NO;
    }else {
        if ([account.shake_text_field.text length]<6 || [account.shake_text_field.text length]>30) {
            
            accountwarning.hidden=NO;
            
            accountwarninglabel.hidden=NO;
            
            accountwarninglabel.text=@"账号为6－30位字母／数字";
            [self do_ShakeWithView:account];
            [self do_ShakeWithView:accountwarning];
            [self do_ShakeWithView:accountwarninglabel];
            if ([account.shake_text_field.text length]>30) {
                NSString *text=[account.shake_text_field.text substringToIndex:30];
                account.shake_text_field.text=text;
                accountwarning.hidden=YES;
                accountwarninglabel.hidden=YES;
                accountwarninglabel.text=@"";
            }
            
            return NO;
        }
        accountwarning.hidden=YES;
        accountwarninglabel.text=@"";
        accountwarninglabel.hidden=YES;
    }
    if ([password.shake_text_field.text length]<=0 ) {
        
        [password do_shake];
        passwordwarning.hidden=NO;
        passwordwarninglabel.hidden=NO;
        passwordwarninglabel.text=@"";
        [self do_ShakeWithView:passwordwarninglabel];
        [self do_ShakeWithView:passwordwarning];

        return NO;
    }else {
        
        if ([password.shake_text_field.text length]<6 || [password.shake_text_field.text length]>30) {
            passwordwarning.hidden=NO;
            passwordwarninglabel.hidden=NO;
            passwordwarninglabel.text=@"密码为6－30位字符";
            [password do_shake];
            [self do_ShakeWithView:passwordwarninglabel];
            [self do_ShakeWithView:passwordwarning];
            if ([password.shake_text_field.text length]>30) {
                NSString *text=[password.shake_text_field.text substringToIndex:30];
                password.shake_text_field.text=text;
                passwordwarning.hidden=YES;
                passwordwarninglabel.hidden=YES;
                passwordwarninglabel.text=@"";
            } 
           
           return NO;
        }        
        passwordwarning.hidden=YES;
        passwordwarninglabel.text=@"";
        passwordwarninglabel.hidden=YES;
    }
    if ([mobilenumber.shake_text_field.text length]<=0) {
        
        [mobilenumber do_shake];
        mobilewarring.hidden=NO;
        mobilewarringlabel.hidden=NO;
        mobilewarringlabel.text=@"请输入11位手机号";
        
        [self do_ShakeWithView:mobilewarring];
        [self do_ShakeWithView:mobilewarringlabel];
         
        return NO;
    }else {
         NSString *regxstr=@"^[0-9]{11}$";
        if ([mobilenumber.shake_text_field.text isMatchedByRegex:regxstr]==NO) {
            mobilewarring.hidden=NO;
            mobilewarringlabel.hidden=NO;
            mobilewarringlabel.text=@"请输入11位手机号";
            [self do_ShakeWithView:mobilewarring];
            [self do_ShakeWithView:mobilewarringlabel];
            [self do_ShakeWithView:countrycode];
            [mobilenumber do_shake];
            if ([mobilenumber.shake_text_field.text length]>11) {
                NSString *text=[mobilenumber.shake_text_field.text substringToIndex:11];
                mobilenumber.shake_text_field.text=text;
                mobilewarring.hidden=YES;
                mobilewarringlabel.hidden=YES; 
            }
            return NO;
        }
        mobilewarring.hidden=YES;
        mobilewarringlabel.text=@"";
        mobilewarringlabel.hidden=YES;
    }
    return YES;
}

#pragma mark -
#pragma mark FanxerNavigationBarDelegate method

-(void)doLeft{
    
    helper=[RegistHelper defaultHelper];
    
    
        [helper setProperty:@"account" Value:account.shake_text_field.text];
    
    
    
        [helper setProperty:@"pwd" Value:password.shake_text_field.text];
    
   
        [helper setProperty:@"mobile" Value: mobilenumber.shake_text_field.text];
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doRight{
    if (isgo) {
        return;
    }
    if (ischeck==NO) {
        
        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"双双提示" message:@"请确保您已经阅读了用户协议" delegate:nil
                                                cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
        [alertview show];
        return;
    }
    if ([self doValidate]==YES) {
        
        CPUIModelManagement *uiManagement = [CPUIModelManagement sharedInstance ];
        if ([uiManagement canConnectToNetwork]==NO) {
            [self WarnningTipShow];
            /*
             点击下一步时，网络连接错误 调用（2）
             */
            return;
        }
        isreturn=NO;
        registtimer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(SelfCount) userInfo:nil repeats:YES];
        CPUIModelRegisterInfo *regInfo = [[CPUIModelRegisterInfo alloc ] init ];
        
        [regInfo setAccountName :account.shake_text_field.text];
        
        [regInfo setPassword:password.shake_text_field.text];
        
        [regInfo setNickName:[regist nikename]];
        
        [regInfo setSex:[regist sex]];
        
        [regInfo setLifeStatus:[regist lifestatus]];
        
        [regInfo setMobileNumber:mobilenumber.shake_text_field.text];
        
        [regInfo setRegionNumber:@"86"];
        
        UIImage *babyimg=[(UIImage *)[bgdict valueForKey:@"children"] imageByScalingAndCroppingForSize:CGSizeMake(70.0, 70.0)];
        UIImage *wifeimg=[(UIImage *)[bgdict valueForKey:@"wife"] imageByScalingAndCroppingForSize:CGSizeMake(120.0, 120.0)];
        
        UIImage *masterimg=[(UIImage *)[bgdict valueForKey:@"master"] imageByScalingAndCroppingForSize:CGSizeMake(120.0, 120.0)];
        
        UIImage *mybackgroundimg=[bgdict valueForKey:@"capturebg"];
        if (babyimg!=nil) {
               [regInfo setBabyImgData: UIImagePNGRepresentation(babyimg)];
        }
        if (wifeimg!=nil) {
//            [regInfo setCoupleImgData:UIImagePNGRepresentation(wifeimg)];
            [regInfo setCoupleImgData:UIImageJPEGRepresentation(wifeimg, 0.8f)];
        }
        if (masterimg!=nil) {
//            [regInfo setSelfImgData:UIImagePNGRepresentation(masterimg)];
            [regInfo setSelfImgData:UIImageJPEGRepresentation(masterimg, 0.8f)];
        }
        
        if (mybackgroundimg!=nil) {
//            [regInfo setSelfBgImgData:UIImagePNGRepresentation(mybackgroundimg)];
            [regInfo setSelfBgImgData:UIImageJPEGRepresentation(mybackgroundimg, 0.8f)];
        }
        
        [[ CPUIModelManagement sharedInstance] registerWithRegInfo:regInfo];
        blockview.alpha=1.0;
        helper=[RegistHelper defaultHelper];
        
        if ([account.shake_text_field.text length]>0) {
            [helper setProperty:@"account" Value:account.shake_text_field.text];
            
        }
        if ([password.shake_text_field.text length]>0) {
            [helper setProperty:@"pwd" Value:password.shake_text_field.text];
        }
        if ([mobilenumber.shake_text_field.text length]>0) {
            [helper setProperty:@"mobile" Value: mobilenumber.shake_text_field.text];
        }

    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"registerCode" isEqualToString:keyPath])
    {
        CPUIModelManagement *uiManagement = [CPUIModelManagement sharedInstance];
        CPLogInfo(@"%d    %@",uiManagement.registerCode,uiManagement.registerDesc);
        isreturn=YES;
        switch (uiManagement.registerCode) {
                
           
            case 0:{
                [account.shake_text_field resignFirstResponder];
                helper=[RegistHelper defaultHelper];
                
                if ([account.shake_text_field.text length]>0) {
                    [helper setProperty:@"account" Value:account.shake_text_field.text];
                    
                }
                if ([password.shake_text_field.text length]>0) {
                    [helper setProperty:@"pwd" Value:password.shake_text_field.text];
                }
                if ([mobilenumber.shake_text_field.text length]>0) {
                    [helper setProperty:@"mobile" Value: mobilenumber.shake_text_field.text];
                }
                  UIImage *mybackgroundimg=[bgdict valueForKey:@"capturebg"];
                blockview.alpha=0.0;
                
                /*
                顺利完成填写用户名密码页面的用户 调用（1）
                 */
                
                
                /*
                 此处进行跳转
                 */
//                verifycodecontroller =[[VerifyViewCodeController alloc] initWithNibName:nil bundle:nil region_string:nil mobile_string:mobilenumber.text top_image:mybackgroundimg];
//                [self.navigationController pushViewController:verifycodecontroller animated:YES];  
                //verifycodecontroller = nil;
                
                
            }
                break;
                /*
                //注册
                "ResponseCode_1100"="用户名已存在";	
                "ResponseCode_1101"="用户名不合法";	
                "ResponseCode_1102"="密码不合法";	
                "ResponseCode_1103"="昵称不合法";	
                "ResponseCode_1104"="性别不合法";	
                "ResponseCode_1105"="手机号不合法";		
                "ResponseCode_1106"="暂时不支持此地区的手机";		
                "ResponseCode_1107"="生活状态不合法";
                 */
            case 1100:
                
            case 1101:{
                /*
                点击下一步时，用户名重名失败 调用（2）
                 */
                accountwarning.hidden=NO;
                accountwarninglabel.hidden=NO;
                accountwarninglabel.text=uiManagement.registerDesc;
                [account do_shake];
                [self do_ShakeWithView:accountwarning];
                [self do_ShakeWithView:accountwarninglabel];
                blockview.alpha=0.0;
            }
            break;
            case 1102:{
                passwordwarning.hidden=NO;
                passwordwarninglabel.hidden=NO;
                passwordwarninglabel.text=uiManagement.registerDesc;
                [password do_shake];
                [self do_ShakeWithView:passwordwarning];
                [self do_ShakeWithView:passwordwarninglabel];
                blockview.alpha=0.0;
            }
            break;
                
            case 1103:{
                   blockview.alpha=0.0;
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"双双提示" message:uiManagement.registerDesc delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
            }
            break;
            case 1104:{
                blockview.alpha=0.0;
                CPLogInfo(@"%@", uiManagement.registerDesc);
                
            }
            break;
            
            case 1105:{
                /*
                 点击下一步时，手机号重复失败 调用（2）
                 */
                
                mobilewarring.hidden=NO;
                
                mobilewarringlabel.hidden=NO;
                
                mobilewarringlabel.text=uiManagement.registerDesc;
                [mobilenumber do_shake];
                [self do_ShakeWithView:mobilewarring];
                [self do_ShakeWithView:mobilewarringlabel];
                [self do_ShakeWithView:countrycode];
                blockview.alpha=0.0;
            }
            break;
            
            case 1106:{
                mobilewarring.hidden=NO;
                
                mobilewarringlabel.hidden=NO;
                
                mobilewarringlabel.text=uiManagement.registerDesc;
                [mobilenumber do_shake];
                [self do_ShakeWithView:mobilewarring];
                [self do_ShakeWithView:mobilewarringlabel];
                [self do_ShakeWithView:countrycode];
                blockview.alpha=0.0;
            }
                
                break;
            
            case 1107:{
               
            }
                break;
           
            case 1500:{
                
                mobilewarring.hidden=NO;
                
                mobilewarringlabel.hidden=NO;
                
                mobilewarringlabel.text=uiManagement.registerDesc;
                [mobilenumber do_shake];
                [self do_ShakeWithView:mobilewarring];
                [self do_ShakeWithView:mobilewarringlabel];
                [self do_ShakeWithView:countrycode];
                blockview.alpha=0.0;
                
            }
            
                break;
            default:{
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"双双提示" message:@"未知错误类型，请稍后再试!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
                blockview.alpha=0.0;
            }
                break;
        }
        
    }
}


-(void)SelfCount{
    count++;
    if (count>=MAX_COUNT ) {
        if (isreturn==YES) {
            [registtimer invalidate];
            registtimer=nil;
            blockview.alpha=0.0;
        }
    }
}
-(void)DoCheck{
    
    if (ischeck==YES) {
        ischeck=[checkbox CheckFor:NO];
    }else {
        ischeck=[checkbox CheckFor:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [account.shake_text_field resignFirstResponder];
    
    [password.shake_text_field resignFirstResponder];
    
    [mobilenumber.shake_text_field resignFirstResponder];
    
}


- (void)shake_field_did_begin_editing:(UITextField *)text_field{
    
}
- (void)shake_field_did_end_editing:(UITextField *)text_field{
    
}

- (void)shake_field_should_return:(UITextField *)text_field{
    
    
    if([account.shake_text_field isEqual:text_field]==YES){
        [password.shake_text_field becomeFirstResponder];
    }
    else if([password.shake_text_field isEqual:text_field]==YES){
        [mobilenumber.shake_text_field becomeFirstResponder];
    }
}
- (void)shake_field_did_text_edit:(UITextField *)text_field{
   
}


-(void)WarnningTipHide{
    isgo=NO;
    [UIView beginAnimations:@"hid" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    toptippanel.alpha=0.0;
    CGRect rect=toptippanel.frame;
    rect.origin.y=-46.0;
    toptippanel.frame=rect;
    [UIView commitAnimations];
}


-(void)WarnningTipShow{
    isgo=YES;
    [UIView beginAnimations:@"hid" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    toptippanel.alpha=1.0;
    CGRect rect=toptippanel.frame;
    rect.origin.y=0.0;
    toptippanel.frame=rect;
    [UIView commitAnimations];
    [self performSelector:@selector(WarnningTipHide) withObject:nil afterDelay:3.5];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
