//
//  BBMeProfileTableViewCell.m
//  teacher
//
//  Created by mac on 14-3-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeProfileTableViewCell.h"

@implementation BBMeProfileTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = 20;
    textLabelFrame.origin.y = (self.contentView.frame.size.height - textLabelFrame.size.height)/2;
    self.textLabel.frame = textLabelFrame;
    CGRect detailLabelFrame ;
    detailLabelFrame.origin.x = textLabelFrame.origin.x+textLabelFrame.size.width+5;
    detailLabelFrame.origin.y = textLabelFrame.origin.y;
    detailLabelFrame.size.width = self.contentView.frame.size.width - textLabelFrame.origin.x - textLabelFrame.size.width - 30;
    detailLabelFrame.size.height = textLabelFrame.size.height;
    self.detailTextLabel.frame = detailLabelFrame;
    [self.detailTextLabel setTextAlignment:NSTextAlignmentRight];
}
@end
