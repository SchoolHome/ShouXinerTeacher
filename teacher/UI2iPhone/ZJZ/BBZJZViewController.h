//
//  BBZJZViewController.h
//  teacher
//
//  Created by ZhangQing on 14-3-12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBMessageGroupBaseTableView.h"
#import "BBSingleMessageGroupCell.h"
#import "BBGroupMessageGroupCell.h"
typedef enum LIST_TYPE
{
    LIST_TYPE_MSG_GROUP = 1,
    LIST_TYPE_CONTACTS = 2
}LIST_TYPE;

@interface BBZJZViewController : PalmViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,BBMessageGroupBaseTableViewDelegate>



@end
