//
//  AddContractViewController.m
//  iCouple
//
//  Created by yong wei on 12-3-28.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "AddContactViewController.h"
#import "HPTopTipView.h"
#import <AddressBook/AddressBook.h>

// 好友最大数量
#define FriendMaxCount 148
// 密友好友最大数量
#define CloseFriendMaxCount 17
// 超时时间
//#define Timeout 1.0f

@interface AddContactViewController ()
@property (strong,nonatomic) FXBlockViewSubmit *messageBox;
@property (strong,nonatomic) MultiSelectTableViewCell *selectedCell;
@property (strong,nonatomic) SingleTableViewCell *singleCell;
@property (strong,nonatomic) NSMutableDictionary *contactTelDictionary;

// 短信接口超时
@property (nonatomic) BOOL isListenFindMobileIsUserDic;
// 添加喜欢超时
@property(nonatomic) BOOL isListenmodifyFriendTypeDic;

// 初始化界面
-(void) initViewControl;
//-(void) initRightButton;
// 输入键盘打开触发
-(void) keyboardDidShow : (id) sender;
// 多选按钮点击触发
-(void) MultiSelectClick : (id) sender;
// 点击多选按钮头像触发事件
-(void) MultiSelectUserImageButton : (id) sender;

-(void) changeMultiCellState : (MultiSelectTableViewCell *)cell;

-(UITableViewCell *) createEventCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withSectionModel : (SectionModel *)sectionModel;
-(UITableViewCell *) createMultiCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  withSectionModel : (SectionModel *)sectionModel;
-(UITableViewCell *) createSingleCell: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  withSectionModel : (SectionModel *)sectionModel;

// 点击eventCellButton事件
// 加为朋友
-(void) addFriends : (id) sender;
// 加为密友
-(void) addCloseFriends : (id) sender;
// 为添加密友保存的临时变量，，委托时调用
@property (strong,nonatomic) AddContactCellBase *addCloseFriendCell;
@property (strong,nonatomic) UserInforModel *addCloseFriendData;
@property (nonatomic) FirstMessageShow firstMessage;
// 调用后台添加密友
-(void) addCloseFriends : (AddContactCellBase *)cell withData :(UserInforModel *)data;
// 加喜欢时发送短信并且是第一次调用
-(void) sendMessageWithFirstAddLover : (SingleTableViewCell *)cell;

-(void)NotificationHandler : (NSNotification *) notification;

-(void) sendInvited : (id) sender;
-(void) BackAction;
-(UserInforModel *) getUserInforWithUserName : (NSString *)userName;


@property (nonatomic,strong) UIImageView *adImage;
// 检测是否有访问通讯录的权限
-(void) checkAddressBoosAccess;
@end

@interface AddContactViewController (Message)

-(void) chooseTelNumberWithSingleCell : (SingleTableViewCell *)cell;
-(void) sendMessageWithTelNumber : (NSArray *) telNumberArray;
-(void) refreshNavigationButtonState;
-(void) findMobileIsUserWithMobiles : (NSArray *) telNumber withLoadText : (NSString *) LoadText;
@end

@interface AddContactViewController (UserProfile)
-(void) openUserProfileController : (id) sender;
@end

@implementation AddContactViewController
@synthesize myTableView = _myTableView , searchBar = _searchBar , isOpenKeyBoard = _isOpenKeyBoard;
@synthesize uiAddContactEnum = _uiAddContactEnum , addContactModel = _addContactModel , NotFoundLabel = _NotFoundLabel;
@synthesize selectedCell = _selectedCell , operationQueue = _operationQueue , isFirstShow = _isFirstShow;
@synthesize fnav = _fnav , singleCell = _singleCell;

@synthesize addCloseFriendCell = _addCloseFriendCell , addCloseFriendData = _addCloseFriendData;
@synthesize messageBox =_messageBox , firstMessage = _firstMessage , isListenFindMobileIsUserDic = _isListenFindMobileIsUserDic , isListenmodifyFriendTypeDic = _isListenmodifyFriendTypeDic;
@synthesize contactTelDictionary = _contactTelDictionary;
@synthesize adImage = _adImage;

- (id) initWithUIAddContract:(UIAddContactView)UIAddContactEnum{
    self = [super init];
    if (self) {
        self.uiAddContactEnum = UIAddContactEnum;
        self.addContactModel = [[AddContactModel alloc] initWithData : UIAddContactEnum];
        isFirstAddCloseFriendContact = YES;
        isSendMessageWithAddCouple = NO;
        isChooseCoupleType = NO;
        self.isFirstShow = YES;
        self.isListenFindMobileIsUserDic = YES;
        self.isListenmodifyFriendTypeDic = YES;
        self.firstMessage = sendNone;
        self.contactTelDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        //self.loading_interval = Timeout;
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"modifyFriendTypeDic" options:0 context:@"modifyFriendTypeDic"];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"findMobileIsUserDic" options:0 context:@"findMobileIsUserDic"];
        // 添加键盘出现事件
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        // 添加选择couple类型页面通知
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotificationHandler:) name:@"ChooseCoupleNotification" object:nil];

    }
    return self;
}

-(void) checkAddressBoosAccess{
    if (&ABAddressBookCreateWithOptions != NULL) {
        CFErrorRef error = nil;
        ABAddressBookRef m_addressBook = ABAddressBookCreateWithOptions(NULL,&error);
//        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        ABAddressBookRequestAccessWithCompletion(m_addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    // 出现错误
                    NSLog(@"申请授权出错");
                } else if (!granted) {
                    // 被拒绝授权
                    self.adImage = [[UIImageView alloc] initWithFrame:CGRectMake((320.0f - 274.0f) / 2.0f, 130.0f, 274.0f, 274.0f)];
                    [self.adImage setImage:[UIImage imageNamed:@"float_open_addbook.png"]];
                    [self.view addSubview:self.adImage];
                    
                    [UIImageView beginAnimations:@"begin" context:nil];
                    [UIImageView setAnimationDelay:8.0f];
                    [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                    
                    [self.adImage setAlpha:1.0f];
                    
                    [UIImageView commitAnimations];
                    [self performSelector:@selector(removeAdImage) withObject:nil afterDelay:8.0f];
                }
            });
        });
        
//        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
//        dispatch_release(sema);

    }
}

-(void) removeAdImage{
    [self.adImage removeFromSuperview];
}

-(void)NotificationHandler : (NSNotification *) notification{
    NotificationContext *notificationContext = (NotificationContext *)[notification object];
    if (notificationContext.requestType == ContactChoose) {
        isReceiveKVO = YES;
        if (isSendMessageWithAddCouple) {
            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:self.singleCell.contactID];
            if (notificationContext.chooseedType == IsLover) {
                contract.isSelected = YES;
                isChooseCoupleType = YES;
                addContactTypeWithSendMessage = FRIEND_CATEGORY_COUPLE;
                NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
                [TelNumber addObject:contract.selectedTelNumber];
                CPLogInfo(@"--------点击添加为另一半--------联系人姓名：%@------好友电话 ：%@--------",contract.fullName,contract.selectedTelNumber);
                CPLogInfo(@"--------开始调用后台服务--------恋爱ing------类型：FRIEND_CATEGORY_COUPLE----------");
//                #warning 短信loading文本信息未确定 - 添加恋爱ing
                [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
            }else if (notificationContext.chooseedType == IsMarried) {
                isChooseCoupleType = YES;
                contract.isSelected = YES;
                addContactTypeWithSendMessage = FRIEND_CATEGORY_MARRIED;
                NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
                [TelNumber addObject:contract.selectedTelNumber];
                CPLogInfo(@"--------点击添加为另一半--------联系人姓名：%@------好友电话 ：%@--------",contract.fullName,contract.selectedTelNumber);
                CPLogInfo(@"--------开始调用后台服务--------小夫妻------类型：FRIEND_CATEGORY_MARRIED----------");
//                #warning 短信loading文本信息未确定 - 添加小夫妻
                [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
            }else {
                contract.isSelected = NO;
                contract.isSendedMessage = NO;
                contract.selectedTelNumber = @"";
                isChooseCoupleType = NO;
            }
        }else {
            // 调用后台添加couple
            if (notificationContext.chooseedType == IsLover) {
                CPLogInfo(@"--------点击添加为另一半----恋爱ing----好友姓名：%@------好友昵称 ：%@--------",
                          [ChooseCoupleModel sharedInstance].chooseedUserinfor.fullName,
                          [ChooseCoupleModel sharedInstance].chooseedUserinfor.nickName);
                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_COUPLE-----userName：%@-----",
                          [ChooseCoupleModel sharedInstance].chooseedUserinfor.userName);
                [self do_show_loading_view_content_string:@"发送另一半请求"];
                
                // 如果没有网络连接
                if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
//                    [self do_show_toptip_view_toptip_string :@"网络不是很给力哦，稍等后再试试"];
                    [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                    return;
                }
                
                if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
                    [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                    return;
                }
                //添加Couple  关系为恋爱ing
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_COUPLE 
                                                                       andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
                                                                   andInviteString:@"" andCouldExpose:YES];
            }else if (notificationContext.chooseedType == IsMarried) {
                CPLogInfo(@"--------点击添加为另一半----小夫妻----好友姓名：%@------好友昵称 ：%@--------",
                          [ChooseCoupleModel sharedInstance].chooseedUserinfor.fullName,
                          [ChooseCoupleModel sharedInstance].chooseedUserinfor.nickName);
                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_MARRIED-----userName：%@-----",
                          [ChooseCoupleModel sharedInstance].chooseedUserinfor.userName);
                
                // 如果没有网络连接
                if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
                    [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                    return;
                }
                
                if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
                    [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                    return;
                }
                [self do_show_loading_view_content_string:@"发送另一半请求"];
                //添加Couple 关系为夫妻
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_MARRIED 
                                                                       andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
                                                                   andInviteString:@"" andCouldExpose:YES];
            }
        }
    }
}

- (void)do_init_loading_view{
    [super do_init_loading_view];
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isReceiveKVO = YES;
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    self.navigationController.delegate = nil;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 当该界面出栈时，接收kvo消息
//    isReceiveKVO = YES;
}

-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // 当该界面被压栈时，不接收kvo消息
    isReceiveKVO = NO;

}

