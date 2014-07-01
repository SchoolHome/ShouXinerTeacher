//
//  ContactsTableviewCell.m
//  teacher
//
//  Created by ZhangQing on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define SmallIconWidth 31.f
#define SmallIconHeight 22.f
#define AllButtonsWidth 320.f-self.userNameLabel.frame.origin.x-self.userNameLabel.frame.size.width
#import "ContactsTableviewCell.h"
@implementation ContactsTableviewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        //姓名
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.f, 21.f, 120.f, 18.f)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textColor = [UIColor colorWithRed:75/255.f green:120/255.f blue:148/255.f alpha:1.f];
        //_userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _userNameLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_userNameLabel];

        //头像
        _userHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.f, 5.f, 50.f, 50.f)];
        [self.contentView addSubview:_userHeadImageView];
        
        //聊天
        UIButton *chat = [UIButton buttonWithType:UIButtonTypeCustom];
        [chat setFrame:CGRectMake(230, (60-SmallIconHeight)/2, SmallIconWidth, SmallIconHeight)];
        //chat.backgroundColor = [UIColor redColor];
        [chat setBackgroundImage:[UIImage imageNamed:@"ZJZCellChat"] forState:UIControlStateNormal];
        [chat addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:chat];
        //打电话
        UIButton *call = [UIButton buttonWithType:UIButtonTypeCustom];
        [call setFrame:CGRectMake(230+SmallIconWidth, (60-SmallIconHeight)/2, SmallIconWidth, SmallIconHeight)];
        //call.backgroundColor = [UIColor yellowColor];
        [call setBackgroundImage:[UIImage imageNamed:@"ZJZCallPhone"] forState:UIControlStateNormal];
        [call addTarget:self action:@selector(call) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:call];
        //发短信
//        UIButton *message= [UIButton buttonWithType:UIButtonTypeCustom];
//        [message setFrame:CGRectMake(call.frame.origin.x+call.frame.size.width+(AllButtonsWidth-SmallIconWidth*3)/4, (60-SmallIconHeight)/2, SmallIconWidth, SmallIconHeight)];
//        [message setBackgroundImage:[UIImage imageNamed:@"ZJZSendSMS"] forState:UIControlStateNormal];
//        [message addTarget:self action:@selector(message) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:message];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setModel:(ContactsModel *)model
{
    _model = model;
    
    UIImage *avatarImage = [UIImage imageWithContentsOfFile:model.avatarPath];
    if (!avatarImage) {
        avatarImage  = [UIImage imageNamed:@"girl.png"];
    }
    [self.userHeadImageView setImage:avatarImage];
    [self.userHeadImageView.layer setMasksToBounds:YES];
    self.userHeadImageView.layer.borderWidth = 0;
    self.userHeadImageView.layer.cornerRadius = 25.0;
    self.userHeadImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    _userNameLabel.text = model.userName;
}
-(void)chat
{
    if ([self.delegate respondsToSelector:@selector(beginChat:)]) {
        [self.delegate beginChat:self.model];
    }
}
-(void)call
{
    if ([self.delegate respondsToSelector:@selector(makeCall:)]) {
        [self.delegate makeCall:self.model.mobile];
    }
}
-(void)message
{
    if ([self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:self.model.mobile];
    }
}
@end
