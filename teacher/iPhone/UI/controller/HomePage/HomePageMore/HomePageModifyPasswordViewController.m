//
//  HomePageModifyPasswordViewController.m
//  iCouple
//
//  Created by ming bright on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomePageModifyPasswordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CPUIModelManagement.h"
#import "ColorUtil.h"
#import "HPTopTipView.h"
#import "HPStatusBarTipView.h"

@implementation HPMPNavgationBar 
@synthesize rightButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImageView *navBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [self addSubview:navBar];
        navBar.image = [UIImage imageNamed:@"bg_list_top_red"];
        
        UILabel *navBarTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        navBarTitle.backgroundColor = [UIColor clearColor];
        navBarTitle.textColor = [UIColor whiteColor];
        [self addSubview:navBarTitle];
        navBarTitle.text = @"修改密码";
        navBarTitle.font = [UIFont systemFontOfSize:20];
        navBarTitle.textAlignment = UITextAlignmentCenter;
        navBarTitle.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        navBarTitle.shadowOffset = CGSizeMake(0,-1);
        
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(10, (44-35)/2, 35, 35);
        [self addSubview:leftButton];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"icon_nav_list_back"] forState:UIControlStateNormal];
        [leftButton setBackgroundImage:[UIImage imageNamed:@"sign_nav_icon_list_back_hove"] forState:UIControlStateHighlighted];
        
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(320-95/2-10, 7, 95/2, 62/2);
        [self addSubview:rightButton];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"complete_more"] forState:UIControlStateNormal];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"complete_morepress"] forState:UIControlStateHighlighted];
        [rightButton setBackgroundImage:[UIImage imageNamed:@"complete_more_unpress"] forState:UIControlStateDisabled];

        
    }
    
    return self;
}


-(void)addTarget:(id)target leftAction:(SEL)action1 rightAction:(SEL)action2 forControlEvents:(UIControlEvents)controlEvents{
    [leftButton addTarget:target action:action1 forControlEvents:controlEvents];
    [rightButton addTarget:target action:action2 forControlEvents:controlEvents];
}

@end


@interface HomePageModifyPasswordViewController ()

@end

@implementation HomePageModifyPasswordViewController


- (void)shake:(UIView *)view{
    CABasicAnimation *animation = 
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([view center].x - 20.0, [view center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([view center].x + 20.0, [view center].y)]];
    [[view layer] addAnimation:animation forKey:@"position"];
    
}