-(void) doLeft{
    [self BackAction];
}

-(void) BackAction {
    //[self dismissModalViewControllerAnimated:YES];
    NSLog(@"%@",self.navigationController.viewControllers);
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) doRight{
    [self sendInvited:self.fnav.rightbutton];
}

// 传输电话号码与远程服务器通信
-(void) sendInvited:(id)sender{
    // 统计信息
    
    NSArray *keys = [self.addContactModel.contactDictionary allKeys];
    NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:10];
    for (id key in keys) {
        ContactModel *contactDic = [self.addContactModel.contactDictionary objectForKey:key];
        if (contactDic.isSelected && contactDic.isSendedMessage == NO) {
            // 统计信息
            [TelNumber addObject:contactDic.selectedTelNumber];
            CPLogInfo(@"---------发送检查的电话：%@----------",contactDic.selectedTelNumber);
        }
    }
    
    if (self.uiAddContactEnum == UIAddFriends) {
        addContactTypeWithSendMessage = FRIEND_CATEGORY_NORMAL;
    }else if (self.uiAddContactEnum == UIAddCloseFriends) {
        addContactTypeWithSendMessage = FRIEND_CATEGORY_CLOSER;
    }

//    #warning 短信loading文本信息未确定
    [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
}


-(void) findMobileIsUserWithMobiles : (NSArray *) telNumber withLoadText : (NSString *) LoadText{
    
    if (self.uiAddContactEnum == UIAddCloseFriends) {
        if (self.addContactModel.userCloseFriendCount >= CloseFriendMaxCount) {
            [[HPTopTipView shareInstance] showMessage :@"两三知己足矣，蜜友已满17人啦"];
            return;
        }
    }
    
    if (self.addContactModel.userFriendCount >= FriendMaxCount) {
        if (self.uiAddContactEnum == UIAddCouple) {
            [[HPTopTipView shareInstance] showMessage :@"人缘真好，好友已满148人啦"];
        }else {
            [[HPTopTipView shareInstance] showMessage :@"人缘真好，好友已满148人啦"];
        }
        return;
    }
    
    // 如果没有网络连接
    if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    
    if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    
    [self do_show_loading_view_content_string:LoadText];
    [[CPUIModelManagement sharedInstance] findMobileIsUserWithMobiles:telNumber];
    
}

-(void) sendMessageWithTelNumber : (NSArray *) telNumberArray{
    
    if (nil == telNumberArray || [telNumberArray count] == 0) {
        return;
    }
    
    if( [MFMessageComposeViewController canSendText] ){
        // 统计信息
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
//        #warning 短信发送内容未确定，需完善
        controller.recipients = telNumberArray;
        controller.body = @"嘿我正玩双双呢，情侣的爱情传声筒，蜜友卖萌搞笑必备，你快下载！咱们就能变声/八卦/闹闹/传情啦！http://s2.tl/dl.htm";
        controller.messageComposeDelegate = self;
        [[HPStatusBarTipView shareInstance] setHidden:YES];
        [self presentModalViewController:controller animated:YES];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" 
                                                  message:@"需要发送短信邀请对方，请使用iphone进行邀请" 
                                                  delegate:self 
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    NSArray *keys = [self.addContactModel.contactDictionary allKeys];
    BOOL isClose = NO;
    [[HPStatusBarTipView shareInstance] setHidden:NO];
    switch (result) {
        case MessageComposeResultCancelled:
            /*发送短信邀请添加喜欢的时候，用户取消掉，重置短信选择属性*/
            if (self.uiAddContactEnum == UIAddLike || self.uiAddContactEnum == UIAddCouple) {
                for (id key in keys) {
                    ContactModel *contactDic = [self.addContactModel.contactDictionary objectForKey:key];
                    if (contactDic.isSelected && contactDic.isSendedMessage == NO) {
                        contactDic.isSelected = NO;
                    }
                }
            }
            break;
        case MessageComposeResultSent:
            for (id key in keys) {
                ContactModel *contactDic = [self.addContactModel.contactDictionary objectForKey:key];
                if (contactDic.isSelected && contactDic.isSendedMessage == NO) {
                    contactDic.isSendedMessage = YES;
                    
                    //通过短信邀请某人的时候，需要调用此方法
                    if (addContactTypeWithSendMessage == FRIEND_CATEGORY_NORMAL) {
                        CPLogInfo(@"---------邀请的类型：%@--------对应的短信的电话：%@----------------",@"好友",contactDic.selectedTelNumber);
                    }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_CLOSER) {
                        CPLogInfo(@"---------邀请的类型：%@--------对应的短信的电话：%@----------------",@"密友",contactDic.selectedTelNumber);
                    }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_LOVER) {
                        CPLogInfo(@"---------邀请的类型：%@--------对应的短信的电话：%@----------------",@"喜欢暗恋",contactDic.selectedTelNumber);
                    }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_COUPLE) {
                        CPLogInfo(@"---------邀请的类型：%@--------对应的短信的电话：%@----------------",@"恋爱ing",contactDic.selectedTelNumber);
                    }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_MARRIED) {
                        CPLogInfo(@"---------邀请的类型：%@--------对应的短信的电话：%@----------------",@"小夫妻",contactDic.selectedTelNumber);
                    }
                    [[CPUIModelManagement sharedInstance] inviteFriendWithCategory:addContactTypeWithSendMessage andMobile:contactDic.selectedTelNumber andCouldExpose:YES];
                    
                }
            }
            // 统计信息
            isClose = YES;
            [self.myTableView reloadData];
            break;
        case MessageComposeResultFailed:
            break;
        default:
            break;
    }
    self.myTableView.frame = CGRectMake(0, 89, 320, 371);
    [self refreshNavigationButtonState];
    
    // 如果邀请喜欢或邀请另一半是产品用户并且发送邀请成功，返回上个界面
    if (self.uiAddContactEnum == UIAddLike || self.uiAddContactEnum == UIAddCouple) {
        if (isClose) {
            [controller dismissModalViewControllerAnimated:NO];
            [self do_hide_loading_view];
            self.isListenFindMobileIsUserDic = YES;
            [self doLeft];
        }else {
            [controller dismissModalViewControllerAnimated:YES];
        }
    }else {
        [controller dismissModalViewControllerAnimated:YES];
    }
}

-(NSOperationQueue *) operationQueue{
    if (nil == _operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initViewControl];
    [self checkAddressBoosAccess];
    CPLogInfo(@"AddContactViewController is init!!!");
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)guesture{
    [self doLeft];
}


-(void) initViewControl{
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, 320, 45)];
    // 替换searchBar背景
    [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
    [self.searchBar insertSubview:imageView atIndex:0];
    
    [self.view addSubview:self.searchBar];
    self.searchBar.delegate = self;
    
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 89, 320, 371)];
    [self.view addSubview:self.myTableView];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    
    // added by xxx 2012.9.15
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.myTableView addGestureRecognizer:rightSwipeGestureRecognizer];
    
    
    self.NotFoundLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,88,0,0)];
    self.NotFoundLabel.textAlignment = UITextAlignmentCenter;
    self.NotFoundLabel.font = [UIFont fontWithName:@"Times New Roman" size:18.0f];
    self.NotFoundLabel.text = @"无结果";
    self.NotFoundLabel.textColor = [UIColor grayColor];
    [self.NotFoundLabel sizeToFit];
    self.NotFoundLabel.frame = CGRectMake(160.0f - self.NotFoundLabel.bounds.size.width / 2 , 
                                          96.0f, self.NotFoundLabel.bounds.size.width, 
                                          self.NotFoundLabel.bounds.size.height);
    
    [self.view addSubview:self.NotFoundLabel];
    self.NotFoundLabel.hidden = YES;
    
    
    // 添加navigtionBar
    UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame=CGRectMake(2.5f, 4.0f, 36.0f, 36.0f);
    [leftButton setImage:[UIImage imageNamed:@"icon_nav_list_back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"sign_nav_icon_list_back_hover.png"] forState:UIControlStateHighlighted];
    
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame=CGRectMake(251.0f, 9.0f, 62.5f, 26.5f);
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_add.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_add_press.png"] forState:UIControlStateHighlighted];
    rightButton.enabled = NO;
    [rightButton setTitle:@"邀请" forState:UIControlStateNormal];
    [rightButton setTitleEdgeInsets:UIEdgeInsetsMake(3.0f, 0.0f, 0.0f, 0.0f)];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:12.0f];
//    rightButton.titleLabel.textColor = [UIColor colorWithWhite:0.5f alpha:0.5f];
    [rightButton setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.75f] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.75f] forState:UIControlStateHighlighted];
    [rightButton.titleLabel setShadowColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f]];
    [rightButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    
    rightButton.frame = CGRectMake(320-134/2-10, (44-58/2)/2, 134/2, 58/2);

    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"topredbar_btn_01_nor"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"topredbar_btn_01_press"] forState:UIControlStateHighlighted];
    
    
    NSString *titleText;
    switch (self.uiAddContactEnum) {
        case UIAddFriends:
            titleText = @"添加好友";
            break;
        case UIAddCloseFriends:
            titleText = @"添加蜜友";
            break;
        case UIAddLike:
            titleText = @"加为喜欢的人";
            break;
        case UIAddCouple:
            titleText = @"添加另一半";
            break;
        default:
            break;
    }
    
    NavigationBothStyle *style;
    if (self.uiAddContactEnum == UIAddFriends || self.uiAddContactEnum == UIAddCloseFriends) {
        style=[[NavigationBothStyle alloc] initWithTitle:titleText Leftcontrol:leftButton Rightcontrol:rightButton];
    }else {
        style=[[NavigationBothStyle alloc] initWithTitle:titleText Leftcontrol:leftButton Rightcontrol:nil];
    }
    style.background = [UIImage imageNamed:@"list_top_bg.png"];

    
    self.fnav =[[FanxerNavigationBarControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f) withStyle:style withDefinedUserControl:YES];
    self.fnav.backageview.frame =CGRectMake(0.0f, 0.0f, 320.0f, 44.0f);
    
    self.fnav._delegate = self;
    self.delegate = self;
    [self.view addSubview:self.fnav];
    
    self.navigationController.delegate = self;
    
