//
//  ContactsStartGroupChatViewController.m
//  teacher
//
//  Created by ZhangQing on 14-3-21.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#define selectedItemsMaxCount  99

#import "ContactsStartGroupChatViewController.h"
#import "HPTopTipView.h"
#import "CPUIModelManagement.h"
#import "BBMutilIMViewController.h"


#import "MutilIMViewController.h"
#import "MutilGroupDetailViewController.h"

NSInteger nickNameSort(CPUIModelUserInfo *user1, CPUIModelUserInfo *user2, void *context)
{
    CPUIModelUserInfo *u1,*u2;
    //类型转换
    u1 = (CPUIModelUserInfo *)user1;
    u2 = (CPUIModelUserInfo *)user2;
    return  [u1.nickName localizedCompare:u2.nickName];
}

@interface ContactsStartGroupChatViewController ()
@property (nonatomic , strong) BBMessageGroupBaseTableView *contactsForGroupListTableview;
@property (nonatomic , strong) NSMutableArray *contactsForGroupListDataArray;//通讯录array,tableview数据源
@property (nonatomic , strong) NSMutableArray *filterExistUserInfosArray;//过滤存在的userinfo后的array,search用
@property (nonatomic , strong) NSArray *hidedUserInfosArray;//隐藏的array
@property (nonatomic , strong) UISearchBar *contactsForGroupTableSearchBar;
@property (nonatomic ,strong) DisplaySelectedMemberView *displaySelectedMembersVIew;
@property (nonatomic) BOOL isAddMemberInExistMsgGroup;

@end

@implementation ContactsStartGroupChatViewController
@synthesize contactsForGroupListDataArray = _contactsForGroupListDataArray;
@synthesize selectedItemsArray = _selectedItemsArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
        [back setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
        
        UIButton *confirm = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirm setTitle:@"确认" forState:UIControlStateNormal];
        [confirm setFrame:CGRectMake(0.f, 7.f, 60.f, 30.f)];
        //sendButton.backgroundColor = [UIColor blackColor];
        [confirm setTitleColor:[UIColor colorWithRed:251/255.f green:76/255.f blue:7/255.f alpha:1.f] forState:UIControlStateNormal];
        [confirm setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirm];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.title = @"通讯录";
    
    _contactsForGroupTableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    _contactsForGroupTableSearchBar.placeholder = @"搜索";
    _contactsForGroupTableSearchBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contactsForGroupTableSearchBar];
    _contactsForGroupTableSearchBar.delegate = self;
    
    _contactsForGroupListTableview = [[BBMessageGroupBaseTableView alloc] initWithFrame:CGRectMake(0.f, 40.f, 320.f, [UIScreen mainScreen].bounds.size.height-102.f ) style:UITableViewStylePlain];
    _contactsForGroupListTableview.delegate = self;
    _contactsForGroupListTableview.dataSource = self;
    _contactsForGroupListTableview.backgroundColor = [UIColor clearColor];
    _contactsForGroupListTableview.messageGroupBaseTableViewdelegate = self;
    _contactsForGroupListTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_contactsForGroupListTableview];
    
    /*
    UIImageView *lineImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, _contactsForGroupListTableview.frame.origin.y+_contactsForGroupListTableview.frame.size.height, 320.f, 2.f)];
    lineImageview.backgroundColor = [UIColor colorWithRed:138/255.f green:136/255.f blue:135/255.f alpha:1.f];
    [self.view addSubview:lineImageview];
    
    _displaySelectedMembersVIew =  [[DisplaySelectedMemberView alloc] initWithFrame:CGRectMake(0.f, _contactsForGroupListTableview.frame.origin.y+_contactsForGroupListTableview.frame.size.height+2, 320.f, 50.f)];
    _displaySelectedMembersVIew.delegate = self;
    [self.view addSubview:_displaySelectedMembersVIew];
    
    if (self.hidedUserInfosArray.count > 0) {
        [self.displaySelectedMembersVIew setSelectedMembersArray:self.hidedUserInfosArray];
    }
    */
    if (!IOS7) {
        for (UIView *subview in _contactsForGroupTableSearchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        
        //[_messageListTableSearchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"ZJZSearch"]];
    }
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"createMsgGroupTag" options:0 context:nil];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"addGroupMemDic" options:0 context:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"createMsgGroupTag"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"addGroupMemDic"];
}
-(NSMutableArray *)searchResultListByKeyWord:(NSString *)keyword
{
    NSMutableArray *tempSearchResult = [[NSMutableArray alloc] init];
    for (CPUIModelUserInfo *userInfo in self.filterExistUserInfosArray) {
        NSRange containStrRange = [userInfo.nickName rangeOfString:keyword options:NSCaseInsensitiveSearch];
        if (containStrRange.length > 0) {
            //有当前关键字结果
            [tempSearchResult addObject:userInfo];
        }else
        {
            //没有
        }
        
    }
    return tempSearchResult;
}
//过滤已存在的userinfo
-(void)filterExistUserInfo : (BOOL)isGroup WithSelectedArray:(NSArray *)userInfos
{
    self.hidedUserInfosArray = [NSArray arrayWithArray:userInfos];
    if (isGroup) {
        self.isAddMemberInExistMsgGroup = YES;
    }
    
    NSMutableArray *tempMutableArray = [[NSMutableArray alloc] initWithArray:self.contactsForGroupListDataArray];
    for (CPUIModelUserInfo *selectedUserInfo in userInfos) {
        for (int i = 0; i < self.contactsForGroupListDataArray.count; i++) {
            CPUIModelUserInfo *userInfo = [self.contactsForGroupListDataArray objectAtIndex:i];
            NSLog(@"\n----selectedUserInfo: nickName = %@  userID = %@ \n----userInfo: nickName = %@  userID = %@",selectedUserInfo.nickName,selectedUserInfo.userInfoID,userInfo.nickName,userInfo.userInfoID);
            if ([userInfo.userInfoID integerValue] == [selectedUserInfo.userInfoID integerValue]) {
                [tempMutableArray removeObject:userInfo];
                break;
            }
        }

    }

    self.contactsForGroupListDataArray = tempMutableArray;
    self.filterExistUserInfosArray = tempMutableArray;

}

