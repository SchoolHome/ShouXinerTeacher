//
//  MutilGroupDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14-11-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "MutilGroupDetailViewController.h"

@interface MutilGroupDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *detailTableview;
@property (nonatomic, strong) CPUIModelMessageGroup *msgGroup;
@end

@implementation MutilGroupDetailViewController

- (id)initWithMsgGroup: (CPUIModelMessageGroup *)tempMsgGroup
{
    self = [super init];
    if (self) {
        self.msgGroup = tempMsgGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark UItableview

@end


@implementation MutilGroupMemberDisplayView



@end
