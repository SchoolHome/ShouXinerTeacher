//
//  AddContactWithProfileViewController.m
//  iCouple
//
//  Created by yong wei on 12-4-12.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "AddContactWithProfileViewController.h"
#import "CPDBManagement.h"
#import "CPLGModelAccount.h"
#import "HPTopTipView.h"
@interface AddContactWithProfileViewController ()
@property (nonatomic) BOOL isFirstAddContact;
@property (strong,nonatomic) FXBlockViewSubmit *messageBox;
// 添加超时
@property(nonatomic) BOOL isListenmodifyFriendTypeDic;

@property(nonatomic) BOOL isAddFriend;
// pop的层数
@property(nonatomic,assign) NSUInteger popCount;

-(void) addContactActionSheet : (id)sender;
-(void) headerButtonClick : (id) sender;
-(void) addContactRelation : (ContactType) contactType;
-(void) addCloseFriend;
-(void)NotificationHandler : (NSNotification *) notification;
@end

@implementation AddContactWithProfileViewController
@synthesize fnav = _fnav , topBGImage = _topBGImage , nickName = _nickName , addContactButton = _addContactButton , descriptionLabel = _descriptionLabel , personalHeadImg = _personalHeadImg , transparentBGImage =_transparentBGImage , profileModel = _profileModel;
@synthesize isFirstAddContact = _isFirstAddContact , messageBox = _messageBox;
@synthesize waitLabel = _waitLabel;
@synthesize isListenmodifyFriendTypeDic = _isListenmodifyFriendTypeDic , isAddFriend = _isAddFriend;
@synthesize popCount = _popCount;
@synthesize fullNameLabel = _fullNameLabel , guideLabel = _guideLabel;
@synthesize sexImage = _sexImage;

-(id) initAddContactWithUserInfor:(UserInforModel *)userInfor{
    
    self = [super init];
    if (self) {
        self.popCount = -1;
        self.profileModel = [UserProfileModel sharedInstance];
        self.profileModel.delegate = self;
        [self.profileModel loadUserProfileInfor:userInfor];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"modifyFriendTypeDic" options:0 context:@"AddContactWithProfileViewController"];
        isFirstShow = YES;
        self.isFirstAddContact = YES;
        self.isListenmodifyFriendTypeDic = YES;
        self.isAddFriend = YES;
        // 添加选择couple类型页面通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChooseCoupleNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationHandler:) name:@"ChooseCoupleNotification" object:nil];
        
        // 添加下载陌生人头像的页面通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StrangerHeaderImage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationHandler:) name:@"StrangerHeaderImage" object:nil];
    }
    
    return self;
}

-(id) initAddContactWithUserInfor:(UserInforModel *)userInfor withPopCount : (NSUInteger) count{
    self = [self initAddContactWithUserInfor:userInfor];
    
    if (self) {
        self.popCount = count;
    }
    
    return self;
}

