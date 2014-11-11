//
//  messageMainViewController.m
//  testSearchBar
//
//  Created by qing zhang on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//EMOJI 配置文件
#define EMOJI_CONFIG_FILE @"emoji.plist"
#import "BBmessageMainViewController.h"


@interface BBmessageMainViewController (){
    
    //拖动背景区域是否结束
    BOOL    isDragedEndMainBGView;
    CGFloat keybordChangeFloat;
    
}

@end

@implementation BBmessageMainViewController
@synthesize  imageviewHeadImg = _imageviewHeadImg ,keybordHeight = _keybordHeight, singleProfileView = _singleProfileView,groupProfileView = _groupProfileView,
imageviewHeadImgBGView = _imageviewHeadImgBGView,IMView = _IMView,profileView = _profileView,unReadedAlert = _unReadedAlert,unCoupleReadedAlert = _unCoupleReadedAlert,
currentStatus = _currentStatus,   isMoved = _isMoved ,buttonBack = _buttonBack , loadingView = _loadingView, animationIsPlayed = _animationIsPlayed , keybordView = _keybordView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(id)initWithStatus : (NSInteger)status;
{
    self = [super init];
    if (self) {
        keybordNeedResetFlag = NO;
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnter) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        
    }
    return self;
}
-(void)viewDidDisappear:(BOOL)animated
{
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (!keybordNeedResetFlag && userInfoType != USER_MANAGER_SYSTEM && userInfoType != USER_MANAGER_XIAOSHUANG) {
        [self.keybordView clearText];
        if (self.currentStatus == message_view_Status_up) {
            UIImageView *imageviewKeybord = (UIImageView *)[self.view viewWithTag:imageviewKeybordTag];
            if (!imageviewKeybord) {
                imageviewKeybord = [[UIImageView alloc] initWithFrame:CGRectMake(0, 460-keybordChangeFloat-61, 320, 61)];
                imageviewKeybord.tag = imageviewKeybordTag;
                [imageviewKeybord setImage:[UIImage imageNamed:@"im_keybord_ios"]];
                [self.view addSubview:imageviewKeybord];
            }
        }
    }
}
-(void)closeKeybordView{
    
}

-(void)viewWillAppear:(BOOL)animated{
    if (!keybordNeedResetFlag && userInfoType != USER_MANAGER_SYSTEM && userInfoType != USER_MANAGER_XIAOSHUANG) {
        if (self.currentStatus != message_view_Status_Down) {
            [self.keybordView reset];
//            [self.keybordView setFrame:CGRect_whenKeybordViewd];
            //[self.keybordView show];
            [self.keybordView showInView:self.view];
        }
        UIImageView *imageviewKeybord = (UIImageView *)[self.view viewWithTag:imageviewKeybordTag];
        if (imageviewKeybord) {
            [imageviewKeybord removeFromSuperview];
        }
    }
    keybordNeedResetFlag = NO;
}

-(void)viewDidAppear:(BOOL)animated{
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //下面需要用到键盘高度，提前初始化
    //self.keybordView = [[KeyboardView alloc] initWithFrame:CGRectMake(0, 503/2, 320, 460)];
    self.keybordView = [KeyboardView sharedKeyboardView];
    
    self.view.multipleTouchEnabled = NO;
    self.view.exclusiveTouch = YES;
    isShakeEnded = YES;
    //logo背景图
    UIImageView *imageviewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.f, 194/2)];
    [imageviewBackground setImage:[UIImage imageNamed:@"bg_profileeeee.jpg"]];
    [self.view addSubview:imageviewBackground];
    
    
    //背景区域，背景图+个人profile
