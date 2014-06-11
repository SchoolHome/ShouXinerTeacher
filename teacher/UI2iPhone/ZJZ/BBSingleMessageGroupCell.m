//
//  BBSingleMessageGroupCell.m
//  teacher
//
//  Created by ZhangQing on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBSingleMessageGroupCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation BBSingleMessageGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMsgGroup:(CPUIModelMessageGroup *)msgGroup
{
    [super setMsgGroup:msgGroup];
    
    if (msgGroup) {
        if (msgGroup.memberList.count > 0) {
            //单聊
                CPUIModelMessageGroupMember *member = [msgGroup.memberList objectAtIndex:0];
                CPUIModelUserInfo *userInfo = member.userInfo;
                if (userInfo) {
                    self.userNameLabel.text = userInfo.nickName;
                    UIImage *image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
                
                    if (!image) {
                        image = [UIImage imageNamed:@"girl.png"];
                    }
                    [self.userHeadImageView setImage:image];
                
            }
        }
    }
    

    [self.userHeadImageView.layer setMasksToBounds:YES];
    self.userHeadImageView.layer.borderWidth = 0;
    self.userHeadImageView.layer.cornerRadius = 25.0;
    self.userHeadImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    

}
@end
