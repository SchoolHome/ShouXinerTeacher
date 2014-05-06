//
//  MutilIMViewController.m
//  iCouple
//
//  Created by qing zhang on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBMutilIMViewController.h"
#import "GroupIndependentProfileViewController.h"
#import "BBMembersInMsgGroupViewController.h"

@interface BBMutilIMViewController ()

@end

@implementation BBMutilIMViewController

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
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"modifyGroupNameDic" options:0 context:@""];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"addFavoriteGroupDic" options:0 context:@""];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"quitGroupDic" options:0 context:@""];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"removeGroupMemDic" options:0 context:@""];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"modifyGroupNameDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"addFavoriteGroupDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"quitGroupDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"removeGroupMemDic"];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *array = [NSArray arrayWithArray:self.modelMessageGroup.memberList];;
    NSString *title = @"";
    int i = 0;
    for (CPUIModelUserInfo *user in array) {
        if (![user.nickName isEqualToString:[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName]) {
            if (user.nickName == nil || [user.nickName isEqualToString:@""]) {
                continue;
            }
            if (i == 2) {
                break;
            }
            i++;
            title = [NSString stringWithFormat:@"%@ %@",title,user.nickName];
        }
    }
    
    self.title = [NSString stringWithFormat:@"%@等",title];
//    if (self.nickName) {
//        [self.nickName removeFromSuperview];
//    }
    UIImageView *imageviewSex = (UIImageView *)[self.view viewWithTag:imageviewSexTag];
    if (imageviewSex) {
        [imageviewSex removeFromSuperview];
    }
    //群profile
//    self.profileView = [[GroupProfileView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 460+upHidedPartInStatusMid) andProfileType:[self.modelMessageGroup.type integerValue] andModelMessageGroup:self.modelMessageGroup];
//    self.profileView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
////    [self.mainBGView addSubview:self.profileView];
//    self.groupProfileView = (GroupProfileView *)self.profileView;
//    self.groupProfileView.profileViewDelegate = self;
//    self.groupProfileView.groupProfileDelegate = self;
    
    //群头像
    
    [self.imageviewHeadImg setBackImage:[self returnCircleHeadImg]];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"ZJZBack"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add setFrame:CGRectMake(0.0f, 7.0f, 30.0f, 30.0f)];
    [add setBackgroundImage:[UIImage imageNamed:@"ZJZAddPeople"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:add];
}

-(void) backClick{
//    [self.navigationController popViewControllerAnimated:YES];
    [self .navigationController popToRootViewControllerAnimated:YES];
}

