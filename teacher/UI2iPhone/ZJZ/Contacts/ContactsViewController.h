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
typedef enum
{
  CONTACT_TYPE_TEACHER = 1,
  CONTACT_TYPE_PARENT = 2,
}CONTACT_TYPE;

@interface ContactsViewController : PalmViewController <UITableViewDelegate,UITableViewDataSource,
    ContactsTableviewCellDelegate,
    UISearchBarDelegate,
    BBMessageGroupBaseTableViewDelegate,
    UISearchDisplayDelegate>

@end
