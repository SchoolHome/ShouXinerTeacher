//
//  BBStudentListTableViewCell.h
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBStudentModel.h"
@protocol BBStudentListTableViewCellDelegate <NSObject>
@optional
-(void)itemIsSelected:(BBStudentModel *)studentModel;
@end

@interface BBStudentListTableViewCell : UITableViewCell
{
    //姓名
    UILabel *userNameLabel;
    //selectedBtn
    UIButton *selectedBtn;
}

@property (nonatomic, strong) BBStudentModel *model;

@property (nonatomic, weak) id<BBStudentListTableViewCellDelegate> delegate;


@end
