//
//  ContactsViewController.m
//  teacher
//
//  Created by ZhangQing on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ContactsViewController.h"
#import "PalmUIManagement.h"
#import "HPTopTipView.h"
#import "ContactsModel.h"
#import "CPUIModelManagement.h"
#import "BBSingleIMViewController.h"
#import "ContactsStartGroupChatViewController.h"
//test
#import "BBMembersInMsgGroupViewController.h"
#import <MessageUI/MessageUI.h>
@interface ContactsViewController ()<UIAlertViewDelegate,MFMessageComposeViewControllerDelegate>
{
    UISearchDisplayController *_contactsSearchDisplay;
    UISearchBar *_contactsTableSearchBar;
    
    NSMutableArray *searchResultList;
    
    CONTACT_TYPE type;
}
@property (nonatomic , strong) BBMessageGroupBaseTableView *contactsListTableview;
@property (nonatomic , strong) NSMutableArray *teachersListSection;
@property (nonatomic , strong) NSMutableArray *parentsListSection;
@property (nonatomic , strong) NSArray *teachers;
@property (nonatomic , strong) NSArray *parents;
@property(nonatomic,strong) NSString *phoneNumber;

@end

@implementation ContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UIButton *btnGroupChat = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnGroupChat setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
        [btnGroupChat setBackgroundImage:[UIImage imageNamed:@"ZJZChat"] forState:UIControlStateNormal];
        [btnGroupChat addTarget:self action:@selector(groupChatMode) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnGroupChat];
        

        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
        [back setBackgroundImage:[UIImage imageNamed:@"ZJZBack"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];

        UISegmentedControl *segement =  [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"",@"", nil]];

        [segement setWidth:0.1 forSegmentAtIndex:0];
        [segement setWidth:0.1 forSegmentAtIndex:1];
        segement.tintColor = [UIColor clearColor];
        segement.segmentedControlStyle = UISegmentedControlStyleBar;
        segement.selectedSegmentIndex = 0;
        [segement addTarget:self action:@selector(segementValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [segement setDividerImage:[UIImage imageNamed:@"ZJZ_Seg_Teacher"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [segement setDividerImage:[UIImage imageNamed:@"ZJZ_Seg_Teacher"] forLeftSegmentState:UIControlStateHighlighted rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [segement setDividerImage:[UIImage imageNamed:@"ZJZ_Seg_Parent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [segement setDividerImage:[UIImage imageNamed:@"ZJZ_Seg_Parent"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

        self.navigationItem.titleView = segement;
        NSLog(@"%@",segement.subviews);
        
        searchResultList = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"createMsgGroupTag" options:0 context:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"createMsgGroupTag"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //self.title = @"通讯录";
    _contactsListTableview = [[BBMessageGroupBaseTableView alloc] initWithFrame:CGRectMake(0.f, 40.f, 320.f, [UIScreen mainScreen].bounds.size.height-102.f ) style:UITableViewStylePlain];
    _contactsListTableview.backgroundColor = [UIColor clearColor];
    _contactsListTableview.delegate = self;
    _contactsListTableview.dataSource = self;
    _contactsListTableview.messageGroupBaseTableViewdelegate = self;
    
    _contactsListTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_contactsListTableview];
    
    _contactsTableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    _contactsTableSearchBar.placeholder = @"搜索";
    _contactsTableSearchBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contactsTableSearchBar];
    _contactsTableSearchBar.delegate = self;
    
    _contactsSearchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:_contactsTableSearchBar contentsController:self];
    _contactsSearchDisplay.delegate = self;
    _contactsSearchDisplay.searchResultsDelegate = self;
    _contactsSearchDisplay.searchResultsDataSource = self;
    _contactsSearchDisplay.searchResultsTableView.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
    _contactsSearchDisplay.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    

    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
    //[[PalmUIManagement sharedInstance] getuserContacts];
	// Do any additional setup after loading the view.
    if (!IOS7) {
        
        for (UIView *subview in _contactsTableSearchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
    }else _contactsListTableview.sectionIndexBackgroundColor = [UIColor clearColor];
    
     [self classifyData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Getter&&Setter
//-(NSArray *)contactsListDataArray
//{
//    if (!_contactsListDataArray) {
//        _contactsListDataArray = [[NSArray alloc] initWithArray:[CPUIModelManagement sharedInstance].friendArray];
//    }
//    NSLog(@"%@",_contactsListDataArray);
//    return _contactsListDataArray;
//}

-(void)setTeachersListSection:(NSMutableArray *)teachersListSection
{
    _teachersListSection = teachersListSection;
    if (type == CONTACT_TYPE_TEACHER) {
        [self.contactsListTableview reloadData];
    }
    
}

-(void)setParentsListSection:(NSMutableArray *)parentsListSection
{

    _parentsListSection = parentsListSection;
    if (type == CONTACT_TYPE_PARENT) {
        [self.contactsListTableview reloadData];
    }
}

-(void)setTeachers:(NSArray *)teachers
{
    _teachers = teachers;
    [self setTeachersListSection:[self sortDataByModels:teachers]];
    
}

-(void)setParents:(NSArray *)parents
{
    _parents = parents;
    [self setParentsListSection:[self sortDataByModels:parents]];
}
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
    if ([keyPath isEqualToString:@"createMsgGroupTag"]) {
        NSInteger resultCodeInt = [CPUIModelManagement sharedInstance].createMsgGroupTag;
        // 成功
        if(resultCodeInt == RESPONSE_CODE_SUCESS){
            CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] userMsgGroup];
            BBSingleIMViewController *single = [[BBSingleIMViewController alloc] init:currMsgGroup];
            [self.navigationController pushViewController:single animated:YES];
        }else if (resultCodeInt == RESPONSE_CODE_ERROR) {
            NSString *errorStr = (NSString *)[[CPUIModelManagement sharedInstance].responseActionDic objectForKey:response_action_res_desc];
            CPLogInfo(@"%@",errorStr);
        }
    }
}
#pragma mark ContactsViewController
-(void)segementValueChanged:(UISegmentedControl *)seg
{
    if (seg.selectedSegmentIndex == 0) {

        type = CONTACT_TYPE_TEACHER;
    }else if (seg.selectedSegmentIndex == 1)
    {

        type = CONTACT_TYPE_PARENT;
    }
    [self.contactsListTableview reloadData];
}
-(void)classifyData
{
    NSMutableArray *teacherArray = [[NSMutableArray alloc] init];
    NSMutableArray *parentArray = [[NSMutableArray alloc] init];
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
            
            [teacherArray addObject:tempModel];
        }else if ([model.coupleAccount isEqualToString:@"Parent"])
        {
            tempModel.isTeacher = NO;
            tempModel.isParent  = YES;
            
            [parentArray addObject:tempModel];
        }else if ([model.coupleAccount isEqualToString:@"TeacherAndParent"])
        {
            tempModel.isTeacher = YES;
            tempModel.isParent  = YES;
            
            [teacherArray addObject:tempModel];
            [parentArray addObject:tempModel];
        }else
        {
            tempModel.isTeacher = NO;
            tempModel.isParent  = NO;
        }
      
        
    }
    [self setTeachers:teacherArray];
    [self setParents:parentArray];
}
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)groupChatMode
{
    ContactsStartGroupChatViewController *groupChat = [[ContactsStartGroupChatViewController alloc] init];
    [self.navigationController pushViewController:groupChat animated:YES];
    
//    BBMembersInMsgGroupViewController *member = [[BBMembersInMsgGroupViewController alloc] init];
//    [self.navigationController pushViewController:member animated:YES];
}
-(NSMutableArray *)sortDataByModels:(NSArray *)studentModels
{
    
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (ContactsModel *tempModel in studentModels) {
        NSInteger sect = [theCollation sectionForObject:tempModel
                                collationStringSelector:@selector(userName)];
        NSLog(@"%d",sect);
        tempModel.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (ContactsModel *tempModel in studentModels) {
        if (![tempModel.userName isEqualToString:@""]) {
            [(NSMutableArray *)[sectionArrays objectAtIndex:tempModel.sectionNumber] addObject:tempModel];
        }
        
    }
    
    NSMutableArray *tempSectionArray = [[NSMutableArray alloc] init];
    for (NSMutableArray *sectionArray in sectionArrays) {
        // if (sectionArray.count > 0) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(userName)];
        [tempSectionArray addObject:sortedSection];
        //}
        
    }
    return tempSectionArray;

    
    // [selectedView setStudentNames:selectedStu];
    
    
    
}
-(CPUIModelUserInfo *)getUserInfoByModelID:(NSInteger)modelID
{
    for (CPUIModelUserInfo *userInfo in [CPUIModelManagement sharedInstance].friendArray) {
        if ([userInfo.userInfoID integerValue] == modelID) {
            return userInfo;
        }
    }
    return nil;
}
#pragma mark Data
-(NSMutableArray *)searchResultListByKeyWord:(NSString *)keyword
{
    NSMutableArray *tempSearchResult = [[NSMutableArray alloc] init];
    
    
    //    for (BBStudentModel *studentModel in tempStudentList) {
    //        NSString *tempStudentName = studentModel.studentName;
    //        NSRange containStrRange = [tempStudentName rangeOfString:keyword options:NSCaseInsensitiveSearch];
    //        if (containStrRange.length > 0) {
    //            //有当前关键字结果
    //            [tempSearchResult addObject:studentModel];
    //        }else
    //        {
    //            //没有
    //
    //        }
    //  }

        for (ContactsModel  *tempModel in type == CONTACT_TYPE_PARENT ? self.parents : self.teachers){
            NSRange containStrRange = [tempModel.userName rangeOfString:keyword options:NSCaseInsensitiveSearch];
            if (containStrRange.length > 0) {
                //有当前关键字结果
                [tempSearchResult addObject:tempModel];
            }else
            {
                //没有
                
            }
        }
    
    
    
    return tempSearchResult;
}
- (void)filterContentForSearchText:(NSString*)searchText
{
	[searchResultList removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *searchResult =  [self searchResultListByKeyWord:searchText];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            [searchResultList addObjectsFromArray:searchResult];
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
    });
}
#pragma mark UITableviewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_contactsTableSearchBar isFirstResponder]) {
        [_contactsTableSearchBar resignFirstResponder];
    }
    
}

