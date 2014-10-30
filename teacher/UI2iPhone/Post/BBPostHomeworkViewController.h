//
//  BBPostHomeworkViewController.h
//  teacher
//
//  Created by ZhangQing on 14-10-30.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBBasePostViewController.h"
#import "BBXKMViewController.h"

@interface BBPostHomeworkViewController : BBBasePostViewController<BBXKMViewControllerDelegate>
{
    NSArray *kmList;
}
@end