- (NSMutableArray *)getUsefulUserinfoList
{
    NSMutableArray *usefulUserInfos = [[NSMutableArray alloc] init];
    NSArray *tempFriends = [[NSArray alloc] initWithArray:[CPUIModelManagement sharedInstance].friendArray];
    for (CPUIModelUserInfo *userInfo in tempFriends) {
        if (userInfo) {
            [usefulUserInfos addObject:userInfo];
        }
    }
    return [[NSMutableArray alloc] initWithArray:[usefulUserInfos sortedArrayUsingFunction:nickNameSort context:NULL]];
}


#pragma mark Getter&&Setter
- (DisplaySelectedMemberView *)displaySelectedMembersVIew
{
    if (!_displaySelectedMembersVIew) {
        _displaySelectedMembersVIew = [[DisplaySelectedMemberView alloc] init];
    }
    return _displaySelectedMembersVIew;
}
- (NSMutableArray *)filterExistUserInfosArray
{
    if (!_filterExistUserInfosArray) {
        _filterExistUserInfosArray = [self getUsefulUserinfoList];
    }
    return _filterExistUserInfosArray;
}
- (NSMutableArray *)selectedItemsArray
{
    if (!_selectedItemsArray) {
        _selectedItemsArray = [[NSMutableArray alloc] init];
    }
    return _selectedItemsArray;
}
- (NSMutableArray *)contactsForGroupListDataArray
{
    if (!_contactsForGroupListDataArray) {
        _contactsForGroupListDataArray = [self getUsefulUserinfoList];
    }
    return _contactsForGroupListDataArray;
}

- (void)setContactsForGroupListDataArray:(NSArray *)contactsForGroupListDataArray
{
    _contactsForGroupListDataArray = [[NSMutableArray alloc] initWithArray:[contactsForGroupListDataArray sortedArrayUsingFunction:nickNameSort context:NULL]];
    [self.contactsForGroupListTableview reloadData];
}
/*
-(void)setSelectedItemsArray:(NSMutableArray *)selectedItemsArray
{
    
    _selectedItemsArray = [[NSMutableArray alloc] initWithArray:selectedItemsArray];
    [self filterExistUserInfo];
    [self.contactsForGroupListTableview reloadData];
    
    [self.displaySelectedMembersVIew setSelectedMembersArray:selectedItemsArray];
}
-(void)setAddMemberInExistMsgGroup:(NSMutableArray *)selectedArray
{
    NSMutableArray *tempUserInfoArray = [[NSMutableArray alloc] init];
    for (CPUIModelMessageGroupMember *member in selectedArray) {
        [tempUserInfoArray addObject:member.userInfo];
    }
    self.isAddMemberInExistMsgGroup = YES;
    [self setSelectedItemsArray:tempUserInfoArray];
}
 */
