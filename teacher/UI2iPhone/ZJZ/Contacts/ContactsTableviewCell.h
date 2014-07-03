//
//  ContactsTableviewCell.h
//  teacher
//
//  Created by ZhangQing on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsModel.h"
//#import "CPUIModelUserInfo.h"
@protocol ContactsTableviewCellDelegate <NSObject>
@optional
-(void)beginChat:(ContactsModel *)model;
-(void)sendMessage:(NSString *)mobileNumber;
-(void)makeCall:(NSString *)mobileNumber;
@end
@interface ContactsTableviewCell : UITableViewCell
{
    
}


@property (nonatomic , assign) id<ContactsTableviewCellDelegate> delegate;
//姓名
@property (nonatomic , strong) UILabel *userNameLabel;
//头像
@property (nonatomic , strong) UIImageView *userHeadImageView;
//model
@property (nonatomic , strong) ContactsModel *model;
@end
