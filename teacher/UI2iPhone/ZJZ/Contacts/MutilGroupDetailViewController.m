//
//  MutilGroupDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "MutilGroupDetailViewController.h"
#import "ContactsStartGroupChatViewController.h"
#import "BBMutilIMViewController.h"
#import "MutilMsgGroupViewController.h"

#import "CPUIModelManagement.h"
#import "CPUIModelMessageGroup.h"
#import "CPUIModelMessageGroupMember.h"


@interface MutilGroupDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    GROUP_MEMBER_FROM_TYPE fromType;
    
    BOOL alreadyQuitGroup;
}

@property (nonatomic, strong) UITableView *detailTableview;
@property (nonatomic, strong) MutilGroupMemberDisplayView *memberDisplayView;
@property (nonatomic, strong) CPUIModelMessageGroup *msgGroup;
@end

@implementation MutilGroupDetailViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"quitGroupDic"]){
        
        if ([[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_code]integerValue]== RESPONSE_CODE_SUCESS) {
            [[HPTopTipView shareInstance] showMessage:@"操作成功" duration:2.0f];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self closeProgress];
        }else {
            [self showProgressWithText:[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_desc] withDelayTime:2.f];
        }
    }
    
    //quitGroupDic无效时备用
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        if ([CPUIModelManagement sharedInstance].userMsgGroupTag == UPDATE_USER_GROUP_TAG_DEL) {
            [[HPTopTipView shareInstance] showMessage:@"操作成功" duration:2.0f];
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self closeProgress];
        }
    }
}

- (id)initWithMsgGroup: (CPUIModelMessageGroup *)tempMsgGroup andGroupName:(NSString *)tempGroupName
           andFromType:(GROUP_MEMBER_FROM_TYPE)type
{
    self = [super init];
    if (self) {
        
        self.msgGroup = tempMsgGroup;
        
        
        groupName = tempGroupName;
        fromType = type;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"讨论组详情";

    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    _memberDisplayView = [[MutilGroupMemberDisplayView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 0.f)];
    _memberDisplayView.delegate = self;
    [_memberDisplayView setMembers:self.msgGroup.memberList];
    _memberDisplayView.backgroundColor = [UIColor whiteColor];
    
    UIView *tableviewFootView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 106.f)];
    
    UIButton *chat = [UIButton buttonWithType:UIButtonTypeCustom];
    [chat setFrame:CGRectMake(CGRectGetMidX(tableviewFootView.frame)-280/2, 4.f, 280, 44.f)];
    [chat addTarget:self action:@selector(beginChat) forControlEvents:UIControlEventTouchUpInside];
    [chat setBackgroundImage:[UIImage imageNamed:@"button_chat"] forState:UIControlStateNormal];
    [tableviewFootView  addSubview:chat];

    UIButton *quit = [UIButton buttonWithType:UIButtonTypeCustom];
    [quit setFrame:CGRectMake(CGRectGetMidX(tableviewFootView.frame)-280/2, CGRectGetMaxY(chat.frame)+10.f, 280, 44.f)];
    [quit addTarget:self action:@selector(quitGroup) forControlEvents:UIControlEventTouchUpInside];
    [quit setBackgroundImage:[UIImage imageNamed:@"button_del"] forState:UIControlStateNormal];
    [tableviewFootView  addSubview:quit];
    
    
    
    _detailTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight-64.f) style:UITableViewStyleGrouped];
    _detailTableview.dataSource = self;
    _detailTableview.delegate = self;
    _detailTableview.tableFooterView = tableviewFootView;
    if (!IOS7) {
        UIView *tableviewBGView = [[UIView alloc] initWithFrame:_detailTableview.frame];
        tableviewBGView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        _detailTableview.backgroundView = tableviewBGView;
    }
    
    _detailTableview.tableHeaderView = _memberDisplayView;
    _detailTableview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_detailTableview];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"quitGroupDic" options:0 context:nil];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupTag" options:0 context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"quitGroupDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupTag"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MemberViewDelegate
- (void)addMemberBtnTapped:(NSArray *)members
{
    ContactsStartGroupChatViewController *contactsGroupChat = [[ContactsStartGroupChatViewController alloc] init];
    contactsGroupChat.msgGroup = self.msgGroup;
    NSMutableArray *tempUserInfos = [NSMutableArray array];
    for (CPUIModelMessageGroupMember *member in members) {
        if (member.userInfo) {
            [tempUserInfos addObject:member.userInfo];
        }
    }
    [contactsGroupChat filterExistUserInfo:YES WithSelectedArray:tempUserInfos];
    [self.navigationController pushViewController:contactsGroupChat animated:YES];
}
#pragma mark - ViewControllerMethod
- (void)refreshMsgGroup
{
    for (CPUIModelMessageGroup *newMsgGroup in [CPUIModelManagement sharedInstance].userMessageGroupList) {
        if ([newMsgGroup.msgGroupID integerValue] == [self.msgGroup.msgGroupID integerValue]) {
            self.msgGroup = newMsgGroup;
            break;
        }
    }
    [_memberDisplayView setMembers:self.msgGroup.memberList];
    
    [self.detailTableview setTableHeaderView:_memberDisplayView];
    [self.detailTableview reloadData];


}

- (NSArray *)getUserInfos
{
    NSMutableArray *userInfos = [[NSMutableArray alloc] init];
    for (CPUIModelMessageGroupMember *member in self.msgGroup.memberList) {
        if (member.userInfo) {
            [userInfos addObject:member.userInfo];
        }
        
    }
    return [NSArray arrayWithArray:userInfos];
}

