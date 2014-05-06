//
//  RegistViewController.h
//  iCouple
//
//  Created by 振杰 李 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBothStyle.h"
#import "FanxerNavigationBarControl.h"
//#import "VerifyViewCodeController.h"
#import "FxProcessFixed.h"
#import "ColorUtil.h"
#import "FXCheckBox.h"
#import "RegistInfo.h"
#import "ImageUtil.h"
#import "RegistHelper.h"
#import "FXTopTipPanel.h"
#import "FanxerIndicatorControl.h"

@class FXShakeField;


@interface RegistViewController : UIViewController<FanxerNavigationBarDelegate,UITextFieldDelegate,UIAlertViewDelegate>{
    
    FanxerNavigationBarControl *fnav;
    
    UIImageView *backgroundimg;
    
    
//    VerifyViewCodeController *verifycodecontroller;
    
    FxProcessFixed *process;
   
    FXShakeField *account;
    
    FXShakeField *password;
    
    UIButton *countrycode;
    
    FXShakeField *mobilenumber;
    
    UIImage *background;
    
    UIView *partoneview;
    
    FXCheckBox *checkbox;
    
    UILabel *label;
    
    UIImageView *accountwarning;
    
    UILabel *accountwarninglabel;
    
    UIImageView *passwordwarning;
    
    UILabel *passwordwarninglabel;
    
    UIImageView *mobilewarring;
    
    UILabel *mobilewarringlabel;
    
    UIButton *linkbtn;
    
    RegistInfo *regist;

    NSDictionary *bgdict;
    
    BOOL ischeck;
    
    RegistHelper *helper;
    
    FXTopTipPanel *toptippanel;
    
    UIView *blockview;
    
    FanxerIndicatorControl *fxind;
    
    BOOL isgo;
    
    NSTimer *registtimer;
    
    BOOL isreturn;
    
    int count;
    
    UIImage * _topImage;
    
}

@property(strong,nonatomic) FanxerNavigationBarControl *fnav;


//@property(strong,nonatomic) VerifyViewCodeController *verifycodecontroller;

-(id)initWithRegistInfo:(RegistInfo *)registinfo;

-(void)loadNav;

-(void)initPartOne;
-(void)SelfValidate:(id)sender;
-(void)LengthValidate:(id)sender;
-(void)SelfCount;

@end
