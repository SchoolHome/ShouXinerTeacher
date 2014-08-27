//
//  BBScrollViewWithPageControl.m
//  teacher
//
//  Created by ZhangQing on 14-8-20.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBScrollViewWithPageControl.h"
#import "UIImage+ProportionalFill.h"
//#import "UIView+DebugRect.h"

@implementation BBScrollViewWithPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.pagingEnabled = YES;
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}
-(id)initWithModels:(NSArray *)models
{
    self = [super initWithFrame:CGRectMake(0.f, 0.f, 320.f, SCROLLVIEW_IMAGEVIEW_HEIGHT)];
    if (self) {
        self.contentSize = CGSizeMake(320.f*models.count, SCROLLVIEW_IMAGEVIEW_HEIGHT);

        for (int i = 0; i<models.count; i++) {
            BBScrollViewInfo *contentScrollview = [[BBScrollViewInfo alloc] initWithFrame:CGRectMake(320.f*i, 0.f, 320.f, self.frame.size.height)];
            contentScrollview.infoDelegate = self;
            [contentScrollview  setInfoModel:models[i]];
            [self addSubview:contentScrollview];
        }
        
        _models = [[NSArray alloc] initWithArray:models];
    }
    return self;
}
-(void)setNeedAutoDisplayImage:(BOOL)needPlay;
{
    if (needPlay) {
        if (!_autoDisplayTimer) {
            _autoDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
        }
    }
}
//scrollview内容自动滚动
-(void)autoPlay
{
    if (_needAutoDisplay) {
        if ([_pageControl getCurrentPage] == _models.count-1) {
            [_pageControl setCurrentPage:0] ;
            [self scrollRectToVisible:CGRectMake(0, 0.f, 320.f, SCROLLVIEW_IMAGEVIEW_HEIGHT) animated:NO];
        }else
        {
            [_pageControl setCurrentPage:[_pageControl getCurrentPage]+1] ;
            [self scrollRectToVisible:CGRectMake(320*[_pageControl getCurrentPage], 0.f, 320.f, SCROLLVIEW_IMAGEVIEW_HEIGHT) animated:YES];
        }
        
    }
    
}
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    _needAutoDisplay = YES;
    
    NSInteger page = scrollView.contentOffset.x/320;
    [_pageControl setCurrentPage:page];
    
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _needAutoDisplay = NO;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark Delegate
-(void)infoTapped:(BBScrollViewInfoModel *)model
{
    
}
-(void)pageControlitemTapped:(NSInteger)indexNumber
{
    
}

@end


#pragma mark ----------- BBScrollViewInfo
@implementation BBScrollViewInfo
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageview = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@""]];
        self.imageview.delegate = self;
        [self.imageview setFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
        [self addSubview:self.imageview];
        
        titleBackground = [[UIView alloc] initWithFrame:CGRectMake(0.f, frame.size.height-28.f, 320.f, 28.f)];
        titleBackground.backgroundColor = [UIColor whiteColor];
        titleBackground.alpha = 0.6;
        [self addSubview:titleBackground];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0.f, frame.size.height-24.f, 320.f, 20.f)];
        self.title.font = [UIFont boldSystemFontOfSize:18.f];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textColor = [UIColor whiteColor];
        [self addSubview:self.title];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)setInfoModel:(BBScrollViewInfoModel *)infoModel
{
    _infoModel = infoModel;
    [self setNeedsDisplay];
}
-(void)tap:(UIGestureRecognizer *)gesture
{
    NSLog(@"tap");
    if ([self.infoDelegate respondsToSelector:@selector(infoTapped:)]) {
        [self.infoDelegate infoTapped:self.infoModel];
    }
}

 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     
 // Drawing code
     [self.imageview setImageURL:[NSURL URLWithString:self.infoModel.infoImageUrl]];
     
     if ([self.infoModel.infoTitle isEqualToString:@""]) {
         titleBackground.backgroundColor = [UIColor clearColor];
     }else [self.title setText:self.infoModel.infoTitle];
     
 }

-(void)imageViewLoadedImage:(EGOImageView *)imageView
{
    CGSize imageSize = imageView.image.size;
    if (imageSize.width <= 320 && imageSize.height <= SCROLLVIEW_IMAGEVIEW_HEIGHT) {
        [imageView setFrame:CGRectMake((320-imageSize.width)/2, (SCROLLVIEW_IMAGEVIEW_HEIGHT-imageSize.height)/2, imageSize.width, imageSize.height)];
    }else
    {
        [imageView setImage:[imageView.image imageByScalingAndCroppingForSizeEx:CGSizeMake(320.f, SCROLLVIEW_IMAGEVIEW_HEIGHT)]];
    }
    
}
@end

#pragma mark ----------- CustomPageControl
#define Btn_Spacing 12.f
#define Btn_Width 8.f
#define Btn_Height 8.f
#define Left_Padding (self.frame.size.width-Btn_Spacing*(number-1)-Btn_Width*number)/2
@implementation CustomPageControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(void)setNumberOfPages : (NSInteger) number
{
    _numberOfPages = number;
    
    
    for (UIButton *sender in self.subviews) {
        [sender removeFromSuperview];
    }
    
    for (int i = 0; i < number; i++) {
        controlBtn[i] = [UIButton buttonWithType:UIButtonTypeCustom];
        [controlBtn[i] setFrame:CGRectMake(Left_Padding+(Btn_Width+Btn_Spacing)*i,( self.frame.size.height-Btn_Height)/2, Btn_Width, Btn_Height)];
        controlBtn[i].alpha = 0.5;
        controlBtn[i].tag = i+1;
        [controlBtn[i] addTarget:self action:@selector(chooseItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:controlBtn[i]];
    }
}
-(void)chooseItem:(UIButton *)sender
{
    //设置当前页
    _currentPage = sender.tag-1;
    //刷新
    [self setNeedsDisplay];
    //pagecontrol点击事件
    if ([self._delegate respondsToSelector:@selector(pageControlitemTapped:)]) {
        [self._delegate pageControlitemTapped:_currentPage];
    }
}
-(void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    [self setNeedsDisplay];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    for (int i = 0; i < _numberOfPages ; i++) {
        //        UIButton *btn = (UIButton *)[self viewWithTag:i+1];
        if (i == _currentPage) {
            controlBtn[i].backgroundColor = [UIColor whiteColor];
        }else
        {
            controlBtn[i].backgroundColor = [UIColor grayColor];
        }
    }
}

-(NSInteger)getCurrentPage
{
    return _currentPage;
}


@end