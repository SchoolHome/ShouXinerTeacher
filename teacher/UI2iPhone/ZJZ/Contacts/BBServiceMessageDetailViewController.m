//
//  BBServiceMessageDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14/11/26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageDetailViewController.h"
#import "BBServiceAccountDetailViewController.h"
#import "BBServiceMessageWebViewController.h"

#import "BBServiceMessageDetailView.h"

#import "CPDBManagement.h"
#import "BBServiceMessageDetailModel.h"
@interface BBServiceMessageDetailViewController ()<BBServiceMessageDetailViewDelegate>

@property (nonatomic, strong) UIScrollView *detailScrollview;
@property (nonatomic, strong) NSArray *messages;
@end

@implementation BBServiceMessageDetailViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self closeProgress];
    if ([keyPath isEqualToString:@"publicMessageResult"]) {
        NSDictionary *result = [PalmUIManagement sharedInstance].publicMessageResult;
        
        if (![result[@"hasError"] boolValue]) {
            NSDictionary *data = result[@"data"];
            NSDictionary *list = data[@"list"];
            [self filterData:list];
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
    
    _detailScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(10.f, 0.f, self.screenWidth-20.f, self.screenHeight-70.f)];
    _detailScrollview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_detailScrollview];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModel:(CPDBModelNotifyMessage *)model
{
    _model = model;
    if (model.from.length > 0) {
        self.title = model.fromUserName;
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
    BBServiceAccountDetailViewController *detail = [[BBServiceAccountDetailViewController alloc] initWithModel:self.model];
    [self.navigationController pushViewController:detail animated:YES];
}


- (void)filterData:(NSDictionary *)fullData
{
    NSMutableArray *tempMessages = [[NSMutableArray alloc] init];
    for (NSString *key in fullData.allKeys) {
        NSArray *tempValue = fullData[key];
        if ([tempValue isKindOfClass:[NSArray class]])
        {
                NSMutableArray *subItems = [[NSMutableArray alloc]initWithCapacity:4];
                for (int i = 0 ; i < tempValue.count; i++) {
                    NSDictionary *dic = tempValue[i];
                    [subItems addObject:[BBServiceMessageDetailModel convertByDic:dic]];
                }
                [tempMessages addObject:subItems];
        }
    }
    self.messages = [NSArray arrayWithArray:tempMessages];
    
    [self reloadData];
}

- (void)reloadData
{
    int singeViews = 0;
    int mutilViews = 0;
    CGFloat singeViewHeight = 220.f;
    CGFloat MutilViewHeight = 220.f;
    for (int i = 0; i<self.messages.count; i++) {
        NSArray *tempArray = self.messages[i];
        CGRect frame;
        if (tempArray.count == 1) {
            frame = CGRectMake(0.f, singeViewHeight*singeViews+MutilViewHeight*mutilViews, CGRectGetWidth(self.detailScrollview.frame), singeViewHeight);
            singeViews++;
        }else
        {
            frame = CGRectMake(0.f, singeViewHeight*singeViews+MutilViewHeight*mutilViews, CGRectGetWidth(self.detailScrollview.frame), singeViewHeight);
            mutilViews++;
        }
        BBServiceMessageDetailView *detailView = [[BBServiceMessageDetailView alloc] initWithFrame:frame];
        detailView.delegate = self;
        [detailView setModels:tempArray];
        [self.detailScrollview addSubview:detailView];
    }
    
    [self.detailScrollview setContentSize:CGSizeMake(self.screenWidth-20.f, singeViewHeight*singeViews+MutilViewHeight*mutilViews)];
}

- (void)itemSelected:(BBServiceMessageDetailModel *)model
{
    BBServiceMessageWebViewController *messageWeb = [[BBServiceMessageWebViewController alloc] init];
    [messageWeb setModel:model];
    [self.navigationController pushViewController:messageWeb animated:YES];
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
