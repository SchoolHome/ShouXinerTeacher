//
//  MessagePictrueViewController.m
//  iCouple
//
//  Created by shuo wang on 12-5-8.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


#import "MessagePictrueViewController.h"
#import "CustomAlertView.h"

@interface MessagePictrueViewController ()
// 图片的存储路径
@property (nonatomic,strong) NSString *path;
// 保存浮层
@property (nonatomic,strong) LoadingView *loadingView;

//计算UIImage的最大Frame
-(CGRect) calculateImageRect;
// 保存图片ActionSheet
-(void) saveImageToLocationActionSheet : (UIGestureRecognizer *) press;
// 保存图片方法
-(void) saveImageToLocation;
// 保存图片的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
// 关闭图片显示动画
-(void) closeImageViewAnimation;
@end

@implementation MessagePictrueViewController
@synthesize imageView = _imageView , scrollView = _scrollView , path = _path;
@synthesize imageViewRect = _imageViewRect , isSaveing = _isSaveing , isuserCloseImageView = _isuserCloseImageView;
@synthesize delegate = _delegate , isBeganShowAnimation = _isBeganShowAnimation;
@synthesize isEndCloseAnimation = _isEndCloseAnimation;
@synthesize loadingView = _loadingView;

-(id) initWithPictruePath : (NSString *) pictruePath withRect : (CGRect) rect {
    self = [super init];
    if (self) {
        self.path = pictruePath;
        self.imageViewRect = rect;
        self.isSaveing = NO;
        self.isuserCloseImageView = NO;
        
        self.isBeganShowAnimation = YES;
        self.isEndCloseAnimation = NO;
    }
    return self;
}

// 截取当前用户触摸输入
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
}

// 关闭图片显示动画
-(void) closeImageViewAnimation{
    
    // 调用外层view处理关闭动画
    if ([self.delegate respondsToSelector:@selector(beganCloseImageAnimation)]) {
        [self.delegate beganCloseImageAnimation];
    }
    
    CGRect closeRect = [self.scrollView convertRect:self.imageViewRect fromView:nil];
    
    [UIView animateWithDuration:ANIMATIONTIME animations:^{
        self.imageView.frame = closeRect;
        
        self.view.backgroundColor = [UIColor blackColor];
        self.view.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(endCloseImageAnimation)]) {
            [self.delegate endCloseImageAnimation];
        }
    }];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:self.imageViewRect];
    UIImage *image = [UIImage imageWithContentsOfFile:self.path];
    self.imageView.image = image;
    
    float height = 0.0f;
    if (isIPhone5) {
        height = 568.0f;
    }else{
        height = 480.0f;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
    [self.scrollView addSubview:self.imageView];
    
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 3.0f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setZoomScale:1.0f animated:YES];
    
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    // 增加手势，，当长按时，触发保存图片事件
    UILongPressGestureRecognizer *longPressRecognizer;
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImageToLocationActionSheet:)];
    [self.scrollView addGestureRecognizer:longPressRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeImageView:)];
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    
    [[HPStatusBarTipView shareInstance] setHidden:YES];
    
    // uiview动画
    [UIImageView beginAnimations:@"ImageBegin" context:nil];
    [UIImageView setAnimationDelay:0.1f];
    [UIImageView setAnimationDuration:ANIMATIONTIME];
    [UIImageView setAnimationCurve:UIViewAnimationCurveLinear];
    
    // 动画的结束回调，回调方法内，增加下载按钮
    [UIImageView setAnimationDelegate:self];
    [UIImageView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    self.imageView.frame = [self calculateImageRect];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor blackColor];
    [UIImageView commitAnimations];
}

// 动画的结束回调，回调方法内，增加下载按钮
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if ([animationID isEqualToString:@"ImageBegin"]) {
        self.isBeganShowAnimation = NO;
    }else {
        if ([self.delegate respondsToSelector:@selector(endCloseImageAnimation)]) {
            [self.delegate endCloseImageAnimation];
        }
    }
}

