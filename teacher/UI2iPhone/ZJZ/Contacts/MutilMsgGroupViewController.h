//
//  MutilMsgGroupViewController.h
//  teacher
//
//  Created by ZhangQing on 14-11-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

@interface MutilMsgGroupViewController : PalmViewController <UITableViewDataSource,UITableViewDelegate>

- (id)initWithMutilMsgGroups : (NSArray *)msgGroups;

@end
