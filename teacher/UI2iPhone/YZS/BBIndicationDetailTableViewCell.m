//
//  BBIndicationDetailTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-5.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBIndicationDetailTableViewCell.h"

@implementation BBIndicationDetailTableViewCell

-(void)shareTaped:(UIButton *)sender{
    if (_delegate&&[_delegate respondsToSelector:@selector(bbIndicationDetailTableViewCell:shareTaped:)]) {
        [_delegate bbIndicationDetailTableViewCell:self shareTaped:sender];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        
        back = [[UIImageView alloc] init];
        [self addSubview:back];
        CALayer *roundedLayer = [back layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 8.0;
        roundedLayer.borderWidth = 1;
        roundedLayer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 30)];
        [self addSubview:time];
        time.backgroundColor = [UIColor clearColor];
        time.textAlignment = NSTextAlignmentCenter;
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20+30, 280, 25)];
        [self addSubview:title];
        title.backgroundColor = [UIColor clearColor];
        
        thumbnail = [[EGOImageView alloc] initWithFrame:CGRectMake(20, 50+30, 280, 200)];
        [self addSubview:thumbnail];
        thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        
        content = [[UILabel alloc] init];
        content.textColor = [UIColor grayColor];
        content.font = [UIFont systemFontOfSize:13];
        content.numberOfLines = 4;
        [self addSubview:content];
        content.backgroundColor = [UIColor clearColor];
        
        line = [[UIImageView alloc] init];
        line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line];
        
        share = [UIButton buttonWithType:UIButtonTypeCustom];
        //share.backgroundColor = [UIColor grayColor];
        [share setBackgroundImage:[UIImage imageNamed:@"YZSShared"] forState:UIControlStateNormal];
        [self addSubview:share];
        [share addTarget:self action:@selector(shareTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    back.frame = CGRectMake(10, 10+25, 300, self.bounds.size.height-20-30);
}

-(NSString *)dateString:(NSNumber *)dateNumber
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dateNumber longLongValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+800"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
    
}

-(void)setData:(BBOADetailModel *)data{
    _data = data;
    
    time.text = [self dateString:_data.ts];
    
    title.text = _data.title;
    thumbnail.backgroundColor = [UIColor clearColor];
    
    if ([_data.images count]>0) {
        thumbnail.imageURL = [NSURL URLWithString:_data.images[0]];
    }
    
    content.frame = CGRectMake(20, 255+30, 280, 60);
    content.text = _data.content;
    [content sizeToFit];
    
    line.frame = CGRectMake(10, 330+30, 300, 1);
    share.frame = CGRectMake(20, 350+30, 24, 24);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
