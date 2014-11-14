//
//  MutilMsgGroupViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "MutilMsgGroupViewController.h"
#import "ContactsStartGroupChatViewController.h"

#import "CPUIModelMessageGroup.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"

#import "ImageUtil.h"
@interface MutilMsgGroupViewController ()
{
    NSArray *mutilMsgGroups;
}
@end

@implementation MutilMsgGroupViewController

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
    
    UITableView *tableview= [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.screenHeight-89.f) style:UITableViewStyleGrouped];
    tableview.backgroundColor = [UIColor clearColor];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
    tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableview];
    // Do any additional setup after loading the view.
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

#pragma mark - UITableview
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


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
    return 10.f;
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
