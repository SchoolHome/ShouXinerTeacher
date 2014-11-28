//
//  BBServiceMessageDetailTableViewCell.m
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#define Banner_Image_Height 100.f
#define Banner_Image_Width 290.f

#define Item_Image_Widht 25.f

#import "BBServiceMessageDetailTableViewCell.h"

@implementation BBServiceMessageDetailTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        back = [[UIImageView alloc] init];
        back.userInteractionEnabled = YES;
        [self.contentView addSubview:back];
        CALayer *roundedLayer = [back layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 8.0;
        roundedLayer.borderWidth = 1;
        roundedLayer.borderColor = [[UIColor lightGrayColor] CGColor];
        
        time = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 30)];
        [self.contentView addSubview:time];
        time.backgroundColor = [UIColor clearColor];
        time.textAlignment = NSTextAlignmentCenter;
    
        banner = [[EGOImageView alloc] initWithPlaceholderImage:nil];
        [banner setFrame:CGRectMake(5.f, 5.f, Banner_Image_Width, Banner_Image_Height)];
        [back addSubview:banner];
    }
    
    return self;
}

- (void)setModel:(BBServiceMessageDetailModel *)model
{
    _model = model;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.model.type == DETAIL_CELL_TYPE_SINGLE) {
        CGSize titleSize = [self.model.title sizeWithFont:[UIFont systemFontOfSize:13.f]];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(banner.frame)+5.f, Banner_Image_Width, titleSize.height> 50 ? titleSize.height : 50.f)];
        titleLabel.font = [UIFont systemFontOfSize:13.f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = self.model.title;
        titleLabel.numberOfLines = 4;
        [back addSubview:titleLabel];
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(titleLabel.frame)+2, Banner_Image_Width, 1.f)];
        line.backgroundColor = [UIColor lightGrayColor];
        [back addSubview:line];
        
        UILabel *readTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(line.frame)+4, 100.f, 20.f)];
        readTitle.backgroundColor = [UIColor clearColor];
        readTitle.text = @"阅读全文";
        readTitle.font = [UIFont systemFontOfSize:14.f];
        readTitle.textColor = [UIColor lightGrayColor];
        [back addSubview:readTitle];
        
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(Banner_Image_Width-30.f, CGRectGetMinY(readTitle.frame)-1.f, 22.f, 22.f)];
        [arrow setImage:[UIImage imageNamed:@"enter"]];
        [back addSubview:arrow];
        
        [back setFrame:CGRectMake(10.f, CGRectGetMaxY(time.frame), self.frame.size.width-20.f, self.frame.size.height-CGRectGetHeight(time.frame))];
    }else if (self.model.type == DETAIL_CELL_TYPE_MUTIL)
    {
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(banner.frame)+5.f, Banner_Image_Width, 20.f)];
        titleLabel.font = [UIFont systemFontOfSize:14.f];
        titleLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        titleLabel.text = self.model.title;
        [back addSubview:titleLabel];
        
        for (int i = 0; i < self.model.items.count; i++) {
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(titleLabel.frame)+2.f+(Item_Image_Widht+4)*i, Banner_Image_Width, 1.f)];
            line.backgroundColor = [UIColor lightGrayColor];
            [back addSubview:line];
            
            UILabel *readTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(banner.frame), CGRectGetMaxY(line.frame)+4, 100.f, 20.f)];
            readTitle.backgroundColor = [UIColor clearColor];
            readTitle.text = @"阅读全文";
            readTitle.font = [UIFont systemFontOfSize:14.f];
            readTitle.textColor = [UIColor lightGrayColor];
            [back addSubview:readTitle];
            
            EGOImageView *itemImageview = [[EGOImageView alloc] initWithPlaceholderImage:nil];
            [itemImageview setFrame:CGRectMake(CGRectGetMaxX(banner.frame)-Item_Image_Widht, CGRectGetMaxY(line.frame)+2.f, Item_Image_Widht, Item_Image_Widht)];
            [back addSubview:itemImageview];
        }

        [back setFrame:CGRectMake(10.f, CGRectGetMaxY(time.frame), self.frame.size.width-20.f, self.frame.size.height-CGRectGetHeight(time.frame))];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