//    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"modifyFriendTypeDic" options:0 context:@"modifyFriendTypeDic"];
//    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"findMobileIsUserDic" options:0 context:@"findMobileIsUserDic"];
//    // 添加键盘出现事件
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil]; 
}

-(void) onTimeOut{
    [super do_hide_loading_view];
    self.isListenFindMobileIsUserDic = NO;
    self.isListenmodifyFriendTypeDic = NO;
    [[HPTopTipView shareInstance] showMessage: @"操作超时"];
}

-(void)willDoLeft
{
    [self do_hide_loading_view];
    [self doLeft];
}
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (!isReceiveKVO) {
        return;
    }
    id code;
    // 服务端处理任务完成
    if ([keyPath isEqualToString:@"modifyFriendTypeDic"]) {
        
        if (self.uiAddContactEnum == AddFriend) {
            /*************** 如果时添加好友界面 ***************/
            if ( ( code = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_code] ) != nil) {
                // 如果code是成功 -- 添加为好友关系邀请发送成功
                if ( [code intValue] == RESPONSE_CODE_SUCESS ) {
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    
                    CPLogInfo(@"---------加好友后台返回调用成功消息---userName：%@--------",userName);
                    
                    UserInforModel *userInfor = [self getUserInforWithUserName:userName];
                    if (nil != userInfor) {
                        userInfor.userInforState = UserStateSucceed;
                        userInfor.descriptionState = 1;
                        [self.myTableView reloadData];
                    }
                }else {
                    // 添加为好友关系邀请发送失败 提示错误消息
                    [[HPTopTipView shareInstance] showMessage: [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc]];
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    
                    CPLogInfo(@"---------加好友后台返回调用失败消息---userName：%@--------",userName);
                    
                    UserInforModel *userInfor = [self getUserInforWithUserName:userName];
                    if (nil != userInfor) {
                        userInfor.userInforState = UserStateFail;
                        [self.myTableView reloadData];
                    }
                }
            }
        }else if (self.uiAddContactEnum == AddCloseFriend) {
            /*************** 如果是添加密友界面 ***************/
            if ( ( code = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_code] ) != nil) {
                // 如果code是成功 -- 添加为密友关系邀请发送成功
                if ( [code intValue] == RESPONSE_CODE_SUCESS ) {
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    CPLogInfo(@"---------加密友后台返回调用成功消息---userName：%@--------",userName);
                    UserInforModel *userInfor = [self getUserInforWithUserName:userName];
                    if (nil != userInfor) {
                        // 如果该好友为双双推荐的朋友，则规则按照添加好友规则执行
                        if (nil != [self.addContactModel.coupleRecommendDictionary objectForKey:userName]) {
                            userInfor.userInforState = UserStateSucceed;
                            userInfor.descriptionState = 1;
                            [self.myTableView reloadData];
                        }else {
                            userInfor.userInforState = UserStateSucceedForCloseFriend;
                            [self.myTableView reloadData];
                        }
                    }
                }else {
                    // 添加为密友关系邀请发送失败 提示错误消息
                    [[HPTopTipView shareInstance] showMessage: [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc]];
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    CPLogInfo(@"---------加密友后台返回调用失败消息---userName：%@--------",userName);
                    UserInforModel *userInfor = [self getUserInforWithUserName:userName];
                    if (nil != userInfor) {
                        userInfor.userInforState = UserStateFail;
                        [self.myTableView reloadData];
                    }
                }
            }
        }else if (self.uiAddContactEnum == UIAddLike) {
            /*************** 如果是添加喜欢\暗恋界面 ***************/
            // 如果服务器本地超时，则不监听
            if (!self.isListenmodifyFriendTypeDic) {
                self.isListenmodifyFriendTypeDic = YES;
                //[self do_show_toptip_view_toptip_string: @"操作超时"];
                CPLogInfo(@"--------------添加喜欢、暗恋邀请超时-----------------");
                return;
            }
            if ( ( code = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_code] ) != nil) {
                // 如果code是成功 -- 添加为喜欢、暗恋关系邀请发送成功
                if ( [code intValue] == RESPONSE_CODE_SUCESS ) {
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    CPLogInfo(@"---------加喜欢、暗恋后台返回调用成功消息---userName：%@--------",userName);
                    
                    
                    self.isListenmodifyFriendTypeDic = YES;
                   // [self doLeft];
                    //2012.9.15改动by zq
                    //[self do_hide_loading_view];
                    [self performSelector:@selector(willDoLeft) withObject:nil afterDelay:1.5];
                }else {
                    [self do_hide_loading_view];
                    self.isListenmodifyFriendTypeDic = YES;
                    // 添加为喜欢、暗恋关系邀请发送失败 提示错误消息
                    [[HPTopTipView shareInstance] showMessage: [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc]];
                    NSString *message = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc];
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    [[HPTopTipView shareInstance] showMessage:message];
                    CPLogInfo(@"---------加喜欢、暗恋后台返回调用失败消息---userName：%@--------",userName);
                    CPLogInfo(@"---------加喜欢、暗恋后台返回调用失败消息：%@--------",[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc]);
                }
            }
        }else if (self.uiAddContactEnum == UIAddCouple) {
            /*************** 如果是添加另一半界面 ***************/
            // 如果服务器本地超时，则不监听
            if (!self.isListenmodifyFriendTypeDic) {
                //warning 超时文本未定义
                self.isListenmodifyFriendTypeDic = YES;
                //[self do_show_toptip_view_toptip_string: @"操作超时"];
                CPLogInfo(@"--------------添加另一半邀请超时-----------------");
                return;
            }
            if ( ( code = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_code] ) != nil) {
                // 如果code是成功 -- 添加为另一半关系邀请发送成功
                if ( [code intValue] == RESPONSE_CODE_SUCESS ) {
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    CPLogInfo(@"---------加另一半后台返回调用成功消息---userName：%@--------",userName);
                    
                    
                    self.isListenmodifyFriendTypeDic = YES;
                    //[self doLeft];
                    //2012.9.15改动by zq
                    //[self do_hide_loading_view];
                    [self performSelector:@selector(willDoLeft) withObject:nil afterDelay:1.5];
                }else {
                    [self do_hide_loading_view];
                    self.isListenmodifyFriendTypeDic = YES;
                    // 添加为另一半关系邀请发送失败 提示错误消息
                    [[HPTopTipView shareInstance] showMessage: [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc]];
                    NSString *message = [[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_res_desc];
                    NSString *userName = (NSString *)[[CPUIModelManagement sharedInstance].modifyFriendTypeDic objectForKey:modify_friend_dic_user_name];
                    [[HPTopTipView shareInstance] showMessage:message];
                    CPLogInfo(@"---------加另一半后台返回调用失败消息---userName：%@--------",userName);
                }
            }
        }
    }else if ([keyPath isEqualToString:@"findMobileIsUserDic"]) {
        
        // 如果服务器本地超时，则不监听
        if (!self.isListenFindMobileIsUserDic) {
            //warning 超时文本未定义
            self.isListenFindMobileIsUserDic = YES;
            
            CPLogInfo(@"--------------短信邀请超时-----------------");
            return;
        }
        
        [self do_hide_loading_view];
        /*用户手机号码传输回调*/
        // 获取code
        if ( ( code = [[CPUIModelManagement sharedInstance].findMobileIsUserDic objectForKey:find_mobile_is_user_res_code] ) != nil) {
            // 如果code是成功 -- 短信验证完成
            self.isListenFindMobileIsUserDic = YES;
            if ( [code intValue] == RESPONSE_CODE_SUCESS) {
                NSArray *resData = (NSArray *)[[CPUIModelManagement sharedInstance].findMobileIsUserDic objectForKey:find_mobile_is_user_data];
                NSMutableArray *resMobileArray = [[NSMutableArray alloc] init];
                NSMutableArray *resNameArray = [[NSMutableArray alloc] init];
                
                for(NSDictionary *dicData in resData){
                    [resMobileArray addObject:[dicData objectForKey:find_mobile_is_user_mobiles]];
                    [resNameArray addObject:[dicData objectForKey:find_mobile_is_user_uname]];
                }
                
                for (NSString *tel1 in resMobileArray) {
                    CPLogInfo(@"-------------------------返回的电话号码：%@",tel1);
                }
                
                NSMutableArray *needSendMessageTelNumber = [NSMutableArray arrayWithCapacity:10];
                
                NSArray *keys = [self.addContactModel.contactDictionary allKeys];
                [self.contactTelDictionary removeAllObjects];
                for (id key in keys) {
                    ContactModel *contactDic = [self.addContactModel.contactDictionary objectForKey:key];
                    if (contactDic.isSelected && contactDic.isSendedMessage == NO) {
                        
                        if (![resMobileArray containsObject:contactDic.selectedTelNumber]) {
                            // 不是产品用户
                            [needSendMessageTelNumber addObject:contactDic.selectedTelNumber];
                        }else {
                            // 是产品用户
                            [self.contactTelDictionary setValue:contactDic forKey:key];
                            
                            NSString *userName = [resNameArray objectAtIndex: [resMobileArray indexOfObject:contactDic.selectedTelNumber]];

                            
                            if (addContactTypeWithSendMessage == FRIEND_CATEGORY_NORMAL) {
                                CPLogInfo(@"-----是产品用户时调用后台服务modifyFriendTypeWithCategory----邀请的类型：%@--------邀请的UserName：%@------",@"好友", userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_CLOSER) {
                                CPLogInfo(@"-----是产品用户时调用后台服务modifyFriendTypeWithCategory----邀请的类型：%@--------邀请的UserName：%@------",@"密友", userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_LOVER) {
                                CPLogInfo(@"-----是产品用户时调用后台服务modifyFriendTypeWithCategory----邀请的类型：%@--------邀请的UserName：%@------",@"喜欢暗恋", userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_COUPLE) {
                                CPLogInfo(@"-----是产品用户时调用后台服务modifyFriendTypeWithCategory----邀请的类型：%@--------邀请的UserName：%@------",@"恋爱ing", userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_MARRIED) {
                                CPLogInfo(@"-----是产品用户时调用后台服务modifyFriendTypeWithCategory----邀请的类型：%@--------邀请的UserName：%@------",@"小夫妻", userName);
                            }
                            // 如果没有网络连接
                            if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
                                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                                return;
                            }
                            
                            if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
                                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                                return;
                            }
                            //通过短信邀请某人的时候，需要调用此方法
                            [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:addContactTypeWithSendMessage andUserName:userName andInviteString:@"" andCouldExpose:YES];
                            
                            //是产品用户
                            if (self.uiAddContactEnum == UIAddFriends || self.uiAddContactEnum == UIAddCloseFriends) {
                                contactDic.isSelected = YES;
                                contactDic.isSendedMessage = YES;
                            }else {
                                contactDic.isSelected = NO;
                                contactDic.isSendedMessage = NO;
                            }
                            
                            // 如果是产品用户并且发送邀请成功，返回上个界面
//                            if (self.uiAddContactEnum == UIAddLike || self.uiAddContactEnum == UIAddCouple) {
//                                [self do_hide_loading_view];
//                                self.isListenFindMobileIsUserDic = YES;
//                                [self doLeft];
//                            }
                            
                            if (addContactTypeWithSendMessage == FRIEND_CATEGORY_NORMAL) {
                                CPLogInfo(@"-----是产品用户----邀请的类型：%@--------需要发送短信的电话：%@------好友的userName：%@----------",@"好友",contactDic.selectedTelNumber , userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_CLOSER) {
                                CPLogInfo(@"-----是产品用户----邀请的类型：%@--------需要发送短信的电话：%@------好友的userName：%@----------",@"密友",contactDic.selectedTelNumber , userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_LOVER) {
                                CPLogInfo(@"-----是产品用户----邀请的类型：%@--------需要发送短信的电话：%@------好友的userName：%@----------",@"喜欢暗恋",contactDic.selectedTelNumber , userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_COUPLE) {
                                CPLogInfo(@"-----是产品用户----邀请的类型：%@--------需要发送短信的电话：%@------好友的userName：%@----------",@"恋爱ing",contactDic.selectedTelNumber , userName);
                            }else if (addContactTypeWithSendMessage == FRIEND_CATEGORY_MARRIED) {
                                CPLogInfo(@"-----是产品用户----邀请的类型：%@--------需要发送短信的电话：%@------好友的userName：%@----------",@"小夫妻",contactDic.selectedTelNumber , userName);
                            }
                        }
                    }
                }
                [self refreshNavigationButtonState];
                [self.myTableView reloadData];
                // 不是产品用户的话直接调用后台服务器接口
                for (NSString *str in needSendMessageTelNumber) {
                    CPLogInfo(@"-----------------需要发送短信的电话：%@-------------------",str);
                }
                [self sendMessageWithTelNumber:needSendMessageTelNumber];
            }else {
                // 短信验证失败 提示错误消息
                [[HPTopTipView shareInstance] showMessage: [[CPUIModelManagement sharedInstance].findMobileIsUserDic objectForKey:find_mobile_is_user_res_desc]];
            }
        }
    }
}



// 根据userName查找userinfor数据
-(UserInforModel *) getUserInforWithUserName:(NSString *)userName{
    UserInforModel *searchedUserInforModel;
    for (SectionModel *section in self.addContactModel.sectionArray) {
        if (section.dataModel == DataUserInforModel) {
            searchedUserInforModel = [section.dataSourceDictionary objectForKey:userName];
            if ( nil != searchedUserInforModel) {
                break;
            }
        }
    }
    return searchedUserInforModel;
}

// 当键盘将要显示的时候，重新设置tableview的大小
-(void) keyboardDidShow:(id)sender{
    self.myTableView.frame = CGRectMake(0, 89, 320, 155);
    self.isOpenKeyBoard =YES;
}

// tableView将要移动的时候取消键盘输入
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isOpenKeyBoard = NO;
    [self.searchBar resignFirstResponder];
    self.myTableView.frame = CGRectMake(0, 89, 320, 371);
}

// 点击索搜按钮的时候取消键盘输入
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.isOpenKeyBoard = NO;
    [searchBar resignFirstResponder];
    self.myTableView.frame = CGRectMake(0, 89, 320, 371);
}

// tableView选中行时取消键盘输入
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isOpenKeyBoard) {
        [self.searchBar resignFirstResponder];
        self.myTableView.frame = CGRectMake(0, 89, 320, 371);
    }
    return indexPath;
}


