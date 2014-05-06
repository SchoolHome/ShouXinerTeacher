//
//  SingleIMViewController.m
//  iCouple
//
//  Created by qing zhang on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SingleIMViewController.h"
#import "SingleIndependentProfileViewController.h"
#import "CoupleBreakIcePageViewController.h"
@interface SingleIMViewController ()

@end

@implementation SingleIMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}
-(id)init : (CPUIModelMessageGroup *)messageGroup
{
    self = [super init:messageGroup];
    if (self) {

        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCoupleType:) name:@"ChooseCoupleNotification" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.modelMessageGroup.memberList > 0) {
        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
        CPUIModelUserInfo *userInfo = member.userInfo;
        
        //性别
        UIImageView *imageviewSex = (UIImageView *)[self.view viewWithTag:imageviewSexTag];
        if (!imageviewSex) {
            //213是nickname结束x坐标
            imageviewSex = [[UIImageView alloc] initWithFrame:CGRectMake(288, 412, 23.f, 23.f)];    
            imageviewSex.tag = imageviewSexTag;
            [self.view insertSubview:imageviewSex belowSubview:self.IMView];
        }
        if ([userInfo.sex integerValue] == USER_INFO_SEX_FEMALE) {
            [imageviewSex setImage:[UIImage imageNamed:@"im_profile_sex1.png"]];
        }else if([userInfo.sex integerValue] == USER_INFO_SEX_MALE)
        {
            [imageviewSex setImage:[UIImage imageNamed:@"im_profile_sex2.png"]];
        }
        
        
        
        //单人profile
        self.profileView = [[SingleProfileView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 460+upHidedPartInStatusMid) andProfileType:[self.modelMessageGroup.type integerValue] andModelMessageGroup:self.modelMessageGroup ];
        self.profileView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
        [self.mainBGView addSubview:self.profileView];    
        self.singleProfileView = (SingleProfileView *)self.profileView;
        self.singleProfileView.profileViewDelegate = self;  
        self.singleProfileView.singleProfileDelegate = self;
        [self.singleProfileView refreshSingleProfile:self.modelMessageGroup];
        
        
        
        //获取头像昵称
        [self.imageviewHeadImg setBackImage:[self returnCircleHeadImg]];
        
        [self refreshCoupleFlag];
        
       
        
    }

	// Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self refreshMsgGroup];
    [self getLoveMessage];
    if (self.modelMessageGroup.memberList > 0) {
        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
        CPUIModelUserInfo *userInfo = member.userInfo;

        if ([userInfo.type integerValue] == USER_RELATION_TYPE_COUPLE || [userInfo.type integerValue] == USER_RELATION_TYPE_MARRIED || [userInfo.type integerValue] == USER_RELATION_TYPE_LOVER) {
        }else {
        }
    }
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.modelMessageGroup.memberList > 0) {
        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
        CPUIModelUserInfo *userInfo = member.userInfo;
        
        if ([userInfo.type integerValue] == USER_RELATION_TYPE_COUPLE || [userInfo.type integerValue] == USER_RELATION_TYPE_MARRIED || [userInfo.type integerValue] == USER_RELATION_TYPE_LOVER) {
        }else {
        }
    }
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
-(void)refreshMsgGroup
{
    
    if ([CPUIModelManagement sharedInstance].userMsgGroup) {
      self.modelMessageGroup = [CPUIModelManagement sharedInstance].userMsgGroup;  
      [self.singleProfileView refreshSingleProfile:[CPUIModelManagement sharedInstance].userMsgGroup];
    }
    //self.modelMessageGroup = [CPUIModelManagement sharedInstance].userMsgGroup;
    //[self.singleProfileView refreshSingleProfile:[CPUIModelManagement sharedInstance].userMsgGroup];
    [self refreshCoupleFlag];
}
//Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.singleProfileView.modelMessageGroup = self.modelMessageGroup;
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        
        switch ([CPUIModelManagement sharedInstance].userMsgGroupTag) {
            case UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND:{
                [self performSelector:@selector(getLoveMessage) withObject:nil afterDelay:2.0];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MEM_LIST:{
                [self.singleProfileView refreshSingleProfile:[CPUIModelManagement sharedInstance].userMsgGroup];
            }
                break;
            default:
            {
            
            }
                break;
        }
    }
    //被删除
    else if ([keyPath isEqualToString:@"deleteFriendDic"])
    {
        if ([[[CPUIModelManagement sharedInstance].deleteFriendDic objectForKey:delete_friend_dic_res_code] integerValue] == RESPONSE_CODE_SUCESS) {
            [[HPTopTipView shareInstance] showMessage:@"Ta已经离开你的双双" duration:2.5f];
            
            [self backToHome:nil];
            [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:nil];
             
        }else {
            [[HPTopTipView shareInstance] showMessage:[[CPUIModelManagement sharedInstance].deleteFriendDic objectForKey:delete_friend_dic_res_desc] duration:1.5f];
        }
    }    
}

