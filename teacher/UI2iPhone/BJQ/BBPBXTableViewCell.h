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
    UILabel *newLine;
    UIImageView *mark;
    UIImageView *contentBack;
    UILabel *content;
    
    EGOImageButton *imageContent[8];
}

@end