- (void)backAction
{
    for (id viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[MutilMsgGroupViewController class]]) {
            [(MutilMsgGroupViewController *)viewController refreshMsgGroup];
            [self.navigationController popToViewController:viewController animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)quitGroup
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确认退出吗?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确认",@"取消",nil];
    [alert show];
}

- (void)beginChat
{
    BBMutilIMViewController *mutilIM = [[BBMutilIMViewController alloc] init:self.msgGroup];
    [self.navigationController pushViewController:mutilIM animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self showProgressWithText:@"正在退出..."];
        [[CPUIModelManagement sharedInstance] quitGroupWithGroup:self.msgGroup];
    }
}
#pragma mark - UItableview
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellIden"];
    cell.textLabel.text = @"组名称";
    cell.detailTextLabel.text = groupName;
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}
@end

#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"
#import "CPUIModelUserInfo.h"
#define itemWidth 50.f
#define itemCountInLine 4
#define intervalForImageAndTitle 5.f
#define intervalForItem 10.f

@implementation MutilGroupMemberDisplayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setMembers:(NSArray *)members
{
    /*
    NSMutableArray *tempMembers = [[NSMutableArray alloc] init];
    for (CPUIModelUserInfo *userInfo in members) {
//        if (userInfo.nickName.length > 0 && ![userInfo.nickName isEqualToString:[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName]) {
//            [tempMembers addObject:userInfo];
//        }
        //算自己
            [tempMembers addObject:userInfo];
    }
     */
    _members = [NSArray arrayWithArray:members];
    CGRect tempFrame = self.frame;
    tempFrame.size.height = 18+(itemWidth+14.f+intervalForItem+intervalForImageAndTitle)*[self getItemLines];
    self.frame = tempFrame;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i< self.members.count+1; i++) {
        CGFloat spacing = (320 - itemWidth*itemCountInLine)/(itemCountInLine+1);
        
        CGRect imageFrame =CGRectMake(
                                      spacing + (itemWidth + spacing)*(i-i/itemCountInLine*itemCountInLine),
                                      10.f + (itemWidth+intervalForImageAndTitle+intervalForItem+14.f)*(i/itemCountInLine),
                                      itemWidth, itemWidth);
        
        
        
        if (i == self.members.count) {
            UIButton *addMember = (UIButton *)[self viewWithTag:1000];
            if (!addMember) {
                addMember = [UIButton buttonWithType:UIButtonTypeCustom];
                
                addMember.tag = 1000;
                [addMember setBackgroundImage:[UIImage imageNamed:@"add_group"] forState:UIControlStateNormal];
                [addMember addTarget:self action:@selector(addMemberInGroup) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:addMember];
            }
            [addMember setFrame:imageFrame];

            return;
        }
        
        CPUIModelMessageGroupMember *member = self.members[i];
        CPUIModelUserInfo *userInfo = member.userInfo;
        
        CGRect nickNameFrame = CGRectMake(CGRectGetMinX(imageFrame)-spacing/2, CGRectGetMaxY(imageFrame)+intervalForImageAndTitle, itemWidth+spacing, 14.f);
        
        UIImageView *itemImage = (UIImageView *)[self viewWithTag:100+i];
        if (!itemImage) {
            itemImage = [[UIImageView alloc] initWithFrame:imageFrame];
            itemImage.layer.cornerRadius = 25.f;
            itemImage.layer.masksToBounds = YES;
            itemImage.layer.borderWidth = 1.f;
            itemImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
            itemImage.tag = 100+i;
            [self addSubview:itemImage];
        }
        if (userInfo.headerPath.length) {
            [itemImage setImage:[UIImage imageWithContentsOfFile:userInfo.headerPath]];
        }else
        {
            if (!userInfo.nickName.length || [userInfo.nickName isEqualToString:[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName]) {
                [itemImage setImage:[UIImage imageWithContentsOfFile:[CPUIModelManagement sharedInstance].uiPersonalInfo.selfHeaderImgPath]];
            }else [itemImage setImage:[UIImage imageNamed:@"girl"]];
            
        }

        
        UILabel *itemNickName = (UILabel *)[self viewWithTag:300+i];
        if (!itemNickName) {
            itemNickName = [[UILabel alloc] initWithFrame:nickNameFrame];
            itemNickName.backgroundColor = [UIColor clearColor];
            itemNickName.textAlignment = NSTextAlignmentCenter;
            itemNickName.font = [UIFont systemFontOfSize:12.f];
            itemNickName.textColor = [UIColor lightGrayColor];
            itemNickName.tag = 300+i;
            [self addSubview:itemNickName];
        }
        itemNickName.text = userInfo.nickName.length ? userInfo.nickName : [CPUIModelManagement sharedInstance].uiPersonalInfo.nickName;
    }
    
}

- (void)addMemberInGroup
{
    if ([self.delegate respondsToSelector:@selector(addMemberBtnTapped:)]) {
        [self.delegate addMemberBtnTapped:self.members];
    }
}

- (NSInteger)getItemLines
{
    NSInteger itemCount = self.members.count+1;
    NSInteger lines = itemCount%itemCountInLine == 0 ? itemCount/itemCountInLine : itemCount/itemCountInLine + 1;
    return lines;
}
@end
