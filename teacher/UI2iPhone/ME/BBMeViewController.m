//
//  BBMeViewController.m
//  teacher
//
//  Created by mac on 14-3-11.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeViewController.h"
#import "BBMeTableViewCell.h"
#import "BBMeProfileController.h"
#import "BBShopViewController.h"
#import "BBHelpViewController.h"
#import "BBFeedbackViewController.h"
#import "BBHonorViewController.h"
#import "ContactsViewController.h"
#import "EGOImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "CPUIModelManagement.h"
#import "AppDelegate.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"

@interface BBMeViewController ()<UIAlertViewDelegate>

@end

@implementation BBMeViewController
-(id)init{
    self = [super init];
    if (self) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"userProfile" options:0 context:nil];
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"userCredits" options:0 context:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] getUserProfile];
    userProfile = nil;
    userCredits = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 不要移除，用户其他页面更新头像后，此页面同步更新
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"uiPersonalInfoTag" options:0 context:NULL];
    
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"我";
    
    listData = [[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@"我的商城", @"班级荣誉", @"我的通讯录", nil],
                [NSArray arrayWithObjects:@"软件更新", @"帮助中心", @"反馈和建议", nil], nil];
    
    
    meTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.screenHeight-49-44-20)
                                               style:UITableViewStyleGrouped];
    [meTableView setDelegate:(id<UITableViewDelegate>)self];
    [meTableView setDataSource:(id<UITableViewDataSource>)self];
    [meTableView setSeparatorColor:[UIColor colorWithRed:0.718f green:0.718f blue:0.718f alpha:1.0f]];
    
    UIView *tableBackView = [[UIView alloc] initWithFrame:meTableView.bounds];
    [tableBackView setBackgroundColor:[UIColor colorWithRed:0.961f green:0.941f blue:0.921f alpha:1.0f]];
    [meTableView setBackgroundView:tableBackView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, meTableView.frame.size.width, 60)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setFrame:CGRectMake(10, 10, meTableView.frame.size.width-20, 30)];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setBackgroundColor:[UIColor redColor]];
    [logoutBtn addTarget:self action:@selector(logoutApp:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutBtn];
    [meTableView setTableFooterView:footerView];
    
    [self.view addSubview:meTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [listData count]+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 1;
    if (section == 0) {
        rowCount = 1;
    }else{
        rowCount = [[listData objectAtIndex:section-1] count];
    }
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 44;
    if (indexPath.section == 0) {
        cellHeight = 90;
    }
    return cellHeight;
}

- (BBMeTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MeCell = @"meCell";
    BBMeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MeCell];
    if (cell == nil) {
        cell = [[BBMeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MeCell];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        if ([self currentVersion] == kIOS7){
#ifdef __IPHONE_7_0
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
#endif
        }
    }
    if (indexPath.section == 0) {
        [cell.headerImageView.layer setCornerRadius:35];
        [cell.headerImageView.layer setMasksToBounds:YES];
        NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
        if (path) {
            cell.headerImageView.image = [UIImage imageWithContentsOfFile:path];
        }else{
            [cell.headerImageView setImage:[UIImage imageNamed:@"girl.png"]];
        }
//        //网络读取头像
//        if (userProfile && [userProfile objectForKey:@"avatar"] != [NSNull null] && ![[userProfile objectForKey:@"avatar"] isEqualToString:@""]) {
//            NSLog(@"%@", [userProfile objectForKey:@"avatar"]);
//            NSMutableString *userAvatar = [[NSMutableString alloc] initWithString:[userProfile objectForKey:@"avatar"]];
//#ifdef TEST
//            NSRange range = [userAvatar rangeOfString:@"att0.shouxiner.com"];
//            if (range.length>0) {
//                [userAvatar replaceCharactersInRange:range withString:@"115.29.224.151"];
//            }
//#endif
//            [cell.headerImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", userAvatar]]];
//        }else{
//            [cell.headerImageView setImage:[UIImage imageNamed:@"girl.png"]];
//        }
        
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        [cell.textLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
        if (userProfile) {
            [cell.textLabel setText:[userProfile objectForKey:@"username"]];
        }
    }else{
        NSInteger section = indexPath.section - 1;
        [cell.textLabel setText:[[listData objectAtIndex:section] objectAtIndex:indexPath.row]];
        if (indexPath.section == 1 && indexPath.row == 0) {
            [[cell.contentView viewWithTag:501] removeFromSuperview];
            [[cell.contentView viewWithTag:502] removeFromSuperview];
            if (userCredits) {
                if ([[userCredits objectForKey:@"credits"] integerValue]) {
                    UIImage *image = [UIImage imageNamed:@"user_credit_back.png"];
                    
                    UIImageView *creditImage = [[UIImageView alloc] init];
                    UILabel *labelNum = [[UILabel alloc] init];
                    [creditImage setTag:501];
                    [labelNum setTag:502];
                    [labelNum setTextAlignment:NSTextAlignmentCenter];
                    [labelNum setBackgroundColor:[UIColor clearColor]];
                    [labelNum setTextColor:[UIColor colorWithRed:0.204f green:0.576f blue:0.871 alpha:1.0f]];
                    [cell.contentView addSubview:creditImage];
                    [cell.contentView addSubview:labelNum];
                    
                    NSString *strCredits = [NSString stringWithFormat:@"%@", [userCredits objectForKey:@"credits"]];
                    UIFont *font = [UIFont fontWithName:@"Arial" size:16];
                    CGSize size = [strCredits sizeWithFont:font constrainedToSize:CGSizeMake(150, 20.0f)];
                    if (size.width < 10) {
                        size.width = 10;
                    }
                    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];

                    [labelNum setFrame:CGRectMake(260-size.width-10, 12, size.width+10, 20)];
                    [creditImage setFrame:labelNum.frame];
                    [creditImage setImage:image];
                    [labelNum setFont:font];
                    [labelNum setText:strCredits];
                }
            }
        }
    }
    [cell setNeedsDisplay];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (userProfile) {
                BBMeProfileController *profileController = [[BBMeProfileController alloc] init];
                profileController.hidesBottomBarWhenPushed = YES;
                profileController.userProfile = userProfile;
                [self.navigationController pushViewController:profileController animated:YES];
            }
        }
            break;
        case 1:
        {
            if (indexPath.row == 0) {//商城
                BBShopViewController *shopViewController = [[BBShopViewController alloc] init];
                shopViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:shopViewController animated:YES];
            }else if(indexPath.row == 1) {//荣誉
                BBHonorViewController *honorViewController = [[BBHonorViewController alloc] init];
                honorViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:honorViewController animated:YES];
            }else{//通讯录
                ContactsViewController *contactsViewController = [[ContactsViewController alloc] init];
                contactsViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:contactsViewController animated:YES];
                /*
                BBAddressBookViewController *addressBookViewController = [[BBAddressBookViewController alloc] init];
                addressBookViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:addressBookViewController animated:YES];
                 */
            }
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {//更新
                [[PalmUIManagement sharedInstance] postCheckVersion];
            }else if (indexPath.row == 1) {//帮助
                BBHelpViewController *helpViewController = [[BBHelpViewController alloc] init];
                helpViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:helpViewController animated:YES];
            }else {//反馈
                BBFeedbackViewController *feedbackViewController = [[BBFeedbackViewController alloc] init];
                feedbackViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:feedbackViewController animated:YES];
            }
        }
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"userProfile" isEqualToString:keyPath]){
        userProfile = [[PalmUIManagement sharedInstance].userProfile objectForKey:ASI_REQUEST_DATA];
        //查询用户商城积分
        [[PalmUIManagement sharedInstance] getUserCredits];
    }
    if ([@"userCredits" isEqualToString:keyPath]) {
        userCredits = [[PalmUIManagement sharedInstance].userCredits objectForKey:ASI_REQUEST_DATA];
        if (![[userCredits objectForKey:@"error"] integerValue]) {
            if (meTableView) {
                [meTableView reloadData];
            }
        }
    }
    if ([@"uiPersonalInfoTag" isEqualToString:keyPath]) {
        [meTableView reloadData];
    }
}

-(void)logoutApp:(UIButton *)btn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"退出" message:@"是否确认退出登录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[CPUIModelManagement sharedInstance] logout];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate launchLogin];
    }
}

-(void)dealloc
{
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"userProfile"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"userCredits"];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"uiPersonalInfoTag"];
}

@end
