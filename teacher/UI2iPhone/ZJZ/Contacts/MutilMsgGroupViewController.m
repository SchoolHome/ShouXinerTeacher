//
//  MutilMsgGroupViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "MutilMsgGroupViewController.h"
#import "ContactsStartGroupChatViewController.h"
#import "MutilGroupDetailViewController.h"

#import "CPUIModelManagement.h"
#import "CPUIModelMessageGroup.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"

#import "ImageUtil.h"
@interface MutilMsgGroupViewController ()
{
    NSArray *mutilMsgGroups;
    UITableView *groupTableview;
    
    BOOL alreadyQuitGroup;
}
@end

@implementation MutilMsgGroupViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if([keyPath isEqualToString:@"quitGroupDic"]){
        if (alreadyQuitGroup) {
            return;
        }
        if ([[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_code]integerValue]== RESPONSE_CODE_SUCESS) {
            [self closeProgress];
            NSMutableArray *tempMutilMsgGroups = [[NSMutableArray alloc] init];
            for (CPUIModelMessageGroup *group in [CPUIModelManagement sharedInstance].userMessageGroupList) {
                if ([group isKindOfClass:[CPUIModelMessageGroup class]]) {
                    if (![group isMsgSingleGroup]) {
                        [tempMutilMsgGroups addObject:group];
                    }
                }
            }
            
            mutilMsgGroups = tempMutilMsgGroups;
            [groupTableview reloadData];
        }else {
            [self showProgressWithText:[[CPUIModelManagement sharedInstance].quitGroupDic objectForKey:group_manage_dic_res_desc] withDelayTime:3.f];
        }
            alreadyQuitGroup = YES;
    }
    
    //quitGroupDic无效时备用
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        if ([CPUIModelManagement sharedInstance].userMsgGroupTag == UPDATE_USER_GROUP_TAG_DEL) {
            if (alreadyQuitGroup) {
                return;
            }
            [self closeProgress];
            NSMutableArray *tempMutilMsgGroups = [[NSMutableArray alloc] init];
            for (CPUIModelMessageGroup *group in [CPUIModelManagement sharedInstance].userMessageGroupList) {
                if ([group isKindOfClass:[CPUIModelMessageGroup class]]) {
                    if (![group isMsgSingleGroup]) {
                        [tempMutilMsgGroups addObject:group];
                    }
                }
            }
            
            mutilMsgGroups = tempMutilMsgGroups;
            [groupTableview reloadData];
            
            alreadyQuitGroup = YES;
        }
    }
}

- (id)initWithMutilMsgGroups : (NSArray *)msgGroups
{
    self = [super init];
    if (self) {
        mutilMsgGroups = [NSArray arrayWithArray:msgGroups];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"讨论组";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"addGroup"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addMsgGroup) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
   groupTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.screenHeight-64.f) style:UITableViewStylePlain];
    groupTableview.backgroundColor = [UIColor clearColor];
    groupTableview.delegate = self;
    groupTableview.dataSource = self;
    if (IOS7) {
        groupTableview.tableHeaderView =  [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
    }
    
    groupTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    groupTableview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:groupTableview];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"quitGroupDic" options:0 context:nil];
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupTag" options:0 context:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [groupTableview setEditing:NO];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"quitGroupDic"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupTag"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ViewControllerMethod
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addMsgGroup
{
    ContactsStartGroupChatViewController *groupChat = [[ContactsStartGroupChatViewController alloc] init];
    [self.navigationController pushViewController:groupChat animated:YES];
}

- (void)refreshMsgGroup
{
    NSMutableArray *tempMutilMsgGroups = [[NSMutableArray alloc] init];
    for (CPUIModelMessageGroup *group in [CPUIModelManagement sharedInstance].userMessageGroupList) {
        if ([group isKindOfClass:[CPUIModelMessageGroup class]]) {
            if (![group isMsgSingleGroup]) {
                [tempMutilMsgGroups addObject:group];
            }
        }
    }
    mutilMsgGroups = [NSArray arrayWithArray:tempMutilMsgGroups];
    [groupTableview reloadData];
}

#pragma mark - UITableview
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CPUIModelMessageGroup *msgGroup = mutilMsgGroups[indexPath.row];
    if (msgGroup) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        MutilGroupDetailViewController *msgGroupDetail = [[MutilGroupDetailViewController alloc] initWithMsgGroup:msgGroup andGroupName:cell.textLabel.text andFromType:GROUP_MEMBER_FROM_TYPE_NORMAL];
        [self.navigationController pushViewController:msgGroupDetail animated:YES];
    }else [self showProgressWithText:@"当前会话不存在" withDelayTime:3.f];

}
#pragma mark UItableviewDatasouce
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mutilMsgGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageGroupCellIdentifier = @"messageGroupCellIdentifier";
    
    CPUIModelMessageGroup *tempMsgGroup = [mutilMsgGroups objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageGroupCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageGroupCellIdentifier];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    }
    if (tempMsgGroup) {
        if (tempMsgGroup.memberList.count > 1) {
            NSArray *array = [NSArray arrayWithArray:tempMsgGroup.memberList];;
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
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@等%d人",title,tempMsgGroup.memberList.count];
            
            
        }else cell.textLabel.text = @"群聊";
        
        cell.imageView.image = [UIImage groupHeader:tempMsgGroup];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return IOS7?1.f : 0.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showProgressWithText:@"正在删除..."];
    CPUIModelMessageGroup *msgGroup = mutilMsgGroups[indexPath.row];
    [[CPUIModelManagement sharedInstance] quitGroupWithGroup:msgGroup];
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