#pragma mark Method
//判断是否需要弹加couple成功动画
-(void)getLoveMessage
{
    CPUIModelMessageGroup *messageGroup = [CPUIModelManagement sharedInstance].coupleMsgGroup;
    if (messageGroup) {
        //遍历message查看是否有
        for (int i = (int)messageGroup.msgList.count-1; i>=0; i--) {
            CPUIModelMessage *message = [messageGroup.msgList objectAtIndex:i];
            if ([message.isReaded intValue] == MSG_READ_STATUS_IS_NOT_READ) {
                if (message.isMatchLoveMsg) {
                    NSString *msgID = [[NSUserDefaults standardUserDefaults] objectForKey:@"msgID"];
                    if (![msgID isEqualToString:[message.msgID stringValue]]) {

                        CoupleCompletedView *coupleComplete = [[CoupleCompletedView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 480.f) withType:message.msgText andCompletedDate:message.date];      
                        [[UIApplication sharedApplication].keyWindow addSubview:coupleComplete];                   
                        //刷新对应信息
                        [self refreshMsgGroup];                      
                    }
                    [[NSUserDefaults standardUserDefaults] setValue:[message.msgID stringValue] forKey:@"msgID"];
                    return;
                }
            }else {
                return;
            }
        }
    }    
}
-(void)refreshCoupleFlag
{
    if (self.modelMessageGroup.memberList > 0) {
        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
        CPUIModelUserInfo *userInfo = member.userInfo;
        //couple标示
        UIImageView *imageviewCoupleFlag = (UIImageView *)[self.imageviewHeadImg viewWithTag:CoupleFlagImageview];
        if ([userInfo.type integerValue] == USER_RELATION_TYPE_COUPLE || [userInfo.type integerValue] == USER_RELATION_TYPE_MARRIED || [userInfo.type integerValue] == USER_RELATION_TYPE_LOVER) {
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_home.png"] forState:UIControlStateNormal];
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_home_press.png"] forState:UIControlStateHighlighted];
            if (!imageviewCoupleFlag) {
                imageviewCoupleFlag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_im_heart_red.png"]];
                imageviewCoupleFlag.tag = CoupleFlagImageview;
                [imageviewCoupleFlag setFrame:CGRectMake(10.f, imageviewHeadImageInStatusMid-22.f, 22.f, 22.f)];
                [self.imageviewHeadImg addSubview:imageviewCoupleFlag];
            }                
        }else {
            if (imageviewCoupleFlag) {
                [imageviewCoupleFlag removeFromSuperview];
            }
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_backmsgwall.png"] forState:UIControlStateNormal];
            [self.buttonBack setBackgroundImage:[UIImage imageNamed:@"btn_backmsgwall_press.png"] forState:UIControlStateHighlighted];
        }
    }
}


#pragma mark ProfileDelegate
//播放profile中的音频关闭其他地方音频
-(void)palyAudioFromSingleProfileView:(UIButton *)sender
{
    [self stopMusicPlayer];
    [self.detailViewController stopSound];
}
//了解更多，进入对方独立profile
-(void)turnToFriendProfile:(CPUIModelUserInfo *)friendUserInfo
{
    [self turnToFriendProfileWithUserInfo:friendUserInfo];
}
//跳转到好友Couple独立profile或陌生人profile
-(void)turnToFriendCoupleProfile:(CPUIModelUserInfo *)coupleUserInfo
{
    //进自己的profile
    if ([[CPUIModelManagement sharedInstance] isMySelfWithUserName:coupleUserInfo.coupleAccount]) {
        [self turnToMySelfProfile];
    } else {
        CPUIModelMessageGroup *group = [[CPUIModelManagement sharedInstance]getMsgGroupWithUserName:coupleUserInfo.coupleAccount];
        if (group) {
            CPUIModelUserInfo *friendCoupleUserInfo;
            if (!coupleUserInfo.coupleUserInfo) {
                friendCoupleUserInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:coupleUserInfo.coupleAccount];    
            }else {
                friendCoupleUserInfo = coupleUserInfo.coupleUserInfo;
            }
            [self turnToFriendProfile:friendCoupleUserInfo];
        }else {
            UserInforModel *userInfor = [[UserInforModel alloc] initUserInfor];
            userInfor.headerPath = coupleUserInfo.selfCoupleHeaderImgPath;
            userInfor.nickName = coupleUserInfo.coupleNickName;
            userInfor.fullName = coupleUserInfo.fullName;
            userInfor.userName = coupleUserInfo.coupleAccount;
            userInfor.telPhoneNumber = coupleUserInfo.mobileNumber;
            [self turnToContactProfileWithUserInfoModel:userInfor];

        }        
    }
}
@end
