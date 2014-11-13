//
//  ContactsViewController.h
//  teacher
//
//  Created by ZhangQing on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "ContactsTableviewCell.h"
#import "BBMessageGroupBaseTableView.h"


@interface ContactsViewController : PalmViewController <UITableViewDelegate,UITableViewDataSource,
    ContactsTableviewCellDelegate,
    UISearchBarDelegate,
    BBMessageGroupBaseTableViewDelegate,
    UISearchDisplayDelegate>

- (id)initWithContactsArray:(NSArray *)contact;

@end
