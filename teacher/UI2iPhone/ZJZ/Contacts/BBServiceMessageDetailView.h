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

@protocol BBServiceMessageDetailViewDelegate <NSObject>

- (void)itemSelected:(BBServiceMessageDetailModel *)model;

@end
@interface BBServiceMessageDetailView : UIView
{
    UIImageView *back;
    UILabel *time;
    EGOImageView *banner;
}
@property (nonatomic ,strong)NSArray *models;
@property (nonatomic ,weak)id<BBServiceMessageDetailViewDelegate> delegate;
@end