-(void) add{
    BBMembersInMsgGroupViewController *c = [[BBMembersInMsgGroupViewController alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.modelMessageGroup.memberList];
    [c setMembers:array andMsgGroup:self.modelMessageGroup];
    [self.navigationController pushViewController:c animated:YES];
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
    self.modelMessageGroup = [CPUIModelManagement sharedInstance].userMsgGroup;
    [self.groupProfileView refreshGroupProfileContent];
}
//Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    self.groupProfileView.modelMessageGroup = self.modelMessageGroup;
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        
        
        switch ([CPUIModelManagement sharedInstance].userMsgGroupTag) {
            case UPDATE_USER_GROUP_TAG_DEFAULT:{
                //[self refreshDictonary];
                [self.groupProfileView refreshGroupProfileContent];
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND:{
                
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT:{
                
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_INSERT_END:{
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_LIST_RELOAD:{
            }
                break;
            case UPDATE_USER_GROUP_TAG_MEM_LIST:{
                //[self refreshDictonary];
                [self.groupProfileView recoverGroupPrifleDeleteStatus];
                [self.groupProfileView refreshGroupProfileContent];
                
            }
                break;
            case UPDATE_USER_GROUP_TAG_MSG_GROUP:{
                if ([self.modelMessageGroup.type integerValue]== MSG_GROUP_UI_TYPE_CONVER)
                {
                    [self.loadingView close];
                    self.loadingView = nil;
                    [self.groupProfileView changeMutilToGroup];
                }
                [self.groupProfileView refreshGroupProfileContent];
            }
                break;
            case UPDATE_USER_GROUP_TAG_ONLY_REFRESH:{
                
            }
                break;
                //退群
            case UPDATE_USER_GROUP_TAG_DEL:
            {
                NSMutableDictionary *groupId = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]];
                NSMutableDictionary *groupName = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic]];
                if (groupId) {
                    //这个ID是否在字典中
                    if ([groupId objectForKey:[self.modelMessageGroup.msgGroupID stringValue]]) {
                        if (groupName) {
                            //将图片设置为可用状态
                            [groupName setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:[groupId objectForKey:[self.modelMessageGroup.msgGroupID stringValue]]];
                        }
                        //删除对应groupID的图片信息
                        [groupId removeObjectForKey:[self.modelMessageGroup.msgGroupID stringValue]];
                    }
                    
                }
                [[NSUserDefaults standardUserDefaults] setValue:groupId forKey:GroupIdWithNameDic];
                [[NSUserDefaults standardUserDefaults] setValue:groupName forKey:GroupPicNameWithStatusDic];
                if (quitGroupFlag) {
                    [self backToHome:nil];
                    quitGroupFlag = NO;
                }else {
                    UIAlertView *alertViewQuit = [[UIAlertView alloc] initWithTitle:nil message:@"你被请出去了" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    alertViewQuit.tag = quitGroupAlertTag;
                    [alertViewQuit show];
                }
                
            }
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"modifyFriendTypeDic"])
    {
        //[self refreshDictonary];
    }else if ([keyPath isEqualToString:@"deleteFriendDic"])
    {
        //[self refreshDictonary];
    }else if ([keyPath isEqualToString:@"modifyGroupNameDic"]) {
        [self.loadingView close];
        self.loadingView = nil;
        if ([[[CPUIModelManagement sharedInstance].modifyGroupNameDic objectForKey:group_manage_dic_res_code] integerValue] == RESPONSE_CODE_SUCESS ) {
            [[HPTopTipView shareInstance] showMessage:@"修改群名成功" duration:1.5f];
            
        }else {
            [[HPTopTipView shareInstance] showMessage:[[CPUIModelManagement sharedInstance].addFavoriteGroupDic objectForKey:group_manage_dic_res_desc] duration:3.5f];
        }
    }else if([keyPath isEqualToString:@"addFavoriteGroupDic"])
    {
        [self.loadingView close];
        self.loadingView = nil;
        if ([[[CPUIModelManagement sharedInstance].addFavoriteGroupDic objectForKey:group_manage_dic_res_code] integerValue] == RESPONSE_CODE_SUCESS ) {
            [[HPTopTipView shareInstance] showMessage:@"操作成功" duration:1.5f];
            [self.groupProfileView closeView];
        }else {
            [[HPTopTipView shareInstance] showMessage:[[CPUIModelManagement sharedInstance].addFavoriteGroupDic objectForKey:group_manage_dic_res_desc] duration:3.5f];
        }
    }
    //退群
    else if([keyPath isEqualToString:@"quitGroupDic"]){
        [self.loadingView close];
        self.loadingView = nil;
        if ([[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_code]integerValue]== RESPONSE_CODE_SUCESS) {
            
            [[HPTopTipView shareInstance] showMessage:@"操作成功" duration:2.0f];
        }else {
            [[HPTopTipView shareInstance] showMessage:[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_desc] duration:3.5f];
        }
    }
    //删除群成员
    else if ([keyPath isEqualToString:@"removeGroupMemDic"])
    {
        [self.loadingView close];
        self.loadingView = nil;
        if ([[[CPUIModelManagement sharedInstance].removeGroupMemDic objectForKey:group_manage_dic_res_code]integerValue]== RESPONSE_CODE_SUCESS) {
            
            [[HPTopTipView shareInstance] showMessage:@"操作成功" duration:1.5f];
        }else {
            [[HPTopTipView shareInstance] showMessage:[[CPUIModelManagement sharedInstance].removeGroupMemDic objectForKey:group_manage_dic_res_desc] duration:3.5f];
        }
        
    }
    
}

