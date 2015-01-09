//
//  BBBJQBannerView.m
//  teacher
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 ws. All rights reserved.
//

#import "BBBJQBannerView.h"

@implementation BBBJQBannerView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
    }
    return self;
}

-(id)initWithAdvs:(NSArray *)advs
{
    advsArray = advs;
    CGFloat fixY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
    {
        fixY = 20;
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self = [self initWithFrame:CGRectMake(0, fixY, screenWidth, 70)];
    if (self) {
        advScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        for (int i=0; i<advsArray.count; i++) {
            NSDictionary *advDic = [advsArray objectAtIndex:i];
            lastTime = [advDic[@"closeButton"] integerValue];
            EGOImageView *adImageview = [[EGOImageView alloc] initWithFrame:CGRectMake(i*advScroll.frame.size.width, 0, advScroll.frame.size.width, advScroll.frame.size.height)];
            [adImageview setDelegate:(id<EGOImageViewDelegate>)self];
            [adImageview setImageURL:[NSURL URLWithString:advDic[@"image"]]];
            [adImageview setUserInteractionEnabled:YES];
            [adImageview setTag:i];
            [advScroll addSubview:adImageview];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapADVImage:)];
            [adImageview addGestureRecognizer:tap];
        }
        [advScroll setContentSize:CGSizeMake(screenWidth*advsArray.count, advScroll.frame.size.height)];
        [self addSubview:advScroll];
        //关闭按钮与倒计时显示label
        CGFloat imgWidth = 26;
        if (lastTime > 0) {
            NSString *strTime = [NSString stringWithFormat:@"%d秒关闭", lastTime];
            UIFont *font = [UIFont systemFontOfSize:12];
            CGSize size = [strTime sizeWithFont:font];
            txtTime = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth-36-size.width, 10, size.width, 15)];
            [txtTime setBackgroundColor:[UIColor clearColor]];
            [txtTime setFont:font];
            [txtTime setTextColor:[UIColor whiteColor]];
            [txtTime setText:strTime];
            imgWidth = imgWidth + size.width + 4;
        }
        UIImage *grayBgImg = [UIImage imageNamed:@"bjq_banner_graybg.png"];
        grayBgImg = [grayBgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 13)];
        UIImageView *grayBg = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth-imgWidth-10, 5, imgWidth, 26)];
        [grayBg setImage:grayBgImg];
        [self addSubview:grayBg];
        [self addSubview:txtTime];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(screenWidth-36, 5, 26, 26)];
        [closeBtn addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn setImage:[UIImage imageNamed:@"bjq_banner_close.png"] forState:UIControlStateNormal];
        [self addSubview:closeBtn];
        
//        [self setAlpha:0];
    }
    return self;
}

-(void)imageViewLoadedImage:(EGOImageView *)imageView
{
    [self setAlpha:1.0];
    if (lastTime > 0) {
        closeTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeClose) userInfo:nil repeats:YES];
    }
}

-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error
{
    NSLog(@"error");
}

-(void)timeClose
{
    lastTime = lastTime - 1;
    if (lastTime == 0) {
        [closeTimer invalidate];
        closeTimer = nil;
        [self closeSelf];
        return;
    }
    [txtTime setText:[NSString stringWithFormat:@"%d秒关闭", lastTime]];
}

-(void)tapADVImage:(UITapGestureRecognizer *)tap
{
    EGOImageView *adImageview = (EGOImageView *)tap.view;
    NSInteger index = adImageview.tag;
    NSDictionary *advDic = [advsArray objectAtIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(advTappedByURL:)]) {
        [self.delegate advTappedByURL:[NSURL URLWithString:advDic[@"url"]]];
    }
    [self closeSelf];
}

-(void)closeSelf
{
    [self removeFromSuperview];
    self.delegate = nil;
}
@end