// 获取tableView的section数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger sectionCount = 0;
    for (SectionModel *sectionModel in self.addContactModel.sectionArray) {
        if ([sectionModel.searchArray count] != 0) {
            sectionCount += 1;
        }
    }
    
    if (sectionCount == 0) {
        self.NotFoundLabel.hidden = NO;
    }else {
        self.NotFoundLabel.hidden = YES;
    }
    return sectionCount;
}

// 获取tableView每个section下Cell的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger sectionCount = 0;
    NSInteger sectionCellCount = 0;
    
    for (SectionModel *sectionModel in self.addContactModel.sectionArray) {
        if ( [sectionModel.searchArray count] != 0 ) {
            if (sectionCount == section) {
                sectionCellCount = [sectionModel.searchArray count];
                break;
            }else {
                sectionCount += 1;
            }
        }
    }
    return sectionCellCount;
}

// 获取自定义Cell
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell;
    NSInteger sectionCount = 0;
    
    for (SectionModel *sectionModel in self.addContactModel.sectionArray) {
        if ( [sectionModel.searchArray count] != 0 ) {
            if (sectionCount == indexPath.section) {
                if (sectionModel.tableViewCellType == EventCell) {
                    cell = [self createEventCell:tableView cellForRowAtIndexPath:indexPath withSectionModel:sectionModel];
                }else if (sectionModel.tableViewCellType == MultiSelectCell) {
                    cell = [self createMultiCell:tableView cellForRowAtIndexPath:indexPath withSectionModel:sectionModel];
                }else if (sectionModel.tableViewCellType == SingleCell) {
                    cell = [self createSingleCell:tableView cellForRowAtIndexPath:indexPath withSectionModel:sectionModel];
                }
                break;
            }else {
                sectionCount += 1;
            }
        }
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor =  [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_list_hover.png"]];  
    return cell;
}

// 构造EventCell对象
-(UITableViewCell *) createEventCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  withSectionModel : (SectionModel *)sectionModel{
    NSString *EventCellIdentifier = [NSString stringWithFormat:@"EventTableViewCell_%d_%d",indexPath.section , indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
    
    if (cell == nil) {
        // cell init
        cell = [[EventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EventCellIdentifier];
    }
    EventTableViewCell *eventCell = (EventTableViewCell *)cell;
    UserInforModel *userInforData;
    id key = [sectionModel.searchArray objectAtIndex:indexPath.row];
    userInforData = (UserInforModel *)[sectionModel.dataSourceDictionary objectForKey:key];
    
    eventCell.saveSectionName = sectionModel.sectionName;
    eventCell.isContactData = NO;
    eventCell.userName = userInforData.userName;
    
    
    
    if ([sectionModel.sectionName isEqualToString: @"  好友"]) {
//        eventCell.headView = [[HPHeadView alloc] initWithFrame:CGRectMake(18.0f, 4.0f, 35.0f, 35.0f)];
        [eventCell.headView setBackImage:[UIImage imageWithContentsOfFile:userInforData.headerPath]];
//        [eventCell.headView setBorderWidth:5.f];
//        [eventCell.headView setCycleImage:[UIImage imageNamed:@"headpic_index_50x50.png"]];
//        [eventCell addSubview:eventCell.headView];
        
        eventCell.userImageButton.hidden = YES;
        // 添加昵称
//        eventCell.nameLabel.text = userInforData.nickName;
        eventCell.contactID = userInforData.userInfoID;
//        CGSize size = [eventCell.nameLabel.text sizeWithFont:eventCell.nameFont];
//        [eventCell.nameLabel setFrame:CGRectMake(eventCell.nameLabel.frame.origin.x, 
//                                                 eventCell.nameLabel.frame.origin.y, 
//                                                 size.width > 132.0f ? 132.0f : size.width, 
//                                                 eventCell.nameLabel.frame.size.height)];
        [eventCell.nameLabel removeFromSuperview];
        eventCell.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 6.0f, 128.0f, 16.0f)];
        eventCell.nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        eventCell.nameLabel.backgroundColor = [UIColor clearColor];
        eventCell.nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        eventCell.nameLabel.numberOfLines = 0;
        eventCell.nameLabel.text = userInforData.nickName;
        [eventCell addSubview:eventCell.nameLabel];
        
        [eventCell.nickName removeFromSuperview];
        eventCell.nickName = [[UILabel alloc] initWithFrame:CGRectMake(62.0f, 26.0f, 128.0f, 12.0f)];
        eventCell.nickName.font = [UIFont systemFontOfSize:12.0f];
        eventCell.nickName.backgroundColor = [UIColor clearColor];
        eventCell.nickName.textColor = [UIColor colorWithHexString:@"#333333"];
        eventCell.nickName.text = userInforData.fullName;
        
        [eventCell addSubview:eventCell.nickName];
    }else{
        eventCell.headView.hidden = YES;
        eventCell.contactID = userInforData.userInfoID;
        eventCell.nameLabel.text = userInforData.fullName;
        CGSize size = [eventCell.nameLabel.text sizeWithFont:eventCell.nameFont];
        size.width = size.width > 70.0f ? 70.0f : size.width;
        
        [eventCell.nameLabel setFrame:CGRectMake(eventCell.nameLabel.frame.origin.x, 
                                                 eventCell.nameLabel.frame.origin.y, 
                                                 size.width,
                                                 eventCell.nameLabel.frame.size.height)];
        
        // 添加昵称
        if ( userInforData.nickName != nil || ![userInforData.nickName isEqualToString:@""] ) {
            NSString *nickName = [NSString stringWithFormat:@"(%@)",userInforData.nickName];
            CGSize nickSize = [nickName sizeWithFont:eventCell.nickNameFont];
            [eventCell.nickName setFrame:CGRectMake(eventCell.nameLabel.frame.origin.x + eventCell.nameLabel.frame.size.width, 
                                                    eventCell.nameLabel.frame.origin.y,
                                                    nickSize.width > 62.0f ? 62.0f : nickSize.width,
                                                    eventCell.nickName.frame.size.height)];
            eventCell.nickName.text = nickName;
        }
        
//        [eventCell.nameLabel removeFromSuperview];
//        eventCell.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 6.0f, 190.0f, 16.0f)];
//        eventCell.nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
//        eventCell.nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
//        eventCell.nameLabel.numberOfLines = 0;
//        eventCell.nameLabel.text = userInforData.nickName;
//        [eventCell addSubview:eventCell.nameLabel];
//        
//        [eventCell.nickName removeFromSuperview];
//        eventCell.nickName = [[UILabel alloc] initWithFrame:CGRectMake(62.0f, 26.0f, 190.0f, 12.0f)];
//        eventCell.nickName.font = [UIFont systemFontOfSize:12.0f];
//        eventCell.nickName.textColor = [UIColor colorWithHexString:@"#333333"];
//        eventCell.nickName.text = userInforData.fullName;
//        [eventCell addSubview:eventCell.nickName];
    }
    if (userInforData.userInforState == UserStateSucceed) {
        [eventCell changeCellForSucceed];
        if (userInforData.descriptionState == 1) {
            [eventCell startTimer];
            [userInforData startTimer];
            userInforData.descriptionState = 2;
        }
    }else if (userInforData.userInforState == UserStateLoading) {
        [eventCell changeCellForLoading];
    }else if (userInforData.userInforState == UserStateFail) {
        [eventCell changeCellForFail];
    }else if (userInforData.userInforState == UserStateSucceedNoText) {
        [eventCell changeCellForSucceedNoText];
    }else if (userInforData.userInforState == UserStateSucceedForCloseFriend) {
        [eventCell changeCellForSucceedForCloseFriend];
    }
    
    if (self.uiAddContactEnum == UIAddFriends) {
        // 添加加为朋友的按钮事件
        [eventCell.addButton addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.addContactModel.friendDictionary count] >=1 ) {
            eventCell.addButton.enabled = NO;
        }
    }else if (self.uiAddContactEnum == UIAddCloseFriends) {
        [eventCell.addButton addTarget:self action:@selector(addCloseFriends:) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([sectionModel.sectionName isEqualToString: @"  双双用户"]) {
        eventCell.isShuangShuangRecommon = YES;
        [eventCell.userImageButton addTarget:self action:@selector(openUserProfileController:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

// 构造MultiCell对象
-(UITableViewCell *) createMultiCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  withSectionModel : (SectionModel *)sectionModel{

    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[MultiSelectTableViewCell alloc] init];
        MultiSelectTableViewCell *multiSelect = (MultiSelectTableViewCell *)cell;
        id key = [sectionModel.searchArray objectAtIndex:indexPath.row];
        ContactModel *contactData = (ContactModel *)[sectionModel.dataSourceDictionary objectForKey:key];
        multiSelect.saveSectionName = sectionModel.sectionName;
        multiSelect.isContactData = YES;
        multiSelect.nameLabel.text = contactData.fullName;
        multiSelect.contactID = contactData.contactID;
        multiSelect.isSelectedButton = contactData.isSelected;
        [multiSelect.selectButton addTarget:self action:@selector(MultiSelectClick:) forControlEvents:UIControlEventTouchDown];
        [multiSelect.userImageButton addTarget:self action:@selector(MultiSelectUserImageButton:) forControlEvents:UIControlEventTouchUpInside];
        if (contactData.isSendedMessage) {
            [multiSelect changeSucceed];
        }
    }
    return cell;
}

// 构造SingleCell对象
-(UITableViewCell *) createSingleCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  withSectionModel : (SectionModel *)sectionModel{

    UITableViewCell *cell = nil;
    
    if (cell == nil) {
        // cell init
        cell = [[SingleTableViewCell alloc] init];
        SingleTableViewCell *singleCell = (SingleTableViewCell *)cell;
        UserInforModel *userInforData;
        ContactModel *contactData;
        if (sectionModel.dataModel == DataUserInforModel) {
            
            id key = [sectionModel.searchArray objectAtIndex:indexPath.row];
            userInforData = (UserInforModel *)[sectionModel.dataSourceDictionary objectForKey:key];
            
            // 添加昵称
            singleCell.nameLabel.text = [[CPUIModelManagement sharedInstance] getContactFullNameWithMobile:userInforData.telPhoneNumber];
            singleCell.saveSectionName = sectionModel.sectionName;
            singleCell.isContactData = NO;
            singleCell.userName = userInforData.userName;
            
            CGSize size = [singleCell.nameLabel.text sizeWithFont:singleCell.nameFont];
            [singleCell.nameLabel setFrame:CGRectMake(singleCell.nameLabel.frame.origin.x, 
                                                     singleCell.nameLabel.frame.origin.y, 
                                                     size.width, 
                                                     singleCell.nameLabel.frame.size.height)];
            
            singleCell.headView = [[HPHeadView alloc] initWithFrame:CGRectMake(18.0f, 4.0f, 35.0f, 35.0f)];
            [singleCell.headView setBackImage:[UIImage imageWithContentsOfFile:userInforData.headerPath]];
            [singleCell.headView setBorderWidth:5.f];
            [singleCell.headView setCycleImage:[UIImage imageNamed:@"headpic_index_50x50.png"]];
            [singleCell addSubview:singleCell.headView];
            
            singleCell.userImageButton.hidden = YES;
            
            [singleCell.nameLabel removeFromSuperview];
            singleCell.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 6.0f, 190.0f, 16.0f)];
            singleCell.nameLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            singleCell.nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
            singleCell.nameLabel.numberOfLines = 0;
            singleCell.nameLabel.text = userInforData.nickName;
            [singleCell addSubview:singleCell.nameLabel];
            
            [singleCell.nickName removeFromSuperview];
            singleCell.nickName = [[UILabel alloc] initWithFrame:CGRectMake(62.0f, 26.0f, 190.0f, 12.0f)];
            singleCell.nickName.font = [UIFont systemFontOfSize:12.0f];
            singleCell.nickName.textColor = [UIColor colorWithHexString:@"#333333"];
            singleCell.nickName.text = userInforData.fullName;
            [singleCell addSubview:singleCell.nickName];
            
            //添加好友profile事件 －－ 界面未设计完成，留作备用
//            [singleCell.userImageButton addTarget:self action:@selector(openUserProfileController:) forControlEvents:UIControlEventTouchUpInside];
        }else if (sectionModel.dataModel == DataContactModel) {
            // 我的联系人的个数 （姓名）
            id key = [sectionModel.searchArray objectAtIndex:indexPath.row];
            contactData = (ContactModel *)[sectionModel.dataSourceDictionary objectForKey:key];
            
            singleCell.nameLabel.text = contactData.fullName;
            singleCell.saveSectionName = sectionModel.sectionName;
            singleCell.isContactData = YES;
            singleCell.contactID = contactData.contactID;
            CGSize size = [singleCell.nameLabel.text sizeWithFont:singleCell.nameFont];
            [singleCell.nameLabel setFrame:CGRectMake(singleCell.nameLabel.frame.origin.x, 
                                                      singleCell.nameLabel.frame.origin.y, 
                                                      size.width, 
                                                      singleCell.nameLabel.frame.size.height)];
            
            
            if (contactData.isSendedMessage) {
                [singleCell changeSucceed];
            }
        }
    }
    return cell;
}

// 在添加好友界面点击添加按钮
-(void) addFriends:(id)sender{
    
    if (self.addContactModel.userFriendCount >= FriendMaxCount) {
        [[HPTopTipView shareInstance] showMessage :@"人缘真好，好友已满148人啦"];
        return;
    }
    
    // 如果没有网络连接
    if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    
    if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    
    EventTableViewCell *cell = (EventTableViewCell *)[sender superview];
    UserInforModel *userInfor = nil;
    // 查找相同的section name名字下的数据源数据
    for (SectionModel *section in self.addContactModel.sectionArray) {
        if ([section.sectionName isEqualToString:cell.saveSectionName]) {
            userInfor = [section.dataSourceDictionary objectForKey:cell.userName];
            break;
        }
    }
    // 如果是双双推荐，增加统计
    if (cell.isShuangShuangRecommon) {
    }
    
    userInfor.userInforState = UserStateLoading;
    [cell changeCellForLoading];
    [cell.activityIndicator startAnimating];
    CPLogInfo(@"--------点击添加为好友--------好友姓名：%@------好友昵称 ：%@--------",userInfor.fullName,userInfor.nickName);
    CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_NORMAL-----userName：%@-----",userInfor.userName);
    //添加为好友
    [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_NORMAL 
                                          andUserName:userInfor.userName
                                          andInviteString:@"" andCouldExpose:YES];
}

// 在添加密友界面点击添加按钮
-(void) addCloseFriends:(id)sender{
    
    if (self.addContactModel.userFriendCount >= FriendMaxCount) {
        [[HPTopTipView shareInstance] showMessage :@"人缘真好，好友已满148人啦"];
        return;
    }
    
    if (self.addContactModel.userCloseFriendCount >= CloseFriendMaxCount) {
        [[HPTopTipView shareInstance] showMessage :@"两三知己足矣，蜜友已满17人啦"];
        return;
    }
    
    // 如果没有网络连接
    if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    
    if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    EventTableViewCell *cell = (EventTableViewCell *)[sender superview];
    UserInforModel *userInfor = nil;
    // 查找相同的section name名字下的数据源数据
    for (SectionModel *section in self.addContactModel.sectionArray) {
        if ([section.sectionName isEqualToString:cell.saveSectionName]) {
            userInfor = [section.dataSourceDictionary objectForKey:cell.userName];
            break;
        }
    }
    
    if ([cell.saveSectionName isEqualToString:@"  双双用户"]) {
        [self addCloseFriends:cell withData:userInfor];
        /* 项目需求变更，取消第一次显示message
//        if (isFirstAddCloseFriendContact) {
//            //#warning 控件未存在，需要后续工作
//            // 显示第一次添加的message
//            self.addCloseFriendCell = cell;
//            self.addCloseFriendData = userInfor;
//            self.messageBox = [[FXBlockViewSubmit alloc] init];
////            #warning 文本信息为确定
//            self.messageBox.delegate = self;
////            [self.messageBox doSetText:[NSString stringWithFormat:@"%@还不是你的好友,需要发送加好友的请求待他确认,同意后,自动成为 闺蜜/死党,对方不会知晓",userInfor.fullName]];
//            //Ta还不是你的好友，收到好友邀请并同意后会悄悄成为你的蜜友
//            [self.messageBox doSetText:@"Ta还不是你的好友，收到好友邀请并同意后会悄悄成为你的蜜友"];
//            [self.messageBox doShowBlockViewInViewController:self];
//            isFirstAddCloseFriendContact = NO;
//            self.firstMessage = sendAddCloseFriend;
//            CPLogInfo(@"显示第一次添加message");
//        }
//        else {
//            [self addCloseFriends:cell withData:userInfor];
//        }
         */
    }else {
        [self addCloseFriends:cell withData:userInfor];
    }
}

- (void)actionBlockViewCloseButtonTouchedSender:(UIButton *)closeButton{
//    if (self.firstMessage == sendAddCloseFriend) {
//        [self addCloseFriends:self.addCloseFriendCell withData:self.addCloseFriendData];
//    }else if (self.firstMessage == sendMessageLike) {
//        [self chooseTelNumberWithSingleCell : self.singleCell];
//    }else if (self.firstMessage == sendMessageCloseFriend) {
//        [self sendMessageWithAddCloseFriend];
//    }
//    if (self.uiAddContactEnum == UIAddCloseFriends) {
//        if (self.firstMessage == sendAddCloseFriend) {
//            [self addCloseFriends:self.addCloseFriendCell withData:self.addCloseFriendData];
//        }else if (self.firstMessage == sendMessageCloseFriend) {
//            [self sendMessageWithFirstAddLover : @""];
//        }
//    }else if (self.uiAddContactEnum == UIAddLike) {
//        if (self.firstMessage == sendMessageLike) {
//            [self sendMessageWithFirstAddLover : @""];
//        }
//    }
}
- (void)actionBlockViewCenterButtonTouchedSender:(UIButton *)centerButton{
    if (self.firstMessage == sendAddCloseFriend) {
        [self addCloseFriends:self.addCloseFriendCell withData:self.addCloseFriendData];
    }else if (self.firstMessage == sendMessageLike) {
        [self chooseTelNumberWithSingleCell : self.singleCell];
    }else if (self.firstMessage == sendMessageCloseFriend) {
        [self sendMessageWithAddCloseFriend];
    }
//    
//    if (self.uiAddContactEnum == UIAddCloseFriends) {
//        if (self.firstMessage == sendAddCloseFriend) {
//            [self addCloseFriends:self.addCloseFriendCell withData:self.addCloseFriendData];
//        }else if (self.firstMessage == sendMessageCloseFriend) {
//            [self sendMessageWithFirstAddLover : @""];
//        }
//    }else if (self.uiAddContactEnum == UIAddLike) {
//        if (self.firstMessage == sendMessageLike) {
//            [self sendMessageWithFirstAddLover : @""];
//        }
//    }
}

-(void) addCloseFriends : (AddContactCellBase *)cell withData :(UserInforModel *)data{
    EventTableViewCell *EventCell = (EventTableViewCell *)cell;
    // 变更数据源状态
    data.userInforState = UserStateLoading;
    // 变更cell状态
    [EventCell changeCellForLoading];
    [EventCell.activityIndicator startAnimating];
    CPLogInfo(@"--------点击添加为密友--------好友姓名：%@------好友昵称 ：%@--------",data.fullName,data.nickName);
    CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_CLOSER-----userName：%@-----",data.userName);
    
    // 如果没有网络连接
    if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    
    if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
        [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        return;
    }
    // 如果是双双推荐，增加统计
    if (EventCell.isShuangShuangRecommon) {
    }
    // 调用服务端处理数据
    [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_CLOSER andUserName:data.userName andInviteString:@"" andCouldExpose:YES];
}

-(void) openUserProfileController:(id)sender{
    EventTableViewCell *cell = (EventTableViewCell *)[sender superview];
    UserInforModel *userInfor = nil;
    // 查找相同的section name名字下的数据源数据
    for (SectionModel *section in self.addContactModel.sectionArray) {
        if ([section.sectionName isEqualToString:cell.saveSectionName]) {
            userInfor = [section.dataSourceDictionary objectForKey:cell.userName];
            break;
        }
    }
    // 统计信息
    AddContactWithProfileViewController *addContactWithProfile = [[AddContactWithProfileViewController alloc] initAddContactWithUserInfor:userInfor];
    [self.navigationController pushViewController:addContactWithProfile animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (self.uiAddContactEnum == UIAddFriends) { 
        // 双双推荐的个数 - 姓名搜索
        [self.addContactModel refreshUserInforDataToSearchedDataSource:searchText withCopyDataSourceType:CoupleRecommend withSearchFieldType:SearchFullName];
        // 我的联系人的个数 － 姓名搜索
        [self.addContactModel refreshContactDataToSearchedDataSource:searchText];
    }else if(self.uiAddContactEnum == UIAddCloseFriends) {
        // 朋友的个数 － 仅仅是好友 - 昵称搜索
        [self.addContactModel refreshUserInforDataToSearchedDataSource:searchText withCopyDataSourceType:Friends withSearchFieldType:SearchNickName];
        // 双双推荐的个数 － 姓名搜索
        [self.addContactModel refreshUserInforDataToSearchedDataSource:searchText withCopyDataSourceType:CoupleRecommend withSearchFieldType:SearchFullName];
        // 我的联系人的个数 － 姓名搜索
        [self.addContactModel refreshContactDataToSearchedDataSource:searchText];
    }else if(self.uiAddContactEnum == UIAddLike){
        // 朋友的个数 － 好友 ＋ 密友 - 昵称搜索
        [self.addContactModel refreshUserInforDataToSearchedDataSource:searchText withCopyDataSourceType:FriendsAndCloseFriends withSearchFieldType:SearchNickName];
        // 我的联系人的个数 － 姓名搜索
        [self.addContactModel refreshContactDataToSearchedDataSource:searchText];
    }else if(self.uiAddContactEnum == UIAddCouple){
        // 朋友的个数 － 好友 ＋ 密友 - 昵称搜索
        [self.addContactModel refreshUserInforDataToSearchedDataSource:searchText withCopyDataSourceType:FriendsAndCloseFriends withSearchFieldType:SearchNickName];
        // 我的联系人的个数 - 姓名搜索
        [self.addContactModel refreshContactDataToSearchedDataSource:searchText];
    }
    
    [self.myTableView reloadData];
}

// 点击多选按钮头像触发事件
-(void) MultiSelectUserImageButton:(id)sender{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *path = [self.myTableView indexPathForCell:cell];
    [self.myTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    MultiSelectTableViewCell* buttonCell = (MultiSelectTableViewCell*)cell;
    [self changeMultiCellState:buttonCell];
    [self.myTableView deselectRowAtIndexPath:path animated:YES];
}

// 点击多选按钮时，改变按钮状态
-(void) MultiSelectClick : (id) sender{
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *path = [self.myTableView indexPathForCell:cell];
    [self.myTableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
    MultiSelectTableViewCell* buttonCell = (MultiSelectTableViewCell*)cell;
    [self changeMultiCellState:buttonCell];
    [self.myTableView deselectRowAtIndexPath:path animated:YES];
}

// 取得用户选择的Cell，如果是多选类型的Cell，操作该Cell状态
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 获得选择的单元格对象
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isMemberOfClass:[MultiSelectTableViewCell class]]) {
        MultiSelectTableViewCell* buttonCell = (MultiSelectTableViewCell*)cell;
        [self changeMultiCellState:buttonCell];
    }else if ([cell isMemberOfClass:[SingleTableViewCell class]]) {
        SingleTableViewCell *singleCell = (SingleTableViewCell *)cell;
        if (self.uiAddContactEnum == UIAddLike) {
            /****************添加喜欢、暗恋页面点击cell*********************/
            if (singleCell.isContactData) {
                if (!singleCell.isSendedMessage) {
                    if (isFirstAddCloseFriendContact) {
                        [self sendMessageWithFirstAddLover:singleCell];
                    }else {
                        [self chooseTelNumberWithSingleCell:singleCell];
                    }
                }
            }else {
                // 点击的为好友或密友
                UserInforModel *userinfor = [self.addContactModel.friendAndCloseFriendDictionary objectForKey:singleCell.userName];
                if (nil == userinfor) {
                    CPLogInfo(@"userinfor数据未取出");
                    return;
                }
                
                /********************服务器端验证************************/
//                if (self.addContactModel.userFriendCount >= FriendMaxCount) {
//                    [self do_show_toptip_view_toptip_string :@"好友数已经达到上限,添加失败"];
//                    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
//                    return;
//                }
                
                // 如果没有网络连接
                if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
                    [[HPTopTipView shareInstance] showMessage :@"网络不是很给力哦，稍等后再试试"];
                    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
                    return;
                }
                
                if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
                    [[HPTopTipView shareInstance] showMessage :@"网络不是很给力哦，稍等后再试试"];
                    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
                    return;
                }
                
                CPLogInfo(@"--------点击添加为喜欢、暗恋--------好友姓名：%@------好友昵称 ：%@--------",userinfor.fullName,userinfor.nickName);
                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_LOVER-----userName：%@-----",userinfor.userName);
                [self do_show_loading_view_content_string:@"正在加为喜欢对象"];
                // 调用服务端处理数据
                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_LOVER andUserName:userinfor.userName andInviteString:@"" andCouldExpose:YES];
            }
        }
        if (self.uiAddContactEnum == UIAddCouple) {
            /****************添加couple页面点击cell*********************/
            if (singleCell.isContactData) {
                if (!singleCell.isSendedMessage) {
                    isSendMessageWithAddCouple = YES;
                    [self chooseTelNumberWithSingleCell:singleCell];
                }
            }else if (!singleCell.isContactData) {
                isSendMessageWithAddCouple = NO;
                for (SectionModel *section in self.addContactModel.sectionArray) {
                    if ([section.sectionName isEqualToString:singleCell.saveSectionName]) {
                        UserInforModel *dataModel = (UserInforModel *)[section.dataSourceDictionary objectForKey:singleCell.userName];
                        
                        CPLogInfo(@"------开始点击添加为另一半--------好友姓名：%@-----好友昵称：%@----",dataModel.fullName,dataModel.nickName);
                        CPLogInfo(@"------开始点击添加为另一半--------好友userName：%@----",dataModel.userName);
                        
                        [ChooseCoupleModel sharedInstance].chooseedUserinfor = dataModel;
                        ChooseCoupleTypeViewController *chooseCoupleType = [[ChooseCoupleTypeViewController alloc] initChooseCoupleTypeView:ContactChoose];
                        [self.navigationController pushViewController:chooseCoupleType animated:YES];
                    }
                }
            }
        }
        if (self.uiAddContactEnum == UIAddCoupleOnlyMoblieNumber) {
            self.singleCell = singleCell;
            // 获取couple手机号码
            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:singleCell.contactID];
            NSUInteger contactTelCount = [contract.contactWayList count];
            
            // 如果添加联系人的电话号码大于1个
            if (contactTelCount > 1) {
                UIActionSheet *telSheet = [[UIActionSheet alloc] initWithTitle:@"请选择一个电话号码" 
                                                                 delegate:self 
                                                                 cancelButtonTitle:nil 
                                                                 destructiveButtonTitle:nil 
                                                                 otherButtonTitles:nil, 
                                                                 nil];
                
                for (CPUIModelContactWay *way in contract.contactWayList) {
                    [telSheet addButtonWithTitle:way.value];
                }
                [telSheet addButtonWithTitle:@"取消"];
                telSheet.destructiveButtonIndex = telSheet.numberOfButtons - 1;
                [telSheet showFromRect:self.view.bounds inView:self.view animated:YES];
            }else {
                //warning 需要结合注册界面未完成
                // 添加的联系人电话号码仅有一个
                if ([contract.contactWayList count] == 1) {
                    // 获取用户选择的电话号码,并通知其他页面
                    CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:0];
                    NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
                    [TelNumber addObject:way.value];
                }
            }
        }
    }
    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) sendMessageWithFirstAddLover : (SingleTableViewCell *)cell{
    self.singleCell = cell;
    ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:cell.contactID];
    self.messageBox = [[FXBlockViewSubmit alloc] init];

    self.messageBox.delegate = self;
    [self.messageBox doSetText:[NSString stringWithFormat:@"%@还不是你的好友,需要发送加好友的请求待Ta确认,同意后,自动成为 喜欢对象,对方不会知晓",contract.fullName]];
    [self.messageBox doShowBlockViewInViewController:self.view];
    isFirstAddCloseFriendContact = NO;
    self.firstMessage = sendMessageLike;
}

