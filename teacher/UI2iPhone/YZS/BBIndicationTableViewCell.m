//
//  BBIndicationTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-5.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBIndicationTableViewCell.h"
#import "ColorUtil.h"

@interface BBIndicationTableViewCell ()

@property (nonatomic,strong) UIImageView *imageBaige;
@property (nonatomic,strong) UILabel *baigeNumber;

@end

@implementation BBIndicationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        icon = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        [self addSubview:icon];
        icon.backgroundColor = [UIColor grayColor];
        
        CALayer *roundedLayer = [icon layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 25.0;
        //roundedLayer.borderWidth = 2;
        roundedLayer.borderColor = [[UIColor grayColor] CGColor];
        
        
//        mark = [[UILabel alloc] initWithFrame:CGRectMake(40, 3, 20, 20)];
//        [self addSubview:mark];
//        mark.font = [UIFont systemFontOfSize:14];
//        mark.textColor = [UIColor whiteColor];
//        mark.backgroundColor = [UIColor orangeColor];
//        mark.textAlignment = NSTextAlignmentCenter;
//        CALayer *roundedLayer1= [mark layer];
//        //[roundedLayer setMasksToBounds:YES];
//        roundedLayer1.cornerRadius = 10.0;
//        roundedLayer1.borderWidth = 0.5;
//        roundedLayer1.borderColor = [[UIColor grayColor] CGColor];
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 230, 20)];
        [self addSubview:title];
        title.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        title.backgroundColor = [UIColor clearColor];
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 50, 20)];
        [self addSubview:time];
        time.textColor =[UIColor grayColor];
        time.backgroundColor = [UIColor clearColor];
        
        content = [[UILabel alloc] initWithFrame:CGRectMake(70, 30, 230, 20)];
        [self addSubview:content];
        content.textColor =[UIColor grayColor];
        content.backgroundColor = [UIColor clearColor];
        
        title.font = [UIFont systemFontOfSize:14];
        time.font = [UIFont systemFontOfSize:14];
        content.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:212/255.f green:212/255.f blue:212/255.f alpha:1.f];
    }else
    {
        self.contentView.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
    }
}


-(NSString *)dateString:(NSNumber *)dateNumber
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[dateNumber longLongValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+800"]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

-(void)setData:(BBOAModel *)data{
    _data = data;
    
    title.text = _data.title;
    
    time.text = [self dateString:_data.ts];
    
    if ([_data.unReaded intValue] != 0) {
        self.imageBaige = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ZJZBaige"] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
        self.imageBaige.frame = CGRectMake(40.0f, 5.0f, 18.0f, 18.0f);
        [self addSubview:self.imageBaige];
        
        self.baigeNumber = [[UILabel alloc] init];
        self.baigeNumber.backgroundColor = [UIColor clearColor];
        self.baigeNumber.textColor = [UIColor whiteColor];
        self.baigeNumber.font = [UIFont systemFontOfSize:10.0f];
        self.baigeNumber.text = [NSString stringWithFormat:@"%d",[_data.unReaded intValue]];
        self.baigeNumber.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        [self.baigeNumber sizeToFit];
        self.baigeNumber.center = CGPointMake(9.0f, 9.0f);
        [self.imageBaige addSubview:self.baigeNumber];
    }else{
        self.baigeNumber.hidden = YES;
        [self.baigeNumber removeFromSuperview];
        self.baigeNumber = nil;
        self.imageBaige.hidden = YES;
        [self.imageBaige removeFromSuperview];
        self.imageBaige = nil;
    }
    
    
//    int m = arc4random()%25+1;
//    
//    mark.text = [NSString stringWithFormat:@"%d",m];
//    CGFloat width = [mark.text sizeWithFont:[UIFont systemFontOfSize:12]
//                          constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
//    if (width<17) {
//        width = 20;
//    }else{
//        width = width + 8;
//    }
//    mark.frame = CGRectMake(40, 3, width, 20);
    
//    [mark sizeThatFits:CGSizeMake(20, 20)];
    
    content.text = _data.content;// @"XX总局重要指示，！＃@¥％％……％&＊&¥％¥＃％…………&&＊";
    
    //icon.image = [UIImage imageNamed:@"girl"];
    
    if (_data.sender_avatar) {
        icon.imageURL = [NSURL URLWithString:_data.sender_avatar];
    }
}

@end
