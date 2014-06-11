//
//  BBMemberInMsgGroupTableViewCell.m
//  teacher
//
//  Created by ZhangQing on 14-3-24.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMemberInMsgGroupTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BBMemberInMsgGroupTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.f, 5.f, 50.f, 50.f)];
        [self.contentView addSubview:_userHeadImageView];
        
        //姓名
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.f, 21.f, 120.f, 18.f)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
         _userNameLabel.textColor = [UIColor colorWithRed:75/255.f green:120/255.f blue:148/255.f alpha:1.f];
        //_userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _userNameLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_userNameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setUserInfo:(CPUIModelUserInfo *)userInfo;
{
    UIImage *avatarImage = [UIImage imageWithContentsOfFile:userInfo.headerPath];
    if (!avatarImage) {
        avatarImage  = [UIImage imageNamed:@"girl.png"];
    }
    [_userHeadImageView setImage:avatarImage];
    [_userHeadImageView.layer setMasksToBounds:YES];
    _userHeadImageView.layer.borderWidth = 0;
    _userHeadImageView.layer.cornerRadius = 25.0;
    _userHeadImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _userNameLabel.text = userInfo.nickName;
}
@end
