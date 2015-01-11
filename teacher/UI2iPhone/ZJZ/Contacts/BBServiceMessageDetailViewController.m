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
{

}
@property (nonatomic, strong) UIScrollView *detailScrollview;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSString *lastestMid;
@end

@implementation BBServiceMessageDetailViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"publicAccountMessages"]) {
        NSDictionary *result = [PalmUIManagement sharedInstance].publicAccountMessages;
        
        if (![result[@"hasError"] boolValue]) {
            [self closeProgress];
            NSDictionary *data = result[@"data"];
            NSDictionary *list = data[@"list"];
            [self filterData:list];
            
        }else{
            
            [self showProgressWithText:@"获取消息失败,请重试" withDelayTime:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if (self.loadStatus == AccountMessageLoadStatusAppend) {
            [self.detailScrollview.infiniteScrollingView stopAnimating];
        }else if (self.loadStatus == AccountMessageLoadStatusRefresh)
        {
            [self.detailScrollview.pullToRefreshView stopAnimating];
        }
        
        
        
    }
    
    if ([keyPath isEqualToString:@"publicMessageResult"]) {
        NSDictionary *result = [PalmUIManagement sharedInstance].publicMessageResult;

        if (![result[@"hasError"] boolValue]) {
            [self closeProgress];
            NSDictionary *data = result[@"data"];
            NSDictionary *list = data[@"list"];
            [self filterData:list];
        }else{
            
            [self showProgressWithText:@"获取消息失败,请重试" withDelayTime:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.infoStatus == AccountInfoStatusExist) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"publicAccountMessages" options:0 context:nil];
    }else   [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"publicMessageResult" options:0 context:nil];


}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.infoStatus == AccountInfoStatusExist) [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"publicAccountMessages"];
    else [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"publicMessageResult"];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lastestMid = @"";
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    if (self.infoStatus == AccountInfoStatusExist) {
        // right
        UIButton *detail = [UIButton buttonWithType:UIButtonTypeCustom];
        [detail setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
        [detail setBackgroundImage:[UIImage imageNamed:@"user_alt"] forState:UIControlStateNormal];
        [detail addTarget:self action:@selector(detailButtonTaped) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detail];
    }

    
    
    _detailScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(15.f, 0.f, self.screenWidth-30.f, self.screenHeight-70.f)];
    _detailScrollview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_detailScrollview];
    // Do any additional setup after loading the view.
    
    if (self.infoStatus == AccountInfoStatusExist) {
        __weak BBServiceMessageDetailViewController *weakSelf = self;
        // 刷新
        [_detailScrollview addPullToRefreshWithActionHandler:^{
            weakSelf.loadStatus = AccountMessageLoadStatusRefresh;
            [[PalmUIManagement sharedInstance] getPublicAccountMessages:weakSelf.model.accountID withMid:@"" withSize:10];
        }];
        
        // 追加
        [_detailScrollview addInfiniteScrollingWithActionHandler:^{
            if (![weakSelf.lastestMid isEqualToString:@""]) {
                weakSelf.loadStatus = AccountMessageLoadStatusAppend;
                [[PalmUIManagement sharedInstance] getPublicAccountMessages:weakSelf.model.accountID withMid:weakSelf.lastestMid withSize:10];
            }
        }];
        
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNotifyMsgmodel:(CPDBModelNotifyMessage *)notifyMsgmodel
{
    self.infoStatus = AccountInfoStatusMiss;
     _notifyMsgmodel  = notifyMsgmodel;
     if (notifyMsgmodel.from.length > 0) {
     self.title = notifyMsgmodel.fromUserName;
     //findNotifyMessagesOfCurrentFromJID
     NSArray *models = [[[CPSystemEngine sharedInstance] dbManagement] findNotifyMessagesOfCurrentFromJID:self.notifyMsgmodel.from];
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

- (void)setModel:(BBServiceAccountModel *)model
{
    self.infoStatus = AccountInfoStatusExist;
    
    _model = model;
    self.title = model.accountName;
    
    [self showProgressWithText:@"正在获取..."];
    [[PalmUIManagement sharedInstance] getPublicAccountMessages:model.accountID withMid:@"" withSize:10];

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
    //转model
    
    NSMutableArray *tempMessages = [[NSMutableArray alloc] init];
    
    for (NSString *key in fullData.allKeys) {
        NSArray *tempValue = fullData[key];
        if ([tempValue isKindOfClass:[NSArray class]])
        {
                NSMutableArray *subItems = [[NSMutableArray alloc]initWithCapacity:4];
                for (int i = 0 ; i < tempValue.count; i++) {
                    NSDictionary *dic = tempValue[i];
                    BBServiceMessageDetailModel *tempModel = [BBServiceMessageDetailModel convertByDic:dic];
                    [subItems addObject:tempModel];
                    if (i == tempValue.count-1) {
                        self.lastestMid = tempModel.mid;
                    }
                }
                [tempMessages addObject:subItems];
        }
    }
    
    if (self.loadStatus == AccountMessageLoadStatusAppend) {
        [tempMessages addObjectsFromArray:self.messages];
    }
    
    //时间排序
    for (NSArray *tempItemArray in tempMessages) {
        if (tempItemArray.count > 1) {
            [tempItemArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                BBServiceMessageDetailModel *tempModel1 = (BBServiceMessageDetailModel*) obj1;
                BBServiceMessageDetailModel *tempModel2 = (BBServiceMessageDetailModel*) obj2;
                return tempModel1.type < tempModel2.type;
            }];
        }
    }
    
    
    [tempMessages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray *tempObj1 = (NSArray *)obj1;
        NSArray *tempObj2 = (NSArray *)obj2;
        BBServiceMessageDetailModel *tempModel1;
        BBServiceMessageDetailModel *tempModel2;
        tempModel1 = tempObj1.count == 1 ? tempObj1[0] : tempObj1[0][0];
        tempModel2 = tempObj2.count == 1 ? tempObj2[0] : tempObj2[0][0];
        
        return tempModel1.ts.integerValue < tempModel2.ts.integerValue;
    }];
    self.messages = [NSArray arrayWithArray:tempMessages];
    
    [self reloadData];
}

- (void)reloadData
{
    for (id view in self.detailScrollview.subviews) {
        if ([view isKindOfClass:[BBServiceMessageDetailView class]]) {
            [view removeFromSuperview];
        }
        
    }
    
    int singeViews = 0;
    int mutilViews = 0;
    CGFloat singeViewHeight = 240.f;
    CGFloat MutilViewHeight = 284.f;
    for (int i = 0; i<self.messages.count; i++) {
        NSArray *tempArray = self.messages[i];
        CGRect frame;
        if (tempArray.count == 1) {
            frame = CGRectMake(0.f, singeViewHeight*singeViews+MutilViewHeight*mutilViews, CGRectGetWidth(self.detailScrollview.frame), singeViewHeight);
            singeViews++;
        }else
        {
            frame = CGRectMake(0.f, singeViewHeight*singeViews+MutilViewHeight*mutilViews, CGRectGetWidth(self.detailScrollview.frame), MutilViewHeight);
            mutilViews++;
        }
        BBServiceMessageDetailView *detailView = [[BBServiceMessageDetailView alloc] initWithFrame:frame];
        detailView.delegate = self;
        [detailView setModels:tempArray];
        [self.detailScrollview addSubview:detailView];
    }
    
    [self.detailScrollview setContentSize:CGSizeMake(self.screenWidth-30.f, singeViewHeight*singeViews+MutilViewHeight*mutilViews)];
    
    [self closeProgress];
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
