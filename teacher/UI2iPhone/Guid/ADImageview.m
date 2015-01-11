//
//  ADImageview.m
//  teacher
//
//  Created by ZhangQing on 14-8-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define closeButtonWidth 44.f
#define closeButtonHeight 20.f
#import "ADImageview.h"
#import "UIImage+ProportionalFill.h"
@implementation ADImageview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        

    }
    return self;
}

-(id)initWithAdvDic:(NSDictionary *)advDic;
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    //280,400.
    self = [self initWithFrame:CGRectMake(0.f, 0.f, 320.f, screenHeight)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        UIImageView *bg = [[UIImageView alloc] initWithFrame:self.frame];
//        bg.backgroundColor  = [UIColor blackColor];
//        bg.alpha = 0.4;
//        [self addSubview:bg];
        self.webUrl = advDic[@"url"];
        self.imgUrl = [NSURL URLWithString:advDic[@"image"]];
        EGOImageView *adImageview = [[EGOImageView alloc] initWithFrame:CGRectMake(0,0 , 320.f, screenHeight)];
        [adImageview setImageURL:self.imgUrl];
        [self addSubview:adImageview];
        
        if ([advDic[@"closeButton"] boolValue]) {
            UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
            [close setFrame:CGRectMake(320-closeButtonWidth, screenHeight-closeButtonHeight, closeButtonWidth, closeButtonHeight)];
            //[close setBackgroundImage:[UIImage imageNamed:@"ZJZBaige"] forState:UIControlStateNormal];
            [close setTitle:@"关闭" forState:UIControlStateNormal];
            close.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
            [close setBackgroundColor:[UIColor colorWithRed:178/255.f green:0.f blue:25/255.f alpha:1.f]];
            [close addTarget:self action:@selector(closeAD) forControlEvents:UIControlEventTouchUpInside];
            [adImageview addSubview:close];
        }
        self.userInteractionEnabled = YES;
        adImageview.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage)];
        [adImageview addGestureRecognizer:tap];
    }
    return self;
}

-(void)closeAD
{
    [self removeFromSuperview];
}

-(void)tapImage
{
    if ([self.adDelegate respondsToSelector:@selector(imageTappedURL:)]) {
        [self.adDelegate imageTappedURL:self.webUrl];
        [self removeFromSuperview];
    }
}

-(void)imageViewLoadedImage:(EGOImageView *)imageView
{
    CGSize imageSize = imageView.image.size;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (imageSize.width <= 320 && imageSize.height <= screenHeight) {
        [imageView setFrame:CGRectMake((320-imageSize.width)/2, (screenHeight-imageSize.height)/2, imageSize.width, imageSize.height)];
    }else
    {
        [imageView setImage:[imageView.image imageByScalingAndCroppingForSizeEx:CGSizeMake(320.f, screenHeight)]];
    }
    
}
-(void)imageViewFailedToLoadImage:(EGOImageView *)imageView error:(NSError *)error
{
    NSLog(@"error");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