-(void)NotificationHandler : (NSNotification *) notification{
    if ([notification.name isEqualToString:@"ChooseCoupleNotification"]) {
        NotificationContext *context = (NotificationContext *)[notification object];
        if (context.requestType == StrangerChoose) {
            // 调用后台添加couple
            if (context.chooseedType == IsLover) {
                CPLogInfo(@"--------点击添加为另一半----恋爱ing----好友姓名：%@------好友昵称 ：%@--------",
                          self.profileModel.personalUserInfor.fullName,
                          self.profileModel.personalUserInfor.nickName);
                CPLogInfo(@"--------开始调用后台服务----恋爱ing--类型：FRIEND_CATEGORY_COUPLE-----userName：%@-----",
                          self.profileModel.personalUserInfor.userName);
                [self do_show_loading_view_content_string:@"稍等哦..."];
                //添加Couple  关系为恋爱ing
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_COUPLE
                                                                       andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
                                                                   andInviteString:@"" andCouldExpose:YES];
            }else if (context.chooseedType == IsMarried) {
                CPLogInfo(@"--------点击添加为另一半----小夫妻----好友姓名：%@------好友昵称 ：%@--------",
                          self.profileModel.personalUserInfor.fullName,
                          self.profileModel.personalUserInfor.nickName);
                CPLogInfo(@"--------开始调用后台服务----小夫妻--类型：FRIEND_CATEGORY_MARRIED-----userName：%@-----",
                          self.profileModel.personalUserInfor.userName);
                [self do_show_loading_view_content_string:@"稍等哦..."];
                //添加Couple 关系为夫妻
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_MARRIED 
                                                                       andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
                                                                   andInviteString:@"" andCouldExpose:YES];
            }
        }
    }else if ([notification.name isEqualToString:@"StrangerHeaderImage"]) {
        StrangerHeaderImageModel *headerImageModel = (StrangerHeaderImageModel *)[notification object];
        if ([self.profileModel.personalUserInfor.userName isEqualToString:headerImageModel.userName]) {
            UIImage *image = [UIImage imageWithContentsOfFile:headerImageModel.headerImagePath];
            if (nil != image) {
                [self.personalHeadImg ResetImage:image];
            }
            
            UIImage *bgImage = [UIImage imageWithContentsOfFile:headerImageModel.bgImagePath];
            if (bgImage != nil) {
                self.topBGImage.image = bgImage;
            }
            if (nil != self.sexImage) {
                [self.sexImage removeFromSuperview];
                self.sexImage = nil;
            }
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
            NSLog(@"%d",hearderCount);
            
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
                        [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_gray_man_50x50.png"] forState:UIControlStateNormal];
                        [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_gray_man_50x50.png"] forState:UIControlStateHighlighted];
                    }else {
                        headImage = [UIImage imageWithContentsOfFile:userInfor.headerPath];
                        CPLogInfo(@"-----------------------小头像：%@--------------------",userInfor.headerPath);
                        if ( nil == headImage) {
                            [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_gray_man_50x50.png"] forState:UIControlStateNormal];
                            [headerbutton setBackgroundImage:[UIImage imageNamed:@"headpic_gray_man_50x50.png"] forState:UIControlStateHighlighted];
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
//                        UIImage *shadow = [UIImage imageNamed:@"man_big.png"];
                        shadowImage.image = shadow;
                        [self.view addSubview:shadowImage];
                    }
                }
            }
        }
    }else {
        [[HPTopTipView shareInstance] showMessage :[completedMsg objectForKey:@"200"]];
    }
}

