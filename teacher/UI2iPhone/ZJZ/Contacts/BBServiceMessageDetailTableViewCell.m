//
//  BBServiceMessageDetailTableViewCell.m
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageDetailTableViewCell.h"

@implementation BBServiceMessageDetailTableViewCell

- (void)setCellType:(DETAIL_CELL_TYPE)cellType
{
    switch (cellType) {
        case DETAIL_CELL_TYPE_MUTIL:
        {
            
        }
            break;
        case DETAIL_CELL_TYPE_SINGLE:
        {
        
        }
            break;
        default:
            break;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
