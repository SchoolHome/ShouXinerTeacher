//
//  BBZJZViewController.m
//  teacher
//
//  Created by ZhangQing on 14-3-12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBZJZViewController.h"
#import "ContactsViewController.h"
#import "MutilMsgGroupViewController.h"
#import "BBSingleIMViewController.h"
#import "BBMutilIMViewController.h"
#import "XiaoShuangIMViewController.h"
#import "SystemIMViewController.h"
#import "ShuangShuangTeamViewController.h"
#import "BBServiceAccountViewController.h"
#import "BBServiceMessageDetailViewController.h"


#import "BBNotifyMessageGroupCell.h"
//shouxin version 4
#import "BBGroupModel.h"

//notifyMessage change
#import "CPUIModelMessageGroup.h"
#import "CPUIModelManagement.h"
#import "CPDBModelNotifyMessage.h"
#import "CPDBManagement.h"


//


@interface BBZJZViewController ()
{
    NSInteger listType;
    //是否请求过班级列表
    BOOL isRequestClassList;
    
    UIButton *segementBtn;
    
    CPDBModelNotifyMessage *tempCacheNotifyMsg;
}
@property (nonatomic, strong)NSArray *tableviewDisplayDataArray;
@property (nonatomic, strong) NSArray *classModels; //班级
@property (nonatomic , strong)BBMessageGroupBaseTableView *messageListTableview;
@property (nonatomic , strong)UISearchBar *messageListTableSearchBar;
@end

@implementation BBZJZViewController
@synthesize tableviewDisplayDataArray = _tableviewDisplayDataArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"通讯录" style:UIBarButtonItemStyleDone target:self action:@selector(turnToContactsViewController)];
        /*
        UIButton *btnContacts = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnContacts setFrame:CGRectMake(0.f, 7.f, 125.f, 30.f)];
        [btnContacts setBackgroundImage:[UIImage imageNamed:@"ZJZAdress"] forState:UIControlStateNormal];
        [btnContacts addTarget:self action:@selector(turnToContactsViewController) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnContacts];
         */
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupListTag" options:0 context:@""];
        //noticeArrayTag
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"noticeArrayTag" options:0 context:@""];
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupListResult" options:0 context:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    
    listType = LIST_TYPE_MSG_GROUP;
    //self.navigationItem.title = @"找家长";
    
    segementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [segementBtn setFrame:CGRectMake(0.f, 0.f, 125.f, 30.f)];
    [segementBtn setBackgroundImage:[UIImage imageNamed:@"tab_mes"] forState:UIControlStateNormal];
//    [segementBtn setBackgroundImage:[UIImage imageNamed:@"tab_contact"] forState:UIControlStateSelected];
    [segementBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
    [segementBtn addTarget:self action:@selector(segeValueChanged:event:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = segementBtn;
    
    
    _messageListTableview = [[BBMessageGroupBaseTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.screenHeight-110.f) style:UITableViewStylePlain];
    _messageListTableview.backgroundColor = [UIColor clearColor];
    _messageListTableview.messageGroupBaseTableViewdelegate = self;
    _messageListTableview.delegate = self;
    _messageListTableview.dataSource = self;
    //_messageListTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
    _messageListTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _messageListTableview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_messageListTableview];
    
    /* //close searchbar
    _messageListTableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    _messageListTableSearchBar.backgroundColor = [UIColor clearColor];
    //[_messageListTableSearchBar setBackgroundImage:[UIImage imageNamed:@"ZJZSearch"]];
    _messageListTableSearchBar.placeholder = @"搜索";
    [self.view addSubview:_messageListTableSearchBar];
    _messageListTableSearchBar.delegate = self;
    

    
    
	// Do any additional setup after loading the view.
    if (!IOS7) {
        for (UIView *subview in _messageListTableSearchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;  
            }   
        }
        //[_messageListTableSearchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"ZJZSearch"]];
    }
    */
    //self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!self.classModels.count) {
        isRequestClassList = NO;
        [self requestClasList];
    }
    
    int unReadCount = 0;
    for (id messageGroup in _tableviewDisplayDataArray) {
        if ([messageGroup isKindOfClass:[CPUIModelMessageGroup class]]) {
            CPUIModelMessageGroup *msgGroup = messageGroup;
            unReadCount += [msgGroup.unReadedCount intValue];
        }
        
    }
    __block NSInteger count = unReadCount;
    dispatch_block_t updateTagBlock = ^{
        [[CPUIModelManagement sharedInstance] setFriendMsgUnReadedCount:count];
    };
    dispatch_async(dispatch_get_main_queue(), updateTagBlock);
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupListTag"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupListResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"noticeArrayTag"];
}
#pragma mark Setter && Getter
- (NSArray *)classModels
{
    if (!_classModels) _classModels = [[NSArray alloc] init];
    
    return _classModels;
}