-(void) headerButtonClick : (id) sender{
    UIButton *header = (UIButton *)sender;
    CPLogInfo(@"%d" , header.tag);
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.profileModel.delegate = nil;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIFont *nickNameFont = [UIFont boldSystemFontOfSize:14.0f];
    UIFont *fullNameFont = [UIFont boldSystemFontOfSize:12.0f];
    UIFont *guideFont = [UIFont boldSystemFontOfSize:12.0f];
    UIFont *descriptionFont = [UIFont boldSystemFontOfSize:12.0f];
    UIFont *addContactButtonFont = [UIFont systemFontOfSize:11.0f];
    
    // 添加背景image
    self.topBGImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 210.5f)];
    self.topBGImage.image = [UIImage imageNamed:@"bg_default.jpg"];
    [self.view addSubview:self.topBGImage];
    
    // 添加navigtionBar
    UIButton *leftbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftbutton.frame=CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
    [leftbutton setImage:[UIImage imageNamed:@"bt_im_profile_back.png"] forState:UIControlStateNormal];
    [leftbutton setImage:[UIImage imageNamed:@"bt_im_profile_backpress.png"] forState:UIControlStateHighlighted];

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
    self.nickName.text = self.profileModel.personalUserInfor.nickName;
    self.nickName.font = nickNameFont;
    [self.nickName sizeToFit];
    if (self.nickName.frame.size.width > 225.0f) {
        self.nickName.frame = CGRectMake(320.0f / 2.0f - 225.0f / 2.0f,
                                         227.0,
                                         225.0f,
                                         self.nickName.frame.size.height);
        self.nickName.lineBreakMode = UILineBreakModeTailTruncation;
    }else{
        self.nickName.frame = CGRectMake(320.0f / 2.0f - self.nickName.frame.size.width / 2.0f,
                                         227.0f,
                                         self.nickName.frame.size.width,
                                         self.nickName.frame.size.height);
    }
    self.nickName.textColor = [UIColor colorWithHexString:@"#333333"];
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
    NSLog(@"tel num : %@",self.profileModel.personalUserInfor.telPhoneNumber);
    NSLog(@"full name : %@",fullName);
    if (nil != fullName) {
        self.fullNameLabel.text = fullName;
        self.fullNameLabel.font = fullNameFont;
        [self.fullNameLabel sizeToFit];
        if (self.fullNameLabel.frame.size.width > 275.0f) {
            self.fullNameLabel.frame = CGRectMake(320.0f / 2.0f - 275.0f / 2.0f,
                                                  246.0f,
                                                  275.0f,
                                                  self.fullNameLabel.frame.size.height);
            self.fullNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        }else{
            self.fullNameLabel.frame = CGRectMake(320.0f / 2.0f - self.fullNameLabel.frame.size.width / 2.0f,
                                                  246.0f,
                                                  self.fullNameLabel.frame.size.width,
                                                  self.fullNameLabel.frame.size.height);
        }
        self.fullNameLabel.textColor = [UIColor colorWithHexString:@"#cccccc"];
        self.fullNameLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.fullNameLabel];
    }
    
    self.guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    self.guideLabel.text = @"你们现在是陌生人，要不要";
    self.guideLabel.font = guideFont;
    [self.guideLabel sizeToFit];
    self.guideLabel.frame = CGRectMake((320.0f - self.guideLabel.frame.size.width)/2.0f, 297.0f,
                                       self.guideLabel.frame.size.width,
                                       self.guideLabel.frame.size.height);
    self.guideLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    self.guideLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.guideLabel];
    
    // 添加更进一步按钮
    self.addContactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addContactButton setBackgroundImage:[UIImage imageNamed:@"btn_add_pink.png"] forState:UIControlStateNormal];
    [self.addContactButton setBackgroundImage:[UIImage imageNamed:@"btn_add_pink_hover.png"] forState:UIControlStateHighlighted];
    self.addContactButton.frame = CGRectMake(320.0f / 2.0f - 152.0f / 2.0f,
                                             320.0f,
                                             152.0f,
                                             44.5f);
    [self.addContactButton setTitle:@"更亲密点" forState:UIControlStateNormal];
    [self.addContactButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addContactButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.addContactButton.titleLabel.shadowColor = [UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.7f];
    self.addContactButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    
    // 设置文字偏离
    [self.addContactButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)];
    [self.addContactButton addTarget:self action:@selector(addContactActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addContactButton];
    
    // 设置描述文字
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
//    self.descriptionLabel.text = [NSString stringWithFormat: @"他们已经是%@的好友了", self.profileModel.personalUserInfor.nickName];
    self.descriptionLabel.text = [NSString stringWithFormat: @"缘分呀！原来你们都认识…"];

    self.descriptionLabel.font = descriptionFont;
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    [self.descriptionLabel sizeToFit];
    self.descriptionLabel.frame = CGRectMake(320.0f / 2.0f - self.descriptionLabel.frame.size.width / 2.0f,
                                     395.0f,
                                     self.descriptionLabel.frame.size.width,
                                     self.descriptionLabel.frame.size.height);
    self.descriptionLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    self.descriptionLabel.hidden = YES;
    [self.view addSubview:self.descriptionLabel];
    
    self.waitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    self.waitLabel.text = @"邀请已上路，给Ta点时间回复：）";
    self.waitLabel.font = descriptionFont;
    self.waitLabel.backgroundColor = [UIColor clearColor];
    [self.waitLabel sizeToFit];
    self.waitLabel.frame = CGRectMake(320.0f/2.0f - self.waitLabel.frame.size.width / 2.0f,
                                      320.0f,
                                      self.waitLabel.frame.size.width,
                                      self.waitLabel.frame.size.height);
    self.waitLabel.textColor = [UIColor colorWithHexString:@"#b8b8b8"];
    self.waitLabel.hidden = YES;
    [self.view addSubview:self.waitLabel];
    
    
//    self.navigationController.delegate = self;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FFFEF3"];
}

