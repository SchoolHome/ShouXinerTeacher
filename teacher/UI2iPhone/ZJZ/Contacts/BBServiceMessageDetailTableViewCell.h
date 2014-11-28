//
//  BBServiceMessageDetailTableViewCell.h
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "BBServiceMessageDetailModel.h"

@interface BBServiceMessageDetailTableViewCell : UITableViewCell
{
    UIImageView *back;
    UILabel *time;
    EGOImageView *banner;
}
@property (nonatomic ,strong)BBServiceMessageDetailModel *model;
@end