-(void)leftTaped:(id)sender{
    
    //[self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightTaped:(id)sender{

    
    CustomAlertView *alert = [[CustomAlertView alloc] init];
    loadingView = [alert showLoadingMessageBox:@"稍等哦..."];
    

    [oldPassword resignFirstResponder];
    [newPassword resignFirstResponder];
    
    
    if ([oldPassword.text length]>=6&&[oldPassword.text length]<=30&&
        [newPassword.text length]>=6&&[newPassword.text length]<=30
        ) {
        //
        [[CPUIModelManagement sharedInstance] modifyUserPasswordWithOldPwd:oldPassword.text andNewPwd:newPassword.text];
    }else {
        [loadingView close];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)baseViewTaped:(id)sender{
    [oldPassword resignFirstResponder];
    [newPassword resignFirstResponder];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    /*
    RESPONSE_CODE_SUCESS = 0,
    RESPONSE_CODE_ERROR   = 1
    */
    
    int code = [[[CPUIModelManagement sharedInstance].changePwdResDic valueForKey:change_pwd_res_code] intValue];
    
    if (RESPONSE_CODE_SUCESS == code) {
        //
        //[[HPTopTipView shareInstance] showMessage:@"密码修改成功"];
        
        [loadingView setMessageString:@"密码修改成功"];
        [loadingView setImage:[UIImage imageNamed:@"right_arrow"]];
        //right_arrow
        
        [loadingView performSelector:@selector(close) withObject:nil afterDelay:0.2];
        [HPStatusBarTipView shareInstance].hidden = YES;
        //[self dismissModalViewControllerAnimated:YES];  // 密码修改成功，退出此界面
    }else{
        
        if (1902 == code) {  // 旧密码错误
            oldTipLabel.text = @"原密码不正确";
            errorIconOld.hidden = NO;
            [self shake:oldBackground];
            [self shake:oldPassword];
            
            [loadingView performSelector:@selector(close) withObject:nil afterDelay:0.2];
            
        }else {    // 其他错误
            [loadingView performSelector:@selector(close) withObject:nil afterDelay:0.2];
            NSString *errorInfo = [[CPUIModelManagement sharedInstance].changePwdResDic valueForKey:change_pwd_res_desc];
            [[HPTopTipView shareInstance] showMessage:errorInfo];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"changePwdResDic" options:0 context:NULL];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    navBar = [[HPMPNavgationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:navBar];
    [navBar addTarget:self 
           leftAction:@selector(leftTaped:) 
          rightAction:@selector(rightTaped:) 
     forControlEvents:UIControlEventTouchUpInside];
    
    navBar.rightButton.enabled = NO;
    
    baseView = [UIButton buttonWithType:UIButtonTypeCustom];
    baseView.frame = CGRectMake(0,44,320,460-44);
    [self.view addSubview:baseView];
    [baseView addTarget:self action:@selector(baseViewTaped:) forControlEvents:UIControlEventTouchDown];
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    UILabel *oldLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 44+50-25, 80, 20)];
    [self.view addSubview:oldLabel];
    oldLabel.text = @"旧密码";
    oldLabel.font = [UIFont systemFontOfSize:14];
    oldLabel.textColor = [UIColor colorWithHexString:@"#999999"];

    
    oldBackground = [[UIImageView alloc] initWithFrame:CGRectMake(55.5, 44+50, 320-111, 36.5)];
    [self.view addSubview:oldBackground];
    oldBackground.image = [UIImage imageNamed:@"item_step2_textbg"];
    
    UIImageView *key1 = [[UIImageView alloc] initWithFrame:CGRectMake(8, (36.5 - 25)/2, 25, 25)];
    key1.image = [UIImage imageNamed:@"icon_step2_key"];
    [oldBackground addSubview:key1];

    
    oldPassword = [[UITextField alloc] initWithFrame:CGRectMake(55.5+8+12.5+25-6.5, 44+50, 320-111-45, 36.5)];
    oldPassword.delegate =self;
    oldPassword.placeholder = @"密码 6-30个字母/数字";
    oldPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    oldPassword.font = [UIFont systemFontOfSize:14];
    oldPassword.textColor = [UIColor colorWithHexString:@"#B6B6B6"];
    oldPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    [oldPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [oldPassword setKeyboardType:UIKeyboardTypeAlphabet];
    [self.view addSubview:oldPassword];
    oldPassword.backgroundColor = [UIColor clearColor];
    
    oldTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36.5+6, 320-111, 10)];
    oldTipLabel.font = [UIFont systemFontOfSize:10];
    oldTipLabel.backgroundColor = [UIColor clearColor];
    oldTipLabel.textColor = [UIColor colorWithHexString:@"#EA5032"];
    oldTipLabel.textAlignment = UITextAlignmentCenter;
    [oldBackground addSubview:oldTipLabel];
    
    errorIconOld = [[UIImageView alloc] initWithFrame:CGRectMake(320-111-21, -10, 17, 17)];
    [oldBackground addSubview:errorIconOld];
    errorIconOld.image = [UIImage imageNamed:@"sign_step2_icon_!"];
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(62, 44+50+36.5+45-25, 80, 20)];
    [self.view addSubview:newLabel];
    newLabel.text = @"新密码";
    newLabel.font = [UIFont systemFontOfSize:14];
    newLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    
    newBackground = [[UIImageView alloc] initWithFrame:CGRectMake(55.5, 44+50+36.5+45, 320-111, 36.5)];
    [self.view addSubview:newBackground];
    newBackground.image = [UIImage imageNamed:@"item_step2_textbg"];
    
    UIImageView *key2 = [[UIImageView alloc] initWithFrame:CGRectMake(8, (36.5 - 25)/2, 25, 25)];
    key2.image = [UIImage imageNamed:@"icon_step2_key"];
    [newBackground addSubview:key2];
    
    newPassword = [[UITextField alloc] initWithFrame:CGRectMake(55.5+8+12.5+25-6.5, 44+50+36.5+45, 320-111-45, 36.5)];
    newPassword.delegate = self;
    newPassword.placeholder = @"密码 6-30个字母/数字";
    newPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    newPassword.font = [UIFont systemFontOfSize:14];
    newPassword.textColor = [UIColor colorWithHexString:@"#B6B6B6"];
    newPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    [newPassword setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [newPassword setKeyboardType:UIKeyboardTypeAlphabet];
    [self.view addSubview:newPassword];
    newPassword.backgroundColor = [UIColor clearColor];
    
    newTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36.5+6, 320-111, 10)];
    newTipLabel.font = [UIFont systemFontOfSize:10];
    newTipLabel.backgroundColor = [UIColor clearColor];
    newTipLabel.textColor = [UIColor colorWithHexString:@"#EA5032"];
    newTipLabel.textAlignment = UITextAlignmentCenter;
    [newBackground addSubview:newTipLabel];
    
    errorIconNew = [[UIImageView alloc] initWithFrame:CGRectMake(320-111-21, -10, 17, 17)];
    [newBackground addSubview:errorIconNew];
    errorIconNew.image = [UIImage imageNamed:@"sign_step2_icon_!"];
    
    errorIconOld.hidden = YES;
    errorIconNew.hidden = YES;
    
    //UITextFieldTextDidChangeNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:oldPassword];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:newPassword];

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{

    if ([textField isEqual:oldPassword]) {
        
        oldTipLabel.text = nil;
        errorIconOld.hidden = YES;
        
        oldBackground.image = [UIImage imageNamed:@"item_step2_textbg_white"];
        oldPassword.returnKeyType = UIReturnKeyNext;
        
        
    }else if([textField isEqual:newPassword]){
        
        newTipLabel.text = nil;
        errorIconNew.hidden = YES;
        
        newBackground.image = [UIImage imageNamed:@"item_step2_textbg_white"];
        newPassword.returnKeyType = UIReturnKeyDone;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:oldPassword]) {
        [newPassword becomeFirstResponder];
        
    }else {
        [textField resignFirstResponder];
    }
    
    return YES;
} 


-(void)textFieldTextDidChangeNotification:(NSNotification *)notify{
    
    if ([oldPassword.text length]>5&&[oldPassword.text length]<31&&
        [newPassword.text length]>5&&[newPassword.text length]<31
        ) {
        //
        navBar.rightButton.enabled = YES;
    }else {
        navBar.rightButton.enabled = NO;
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([textField isEqual:oldPassword]) {
        oldBackground.image = [UIImage imageNamed:@"item_step2_textbg"];
        
        if ([oldPassword.text length]<6||[oldPassword.text length]>30) {
            
            errorIconOld.hidden = NO;
            oldTipLabel.text = @"密码为6-30个字母/数字";
            [self shake:oldPassword];
            [self shake:oldBackground];
        }
        
    }else if([textField isEqual:newPassword]){
        newBackground.image = [UIImage imageNamed:@"item_step2_textbg"];
        
        if ([newPassword.text length]<6||[newPassword.text length]>30) {
            
            errorIconNew.hidden = NO;
            
            newTipLabel.text = @"密码为6-30个字母/数字";
            [self shake:newPassword];
            [self shake:newBackground];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"changePwdResDic" context:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil]; 
}

@end
