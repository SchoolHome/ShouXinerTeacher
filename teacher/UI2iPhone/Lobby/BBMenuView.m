//
//  BBMenuView.m
//  teacher
//
//  Created by singlew on 14/10/29.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMenuView.h"

@interface BBMenuView ()
-(void) clickItem : (UIButton *) sender;
-(void) clickCloseView;
@end

@implementation BBMenuView

-(id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self != nil) {
#ifdef IS_TEACHER
        self.PBXButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.PBXButton.frame = CGRectMake(55.0f, 165.0f, 70.0f, 102.0f);
        [self.PBXButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
        [self.PBXButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        self.PBXButton.tag = 0;
        [self addSubview:self.PBXButton];
        
        self.homeWorkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.homeWorkButton.frame = CGRectMake(195.0f, 165.0f, 70.0f, 102.0f);
        [self.homeWorkButton setImage:[UIImage imageNamed:@"f_hwork"] forState:UIControlStateNormal];
        [self.homeWorkButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        self.homeWorkButton.tag = 1;
        [self addSubview:self.homeWorkButton];
        
        self.noticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.noticeButton.frame = CGRectMake(55.0f, 303.0f, 70.0f, 102.0f);
        [self.noticeButton setImage:[UIImage imageNamed:@"f_notice"] forState:UIControlStateNormal];
        [self.noticeButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        self.noticeButton.tag = 3;
        [self addSubview:self.noticeButton];
        
        self.SBSButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.SBSButton.frame = CGRectMake(195.0f, 303.0f, 70.0f, 102.0f);
        [self.SBSButton setImage:[UIImage imageNamed:@"talk"] forState:UIControlStateNormal];
        [self.SBSButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        self.SBSButton.tag = 4;
        [self addSubview:self.SBSButton];
        
        self.closeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeViewButton.frame = CGRectMake(0.0f, frame.size.height - 49.0f, 320.0f, 49.0f);
        [self.closeViewButton setImage:[UIImage imageNamed:@"label_bg"] forState:UIControlStateNormal];
        [self.closeViewButton setImage:[UIImage imageNamed:@"label_bg"] forState:UIControlStateHighlighted];
        [self.closeViewButton addTarget:self action:@selector(clickCloseView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeViewButton];
#else
        self.PBXButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.PBXButton.frame = CGRectMake(55.0f, 303.0f, 70.0f, 102.0f);
        [self.PBXButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
        [self.PBXButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        self.noticeButton.tag = 0;
        [self addSubview:self.PBXButton];
        
        self.SBSButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.SBSButton.frame = CGRectMake(195.0f, 303.0f, 70.0f, 102.0f);
        [self.SBSButton setImage:[UIImage imageNamed:@"talk"] forState:UIControlStateNormal];
        [self.SBSButton addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
        self.SBSButton.tag = 4;
        [self addSubview:self.SBSButton];
        
        self.closeViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeViewButton.frame = CGRectMake(0.0f, frame.size.height - 49.0f, 320.0f, 49.0f);
        [self.closeViewButton setImage:[UIImage imageNamed:@"label_bg"] forState:UIControlStateNormal];
        [self.closeViewButton setImage:[UIImage imageNamed:@"label_bg"] forState:UIControlStateHighlighted];
        [self.closeViewButton addTarget:self action:@selector(clickCloseView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeViewButton];
#endif
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 90.0f;
    }
    return self;
}

-(void) clickItem : (UIButton *) sender{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(clickItemIndex:)]) {
        [self.delegate clickItemIndex:sender.tag];
    }
}

-(void) clickCloseView{
    [self removeFromSuperview];
}
@end