-(void) chooseTelNumberWithSingleCell : (SingleTableViewCell *)cell{
    
    self.singleCell = cell;
    ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:cell.contactID];
    
    NSUInteger contactTelCount = [contract.contactWayList count];
    // 如果添加联系人的电话号码大于1个
    if (contactTelCount > 1) {
        UIActionSheet *telSheet = [[UIActionSheet alloc] initWithTitle:@"请选择一个电话号码" 
                                                         delegate:self 
                                                         cancelButtonTitle:nil 
                                                         destructiveButtonTitle:nil 
                                                         otherButtonTitles:nil, 
                                                         nil];
        
        for (CPUIModelContactWay *way in contract.contactWayList) {
            [telSheet addButtonWithTitle:way.value];
        }
        [telSheet addButtonWithTitle:@"取消"];
        telSheet.destructiveButtonIndex = telSheet.numberOfButtons - 1;
        [telSheet showFromRect:self.view.bounds inView:self.view animated:YES];
    }else {
        // 添加的联系人电话号码仅有一个
        if ([contract.contactWayList count] == 1) {
            CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:0];
            contract.selectedTelNumber = way.value;
            NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
            [TelNumber addObject:contract.selectedTelNumber];
            
            if (self.uiAddContactEnum == UIAddLike) {
                contract.isSelected = YES;
                addContactTypeWithSendMessage = FRIEND_CATEGORY_LOVER;
                CPLogInfo(@"--------点击添加为喜欢、暗恋--------好友姓名：%@------好友电话 ：%@--------",contract.fullName,contract.selectedTelNumber);
                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_LOVER----------");
//                #warning 短信loading文本信息未确定 - 添加喜欢
                [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
            }else if (self.uiAddContactEnum == UIAddCouple) {
                ChooseCoupleTypeViewController *chooseCoupleType = [[ChooseCoupleTypeViewController alloc] initChooseCoupleTypeView:ContactChoose];
                [self.navigationController pushViewController:chooseCoupleType animated:YES];
            }
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // 如果是第一次呈现此界面，返回
   
    if (self.isFirstShow) {
        if (self.uiAddContactEnum == UIAddFriends) {
            CPLogInfo(@"-------------%d----------------",self.addContactModel.userFriendCount);
            NSUInteger minOffset = FriendMaxCount - self.addContactModel.userFriendCount;
            if (minOffset <= 3) {
                [[HPTopTipView shareInstance] showMessage :[NSString stringWithFormat:@"还能添加%d好友",minOffset]];
            }
        }else if (self.uiAddContactEnum == UIAddCloseFriends) {
            CPLogInfo(@"-------------%d----------------",self.addContactModel.userCloseFriendCount);
            NSUInteger minOffset = CloseFriendMaxCount - self.addContactModel.userCloseFriendCount;
            if (minOffset <= 3) {
                [[HPTopTipView shareInstance] showMessage :[NSString stringWithFormat:@"还能添加%d密友",minOffset]];
            }
        }
        self.isFirstShow = NO;
        return;
    }
//    if ([viewController isMemberOfClass:[ChooseCoupleTypeViewController class]]) {
//        return;
//    }else {
//        if (isSendMessageWithAddCouple) {
//            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:self.singleCell.contactID];
//            if ([ChooseCoupleModel sharedInstance].chooseedType == IsLover) {
//                contract.isSelected = YES;
//                isChooseCoupleType = YES;
//                addContactTypeWithSendMessage = FRIEND_CATEGORY_COUPLE;
//                NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
//                [TelNumber addObject:contract.selectedTelNumber];
//                CPLogInfo(@"--------点击添加为另一半--------联系人姓名：%@------好友电话 ：%@--------",contract.fullName,contract.selectedTelNumber);
//                CPLogInfo(@"--------开始调用后台服务--------恋爱ing------类型：FRIEND_CATEGORY_COUPLE----------");
//                #warning 短信loading文本信息未确定 - 添加恋爱ing
//                [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
//            }else if ([ChooseCoupleModel sharedInstance].chooseedType == IsMarried) {
//                isChooseCoupleType = YES;
//                contract.isSelected = YES;
//                addContactTypeWithSendMessage = FRIEND_CATEGORY_MARRIED;
//                NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
//                [TelNumber addObject:contract.selectedTelNumber];
//                CPLogInfo(@"--------点击添加为另一半--------联系人姓名：%@------好友电话 ：%@--------",contract.fullName,contract.selectedTelNumber);
//                CPLogInfo(@"--------开始调用后台服务--------小夫妻------类型：FRIEND_CATEGORY_MARRIED----------");
//                #warning 短信loading文本信息未确定 - 添加小夫妻
//                [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
//            }else {
//                contract.isSelected = NO;
//                contract.isSendedMessage = NO;
//                contract.selectedTelNumber = @"";
//                isChooseCoupleType = NO;
//            }
//        }else {
//            // 调用后台添加couple
//            if ([ChooseCoupleModel sharedInstance].chooseedType == IsLover) {
//                CPLogInfo(@"--------点击添加为另一半----恋爱ing----好友姓名：%@------好友昵称 ：%@--------",
//                      [ChooseCoupleModel sharedInstance].chooseedUserinfor.fullName,
//                      [ChooseCoupleModel sharedInstance].chooseedUserinfor.nickName);
//                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_COUPLE-----userName：%@-----",
//                      [ChooseCoupleModel sharedInstance].chooseedUserinfor.userName);
//                [self do_show_loading_view_content_string:@"发送另一半请求"];
//                
//                // 如果没有网络连接
//                if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
//                    [self do_show_toptip_view_toptip_string :@"当前未连接网络，请联网后重试"];
//                    return;
//                }
//                
//                if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
//                    [self do_show_toptip_view_toptip_string :@"当前未连接网络，请联网后重试"];
//                    return;
//                }
//                //添加Couple  关系为恋爱ing
//                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_COUPLE 
//                                                      andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
//                                                      andInviteString:@"" andCouldExpose:YES];
//            }else if ([ChooseCoupleModel sharedInstance].chooseedType == IsMarried) {
//                CPLogInfo(@"--------点击添加为另一半----小夫妻----好友姓名：%@------好友昵称 ：%@--------",
//                      [ChooseCoupleModel sharedInstance].chooseedUserinfor.fullName,
//                      [ChooseCoupleModel sharedInstance].chooseedUserinfor.nickName);
//                CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_MARRIED-----userName：%@-----",
//                      [ChooseCoupleModel sharedInstance].chooseedUserinfor.userName);
//                
//                // 如果没有网络连接
//                if (![[CPUIModelManagement sharedInstance] canConnectToNetwork]) {
//                    [self do_show_toptip_view_toptip_string :@"当前未连接网络，请联网后重试"];
//                    return;
//                }
//                
//                if ([CPUIModelManagement sharedInstance].sysOnlineStatus != SYS_STATUS_ONLINE) {
//                    [self do_show_toptip_view_toptip_string :@"当前未连接网络，请联网后重试"];
//                    return;
//                }
//                [self do_show_loading_view_content_string:@"发送另一半请求"];
//                //添加Couple 关系为夫妻
//                [[CPUIModelManagement sharedInstance] modifyFriendTypeWithCategory:FRIEND_CATEGORY_MARRIED 
//                                                      andUserName:[ChooseCoupleModel sharedInstance].chooseedUserinfor.userName
//                                                      andInviteString:@"" andCouldExpose:YES];
//            }
//        }
//    }
}



-(void) changeMultiCellState:(MultiSelectTableViewCell *)cell{
    // 如果选择的联系人已经达到10人要求，并且不是取消操作，返回
    NSUInteger result = [self.addContactModel getInvitedContactCount];
    if (result >= 10) {
        if (!cell.isSelectedButton) {
            // 弹出浮层，一次最多邀请10个好友
//            [self do_show_toptip_view_toptip_string :@"一次最多邀请10个好友"];
            [[HPTopTipView shareInstance] showMessage:@"一次最多邀请10个好友"];
            return;
        }
    }
    
    if (cell.isSendedMessage) {
        return;
    }
    
    self.selectedCell = cell;
    ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:cell.contactID];
//    // 如果是添加操作
//    if (!cell.isSelectedButton) {
//        
//        NSUInteger contactTelCount = [contract.contactWayList count];
//        CPLogInfo(@"%d" , [contract.contactWayList count]);
//        for (CPUIModelContactWay *w in contract.contactWayList) {
//            CPLogInfo(@"%@",w.value);
//        }
//        
//        
//        // 如果添加联系人的电话号码大于1个
//        if (contactTelCount > 1) {
//            UIActionSheet *telSheet = [[UIActionSheet alloc] initWithTitle:@"请选择一个电话号码" 
//                                                            delegate:self 
//                                                            cancelButtonTitle:nil 
//                                                            destructiveButtonTitle:nil 
//                                                            otherButtonTitles:nil, 
//                                                            nil];
//            for (CPUIModelContactWay *way in contract.contactWayList) {
//                [telSheet addButtonWithTitle:way.value];
//            }
//            self.selectedCell = cell;
//            [telSheet addButtonWithTitle:@"取消"];
//            telSheet.destructiveButtonIndex = telSheet.numberOfButtons - 1;
//            [telSheet showFromRect:self.view.bounds inView:self.view animated:YES];
//        }else {
//            // 添加的联系人电话号码仅有一个
//            if ([contract.contactWayList count] == 1) {
//                CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:0];
//                contract.selectedTelNumber = way.value;
//            }
//            cell.isSelectedButton = !cell.isSelectedButton;
//            contract.isSelected = cell.isSelectedButton;
//        }
//    }else {
//        // 如果是取消这个联系人
//        contract.selectedTelNumber = @"";
//        cell.isSelectedButton = !cell.isSelectedButton;
//        contract.isSelected = cell.isSelectedButton;
//    }
    
    if (isFirstAddCloseFriendContact) {
        if (self.uiAddContactEnum == UIAddCloseFriends) {
            [self sendMessageWithAddCloseFriend];
//            self.messageBox = [[FXBlockViewSubmit alloc] init];
////            #warning 文本信息为确定
//            self.messageBox.delegate = self;
////            [self.messageBox doSetText:[NSString stringWithFormat:@"%@还不是你的好友,需要发送加好友的请求待他确认,同意后,自动成为 闺蜜/死党,对方不会知晓",contract.fullName]];
//            [self.messageBox doSetText:@"Ta还不是你的好友，收到好友邀请并同意后会悄悄成为你的蜜友"];
//            [self.messageBox doShowBlockViewInViewController:self];
//            self.firstMessage = sendMessageCloseFriend;
//            isFirstAddCloseFriendContact = NO;
        }else if (self.uiAddContactEnum == UIAddLike) {
            self.messageBox = [[FXBlockViewSubmit alloc] init];
            //warning 文本信息为确定
            self.messageBox.delegate = self;
            [self.messageBox doSetText:[NSString stringWithFormat:@"%@还不是你的好友,需要发送加好友的请求待Ta确认,同意后,自动成为 喜欢对象,对方不会知晓",contract.fullName]];
            [self.messageBox doShowBlockViewInViewController:self.view];
            isFirstAddCloseFriendContact = NO;
        }else {
            [self sendMessageWithAddCloseFriend];
        }
    }else {
        [self sendMessageWithAddCloseFriend];
    }
}

