//
//  AddContactAnswerViewController.m
//  iCouple
//
//  Created by shuo wang on 12-6-7.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#define LoadingView_TimeOut 30.0f

#import "AddContactAnswerViewController.h"
#import "HPTopTipView.h"
#import "UserInforModel.h"
//#import "OtherIMViewController.h"
#import "HomeMainViewController.h"
//#import "CoupleIMViewController.h"
#import "CoupleCompletedView.h"
#import "CPUIModelPersonalInfo.h"
#import "SingleIndependentProfileViewController.h"

@interface AddContactAnswerViewController ()
@property (nonatomic,strong) UIButton *comfirmButton;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) CPUIModelUserInfo *userInfo;
@property (nonatomic,strong) UserInforModel *addContactUserInfor;
@property (nonatomic,strong) CPUIModelSysMessageReq *messageRequest;
@property (nonatomic,strong) ExMessageModel *exModel;
@property (nonatomic,strong) LoadingView *loadingView;
@property (nonatomic,strong) CoupleCompletedView *completedView;
@property (nonatomic,assign) SysMsgApplyType msgApplyType;
@property (nonatomic,strong) CPUIModelMessageGroup *group;
@property (nonatomic,strong) HPHeadView *friendBabyIMG;
@property (nonatomic,strong) UILabel *friendBabyName;

-(void) clickComfirmButton;
-(void) clickCancelButton;
-(void) beginAnimation;
-(void) endAnimation;
-(NetworkStatus) getCurrentNetworkState;
@end

@implementation AddContactAnswerViewController
@synthesize fnav = _fnav , topBGImage =_topBGImage , transparentBGImage = _transparentBGImage , personalHeadImg = _personalHeadImg;
@synthesize nickName = _nickName , descriptionLabel = _descriptionLabel , profileModel = _profileModel;
@synthesize comfirmButton = _comfirmButton , cancelButton = _cancelButton;
@synthesize userInfo = _userInfo , messageRequest = _messageRequest , exModel = _exModel;
@synthesize addContactUserInfor = _addContactUserInfor;
@synthesize loadingView = _loadingView , completedView = _completedView;
@synthesize msgApplyType = _msgApplyType , group = _group;
@synthesize fullNameLabel = _fullNameLabel , contentLabel = _contentLabel , textLabel = _textLabel;
@synthesize guideLabel = _guideLabel , sexImage = _sexImage;
@synthesize friendBabyIMG = _friendBabyIMG , friendBabyName = _friendBabyName;

// 初始化数据
-(id) initAddContactWithUserInfor : (ExMessageModel *) exModel{
    self = [super init];
    
    if (self) {
        self.profileModel = [UserProfileModel sharedInstance];
        self.profileModel.delegate = self;
        self.messageRequest = [exModel.messageModel getSysMsgReq];
        self.userInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:self.messageRequest.userName];
        
        if ( nil == self.userInfo){
            self.userInfo = [[CPUIModelUserInfo alloc] init];
            [self.userInfo setName:self.messageRequest.userName];
            [self.userInfo setNickName:self.messageRequest.nickName];
            [self.userInfo setMobileNumber:self.messageRequest.mobileNumber];
        }
        
        
        
        
        self.addContactUserInfor = [[UserInforModel alloc] initUserInfor];
        self.addContactUserInfor.headerPath = self.userInfo.headerPath;
        self.addContactUserInfor.nickName = self.userInfo.nickName;
        self.addContactUserInfor.fullName = self.userInfo.fullName;
        self.addContactUserInfor.userName = self.userInfo.name;
        self.addContactUserInfor.telPhoneNumber = self.userInfo.mobileNumber;
//        NSLog(@"%@",self.userInfo.selfBabyHeaderImgPath);
        
        self.exModel = exModel;
        [self.profileModel loadUserProfileInfor:self.addContactUserInfor];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"responseActionDic" options:0 context:@"responseActionDic"];
        
        // 添加下载陌生人头像的页面通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StrangerHeaderImage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationHandler:) name:@"StrangerHeaderImage" object:nil];
    }
    return self;
}

