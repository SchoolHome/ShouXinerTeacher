//
//  BBFSDropdownView.m
//  teacher
//
//  Created by xxx on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFSDropdownView.h"
#define kDropdownWidth      83
#define kDropdownCellHeight 44

@implementation BBFSDropdownView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.unfolded = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _listData = [[NSArray alloc] initWithObjects:
                     @"BBPBX",@"BBFZY",@"BBFTZ",@"BBSBS", nil];
        
        _list = [[UITableView alloc] initWithFrame:CGRectMake((self.frame.size.width-kDropdownWidth), 44+20, kDropdownWidth, 0) style:UITableViewStylePlain];
        _list.rowHeight = kDropdownCellHeight;
        _list.dataSource = self;
        _list.delegate = self;
        _list.scrollEnabled = NO;
        _list.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0 green:0 blue:0 alpha:0.55];
        _list.separatorColor = [UIColor darkGrayColor];//[UIColor colorWithHexString:@"515151"];
        
        [self addSubview:_list];
        
        _list.layer.borderWidth = 1;
        _list.layer.borderColor = [UIColor darkGrayColor].CGColor;
        
        [self addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)close{
    
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbFSDropdownViewTaped:)]) {
        [self.delegate bbFSDropdownViewTaped:self];
    }
}

-(void)dismiss{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _list.frame = CGRectMake((self.frame.size.width-kDropdownWidth), 44+20, kDropdownWidth, 0);
                     }
                     completion:^(BOOL finished) {
                         self.unfolded = NO;
                         [self removeFromSuperview];
                     }];
}

-(void)show{
    
    _list.frame = CGRectMake((self.frame.size.width-kDropdownWidth), 44+20, kDropdownWidth, 0);
    [UIView animateWithDuration:0.3
                     animations:^{
                         _list.frame = CGRectMake((self.frame.size.width-kDropdownWidth), 44+20, kDropdownWidth, kDropdownCellHeight*[_listData count]);
                     }
                     completion:^(BOOL finished) {
                         self.unfolded = YES;
                     }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 44)];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 44)];

    }
//    cell.textLabel.text = [_listData objectAtIndex:indexPath.row];
//    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
//    cell.textLabel.textAlignment = UITextAlignmentCenter;
//    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIImageView *bk = (UIImageView *)cell.backgroundView;
    UIImageView *sbk = (UIImageView *)cell.selectedBackgroundView;
    bk.image = [UIImage imageNamed:_listData[indexPath.row]];
    sbk.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@Press",_listData[indexPath.row]]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self dismiss];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbFSDropdownView:didSelectedAtIndex:)]) {
        [self.delegate bbFSDropdownView:self didSelectedAtIndex:indexPath.row];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end