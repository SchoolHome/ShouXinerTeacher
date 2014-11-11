//
//  SingleSmallExpressionCell.m
//  iCouple
//
//  Created by ming bright on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SingleSmallExpressionCell.h"
#import "ExpressionImageView.h"
#import "AnimImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "ExpressionsParser.h"

@implementation TextDisplayView
@synthesize delegate;
@synthesize parser;
@synthesize isBelongMe;
@synthesize exModel = _exModel;

/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(textDisplayViewTaped:)]) {
        [self.delegate textDisplayViewTaped:self];
    }
    
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[ExpressionImageView class]]) {
            ExpressionImageView *imageView = (ExpressionImageView*)aView;
            if ([imageView isAnimating]) {
                [imageView stopAnimating];
                self.exModel.isPlayAnimation = NO;
            }else {
                [imageView startAnimating];
                self.exModel.isPlayAnimation = YES;
            }
        }
    }
}
*/

-(void)refreshAnim{
//    self.exModel.isPlayAnimation = !self.exModel.isPlayAnimation;
    
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[ExpressionImageView class]]) {
            ExpressionImageView *imageView = (ExpressionImageView*)aView;
            if (self.exModel.isPlayAnimation) {
                [imageView startAnimating];
            }else {
                [imageView stopAnimating];
            }
//            if ([imageView isAnimating]) {
//                [imageView stopAnimating];
//                self.exModel.isPlayAnimation = NO;
//            }else {
//                [imageView startAnimating];
//                self.exModel.isPlayAnimation = YES;
//            }
        }
    }
}

-(void)setParser:(ExpressionsParser *)aParser{
    self.backgroundColor = [UIColor clearColor];
    parser = aParser;
    //[self setNeedsDisplay];
}

-(void)setIsBelongMe:(BOOL)isBelongMe_{
    isBelongMe = isBelongMe_;
    [self setNeedsDisplay];
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //移除subview
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[ExpressionImageView class]]) {
            [aView removeFromSuperview];
        }
    }
    
    //设置字体颜色
    if (isBelongMe) {
        [[UIColor whiteColor] set];
    }else {
        [[UIColor blackColor] set];
    }
    
    //layout
    int totalLines = [parser.departedContentArray count]; //总行数
    
    UIFont *fon=[UIFont systemFontOfSize:14.0f];
    
    //CPLogInfo(@"fon.lineHeight ====%f",fon.lineHeight);
    
    CGFloat upX=0;
    CGFloat upY=0;
    
    CGFloat viewWidth = 0;
    
    for (int i = 0; i<totalLines; i++) {
        NSArray *data = [parser.departedContentArray objectAtIndex:i];
        //CPLogInfo(@"data == %@",data);
        NSNumber *number = [parser.departedHeightArray objectAtIndex:i];
        
        if ([number boolValue]) {  //如果这一行有表情符号
            //CPLogInfo(@"have expression");
            for (int i=0;i<[data count];i++) {
                NSString *str=[data objectAtIndex:i];
                if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]) 
                {
                    //smile_default.gif
                    
                    ExpressionImageView *anim = [[ExpressionImageView alloc] initWithFrame:CGRectMake(upX, upY,kExpressionSizeWidth, kExpressionSizeHeight) expression:str];
                    [self addSubview:anim];
                    anim = nil;
                    

                    upX=kExpressionSizeWidth+upX;
                }else {
                    
                    NSString *temp =str;// []//[str substringWithRange:NSMakeRange(j, 1)];
                    
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
                    [temp drawAtPoint:CGPointMake(upX, upY+18) withFont:fon];

                    upX=upX+size.width;
                }
            }	
            
            upY = upY + kExpressionSizeHeight + kTwoLinePadding;
            //upX = 0;
            
        }else {  //这一行没有表情符号,只绘制文字
            //CPLogInfo(@"NO Expression in this line!!!");
            for (int i=0;i<[data count];i++) {
                
                NSString *str=[data objectAtIndex:i];
                NSString *temp = str;
                CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];

                [temp drawAtPoint:CGPointMake(upX, upY) withFont:fon];
                upX=upX+size.width;
                
            }
            
            upY = upY + kTextSizeHeight + kTwoLinePadding;
            //upX = 0;
        }
        
        viewWidth = upX;  //最大宽度
        upX = 0;
    }
    
    //returnView.backgroundColor = [UIColor clearColor];
    
    //CPLogInfo(@"upY == %f",upY);
    
    
