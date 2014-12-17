//
//  BBPostHomeworkViewController.m
//  teacher
//
//  Created by ZhangQing on 14-10-30.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBPostHomeworkViewController.h"

@implementation BBPostHomeworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    kmList = @[@"不指定科目",@"数学",@"语文",@"英语",@"体育",@"自然科学",@"其它"];
}

-(void)bbXKMViewController:(BBXKMViewController *)controller didSelectedIndex:(int)index{
    
    NSLog(@"");
    
    self.selectedIndex = index;
    
    [self.postTableview reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2,1)] withRowAnimation:UITableViewRowAnimationAutomatic];
}
#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TABLEVIEW_SECTION_COUNT+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 1;
    }else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        static NSString *classIden = @"CellIdentifierClass";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:classIden];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:classIden];
            cell.textLabel.text = @"科目";
            cell.textLabel.backgroundColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = [UIColor whiteColor];
        }
            cell.detailTextLabel.text = kmList[self.selectedIndex];
        
        return cell;
    }else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        BBXKMViewController *xkm = [[BBXKMViewController alloc] init];
        xkm.selectedIndex = self.selectedIndex;
        xkm.xkmDelegate = self;
        [self.navigationController pushViewController:xkm animated:YES];
    }else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
@end