- (NSArray *) tableviewDisplayDataArray
{
    if (!_tableviewDisplayDataArray) {
//        _tableviewDisplayDataArray = [[NSArray alloc] initWithArray:[CPUIModelManagement sharedInstance].userMessageGroupList];
        NSArray *array = [NSArray arrayWithArray:[CPUIModelManagement sharedInstance].userMessageGroupList];
        NSMutableArray *arrayM = [[NSMutableArray alloc] initWithCapacity:20];
        for (CPUIModelMessageGroup *g in array) {
            if (([g.msgList count] != 0 && [g isMsgSingleGroup]) || [g isMsgMultiGroup]) {
                [arrayM addObject:g];
            }
        }
        [arrayM addObjectsFromArray:[PalmUIManagement sharedInstance].noticeArray];
        _tableviewDisplayDataArray = [NSArray arrayWithArray:arrayM];
    }
    return _tableviewDisplayDataArray;
}
-(void)setTableviewDisplayDataArray:(NSArray *)tableviewDisplayDataArray
{
    _tableviewDisplayDataArray = tableviewDisplayDataArray;
    [self.messageListTableview reloadData];
}


#pragma mark Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"userMsgGroupListTag"] || [keyPath isEqualToString:@"noticeArrayTag"]) {
        DDLogInfo(@"receive msgGroupList");
//        self.tableviewDisplayDataArray = [CPUIModelManagement sharedInstance].userMessageGroupList;
        NSArray *array = [NSArray arrayWithArray:[CPUIModelManagement sharedInstance].userMessageGroupList];
        NSMutableArray *arrayM = [[NSMutableArray alloc] initWithCapacity:10];
        for (CPUIModelMessageGroup *g in array) {
            if (([g.msgList count] != 0 && [g isMsgSingleGroup]) || [g isMsgMultiGroup]) {
                [arrayM addObject:g];
            }
        }
        [arrayM addObjectsFromArray:[PalmUIManagement sharedInstance].noticeArray];
        
        [arrayM sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *tempTimeInterval1;
            NSNumber *tempTimeInterval2;
            
            if ([obj1 isKindOfClass:[CPUIModelMessageGroup class]]) {
                CPUIModelMessageGroup *tempGroup = (CPUIModelMessageGroup *)obj1;
                tempTimeInterval1 = tempGroup.updateDate;
            }else{
                CPDBModelNotifyMessage *tempGroup = (CPDBModelNotifyMessage *)obj1;
                tempTimeInterval1 = tempGroup.date;
            }
            
            if ([obj2 isKindOfClass:[CPUIModelMessageGroup class]]) {
                CPUIModelMessageGroup *tempGroup = (CPUIModelMessageGroup *)obj2;
                tempTimeInterval2 = tempGroup.updateDate;
            }else{
                CPDBModelNotifyMessage *tempGroup = (CPDBModelNotifyMessage *)obj2;
                tempTimeInterval2 = tempGroup.date;
            }
            return tempTimeInterval1.integerValue < tempTimeInterval2.integerValue;

        }];
        
        self.tableviewDisplayDataArray = [NSArray arrayWithArray:arrayM];
    }
    
    if ([@"groupListResult" isEqualToString:keyPath])  // 班级列表
    {
        NSDictionary *result = [PalmUIManagement sharedInstance].groupListResult;
        
        if (![result[@"hasError"] boolValue]) {
            self.classModels = [NSArray arrayWithArray:result[@"data"]];
            if (listType == LIST_TYPE_CONTACTS) {
                [self.messageListTableview  reloadData];
            }
        }else{
            [self showProgressWithText:@"班级列表加载失败" withDelayTime:0.1];
        }
    }
    
    if ([keyPath isEqualToString:@"publicAccountDic"]) {
        [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"publicAccountDic"];
        NSDictionary *result = [PalmUIManagement sharedInstance].publicAccountDic;
        if (![result[@"hasError"] boolValue]) {
            [self closeProgress];
            NSDictionary *data = result[@"data"][@"list"];
            for (NSDictionary *tempItemModel in data.allValues) {
                if ([tempItemModel isKindOfClass:[NSDictionary class]]) {
                    if ([tempItemModel[@"name"] isEqualToString:tempCacheNotifyMsg.fromUserName]) {

                        BBServiceMessageDetailViewController *messageDetail = [[BBServiceMessageDetailViewController alloc] init];
                        [messageDetail setModel:[BBServiceAccountModel convertByDic:tempItemModel]];
                        messageDetail.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:messageDetail animated:YES];
                        [[CPSystemEngine sharedInstance] updateUnreadedMessageStatusChanged:tempCacheNotifyMsg];
                        return;
                    }
                }
            }
            if (tempCacheNotifyMsg) {
                BBServiceMessageDetailViewController *messageDetail = [[BBServiceMessageDetailViewController alloc] init];
                [messageDetail setNotifyMsgmodel:tempCacheNotifyMsg];
                messageDetail.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:messageDetail animated:YES];
                [[CPSystemEngine sharedInstance] updateUnreadedMessageStatusChanged:tempCacheNotifyMsg];
            }else [self showProgressWithText:@"无法查看" withDelayTime:2];
        }else
        {
            [self showProgressWithText:result[@"errorMessage"] withDelayTime:2.f];
        }
    }
    
}
#pragma mark BBZJZViewControllerMethod

