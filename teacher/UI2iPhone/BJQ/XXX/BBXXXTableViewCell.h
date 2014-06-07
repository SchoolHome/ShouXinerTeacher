//
//  BBXXXTableViewCell.h
//  teacher
//
//  Created by xxx on 14-3-24.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "BBNotifyModel.h"






@interface BBXXXTableViewCell : UITableViewCell
{
    EGOImageView *icon;
    UILabel *title;
    UILabel *content;
    UIImageView *like;
    UILabel *time;
    EGOImageView *thumbnail;
    UILabel *contentPreView;
}

@property(nonatomic,strong) BBNotifyModel *data;

@end
