//
//  BBStudentListTableViewCell.m
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBStudentListTableViewCell.h"

@implementation BBStudentListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        //selectedBtn
        selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [selectedBtn setFrame:CGRectMake(5.f, 19.f, 22.f, 22.f)];
        [selectedBtn addTarget:self action:@selector(selectUser:) forControlEvents:UIControlEventTouchUpInside];
        [selectedBtn setBackgroundImage:[UIImage imageNamed:@"ZJZUnCheck"] forState:UIControlStateNormal];
        [selectedBtn setBackgroundImage:[UIImage imageNamed:@"ZJZChecked"] forState:UIControlStateSelected];
        [self.contentView addSubview:selectedBtn];
        //姓名
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 21.f, 120.f, 18.f)];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.textColor = [UIColor colorWithRed:75/255.f green:120/255.f blue:148/255.f alpha:1.f];
        userNameLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:userNameLabel];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)selectUser:(UIButton *)sender
{
    
    if ([self.delegate respondsToSelector:@selector(itemIsSelected:)]) {
        [self.delegate itemIsSelected:self.model];
    }
}

-(void)setModel:(BBStudentModel *)model
{
    
    userNameLabel.text = model.studentName;
    selectedBtn.selected = model.isSelected;
    
    _model = model;
}

@end
