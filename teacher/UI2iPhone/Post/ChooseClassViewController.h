//
//  ChooseClassViewController.h
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
@protocol ChooseClassDelegate <NSObject>
- (void)classChoose : (NSInteger)index;
@end

@interface ChooseClassViewController : PalmViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *classModels;
}
@property (nonatomic, weak) id<ChooseClassDelegate> delegate;
- (id)initWithClasses : (NSArray *)classes;


@end
