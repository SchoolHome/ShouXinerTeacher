//
//  BBBaseTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBBaseTableViewCell.h"
#import "CoreUtils.h"

@interface BBBaseTableViewCell ()

@end

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

-(void) hEvent : (UIButton *) sender{
    if (_delegate&&[_delegate respondsToSelector:@selector(bbBaseTableViewCell:commentButtonTaped:)]) {
        [_delegate bbBaseTableViewCell:self commentButtonTaped:sender];
    }
}

-(void) moreTaped:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(bbBaseTableViewCell:moreButtonTaped:)]) {
        [_delegate bbBaseTableViewCell:self moreButtonTaped:sender];
    }
}

-(void) recommendTaped:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(bbBaseTableViewCell:recommendButtonTaped:)]) {
        [_delegate bbBaseTableViewCell:self recommendButtonTaped:sender];
    }
}

-(void) longPress : (UILongPressGestureRecognizer *) gesture{
    if (_delegate && [_delegate respondsToSelector:@selector(bbBaseTableViewCell:touchPoint:longPressText:)]) {
        CGPoint point = [gesture locationInView:self];
        [_delegate bbBaseTableViewCell:self touchPoint:point longPressText:_data.content];
    }
}

-(void) deleteButtonTaped:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(bbBaseTableViewCell:deleteButtonTaped:)]) {
        [_delegate bbBaseTableViewCell:self deleteButtonTaped:sender];
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
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
        
        _icon = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        [self addSubview:_icon];
        _icon.backgroundColor = [UIColor grayColor];
        
        CALayer *roundedLayer = [_icon layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 25.0;
        roundedLayer.borderWidth = 0;
        roundedLayer.borderColor = [[UIColor grayColor] CGColor];
        
        _time = [[UILabel alloc] init];
        _time.textColor = [UIColor lightGrayColor];
        _time.font = [UIFont systemFontOfSize:12];
        [self addSubview:_time];
        _time.backgroundColor = [UIColor clearColor];
        
        self.moreButton = [[UIButton alloc] init];
        [self addSubview:self.moreButton];
        [self.moreButton setBackgroundImage:[UIImage imageNamed:@"BJQMoreButton"] forState:UIControlStateNormal];
        [self.moreButton setBackgroundImage:[UIImage imageNamed:@"BJQMoreButton"] forState:UIControlStateHighlighted];
        [self.moreButton addTarget:self action:@selector(moreTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.recommendButton = [[UIButton alloc] init];
        [self addSubview:self.recommendButton];
        [self.recommendButton setBackgroundImage:[UIImage imageNamed:@"BJQHaveNotTuiJian"] forState:UIControlStateNormal];
        [self.recommendButton setBackgroundImage:[UIImage imageNamed:@"BJQHaveNotTuiJian"] forState:UIControlStateHighlighted];
        [self.recommendButton addTarget:self action:@selector(recommendTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        self.deleteTopic = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.deleteTopic];
        [self.deleteTopic addTarget:self action:@selector(deleteButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.deleteTopic setTitle:@"删除" forState:UIControlStateNormal];
        self.deleteTopic.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.deleteTopic setTitleColor:[UIColor colorWithHexString:@"7596cc"] forState:UIControlStateNormal];
        
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
        _likeContent.numberOfLines = 0;
        _likeContent.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
//    _line.frame = CGRectMake(60, 0, 8, self.bounds.size.height);

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)setData:(BBTopicModel *)data{
    _data = data;
    
    if (_data.author_avatar) {
        _icon.imageURL = [NSURL URLWithString:_data.author_avatar];
    }
    
    
    if ([_data.am_i_like boolValue]) {
//        [_like setBackgroundImage:[UIImage imageNamed:@"BBAmILike"] forState:UIControlStateNormal];
    }else{
//        [_like setBackgroundImage:[UIImage imageNamed:@"BBZan"] forState:UIControlStateNormal];
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
