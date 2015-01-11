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
#import "BBMeSettingViewController.h"
#import "BBMeWebViewController.h"
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
#import "BBProfileModel.h"

@interface BBMeViewController ()<UIAlertViewDelegate>
{
    UIButton *headerImgBtn;
    BBProfileModel *profileModel;
}
@end

@implementation BBMeViewController
-(id)init{
    self = [super init];
    if (self) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"userProfile" options:0 context:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] getUserProfile];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 不要移除，用户其他页面更新头像后，此页面同步更新
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"uiPersonalInfoTag" options:0 context:NULL];
    
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"我";
    
    listData = [[NSArray alloc] initWithObjects:
                [NSArray arrayWithObjects://[NSDictionary dictionaryWithObjectsAndKeys:@"手心商城", @"title", @"http://www.shouxiner.com/teacher_jfen/mobile_web_shop", @"url", @"shop.png", @"icon", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"荣誉档案", @"title", @"http://www.shouxiner.com/webview/group_awards", @"url", @"star.png", @"icon", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"成长中心", @"title", @"http://www.shouxiner.com/webview/medal_list", @"url", @"grow.png", @"icon", nil],
                 nil],
                [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"设置", @"title", @"", @"url", @"set_up.png", @"icon", nil], nil],
                nil];
    
    meTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.screenHeight-49-44-20)
                                               style:UITableViewStyleGrouped];
    [meTableView setDelegate:(id<UITableViewDelegate>)self];
    [meTableView setDataSource:(id<UITableViewDataSource>)self];
  //  [meTableView setSeparatorColor:[UIColor clearColor]];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, meTableView.frame.size.width, meTableView.frame.size.height)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.0f]];
    [meTableView setBackgroundView:backgroundView];
    backgroundView = nil;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 170)];
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:headerView.bounds];
    [bgImage setImage:[UIImage imageNamed:@"BBTopBGNew.png"]];
    [headerView addSubview:bgImage];
    bgImage = nil;
    headerImgBtn = [[UIButton alloc] initWithFrame:CGRectMake((headerView.frame.size.width-80)/2, (headerView.frame.size.height-80)/2, 80, 80)];
    [headerImgBtn setContentMode:UIViewContentModeScaleAspectFit];
    [headerImgBtn setUserInteractionEnabled:NO];
    [headerImgBtn addTarget:self action:@selector(clickInfoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerImgBtn];
    [meTableView setTableHeaderView:headerView];
    
    NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
    if (path) {
        [headerImgBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    }else{
        [headerImgBtn setImage:[UIImage imageNamed:@"girl.png"]forState:UIControlStateNormal];
    }
    [headerImgBtn.layer setCornerRadius:40];
    [headerImgBtn.layer setBorderWidth:2];
    [headerImgBtn.layer setMasksToBounds:YES];
    [headerImgBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, meTableView.frame.size.width, 60)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setFrame:CGRectMake((meTableView.frame.size.width-280)/2, 8, 280, 44)];
    [logoutBtn setImage:[UIImage imageNamed:@"sign_out.png"] forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutApp:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:logoutBtn];
    [meTableView setTableFooterView:footerView];
    
    [self.view addSubview:meTableView];
}

-(void)clickInfoBtn:(UITapGestureRecognizer *)tap
{
    BBMeProfileController *viewController = [[BBMeProfileController alloc] init];
    [viewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [listData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[listData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)return 0;
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MeCell = @"meCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MeCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MeCell];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        /*UIImageView *separatorLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-247, 43, 247, 1)];
        //[separatorLine setImage:[UIImage imageNamed:@""]];
        [separatorLine setBackgroundColor:[UIColor grayColor]];
        [cell addSubview:separatorLine];*/
        [cell.textLabel setTextColor:[UIColor colorWithRed:39.f/255.f green:39.f/255.f blue:39.f/255.f alpha:1.0f]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14.f]];
    }
    NSArray *dataList = [listData objectAtIndex:indexPath.section];
    NSDictionary *dataDic = [dataList objectAtIndex:indexPath.row];
    
    [cell.textLabel setText:[dataDic objectForKey:@"title"]];
    [cell.imageView setImage:[UIImage imageNamed:[dataDic objectForKey:@"icon"]]];
    /*
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
    }*/
    [cell setNeedsDisplay];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataList = [listData objectAtIndex:indexPath.section];
    NSDictionary *dataDic = [dataList objectAtIndex:indexPath.row];
    if ([[dataDic objectForKey:@"url"] length]>0) {
        BBMeWebViewController *viewController = [[BBMeWebViewController alloc] init];
        [viewController setHidesBottomBarWhenPushed:YES];
        [viewController.navigationItem setTitle:[dataDic objectForKey:@"title"]];
        viewController.url = [NSURL URLWithString:[dataDic objectForKey:@"url"]];
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        BBMeSettingViewController *viewController = [[BBMeSettingViewController alloc] init];
        [viewController setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:viewController animated:YES];
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
        [headerImgBtn setUserInteractionEnabled:YES];
        NSDictionary *userProfile = [[PalmUIManagement sharedInstance].userProfile objectForKey:ASI_REQUEST_DATA];
        if (!profileModel) {
            profileModel = [BBProfileModel shareProfileModel];
        }
        [profileModel coverWithJson:userProfile];
        //查询用户商城积分
        self.navigationItem.title = profileModel.username;
        [meTableView reloadData];
    }
    /*
    if ([@"userCredits" isEqualToString:keyPath]) {
        NSDictionary *userCredits = [[PalmUIManagement sharedInstance].userCredits objectForKey:ASI_REQUEST_DATA];
        if (![[userCredits objectForKey:@"error"] integerValue]) {
            if (meTableView) {
                [meTableView reloadData];
            }
        }
    }*/
    if ([@"uiPersonalInfoTag" isEqualToString:keyPath]) {
        //[meTableView reloadData];
        NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
        if (path) {
            [headerImgBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
        }else{
            [headerImgBtn setImage:[UIImage imageNamed:@"girl.png"]forState:UIControlStateNormal];
        }
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
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"uiPersonalInfoTag"];
}

@end
