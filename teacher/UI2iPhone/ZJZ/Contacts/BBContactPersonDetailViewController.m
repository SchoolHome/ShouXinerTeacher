//
//  BBContactPersonDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBContactPersonDetailViewController.h"

#import "BBSingleIMViewController.h"

#import "CPUIModelManagement.h"

@interface BBContactPersonDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)ContactsModel *userInfo;

@end

@implementation BBContactPersonDetailViewController



- (id)initWithUserInfo:(ContactsModel *)tempUserInfo
{
    self = [super init];
    if (self) {
        self.userInfo = tempUserInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详细资料";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIView *tableviewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 90.f)];
    
    UIImageView *head = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, 70.f, 70.f)];
    if (self.userInfo.avatarPath.length > 0) {
        [head setImage:[UIImage imageWithContentsOfFile:self.userInfo.avatarPath]];
        head.layer.masksToBounds = YES;
        head.layer.cornerRadius = 35.f;
        head.layer.borderColor = [[UIColor whiteColor] CGColor];
        head.layer.borderWidth = 2.f;
    }else
    {
        [head setImage:[UIImage imageNamed:@"girl"]];
    }
    [tableviewHeaderView addSubview:head];
    
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(head.frame)+16.f, CGRectGetMidY(head.frame)-12.f,self.screenWidth-CGRectGetMaxX(head.frame)-10.f , 24.f)];
    nickName.text = self.userInfo.userName;
    nickName.backgroundColor = [UIColor clearColor];
    [tableviewHeaderView addSubview:nickName];
    
    UIView *tableviewFootView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 50.f)];
    
    UIButton *chat = [UIButton buttonWithType:UIButtonTypeCustom];
    [chat setFrame:CGRectMake(CGRectGetMidX(tableviewFootView.frame)-280/2, 4.f, 280, 44.f)];
    [chat addTarget:self action:@selector(beginChat) forControlEvents:UIControlEventTouchUpInside];
    [chat setBackgroundImage:[UIImage imageNamed:@"button_chat"] forState:UIControlStateNormal];
    [tableviewFootView  addSubview:chat];

    
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight-40.f) style:UITableViewStyleGrouped];
    tableview.scrollEnabled = NO;
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableHeaderView = tableviewHeaderView;
    tableview.tableFooterView = tableviewFootView;
    if (!IOS7) {
        UIView *tableviewBGView = [[UIView alloc] initWithFrame:tableview.frame];
        tableviewBGView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        tableview.backgroundView = tableviewBGView;
    }
    [self.view addSubview:tableview];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"createMsgGroupTag" options:0 context:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"createMsgGroupTag"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)beginChat
{
    CPUIModelUserInfo *tempUserInfo = [self getUserInfoByModelID:self.userInfo.modelID];
    if (tempUserInfo) {
        [self showProgressWithText:@"正在发起聊天..."];
        [[CPUIModelManagement sharedInstance] createConversationWithUsers:[NSArray arrayWithObject:tempUserInfo] andMsgGroups:nil andType:CREATE_CONVER_TYPE_COMMON];
    }else {
        [self showProgressWithText:@"发起聊天失败" withDelayTime:2.f];
    }

}

- (void)backButtonTaped
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Data
- (CPUIModelUserInfo *)getUserInfoByModelID:(NSInteger)modelID
{
    for (CPUIModelUserInfo *userInfo in [CPUIModelManagement sharedInstance].friendArray) {
        if ([userInfo.lifeStatus integerValue] == modelID) {
            return userInfo;
        }
    }
    return nil;
}
#pragma mark - Observer
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
        [self closeProgress];
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

#pragma mark - UITableview
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 2 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"baseCellIden"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.backgroundColor = [UIColor whiteColor];
    
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = indexPath.row == 0 ? @"性别":@"地区";
            NSString *sexTitle = [self.userInfo.sex integerValue] == 1 ? @"男" : @"女";
            cell.detailTextLabel.text = indexPath.row == 0 ? sexTitle:self.userInfo.cityName;
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"个性签名";
            cell.detailTextLabel.text = self.userInfo.sign;
        }
            break;
        default:
            break;
    }
    
    
    
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
