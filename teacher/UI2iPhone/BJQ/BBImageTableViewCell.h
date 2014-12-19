//
//  BBImageTableViewCell.h
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBBaseTableViewCell.h"

@interface BBImageTableViewCell : BBBaseTableViewCell
{
    UILabel *title;
    UILabel *content;
    
    EGOImageButton *imageContent[9];
}


@end
