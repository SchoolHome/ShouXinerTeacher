//
//  BBNotifyMessageGroupCell.m
//  teacher
//
//  Created by ZhangQing on 14-7-24.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBNotifyMessageGroupCell.h"

@implementation BBNotifyMessageGroupCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)setDBModelNotifyMsgGroup:(CPDBModelNotifyMessage *)msgGroup
{
    [super setDBModelNotifyMsgGroup:msgGroup];
    if (msgGroup) {
        self.userNameLabel.text = msgGroup.fromUserName;
        [self.userHeadImageView setPlaceholderImage:[UIImage imageNamed:@"girl.png"]];
        [self.userHeadImageView setImageURL:[NSURL URLWithString:msgGroup.fromUserAvatar]];
    }
    
    
    [self.userHeadImageView.layer setMasksToBounds:YES];
    self.userHeadImageView.layer.borderWidth = 0;
    self.userHeadImageView.layer.cornerRadius = 25.0;
    self.userHeadImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
}
@end