#pragma mark GroupProfile
//刷新groupProfile的成员数组
-(void)refreshDictonary
{
    if (self.groupProfileView.groupMembers && self.groupProfileView.groupMembers.allKeys.count > 0) {
        [self.groupProfileView.groupMembers removeAllObjects];
    }
    int oldTag = 0;
    
    
    NSMutableArray *memberArr = [[NSMutableArray alloc] init];
    
    if (self.modelMessageGroup.memberList.count == 0) {
        [self.groupProfileView.groupMembers setValue:memberArr forKey:[NSString stringWithFormat:@"%d",0]];
    }else {
        for (int i = 0 ; i < self.modelMessageGroup.memberList.count; i++) {
            CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:i];
            
            if (oldTag != i/4+1 && i != 0) {
                [self.groupProfileView.groupMembers setValue:[NSMutableArray arrayWithArray:memberArr] forKey:[NSString stringWithFormat:@"%d",i/4-1]];
                [memberArr removeAllObjects];
            }
            [memberArr addObject:member];
            
            if (i == self.modelMessageGroup.memberList.count - 1 ) {
                [self.groupProfileView.groupMembers setValue:memberArr forKey:[NSString stringWithFormat:@"%d",i/4]];
                
            }
            oldTag = i/4+1;
        }
    }
    
    
}

#pragma mark Method
-(void)setFrameWhenAnimationed:(NSUInteger)type
{
    [super setFrameWhenAnimationed:type];
    if (type != message_view_Status_Middle) {
        self.groupProfileView.imageviewMemberNameBG.alpha = 0.f;
    }
}

