//
//  BBFXAdScrollView.h
//  teacher
//
//  Created by mac on 14/11/10.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBFXModel.h"
#import "EGOImageView.h"

@protocol BBFXAdScrollViewDelegate <NSObject>
-(void)adViewTapped:(BBFXModel *)model;
@end
@interface BBFXAdScrollView : UIView
{
    UIScrollView *adScroll;
}
@property (nonatomic, strong) NSArray *adsArray;
@property (nonatomic, assign) id<BBFXAdScrollViewDelegate> delegate;
@end
