//
//  BBNoticeTableViewCell.h
//  teacher
//
//  Created by singlew on 14/10/22.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBaseTableViewCell.h"

@interface BBNoticeTableViewCell : BBBaseTableViewCell
{
    
    UILabel *title;
    UIImageView *contentBack;
    UILabel *content;
    
    EGOImageButton *imageContent[8];
}
@end
