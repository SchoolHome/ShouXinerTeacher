//
//  BBBJQBannerView.h
//  teacher
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 ws. All rights reserved.
//

#import "EGOImageView.h"
@protocol BBBJQBannerViewDelegate <NSObject>
-(void)advTappedByURL:(NSURL *)advUrl;
@end
@interface BBBJQBannerView : UIView<EGOImageViewDelegate>
{
    UIScrollView *advScroll;
    UILabel *txtTime;
    NSArray *advsArray;
    NSInteger lastTime;
    NSTimer *closeTimer;
}
@property (nonatomic, weak) id<BBBJQBannerViewDelegate> delegate;
-(id)initWithAdvs:(NSArray *)advs;
@end
