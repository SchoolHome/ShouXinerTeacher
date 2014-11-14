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

#import "BBNotifyMessageGroupCell.h"
//shouxin version 4
#import "BBGroupModel.h"

//notifyMessage change
#import "CPUIModelManagement.h"
#import "CPDBModelNotifyMessage.h"
#import "CPDBManagement.h"


//


@interface BBZJZViewController ()
{
    NSInteger listType;
    //是否请求过班级列表
    BOOL isRequestClassList;
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
    
    UIButton *segementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [segementBtn setFrame:CGRectMake(0.f, 0.f, 125.f, 30.f)];
    [segementBtn setBackgroundImage:[UIImage imageNamed:@"tab_mes"] forState:UIControlStateNormal];
    [segementBtn setBackgroundImage:[UIImage imageNamed:@"tab_contact"] forState:UIControlStateSelected];
    [segementBtn addTarget:self action:@selector(segeValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = segementBtn;
    
    
    _messageListTableview = [[BBMessageGroupBaseTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.screenHeight-89.f) style:UITableViewStyleGrouped];
    _messageListTableview.backgroundColor = [UIColor clearColor];
    _messageListTableview.messageGroupBaseTableViewdelegate = self;
    _messageListTableview.delegate = self;
    _messageListTableview.dataSource = self;
    _messageListTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
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
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
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
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupListResult" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupListResult"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupListTag"];
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
            if ([g.msgList count] != 0) {
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
            if ([g.msgList count] != 0) {
                [arrayM addObject:g];
            }
        }
        [arrayM addObjectsFromArray:[PalmUIManagement sharedInstance].noticeArray];
        
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

}
#pragma mark BBZJZViewControllerMethod

- (void)requestClasList
{
    if (!isRequestClassList) {
        [[PalmUIManagement sharedInstance] getGroupList];
        isRequestClassList = YES;
    }
}

- (void)segeValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
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
        tempModel.modelID = [model.userInfoID integerValue];
        tempModel.avatarPath = model.headerPath;
        //tempModel.jid = model.
        tempModel.mobile = model.mobileNumber;
        //tempModel.uid = [infoDic objectForKey:@"uid"];
        tempModel.userName = model.nickName;
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
            NSLog(@"%@",dic);
            if (dic && dic.allKeys > 0) {
                if ([dic.allKeys[0] integerValue] == classNum) {
                    [tempParentsArray addObject:tempModel];
                }
            }
        }else if ([model.coupleAccount isEqualToString:@"TeacherAndParent"])
        {
            tempModel.isTeacher = YES;
            tempModel.isParent  = YES;
            [tempTeachersArray addObject:tempModel];
            NSDictionary *dic = (NSDictionary *)[model.birthday objectFromJSONString];
            if (dic && dic.allKeys > 0) {
                if ([dic.allKeys[0] integerValue] == classNum) {
                    [tempParentsArray addObject:tempModel];
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
            CPDBModelNotifyMessage *msgGroup = cell.msgGroup;
            //设置未读数
            
            [[CPSystemEngine sharedInstance] updateUnreadedMessageStatusChanged:msgGroup];
            
            
            NSArray *msgGroupOfCurrentFrom = [[[CPSystemEngine sharedInstance] dbManagement] findNotifyMessagesOfCurrentFromJID:msgGroup.from];
            NSLog(@"msgGroupOfCurrentFrom%@",msgGroupOfCurrentFrom);
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
                        if (![group isMsgSingleGroup] && [group.msgList count] != 0) {
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
                
            }
                break;
            default:
                break;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    

    
    
}
#pragma mark UItableviewDatasouce
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
                    //cell.backgroundColor = [UIColor clearColor];
                }
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:messageGroupCellIdentifier];
                if (nil ==cell) {
                    cell = [[BBGroupMessageGroupCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageGroupCellIdentifier];
                    //cell.backgroundColor = [UIColor clearColor];
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
    return 10.f;
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