- (void)requestClasList
{
    if (!isRequestClassList) {
        [[PalmUIManagement sharedInstance] getGroupList];
        isRequestClassList = YES;
    }
}

- (void)segeValueChanged:(UIButton *)sender event:(UIEvent *) touchEvent
{
    UITouch *touch = [[touchEvent allTouches] anyObject];
    
    CGPoint point = [touch locationInView:segementBtn];
    if ((CGRectContainsPoint(CGRectMake(0.f, 0.f, CGRectGetWidth(segementBtn.frame)/2, CGRectGetHeight(segementBtn.frame)), [touch locationInView:segementBtn]) || point.x < 0.f) && listType == LIST_TYPE_MSG_GROUP ) {
        return;
    }else if ((CGRectContainsPoint(CGRectMake(CGRectGetWidth(segementBtn.frame)/2, 0.f, CGRectGetWidth(segementBtn.frame)/2, CGRectGetHeight(segementBtn.frame)), [touch locationInView:segementBtn]) || point.x > 126.f) && listType == LIST_TYPE_CONTACTS)
    {
        return;
    }
    
    sender.selected = !sender.selected;
    [segementBtn setBackgroundImage:sender.selected ? [UIImage imageNamed:@"tab_contact"] : [UIImage imageNamed:@"tab_mes"] forState:UIControlStateNormal];
    listType = sender.selected ? LIST_TYPE_CONTACTS : LIST_TYPE_MSG_GROUP;
    [self.messageListTableview reloadData];
}

