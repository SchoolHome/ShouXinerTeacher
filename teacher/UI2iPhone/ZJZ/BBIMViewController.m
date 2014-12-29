//
//  IMViewController.m
//  iCouple
//
//  Created by qing zhang on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBIMViewController.h"
#import "TPCMToAMR.h"
#import "HomePageViewController.h"
#import "AddContactAnswerViewController.h"
#import "HomePageSelfProfileViewController.h"
#import "AllFriendsViewController.h"
#import "HomePageViewController.h"
#import "OverlayGuidView.h"
#import "HomeInfo.h"

@interface BBIMViewController ()
{
    UIImageView *alarmAlert;
    NSTimer * autoSendMsgTimer;
    
    BOOL isInited;
    int loopCount;
}
@property (nonatomic , strong) MessagePictrueViewController *messagePictrueController;

@property (nonatomic , strong)MessageVideoViewController *messageVideo;

@property (nonatomic, strong) NSTimer * autoSendMsgTimer;
@end

@implementation BBIMViewController
@synthesize detailViewController = _detailViewController , modelMessageGroup = _modelMessageGroup , messageVideo = _messageVideo ,
messagePictrueController = _messagePictrueController;
@synthesize autoSendMsgTimer = autoSendMsgTimer;
@synthesize msgGroupNeedRemove;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initByUnreadedMessage:(CPUIModelMessageGroup *)messageGroup
{
    self = [self init:messageGroup];
    if (self) {
        
    }
    return self;
}
-(id)init : (CPUIModelMessageGroup *)messageGroup
{
    NSLog(@"--------------IM messageGroup == %@-----------------",messageGroup);
    self.modelMessageGroup = messageGroup;
    self->loopCount = 0;
    self = [super initWithStatus:2];
    isInited = YES;
    
    
    if (self) {
        if (self.modelMessageGroup) {
            [[CPUIModelManagement sharedInstance] markMsgGroupReadedWithMsgGroup:self.modelMessageGroup];
            if (self.modelMessageGroup.memberList.count > 0) {
                CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
                userInfoType = [member.userInfo.type integerValue];
            }
            [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:self.modelMessageGroup];
        }
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupTag" options:0 context:@""];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"modifyFriendTypeDic" options:0 context:@""];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"deleteFriendDic" options:0 context:@""];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"responseActionDic" options:0 context:@"responseActionDic"];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"coupleMsgGroupTag" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSLog(@"--------------------------------IM setCurrentMsgGroup--------------------------- ==%@",self.modelMessageGroup);
    if (!isInited) {
        
        if ([HomeInfo shareObject].oldMsgGroup) {
            [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:[HomeInfo shareObject].oldMsgGroup];
            self.modelMessageGroup = [HomeInfo shareObject].oldMsgGroup;
        }
        
        
    }else
    {
        //当从im点右上角进入im时
        [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:self.modelMessageGroup];
    }
    
    
    if ([[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2] isKindOfClass:[IMViewController class]]) {
        IMViewController *viewcontroler = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        viewcontroler.msgGroupNeedRemove = YES;
    }
    
    
}


-(void) keyboardWillShow : (NSNotification *)not{
    CGRect keyboardBounds;
    [[not.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];

    float height = 0.0f;
    if (self.screenHeight == 568.0f) {
        height = 461.0f - keyboardBounds.size.height;
    }else{
        height = 373.0f - keyboardBounds.size.height;
    }
    
    // animations settings
    [UIView animateWithDuration:[duration integerValue] delay:0.0f options:[curve intValue] animations:^{
        self.IMView.frame = CGRectMake(0, 0, self.IMView.frame.size.width, height);
    } completion:^(BOOL finished) {
        [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:YES withImportData:YES withRefreshMessage:YES];
    }];
}

-(void) keyboardWillHide : (NSNotification *)not{
    NSNumber *duration = [not.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [not.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    float height = 461.0f;
    if (self.screenHeight != 568.0f) {
        height = 373.0f;
    }
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.IMView.frame = CGRectMake(0, 0, self.IMView.frame.size.width, height);
    [UIView commitAnimations];
}



-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self.keybordView showInView:self.view];
    
//    BOOL isfirstViewd =[[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirstViewd"] boolValue];
//    if (!isfirstViewd) {
//        OverlayGuidView *overlayView = [[OverlayGuidView alloc] initWithFrame:CGRectMake(34, -75, 208, 104)];
//        [overlayView setImage:[UIImage imageNamed:@"ss_im_item_float"]];
//        [overlayView showInView:[self.keybordView keyboardTopBar] duration:3.f];
//        
//        [self.keybordView bringSubviewToFront:overlayView];
//        
//        UILabel *overlayViewText = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 194, 40)];
//        overlayViewText.backgroundColor = [UIColor clearColor];
//        overlayViewText.text = @"点这里玩玩小双特有的传情、传声、偷偷问、闹闹吧！";
//        overlayViewText.font = [UIFont systemFontOfSize:14.f];
//        overlayViewText.numberOfLines = 2;
//        overlayViewText.textColor = [UIColor whiteColor];
//        [overlayView addSubview:overlayViewText];
//        
//        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isFirstViewd"];
//        
//        
//    }
    
    if (self.msgGroupNeedRemove) {
        if (self.currentStatus != message_view_Status_Down) {
            [[CPUIModelManagement sharedInstance] markMsgGroupReadedWithMsgGroup:self.modelMessageGroup];
            [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:YES withImportData:YES withRefreshMessage:YES];
        }else {
            [self setunReadedAlertStatus];
        }
        self.msgGroupNeedRemove = NO;
    }
    //如果homemain不在栈里，则添加进来
//    NSMutableArray *arrControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    //改变栈的结构
//    if (arrControllers.count > 3) {
//        for (int i = 0; i<arrControllers.count; i++) {
//            
//            if (i>1 && i != arrControllers.count-1) {
//                [arrControllers removeObjectAtIndex:i];
//                
//                i--;
//                
//            }
//        }
//    }
//    [self.navigationController setViewControllers:arrControllers];
//    HomeMainViewController *homemain;
//    for (id viewcontroller in arrControllers) {
//        if ([viewcontroller isKindOfClass:[HomePageViewController class]]) {
//            if ([viewcontroller homeMainViewController]) {
//                homemain = [viewcontroller homeMainViewController];
//            }else {
//                homemain = [[HomeMainViewController alloc] init];
//            }
//        }else if ([viewcontroller isKindOfClass:[HomeMainViewController class]]) {
//            return;
//        }
//    }
    
    //HomeMainViewController *homemain = [[HomeMainViewController alloc] init];
//    [arrControllers insertObject:homemain atIndex:1];
    
//    [self.navigationController setViewControllers:arrControllers];
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.keybordView resetFrame];
    
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupTag"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"modifyFriendTypeDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"deleteFriendDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"responseActionDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"coupleMsgGroupTag"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    
    [self stopMusicPlayer];
    [self stopMessageDetailSound];
    
    isInited = NO;
    if (self.modelMessageGroup) {
        [HomeInfo shareObject].oldMsgGroup = self.modelMessageGroup;
        [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:nil];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self changeButtonImageByStatus:Btn_Back_IM];
    //未读数
    self.unReadedAlert = [[UIImageView alloc] init];
    [self.imageviewHeadImg addSubview:self.unReadedAlert];
    //IM内容区
    self.detailViewController = [[MessageDetailViewController alloc] init];
    self.detailViewController.view.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    self.detailViewController.delegate = self;
    self.detailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.detailViewController.view setFrame:CGRectMake(0, 0, self.IMView.frame.size.width, self.IMView.frame.size.height)];
    
    [self.detailViewController.messageTable setFrame:CGRectMake(0, 0, 320.f, self.detailViewController.view.frame.size.height)];
    [self.IMView addSubview:self.detailViewController.view];
    [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:NO withImportData:YES withRefreshMessage:NO];
    
    UIImageView *hideBordInIMView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -10.f, 320, 25.f)];
    [hideBordInIMView setImage:[UIImage imageNamed:@"im_mask2.png"]];
    [self.IMView addSubview:hideBordInIMView];
    
    
    //刷新近况
    [self refreshFriendRecent:-1];
    self.detailViewController.canPlayMagic = YES;
    
    //设置未读数
    [self setunReadedAlertStatus];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMsgGroup) name:@"refreshMessageGroup" object:nil];
}
-(void)refreshMsgGroup
{
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Observer

//Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.modelMessageGroup = [CPUIModelManagement sharedInstance].userMsgGroup;
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        /**********************王硕 2012－5－24**************************/
        
        switch ([CPUIModelManagement sharedInstance].userMsgGroupTag) {
            case UPDATE_USER_GROUP_TAG_DEFAULT:{
                [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:NO withImportData:YES withRefreshMessage:NO];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND:{
                [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:YES withImportData:YES withRefreshMessage:YES];
                
                //当proifle时记录未读数
                if (self.currentStatus == message_view_Status_Down ) {
                    [self setunReadedAlertStatus];
                }else {
                    [[CPUIModelManagement sharedInstance] markMsgGroupReadedWithMsgGroup:self.modelMessageGroup];
                }
                
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT:{
                [self.detailViewController loadHistoryMessageData:[CPUIModelManagement sharedInstance].userMsgGroup];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END:{
                [self.detailViewController loadHIstoryMessageDataIsNull];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD:{
                [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:NO withAnimated:NO withImportData:YES withRefreshMessage:NO];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MEM_LIST:{
            }
                
                [self refreshFriendRecent:-1];
                break;
            case UPDATE_USER_GROUP_TAG_MSG_GROUP:{
                [self setunReadedAlertStatus];
            }
                break;
            case UPDATE_USER_GROUP_TAG_ONLY_REFRESH:{
                [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:NO withAnimated:NO withImportData:NO withRefreshMessage:YES];
            }
                break;
                //退群
            case UPDATE_USER_GROUP_TAG_DEL:
            {
            }
            default:
                break;
        }
        
        /**********************王硕 2012－5－24**************************/
        [self.imageviewHeadImg setBackImage:[self returnCircleHeadImg]];
    }else if ([keyPath isEqualToString:@"modifyFriendTypeDic"])
    {
        
    }else if ([keyPath isEqualToString:@"deleteFriendDic"])
    {
        
    }
    //系统消息过来的消息框点击同意后
    
    else if ([keyPath isEqualToString:@"responseActionDic"])
    {
        //warning 成为couple后的庆祝动画
    }else if ([keyPath isEqualToString:@"coupleMsgGroupTag"]) {
        switch ([CPUIModelManagement sharedInstance].coupleMsgGroupTag) {
            case UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT:{
                [self.detailViewController loadHistoryMessageData:[CPUIModelManagement sharedInstance].userMsgGroup];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END:{
                [self.detailViewController loadHIstoryMessageDataIsNull];
            }
                break;
        }
    }
}
#pragma mark Method
//页面退出时需要设置的属性
-(void)needResetProperty:(BOOL)needRemoveMsgGroup andNeedResetKeybord:(BOOL)needReset
{
    if (needRemoveMsgGroup) {
        self.msgGroupNeedRemove = NO;
    }
    if (needReset) {
        
    }
}
//返回
-(void)backToHome:(UIButton *)sender
{
    NSLog(@"-----------IMBack--------------self.modelmessageGroup==%@",self.modelMessageGroup);
    if (userInfoType != USER_MANAGER_SYSTEM && userInfoType != USER_MANAGER_XIAOSHUANG && self.currentStatus == message_view_Status_Down) {
        //[self.keybordView setFrame:CGRect_whenKeybordViewd];
        //[self.keybordView dismiss];
    }
    if (self.modelMessageGroup) {
        if ([self.modelMessageGroup.relationType integerValue] == MSG_GROUP_UI_RELATION_TYPE_COUPLE) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }else {
            for (HomeMainViewController *homeMain in self.navigationController.viewControllers) {
                if ([homeMain isKindOfClass:[HomeMainViewController class]]) {
                    if ([self.modelMessageGroup.relationType integerValue] == MSG_GROUP_UI_RELATION_TYPE_COMMON || [self.modelMessageGroup isMsgMultiConver]) {
                        [homeMain scrollToRect:ContactFriend_NormalFriend withAnimation:NO];
                        [self.navigationController popToViewController:homeMain animated:YES];
                    }else if([self.modelMessageGroup.relationType integerValue] == MSG_GROUP_UI_RELATION_TYPE_CLOSER || [self.modelMessageGroup isMsgConverGroup])
                    {
                        [homeMain scrollToRect:ContactFriend_CloseFriend withAnimation:YES];
                        [self.navigationController popToViewController:homeMain animated:YES];
                    }else {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    return;
                }
            }
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)setFrameWhenAnimationed:(NSUInteger)type
{
    [super setFrameWhenAnimationed:type];
    if (type == 1 || type == 2) {
        self.detailViewController.canPlayMagic = YES;
        [[CPUIModelManagement sharedInstance] markMsgGroupReadedWithMsgGroup:self.modelMessageGroup];
        if ([self.modelMessageGroup isMsgSingleGroup]) {
            [self.singleProfileView stopAudioPlayer];
        }
        [self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:NO withImportData:NO withRefreshMessage:NO];
    }else {
        self.detailViewController.canPlayMagic = NO;
    }
}
//返回头像Image(如果多人IM也可自己设置头像在此方法中扩充即可)
-(UIImage *)returnCircleHeadImg
{
    UIImage *headImage;
    if ([self.modelMessageGroup isMsgSingleGroup])
    {
        if (self.modelMessageGroup.memberList.count > 0 ) {
            CPUIModelMessageGroupMember *member =  [self.modelMessageGroup.memberList objectAtIndex:0];
            CPUIModelUserInfo *userInfo = member.userInfo;
            //获取最新昵称
//            self.nickName.text = userInfo.nickName;
            //获取通讯录名字
            if ([[CPUIModelManagement sharedInstance] getContactFullNameWithMobile:userInfo.mobileNumber]) {
//                self.contactName.text = [NSString stringWithFormat:@"(%@)",[[CPUIModelManagement sharedInstance] getContactFullNameWithMobile:userInfo.mobileNumber]];
            }
            //获取最新头像
            headImage = [UIImage imageWithContentsOfFile:userInfo.headerPath];
            if (!headImage) {
                headImage = [UIImage imageNamed:@"headpic_index_normal_120x120"];
            }
        }else {
            headImage = [UIImage imageNamed:@"headpic_index_normal_120x120"];
        }
    }else {
        headImage = [UIImage imageNamed:@"head_group_im.png"];
    }
    
    
    return headImage;
}
//刷新近况
-(void)refreshFriendRecent:(NSInteger)type
{
//    if (type == -1) {
//        type = self.currentStatus;
//    }
//    if (self.modelMessageGroup.memberList.count > 0 && ([self.modelMessageGroup.type integerValue] == MSG_GROUP_UI_TYPE_SINGLE || [self.modelMessageGroup.type integerValue] == MSG_GROUP_UI_TYPE_SINGLE_PRE) && type == message_view_Status_Middle) {
//        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
//        CPUIModelUserInfo *userInfo = member.userInfo;
//        //近况
//        if (self.recentView.subviews.count >0) {
//            [self.recentView removeFromSuperview];
//        }
//        switch (userInfo.recentType) {
//            case USER_RECENT_TYPE_TEXT:
//            {
//                if ([userInfo.recentContent isEqualToString:@""]) {
//                    //[self.recentView setHidden:YES];
//                }else {
//                    self.recentView = [[RecentView alloc] initWithTextFrame:CGRect_recentTextView withGroupData:self.modelMessageGroup];
//                    [self.recentView setImage:[UIImage imageNamed:@"float_im_state_text.png"]];
//                    [self.recentView setFrame:CGRect_recentTextView];
//                    [self.view addSubview:self.recentView];
//                }
//            }
//                break;
//            case USER_RECENT_TYPE_AUDIO:
//            {
//                self.recentView = [[RecentView alloc] initWithAudioFrame:CGRect_recentAudioView withGroupData:self.modelMessageGroup];
//                self.recentView.recentViewDelegate = self;
//                [self.recentView setImage:[UIImage imageNamed:@"float_im_state_say.png"]];
//                [self.recentView setFrame:CGRect_recentAudioView];
//                [self.view addSubview:self.recentView];
//            }
//                break;
//            default:
//            {
//                [self.recentView setHidden:YES];
//            }
//                break;
//        }
//    }else {
//        self.recentView.hidden = YES;
//    }
}
//设置未读数
-(void)setunReadedAlertStatus
{
    
    if (self.currentStatus == message_view_Status_Down && [self.modelMessageGroup.unReadedCount integerValue] > 0) {
        
        if ([self.modelMessageGroup.unReadedCount integerValue] < 100) {
            CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d",[self.modelMessageGroup.unReadedCount integerValue]] sizeWithFont:[UIFont systemFontOfSize:12]];
            [self.unReadedAlert setFrame:CGRectMake(imageviewHeadImageInStatusMid-25.f-unReaderTextSize.width/2.f, 5.f, unReaderTextSize.width + 20.f, 27.5)];
        }else {
            CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d+",99] sizeWithFont:[UIFont systemFontOfSize:12]];
            [self.unReadedAlert setFrame:CGRectMake(imageviewHeadImageInStatusMid-25.f-unReaderTextSize.width/2.f, 5.f, unReaderTextSize.width + 20.f, 27.5)];
        }
        
        //未读数
        UILabel *labelUnReaded = (UILabel *)[self.unReadedAlert viewWithTag:UnReadedLabel];
        if (!labelUnReaded) {
            labelUnReaded = [[UILabel alloc] initWithFrame:CGRectMake(3.f, 6.f, self.unReadedAlert.frame.size.width-6.f, 12)];
            labelUnReaded.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
            labelUnReaded.font = [UIFont systemFontOfSize:12];
            labelUnReaded.backgroundColor = [UIColor clearColor];
            labelUnReaded.textAlignment = UITextAlignmentCenter;
            labelUnReaded.tag = UnReadedLabel;
            [self.unReadedAlert addSubview:labelUnReaded];
        }else {
            [labelUnReaded setFrame:CGRectMake(3.f, 6.f, self.unReadedAlert.frame.size.width-6.f, 12)];
            //labelUnReaded.text = [NSString stringWithFormat:@"%d",[self.modelMessageGroup.unReadedCount integerValue]];
        }
        
        if ([self.modelMessageGroup.unReadedCount integerValue] < 100) {
            labelUnReaded.text = [NSString stringWithFormat:@"%d",[self.modelMessageGroup.unReadedCount integerValue]];
        }else {
            labelUnReaded.text = @"99+";
        }
        self.unReadedAlert.hidden = NO;
        labelUnReaded.hidden =YES;
        if (self.modelMessageGroup.msgList.count > 0) {
            UIImage *image1 = [UIImage imageNamed:@"item_index_redcircle.png"];
            UIImage *image = [image1 stretchableImageWithLeftCapWidth:image1.size.width/2.f topCapHeight:0];
            [self.unReadedAlert setImage:image];
            CPUIModelMessage *message = [self.modelMessageGroup.msgList objectAtIndex:self.modelMessageGroup.msgList.count-1];
            if ([self.modelMessageGroup.unReadedCount integerValue] == 1) {
                if ([message.flag integerValue] == MSG_FLAG_RECEIVE) {
                    switch ([message.contentType integerValue]) {
                        case MSG_CONTENT_TYPE_TEXT:
                        {
                            labelUnReaded.hidden = NO;
                            //[self.unReadedAlert setImage:[UIImage imageNamed:@"icon_info_bg.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_IMG:
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_photo.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_AUDIO:
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_voice.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_VIDEO:
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_video.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_MAGIC:
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_video.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_CS:
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_voice.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_CQ:
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_video.png"]];
                        }
                            break;
                        case MSG_CONTENT_TYPE_ALARMED_TEXT: //文本的提醒过的
                        case   MSG_CONTENT_TYPE_ALARM_TEXT ://文本的提醒
                        case MSG_CONTENT_TYPE_ALARM_AUDIO:    //语音的提醒
                        case MSG_CONTENT_TYPE_ALARMED_AUDIO://语音的提醒过的
                        {
                            [self.unReadedAlert setImage:[UIImage imageNamed:@"icon_alarm.png"]];
                        }
                            break;
                        default:
                        {
                            labelUnReaded.hidden = NO;
                        }
                            break;
                    }
                    
                }
                
                
            }else if ([self.modelMessageGroup.unReadedCount integerValue] >1 && [self.modelMessageGroup.unReadedCount integerValue] < 100){
                labelUnReaded.hidden = NO;
                //[self.unReadedAlert setImage:[UIImage imageNamed:@"icon_info_bg.png"]];
            }else if ([self.modelMessageGroup.unReadedCount integerValue] >= 100)
            {
                labelUnReaded.hidden = NO;
            }
        }
        
        
    }else {
        self.unReadedAlert.hidden = YES;
    }
}


#pragma mark Profile
//profile
//"+"号添加好友进回话，过滤掉当前回话成员的memberList
/*
 -(void)addFriendInFriendViewController
 {
 NSMutableArray *arrFriendsInMemberList = [[NSMutableArray alloc] init];
 for (int i = 0; i<[CPUIModelManagement sharedInstance].friendArray.count; i++) {
 CPUIModelUserInfo *userInfoFriendArr = [[CPUIModelManagement sharedInstance].friendArray objectAtIndex:i];
 if (self.modelMessageGroup.memberList.count > 0) {
 for (int j = 0; j<self.modelMessageGroup.memberList.count; j++) {
 CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:j];
 if ([member.userInfo.name isEqualToString:userInfoFriendArr.name] || !([userInfoFriendArr.type integerValue]== 1 || [userInfoFriendArr.type integerValue]== 2 || [userInfoFriendArr.type integerValue]== 3 || [userInfoFriendArr.type integerValue]== 4 || [userInfoFriendArr.type integerValue]== 5)) {
 break;
 }
 if (j == self.modelMessageGroup.memberList.count - 1) {
 [arrFriendsInMemberList addObject:userInfoFriendArr];
 }
 }
 }else {
 if ([userInfoFriendArr.type integerValue]== 1 || [userInfoFriendArr.type integerValue]== 2 || [userInfoFriendArr.type integerValue]== 3 || [userInfoFriendArr.type integerValue]== 4 || [userInfoFriendArr.type integerValue]== 5) {
 [arrFriendsInMemberList addObject:userInfoFriendArr];
 }
 }
 
 }
 
 keybordNeedResetFlag = YES;
 msgGroupNeedRemove = YES;
 if (arrFriendsInMemberList.count != 0) {
 FriendsViewController *friend = [[FriendsViewController alloc] initWithFromTypeProfileWithFriendArray:arrFriendsInMemberList withGroup:self.modelMessageGroup];
 [self.navigationController pushViewController:friend animated:YES];
 }else {
 [[HPTopTipView shareInstance] showMessage:@"你的好友都在这里啦" duration:1.5f];
 }
 
 }
 */
//新大家添加好友，直接传messageGroup
-(void)addFriendInFriendViewController
{
    keybordNeedResetFlag = YES;
    self.msgGroupNeedRemove = YES;
    if (self.modelMessageGroup) {
        int i = 0;
        for (CPUIModelMessageGroupMember *member in self.modelMessageGroup.memberList) {
            if (![member isHiddenMember]) {
                i++;
            }
        }
        NSLog(@"%d,%d",i,[CPUIModelManagement sharedInstance].friendArray.count);
        if (i >= [CPUIModelManagement sharedInstance].friendArray.count - 3 || i == 19) {
            [[HPTopTipView shareInstance] showMessage:@"你的好友都在这里啦" duration:1.5f];
        }else {
            AllFriendsViewController *friend = [[AllFriendsViewController alloc] initWithState:ALL_FRIENDS_STATE_CHAT group:self.modelMessageGroup];
            [self.navigationController pushViewController:friend animated:YES];
        }
        
    }
    
    
}
#pragma mark Keybord

-(void)clickCancel:(id)context
{
    
}
-(void) clickConfirm : (BOOL) isChecked withContext : (id) context{
    
    if(_magicDownloadType == MAGIC_DOWNLOAD_TYPE_SINGLE){
        
        [[CPUIModelManagement sharedInstance] downloadPetRes:_magicID ofPet:_petID];
    }
    else if(_magicDownloadType == MAGIC_DOWNLOAD_TYPE_MULTI){
        [[CPUIModelManagement sharedInstance] updatePetResOfPet:nil];
    }
    else if(_magicDownloadType == MAGIC_DOWNLOAD_TYPE_NONE){
        
    }
    
    if(isChecked == YES){
        _hideAlert = YES;
    }
    else{
        _hideAlert = NO;
    }
    [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断下载"];
}
-(void)keyboardViewDownloadMagic:(NSString *)magicMsgID_ ofPet:(NSString *)petID_
{
    _magicDownloadType = MAGIC_DOWNLOAD_TYPE_SINGLE;
    _magicID = magicMsgID_;
    _petID   = petID_;
    //    _magicID = [NSString stringWithFormat:magicMsgID_];
    //    _petID = [NSString stringWithFormat:petID_];
    if([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi){
        [[CPUIModelManagement sharedInstance] downloadPetRes:_magicID ofPet:_petID];
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断下载"];
    }
    else{
        if(_hideAlert == YES){
            [[CPUIModelManagement sharedInstance] downloadPetRes:_magicID ofPet:_petID];
        }
        else{
            
            CustomAlertView *custom = [[CustomAlertView alloc] init];
            CPUIModelPetMagicAnim *MagicAnim = [[CPUIModelManagement sharedInstance] magicObjectOfID:magicMsgID_ fromPet:petID_];
            CGFloat size = [MagicAnim.size floatValue]/1024;
            
            NSString * checkString_ = [NSString stringWithFormat:@"该表情%.1fM,你处于非Wifi环境,现在下载么",size];
            check = [custom showCheckMessage:checkString_ withContext:@""];
            check.delegate =self;
        }
        
    }
}
//keybord
-(void)keyboardViewDownloadCount:(int)count size:(CGFloat)size
{
    _magicDownloadType = MAGIC_DOWNLOAD_TYPE_MULTI;
    if([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi){
        [[CPUIModelManagement sharedInstance] updatePetResOfPet:nil];
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断下载"];
    }
    else{
        CustomAlertView *custom = [[CustomAlertView alloc] init];
        
        NSString * messageString = [NSString stringWithFormat:@"共%d个魔法表情(%.1fM),你处于非WiFi环境,现在下载么?",count,size/1024];
        check = [custom showCheckMessage:messageString withContext:@""];
        check.delegate =self;
    }
}
-(void)keyboardViewNeedMoreAlert
{
    _magicDownloadType = MAGIC_DOWNLOAD_TYPE_NONE;
    if(block_view_submit == nil){
        block_view_submit = [[FXBlockViewSubmit alloc] init];
        [block_view_submit doSetText:@"想要更多新表情？ 给社稷施mm和攻城狮gg点动力吧"];
        [block_view_submit doSetCenterButtonNormalImage:[UIImage imageNamed:@"sure_im_magicdownload@2x.png"] highlightImage:[UIImage imageNamed:@"surepress_im_magicdownload@2x.png"]];
        [block_view_submit doSetCenterButtonNormalTitle:@"加油" highlightTitle:@"加油"];
        [block_view_submit.centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [block_view_submit.centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [block_view_submit setDelegate:self];
    }
    
    [block_view_submit doShowBlockViewInViewController:[UIApplication sharedApplication].keyWindow];
}
- (void)actionBlockViewCloseButtonTouchedSender:(UIButton *)closeButton{
    [block_view_submit doHideBlockView];
}
- (void)actionBlockViewCenterButtonTouchedSender:(UIButton *)centerButton{
    [block_view_submit doHideBlockView];
    [[CPUIModelManagement sharedInstance] pushFanxerTeam];
}
//键盘关闭
- (void)keyboardViewDidDisappear
{
//    switch (self.currentStatus) {
//        case message_view_Status_up:
//        {
//            [self.IMView setFrame:CGRect_IMViewInStatusUp];
//        }
//            break;
//        case message_view_Status_Middle:
//        {
//            [self.IMView setFrame:CGRect_IMViewInStatusMid];
//        }
//            break;
//        default:
//            break;
//    }
//    keybordViewed = NO;
    //[self.detailViewController refreshMessageData:self.modelMessageGroup withMove:YES withAnimated:NO withImportData:NO withRefreshMessage:NO];
}
// open pet
-(void)keyboardViewOpenPet
{
    self.detailViewController.canPlayMagic = NO;
    
    for (PetView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([view isKindOfClass:[PetView class]]) {
            return;
        }
    }
    //[self clickAnyThingWill:YES ];
    PetView *petView ;
    //根据relationType判断的状态不是最新的
    if ([self.modelMessageGroup isMsgMultiGroup]) {
        petView = [[PetView alloc] initWithFrame:CGRectMake(0, 20, 320, 480) type:PetViewTypeGroup];
    }else{
        if (self.modelMessageGroup.memberList.count>0) {
            CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
            CPUIModelUserInfo *userInfor = member.userInfo;
            CPUIModelUserInfo *userInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:userInfor.name];
            if ([userInfo.type integerValue] == USER_RELATION_TYPE_COMMON) {
                petView = [[PetView alloc] initWithFrame:CGRectMake(0, 20, 320, 480) type:PetViewTypeNoneCouple];
            }else {
                petView = [[PetView alloc] initWithFrame:CGRectMake(0, 20, 320, 480) type:PetViewTypeCouple];
            }
        }
    }
    
    
    petView.delegate = self;
    //[petView showInView:self.view];
    [petView showInView:[UIApplication sharedApplication].keyWindow];
    
    /****************王硕 2012－6－14*********************/
    [self stopMessageDetailSound];
    /****************王硕 2012－6－14*********************/
    [[MusicPlayerManager sharedInstance] stop];
}
//pet发送
-(void)petFeelingStartSend:(PetView *)aPetView message: (CPUIModelMessage *)message{
    
    [[CPUIModelManagement sharedInstance]sendMsgWithGroup:self.modelMessageGroup andMsg:message];
    self.detailViewController.canPlayMagic = YES;
}
//pet取消
-(void)petViewDidDismiss
{
    
    self.detailViewController.canPlayMagic = YES;
}
//选取相册
-(void)keyboardViewOpenPhotoLibrary
{
//    [[HPStatusBarTipView shareInstance] setHidden:YES];
    
    float height = 461.0f;
    if (self.screenHeight != 568.0f) {
        height = 373.0f;
    }
    self.IMView.frame = CGRectMake(0, 0, self.IMView.frame.size.width, height);
    
    
    self.detailViewController.canPlayMagic = NO;
    imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    self.msgGroupNeedRemove = YES;
    imagePicker.delegate = self;
    [self presentModalViewController: imagePicker animated: YES];
    [self reBoundByCurrentStatus];
}
//选取照相机
-(void)keyboardViewOpenCamera
{
//    [[HPStatusBarTipView shareInstance] setHidden:YES];
    
    float height = 461.0f;
    if (self.screenHeight != 568.0f) {
        height = 373.0f;
    }
    self.IMView.frame = CGRectMake(0, 0, self.IMView.frame.size.width, height);
    self.detailViewController.canPlayMagic = NO;
    imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (userInfoType != USER_MANAGER_FANXER) {
//            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//            imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
//            imagePicker.videoMaximumDuration = 30;
        }else {
            
        }
        
    }
    imagePicker.delegate = self;
    self.msgGroupNeedRemove = YES;
    [self presentModalViewController:imagePicker animated: YES];
    [self reBoundByCurrentStatus];
    /*********************王硕 2012－6－19***************************/
    [self stopMessageDetailSound];
    /*********************王硕 2012－6－19***************************/
    [[MusicPlayerManager sharedInstance] stop];
    
}
//取消图片选择器
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    self.detailViewController.canPlayMagic = YES;
}

//图片选择器选择图片后续
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"]){
        
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        if (self.modelMessageGroup) {
            
            CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
            [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_VIDEO]];
            [message setVideoUrl:videoURL];
            [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.modelMessageGroup andMsg:message];
        }else {
        }
    }else if ([mediaType isEqualToString:@"public.image"]){
        if (self.modelMessageGroup) {
            CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
            [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_IMG]];
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            UIImage *imageScale = image;
            
            CGFloat scaleFloat = 0.0f;
            if (image.size.width > 640.0f && image.size.height > 960.0f) {
                if (image.size.width >= image.size.height) {
                    scaleFloat = 640.0f / image.size.width;
                }else {
                    scaleFloat = 960.0f / image.size.height;
                }
            }else if (image.size.width > 640.0f && image.size.height <= 960.0f) {
                scaleFloat = 640.0f / image.size.width;
            }else if (image.size.width <= 640.0f && image.size.height > 960.0f) {
                scaleFloat = 960.0f / image.size.height;
            }else {
                scaleFloat = -1.0f;
            }
            if (scaleFloat > 0.0f) {
                imageScale = [UIImage scaleImage:image scaleFactor:scaleFloat];
            }
            [message setMsgData:UIImageJPEGRepresentation(imageScale, 0.5f)];
            [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.modelMessageGroup andMsg:message];
        }else {
            
        }
    }
    
    [self dismissModalViewControllerAnimated:YES];
    self.detailViewController.canPlayMagic = YES;
}


- (void) onTimer:(NSTimer *)timer
{
    CPUIModelMessageGroup *messageGroup = [[timer userInfo]objectForKey:@"msggroup"];
    CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
    [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
    NSMutableString *msgText = [[NSMutableString alloc]init];
    [msgText appendString:@"ios autoMsg:"];
    self->loopCount  += 1;
    [msgText appendString:[NSString stringWithFormat:@"%d", self->loopCount]];
    [message setMsgText:msgText];
    [message setDate:[CoreUtils getLongFormatWithNowDate]];
    [[CPUIModelManagement sharedInstance] sendMsgWithGroup:messageGroup andMsg:message];
}

- (NSTimer*) getAnActiveTimer
{
    if(nil == autoSendMsgTimer||![autoSendMsgTimer isValid]){
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:self.modelMessageGroup forKey:@"msggroup"];
        
        autoSendMsgTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(onTimer:) userInfo:dic repeats:YES];
    }
    return autoSendMsgTimer;
}
// send message
-(void)keyboardViewSendText:(NSString *)text_
{
    if (![text_ isEqualToString:@""]) {
        
        if (self.modelMessageGroup) {
            CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
            [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_TEXT]];
            [message setMsgText:text_];
            [message setDate:[CoreUtils getLongFormatWithNowDate]];
            [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.modelMessageGroup andMsg:message];
            if ([text_ isEqualToString:@"loopstart"]){
                NSTimer *timer = [self getAnActiveTimer];
                [timer fire];
            }else if([text_ isEqualToString:@"loopstop"]){
                NSTimer *timer = [self getAnActiveTimer];
                [timer invalidate];
            }
        }else {
            
        }
    }
    
    
}
-(void)keyboardViewSendMagic:(NSString *)magicMsgID_ ofPet:(NSString *)petID_
{
    if (self.modelMessageGroup) {
        
        CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
        [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_MAGIC]];
        [message setMagicMsgID:magicMsgID_];
        [message setPetMsgID:petID_];
        [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.modelMessageGroup andMsg:message];
        
        [self.detailViewController firstSendMagicMessageWithID:magicMsgID_ withPetID:petID_];
    }else {
        
    }
}

// 录音相关
// 开始
-(void)keyboardViewRecordDidStarted:(id) arMicView_
{
    [self stopMusicPlayer];
    self.detailViewController.canPlayMagic = NO;
    self.view.userInteractionEnabled = NO;
}
// 录音太短
-(void)keyboardViewRecordTooShort:(id) arMicView_
{
    self.view.userInteractionEnabled = YES;
    self.detailViewController.canPlayMagic = YES;
}
// 正确录音结束
-(void)keyboardViewRecordDidEnd:(id) arMicView_ pcmPath:(NSString *)pcmPath_ length:(CGFloat) audioLength_
{
    self.view.userInteractionEnabled = YES;
    self.detailViewController.canPlayMagic = YES;
    if (self.modelMessageGroup) {
        CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
        [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_AUDIO]];
        [message setFilePath:pcmPath_];
        [message setMediaTime:[NSNumber numberWithInteger:audioLength_]];
        [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.modelMessageGroup andMsg:message];
    }
}
// 录音转码失败或者被中断

-(void)keyboardViewRecordErrorDidOccur:(id) arMicView_ error:(NSError *)error
{
    self.view.userInteractionEnabled = YES;
    self.detailViewController.canPlayMagic = YES;
}
#pragma mark DetailViewController
-(void)clickedSoundMessage
{
    [self stopMusicPlayer];
}
-(void)stopUserSound
{
    [self stopMusicPlayer];
}
//detail
-(void) stopMessageDetailSound{
    [self.detailViewController stopSound];
}
//闹钟消息提醒浮层
-(void) alarmFirstShow
{
    alarmAlert = [[UIImageView alloc] initWithFrame:CGRectMake(320.0f -204.5f-3.0f, 47.0f, 204.5f, 78.5f)];
    [alarmAlert setImage:[UIImage imageNamed:@"alarm_im_item_float.png"]];
    [self.view addSubview:alarmAlert];
    [UIImageView beginAnimations:@"show" context:nil];
    [UIImageView setAnimationDuration:0.5f];
    [UIImageView setAnimationDelay:2.5f];
    [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // 动画的结束回调，回调方法内
    [UIImageView setAnimationDelegate:self];
    [UIImageView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    
    [alarmAlert setAlpha:1.0f];
    
    [self performSelector:@selector(endAnimation) withObject:self afterDelay:3.0];
    
    [UIImageView commitAnimations];
}
-(void)endAnimation
{
    [alarmAlert removeFromSuperview];
}
// 点击系统消息跳转
-(void) clickedSystemActionMessage : (AddContactAnalysis) analysisResult withModel : (ExMessageModel *) exModel
{
    CPUIModelSysMessageReq *messageRequest = [exModel.messageModel getSysMsgReq];
    CPUIModelUserInfo *userInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:messageRequest.userName];
    if ( nil == userInfo)
    {
        userInfo = [[CPUIModelUserInfo alloc] init];
        [userInfo setName:messageRequest.userName];
        [userInfo setNickName:messageRequest.nickName];
    }
    UserInforModel *userInfor = [[UserInforModel alloc] initUserInfor];
    userInfor.headerPath = userInfo.headerPath;
    userInfor.nickName = userInfo.nickName;
    userInfor.fullName = userInfo.fullName;
    userInfor.userName = userInfo.name;
    userInfor.telPhoneNumber = userInfo.mobileNumber;
    
    if (analysisResult == OpenAddContactWithAnswer) {
        
        AddContactAnswerViewController *answer = [[AddContactAnswerViewController alloc] initAddContactWithUserInfor:exModel];
        [self.navigationController pushViewController:answer animated:YES];
    }else if(analysisResult == OpenAddContactWithProfile)
    {
        AddContactWithProfileViewController *profile = [[AddContactWithProfileViewController alloc] initAddContactWithUserInfor:userInfor];
        [self.navigationController pushViewController:profile animated:YES];
    }else if(analysisResult == OpenAddContactWithCommendProfile)
    {
        CPUIModelSysMessageFriCommend *messageRequestCommend = [exModel.messageModel getSysMsgFriCommend];
        UserInforModel *userInfor = [[UserInforModel alloc] initUserInfor];
        //        userInfor.headerPath = messageRequestCommend.headerPath;
        userInfor.nickName = messageRequestCommend.nickName;
        userInfor.userName = messageRequestCommend.userName;
        userInfor.telPhoneNumber = messageRequestCommend.mobileNumber;
        
        AddContactWithProfileViewController *profile = [[AddContactWithProfileViewController alloc] initAddContactWithUserInfor:userInfor];
        [self.navigationController pushViewController:profile animated:YES];
    }else if (analysisResult == OpenSingleIndependentProfile){
        SingleIndependentProfileViewController *singleIndependeneProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:userInfo];
        [self.navigationController pushViewController:singleIndependeneProfile animated:YES];
    }
    keybordNeedResetFlag = YES;
    self.msgGroupNeedRemove = YES;
}
//点击所有内容区
-(void) clickedMessageCell
{
    //[self clickAnyThingWill:NO];
    [self.keybordView hidePhotoSwitch];
    [self.keybordView resetFrame];
}
//点击头像
-(void)clickedUserHeadOfMessage:(id)senderUserID
{
//    CPUIModelMessageGroupMember *member = (CPUIModelMessageGroupMember *)senderUserID;
//    CPUIModelUserInfo *userInfo = member.userInfo;
//    [self stopMessageDetailSound];
//    [self stopMusicPlayer];
//    
//    if (self.keybordHeight != 0) {
//        self.keybordHeight =0;
//    }
//    [self setFrameWhenAnimationed : message_view_Status_Middle];
//    //我自己
//    if ([[CPUIModelManagement sharedInstance] isMySelfWithUserName:member.userName])
//    {
//        [self turnToMySelfProfile];
//    }
//    //couple
//    else if([[CPUIModelManagement sharedInstance] isMyCoupleWithUserName:member.userName])
//    {
//        [self turnToFriendProfileWithUserInfo:userInfo];
//    }
//    else {
//        //好友
//        if (userInfo) {
//            [self turnToFriendProfileWithUserInfo:userInfo];
//        }
//        //陌生人
//        else {
//            if (!userInfo)
//            {
//                userInfo = [[CPUIModelUserInfo alloc] init];
//                [userInfo setName:member.userName];
//                [userInfo setNickName:member.nickName];
//                [userInfo setHeaderPath:member.headerPath];
//            }
//            [self turnToContactProfileWithCPUIModelUserInfo:userInfo];
//        }
//    }
//    keybordNeedResetFlag = NO;
}


// 移动tableView
-(void) movedMessageTableView : (UITableView *) tableView
{
    
    [self.keybordView resetFrame];
    [self.keybordView hidePhotoSwitch];
}
// 点击tableView Cell
-(void) clickMessageTableView : (UITableView *) tableView
{
    
    [self.keybordView resetFrame];
    [self.keybordView hidePhotoSwitch];
}


#pragma mark RecentView
-(void)stopMusicPlayer
{
    [[MusicPlayerManager sharedInstance] stop];
//    UIButton *btnAudio = (UIButton *)[self.recentView viewWithTag:btnAudioTag];
//    if (btnAudio) {
//        [btnAudio setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white.png"] forState:UIControlStateNormal];
//        [btnAudio setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey.png"] forState:UIControlStateHighlighted];
//    }
}
-(void)musicPlayerDidFinishPlaying:(MusicPlayerManager *) player playerName:(NSString *)name{
    
//    UIButton *btnAudio = (UIButton *)[self.recentView viewWithTag:btnAudioTag];
//    if (self.modelMessageGroup.memberList.count > 0) {
//        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
//        CPUIModelUserInfo *userInfo = member.userInfo;
//        NSString *amrPath = userInfo.recentContent;
//        NSRange range = [amrPath rangeOfString:@"header"];
//        NSString *friendAmrPath = [[amrPath substringToIndex:range.location+range.length] stringByAppendingPathComponent:@"friendPath"];
//        NSString *wavPath = [[friendAmrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
//        if ([name isEqualToString:wavPath]) {
//            [btnAudio setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white.png"] forState:UIControlStateNormal];
//            [btnAudio setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey.png"] forState:UIControlStateHighlighted];
//        }
//        [self.recentView setAudioLength:-1];
//    }
    
//    self.detailViewController.canPlayMagic = YES;
}
-(void)palyAudio:(UIButton *)sender
{
    if (self.modelMessageGroup.memberList.count > 0) {
        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
        CPUIModelUserInfo *userInfo = member.userInfo;
        NSString *amrPath = userInfo.recentContent;
        NSString *wavPath;
        NSString *coupleWavPath;
        if ([userInfo.type integerValue] == USER_RELATION_TYPE_LOVER || [userInfo.type integerValue] == USER_RELATION_TYPE_MARRIED || [userInfo.type integerValue] == USER_RELATION_TYPE_COUPLE) {
            if (amrPath) {
                coupleWavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
                if (![[NSFileManager defaultManager] fileExistsAtPath:coupleWavPath]) {  // 转网络的amr－> wav
                    [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:coupleWavPath];
                }
            }
            if (userInfo.recentType == USER_RECENT_TYPE_AUDIO) {
                // NSString *wavPath = [[CoreUtils getDocumentPath] stringByAppendingPathComponent:@"/couple_audio_recent_wav.wav"];
                
                if ([[MusicPlayerManager sharedInstance] isPlaying]) {
                    [[MusicPlayerManager sharedInstance] stop];
                    //[self resetAudioLength];
                    [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white.png"] forState:UIControlStateNormal];
                    [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey.png"] forState:UIControlStateHighlighted];
                    self.detailViewController.canPlayMagic = YES;
                }else {
                    [self stopMessageDetailSound];
                    
                    [MusicPlayerManager sharedInstance].delegate = self;
                    [[MusicPlayerManager sharedInstance] playMusic:coupleWavPath playerName:coupleWavPath];
                    
                    [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_state_stop_little_white.png"] forState:UIControlStateNormal];
                    [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_state__stop_little_grey.png"] forState:UIControlStateHighlighted];
                    self.detailViewController.canPlayMagic = NO;
                }
                //                if ([self.singleProfileDelegate respondsToSelector:@selector(palyAudioFromSingleProfileView:)]) {
                //                    [self.singleProfileDelegate palyAudioFromSingleProfileView:sender];
                //                }
            }
        }else {
            if (userInfo.recentType == USER_RECENT_TYPE_AUDIO) {
                
                if (amrPath) {
                    NSRange range = [amrPath rangeOfString:@"header"];
                    NSString *friendAmrPath = [[amrPath substringToIndex:range.location+range.length] stringByAppendingPathComponent:@"friendPath"];
                    wavPath = [[friendAmrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
                    [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
                    
                }
                if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
                    if ([[MusicPlayerManager sharedInstance] isPlaying]) {
                        [[MusicPlayerManager sharedInstance] stop];
                        
                        [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white.png"] forState:UIControlStateNormal];
                        [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey.png"] forState:UIControlStateHighlighted];
//                        [self.recentView setAudioLength:-1];
                        self.detailViewController.canPlayMagic = YES;
                    }else {
                        [self stopMessageDetailSound];
                        
                        [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_state_stop_little_white.png"] forState:UIControlStateNormal];
                        [sender setBackgroundImage:[UIImage imageNamed:@"btn_im_state__stop_little_grey.png"] forState:UIControlStateHighlighted];
                        
                        
                        [MusicPlayerManager sharedInstance].delegate = self;
                        [[MusicPlayerManager sharedInstance] playMusic:wavPath playerName:wavPath];
                        
                        
                        self.detailViewController.canPlayMagic = NO;
                        
                        
                    }
                }
            }
        }
    }
    
}
#pragma mark 点击头像跳转

-(void)turnToFriendProfileWithUserInfo:(CPUIModelUserInfo *)friendUserInfo
{
//    SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfoFromIM:friendUserInfo];
//    [self.navigationController pushViewController:singleIndependentProfile animated:YES];
//    
//    msgGroupNeedRemove = YES;
}
//到自己的profile
-(void)turnToMySelfProfile
{
//    HomePageSelfProfileViewController *myProfileView = [[HomePageSelfProfileViewController alloc] init];
//    [self.navigationController pushViewController:myProfileView animated:YES];
//    
//    keybordNeedResetFlag = YES;
//    self.msgGroupNeedRemove = YES;
}
//跳转到陌生人profile
-(void)turnToContactProfileWithCPUIModelUserInfo:(CPUIModelUserInfo *)userInfo
{
//    [self stopMessageDetailSound];
//    UserInforModel *userInfor = [[UserInforModel alloc] initUserInfor];
//    userInfor.headerPath = userInfo.headerPath;
//    userInfor.nickName = userInfo.nickName;
//    userInfor.fullName = userInfo.fullName;
//    userInfor.userName = userInfo.name;
//    userInfor.telPhoneNumber = userInfo.mobileNumber;
//    AddContactWithProfileViewController *profile = [[AddContactWithProfileViewController alloc] initAddContactWithUserInfor:userInfor];
//    [self.navigationController pushViewController:profile animated:YES];
//    
//    keybordNeedResetFlag = YES;
//    self.msgGroupNeedRemove = YES;
}
-(void)turnToContactProfileWithUserInfoModel:(UserInforModel *)userInfo
{
//    AddContactWithProfileViewController *profile = [[AddContactWithProfileViewController alloc] initAddContactWithUserInfor:userInfo];
//    [self.navigationController pushViewController:profile animated:YES];
//    
//    keybordNeedResetFlag = YES;
//    self.msgGroupNeedRemove = YES;
}
#pragma mark ActionSheetDelegate
#pragma mark AlertViewDelegate
@end
