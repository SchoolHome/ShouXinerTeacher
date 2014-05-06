//
//  GroupIndependentProfileViewController.m
//  iCouple
//
//  Created by qing zhang on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupIndependentProfileViewController.h"
#import "CPUIModelMessageGroupMember.h"
#import "SingleIndependentProfileViewController.h"
#import "AddContactViewController.h"
#import "MutilIMViewController.h"

#define tableviewFootTag 1101
#define quitBtnTag 1102
#define quitTextTag 1103
#define quitGroupAlertTagIndependent 1104

#define GroupPicNameWithStatusDic @"groupPicNameDic"
#define GroupIdWithNameDic @"groupIdDic"
#define PicturenUsed 1
#define PictureUnUsed 2
@interface GroupIndependentProfileViewController ()
{
    //群头像
    UIImageView *groupHeadImg;
    
    //人数
    UILabel *groupNumber;
    UILabel *textPeople;
    
    //群名
    UILabel *groupNameText;
    
    //群成员
    UIScrollView *groupMembers;
    
    //标示是否是自己主动退群
    BOOL quitGroupFlag;
}
@property (nonatomic , strong) CPUIModelMessageGroup *messageGroup;
@end

@implementation GroupIndependentProfileViewController
@synthesize messageGroup;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
//大家进来时初始化
-(id)initWithMsgGroup:(CPUIModelMessageGroup *)msgGroup
{
    self = [super init];
    if (self) {
        self.messageGroup = msgGroup;
         [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:self.messageGroup];
    }
    return self;
}
-(id)initWithMsgGroupFromIM:(CPUIModelMessageGroup *)msgGroup
{
    self = [super init];
    if (self) {
        self.messageGroup = msgGroup;
       
        
        self.comeFromIM = YES;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    groupHeadImg = [[UIImageView alloc] initWithFrame:CGRectMake(125, 154, 70, 70)];
    [groupHeadImg setImage:[UIImage imageNamed:@"profile_headpic_group.png"]];
//    [groupHeadImg setBackImage:[UIImage imageNamed:@"profile_headpic_group.png"]];
//    [groupHeadImg setBorderWidth:0.f];
//    [groupHeadImg setCycleImage:[UIImage imageNamed:@"headpic_index_70x70.png"]];
    [self.view addSubview:groupHeadImg];
	// Do any additional setup after loading the view.
    
    groupMembers = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 253, 320, 207)];
    groupMembers.backgroundColor = [UIColor clearColor];
    [self.view addSubview:groupMembers];
    
    [self refreshGroupData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

}
-(void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"quitGroupDic" options:0 context:nil];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupTag" options:0 context:nil];
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"quitGroupDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupTag"];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        switch ([CPUIModelManagement sharedInstance].userMsgGroupTag) {
                //退群
            case UPDATE_USER_GROUP_TAG_DEL:
            {
                NSMutableDictionary *groupId = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]];
                NSMutableDictionary *groupName = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic]];
                if (groupId) {
                    //这个ID是否在字典中
                    if ([groupId objectForKey:[self.messageGroup.msgGroupID stringValue]]) {
                        if (groupName) {
                            //将图片设置为可用状态
                            [groupName setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:[groupId objectForKey:[self.messageGroup.msgGroupID stringValue]]];
                        }
                        //删除对应groupID的图片信息
                        [groupId removeObjectForKey:[self.messageGroup.msgGroupID stringValue]];    
                    }
                    
                }
                [[NSUserDefaults standardUserDefaults] setValue:groupId forKey:GroupIdWithNameDic];
                [[NSUserDefaults standardUserDefaults] setValue:groupName forKey:GroupPicNameWithStatusDic];
                if (quitGroupFlag) {
                    [self.loadingView close];
                    self.loadingView = nil;
                    
                    for (HomeMainViewController *homeMain in self.navigationController.viewControllers) {
                        if ([homeMain isKindOfClass:[HomeMainViewController class]]) {
                            if ( [self.messageGroup isMsgMultiConver]) {
                                [homeMain scrollToRect:ContactFriend_NormalFriend withAnimation:NO];
                                [self.navigationController popToViewController:homeMain animated:YES];   
                            }else if([self.messageGroup isMsgConverGroup])
                            {
                                [homeMain scrollToRect:ContactFriend_CloseFriend withAnimation:YES];
                                [self.navigationController popToViewController:homeMain animated:YES];
                            }
                            return;
                        }
                    }
                    quitGroupFlag = NO;
                }else {
                    UIAlertView *alertViewQuit = [[UIAlertView alloc] initWithTitle:nil message:@"你被请出去了" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    alertViewQuit.tag = quitGroupAlertTagIndependent;
                    [alertViewQuit show];
                }
                
            }
                break;
            case UPDATE_USER_GROUP_TAG_MEM_LIST:{
                [self refreshGroupData];
                [self refreshGroupMembers];
                
            }
                break;
        }
    }
    //退群
    else if([keyPath isEqualToString:@"quitGroupDic"]){
        [self.loadingView close];
        self.loadingView = nil;
        if ([[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_code]integerValue]== RESPONSE_CODE_SUCESS) {
            
            [[HPTopTipView shareInstance] showMessage:@"操作成功" duration:1.5f];
        }else {
            [[HPTopTipView shareInstance] showMessage:[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_desc] duration:3.5f]; 
        }
    }else if ([keyPath isEqualToString:@"createMsgGroupTag"]) {
        if ([CPUIModelManagement sharedInstance].createMsgGroupTag == RESPONSE_CODE_SUCESS) {
            CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
            if ([currMsgGroup isMsgMultiGroup]) {   // 群
                MutilIMViewController *mutil = [[MutilIMViewController alloc] init:currMsgGroup];
                [self.navigationController pushViewController:mutil animated:YES];
                return;
            }
        }else {
            
        }
    }
}
#pragma mark refreshData
-(void)refreshGroupData
{
    if (self.messageGroup) {
        
    
        int peopleNumber = 0;
        for (CPUIModelMessageGroupMember *member in self.messageGroup.memberList) {
            if (![member isHiddenMember]) {
                peopleNumber++;
            }
        }
        //根据groupID获取背景图
        [self.upBGImage setImage:[UIImage imageNamed:[self getGroupAndMutilPictureNameWithGroupID]]];
        //群名
        if (!groupNameText) {
            groupNameText = [[UILabel alloc] initWithFrame:CGRectMake(80, 227, 160, 16)];
            groupNameText.textColor = [UIColor colorWithHexString:@"#ffffff"];
            groupNameText.font = [UIFont boldSystemFontOfSize:15.f];
            groupNameText.backgroundColor = [UIColor clearColor];
            groupNameText.textAlignment = UITextAlignmentCenter;
            groupNameText.shadowColor = [UIColor colorWithRed:9/255.f green:9/255.f blue:11/255.f alpha:0.5f];
            groupNameText.shadowOffset = CGSizeMake(0.f, -1.f);
            [self.view addSubview:groupNameText];
        }
        groupNameText.text = self.messageGroup.groupName;
        
        //人数
        if (!groupNumber) {
            groupNumber = [[UILabel alloc] initWithFrame:CGRectMake(3, 18, 40, 30)];
            groupNumber.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
            groupNumber.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.f];
            groupNumber.shadowColor = [UIColor colorWithRed:9/255.f green:9/255.f blue:11/255.f alpha:0.4f];
            groupNumber.shadowOffset = CGSizeMake(0.f, -1.f);
            groupNumber.textAlignment = UITextAlignmentRight;
            groupNumber.backgroundColor = [UIColor clearColor];
            [groupHeadImg addSubview:groupNumber];        
        }
        groupNumber.text = [NSString stringWithFormat:@"%d",peopleNumber+1];    
    //    CGSize size = CGSizeMake(41.0f,9999.0f);
    //    CGSize stringSize = [groupNumber.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:36.f] constrainedToSize:size lineBreakMode:groupNumber.lineBreakMode];
    //    groupNumber.frame = CGRectMake(10.f, 2.f, 41.f, stringSize.height / 2.0f + 5.0f);
        
        if (!textPeople) {
            textPeople = [[UILabel alloc] initWithFrame:CGRectMake(44, 36, 12, 12)];
            textPeople.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
            textPeople.shadowColor = [UIColor colorWithRed:9/255.f green:9/255.f blue:11/255.f alpha:0.5f];
            textPeople.shadowOffset = CGSizeMake(0.f, -0.5f);        
            textPeople.font = [UIFont systemFontOfSize:12.f];
            textPeople.backgroundColor = [UIColor clearColor];
            textPeople.text = @"人";
            [groupHeadImg addSubview:textPeople];
        }
        
        //刷新群列表
        [self refreshGroupMembers];
    }
}
-(void)refreshGroupMembers{
    for (UIView *view in groupMembers.subviews) {
        if ([view isKindOfClass:[GroupUserItemView class]]) {
            [view removeFromSuperview];
        }else if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    int i = 0;
    if (self.messageGroup.memberList > 0) {
        GroupUserItemView *userItem = nil;
        for (CPUIModelMessageGroupMember *member in self.messageGroup.memberList) {
            //2012.8.6 加入是否是隐藏成员判断
            if (![member isHiddenMember]) {
                int row = i/4;
                int col = i%4;
                userItem = [[GroupUserItemView alloc] initGroupUserItem:member];
                userItem.frame = CGRectMake(20.0f + 75.0f * col, 15.0f + 85.0f *row, 75.0f, 85.0f);
                userItem.delegate = self;
                userItem.delButton.frame = CGRectMake(userItem.frame.origin.x - 23.0f, userItem.frame.origin.y - 23.0f, 47.5f, 47.5f);
                [groupMembers addSubview:userItem];
                [groupMembers addSubview:userItem.delButton];
                
                i++;     
            }
            
        }
        //int row = [self.modelMessageGroup.memberList count] / 4;
        int row = i / 4;
        if (i%4 == 0) {
            row -= 1;
        }
        UIView *scrollviewFoot = [self.view viewWithTag:tableviewFootTag];
        if (scrollviewFoot) {
            scrollviewFoot.center = CGPointMake(160.f, row*85.0f + 145.0f);    
            
        }else {
            //群成员tableview
            scrollviewFoot = [[UIView alloc] initWithFrame:CGRectMake(0, row*85.0f + 105.0f, 320.f, 80.f)];
            scrollviewFoot.tag = tableviewFootTag;
            scrollviewFoot.backgroundColor = [UIColor clearColor];
            UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            //[quitBtn setTitleColor:[UIColor colorWithRed:67/255.f green:67/255.f blue:67/255.f alpha:1.f] forState:UIControlStateNormal];
            [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            quitBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
            quitBtn.titleLabel.textAlignment = UITextAlignmentCenter;
            [quitBtn setFrame:CGRectMake(106.f, 10.f, 107.f, 36.5f)];
            quitBtn.tag = quitBtnTag;
            [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_pet_downloadall.png"] forState:UIControlStateNormal];
            [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_pet_downloadallpress.png"] forState:UIControlStateHighlighted];
            [quitBtn addTarget:self action:@selector(quitGroup:) forControlEvents:UIControlEventTouchUpInside];
            [scrollviewFoot addSubview:quitBtn];
            
            UILabel *quitText = [[UILabel alloc] initWithFrame:CGRectMake(90.f, 56.5f, 130, 10.f)];
            quitText.font = [UIFont systemFontOfSize:10.f];
            quitText.textColor = [UIColor colorWithRed:185/255.f green:185/255.f blue:185/255.f alpha:1.f];
            quitText.textAlignment =  UITextAlignmentCenter;
            quitText.tag = quitTextTag;
            quitText.backgroundColor = [UIColor clearColor];
            [scrollviewFoot addSubview:quitText];
            
            [groupMembers addSubview:scrollviewFoot];
        }
        UIButton *quitBtn = (UIButton *)[groupMembers viewWithTag:quitBtnTag];
        UILabel *quitText = (UILabel *)[groupMembers viewWithTag:quitTextTag];
        if ([self.messageGroup isMsgMultiGroup]) {
            [quitBtn setTitle:@"退出" forState:UIControlStateNormal];
            quitText.text = @"不再接收新消息，且清空记录";
        }
        groupMembers.contentSize = CGSizeMake(320.f,scrollviewFoot.frame.origin.y+scrollviewFoot.frame.size.height);
    }
}
#pragma mark method
//去聊天
-(void)goChat
{
    if (self.messageGroup) {
     [[CPUIModelManagement sharedInstance] createConversationWithUsers:nil andMsgGroups:[NSArray arrayWithObject:self.messageGroup] andType:CREATE_CONVER_TYPE_CLOSED];        
    }

}
//获取到图片
-(NSString *)getGroupAndMutilPictureNameWithGroupID
{
    NSString *msgGroupID = [self.messageGroup.msgGroupID stringValue];
    //没有群ID字典时
    if (![[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]) {
        NSMutableDictionary *groupIdWithGroupNameDic = [[NSMutableDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setValue:groupIdWithGroupNameDic forKey:GroupIdWithNameDic];
    }
    NSMutableDictionary *groupId = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]];
    //对应groupID有值的话直接取，没有的话则获取个新的
    if ([groupId objectForKey:msgGroupID]) {
        return [groupId objectForKey:msgGroupID];
    }else {
        //没有群名字典时
        NSDictionary *tempGroupPicNameWithStatusDic = [[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic];
        if (!tempGroupPicNameWithStatusDic||[tempGroupPicNameWithStatusDic count]==0) {
            NSMutableDictionary *groupNameDic = [[NSMutableDictionary alloc] init];
            for (int i = 1; i<6; i++) {
                NSString *str = [NSString stringWithFormat:@"pic_im_drlt00%d.jpg",i];
                [groupNameDic setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:str];
            }
            [[NSUserDefaults standardUserDefaults] setObject:groupNameDic forKey:GroupPicNameWithStatusDic];
        }
        
        NSMutableDictionary *groupName = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic]];
        //判断是否当前都是以用的图片
        if (![groupName.allValues containsObject:[NSNumber numberWithInt:PictureUnUsed]]) {
            //重置图片状态
            CPLogInfo(@"ResetPicStatus");
            for (NSString *strPicName in groupName.allKeys) {
                [groupName setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:strPicName];
            }
        }
        
        
        
        for (NSString *str in groupName.allKeys) {
            //如果取出来的是未使用
            if ([[groupName objectForKey:str] intValue] == PictureUnUsed) {
                //改变图片状态为已使用
                [groupName setValue:[NSNumber numberWithInt:PicturenUsed] forKey:str];
                //存入对应groupID的图片
                [groupId setValue:str forKey:msgGroupID];
                [[NSUserDefaults standardUserDefaults] setValue:groupId forKey:GroupIdWithNameDic];
                [[NSUserDefaults standardUserDefaults] setValue:groupName forKey:GroupPicNameWithStatusDic];
                return str;
            }
        }
    }
    
    return [NSString stringWithFormat:@"pic_im_drlt00%d.jpg",1];
    
}
//退群
-(void)quitGroup:(UIButton *)sender
{
    if ([CPUIModelManagement sharedInstance].sysOnlineStatus == SYS_STATUS_ONLINE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"以后不会再接收消息，确定退出么?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
        alert.delegate = self;
        [alert show];
    }else{
        [[HPTopTipView shareInstance] showMessage:@"当前网络未连接,请稍后再试"];
    }
    

}
#pragma mark gourpUserItemDelegate
-(void) clickGroupUserItem : (GroupUserItemView *) item{
        //GroupUserItemView *userItem = nil;

        
        CPUIModelUserInfo *oldUserInfo = item.member.userInfo;
        CPUIModelUserInfo *userInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:oldUserInfo.name];
        if (userInfo) {
            SingleIndependentProfileViewController *singleIndepedentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:userInfo];
            [self.navigationController pushViewController:singleIndepedentProfile animated:YES];
        }else {
            UserInforModel *userInfor = [[UserInforModel alloc] initUserInfor];
            [userInfor setHeaderPath:item.member.headerPath];
            [userInfor setNickName:item.member.nickName];
            [userInfor setUserName:item.member.userName];
            if (!item.member.mobileNumber) {
                [userInfor setTelPhoneNumber:item.member.userInfo.mobileNumber];
            }else {
                [userInfor setTelPhoneNumber:item.member.mobileNumber];
            }
            
            AddContactWithProfileViewController *profile = [[AddContactWithProfileViewController alloc] initAddContactWithUserInfor:userInfor];
            [self.navigationController pushViewController:profile animated:YES];
        }
    
}
#pragma mark AlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == quitGroupAlertTagIndependent) {
        for (HomeMainViewController *homeMain in self.navigationController.viewControllers) {
            if ([homeMain isKindOfClass:[HomeMainViewController class]]) {
                [homeMain scrollToRect:ContactFriend_CloseFriend];
                [self.navigationController popToViewController:homeMain animated:YES];
                return;
            }
        }
    }else {
        if (buttonIndex == 0) {
            quitGroupFlag = YES;
            if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
                [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
            }else {
                CustomAlertView *customAlert = [[CustomAlertView alloc] init];
                if (!self.loadingView) {
                    self.loadingView = [customAlert showLoadingMessageBox:@"稍等哦..." withTimeOut:TimeOut];
                }
                [[CPUIModelManagement sharedInstance] quitGroupWithGroup:messageGroup];
            }
        }    
    }
    
}
@end
