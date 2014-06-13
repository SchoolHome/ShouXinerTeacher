//
//  BBXXXTableViewCell.m
//  teacher
//
//  Created by xxx on 14-3-24.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBXXXTableViewCell.h"
#import "ColorUtil.h"
#import "BBBaseTableViewCell.h"

@implementation BBXXXTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.contentView.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        
        icon = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        icon.backgroundColor = [UIColor grayColor];
        [self addSubview:icon];
        CALayer *roundedLayer = [icon layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 25.0;
        roundedLayer.borderWidth = 0;
        roundedLayer.borderColor = [[UIColor grayColor] CGColor];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 200, 20)];
        [self addSubview:title];
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        title.backgroundColor = [UIColor clearColor];
        
        content = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 160, 40)];
        [self addSubview:content];
        content.font = [UIFont systemFontOfSize:14];
        content.numberOfLines = 2;
        content.backgroundColor = [UIColor clearColor];
        
        like = [[UIImageView alloc] initWithFrame:CGRectMake(70, 35, 25, 25)];
        like.backgroundColor = [UIColor clearColor];
        [self addSubview:like];
        like.image = [UIImage imageNamed:@"BBheart"];
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(70, 70, 100, 20)];
        time.textColor = [UIColor lightGrayColor];
        time.font = [UIFont systemFontOfSize:12];
        [self addSubview:time];
        time.backgroundColor = [UIColor clearColor];

        thumbnail = [[EGOImageView alloc] initWithFrame:CGRectMake(240, 30, 60, 60)];
        [self addSubview:thumbnail];
        thumbnail.backgroundColor = [UIColor clearColor];
        
        contentPreView = [[UILabel alloc] initWithFrame:CGRectMake(240, 30, 60, 60)];
        contentPreView.textColor = [UIColor blackColor];
        contentPreView.font = [UIFont systemFontOfSize:12];
        contentPreView.numberOfLines = 4;
        [self addSubview:contentPreView];
        contentPreView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(NSString *)timeStringFromNumber:(NSNumber *) number{
    
    NSTimeInterval  t1 = [number longLongValue];
    //NSTimeInterval  t2 = [[CoreUtils convertDateToLocalTime:[NSDate date]] timeIntervalSince1970];
    NSTimeInterval  t2 = [[NSDate date] timeIntervalSince1970];
    
    int second = (t2 -t1);
    NSString *final = @"刚刚";
    
    if (second<60) {
        final = @"刚刚";
    }else if(second<60*60){
        int min = second/60;
        final = [NSString stringWithFormat:@"%d分钟前",min];
    }else if(second<60*60*24){
        
        int hour = second/(60*60);
        final = [NSString stringWithFormat:@"%d小时前",hour];
    }else{
        
        int day = second/(60*60*24);
        final = [NSString stringWithFormat:@"%d天前",day];
    }
    return final;
}

-(void)setData:(BBNotifyModel *)data{

    _data = data;
    
    //icon.image = [UIImage imageNamed:@"girl"];
    
    icon.image = nil;
    
    if (_data.sender_avatar) {
        icon.imageURL = [NSURL URLWithString:_data.sender_avatar];
    }
    
    //icon.imageURL = [NSURL URLWithString:_data.sender_avatar];
    
    title.text = _data.sender_name;
    content.text = data.topic_title;
    time.text = [self timeStringFromNumber:data.ts];
    
//    tlike
//    tcomment
    
    if ([_data.type isEqualToString:@"tlike"]) {
        like.hidden = NO;
        content.hidden = YES;
    }else if([_data.type isEqualToString:@"tcomment"]){
        like.hidden = YES;
        content.hidden = NO;
    }
    
    
    NSString *imageUrl = data.imageUrl;
    if (imageUrl == [NSNull null] || [imageUrl isEqualToString:@""] ) {
        contentPreView.hidden = NO;
        thumbnail.hidden = YES;
        contentPreView.text = data.content;
    }else
    {
        thumbnail.hidden = NO;
        contentPreView.hidden = YES;
        [thumbnail  setImageURL:[NSURL URLWithString:imageUrl]];
    }
    //[self showDebugRect:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