//    self.mainBGView = [[UIView alloc] initWithFrame:CGRect_mainBGViewInStatusMid];
//    self.mainBGView.backgroundColor = [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1.0];;
//    [self.view addSubview:self.mainBGView];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    
    self.imageviewHeadImg = [[MSHeadView alloc] init];
    [self.imageviewHeadImg setBorderWidth:5.f];
    self.imageviewHeadImg.touchDelegate = self;
    [self.imageviewHeadImg setFrame:CGRectMake(320-imageviewSingleHeadImageInStatusMid-26.5,imageviewUpBGInStatusMid-imageviewSingleHeadImageInStatusMid+21.f , imageviewSingleHeadImageInStatusMid, imageviewSingleHeadImageInStatusMid)];
    [self.imageviewHeadImg addTarget:self action:@selector(pressHeadImg) forControlEvents:UIControlEventTouchUpInside];
    [self.imageviewHeadImg setCycleImage:[UIImage imageNamed:@"headpic_im_120x120.png"]];
    self.imageviewHeadImg.hidden = YES;
    self.currentStatus = 2;
    
    //昵称
//    self.nickName = [[UILabel alloc] initWithFrame:CGRect_nickNameInStatusMid];
//    self.nickName.textColor = [UIColor whiteColor];
//    self.nickName.textAlignment = UITextAlignmentRight;
//    self.nickName.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.75f];
//    self.nickName.shadowOffset = CGSizeMake(0.f, 1.f);
//    self.nickName.font = [UIFont boldSystemFontOfSize:15.f];
//    self.nickName.backgroundColor = [UIColor clearColor];
//    [self.nickName setFrame:CGRect_nickNameInStatusMid];
//    [self.view addSubview:self.nickName];
    
    //通讯录姓名
//    self.contactName = [[UILabel alloc] initWithFrame:CGRect_contactNameInStatusDown];
//    self.contactName.textColor = [UIColor colorWithRed:201/255.f green:201/255.f blue:201/255.f alpha:1.0];
//    self.contactName.textAlignment = UITextAlignmentRight;
//    self.contactName.font = [UIFont systemFontOfSize:10.f];
//    self.contactName.backgroundColor = [UIColor clearColor];
//    [self.view insertSubview:self.contactName belowSubview:self.IMView];
//    self.contactName.hidden = YES;
    
    //IM区域
    self.IMView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, self.screenHeight - 64.0f - [self.keybordView currentHeight])];
    
    self.IMView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.IMView];
    
    UIImageView *imageviewIMBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_im_couple.png"]];
    [imageviewIMBG setFrame:CGRectMake(0, 0, 320, self.IMView.frame.size.height)];
    imageviewIMBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.IMView addSubview:imageviewIMBG];
    
    //头像下面的横条
    self.imageviewHeadImgBGView = [[UIImageView alloc] initWithFrame:CGRect_imageviewHeadImgBGViewInStatusMid];
    self.imageviewHeadImgBGView.backgroundColor = [UIColor clearColor];
    [self.imageviewHeadImgBGView setImage:[UIImage imageNamed:@"bg_im_couple_top00.png"]];
    self.imageviewHeadImgBGView.hidden= YES;
    [self.view addSubview:self.imageviewHeadImgBGView];
    
    //头像
    [self.view addSubview:self.imageviewHeadImg];
    
    //键盘
    self.keybordView.backgroundColor = [UIColor clearColor];
    
    self.keybordView.delegate = self;
    //[self.view addSubview:self.keybordView];
    
    //返回按钮
//    self.buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.buttonBack setFrame:CGRectMake(0.f, 0.f, 60.f, 60.f)];
//    [self.buttonBack addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.buttonBack];
    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)applicationDidEnter
{
    NSLog(@"%@",self.view);
    if (self.isMoved) {
        [self reBoundByCurrentStatus];
    }
    
}
-(void)keybordWillDisappear:(NSNotification *)notification{
}

- (void)keyboardWillShow:(NSNotification *)notification{
}

#pragma mark method

-(void)pressHeadImg{
}

