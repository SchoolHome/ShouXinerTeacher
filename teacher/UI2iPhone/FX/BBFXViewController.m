//
//  BBFXViewController.m
//  teacher
//
//  Created by mac on 14/11/7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFXViewController.h"
#import "BBFXTableViewCell.h"
#import "BBFXGridView.h"
#import "BBFXModel.h"

@interface BBFXViewController ()
{
    BBFXGridView *tempGrid;
}
@property (nonatomic, strong) NSMutableArray *discoverArray;
@property (nonatomic, strong) NSMutableArray *serviceArray;
@end

@implementation BBFXViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"discoverResult" isEqualToString:keyPath]){
        NSDictionary *discoverResult = [PalmUIManagement sharedInstance].discoverResult;
        if ([discoverResult[@"errno"] integerValue]==0) {
            if (![discoverResult[@"discover"] isKindOfClass:[NSNull class]]) {
                NSDictionary *discoverDic = discoverResult[@"discover"];
                for (NSString *key in [discoverDic allKeys]) {
                    NSDictionary *oneDiscover = discoverDic[key];
                    BBFXModel *oneModel = [[BBFXModel alloc] initWithJson:oneDiscover];
                    [self.discoverArray addObject:oneModel];
                }
            }
            if (![discoverResult[@"service"] isKindOfClass:[NSNull class]]) {
                NSDictionary *serviceDic = discoverResult[@"service"];
                for (NSString *key in [serviceDic allKeys]) {
                    NSDictionary *oneService = serviceDic[key];
                    BBFXModel *model = [[BBFXModel alloc] initWithJson:oneService];
                    [self.serviceArray addObject:model];
                }
                
            }
        }
        [fxTableView reloadData];
    }
}

-(id)init{
    self = [super init];
    if (self) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"discoverResult" options:0 context:nil];
        _discoverArray = [[NSMutableArray alloc] init];
        _serviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.navigationItem.title = @"发现";
    CGFloat heightFix = 20.f;
    if (IOS7) {
        heightFix = 20.f;
    }else{
        heightFix = 0;
    }
    [self.discoverArray addObjectsFromArray:[NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"", @"", @"", @"", @"", @"", @"", @"", @"",nil]];
    fxTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.screenHeight-44-49-heightFix) style:UITableViewStylePlain];
    [fxTableView setRowHeight:108];
    [fxTableView setDelegate:(id<UITableViewDelegate>)self];
    [fxTableView setDataSource:(id<UITableViewDataSource>)self];
    [self.view addSubview:fxTableView];
    
    [[PalmUIManagement sharedInstance] getDiscoverData];
}

-(void)addDiscoverHeader
{
    [UIView animateWithDuration:0.5f animations:^{
        fxTableView.tableHeaderView = nil;
    } completion:^(BOOL finished){
        
    }];
}

-(void)removeDiscoverHeader
{
    [UIView animateWithDuration:0.5f animations:^{
        fxTableView.tableHeaderView = nil;
    } completion:^(BOOL finished){
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int residue = [self.discoverArray count] % 3;
    if (residue > 0) residue = 1;
    return [self.discoverArray count]/3 + residue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FXCellIdentifier = @"FXCellIdentifier";
    
    BBFXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FXCellIdentifier];
    if (nil == cell) {
        cell = [[BBFXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FXCellIdentifier];
    }
    NSInteger count = [self.discoverArray count];
    CGFloat x = 0.0f;
    for (int i=0; i<3; i++) {
        NSInteger index = i + indexPath.row * 3;
        if (index < count) {
            if ([cell.contentView.subviews count] > i) {
                tempGrid = [cell.contentView.subviews objectAtIndex:i];
            } else {
                tempGrid = nil;
            }
            
            BBFXGridView *gridView = [self dequeueReusableGridView];
            
            if (gridView.superview != cell.contentView) {
                [gridView removeFromSuperview];
                [cell.contentView addSubview:gridView];
                [gridView addTarget:self action:@selector(tapOneGrid:) forControlEvents:UIControlEventTouchUpInside];
            }
            [gridView setBackgroundColor:[UIColor blueColor]];
            gridView.hidden = NO;
            [gridView setViewData:nil];
            gridView.rowIndex = indexPath.row;
            gridView.colIndex = i;
            [gridView setFrame:CGRectMake(x, 0, 107, 107)];
            x = x + 107.0f+1;
        }else{
            BBFXGridView *gridView = (BBFXGridView *)[cell.contentView.subviews objectAtIndex:i];
            gridView.hidden = YES;
        }
    }
    return cell;
}

-(void)tapOneGrid:(BBFXGridView *)gridView
{
    NSLog(@"tao:::%d, %d", gridView.colIndex, gridView.rowIndex);
}

-(BBFXGridView *)dequeueReusableGridView{
    BBFXGridView* temp = tempGrid;
    tempGrid = nil;
    if (temp == nil) {
        temp = [[BBFXGridView alloc] init];
    }
    return temp;
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
