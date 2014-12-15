//
//  BBVideoTableViewCell.h
//  teacher
//
//  Created by singlew on 14/10/30.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBBaseTableViewCell.h"

@interface BBVideoTableViewCell : BBBaseTableViewCell{
    UILabel *title;
    UIImageView *contentBack;
    UILabel *content;
    UIImageView *typeImage;
    UIImageView *playImage;
}
@property (nonatomic,strong) EGOImageButton *imageContent;
@end