//    CGFloat viewHeight = 0;
//    
//    for (NSNumber *nb in parser.departedHeightArray) {
//        if ([nb boolValue]) {
//            viewHeight = viewHeight + kExpressionSizeHeight+kTwoLinePadding;
//        }else {
//            viewHeight = viewHeight + kTextSizeHeight+kTwoLinePadding;
//        }
//    }
//    
//    viewHeight = viewHeight - kTwoLinePadding;
//    
//    
//    if (1==totalLines) {  //只有一行字
//        returnView.frame = CGRectMake(0, 0, viewWidth, viewHeight);
//    }else {
//        returnView.frame = CGRectMake(0, 0, kMaxWidth, viewHeight);
//    }
    
    if (self.exModel.isPlayAnimation) {
        for (UIView *aView in [self subviews]) {
            if ([aView isKindOfClass:[ExpressionImageView class]]) {
                ExpressionImageView *imageView = (ExpressionImageView*)aView;
                if ([imageView isAnimating]) {
                    [imageView stopAnimating];
                }else {
                    [imageView startAnimating];
                }
            }
        }
    }
}

@end


@implementation SingleSmallExpressionCell

- (void)createAvatar{
    [self createAvatarControl];
}


-(void)textDisplayViewTaped:(TextDisplayView *)textDisplayView_{
    /*
    if ([self.delegate respondsToSelector:@selector(smallExpressionCellTaped:)]) {
        [self.delegate smallExpressionCellTaped:self];
    }
    */
}

-(void)backgroundTaped:(id)sender{
    
    
    if ([self.delegate respondsToSelector:@selector(smallExpressionCellTaped:)]) {
        [self.delegate smallExpressionCellTaped:self];
    }
    [textDisplayView refreshAnim];
}