#pragma mark Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    /*
     if (![[tempDic objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
     NSDictionary *tempJsonDic = [[tempDic objectForKey:ASI_REQUEST_DATA] objectForKey:@"list"];
     [self creatContactsData:tempJsonDic];
     }else
     {
     [[HPTopTipView shareInstance] showMessage:[tempDic objectForKey:ASI_REQUEST_ERROR_MESSAGE]];
     }
     */
    [self closeProgress];
    if ([keyPath isEqualToString:@"createMsgGroupTag"]) {
        NSInteger resultCodeInt = [CPUIModelManagement sharedInstance].createMsgGroupTag;
        // 成功
        if(resultCodeInt == RESPONSE_CODE_SUCESS){
            CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
            BBMutilIMViewController *mutilIM = [[BBMutilIMViewController alloc] init:currMsgGroup];
            [self.navigationController pushViewController:mutilIM animated:YES];
        }else if (resultCodeInt == RESPONSE_CODE_ERROR) {
            NSString *errorStr = (NSString *)[[CPUIModelManagement sharedInstance].responseActionDic objectForKey:response_action_res_desc];
            CPLogInfo(@"%@",errorStr);
        }
    }else if ([keyPath isEqualToString:@"addGroupMemDic"])
    {
        for (id viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[MutilGroupDetailViewController class]]) {
                [(MutilGroupDetailViewController *)viewController refreshMsgGroup];
                [self.navigationController popToViewController:viewController animated:YES];
            }
        }
    }
}
#pragma mark ContactsStartGroupChatViewController
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmAction
{
    if (!self.selectedItemsArray.count) {
        [self showProgressWithText:@"人员不能为空" withDelayTime:2.f];
        return;
    }
    
    if (!self.isAddMemberInExistMsgGroup) {
        [self.selectedItemsArray addObjectsFromArray:self.hidedUserInfosArray];
        [[CPUIModelManagement sharedInstance] createConversationWithUsers:self.selectedItemsArray andMsgGroups:nil andType:CREATE_CONVER_TYPE_COMMON];
    }else
    {
        [self showProgressWithText:@"正在添加..."];
        [[CPUIModelManagement sharedInstance] addGroupMemWithUserNames:self.selectedItemsArray andGroup:self.msgGroup];
        
    }

}