-(void) sendMessageWithAddCloseFriend{
    
    MultiSelectTableViewCell *cell = self.selectedCell;
    
    ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:cell.contactID];
    // 如果是添加操作
    if (!cell.isSelectedButton) {
        
        NSUInteger contactTelCount = [contract.contactWayList count];
        CPLogInfo(@"%d" , [contract.contactWayList count]);
        for (CPUIModelContactWay *w in contract.contactWayList) {
            CPLogInfo(@"%@",w.value);
        }
        
        
        // 如果添加联系人的电话号码大于1个
        if (contactTelCount > 1) {
            UIActionSheet *telSheet = [[UIActionSheet alloc] initWithTitle:@"请选择一个电话号码" 
                                                                  delegate:self 
                                                         cancelButtonTitle:nil 
                                                    destructiveButtonTitle:nil 
                                                         otherButtonTitles:nil, 
                                       nil];
            for (CPUIModelContactWay *way in contract.contactWayList) {
                [telSheet addButtonWithTitle:way.value];
            }
            self.selectedCell = cell;
            [telSheet addButtonWithTitle:@"取消"];
            telSheet.destructiveButtonIndex = telSheet.numberOfButtons - 1;
            [telSheet showFromRect:self.view.bounds inView:self.view animated:YES];
        }else {
            // 添加的联系人电话号码仅有一个
            if ([contract.contactWayList count] == 1) {
                CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:0];
                contract.selectedTelNumber = way.value;
            }
            cell.isSelectedButton = !cell.isSelectedButton;
            contract.isSelected = cell.isSelectedButton;
        }
    }else {
        // 如果是取消这个联系人
        contract.selectedTelNumber = @"";
        cell.isSelectedButton = !cell.isSelectedButton;
        contract.isSelected = cell.isSelectedButton;
    }
    // 刷新导航栏按钮状态
    [self refreshNavigationButtonState];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        return;
    }else {
        if (self.uiAddContactEnum == UIAddFriends || self.uiAddContactEnum == UIAddCloseFriends) {
            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:self.selectedCell.contactID];
            CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:buttonIndex];
            contract.selectedTelNumber = way.value;
            self.selectedCell.isSelectedButton = !self.selectedCell.isSelectedButton;
            contract.isSelected = self.selectedCell.isSelectedButton;
            // 刷新导航栏按钮状态
            [self refreshNavigationButtonState];
        }else if (self.uiAddContactEnum == UIAddLike) {
            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:self.singleCell.contactID];
            contract.isSelected = YES;
            CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:buttonIndex];
            contract.selectedTelNumber = way.value;
            NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
            [TelNumber addObject:contract.selectedTelNumber];
            addContactTypeWithSendMessage = FRIEND_CATEGORY_LOVER;
            CPLogInfo(@"--------点击添加为喜欢、暗恋--------好友姓名：%@------好友电话 ：%@--------",contract.fullName,contract.selectedTelNumber);
            CPLogInfo(@"--------开始调用后台服务------类型：FRIEND_CATEGORY_LOVER----------");
