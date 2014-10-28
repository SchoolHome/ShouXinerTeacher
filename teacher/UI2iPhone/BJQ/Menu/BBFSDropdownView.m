//
//  BBFSDropdownView.m
//  teacher
//
//  Created by xxx on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFSDropdownView.h"
#define kDropdownWidth      116
#define kDropdownCellHeight 129

@interface BBFSDropdownView ()
-(void) bbTouchButton : (UIButton *) sender;
@end

@implementation BBFSDropdownView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.unfolded = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width-kDropdownWidth) - 10.0f, 44+20, kDropdownWidth, kDropdownCellHeight)];
        self.bgView.image = [UIImage imageNamed:@"options"];
        self.bgView.userInteractionEnabled = YES;
        self.bgView.clipsToBounds = YES;
        [self addSubview:self.bgView];
        
        self.showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.showAllButton.frame = CGRectMake(0.0f, 9.0f, 116.0f, 40.0f);
        [self.showAllButton setImage:[UIImage imageNamed:@"all"] forState:UIControlStateNormal];
        [self.showAllButton setImage:[UIImage imageNamed:@"all_press"] forState:UIControlStateHighlighted];
        [self.showAllButton addTarget:self action:@selector(bbTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        self.showAllButton.tag = 0;
        [self.bgView addSubview:self.showAllButton];
        
        self.showHomeworkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.showHomeworkButton.frame = CGRectMake(0.0f, 49.0f, 116.0f, 40.0f);
        [self.showHomeworkButton setImage:[UIImage imageNamed:@"hwork"] forState:UIControlStateNormal];
        [self.showHomeworkButton setImage:[UIImage imageNamed:@"hwork_press"] forState:UIControlStateHighlighted];
        [self.showHomeworkButton addTarget:self action:@selector(bbTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        self.showHomeworkButton.tag = 1;
        [self.bgView addSubview:self.showHomeworkButton];
        
        self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.refreshButton.frame = CGRectMake(0.0f, 89.0f, 116.0f, 40.0f);
        [self.refreshButton setImage:[UIImage imageNamed:@"f5"] forState:UIControlStateNormal];
        [self.refreshButton setImage:[UIImage imageNamed:@"f5_press"] forState:UIControlStateHighlighted];
        [self.refreshButton addTarget:self action:@selector(bbTouchButton:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshButton.tag = 2;
        [self.bgView addSubview:self.refreshButton];
        
        [self addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)close{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbFSDropdownViewTaped:)]) {
        [self.delegate bbFSDropdownViewTaped:self];
    }
}

-(void)dismiss{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.bgView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         self.unfolded = NO;
                         [self removeFromSuperview];
                     }];
}

-(void)show{
    self.bgView.alpha = 0.0f;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.bgView.alpha = 100.0f;
                     }
                     completion:^(BOOL finished) {
                         self.unfolded = YES;
                     }];
}


-(void) bbTouchButton : (UIButton *) sender{
    [self dismiss];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbFSDropdownView:didSelectedAtIndex:)]) {
        [self.delegate bbFSDropdownView:self didSelectedAtIndex:sender.tag];
    }
}

@end