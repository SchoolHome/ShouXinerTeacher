//
//  BBZJZViewController.m
//  teacher
//
//  Created by ZhangQing on 14-3-12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBZJZViewController.h"
#import "CPUIModelManagement.h"
#import "ContactsViewController.h"

//test
#import "BBSingleIMViewController.h"
#import "BBMutilIMViewController.h"
#import "XiaoShuangIMViewController.h"
#import "SystemIMViewController.h"
#import "ShuangShuangTeamViewController.h"

@interface BBZJZViewController ()
@property (nonatomic , strong)NSArray *tableviewDisplayDataArray;
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
        UIButton *btnContacts = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnContacts setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
        [btnContacts setBackgroundImage:[UIImage imageNamed:@"ZJZAdress"] forState:UIControlStateNormal];
        [btnContacts addTarget:self action:@selector(turnToContactsViewController) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnContacts];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupListTag" options:0 context:@""];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"找家长";
    
    
    _messageListTableSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    //[_messageListTableSearchBar setBackgroundImage:[UIImage imageNamed:@"ZJZSearch"]];
    _messageListTableSearchBar.placeholder = @"搜索";
    [self.view addSubview:_messageListTableSearchBar];
    _messageListTableSearchBar.delegate = self;
    
    _messageListTableview = [[BBMessageGroupBaseTableView alloc] initWithFrame:CGRectMake(0.f, 40.f, 320.f, self.screenHeight-150.f) style:UITableViewStylePlain];
    _messageListTableview.backgroundColor = [UIColor clearColor];
    _messageListTableview.messageGroupBaseTableViewdelegate = self;
    _messageListTableview.delegate = self;
    _messageListTableview.dataSource = self;
    _messageListTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_messageListTableview];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
	// Do any additional setup after loading the view.
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
-(NSArray *) tableviewDisplayDataArray
{
    
    if (!_tableviewDisplayDataArray) {
        _tableviewDisplayDataArray = [[NSArray alloc] initWithArray:[CPUIModelManagement sharedInstance].userMessageGroupList];
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
    
    if ([keyPath isEqualToString:@"userMsgGroupListTag"]) {
        DDLogInfo(@"receive msgGroupList");
        self.tableviewDisplayDataArray = [CPUIModelManagement sharedInstance].userMessageGroupList;
        [self.messageListTableview reloadData];
    }
}
#pragma mark BBZJZViewControllerMethod
-(void)turnToContactsViewController
{
    ContactsViewController *contacts = [[ContactsViewController alloc] init];
//    [self presentModalViewController:contacts animated:YES];
    contacts.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contacts animated:YES];
}
-(NSMutableArray *)searchResultListByKeyWord:(NSString *)keyword
{
    NSMutableArray *tempSearchResult = [[NSMutableArray alloc] init];
    for (CPUIModelMessageGroup *msgGroup in [CPUIModelManagement sharedInstance].userMessageGroupList) {
            if ([msgGroup isMsgSingleGroup] && msgGroup.memberList.count>0) {
                CPUIModelMessageGroupMember *member = [msgGroup.memberList objectAtIndex:0];
                CPUIModelUserInfo *userInfo = member.userInfo;
                NSRange containStrRange = [userInfo.nickName rangeOfString:keyword options:NSCaseInsensitiveSearch];
                if (containStrRange.length > 0) {
                //有当前关键字结果
                    [tempSearchResult addObject:msgGroup];
                }else
                {
                //没有
                }
            }else
            {
                CPLogInfo(@"msggroup.memberList == 0 or isNotSIngleGroup");
            }
    }
    return tempSearchResult;
}
#pragma mark UITableviewDelegate
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBMessageGroupBaseCell *cell =(BBMessageGroupBaseCell *) [tableView cellForRowAtIndexPath:indexPath];
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
}
#pragma mark UItableviewDatasouce
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableviewDisplayDataArray.count != 0) {
        return self.tableviewDisplayDataArray.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageGroupCellIdentifier = @"messageGroupCellIdentifier";
    BBMessageGroupBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:messageGroupCellIdentifier];
    CPUIModelMessageGroup *tempMsgGroup = [self.tableviewDisplayDataArray objectAtIndex:indexPath.row];
    if (!cell) {
        if ([tempMsgGroup isMsgSingleGroup]) {
            cell = [[BBSingleMessageGroupCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageGroupCellIdentifier];
        }else{
            cell = [[BBGroupMessageGroupCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:messageGroupCellIdentifier];
        }

    }
    
    cell.msgGroup = tempMsgGroup;

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}
#pragma mark SearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.tableviewDisplayDataArray = [[NSMutableArray alloc] initWithArray:[CPUIModelManagement sharedInstance].userMessageGroupList];
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
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([_messageListTableSearchBar isFirstResponder]) {
        [_messageListTableSearchBar resignFirstResponder];
    }
}

@end
