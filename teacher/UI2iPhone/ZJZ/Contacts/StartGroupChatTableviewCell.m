//
//  StartGroupChatTableviewCell.m
//  teacher
//
//  Created by ZhangQing on 14-3-21.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "StartGroupChatTableviewCell.h"

@implementation StartGroupChatTableviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        self.backgroundColor = [UIColor whiteColor];
        //selectedBtn
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setFrame:CGRectMake(5.f, 19.f, 22.f, 22.f)];
        [_selectedBtn addTarget:self action:@selector(selectUser:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"ZJZUnCheck"] forState:UIControlStateNormal];
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"ZJZChecked"] forState:UIControlStateSelected];
        [self.contentView addSubview:_selectedBtn];
        //姓名
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 21.f, 120.f, 18.f)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textColor = [UIColor colorWithRed:75/255.f green:120/255.f blue:148/255.f alpha:1.f];
        //_userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _userNameLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_userNameLabel];
        
        //头像
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45.f, 5.f, 50.f, 50.f)];
        [self.contentView addSubview:_userHeadImageView];
        
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    
    // Configure the view for the selected state
}
-(void)selectUser:(UIButton *)sender
{
    
    if ([self.delegate respondsToSelector:@selector(itemIsSelected:andIndexPath:)]) {
        [self.delegate itemIsSelected:self.model andIndexPath:self.currentIndexPath];
    }
}
-(void)setModel:(CPUIModelUserInfo *)model
{
    _model = model;
    
    UIImage *avatarImage = [UIImage imageWithContentsOfFile:model.headerPath];
    if (!avatarImage) {
        avatarImage  = [UIImage imageNamed:@"girl.png"];
    }
    [self.userHeadImageView setImage:avatarImage];
    [self.userHeadImageView.layer setMasksToBounds:YES];
    self.userHeadImageView.layer.borderWidth = 0;
    self.userHeadImageView.layer.cornerRadius = 25.0;
    self.userHeadImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _userNameLabel.text = model.nickName;
    


}
@end