#pragma mark selectedItemView
- (void)removeItem:(CPUIModelUserInfo *)model
{
    NSMutableArray *tempItemsArray = [NSMutableArray arrayWithArray:self.selectedItemsArray];
    //[tempItemsArray addObjectsFromArray:self.selectedItemsArray];
    for (CPUIModelUserInfo *userInfo in self.selectedItemsArray) {
        if ([userInfo.nickName isEqualToString:model.nickName]) {
            [tempItemsArray removeObject:userInfo];
        }
    }
    [self.selectedItemsArray removeAllObjects];
    [self.selectedItemsArray addObjectsFromArray:tempItemsArray];
}
- (BOOL)checkUserInfoIsSelected : (CPUIModelUserInfo *)model
{
    for (CPUIModelUserInfo *userInfo in self.selectedItemsArray) {
        if ([userInfo.userInfoID integerValue] == [model.userInfoID integerValue]) {
            return YES;
        }
    }
    return NO;
}
//add or remove in selectedItemArray
-(void)changeSelectedItemArrayBySelectedStatus:(BOOL)isSelected andModel:(CPUIModelUserInfo *)userInfo
{
    if (isSelected) {
        [self.selectedItemsArray addObject:userInfo];
    }else
    {
        [self removeItem:userInfo];
    }
    CPLogInfo(@"selected Items count == %d",self.selectedItemsArray.count);
    //修改UI
    NSMutableArray *tempAllSelectedArray = [NSMutableArray arrayWithArray:self.hidedUserInfosArray];
    [tempAllSelectedArray addObjectsFromArray:self.selectedItemsArray];
    [self.displaySelectedMembersVIew setSelectedMembersArray:tempAllSelectedArray];
    
    self.navigationItem.rightBarButtonItem.enabled = tempAllSelectedArray.count ?YES:NO;
    
}
#pragma mark DisplaySelectedViewDelegate
-(void)confirmBtnTapped:(NSArray *)userinfos
{
    if (!self.isAddMemberInExistMsgGroup) {
        [[CPUIModelManagement sharedInstance] createConversationWithUsers:userinfos andMsgGroups:nil andType:CREATE_CONVER_TYPE_COMMON];
    }else
    {
        for (id viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[BBMutilIMViewController class]]) {
//                [self.navigationController popToViewController:viewController animated:YES];
                [[CPUIModelManagement sharedInstance] addGroupMemWithUserNames:self.selectedItemsArray andGroup:self.msgGroup];
                /*
                 NSMutableArray *tempUserInfos = [[NSMutableArray alloc] initWithArray:userinfos];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    for (CPUIModelUserInfo *userInfo in self.hidedUserInfosArray) {
                        for (CPUIModelUserInfo *tempUserInfoInUserinfos in userinfos) {
                            if ([userInfo.userInfoID integerValue] == [tempUserInfoInUserinfos.userInfoID   integerValue]) {
                                [tempUserInfos removeObject:tempUserInfoInUserinfos];
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(),  ^{

                        [[CPUIModelManagement sharedInstance] addGroupMemWithUserNames:self.selectedItemsArray andGroup:self.msgGroup];
                        
                    });
                });
                */
                

            }
                                   
        }

    }
}
#pragma mark UITableviewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_contactsForGroupTableSearchBar isFirstResponder]) {
        [_contactsForGroupTableSearchBar resignFirstResponder];
    }
    
}

-(void)tableviewHadTapped
{
    if ([_contactsForGroupTableSearchBar isFirstResponder]) {
        [_contactsForGroupTableSearchBar resignFirstResponder];
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedItemsArray.count == selectedItemsMaxCount) {
        [[HPTopTipView shareInstance] showMessage:@"已达到人数上线"];
        return;
    }
    StartGroupChatTableviewCell *cell =(StartGroupChatTableviewCell *) [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    [self changeSelectedItemArrayBySelectedStatus:cell.selectedBtn.selected andModel:cell.model];
}
-(void)itemIsSelected:(CPUIModelUserInfo *)userInfo andIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedItemsArray.count == selectedItemsMaxCount) {
        [[HPTopTipView shareInstance] showMessage:@"已达到人数上线"];
        return;
    }
    StartGroupChatTableviewCell *cell =(StartGroupChatTableviewCell *) [self.contactsForGroupListTableview cellForRowAtIndexPath:indexPath];
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    [self changeSelectedItemArrayBySelectedStatus:cell.selectedBtn.selected andModel:userInfo];
}
#pragma mark UItableviewDatasouce
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectZero];
    sectionView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, 200.f, 20.f)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:14.f];
    title.textColor = [UIColor lightGrayColor];
    title.text = @"手心网家长用户";
    [sectionView addSubview:title];
    return sectionView;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"手心网家长用户";
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactsForGroupListDataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *contactsTableviewCellIdentifier = @"contactsForGroupTableviewCellIdentifier";
    StartGroupChatTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactsTableviewCellIdentifier];
    if (!cell) {
        cell = [[StartGroupChatTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactsTableviewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    CPUIModelUserInfo *userInfo = [self.contactsForGroupListDataArray objectAtIndex:indexPath.row];
    [cell setModel:userInfo];
    cell.currentIndexPath = indexPath;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL checkResult = [self checkUserInfoIsSelected:userInfo];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            if (checkResult){
                cell.selectedBtn.selected = YES;
            }
            else cell.selectedBtn.selected = NO;

        });
    });
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

#pragma mark SearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.contactsForGroupListDataArray = [[NSMutableArray alloc] initWithArray:self.filterExistUserInfosArray];
    }else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *searchResult =  [self searchResultListByKeyWord:searchText];
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                [self setContactsForGroupListDataArray:searchResult];
                
                
            });
        });
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([_contactsForGroupTableSearchBar isFirstResponder]) {
        [_contactsForGroupTableSearchBar resignFirstResponder];
    }
}

@end