- (NSMutableArray *)searchResultListByKeyWord:(NSString *)keyword
{
    NSMutableArray *tempSearchResult = [[NSMutableArray alloc] init];
    for (CPUIModelMessageGroup *msgGroup in [CPUIModelManagement sharedInstance].userMessageGroupList) {
            if ([msgGroup isMsgSingleGroup] && msgGroup.memberList.count>0) {
                CPUIModelMessageGroupMember *member = [msgGroup.memberList objectAtIndex:0];
                CPUIModelUserInfo *userInfo = member.userInfo;
                if (msgGroup.msgList > 0) {
                    NSRange containStrRange = [userInfo.nickName rangeOfString:keyword options:NSCaseInsensitiveSearch];
                    if (containStrRange.length > 0 ) {
                        //有当前关键字结果
                        [tempSearchResult addObject:msgGroup];
                    }else
                    {
                        //没有
                    }
                }

            }else
            {
                CPLogInfo(@"msggroup.memberList == 0 or isNotSIngleGroup");
            }
    }
    
    for (CPDBModelNotifyMessage *message in [PalmUIManagement sharedInstance].noticeArray) {
        NSRange containStrRange = [message.fromUserName rangeOfString:keyword options:NSCaseInsensitiveSearch];
        if (containStrRange.length > 0) {
            //有当前关键字结果
            [tempSearchResult addObject:message];
        }else
        {
            //没有
        }
    }
    return tempSearchResult;
}

- (NSArray *)classifyDataByType:(NSInteger )classNum
{
    NSMutableArray *tempTeachersArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempParentsArray = [[NSMutableArray alloc] init];
    for (CPUIModelUserInfo *model in [CPUIModelManagement sharedInstance].friendArray) {

        ContactsModel *tempModel = [[ContactsModel alloc] init];
        tempModel.modelID = [model.lifeStatus integerValue];
        tempModel.avatarPath = model.headerPath;
        //tempModel.jid = model.
        tempModel.mobile = model.mobileNumber;
        //tempModel.uid = [infoDic objectForKey:@"uid"];
        tempModel.userName = model.nickName;
        tempModel.sex = model.sex;
        //是否激活
        NSLog(@"%d",[model.sex integerValue]);
        tempModel.isActive = [model.sex integerValue] == 0 ? NO : YES;
    
        //是否是家长   //是否是老师
        if ([model.coupleAccount isEqualToString:@"Teacher"]) {
            tempModel.isTeacher = YES;
            tempModel.isParent  = NO;
            [tempTeachersArray addObject:tempModel];
        }else if ([model.coupleAccount isEqualToString:@"Parent"])
        {
            tempModel.isTeacher = NO;
            tempModel.isParent  = YES;
            
            
            //所属班级
            NSDictionary *dic = (NSDictionary *)[model.birthday objectFromJSONString];
            if (dic && dic.allKeys > 0) {
                for (NSString *key in dic.allKeys) {
                    if ([key integerValue] == classNum) {
                        [tempParentsArray addObject:tempModel];
                    }
                }
            }
        }else if ([model.coupleAccount isEqualToString:@"TeacherAndParent"])
        {
            tempModel.isTeacher = YES;
            tempModel.isParent  = YES;
            [tempTeachersArray addObject:tempModel];
            NSDictionary *dic = (NSDictionary *)[model.birthday objectFromJSONString];
            if (dic && dic.allKeys > 0) {
                for (NSString *key in dic.allKeys) {
                    if ([key integerValue] == classNum) {
                        [tempParentsArray addObject:tempModel];
                    }
                }
            }
        }else
        {
            tempModel.isTeacher = NO;
            tempModel.isParent  = NO;
        }
        
    }
    if (classNum == -1) {
        return [NSArray arrayWithArray:tempTeachersArray];
    }else
    {
        return [NSArray arrayWithArray:tempParentsArray];
    }
}

