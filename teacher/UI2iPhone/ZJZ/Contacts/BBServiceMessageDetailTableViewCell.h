//
//  BBServiceMessageDetailTableViewCell.h
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    DETAIL_CELL_TYPE_MAIN_IMAGE = 1,
    DETAIL_CELL_TYPE_MAIN_TITLE = 2,
    DETAIL_CELL_TYPE_SINGLE_FULL = 3,

}DETAIL_CELL_TYPE;

@interface BBServiceMessageDetailTableViewCell : UITableViewCell
@property (nonatomic) DETAIL_CELL_TYPE cellType;
@end
