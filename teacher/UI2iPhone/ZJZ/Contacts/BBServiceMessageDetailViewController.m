//
//  BBServiceMessageDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14/11/26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageDetailViewController.h"
#import "BBServiceAccountDetailViewController.h"

#import "BBServiceMessageDetailTableViewCell.h"


#import "CPDBManagement.h"

@interface BBServiceMessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *detailTableView;

@end

@implementation BBServiceMessageDetailViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self closeProgress];
    if ([keyPath isEqualToString:@"publicMessageResult"]) {
        NSDictionary *result = [PalmUIManagement sharedInstance].publicMessageResult;
        
        if (![result[@"hasError"] boolValue]) {
            NSDictionary *data = result[@"data"];
            NSArray *list = data[@"list"];
        }else{
            [self showProgressWithText:@"获取消息失败,请重试" withDelayTime:1];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"publicMessageResult" options:0 context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"publicMessageResult"];
}

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

- (void)setModel:(CPDBModelNotifyMessage *)model
{
    _model = model;
    if (model.mid.length > 0) {
        //findNotifyMessagesOfCurrentFromJID
        NSArray *models = [[[CPSystemEngine sharedInstance] dbManagement] findNotifyMessagesOfCurrentFromJID:self.model.from];
        NSString *mids;
        for (int i = 0; i< models.count; i++) {
            CPDBModelNotifyMessage *message = models[i];
            if (message) {
                if (i == 0) mids = message.mid;
                else mids = [mids stringByAppendingFormat:@",%@",message.mid];
            }
        }
        [self showProgressWithText:@"正在获取..."];
        [[PalmUIManagement sharedInstance] getPublicMessage:mids];
    }
}
#pragma mark - ViewCOntroller
- (void)backButtonTaped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)detailButtonTaped
{
    BBServiceAccountDetailViewController *detail = [[BBServiceAccountDetailViewController alloc] initWithModel:nil];
    [self.navigationController pushViewController:detail animated:YES];
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
    BBServiceMessageDetailTableViewCell *cell = [[BBServiceMessageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    return cell;
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
