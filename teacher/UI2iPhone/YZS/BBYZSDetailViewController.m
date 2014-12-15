//
//  BBYZSDetailViewController.m
//  BBTeacher
//
//  Created by xxx on 14-3-5.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBYZSDetailViewController.h"
#import "BBYZSShareViewController.h"

#import "CoreUtils.h"

#import "BBJFViewController.h"

@interface BBYZSDetailViewController ()

@property(nonatomic,strong) NSMutableArray *detailList;

@end

@implementation BBYZSDetailViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([@"notiWithSenderList" isEqualToString:keyPath])
    {
        NSDictionary *dict = [PalmUIManagement sharedInstance].notiWithSenderList;
        
        NSLog(@"%@",  NSStringFromClass([dict[@"data"][@"list"] class]));
        
        NSArray *arr = [NSArray arrayWithArray:dict[@"data"][@"list"]];
        if ([arr count]>0) {
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBOADetailModel *model = [BBOADetailModel fromJson:(NSDictionary *)obj];
                [list addObject:model];
            }];
            
            switch (self.loadStatus) {
                case OALoadStatusRefresh:
                    //
                {
                    [self.detailList removeAllObjects];
                    [self.detailList addObjectsFromArray:list];
                    [yzsDetailTableView.pullToRefreshView stopAnimating];
                    
                    NSDate *now = [CoreUtils convertDateToLocalTime:[NSDate date]];
                    NSString *date = [NSString stringWithFormat:@"最近更新: %@",[[now description] substringToIndex:16]];
                    [yzsDetailTableView.pullToRefreshView setSubtitle:date forState:SVPullToRefreshStateAll];
                }
                    break;
                case OALoadStatusAppend:
                    //
                {
                    [self.detailList addObjectsFromArray:list];
                    [yzsDetailTableView.infiniteScrollingView stopAnimating];
                }
                    break;
                default:
                    break;
            }
            [yzsDetailTableView reloadData];
            
        }else{
        
            switch (self.loadStatus) {
                case OALoadStatusRefresh:
                    //
                {
                    [yzsDetailTableView.pullToRefreshView stopAnimating];
                }
                    break;
                case OALoadStatusAppend:
                    //
                {
                    [yzsDetailTableView.infiniteScrollingView stopAnimating];
                }
                    break;
                default:
                    break;
            }
            [yzsDetailTableView reloadData];
        }
    }
}

-(void)backButtonTaped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addObservers{
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"notiWithSenderList" options:0 context:NULL];
}

-(void)removeObservers{
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"notiWithSenderList"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addObservers];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeObservers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.detailList = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = _oaModel.sender_username;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    int heightFix = 20;
    if (IOS7) {
        heightFix = 20;
    }else{
        heightFix = 0;
    }
    
    yzsDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-heightFix-44) style:UITableViewStylePlain];
    yzsDetailTableView.dataSource = self;
    yzsDetailTableView.delegate = self;
    [self.view addSubview:yzsDetailTableView];
    yzsDetailTableView.separatorColor = [UIColor clearColor];
    
    yzsDetailTableView.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];;
    
    __weak BBYZSDetailViewController *weakSelf = self;
    // 刷新
    [yzsDetailTableView addPullToRefreshWithActionHandler:^{
        weakSelf.loadStatus = OALoadStatusRefresh;
        [[PalmUIManagement sharedInstance] getNotiListWithSender:[weakSelf.oaModel.sender_uid intValue] withOffset:0 withLimit:3];
    }];
    
    // 追加
    [yzsDetailTableView addInfiniteScrollingWithActionHandler:^{
        
        weakSelf.loadStatus = OALoadStatusAppend;
        int offset = [weakSelf.detailList count];
        [[PalmUIManagement sharedInstance] getNotiListWithSender:[weakSelf.oaModel.sender_uid intValue] withOffset:offset withLimit:3];
    }];
    
    [yzsDetailTableView triggerPullToRefresh];
}

#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.detailList count];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"3月16日  12:21";
//    label.backgroundColor = [UIColor lightGrayColor];
//    
//    return label;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"defCell";
    
    BBIndicationDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BBIndicationDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setData:self.detailList[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 430;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BBOADetailModel *model = self.detailList[indexPath.row];
    BBJFViewController *jf = [[BBJFViewController alloc] init];
    jf.hidesBottomBarWhenPushed = YES;
    jf.url = [NSURL URLWithString:model.url];
    [self.navigationController pushViewController:jf animated:YES];
}

#pragma mark - BBIndicationDetailTableViewCellDelegate

-(void)bbIndicationDetailTableViewCell:(BBIndicationDetailTableViewCell *)cell shareTaped:(UIButton *)send{

    NSLog(@"send");
    NSIndexPath *indexPath = [yzsDetailTableView indexPathForCell:cell];
    BBYZSShareViewController *share = [[BBYZSShareViewController alloc] init];
    share.oaDetailModel = self.detailList[indexPath.row];
    [self.navigationController pushViewController:share animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