#pragma mark GroupProfileDelegate
//群profile点击头像跳转
-(void)turnToIndependentProfileView:(CPUIModelUserInfo *)memberUserInfo
{
    
    if (memberUserInfo) {
        SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:memberUserInfo];
        [self.navigationController pushViewController:singleIndependentProfile animated:YES];
    }
    self.msgGroupNeedRemove = YES;
}
//群profile跳转到陌生人profile
-(void)turnToContactProfileDelegate:(CPUIModelUserInfo *)userInfo
{
    [self turnToContactProfileWithCPUIModelUserInfo:userInfo];
}
//跳转到群独立profile
-(void)turnToGroupindependentProfile:(CPUIModelMessageGroup *)msgGroup
{
    GroupIndependentProfileViewController *groupIndependentProfile = [[GroupIndependentProfileViewController alloc] initWithMsgGroupFromIM:msgGroup];
    [self.navigationController pushViewController:groupIndependentProfile animated:YES];
    self.msgGroupNeedRemove = YES;
}
//退群
-(void)quitGroup:(CPUIModelMessageGroup *)messageGroup
{
    quitGroupFlag = YES;
    [self.detailViewController stopSound];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
    }else {
        CustomAlertView *customAlert = [[CustomAlertView alloc] init];
        if (!self.loadingView) {
            self.loadingView = [customAlert showLoadingMessageBox:@"稍等哦..." withTimeOut:TimeOut];
            //self.loadingView.delegate = self;
        }
        [[CPUIModelManagement sharedInstance] quitGroupWithGroup:messageGroup];
    }
}
//删除群成员
-(void)deleteGroupMember:(CPUIModelMessageGroup *)messageGroup andMemberArr:(NSArray *)memberArr
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
    }else {
        CustomAlertView *customAlert = [[CustomAlertView alloc] init];
        if (!self.loadingView) {
            self.loadingView = [customAlert showLoadingMessageBox:@"正在请Ta离开，稍等哦..." withTimeOut:TimeOut];
            //self.loadingView.delegate = self;
        }
        [[CPUIModelManagement sharedInstance] removeGroupMemWithUserNames:memberArr andGroup:messageGroup];
    }
}
//添加群
-(void)addFavoriteGroup:(CPUIModelMessageGroup *)messageGroup andGroupName : (NSString *)groupName
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
    }else {
        CustomAlertView *customAlert = [[CustomAlertView alloc] init];
        if (!self.loadingView) {
            self.loadingView = [customAlert showLoadingMessageBox:@"正在保存..." withTimeOut:TimeOut];
            //self.loadingView.delegate = self;
        }
        [[CPUIModelManagement sharedInstance] addFavoriteGroupWithGroup:messageGroup andName:groupName];
    }
}
//修改群名
-(void)modifyFavoriteGroupName:(CPUIModelMessageGroup *)messageGroup andGroupName: (NSString *)groupName
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
    }else {
        CustomAlertView *customAlert = [[CustomAlertView alloc] init];
        if (!self.loadingView) {
            self.loadingView = [customAlert showLoadingMessageBox:@"正在保存..." withTimeOut:TimeOut];
            // self.loadingView.delegate = self;
        }
        [[CPUIModelManagement sharedInstance] modifyFavoriteGroupNameWithGroup:self.modelMessageGroup withGroupName:groupName];
    }
}
#pragma mark touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    [self.profileView tapByController];
    
    if (self.currentStatus == message_view_Status_Middle && [self isInUpBGRectOrInHeadImgRect:point] != 1 && !self.isMoved) {
        [UIView animateWithDuration:0.2f animations:^
         {
             [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
             self.groupProfileView.imageviewMemberNameBG.alpha = 0.f;
             // self.groupProfileView.imageviewMemberNameBG.hidden = YES;
         }];
    }
    
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (point.y-beginPoint.y>0 ) {
        [UIView animateWithDuration:0.2f animations:^
         {
             [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
             
             self.groupProfileView.imageviewMemberNameBG.alpha = 0.f;
             // self.groupProfileView.imageviewMemberNameBG.hidden = YES;
         }];
        
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.currentStatus == message_view_Status_Middle) {
        [UIView animateWithDuration:0.2f animations:^
         {
             [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
             self.groupProfileView.imageviewMemberNameBG.alpha = 1.f;
         }];
    }else {
        self.groupProfileView.imageviewMemberNameBG.alpha = 0.f;
    }
}
#pragma mark AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == deleteFriendsAlertTag && buttonIndex == 0) {
        if (self.modelMessageGroup.memberList.count > 0) {
            CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
            CPUIModelUserInfo *userInfo = member.userInfo;
            if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
                [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
            }else {
                [[CPUIModelManagement sharedInstance] deleteFriendRelationWithUserName:userInfo.name];
                CustomAlertView *customAlert = [[CustomAlertView alloc] init];
                if (!self.loadingView) {
                    self.loadingView = [customAlert showLoadingMessageBox:@"稍等哦..." withTimeOut:TimeOut];
                    // self.loadingView.delegate = self;
                }
            }
        }
    }else if(alertView.tag == quitGroupAlertTag)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        quitGroupFlag = NO;
    }
    
    
}
#pragma mark Noti
- (void)keyboardWillShow:(NSNotification *)notification
{
    UITextField *textfieldChangeName = (UITextField *)[self.groupProfileView viewWithTag:TextfiledChangeGroupNameTag];
    UITextField *textfiledGroupName = (UITextField *)[self.groupProfileView viewWithTag:TextfiledGroupNameTag];
    if ([textfieldChangeName isFirstResponder]) {
        NSDictionary *info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        if (kbSize.height == 216) {
            self.groupProfileView.buttonView.center = CGPointMake(160, 205);
        }else if(kbSize.height == 252)
        {
            self.groupProfileView.buttonView.center = CGPointMake(160, 195);
        }
    }else if([textfiledGroupName isFirstResponder]){
        
    }else {
        [super keyboardWillShow:notification];
    }
}
-(void)keybordWillDisappear:(NSNotification *)notification
{
    
    UITextField *textfieldChangeName = (UITextField *)[self.groupProfileView viewWithTag:TextfiledChangeGroupNameTag];
    if ([textfieldChangeName isFirstResponder]) {
        self.groupProfileView.buttonView.center = CGPointMake(160, 205);
    }else {
        [super keybordWillDisappear:notification];
    }
}
@end