-(void) addContactActionSheet : (id)sender{
    
    NSMutableArray *contactType = [[NSMutableArray alloc] initWithCapacity:5];
    [contactType addObject:@"好友"];
    [contactType addObject:@"密友"];
    
    // 如果我有喜欢、暗恋或我有couple
    if (![[CPUIModelManagement sharedInstance] hasLover] && ![[CPUIModelManagement sharedInstance] hasCouple]) {
        
        [contactType addObject:@"喜欢"];
        [contactType addObject:@"另一半"];
    }
    
    UIActionSheet *contactSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                         delegate:self 
                                                         cancelButtonTitle:nil 
                                                         destructiveButtonTitle:nil 
                                                         otherButtonTitles:nil, 
                                                         nil];
    for (NSString *str in contactType) {
        [contactSheet addButtonWithTitle:str];
    }
    
    [contactSheet addButtonWithTitle:@"取消"];
    contactSheet.destructiveButtonIndex = contactSheet.numberOfButtons - 1;
    [contactSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        return;
    }else {
        
        // 如果没有网络连接
        if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
            [[HPTopTipView shareInstance] showMessage :@"网络不是很给力哦，稍等后再试试"];
            return;
        }
        
        if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
            [[HPTopTipView shareInstance] showMessage :@"网络不是很给力哦，稍等后再试试"];
            return;
        }
        
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        ContactType contactType;
        if ([buttonTitle isEqualToString:@"好友"]) {
            contactType = AddFriend;
        }else if ([buttonTitle isEqualToString:@"密友"]) {
            contactType = AddCloseFriend;
            self.isAddFriend = YES;
        }else if ([buttonTitle isEqualToString:@"喜欢"]) {
            contactType = AddLover;
            self.isAddFriend = NO;
        }else if ([buttonTitle isEqualToString:@"另一半"]) {
            contactType = AddCouple;
        }
        // 统计信息
        [self addContactRelation:contactType];
    }
}

-(void) addContactRelation : (ContactType) contactType{
    switch (contactType) {
        case AddFriend:{
                CPLogInfo(@"--------点击添加为好友--------好友姓名：%@------好友昵称 ：%@--------",
                      self.profileModel.personalUserInfor.fullName,
                      self.profileModel.personalUserInfor.nickName);
                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_NORMAL-----userName：%@-----",
                      self.profileModel.personalUserInfor.userName);
                [self do_show_loading_view_content_string:@"稍等哦..."];
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_NORMAL andUserName:self.profileModel.    personalUserInfor.userName andInviteString:@"" andCouldExpose:YES];
            }
            break;
        case AddCloseFriend: {
//                if (self.isFirstAddContact) {
//                    self.messageBox = [[FXBlockViewSubmit alloc] init];
////                    #warning 文本信息为确定
//                    self.messageBox.delegate = self;
////                    [self.messageBox doSetText:[NSString stringWithFormat:@"%@还不是你的好友,需要发送加好友的请求待他确认,同意后,自动成为 闺蜜/死党,对方不会知晓",self.profileModel.personalUserInfor.nickName]];
//                    [self.messageBox doSetText:@"Ta还不是你的好友，收到好友邀请并同意后会悄悄成为你的蜜友"];
//                    [self.messageBox doShowBlockViewInViewController:self];
//                    self.isFirstAddContact = NO;
//                }else {
                    CPLogInfo(@"--------点击添加为密友--------好友姓名：%@------好友昵称 ：%@--------",
                          self.profileModel.personalUserInfor.fullName,
                          self.profileModel.personalUserInfor.nickName);
                    CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_CLOSER-----userName：%@-----",
                          self.profileModel.personalUserInfor.userName);
                    [self do_show_loading_view_content_string:@"稍等哦..."];
                    [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_CLOSER andUserName:self.profileModel.personalUserInfor.userName andInviteString:@"" andCouldExpose:YES];
