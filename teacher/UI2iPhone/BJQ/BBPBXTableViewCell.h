//
//  BBPBXTableViewCell.h
//  teacher
//
//  Created by singlew on 14-6-5.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBaseTableViewCell.h"

@interface BBPBXTableViewCell : BBBaseTableViewCell{
    UILabel *title;
    UILabel *content;
    UIImageView *typeImage;
    EGOImageButton *imageContent[9];
}

@end