-(void)tableviewHadTapped
{
    if ([_contactsTableSearchBar isFirstResponder]) {
        [_contactsTableSearchBar resignFirstResponder];
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}
#pragma mark UItableviewDatasouce
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (type == CONTACT_TYPE_PARENT) return  [[self.parentsListSection objectAtIndex:section] count] ? 30 : 0;
        
        else  return  [[self.teachersListSection objectAtIndex:section] count] ? 30 : 0;
        
    }
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    } else {
        
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectZero];
        //sectionView.backgroundColor = [UIColor blackColor];
        sectionView.backgroundColor = [UIColor colorWithRed:128/255.f green:143/255.f blue:155/255.f alpha:1.f];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, 200.f, 20.f)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:14.f];
        title.textColor = [UIColor whiteColor];
        if (type == CONTACT_TYPE_PARENT)    title.text = [[self.parentsListSection objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        
        else  title.text = [[self.teachersListSection objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
 
        [sectionView addSubview:title];
        return sectionView;
    }
    
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
	} else {
        return type == CONTACT_TYPE_PARENT ? self.parentsListSection.count : self.teachersListSection.count;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"%@",self.searchDisplayController.searchResultsTableView);
        return searchResultList.count;
    }else
    {
        return type == CONTACT_TYPE_PARENT ? [[self.parentsListSection objectAtIndex:section] count] :
        [[self.teachersListSection objectAtIndex:section] count];
    }


    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *contactsTableviewCellIdentifier = @"contactsTableviewCellIdentifier";
    ContactsTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:contactsTableviewCellIdentifier];
    if (!cell) {
        cell = [[ContactsTableviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contactsTableviewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [cell setModel:[searchResultList objectAtIndex:indexPath.row]];
    }else
    {
            [cell setModel:type == CONTACT_TYPE_PARENT ?
             [[self.parentsListSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] :
            [[self.teachersListSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];

    }
    

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}
#pragma mark ContactsTableviewCellDelegate
-(void)beginChat:(ContactsModel *)model
{
    CPUIModelUserInfo *userInfo = [self getUserInfoByModelID:model.modelID];
    if (!userInfo) {
        [self showProgressWithText:@"未获取到信息" withDelayTime:3];
        return;
    }
    [[CPUIModelManagement sharedInstance] createConversationWithUsers:[NSArray arrayWithObject:userInfo] andMsgGroups:nil andType:CREATE_CONVER_TYPE_COMMON];
}
-(void)sendMessage:(NSString *)mobileNumber
{
    if ([mobileNumber isEqualToString:@"0"]) {
        [self showProgressWithText:@"对方未绑定电话号码" withDelayTime:3];
        return;
    }
    self.phoneNumber = mobileNumber;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"确认要给%@发送短信吗?",mobileNumber] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
    alert.tag = 2;
    [alert show];
    
//    NSString *mobileNumberUrlStr = [NSString stringWithFormat:@"sms://%@",mobileNumber];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobileNumberUrlStr]];
}
-(void)makeCall:(NSString *)mobileNumber
{
    if ([mobileNumber isEqualToString:@"0"]) {
        [self showProgressWithText:@"对方未绑定电话号码" withDelayTime:3];
        return;
    }
    self.phoneNumber = mobileNumber;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"电话" message:[NSString stringWithFormat: @"确认拨打%@",mobileNumber] delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消", nil];
    alert.tag = 1;
    [alert show];
//    NSString *mobileNumberUrlStr = [NSString stringWithFormat:@"telprompt://%@",mobileNumber];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobileNumberUrlStr]];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
//        NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",self.phoneNumber]];
//        UIWebView *phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
//        [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
        if (alertView.tag == 1) {
            NSString *mobileNumberUrlStr = [NSString stringWithFormat:@"telprompt://%@",self.phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobileNumberUrlStr]];
        }else if (alertView.tag == 2)
        {
//            NSString *mobileNumberUrlStr = [NSString stringWithFormat:@"sms://%@",self.phoneNumber];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobileNumberUrlStr]];

            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *picker =[[MFMessageComposeViewController alloc] init];
                picker.recipients = [NSArray arrayWithObject:self.phoneNumber];
                picker.messageComposeDelegate =self;
                
                picker.body=[NSString stringWithFormat:@"'%@'邀请您下载手心网客户端，app.shouxiner.com",[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName];
                [self presentModalViewController:picker animated:YES];
                
            }else [self showProgressWithText:@"当前设备不支持短信" withDelayTime:2.5f];


        }

    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    
    switch(result)
    {
        caseMessageComposeResultCancelled:
            
            break;
        caseMessageComposeResultSent:
            
            break;
        caseMessageComposeResultFailed:
            [self showProgressWithText:@"短信发送失败" withDelayTime:2.5f];
            break;
        default:
            
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
#pragma mark SearchBarDelegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController setActive:YES animated:YES];
    
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.contactsListTableview reloadData];
}
#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    //    scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    //    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
    //	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}


@end