//                }
            }
            break;
        case AddLover: {
            if (self.isFirstAddContact) {
                self.messageBox = [[FXBlockViewSubmit alloc] init];
                //warning 文本信息为确定
                self.messageBox.delegate = self;
                [self.messageBox doSetText:[NSString stringWithFormat:@"%@还不是你的好友,需要发送加好友的请求待Ta确认,同意后,自动成为 喜欢对象,对方不会知晓",self.profileModel.personalUserInfor.nickName]];
                [self.messageBox doShowBlockViewInViewController:self.view];
                self.isFirstAddContact = NO;
            }else {
                CPLogInfo(@"--------点击添加为喜欢、暗恋--------好友姓名：%@------好友昵称 ：%@--------",
                      self.profileModel.personalUserInfor.fullName,
                      self.profileModel.personalUserInfor.nickName);
                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_LOVER-----userName：%@-----",
                      self.profileModel.personalUserInfor.userName);
                [self do_show_loading_view_content_string:@"稍等哦..."];
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_LOVER andUserName:self.profileModel.personalUserInfor.userName andInviteString:@"" andCouldExpose:YES];
                }
            }
            break;
        case AddCouple:{
                [ChooseCoupleModel sharedInstance].chooseedUserinfor = self.profileModel.personalUserInfor;
                ChooseCoupleTypeViewController *chooseCoupleType = [[ChooseCoupleTypeViewController alloc] initChooseCoupleTypeView:StrangerChoose];
                [self.navigationController pushViewController:chooseCoupleType animated:YES];
            }
            break;
        default:
            break;
    }
}

- (void)actionBlockViewCloseButtonTouchedSender:(UIButton *)closeButton{
//    if (self.isAddFriend) {
//        [self addCloseFriend];
//    }else {
//        [self addLover];
//    }
}
- (void)actionBlockViewCenterButtonTouchedSender:(UIButton *)centerButton{
    if (self.isAddFriend) {
        [self addCloseFriend];
    }else {
        [self addLover];
    }
}

-(void) addCloseFriend{
    CPLogInfo(@"--------点击添加为密友--------好友姓名：%@------好友昵称 ：%@--------",
          self.profileModel.personalUserInfor.fullName,
          self.profileModel.personalUserInfor.nickName);
    CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_CLOSER-----userName：%@-----",
          self.profileModel.personalUserInfor.userName);
    [self do_show_loading_view_content_string:@"稍等哦..."];
    [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_CLOSER andUserName:self.profileModel.personalUserInfor.userName andInviteString:@"" andCouldExpose:YES];
}

-(void) addLover{
    CPLogInfo(@"--------点击添加为喜欢、暗恋--------好友姓名：%@------好友昵称 ：%@--------",
          self.profileModel.personalUserInfor.fullName,
          self.profileModel.personalUserInfor.nickName);
    CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_LOVER-----userName：%@-----",
          self.profileModel.personalUserInfor.userName);
    [self do_show_loading_view_content_string:@"稍等哦..."];
    [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_LOVER andUserName:self.profileModel.personalUserInfor.userName andInviteString:@"" andCouldExpose:YES];
}

-(void) onTimeOut{
    //[super do_hide_loading_view];
    self.isListenmodifyFriendTypeDic = NO;
    [[HPTopTipView shareInstance] showMessage: @"操作超时"];
    CPLogInfo(@"--------------添加邀请超时-----------------");
}