// 计算UIImageView的点位和大小
-(CGRect) calculateImageRect{
    CGRect rect;
    UIImage *image = [UIImage imageWithContentsOfFile:self.path];

    float maxHeight = 960.0f;
    float height = 480.0f;
    if (isIPhone5) {
        maxHeight = 1136.0f;
        height = 568.0f;
    }
    
    if (image.size.width <= 640.0f && image.size.height <=maxHeight) {
        rect.origin.x = (320.0f - image.size.width / 2.0f) / 2.0f;
        rect.origin.y = (height - image.size.height / 2.0f) / 2.0f;
        rect.size.width = image.size.width / 2.0f;
        rect.size.height = image.size.height / 2.0f;
        return rect;
    }else if (image.size.width > 640.0f && image.size.height <= maxHeight) {
        rect.origin.x = 0.0f;
        rect.size.width = 320.0f;
        
        float horizontalScale = 640.0f / image.size.width;
        rect.size.height = (image.size.height * horizontalScale) / 2.0f;
        rect.origin.y = (height - rect.size.height) / 2.0f;
        return rect;
    }else if (image.size.width <= 640.0f && image.size.height > maxHeight) {
        rect.origin.y = 0.0f;
        rect.size.height = height;
        
        float verticalScale = maxHeight / image.size.height;
        rect.size.width = (image.size.width * verticalScale) /2.0f;
        rect.origin.x = (320.0f - rect.size.width) / 2.0f;
        return rect;
    }else {
        float horizontalScale = 640.0f / image.size.width;
        float verticalScale = maxHeight / image.size.height;
        
        if (horizontalScale <= verticalScale) {
            rect.size.width = (image.size.width * horizontalScale) / 2.0f;
            rect.size.height = (image.size.height * horizontalScale) / 2.0f;
            
            rect.origin.x = 0.0f;
            rect.origin.y = (height - rect.size.height) / 2.0f;
            return rect;
        }else {
            rect.size.width = (image.size.width * verticalScale) / 2.0f;
            rect.size.height = (image.size.height * verticalScale) /2.0f;
            
            rect.origin.x = (320.0f - rect.size.width) / 2.0f;
            rect.origin.y = 0.0f;
            return rect;
        }
    }
}

-(void) scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    //返回ScrollView上添加的需要缩放的视图
    return self.imageView; 
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

// 点击时，展示关闭动画
-(void) closeImageView : (UIGestureRecognizer *) press{
    if (self.isBeganShowAnimation) {
        return;
    }
    if (self.isEndCloseAnimation) {
        return;
    }
    self.isEndCloseAnimation = YES;
    [self closeImageViewAnimation];
}

// 长按时，保存图片到本地
-(void) saveImageToLocationActionSheet : (UIGestureRecognizer *) press{
    if (press.state != UIGestureRecognizerStateBegan) {  
        return;  
    }
    // 如果用户正在保存返回
    if (self.isSaveing) {
        return;
    }
    
    NSMutableArray *saveImage = [[NSMutableArray alloc] initWithCapacity:2];
    [saveImage addObject:@"保存图片到本地"];
    
    UIActionSheet *saveSheet = [[UIActionSheet alloc] initWithTitle:@"" 
                                                      delegate:self 
                                                      cancelButtonTitle:nil 
                                                      destructiveButtonTitle:nil 
                                                      otherButtonTitles:nil, 
                                                      nil];
    for (NSString *str in saveImage) {
        [saveSheet addButtonWithTitle:str];
    }
    
    [saveSheet addButtonWithTitle:@"取消"];
    saveSheet.destructiveButtonIndex = saveSheet.numberOfButtons - 1;
    [saveSheet showFromRect:self.view.bounds inView:self.view animated:YES];
}

// ActionSheet的回调方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    // 如果是点击了取消按钮，则返回
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        return;
    }else {
        [self saveImageToLocation];
    }
}

// 保存图片方法
-(void) saveImageToLocation{
    // 如果用户正在返回
    if (self.isSaveing) {
        return;
    }
    
    CustomAlertView *custom = [[CustomAlertView alloc] init];
    self.loadingView = [custom showLoadingMessageBox:@"正在保存..."];
    
    self.isSaveing = YES;
    // 保存图片到本地相册
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

// 保存图片的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSString *loadingString = @"";
    if (error == nil){
        // 成功保存图片
        loadingString = @"保存成功";
    }
    else{
        // 保存图片失败
        loadingString = @"保存失败";
    }
    [self.loadingView setMessageString:loadingString];
    if (error == nil) {
        UIImage *completeImage = [UIImage imageNamed:@"right_arrow.png"];
        [self.loadingView setImage:completeImage];
    }else {
        [self.loadingView setImage:nil];
    }
    
    [self.loadingView close];
    
    self.isSaveing = NO;
}

@end