//            #warning 短信loading文本信息未确定 - 添加喜欢
            [self findMobileIsUserWithMobiles:TelNumber withLoadText:@"正在验证"];
        }else if (self.uiAddContactEnum == UIAddCouple) {
            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:self.singleCell.contactID];
            contract.isSelected = YES;
            CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:buttonIndex];
            contract.selectedTelNumber = way.value;
            
            ChooseCoupleTypeViewController *chooseCoupleType = [[ChooseCoupleTypeViewController alloc] initChooseCoupleTypeView:ContactChoose];
            [self.navigationController pushViewController:chooseCoupleType animated:YES];
        }else if (self.uiAddContactEnum == UIAddCoupleOnlyMoblieNumber) {
            //#warning 需要结合注册界面未完成
            // 获取用户选择的电话号码,并通知其他页面
            ContactModel *contract = (ContactModel *)[self.addContactModel.contactDictionary objectForKey:self.singleCell.contactID];
            CPUIModelContactWay *way = [contract.contactWayList objectAtIndex:buttonIndex];
            NSMutableArray *TelNumber = [NSMutableArray arrayWithCapacity:1];
            [TelNumber addObject:way.value];
            
        }
    }
}

-(void) refreshNavigationButtonState{
    NSUInteger result = [self.addContactModel getInvitedContactCount];
    if (result == 0) {
        [self.fnav.rightbutton setTitle:@"邀请" forState:UIControlStateNormal];
        // = [UIFont systemFontOfSize:12.0f];
        [self.fnav.rightbutton setTitleEdgeInsets:UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f)];
//        self.fnav.rightbutton.titleLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.0f alpha:0.5f];
        [self.fnav.rightbutton setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.75f] forState:UIControlStateNormal];
        [self.fnav.rightbutton setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.75f] forState:UIControlStateHighlighted];
        //self.fnav.rightbutton.titleLabel
        self.fnav.rightbutton.enabled = NO;
    }else {
        [self.fnav.rightbutton setTitle:[NSString stringWithFormat:@"邀请(%d)", result] forState:UIControlStateNormal];
        //self.fnav.rightbutton.font = [UIFont systemFontOfSize:12.0f];
        [self.fnav.rightbutton setTitleEdgeInsets:UIEdgeInsetsMake(4.0f, 0.0f, 0.0f, 0.0f)];
        [self.fnav.rightbutton setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.fnav.rightbutton setTitleColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f] forState:UIControlStateHighlighted];
        self.fnav.rightbutton.enabled = YES;
    }
}