-(void)changeButtonImageByStatus : (NSInteger)btnStatus
{
    switch (btnStatus) {
        case Btn_Back_IM:
        {
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_backmsgwall.png"] forState:UIControlStateNormal];
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_backmsgwall_press.png"] forState:UIControlStateHighlighted];
            self.buttonBack.tag = Btn_Back_IM;
        }
            break;
        case Btn_Back_Couple:
        {
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_home.png"] forState:UIControlStateNormal];
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_home_press.png"] forState:UIControlStateHighlighted];
            self.buttonBack.tag = Btn_Back_Couple;
        }
            break;
        case Btn_Back_ProfileTag:
        {
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_back.png"] forState:UIControlStateNormal];
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_backpress.png"] forState:UIControlStateHighlighted];
            self.buttonBack.tag = Btn_Back_ProfileTag;
        }
            break;
        default:
            break;
    }
}
//显示或隐藏头部近况和昵称部分
-(void)changeStatusForNickNameAndRecent : (BOOL)isChanged :(CGRect)nickNameFrame{
    if (isChanged) {
//        [self.nickName setHidden:YES];
        //[self.nickName setFrame:CGRectMake(320-195.f, 460-55.f, 88.f , 14.f)];
    }else {
//        [self.nickName setFrame:nickNameFrame];
//        [self.nickName setHidden:NO];
    }
    if (self.currentStatus == message_view_Status_Middle) {
//        self.recentView.hidden = NO;
    }else {
//        self.recentView.hidden = YES;
    }
}

//显示BGview的隐藏部分，目前未用到
-(void) scrolledViewWhenNeedViewTopView
{
//    self.currentStatus = 3;
//    [UIView beginAnimations:@"" context:nil];
//    [UIView setAnimationDuration:0.3f];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    [self setFrameWhenAnimationed:3];
//    //[self.mainBGView setFrame:CGRectMake(0, 0, 320.f, 510.f)];
//    [self.profileView.imageviewBGInMainView setFrame:CGRect_imageviewBGInMainViewInStatusDown];
//    
//    [UIView commitAnimations];
}

//隐藏BGView的显示部分，目前未用到
-(void) scrolledViewWhenNeedHideTopView{
    self.currentStatus = 1;
}

//判断点击区域在哪个区域
/****
 return 1 :B区
 return 2 :A区
 return 0 :其他区域，目前其他区域全部不接受点击
 ****/
-(NSInteger) isInUpBGRectOrInHeadImgRect : (CGPoint)tapPoint{
    return 0;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setFrameWhenDraged : (NSInteger)type : (CGFloat)offsetValue{
    
}

//1:dragA区域触发，2：dragB区域触发 ，needMinusOffsetValueForChangeStatus尽在B区域有效 YES为拖动B从statusUP下来，NO为拖动B从statusMid下来
//3:在statusDown时dragB区触发
- (void) scrolledViewWhenMainBGViewDraged : (CGFloat)offsetValue :(NSInteger)dragedView : (BOOL)needMinusOffsetValueForChangeStatus{
    
}

//任何操作都会移动头像，头像下的横条，和IM区域，此函数即当需要调用的时候用的
- (void) scrolledViewWhenViewDraged : (CGFloat)offsetValue{

    
}

- (void)changeStatusBySwipeLevel : (NSInteger)swipeLevel{
    
}

- (void)reBoundByCurrentStatus{
}

//到两边的回弹效果
-(void)setFrameWhenScrollToEnd{

}

//1:设置topFrame，2设置middleFrame，3设置BottomFrame，也只会在touchend后会用到，即切换3中状态时的布局位置
-(void) setFrameWhenAnimationed : (NSUInteger)type{
 
}

//当statusDown时上滑B区，移动个人profile区,TouchStatus:YES==Move,NO = End
-(void)changeFrameWhenUpSwipeInStatusDown : (CGFloat)offsetValue TouchStatus:(BOOL)statusMoveOrEnd{
}

#pragma mark MSHeadViewDelegate
-(void)touchedHeadView:(UITouch *)viewTouch withEvent:(UIEvent *)viewEvent withTouchButtonStatus:(TouchButtonStatus)status{

}
#pragma mark touchMethod

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
#pragma mark shakeAnimation
- (void)shakeAnimation{
    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
}

-(void)keybordAppear{
    self.currentStatus = 1;
    [self setFrameWhenScrollToEnd];
}

-(void)endShaked{

}

#pragma mark makeUIImageRounded

// 键盘出现
- (void)keyboardViewDidAppear:(CGFloat)height // 高度暂时是 0
{
    if (!keybordViewed) {
        keybordViewed = YES;
    }
    [self keybordAppear];
}

@end