- (id)initWithType : (MessageCellType) messageCellType  withBelongMe : (BOOL) isBelongMe withKey:(NSString *)key{
    self = [super initWithType:messageCellType withBelongMe:isBelongMe withKey:key];
    if (self) {
        
        textDisplayView = [[TextDisplayView alloc] initWithFrame:CGRectZero];
        textDisplayView.isBelongMe = isBelongMe;
        textDisplayView.exclusiveTouch = YES;
        textDisplayView.userInteractionEnabled = NO;
        //[self addSubview:textDisplayView];
        
        ellipticalBackground.exclusiveTouch = YES;
        [ellipticalBackground addTarget:self action:@selector(backgroundTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}


-(CGSize)calculateTextDisplayViewSize:(ExMessageModel *)model{
    
    CGFloat viewWidth = 0;  //最大宽度
    for (NSNumber *wid in model.expressionsParser.departedWidthArray) {
        if ([wid floatValue]>=viewWidth) {
            viewWidth = [wid floatValue];
        }
    }
    
    CGFloat viewHeight = 0;
    for (NSNumber *nb in model.expressionsParser.departedHeightArray) {
        if ([nb boolValue]) {
            viewHeight = viewHeight + kExpressionSizeHeight+kTwoLinePadding;
        }else {
            viewHeight = viewHeight + kTextSizeHeight+kTwoLinePadding;
        }
    }
    viewHeight = viewHeight - kTwoLinePadding;
    
    if (1==[model.expressionsParser.departedHeightArray count]) {  //只有一行字
        CGFloat width1 = 0;
        
        for (NSString *str in [model.expressionsParser.departedContentArray objectAtIndex:0]) {
            
            if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]) {
                width1 = width1 + kExpressionSizeWidth;
            }else {
                CGSize size=[str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
                
                width1 = width1 + size.width;
            }
        }
        
        return CGSizeMake(width1, viewHeight);
    }else {
        return CGSizeMake(viewWidth, viewHeight); // kMaxWidth
    }
}

- (void)refreshCell{
    [super refreshCell];
    ExMessageModel *model = (ExMessageModel*)self.data;

    //背景最大宽度 251  字能占的宽度 251 - 11 - 11ian
    [self adaptEllipticalBackgroundImage];
    
    textDisplayView.exModel = model;
    
    [self addSubview:textDisplayView];
    [textDisplayView setParser:model.expressionsParser];
    CGSize size = [self calculateTextDisplayViewSize:model];
    textDisplayView.frame = CGRectMake(0, 0, size.width, size.height);
    textDisplayView.backgroundColor = [UIColor clearColor];
    
    // 文字宽度偏小的时候
    CGFloat backWidth = size.width;
    if (size.width<21) {
        backWidth = 21;  //保证最小宽度
    }
    
    if (self.isBelongMe) {
        self.ellipticalBackground.frame = CGRectMake(56.0f, kCellTopPadding + 2.0f, backWidth+2*kLeftAndRightPadding, textDisplayView.frame.size.height+2*(kTopAndButtomPadding-2));
    }else{
        self.ellipticalBackground.frame = CGRectMake(320.0f - 56.0f - (backWidth+2*kLeftAndRightPadding), kCellTopPadding + 2.0f, backWidth+2*kLeftAndRightPadding, textDisplayView.frame.size.height+2*(kTopAndButtomPadding-2));
    }
    textDisplayView.frame = CGRectMake(ellipticalBackground.frame.origin.x+(ellipticalBackground.frame.size.width - backWidth)/2, kCellTopPadding + (kTopAndButtomPadding-2), textDisplayView.frame.size.width, textDisplayView.frame.size.height);
    textDisplayView.center = self.ellipticalBackground.center; //中间对齐
    
    textDisplayView.isBelongMe = self.isBelongMe;
    
    
    timestampLabel.frame = CGRectMake((320 -50)/2, ellipticalBackground.frame.size.height+kCellTopPadding, 50, kTimestampLabelHeight);
    timestampLabel.text = [self timeStringFromNumber:model.messageModel.date];

    self.resendButton.frame = CGRectMake(ellipticalBackground.frame.origin.x + ellipticalBackground.frame.size.width + 10.0f, 
                                         ( ellipticalBackground.frame.size.height - kResendButtonWidth ) /2.0f +2.0f ,
                                         kResendButtonWidth, kResendButtonWidth);
    
    if (!model.isGroupMessageTable) {
        if (model.isShowAlarmTip && self.isBelongMe) {
            [self showAlarmTip];
        }else{
            [self.alarmTip removeFromSuperview];
            self.alarmTip = nil;
        }
    }
    [self bringSubviewToFront:self.alarmTip];
    
    if (self.isBelongMe) {
        avatar.frame = CGRectMake(7.5f, ellipticalBackground.frame.origin.y + ellipticalBackground.frame.size.height -  kAvatarHeight + 4.0f, kAvatarWidth, kAvatarHeight);
    }else{
        avatar.frame = CGRectMake(320.0f-7.5f-kAvatarWidth, ellipticalBackground.frame.origin.y+ ellipticalBackground.frame.size.height -  kAvatarHeight + 4.0f, kAvatarWidth, kAvatarHeight);
    }
    
    if (!self.userHeadImage) {
        avatar.backImage = [UIImage imageNamed:@"headpic_index_normal_120x120"];
    }else {
        avatar.backImage = self.userHeadImage;
    }
}

-(void) showAlarmTip{
    if ( nil == self.alarmTip ) {
        [self createAlarmTip];
    }
    [self.alarmTip setBackgroundImage:[UIImage imageNamed:@"alarm_im_btn_chatset_nor.png"] forState:UIControlStateNormal];
    [self.alarmTip setBackgroundImage:[UIImage imageNamed:@"alarm_im_btn_chatset_press.png"] forState:UIControlStateHighlighted];
    if (self.isBelongMe) {
        self.alarmTip.frame = CGRectMake(ellipticalBackground.frame.origin.x + ellipticalBackground.frame.size.width, ellipticalBackground.frame.origin.y, 35.0f, 35.0f);
    }else{
        self.alarmTip.frame = CGRectMake(ellipticalBackground.frame.origin.x-2.0f, ellipticalBackground.frame.origin.y, 35.0f, 35.0f);
    }
}

-(void) alarmTipTaped:(HPHeadView *)sender{
    NSLog(@"闹钟被点击");
    if ([self.delegate respondsToSelector:@selector(clickedAlarmTip:)]) {
        [self.delegate clickedAlarmTip:self.data];
    }
}

-(void)layoutBaseControls{
    resendButton.frame = CGRectMake(320 - kResendButtonWidth - 5, 5, kResendButtonWidth, kResendButtonHeight);
}


@end
