//
//  ChooseClassViewController.m
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ChooseClassViewController.h"

#import "BBGroupModel.h"
@implementation ChooseClassViewController

- (id)initWithClasses : (NSArray *)classes
{
    self = [super init];
    if (self) {
        classModels = [[NSArray alloc] initWithArray:classes];
    }
    return self;
}

- (void)viewDidLoad
{
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight-44.f) style:UITableViewStylePlain];
    tableview.delegate = self;
    tableview.dataSource = self;
    tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  classModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classCellIden = @"classIden";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classCellIden];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:classCellIden];
    }
    
    BBGroupModel *model = classModels[indexPath.row];
    cell.textLabel.text = model.alias;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