// KVO监听modifyFriendTypeDic成员变量
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    // 如果服务器本地超时，则不监听
    if (!self.isListenmodifyFriendTypeDic) {
        self.isListenmodifyFriendTypeDic = YES;
        //[self do_show_toptip_view_toptip_string: @"操作超时"];
        //CPLogInfo(@"--------------添加邀请超时-----------------");
        return;
    }
    
    // 服务端处理任务完成
    if ([keyPath isEqualToString:@"modifyFriendTypeDic"]) {
        id code;
        // 获取code
        if ( ( code = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_code] ) != nil) {
            // 如果code是成功
            if ( [code intValue] == RESPONSE_CODE_SUCESS) {
                CPLogInfo(@"--------后台返回调用成功--------好友姓名：%@------好友昵称 ：%@--------",
                      self.profileModel.personalUserInfor.fullName,
                      self.profileModel.personalUserInfor.nickName);
                [self do_hide_loading_view];
                // 修改关系成功
                [[HPTopTipView shareInstance] showMessage: @"请求发送成功，等待对方同意"];
                self.addContactButton.hidden = YES;
                self.waitLabel.hidden = NO;
            }else {
                CPLogInfo(@"--------后台返回调用失败--------好友姓名：%@------好友昵称 ：%@--------",
                      self.profileModel.personalUserInfor.fullName,
                      self.profileModel.personalUserInfor.nickName);
                [super do_hide_loading_view];
                // 修改关系失败
                [[HPTopTipView shareInstance] showMessage: [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc]];
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
//    // 如果是第一次呈现此界面，返回
//    if (isFirstShow) {
//        isFirstShow = NO;
//        return;
//    }
//    if ([viewController isMemberOfClass:[ChooseCoupleTypeViewController class]]) {
//        return;
//    }else if([viewController isMemberOfClass:[AddContactViewController class]]){
//        return;
//    }else if([viewController isMemberOfClass:[AddContactWithProfileViewController class]]){
//        // 调用后台添加couple
//        if ([ChooseCoupleModel sharedInstance].chooseedType == IsLover) {
//            CPLogInfo(@"--------点击添加为另一半----恋爱ing----好友姓名：%@------好友昵称 ：%@--------",
//                  self.profileModel.personalUserInfor.fullName,
//                  self.profileModel.personalUserInfor.nickName);
//            CPLogInfo(@"--------开始调用后台服务----恋爱ing--类型：FRIEND_CATEGORY_COUPLE-----userName：%@-----",
//                  self.profileModel.personalUserInfor.userName);
//            [self do_show_loading_view_content_string:@"正在发送请求"];
//            //添加Couple  关系为恋爱ing
//            [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_COUPLE
//                                                  andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
//                                                  andInviteString:@"" andCouldExpose:YES];
//        }else if ([ChooseCoupleModel sharedInstance].chooseedType == IsMarried) {
//            CPLogInfo(@"--------点击添加为另一半----小夫妻----好友姓名：%@------好友昵称 ：%@--------",
//                  self.profileModel.personalUserInfor.fullName,
//                  self.profileModel.personalUserInfor.nickName);
//            CPLogInfo(@"--------开始调用后台服务----小夫妻--类型：FRIEND_CATEGORY_MARRIED-----userName：%@-----",
//                  self.profileModel.personalUserInfor.userName);
//            [self do_show_loading_view_content_string:@"正在发送请求"];
//            //添加Couple 关系为夫妻
//            [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_MARRIED 
//                                                  andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
//                                                  andInviteString:@"" andCouldExpose:YES];
//        }
//    }
}

// 无操作
-(void)ChooseImageFrom:(NSInteger)imgtype tag:(NSInteger)tag{
    return;
}

// 返回前一个页面
-(void)doLeft{
    [self.navigationController popViewControllerAnimated:YES];
//    if (self.popCount == -1) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else {
//        int index = [[self.navigationController viewControllers] indexOfObject:self];
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-self.popCount] animated:YES];
//    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"modifyFriendTypeDic" context:@"AddContactWithProfileViewController"];
}

@end
