//
//  ChooseClassViewController.h
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

@interface ChooseClassViewController : PalmViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *classModels;
}
- (id)initWithClasses : (NSArray *)classes;

@end
