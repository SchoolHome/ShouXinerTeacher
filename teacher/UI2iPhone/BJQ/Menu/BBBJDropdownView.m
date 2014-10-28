//
//  BBBJDropdownView.m
//  teacher
//
//  Created by xxx on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBBJDropdownView.h"
#define kDropdownWidth      116

@interface BBBJDropdownView ()
@property (nonatomic) float height;
-(void) bbTouchButton : (UIButton *) sender;
@end

@implementation BBBJDropdownView


-(void)setListData:(NSArray *)listData{
    _listData = listData;
    
    self.height = 48.0f + 40 * ([listData count] - 1);
    
    self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-kDropdownWidth) - 10.0f, 44+20, kDropdownWidth, self.height)];
    self.bgView.userInteractionEnabled = YES;
    self.bgView.clipsToBounds = YES;
    [self addSubview:self.bgView];
    
    for (int i = 0; i<[listData count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i == 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"BJQClassTap"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"BJQClassTapPressed"] forState:UIControlStateNormal];
            button.frame = CGRectMake(0.0, 0.0f, kDropdownWidth, 48.0f);
        }
        UIButton *lastButton = [self.buttonArray lastObject];
        if (i == [listData count] - 1) {
            [button setBackgroundImage:[UIImage imageNamed:@"BJQClassBottom"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"BJQClassBottomPressed"] forState:UIControlStateNormal];
            button.frame = CGRectMake(0.0, lastButton.frame.origin.y + lastButton.frame.size.height, kDropdownWidth, 40.0f);
        }
        [button setBackgroundImage:[UIImage imageNamed:@"BJQClassMiddle"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"BJQClassMiddlePressed"] forState:UIControlStateNormal];
        button.frame = CGRectMake(0.0, lastButton.frame.origin.y + lastButton.frame.size.height, kDropdownWidth, 40.0f);
        [button setTitle:listData[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(bbTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonArray addObject:button];
        [self.bgView addSubview:button];
    }
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.unfolded = NO;
        self.backgroundColor = [UIColor clearColor];
        self.buttonArray = [[NSMutableArray alloc] init];
//        _listData = [[NSArray alloc] initWithObjects:
//                     @"三年级（4）班",@"三年级（3）班",@"三年级（2）班",@"三年级（1）班", nil];
        [self addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)close{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbBJDropdownViewTaped:)]) {
        [self.delegate bbBJDropdownViewTaped:self];
    }
}

-(void)dismiss{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.bgView.alpha = 0.0f;
                     }completion:^(BOOL finished) {
                         self.unfolded = NO;
                         [self removeFromSuperview];
                     }];
}

-(void)show{
//    self.bgView.alpha = 0.0f;
//    [UIView animateWithDuration:0.3
//                     animations:^{
//                         self.bgView.alpha = 100.0f;
//                     }completion:^(BOOL finished) {
//                         self.unfolded = YES;
//                     }];
}

-(void) bbTouchButton : (UIButton *) sender{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbBJDropdownView:didSelectedAtIndex:)]) {
        [self.delegate bbBJDropdownView:self didSelectedAtIndex:sender.tag];
    }
}
@end
