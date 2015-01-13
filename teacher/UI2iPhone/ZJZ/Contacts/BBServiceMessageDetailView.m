//
//  BBServiceMessageDetailTableViewCell.m
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#define Banner_Image_Height 150.f
#define Banner_Image_Width 270.f

#define Item_Image_Widht 50.f

#import "BBServiceMessageDetailView.h"


#import "ColorUtil.h"
@implementation BBServiceMessageDetailView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *imageBack = [UIImage imageNamed:@"blank_area"];
        
        back = [[UIImageView alloc] init];
        [back setImage:[imageBack stretchableImageWithLeftCapWidth:imageBack.size.width/2 topCapHeight:imageBack.size.height/2]];
        back.userInteractionEnabled = YES;
        [self addSubview:back];
//        CALayer *roundedLayer = [back layer];
//        [roundedLayer setMasksToBounds:YES];
//        roundedLayer.cornerRadius = 8.0;
//        roundedLayer.borderWidth = 1;
//        roundedLayer.borderColor = [[UIColor whiteColor] CGColor];
        
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, self.frame.size.width, 30)];
        [self addSubview:time];
        time.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        time.textColor = [UIColor lightGrayColor];
        time.textAlignment = NSTextAlignmentCenter;
        time.font = [UIFont systemFontOfSize:12.f];
        
        banner = [[EGOImageView alloc] initWithPlaceholderImage:nil];
        banner.userInteractionEnabled = YES;
        banner.contentMode = UIViewContentModeScaleToFill;
        [banner setFrame:CGRectMake(10.f, 5.f, Banner_Image_Width, Banner_Image_Height)];
        [back addSubview:banner];
    }
    return self;
}


- (void)setModels:(NSArray *)models
{
    _models = models;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.models.count == 1) {
        BBServiceMessageDetailModel *model = self.models[0];
        
        time.text = [self dateString:model.ts];
        
        [banner setImageURL:[NSURL URLWithString:model.imageUrl]];
        
        CGSize titleSize = [model.content sizeWithFont:[UIFont systemFontOfSize:13.f]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(banner.frame)+5.f, Banner_Image_Width, titleSize.height> 50 ? titleSize.height : 50.f)];
        titleLabel.font = [UIFont systemFontOfSize:13.f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.text = model.content;
        titleLabel.numberOfLines = 4;
        [back addSubview:titleLabel];
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(-1.f, CGRectGetMaxY(titleLabel.frame)+2, self.frame.size.width+2, 1.f)];
        line.backgroundColor = [UIColor colorWithRed:240/255.f green:242/255.f blue:245/255.f alpha:1.f];
        [back addSubview:line];
        
        UILabel *readTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(line.frame)+6, 100.f, 20.f)];
        readTitle.backgroundColor = [UIColor clearColor];
        readTitle.text = @"阅读全文";
        readTitle.font = [UIFont systemFontOfSize:14.f];
        readTitle.textColor = [UIColor lightGrayColor];
        [back addSubview:readTitle];
        
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(Banner_Image_Width-30.f, CGRectGetMinY(readTitle.frame)-1.f, 22.f, 22.f)];
        [arrow setImage:[UIImage imageNamed:@"enter"]];
        [back addSubview:arrow];
        
        [back setFrame:CGRectMake(0.f, CGRectGetMaxY(time.frame), 290.f, self.frame.size.height-CGRectGetHeight(time.frame))];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleViewTapped)];
        [back addGestureRecognizer:tap];
    }else if (self.models.count > 1)
    {
        for (int i = 0; i < self.models.count; i++) {
            BBServiceMessageDetailModel *model = self.models[i];
            if (i == 0) {
                [banner setImageURL:[NSURL URLWithString:model.imageUrl]];
                
                time.text = [self dateString:model.ts];
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(banner.frame)-26.f, CGRectGetWidth(banner.frame), 26.f)];
                titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
                titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.text = model.title;
                [back addSubview:titleLabel];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mutilViewBannerTapped)];
                [banner addGestureRecognizer:tap];
                
            }else if(i < 5)
            {
                UIView *tapView = [[UIView alloc] initWithFrame:CGRectZero];
                tapView.tag = i;
                [back addSubview:tapView];
                
                UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(-1, CGRectGetMaxY(banner.frame)+6.f+(Item_Image_Widht+4)*(i-1), self.frame.size.width+2, 1.f)];
                line.backgroundColor = [UIColor colorWithRed:240/255.f green:242/255.f blue:245/255.f alpha:1.f];
                [back addSubview:line];
                
                UILabel *readTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(line.frame)+4, CGRectGetMaxX(banner.frame)-Item_Image_Widht-20.f, 36.f)];
                readTitle.backgroundColor = [UIColor clearColor];
                readTitle.text = model.title;
                readTitle.numberOfLines = 2;
                readTitle.font = [UIFont systemFontOfSize:13.f];
                readTitle.textColor = [UIColor lightGrayColor];
                [back addSubview:readTitle];
                
                EGOImageView *itemImageview = [[EGOImageView alloc] initWithPlaceholderImage:nil];
                [itemImageview setFrame:CGRectMake(CGRectGetMaxX(banner.frame)-Item_Image_Widht, CGRectGetMaxY(line.frame)+2.f, Item_Image_Widht, Item_Image_Widht)];
                [itemImageview setImageURL:[NSURL URLWithString:model.imageUrl]];
                itemImageview.contentMode = UIViewContentModeScaleAspectFit;
                [back addSubview:itemImageview];
                
                [tapView setFrame:CGRectMake(CGRectGetMinX(line.frame), CGRectGetMinY(line.frame), CGRectGetWidth(line.frame), CGRectGetMaxY(itemImageview.frame)-CGRectGetMinY(line.frame))];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mutilViewTapped:)];
                [tapView addGestureRecognizer:tap];
                
                if (i == self.models.count-1) {
                    [back setFrame:CGRectMake(0.f, CGRectGetMaxY(time.frame), 290.f, CGRectGetMaxY(tapView.frame)+10.f)];
                }
            }
        }


    }
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)singleViewTapped
{
    if ([self.delegate respondsToSelector:@selector(itemSelected:)]) {
        BBServiceMessageDetailModel *model = self.models[0];
        [self.delegate itemSelected:model];
    }
}

- (void)mutilViewBannerTapped
{
    if ([self.delegate respondsToSelector:@selector(itemSelected:)]) {
        BBServiceMessageDetailModel *model = self.models[0];
        [self.delegate itemSelected:model];
    }
}

- (void)mutilViewTapped:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(itemSelected:)]) {
        BBServiceMessageDetailModel *model = self.models[gesture.view.tag];
        [self.delegate itemSelected:model];
    }
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

@end
