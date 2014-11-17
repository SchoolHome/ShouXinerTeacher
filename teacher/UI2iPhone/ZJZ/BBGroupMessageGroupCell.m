//
//  BBGroupMessageGroupCell.m
//  teacher
//
//  Created by ZhangQing on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBGroupMessageGroupCell.h"

#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"

#import "ImageUtil.h"

@implementation BBGroupMessageGroupCell

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
//notifyMessage change
-(void)setUIModelMsgGroup:(CPUIModelMessageGroup *)msgGroup
{
    [super setUIModelMsgGroup:msgGroup];
    
    if (msgGroup) {
        if (msgGroup.memberList.count > 1) {
            NSArray *array = [NSArray arrayWithArray:msgGroup.memberList];;
            NSString *title = @"";
            int i = 0;
            for (CPUIModelUserInfo *user in array) {
                if (![user.nickName isEqualToString:[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName]) {
                    if (user.nickName == nil || [user.nickName isEqualToString:@""]) {
                        continue;
                    }
                    if (i == 2) {
                        break;
                    }
                    i++;
                    title = [NSString stringWithFormat:@"%@ %@",title,user.nickName];
                }
            }
            title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@等",title];
        }
        self.userHeadImageView.image = [UIImage groupHeader:msgGroup];
    }
    
//    self.userHeadImageView.image = [UIImage imageNamed:@"girl.png"];
//    [self.userHeadImageView.layer setMasksToBounds:YES];
//    self.userHeadImageView.layer.borderWidth = 0;
//    self.userHeadImageView.layer.cornerRadius = 25.0;
//    self.userHeadImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    
}
@end
