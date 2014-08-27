//
//  BBScrollViewWithPageControl.h
//  teacher
//
//  Created by ZhangQing on 14-8-20.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define SCROLLVIEW_IMAGEVIEW_HEIGHT 200.f

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "BBScrollViewInfoModel.h"

#pragma mark - BBScrollViewInfo
//InfoDelegate
@protocol ContentScrollviewInfoDelegate <NSObject>

-(void)infoTapped:(BBScrollViewInfoModel *)model;

@end

//Info
@interface BBScrollViewInfo : UIView <EGOImageViewDelegate>
{
    UIView *titleBackground;
}
@property (nonatomic , strong)EGOImageView *imageview;
@property (nonatomic , strong)UILabel *title;
@property (nonatomic , strong) BBScrollViewInfoModel *infoModel;
@property (nonatomic , assign) id<ContentScrollviewInfoDelegate> infoDelegate;

@end


#pragma mark - CustomPageControl
//pageControlDelegate
@protocol CustomPageControlDelegate <NSObject>

@required
-(void)pageControlitemTapped:(NSInteger)indexNumber;

@end

@interface CustomPageControl : UIControl
{
    NSInteger _numberOfPages;
    NSInteger _currentPage;
    UIButton *controlBtn[5];
}
@property (nonatomic , assign) id<CustomPageControlDelegate> _delegate;

-(void)setNumberOfPages : (NSInteger) number;

-(void)setCurrentPage:(NSInteger)currentPage;

-(NSInteger)getCurrentPage;
@end

#pragma mark - BBScrollViewWithPageControl
@interface BBScrollViewWithPageControl : UIScrollView<ContentScrollviewInfoDelegate,CustomPageControlDelegate,UIScrollViewDelegate>
{
    CustomPageControl *_pageControl;
    NSArray *_models;
    NSTimer *_autoDisplayTimer;
    
    BOOL _needAutoDisplay;
}
-(id)initWithModels:(NSArray *)models;

-(void)setNeedAutoDisplayImage:(BOOL)needPlay;
@end