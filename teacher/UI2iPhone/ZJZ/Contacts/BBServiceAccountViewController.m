//
//  BBServiceAccountViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-19.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceAccountViewController.h"
#import "BBServiceMessageDetailViewController.h"
@interface BBServiceAccountViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)NSArray *serviceItems;
@end

@implementation BBServiceAccountViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"publicAccountDic"]) {
        NSDictionary *result = [PalmUIManagement sharedInstance].publicAccountDic;
        if (![result[@"hasError"] boolValue]) {
            NSArray *data = result[@"data"][@"list"];
            [self setServiceItems:data];
        }else
        {
            [self showProgressWithText:result[@"errorMessage"] withDelayTime:2.f];
        }
    }
}

- (id)initWithServiceItems:(NSArray *)items
{
    self = [super init];
    if (self) {
        _serviceItems = items;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"服务号";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UITableView *serviceTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight) style:UITableViewStylePlain];
    serviceTableview.delegate = self;
    serviceTableview.dataSource = self;
    serviceTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    serviceTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, 10.f)];
    serviceTableview.backgroundColor = [UIColor clearColor];
    serviceTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:serviceTableview];
    
    [self showProgressWithText:@"正在获取"];
    [[PalmUIManagement sharedInstance] getPublicAccount];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"publicAccountDic" options:0 context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"publicAccountDic"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Setter
- (void)setServiceItems:(NSArray *)serviceItems
{
    
}
#pragma mark - UITableview
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ItemHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger itemsCount = self.serviceItems.count;
    return itemsCount%3 == 0 ? itemsCount/3 : itemsCount/3+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *serviceBaseCell = @"ServiceBaseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:serviceBaseCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serviceBaseCell];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSInteger n = self.serviceItems.count-indexPath.row*3;
        for (int i = 0; i <(n>ItemCount?ItemCount:n); i++) {
            CGFloat interval = (self.screenWidth-ItemImageWidht*ItemCount)/(ItemCount+1);
            ServiceItem *item = [[ServiceItem alloc] initWithFrame:CGRectMake(interval+(ItemImageWidht+interval)*i, 0.f, ItemImageWidht, ItemHeight)];
            item.delegate = self;
            item.backgroundColor = [UIColor clearColor];
            item.itemRow = indexPath.row;
            item.itemIndex = i;
            [[cell contentView] addSubview:item];
        }
    }
    
    for (id subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[ServiceItem class]]) {
            ServiceItem *item = (ServiceItem *)subview;
            [item setContent:self.serviceItems[item.itemRow*ItemCount + item.itemIndex]];
        }
    }
    
    return cell;
}
#pragma mark - Delegate
- (void)itemTappedWithRow:(NSInteger)row andIndex:(NSInteger)index
{
    NSLog(@"row == %d,index==%d",row,index);
    CPDBModelNotifyMessage *model = self.serviceItems[row*ItemCount + index];
    if (model) {
        BBServiceMessageDetailViewController *messageDetail = [[BBServiceMessageDetailViewController alloc] init];
        [messageDetail performSelector:@selector(setModel:) withObject:model afterDelay:0.5];
        //[messageDetail setModel:model];
        [self.navigationController pushViewController:messageDetail animated:YES];

    }else [self showProgressWithText:@"无法查看" withDelayTime:2];
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


@implementation ServiceItem
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.itemHead = [EGOImageButton buttonWithType:UIButtonTypeCustom];
        [self.itemHead setPlaceholderImage:[UIImage imageNamed:@"girl"]];
        [self.itemHead setFrame:CGRectMake(0.f, 10.f, ItemImageWidht, ItemImageWidht)];
        self.itemHead.layer.masksToBounds = YES;
        self.itemHead.layer.cornerRadius = ItemImageWidht/2.f;
        self.itemHead.layer.borderColor = [UIColor whiteColor].CGColor;
        self.itemHead.layer.borderWidth = 2.f;
        [self.itemHead addTarget:self action:@selector(tapHead) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.itemHead];
        
        self.itemTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(self.itemHead.frame)+4.f, ItemImageWidht, 30.f)];
        self.itemTitle.backgroundColor = [UIColor clearColor];
        self.itemTitle.textAlignment = NSTextAlignmentCenter;
        self.itemTitle.numberOfLines = 2;
        self.itemTitle.font = [UIFont systemFontOfSize:12.f];
        [self addSubview:self.itemTitle];
    }
    
    return self;
}

- (void)setContent:(CPDBModelNotifyMessage *)message
{
    [self.itemHead setImageURL:[NSURL URLWithString:message.fromUserAvatar]];
    [self.itemTitle setText:message.fromUserName];
    
}

- (void)tapHead
{
    if ([self.delegate respondsToSelector:@selector(itemTappedWithRow:andIndex:)]) {
        [self.delegate itemTappedWithRow:self.itemRow andIndex:self.itemIndex];
    }
}
@end