-(void)NotificationHandler : (NSNotification *) notification{
    if ([notification.name isEqualToString:@"StrangerHeaderImage"]) {
        StrangerHeaderImageModel *headerImageModel = (StrangerHeaderImageModel *)[notification object];
        if ([self.profileModel.personalUserInfor.userName isEqualToString:headerImageModel.userName]) {
            UIImage *image = [UIImage imageWithContentsOfFile:headerImageModel.headerImagePath];
            if (image != nil) {
                [self.personalHeadImg ResetImage:image];
            }
            
            UIImage *bgImage = [UIImage imageWithContentsOfFile:headerImageModel.bgImagePath];
            if (bgImage != nil) {
                self.topBGImage.image = bgImage;
            }
            
//            UIImage *babyImage = [UIImage imageWithContentsOfFile:headerImageModel.bgImagePath];
//            if (nil != babyImage && headerImageModel.hasBaby) {
//                
//                if (nil != self.friendBabyIMG) {
//                    [self.friendBabyIMG removeFromSuperview];
//                }
//                
//                self.friendBabyIMG = [[HPHeadView alloc] init];
//                self.friendBabyIMG.borderWidth = 5.f;
//                [self.friendBabyIMG setFrame:CGRectMake(86.f, 166.f, 55.f, 55.f)];
//                [self.friendBabyIMG setCycleImage:[UIImage imageNamed:@"headpic_index_70x70.png"]];
//                [self.view addSubview:self.friendBabyIMG];
//                
//                UIImage *imageBaby = [UIImage imageWithContentsOfFile:headerImageModel.bgImagePath];
//                if (!imageBaby) {
//                    imageBaby = [UIImage imageNamed:@"baby.png"];
//                }
//                [self.friendBabyIMG setBackImage:imageBaby];
//                [self.personalHeadImg bringSubviewToFront:self.view];
//                
//                if (nil != self.friendBabyName) {
//                    [self.friendBabyName removeFromSuperview];
//                }
//                self.friendBabyName = [[UILabel alloc] initWithFrame:CGRectMake(44.f, 200.f, 42.f, 13.f)];
//                self.friendBabyName.font = [UIFont systemFontOfSize:12.f];
//                self.friendBabyName.textAlignment = UITextAlignmentRight;
//                self.friendBabyName.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0];
//                self.friendBabyName.backgroundColor = [UIColor clearColor];
//                self.friendBabyName.text = @"宝宝";
//                [self.view addSubview:self.friendBabyName];
//            }
            
            self.sexImage = [[UIImageView alloc] init];
            if([headerImageModel.sex intValue] == USER_INFO_SEX_MALE){
                [self.sexImage setImage:[UIImage imageNamed:@"profile_icon_male_01.png"]];
            }else{
                [self.sexImage setImage:[UIImage imageNamed:@"profile_icon_female_01.png"]];
            }
            self.sexImage.frame = CGRectMake(self.nickName.frame.origin.x + self.nickName.frame.size.width,
                                             self.nickName.frame.origin.y + 2.0f,
                                             14.0f, 14.0f);
            [self.view addSubview:self.sexImage];
        }
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.profileModel.delegate = nil;
}

-(void) loadPersonProfileDataCompleted : (id) msg{
    NSDictionary *completedMsg = (NSDictionary *)msg;
    
    if ([completedMsg objectForKey:@"1"] != nil) {
        NSArray *userinforArray = (NSArray *)[completedMsg objectForKey:@"1"];
        NSUInteger offsetX = 6;
        NSUInteger offsetY = 6;
        if ([userinforArray count] != 0) {
            self.descriptionLabel.hidden = NO;
            NSUInteger hearderCount = [userinforArray count];
            BOOL isBeyondMax = NO;
            if (hearderCount > 8) {
                isBeyondMax = YES;
            }
            
            for (int i = 0; i < hearderCount; i++) {
                UIButton *headerbutton = [UIButton buttonWithType:UIButtonTypeCustom];
                if ( i >= 7 && isBeyondMax ) {
                    
                    [headerbutton setBackgroundImage:[UIImage imageNamed:@"item_add_avatar_small_more.png"] forState:UIControlStateNormal];
                    [headerbutton setBackgroundImage:[UIImage imageNamed:@"item_add_avatar_small_more.png"] forState:UIControlStateHighlighted];
                    NSUInteger Row = i%8;
                    NSUInteger Col = i/8;
                    headerbutton.frame = CGRectMake(41.0f + Row * (offsetX + 25.0f), 
                                                    415.0f + Col * (offsetY + 25.0f),
                                                    25.0f, 25.0f);
                    [self.view addSubview:headerbutton];
                    break;
                }else {
                    // 提取用户头像
                    CPUIModelUserInfo *userInfor = (CPUIModelUserInfo *)[userinforArray objectAtIndex:i];
                    
                    UIImage *headImage = nil;
                    UIImageView *shadowImage = nil;
                    CPLogInfo(@"-----------用户头像路径为 ：%@-------------" , userInfor.headerPath);
                    
                    if ( nil == userInfor.headerPath || [userInfor.headerPath isEqualToString:@""]) {
                        [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_50×50_add_avatar_small.png"] forState:UIControlStateNormal];
                        [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_50×50_add_avatar_small.png"] forState:UIControlStateHighlighted];
                    }else {
                        headImage = [UIImage imageWithContentsOfFile:userInfor.headerPath];
                        CPLogInfo(@"-----------------------小头像：%@--------------------",userInfor.headerPath);
                        if ( nil == headImage) {
                            [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_50×50_add_avatar_small.png"] forState:UIControlStateNormal];
                            [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_50×50_add_avatar_small.png"] forState:UIControlStateHighlighted];
                        }else {
                            // 制作圆角
                            headImage = [[TImageOperator sharedInstance] doCreateRoundImage:headImage size:CGSizeMake(50.0f, 50.0f) radius:8.0f];
                            [headerbutton setBackgroundImage:headImage forState:UIControlStateNormal];
                            [headerbutton setBackgroundImage:headImage forState:UIControlStateHighlighted];
                            shadowImage = [[UIImageView alloc] init];
                        }
                    }
                    
                    NSUInteger Row = i%8;
                    NSUInteger Col = i/8;
                    headerbutton.frame = CGRectMake(41.0f + Row * (offsetX + 25.0f), 
                                                    415.0f + Col * (offsetY + 25.0f),
                                                    25.0f, 25.0f);
                    headerbutton.tag = i;
                    [headerbutton addTarget:self action:@selector(headerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:headerbutton];
                    if (nil != shadowImage) {
                        shadowImage.frame = headerbutton.frame;
                        UIImage *shadow = [UIImage imageNamed:@"headpic_shadow_50_50.png"];
                        shadowImage.image = shadow;
                        [self.view addSubview:shadowImage];
                    }
                }
            }
        }
    }else {
        [[HPTopTipView shareInstance] showMessage:[completedMsg objectForKey:@"200"]];
    }
}

// 头像点击
-(void) headerButtonClick : (id) sender{
    UIButton *header = (UIButton *)sender;
    CPLogInfo(@"%d" , header.tag);
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    BOOL isfriend = YES;
    CPUIModelUserInfo *info = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:self.profileModel.personalUserInfor.userName];
    
    if (info == nil) {
        isfriend = NO;
    }
    NSString *friendType = @"";
    if (isfriend) {
        if ([info.type intValue] == SYS_MSG_APPLY_TYPE_COMMON) {
            friendType = @"好友";
        }else if ([info.type intValue] == SYS_MSG_APPLY_TYPE_CLOSER){
            friendType = @"蜜友";
        }else if ([info.type intValue] == SYS_MSG_APPLY_TYPE_LOVE){
            friendType = @"你喜欢的人";
        }else if ([info.type intValue] == SYS_MSG_APPLY_TYPE_COUPLE){
            friendType = @"情侣";
        }else if ([info.type intValue] == SYS_MSG_APPLY_TYPE_MARRIED){
            friendType = @"夫妻";
        }
    }
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIFont *nickNameFont = [UIFont boldSystemFontOfSize:14.0f];
    UIFont *fullNameFont = [UIFont boldSystemFontOfSize:12.0f];
    UIFont *descriptionFont = [UIFont boldSystemFontOfSize:12.0f];
    
    // 添加背景image
    self.topBGImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 210.5f)];
    self.topBGImage.image = [UIImage imageNamed:@"bg_default.jpg"];
    [self.view addSubview:self.topBGImage];
    
    // 添加navigtionBar
    UIButton *leftbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftbutton.frame=CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
    [leftbutton setImage:[UIImage imageNamed:@"sign_nav_btn_back.png"] forState:UIControlStateNormal];
    [leftbutton setImage:[UIImage imageNamed:@"sign_nav_btn_back_hover.png"] forState:UIControlStateHighlighted];
    
    NavigationBothStyle *style=[[NavigationBothStyle alloc] initWithTitle:@"" Leftcontrol:leftbutton Rightcontrol:nil];
    self.fnav =[[FanxerNavigationBarControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f) withStyle:style withDefinedUserControl:YES];
    self.fnav._delegate = self;
    [self.view addSubview:self.fnav];
    
    // 添加底边透明背景
    self.transparentBGImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sign_step1_image_bar@2x.png"]];
    self.transparentBGImage.frame = CGRectMake(0.0f, 196.0f, 320.0f, 15.0f);
    [self.view addSubview:self.transparentBGImage];
    
    [[StrangerHeaderImage sharedInstance] getUserHeaderImage:self.profileModel.personalUserInfor.userName];
    
    // 添加用户头像
    UIImage *headImage = nil;
    CPLogInfo(@"-----------用户头像路径为 ：%@-------------" , self.profileModel.personalUserInfor.headerPath);
    if ( nil == self.profileModel.personalUserInfor.headerPath || [self.profileModel.personalUserInfor.headerPath isEqualToString:@""]) {
        self.personalHeadImg = [[FxImgBall alloc] initWithFrame:CGRectMake(125.0f, 149.0f, 68.0f, 68.0f) img:[UIImage imageNamed:@"sign_step1_avatar_me.png"] needhightlight:NO];
    }else {
        headImage = [UIImage imageWithContentsOfFile:self.profileModel.personalUserInfor.headerPath];
        if ( nil == headImage) {
            self.personalHeadImg = [[FxImgBall alloc] initWithFrame:CGRectMake(125.0f, 149.0f, 68.0f, 68.0f) img:[UIImage imageNamed:@"sign_step1_avatar_me.png"] needhightlight:NO];
        }else {
            //            self.personalHeadImg = [[FxImgBall alloc] initWithFrame:CGRectMake(125.0f, 149.0f, 68.0f, 68.0f) img:headImage needhightlight:NO];
            self.personalHeadImg = [[FxImgBall alloc] initWithFrame:CGRectMake(125.0f, 149.0f, 68.0f, 68.0f) img:[UIImage imageNamed:@"sign_step1_avatar_me.png"] needhightlight:NO];
            [self.personalHeadImg ResetImage:headImage];
        }
    }
    self.personalHeadImg.delegate = self;
    self.personalHeadImg.isChangeImage = NO;
    self.personalHeadImg.button.enabled = NO;
    [self.view addSubview:self.personalHeadImg];
    
    
    // 添加昵称
    self.nickName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    //        /**1=普通好友
    //         2=密友
    //         3=喜欢
    //         4=恋人couple
    //         5=夫妻couple
    //         **/
    //        typedef enum
    //        {
    //            SYS_MSG_APPLY_TYPE_COMMON = 1,
    //            SYS_MSG_APPLY_TYPE_CLOSER = 2,
    //            SYS_MSG_APPLY_TYPE_LOVE = 3,
    //            SYS_MSG_APPLY_TYPE_COUPLE = 4,
    //            SYS_MSG_APPLY_TYPE_MARRIED = 5,
    //        }SysMsgApplyType;
    NSString *type = @"";
    NSString *buttonComfirm = @"接受";
    NSString *buttonCancel = @"拒绝";
    switch ([self.messageRequest.applyType intValue]) {
        case SYS_MSG_APPLY_TYPE_COMMON:
            self.msgApplyType = SYS_MSG_APPLY_TYPE_COMMON;
            type = @"好友";
            break;
        case SYS_MSG_APPLY_TYPE_CLOSER:
            self.msgApplyType = SYS_MSG_APPLY_TYPE_CLOSER;
            type = @"好友";
            break;
        case SYS_MSG_APPLY_TYPE_LOVE:
            self.msgApplyType = SYS_MSG_APPLY_TYPE_LOVE;
            type = @"好友";
            break;
        case SYS_MSG_APPLY_TYPE_COUPLE:
            self.msgApplyType = SYS_MSG_APPLY_TYPE_COUPLE;
            type = @"情侣";
            buttonComfirm = @"愿意";
            buttonCancel = @"拒绝";
            break;
        case SYS_MSG_APPLY_TYPE_MARRIED:
            self.msgApplyType = SYS_MSG_APPLY_TYPE_MARRIED;
            type = @"夫妻";
            buttonComfirm = @"愿意";
            buttonCancel = @"拒绝";
            break;
        default:
            break;
    }
    self.nickName.text = self.profileModel.personalUserInfor.nickName;
    //[NSString stringWithFormat:@"%@想加你为%@",self.profileModel.personalUserInfor.nickName,type];
    self.nickName.font = nickNameFont;
    [self.nickName sizeToFit];
    self.nickName.frame = CGRectMake(320.0f / 2.0f - self.nickName.frame.size.width / 2.0f,
                                     227.0f,
                                     self.nickName.frame.size.width,
                                     self.nickName.frame.size.height);
    self.nickName.textColor = [UIColor colorWithHexString:@"#424242"];
    self.nickName.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.nickName];
    
    // 添加通讯录名称
    self.fullNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    NSString *fullName = nil;
    if ( nil == self.profileModel.personalUserInfor.fullName || [self.profileModel.personalUserInfor.fullName isEqualToString:@""]) {
        if (nil != self.profileModel.personalUserInfor.telPhoneNumber && ![self.profileModel.personalUserInfor.telPhoneNumber isEqualToString:@""]) {
            fullName = [[CPUIModelManagement sharedInstance] getContactFullNameWithMobile:self.profileModel.personalUserInfor.telPhoneNumber];
        }
    }else{
        fullName = self.profileModel.personalUserInfor.fullName;
    }
    
    if (nil != fullName) {
        self.fullNameLabel.text = fullName;
        self.fullNameLabel.font = fullNameFont;
        [self.fullNameLabel sizeToFit];
        self.fullNameLabel.frame = CGRectMake(320.0f / 2.0f - self.fullNameLabel.frame.size.width / 2.0f,
                                              246.0f,
                                              self.fullNameLabel.frame.size.width,
                                              self.fullNameLabel.frame.size.height);
        self.fullNameLabel.textColor = [UIColor colorWithHexString:@"#cccccc"];
        self.fullNameLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.fullNameLabel];
    }
    
    // 添加文本文件
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    self.contentLabel.text = type;
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    self.contentLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [self.contentLabel sizeToFit];
    
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    if (isfriend) {
        self.textLabel.text = [NSString stringWithFormat:@"你们现在是%@，Ta想加你为",friendType];
    }else{
        self.textLabel.text = @"你们现在是陌生人，Ta想加你为";
    }
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    self.textLabel.font = [UIFont systemFontOfSize:12.0f];
    [self.textLabel sizeToFit];
    
    self.textLabel.frame = CGRectMake((320.0f - self.contentLabel.frame.size.width - self.textLabel.frame.size.width) / 2.0f,
                                       297.0f,
                                       self.textLabel.frame.size.width,
                                      self.textLabel.frame.size.height);
    self.contentLabel.frame = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width,
                                         297.0f, self.contentLabel.frame.size.width, self.contentLabel.frame.size.height);
    
    [self.view addSubview:self.textLabel];
    [self.view addSubview:self.contentLabel];
    
    
    // 添加确定按钮
    self.comfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *comfirmImage = [UIImage imageNamed:@"profile_btn_red_nor.png"];
    UIImage *comfirmImagePress = [UIImage imageNamed:@"profile_btn_red_press.png"];
    [self.comfirmButton setBackgroundImage:comfirmImage forState:UIControlStateNormal];
    [self.comfirmButton setBackgroundImage:comfirmImagePress forState:UIControlStateHighlighted];
    self.comfirmButton.frame = CGRectMake(48.0f, 320.0f, comfirmImage.size.width, comfirmImage.size.height);
    [self.comfirmButton setTitle:buttonComfirm forState:UIControlStateNormal];
    [self.comfirmButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    self.comfirmButton.titleLabel.font = nickNameFont;
    [self.comfirmButton addTarget:self action:@selector(clickComfirmButton) forControlEvents:UIControlEventTouchUpInside];
    // 设置文字偏离
    [self.comfirmButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.view addSubview:self.comfirmButton];
    
    
    // 添加取消按钮
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *cancelImage = [UIImage imageNamed:@"profile_btn_gray_nor.png"];
    UIImage *cancelImagePress = [UIImage imageNamed:@"profile_btn_gray_press.png"];
    [self.cancelButton setBackgroundImage:cancelImage forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:cancelImagePress forState:UIControlStateHighlighted];
    self.cancelButton.frame = CGRectMake(175.0f, 320.0f, cancelImage.size.width, cancelImage.size.height);
    [self.cancelButton setTitle:buttonCancel forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = nickNameFont;
    [self.cancelButton addTarget:self action:@selector(clickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    // 设置文字偏离
    [self.cancelButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [self.view addSubview:self.cancelButton];
    
    // 设置描述文字
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    self.descriptionLabel.text = @"缘分呀！原来你们都认识…";
    self.descriptionLabel.font = descriptionFont;
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.frame = CGRectMake(320.0f / 2.0f - self.descriptionLabel.frame.size.width / 2.0f,
                                             395.0f,
                                             self.descriptionLabel.frame.size.width,
                                             self.descriptionLabel.frame.size.height);
    self.descriptionLabel.textColor = [UIColor colorWithHexString:@"#b8b8b8"];
    self.descriptionLabel.hidden = YES;
    [self.view addSubview:self.descriptionLabel];
    
//    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FFFEF3"];
}

-(void) clickComfirmButton{
    
    // 网络连接出错
    switch ([self getCurrentNetworkState]) {
        case NotReachable:{
                // 无网的情况
                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                return;
            }
            break;
        default:
            break;
    }
    
    [[CPUIModelManagement sharedInstance] responseActionWithMsg:self.exModel.messageModel actionFlag:REQ_FLAG_ACCEPT];
    CustomAlertView *custom = [CustomAlertView alloc];
    self.loadingView = [custom showLoadingMessageBox:@"稍等哦..." withTimeOut:LoadingView_TimeOut];
    self.loadingView.delegate = self;
}

// 超时
-(void) timeOut{
    [[HPTopTipView shareInstance] showMessage:@"操作超时"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    //#define response_action_res_code        @"resCode"
    //#define response_action_res_desc        @"resDesc"
    //#define response_action_msg_group       @"msgGroup"
    
    [self.loadingView close];

    if ([keyPath isEqualToString:@"responseActionDic"]) {
        NSNumber *code = (NSNumber *)[[CPUIModelManagement sharedInstance].responseActionDic objectForKey:response_action_res_code];
        if ([code intValue] == RESPONSE_CODE_SUCESS) {
            
            self.group = (CPUIModelMessageGroup *)[[CPUIModelManagement sharedInstance].responseActionDic objectForKey:response_action_msg_group];
            if (nil == self.group) {
                return;
            }
            // 操作成功跳转页面
            switch ([self.messageRequest.applyType intValue]) {
                case SYS_MSG_APPLY_TYPE_COMMON:{
                        // 添加好友成功 ，跳转到个人独立profile
                        SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:self.userInfo];
                        [self.navigationController pushViewController:singleIndependentProfile animated:YES];
                    }
                    break;
                case SYS_MSG_APPLY_TYPE_CLOSER:{
                        // 添加密友成功 ，跳转到个人独立profile
                        SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:self.userInfo];
                        [self.navigationController pushViewController:singleIndependentProfile animated:YES];
                    }
                    break;
                case SYS_MSG_APPLY_TYPE_LOVE:{
                        // 添加喜欢成功 ，跳转到个人独立profile
                        SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:self.userInfo];
                        [self.navigationController pushViewController:singleIndependentProfile animated:YES];
                    }
                    break;
                case SYS_MSG_APPLY_TYPE_COUPLE:{
                        // 添加couple成功 ，跳转到个人独立profile － 出庆祝页面
                        SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:self.userInfo];
                        [self.navigationController pushViewController:singleIndependentProfile animated:YES];
                    }
                    break;
                case SYS_MSG_APPLY_TYPE_MARRIED:{
                        // 添加夫妻成功 ，跳转到个人独立profile －－出现庆祝页面
                        SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:self.userInfo];
                        [self.navigationController pushViewController:singleIndependentProfile animated:YES];
                    }
                    break;
                default:
                    break;
            }
        }else if ([code intValue] == RESPONSE_CODE_ERROR) {
            // 出错 -- 服务器正在开小差，请退出应用重试
            NSString *errorStr = (NSString *)[[CPUIModelManagement sharedInstance].responseActionDic objectForKey:response_action_res_desc];
            for (UIViewController *controller in self.navigationController.viewControllers) {
//                if ([controller isMemberOfClass:[OtherIMViewController class]]) {
//                    //设置前页面显示错误消息
//                    OtherIMViewController *other = (OtherIMViewController *)controller;
//                    other.wrongText = errorStr;
//                    [self.navigationController popToViewController:other animated:YES];
//                    break;
//                }
            }
        }else {
            // 出错
            NSString *errorStr = (NSString *)[[CPUIModelManagement sharedInstance].responseActionDic objectForKey:response_action_res_desc];
            [[HPTopTipView shareInstance] showMessage:errorStr];
        }
    }
}

-(void) clickCancelButton{
    
    // 网络连接出错
    switch ([self getCurrentNetworkState]) {
        case NotReachable:{
                // 无网的情况
                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                return;
            }
            break;
        default:
            break;
    }
    
    // 拒绝或忽略
    [[CPUIModelManagement sharedInstance] responseActionWithMsg:self.exModel.messageModel actionFlag:REQ_FLAG_REFUSE];
    [self.navigationController popViewControllerAnimated:YES];

}

// 开始加couple完成动画
-(void) beginAnimation{    
    // uiview动画
    [UIImageView beginAnimations:@"ImageBegin" context:nil];
//    [UIImageView setAnimationDelay:0.1f];
    [UIImageView setAnimationDuration:0.5];
    [UIImageView setAnimationCurve:UIViewAnimationCurveLinear];
    
    // 动画的结束回调，回调方法内，增加下载按钮
    [UIImageView setAnimationDelegate:self];
    [UIImageView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    self.completedView.imageView.alpha = 1.0f;
    
    [UIImageView commitAnimations];
}

-(void) endAnimation{
    // uiview动画
    [UIImageView beginAnimations:@"ImageEnd" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationCurve:UIViewAnimationCurveLinear];
    
    // 动画的结束回调，回调方法内，增加下载按钮
    [UIImageView setAnimationDelegate:self];
    [UIImageView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    self.completedView.imageView.alpha = 0.0f;
    
    [UIImageView commitAnimations];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

// 动画的结束回调，回调方法内，增加下载按钮
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if ([animationID isEqualToString:@"ImageBegin"]) {
        [self performSelector:@selector(endAnimation) withObject:nil afterDelay:3.0f];
        
        if (self.msgApplyType == SYS_MSG_APPLY_TYPE_LOVE) {
//            OtherIMViewController *OtherIM = [[OtherIMViewController alloc] init:self.group ISNeedProfileStatus:NO];
//            [self.navigationController pushViewController:OtherIM animated:YES];
        }else {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isMemberOfClass:[HomeMainViewController class]]) {
                    HomeMainViewController *home = (HomeMainViewController*)controller;
                    [home changeCoupleIceBreak:NO];
                    [home scrollToRect:ContactFriend_Couple];
                    [self.navigationController popToViewController:home animated:YES];
                    break;
                }else {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    if ([controller isMemberOfClass:[HomePageViewController class]]) {
                        HomePageViewController *page = (HomePageViewController *)controller;
                        HomeMainViewController *home =  [page homeMainViewController];
                        [home changeCoupleIceBreak:NO];
                    }
                    [[HomePageViewController sharedHomePageViewController] transformToHomeMainController:ContactFriend_Couple animated:NO];
                    break;
                }
            }
        }
    }else if([animationID isEqualToString:@"ImageEnd"]){
        [self.completedView removeFromSuperview];
    }
}

-(NetworkStatus) getCurrentNetworkState{
    return [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// 返回前一个页面
-(void)doLeft{
    [self.navigationController popViewControllerAnimated:YES];
}

// 无操作
-(void)ChooseImageFrom:(NSInteger)imgtype tag:(NSInteger)tag{
    return;
}

-(void) dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"responseActionDic" context:@"responseActionDic"];
}

@end
