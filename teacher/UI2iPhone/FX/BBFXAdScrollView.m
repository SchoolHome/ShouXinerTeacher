//
//  BBFXAdScrollView.m
//  teacher
//
//  Created by mac on 14/11/10.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFXAdScrollView.h"

@implementation BBFXAdScrollView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        adScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [adScroll setDelegate:(id<UIScrollViewDelegate>)self];
        [adScroll setShowsHorizontalScrollIndicator:NO];
        [adScroll setPagingEnabled:YES];
        [self addSubview:adScroll];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height-25, frame.size.width, 20)];
        [pageControl setPageIndicatorTintColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.5f]];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
    }
    return self;
}

-(void)setAdsArray:(NSArray *)adsArray
{
    _adsArray = adsArray;
    NSInteger count = [self.adsArray count];
    [pageControl setNumberOfPages:count];
    [adScroll setContentSize:CGSizeMake(adScroll.frame.size.width*count, adScroll.frame.size.height)];
    for (int i=0; i<count; i++) {
        BBFXModel *model = [self.adsArray objectAtIndex:i];
        EGOImageView *egoAdView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@""]];
        [egoAdView setFrame:CGRectMake(adScroll.frame.size.width*i, 0, adScroll.frame.size.width, adScroll.frame.size.height)];
        [egoAdView setTag:i];
        [egoAdView setImageURL:[NSURL URLWithString:model.image]];
        [egoAdView setUserInteractionEnabled:YES];
        [adScroll addSubview:egoAdView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEgoAdView:)];
        [egoAdView addGestureRecognizer:tap];
    }
}

-(void)tapEgoAdView:(UITapGestureRecognizer *)tap
{
    EGOImageView *egoAdView = (EGOImageView *)tap.view;
    NSInteger tag = egoAdView.tag;
    BBFXModel *model = [self.adsArray objectAtIndex:tag];
    if (_delegate && [self.delegate respondsToSelector:@selector(adViewTapped:)]) {
        [self.delegate performSelector:@selector(adViewTapped:) withObject:model];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

- (void)changePage:(UIPageControl *)sender
{
     int page = pageControl.currentPage;
    CGRect frame = adScroll.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [adScroll scrollRectToVisible:frame animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
