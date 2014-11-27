//
//  BBServiceMessageDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14/11/26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageDetailViewController.h"

@interface BBServiceMessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *detailTableView;

@end

@implementation BBServiceMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *detail = [UIButton buttonWithType:UIButtonTypeCustom];
    [detail setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [detail setBackgroundImage:[UIImage imageNamed:@"user_alt"] forState:UIControlStateNormal];
    [detail addTarget:self action:@selector(detailButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detail];
    
    _detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight) style:UITableViewStyleGrouped];
    _detailTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 1.f)];
    _detailTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    [self.view addSubview:_detailTableView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - ViewCOntroller
- (void)backButtonTaped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)detailButtonTaped
{
    
}

#pragma mark - UITableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