#pragma mark UITableviewDelegate
//close searchbar
/*
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_messageListTableSearchBar isFirstResponder]) {
        [_messageListTableSearchBar resignFirstResponder];
    }
    
}

-(void)tableviewHadTapped
{
    if ([_messageListTableSearchBar isFirstResponder]) {
        [_messageListTableSearchBar resignFirstResponder];
    }
    
}
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //notifyMessage change
    if (listType == LIST_TYPE_MSG_GROUP)
    {
        BBMessageGroupBaseCell *cell =(BBMessageGroupBaseCell *) [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.msgGroup isKindOfClass:[CPUIModelMessageGroup class]]) {
            CPUIModelMessageGroup *messageGroup = cell.msgGroup;
            
            if ([messageGroup isMsgSingleGroup]) {
                BBSingleIMViewController *singleIM = [[BBSingleIMViewController alloc] init:messageGroup];
                singleIM.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:singleIM animated:YES];
            }else{
                BBMutilIMViewController *mutilIM = [[BBMutilIMViewController alloc] init:messageGroup];
                mutilIM.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:mutilIM animated:YES];
            }
            
            __block NSInteger count = [CPUIModelManagement sharedInstance].friendMsgUnReadedCount;
            count -= [messageGroup.unReadedCount intValue];
            dispatch_block_t updateTagBlock = ^{
                [[CPUIModelManagement sharedInstance] setFriendMsgUnReadedCount:count];
            };
            dispatch_async(dispatch_get_main_queue(), updateTagBlock);
        }else if ([cell.msgGroup isKindOfClass:[CPDBModelNotifyMessage class]]){
            [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"publicAccountDic" options:0 context:nil];
            
            tempCacheNotifyMsg = cell.msgGroup;
            
            [self showProgressWithText:@"正在获取"];
            [[PalmUIManagement sharedInstance] getPublicAccount];
            
            //设置未读数
            /*
            if (msgGroup) {
                BBServiceMessageDetailViewController *messageDetail = [[BBServiceMessageDetailViewController alloc] init];
                BBServiceAccountModel *tempModel = [[BBServiceAccountModel alloc] init];
                
                [messageDetail setModel:msgGroup];
                messageDetail.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:messageDetail animated:YES];
                [[CPSystemEngine sharedInstance] updateUnreadedMessageStatusChanged:msgGroup];
            }else [self showProgressWithText:@"无法查看" withDelayTime:2];
        */
        }
    }else
    {
        
        switch (indexPath.section) {
            case 0:
            {
                BBGroupModel *tempModel = self.classModels[indexPath.row];
            
                NSArray *contacts = [self classifyDataByType:[tempModel.groupid integerValue]];
                if (contacts.count) {
                    ContactsViewController *contact = [[ContactsViewController alloc] initWithContactsArray:contacts];
                    contact.hidesBottomBarWhenPushed = YES;
                    contact.title = tempModel.alias;
                    [self.navigationController pushViewController:contact animated:YES];
                }else [self showProgressWithText:@"当前班级无任何联系人" withDelayTime:2.f];
                
            }
                break;
            case 1:
            {
                NSArray *contacts = [self classifyDataByType:-1];
                if (contacts.count) {
                    ContactsViewController *contact = [[ContactsViewController alloc] initWithContactsArray:contacts];
                    contact.hidesBottomBarWhenPushed = YES;
                    contact.title = @"同事";
                    [self.navigationController pushViewController:contact animated:YES];
                }else [self showProgressWithText:@"当前无任何联系人" withDelayTime:2.f];
            }
                break;
            case 2:
            {
                NSMutableArray *tempMutilMsgGroups = [[NSMutableArray alloc] init];
                for (CPUIModelMessageGroup *group in self.tableviewDisplayDataArray) {
                    if ([group isKindOfClass:[CPUIModelMessageGroup class]]) {
                        if (![group isMsgSingleGroup]) {
                            [tempMutilMsgGroups addObject:group];
                        }
                    }
                }
                MutilMsgGroupViewController *mutilMsgGroup = [[MutilMsgGroupViewController alloc] initWithMutilMsgGroups:tempMutilMsgGroups];
                mutilMsgGroup.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:mutilMsgGroup animated:YES];
            }
                break;
            case 3:
            {
                //[PalmUIManagement sharedInstance].noticeArray
                BBServiceAccountViewController *serviceAccount = [[BBServiceAccountViewController alloc] init];
                serviceAccount.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:serviceAccount animated:YES];
            }
                break;
            default:
                break;
        }
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark UItableviewDatasouce

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (listType == LIST_TYPE_CONTACTS) {
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 20.f)];
        sectionView.backgroundColor =  [UIColor colorWithHexString:@"#f2f2f2"];
        return sectionView;
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (listType == LIST_TYPE_MSG_GROUP) {
        return self.tableviewDisplayDataArray.count != 0 ? self.tableviewDisplayDataArray.count : 0;
    }else
    {
        return section == 0 ? self.classModels.count : 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return listType == LIST_TYPE_MSG_GROUP ? 1 : 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (listType == LIST_TYPE_MSG_GROUP) {
        static NSString *messageGroupCellIdentifier = @"messageGroupCellIdentifier";
        static NSString *messageSingleCellIdentifier = @"messageSingleCellIdentifier";
        static NSString *messageNotifyCellIdentifier = @"messageNotifyCellIdentifier";
        
        id tempMsgGroup = [self.tableviewDisplayDataArray objectAtIndex:indexPath.row];
        
        BBMessageGroupBaseCell *cell;
        if ([tempMsgGroup isKindOfClass:[CPUIModelMessageGroup class]]) {
            if ([tempMsgGroup isMsgSingleGroup]) {
                cell = [tableView dequeueReusableCellWithIdentifier:messageSingleCellIdentifier];
                if (nil == cell) {
                    cell = [[BBSingleMessageGroupCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageSingleCellIdentifier];
                }
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:messageGroupCellIdentifier];
                if (nil ==cell) {
                    cell = [[BBGroupMessageGroupCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageGroupCellIdentifier];
                }
            }
            [cell setUIModelMsgGroup:tempMsgGroup];
            //cell.msgGroup = tempMsgGroup;
        }else if ([tempMsgGroup isKindOfClass:[CPDBModelNotifyMessage class]])
        {
            cell = [tableView dequeueReusableCellWithIdentifier:messageNotifyCellIdentifier];
            if (nil == cell) {
                cell = [[BBNotifyMessageGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageNotifyCellIdentifier];
                //cell.backgroundColor = [UIColor clearColor];
            }
            [cell setDBModelNotifyMsgGroup:tempMsgGroup];
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        return cell;
    }else
    {
        static NSString *contactsDefaultCellIdentifier = @"contactsDefaultCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactsDefaultCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactsDefaultCellIdentifier];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14.f];
            if (!IOS7) {
                UIView *cellBG = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 40.f)];
                cellBG.backgroundColor = [UIColor whiteColor];
                [cell addSubview:cellBG];
                [cell sendSubviewToBack:cellBG];
            }
        }
        
        switch (indexPath.section) {
            case 0:
            {
                BBGroupModel *tempModel = self.classModels[indexPath.row];
                cell.textLabel.text = tempModel.alias;
            }
                break;
            case 1:
                cell.textLabel.text = @"同事";
                break;
                
            case 2:
                cell.textLabel.text = @"讨论组";
                break;
                
            case 3:
                cell.textLabel.text = @"服务号";
                break;
            default:
                break;
        }
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (listType == LIST_TYPE_MSG_GROUP) {
        return 0;
    }else if (section == 0)
    {
        return 0;
    }
    
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return listType == LIST_TYPE_MSG_GROUP ?70.f : 40.f;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return listType == LIST_TYPE_MSG_GROUP ?YES : NO;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id tempMsgGroup = [self.tableviewDisplayDataArray objectAtIndex:indexPath.row];
    if ([tempMsgGroup isKindOfClass:[CPUIModelMessageGroup class]]) {
        [[CPUIModelManagement sharedInstance] deleteMsgGroup:tempMsgGroup];
    }else if ([tempMsgGroup isKindOfClass:[CPDBModelNotifyMessage class]])
    {
        [[CPSystemEngine sharedInstance] deleteNotifyMessageGroupByOperationWithObj:tempMsgGroup];
//        CPDBModelNotifyMessage *msgGroup = tempMsgGroup;
//        [[[CPSystemEngine sharedInstance] dbManagement] deleteMsgGroupByFrom:msgGroup.from];
    }
}
#pragma mark SearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        //self.tableviewDisplayDataArray = [[NSMutableArray alloc] initWithArray:[CPUIModelManagement sharedInstance].userMessageGroupList];
        self.tableviewDisplayDataArray = nil;
        [self.messageListTableview reloadData];
    }else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *searchResult =  [self searchResultListByKeyWord:searchText];
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                [self setTableviewDisplayDataArray:searchResult];
                
                
            });
        });
    }
}
/*//close searchbar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([_messageListTableSearchBar isFirstResponder]) {
        [_messageListTableSearchBar resignFirstResponder];
    }
}
*/
@end
