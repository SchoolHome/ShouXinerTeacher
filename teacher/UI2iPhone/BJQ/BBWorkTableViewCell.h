//
//  BBWorkTableViewCell.h
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//
/*
 作业和通知是一样的
 */
#import "BBBaseTableViewCell.h"


@interface BBWorkTableViewCell : BBBaseTableViewCell
{

    UILabel *title;
    UIImageView *contentBack;
    UILabel *content;

    EGOImageButton *imageContent[8];
}

@end
