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
    /*
    NSString *str = @"{\"01010000000000000094c030059f0fcaef8ba960\":[{\"mid\":\"010400000000000003a00ba0ab69e7ee9aa01b54\",\"uid\":100000125,\"username\":\"系统管理员\",\"avatar\":\"http:\/\/att0.shouxiner.com\/attachment\/get\/F000NwIAABPh9QXmrqBUAAFqcGcg8o5LTX_yvCqKpyM3XHiFOQ..\/logo3\",\"type\":1,\"title\":\"123123123\",\"content\":\"12323123123123123123123\",\"ts\":\"1421120060\",\"link\":\"http:\/\/www.shouxiner.com\/webview\/pubMessage?mid=010400000000000003a00ba0ab69e7ee9aa01b54\",\"image\":\"http://att0.shouxiner.com/attachment/get/F000-i0AAGUa9gVIkbNUAAFqcGcglvQjiqUrWEgowGwIGRmM1g../mblogo\"},{\"mid\":\"010400000000000003a00ba0ab69e7ee9aa01b54\",\"uid\":100000125,\"username\":\"系统管理员\",\"avatar\":\"http:\/\/att0.shouxiner.com\/attachment\/get\/F000NwIAABPh9QXmrqBUAAFqcGcg8o5LTX_yvCqKpyM3XHiFOQ..\/logo3\",\"type\":1,\"title\":\"123123123\",\"content\":\"12323123123123123123123\",\"ts\":\"1421120060\",\"link\":\"http:\/\/www.shouxiner.com\/webview\/pubMessage?mid=010400000000000003a00ba0ab69e7ee9aa01b54\",\"image\":\"http://att0.shouxiner.com/attachment/get/F000-i0AAGUa9gVIkbNUAAFqcGcglvQjiqUrWEgowGwIGRmM1g../mblogo\"},{\"mid\":\"010400000000000003a00ba0ab69e7ee9aa01b54\",\"uid\":100000125,\"username\":\"系统管理员\",\"avatar\":\"http:\/\/att0.shouxiner.com\/attachment\/get\/F000NwIAABPh9QXmrqBUAAFqcGcg8o5LTX_yvCqKpyM3XHiFOQ..\/logo3\",\"type\":1,\"title\":\"123123123\",\"content\":\"12323123123123123123123\",\"ts\":\"1421120060\",\"link\":\"http:\/\/www.shouxiner.com\/webview\/pubMessage?mid=010400000000000003a00ba0ab69e7ee9aa01b54\",\"image\":\"http://att0.shouxiner.com/attachment/get/F000-i0AAGUa9gVIkbNUAAFqcGcglvQjiqUrWEgowGwIGRmM1g../mblogo\"}],\"0101000000000000008d4d8956965b8a7bb36c30\":[{\"mid\":\"0104000000000000038a44c7d99785b26f7ca839\",\"uid\":100000125,\"username\":\"系统管理员\",\"avatar\":\"http:\/\/att0.shouxiner.com\/attachment\/get\/F000NwIAABPh9QXmrqBUAAFqcGcg8o5LTX_yvCqKpyM3XHiFOQ..\/logo3\",\"type\":1,\"title\":\"1最终形成\",\"content\":\"擦擦擦把把阿斯蒂芬\",\"ts\":\"1421116386\",\"link\":\"http:\/\/www.shouxiner.com\/webview\/pubMessage?mid=0104000000000000038a44c7d99785b26f7ca839\",\"image\":\"http://att0.shouxiner.com/attachment/get/F000-i0AAGUa9gVIkbNUAAFqcGcglvQjiqUrWEgowGwIGRmM1g../mblogo\"}]}";
    NSString *testStr = @"sxsoul::: {\"010300000000000027c34338134350f39cb54373\":[{\"title\":\"标题较长标题较长标题较长标题较长\",\"avatar\":\"http://att0.shouxiner.com/attachment/get/F000SAIAAAwAAACpapRRAAFqcGcgqsby5d1zccQVZ-6KD6sOew../logo3\"}]}";
    
     
     
    NSString *json = @"{\"01030000000000002c1b411ee47c7127fe642c49\":[{\"title\":\"“赢”战期末，专家助力！\",\"uid\":101092808,\"avatar\":\"http://att0.shouxiner.com/attachment/get/F000VwUAAMiNBganmFdTAAFwbmcgesclM1H2eSx-Ahh4iAGYgg../logo3\"}]}";
    
     
    NSDictionary *fullDicDic = [str objectFromJSONString];
    fullData = [str objectFromJSONString];
    //NSDictionary *fullDic = [str objectFromJSONString];
    NSString *jsonStr = [fullData JSONString];
    */
    
    NSMutableArray *tempMessages = [[NSMutableArray alloc] init];
    
    for (NSString *key in fullData.allKeys) {
        NSArray *tempValue = fullData[key];
        if ([tempValue isKindOfClass:[NSArray class]])
        {
                NSMutableArray *subItems = [[NSMutableArray alloc]initWithCapacity:4];
                for (int i = 0 ; i < tempValue.count; i++) {
                    NSDictionary *dic = tempValue[i];
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        BBServiceMessageDetailModel *tempModel = [BBServiceMessageDetailModel convertByDic:dic];
                        [subItems addObject:tempModel];
                        if (i == tempValue.count-1) {
                            self.lastestMid = tempModel.mid;
                        }
                    }
                }
                [tempMessages addObject:subItems];
        }else if ([tempValue isKindOfClass:[NSDictionary class]])
        {
            
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
    
    NSLog(@"%@",tempMessages);
    [tempMessages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray *tempObj1 = (NSArray *)obj1;
        NSArray *tempObj2 = (NSArray *)obj2;
        BBServiceMessageDetailModel *tempModel1;
        BBServiceMessageDetailModel *tempModel2;
        if (tempObj1.count > 0)  tempModel1 = tempObj1.count == 1 ? tempObj1[0] : tempObj1[0];
        if (tempObj2.count > 0) tempModel2 = tempObj2.count == 1 ? tempObj2[0] : tempObj2[0];
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
    CGFloat singeViewHeight = 254.f;
    CGFloat currentMutilViewHeight = 0.f;
    for (int i = 0; i<self.messages.count; i++) {
        NSArray *tempArray = self.messages[i];
        CGRect frame;
        if (tempArray.count == 1) {
            frame = CGRectMake(0.f, singeViewHeight*singeViews+currentMutilViewHeight, CGRectGetWidth(self.detailScrollview.frame), singeViewHeight);
            singeViews++;
        }else
        {
            CGFloat mutilViewOwnHeight = 200+(tempArray.count-1)*40;
            
            frame = CGRectMake(0.f, singeViewHeight*singeViews+currentMutilViewHeight, CGRectGetWidth(self.detailScrollview.frame), mutilViewOwnHeight);
            mutilViews++;
            
            currentMutilViewHeight += mutilViewOwnHeight;
        }
        
        
        
        BBServiceMessageDetailView *detailView = [[BBServiceMessageDetailView alloc] initWithFrame:frame];
        detailView.delegate = self;
        [detailView setModels:tempArray];
        [self.detailScrollview addSubview:detailView];
    }
    
    [self.detailScrollview setContentSize:CGSizeMake(self.screenWidth-30.f, singeViewHeight*singeViews+currentMutilViewHeight)];
    
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
