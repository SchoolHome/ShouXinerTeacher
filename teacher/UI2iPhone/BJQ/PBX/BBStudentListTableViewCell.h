//
//  BBStudentListTableViewCell.h
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BBStudentListTableViewCellDelegate <NSObject>
@optional
-(void)itemIsSelected:(NSIndexPath *)indexPath;
@end

@interface BBStudentListTableViewCell : UITableViewCell
{
    //姓名
    UILabel *userNameLabel;

    
}
//selectedBtn
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, weak) id<BBStudentListTableViewCellDelegate> delegate;

-(void)setStudentName : (NSString *)name;
@end
