//
//  BBBaseTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBBaseTableViewCell.h"
#import "CoreUtils.h"

@implementation BBBaseTableViewCell


-(void)replyTaped:(id)sender{
    if (_delegate&&[_delegate respondsToSelector:@selector(bbBaseTableViewCell:replyButtonTaped:)]) {
        [_delegate bbBaseTableViewCell:self replyButtonTaped:sender];
    }
}

-(void)likeTaped:(id)sender{
    if (_delegate&&[_delegate respondsToSelector:@selector(bbBaseTableViewCell:likeButtonTaped:)]) {
        [_delegate bbBaseTableViewCell:self likeButtonTaped:sender];
    }
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.contentView.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        
        _icon = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 10, 50, 50)];
        [self addSubview:_icon];
        _icon.backgroundColor = [UIColor grayColor];
        
        CALayer *roundedLayer = [_icon layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 25.0;
        roundedLayer.borderWidth = 0;
        roundedLayer.borderColor = [[UIColor grayColor] CGColor];
        
        _line = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 8, self.bounds.size.height)];
        //_line.backgroundColor = [UIColor lightGrayColor];
        _line.image = [UIImage imageNamed:@"BBLine"];
        //_line.alpha = 0.5;
        [self addSubview:_line];
        
        UIImageView *point = [[UIImageView alloc] initWithFrame:CGRectMake(60-3.5, 35, 15, 13)];
        point.image = [UIImage imageNamed:@"BBPoint"];
        [self addSubview:point];
        //point.backgroundColor = [UIColor grayColor];
        
        _time = [[UILabel alloc] init];
        _time.textColor = [UIColor lightGrayColor];
        _time.font = [UIFont systemFontOfSize:12];
        [self addSubview:_time];
        _time.backgroundColor = [UIColor clearColor];
        
        _like = [[UIButton alloc] init];
        [self addSubview:_like];
        [_like setBackgroundImage:[UIImage imageNamed:@"BBZan"] forState:UIControlStateNormal];
        [_like setBackgroundImage:[UIImage imageNamed:@"BBZanPress"] forState:UIControlStateHighlighted];
        
        [_like addTarget:self action:@selector(likeTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        _reply = [[UIButton alloc] init];
        [self addSubview:_reply];
        [_reply setBackgroundImage:[UIImage imageNamed:@"BBComment"] forState:UIControlStateNormal];
        [_reply setBackgroundImage:[UIImage imageNamed:@"BBCommentPress"] forState:UIControlStateHighlighted];
        
        [_reply addTarget:self action:@selector(replyTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _relpyContentBack = [[UIImageView alloc] init];
        [self addSubview:_relpyContentBack];
        
        _relpyContentLine = [[UIImageView alloc] init];
        [self addSubview:_relpyContentLine];
        
        _relpyContentBackTop = [[UIImageView alloc] init];
        [self addSubview:_relpyContentBackTop];
        
        _relpyContentBackBottom = [[UIImageView alloc] init];
        [self addSubview:_relpyContentBackBottom];
        
        _likeContent = [[UILabel alloc] init];
        _likeContent.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        _likeContent.font = [UIFont systemFontOfSize:12];
        [self addSubview:_likeContent];
        _likeContent.backgroundColor = [UIColor clearColor];
        
        _relpyContent = [[OHAttributedLabel alloc] init];
        [self addSubview:_relpyContent];
        _relpyContent.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _line.frame = CGRectMake(60, 0, 8, self.bounds.size.height);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)setData:(BBTopicModel *)data{
    _data = data;
    //_icon.image = [UIImage imageNamed:@"girl"];
    
    if (_data.author_avatar) {
        _icon.imageURL = [NSURL URLWithString:_data.author_avatar];
    }
    
    
    if ([_data.am_i_like boolValue]) {
        [_like setBackgroundImage:[UIImage imageNamed:@"BBAmILike"] forState:UIControlStateNormal];
    }else{
        [_like setBackgroundImage:[UIImage imageNamed:@"BBZan"] forState:UIControlStateNormal];
    }
}

@end


@implementation UIView (Debug)

-(NSArray *) allSubviewsForView: (UIView *) view{
    
	NSMutableArray *subviews = [NSMutableArray array];
	[subviews addObject: view];
    
	for( UIView *subview in view.subviews ){
		[subviews addObjectsFromArray: [self allSubviewsForView: subview]];
	}
	return [NSArray arrayWithArray: subviews];
}

-(NSArray *) allSubviews{
	return [self allSubviewsForView: self];
}

-(void)showDebugRect:(BOOL) show_{
    
    for( UIView *view in [self allSubviews]){
        
		//view.clipsToBounds = YES;
		view.layer.borderWidth = 1.0f;
        
        if (show_) {
            view.layer.borderColor = [[UIColor redColor] CGColor];
        }else {
            view.layer.borderColor = [[UIColor clearColor] CGColor];
        }
	}
}

@end
