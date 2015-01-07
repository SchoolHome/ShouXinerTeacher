//
//  BBBJQBannerView.h
//  teacher
//
//  Created by mac on 15/1/7.
//  Copyright (c) 2015年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BBBJQBannerViewDelegate <NSObject>
-(void)advTappedByURL:(NSURL *)advUrl;
@end
@interface BBBJQBannerView : UIView
{
    UIScrollView *advScroll;
}
@end