// 设置Section头部高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 26.0f;
}

// 设置每个section的头部名称
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *SectionName;
    NSInteger sectionCount = 0;
    for (SectionModel *sectionModel in self.addContactModel.sectionArray) {
        if ( [sectionModel.searchArray count] != 0 ) {
            if (sectionCount == section) {
                SectionName = sectionModel.sectionName;
                break;
            }else {
                sectionCount += 1;
            }
        }
    }

    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 26.0f)];
    bgImage.image = [UIImage imageNamed:@"addressbook_titlebar.png"];
    
    CGRect frameRect = CGRectMake(0.0f, 1.0f, 320.0f, 26.0f);
    UILabel *label = [[UILabel alloc] initWithFrame:frameRect];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = SectionName;
    label.font = [UIFont fontWithName:@"Times New Roman" size:14.0f];;
    [bgImage addSubview:label];
    return bgImage;
} 

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
 转换十六进制颜色值为UIColor对象
 例子：
 [AddContractViewController colorWithHexString : @"#FFFFFF"];
 
 */
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // 传入字符小于六位，返回默认白色
    if ([cString length] < 6) return [UIColor whiteColor];
    
    //不合法行参，一律返回白色
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor whiteColor];
    // 分割字符
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // 保存数据
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

-(void) dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"modifyFriendTypeDic" context:@"modifyFriendTypeDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"findMobileIsUserDic" context:@"findMobileIsUserDic"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChooseCoupleNotification" object:nil];
}

@end
