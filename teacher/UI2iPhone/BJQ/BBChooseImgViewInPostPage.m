//
//  BBChooseImgViewInPostPage.m
//  teacher
//
//  Created by ZhangQing on 14-10-30.
//  Copyright (c) 2014年 ws. All rights reserved.
//



#import "BBChooseImgViewInPostPage.h"
@interface BBChooseImgViewInPostPage()
{
    CGFloat cacheViewHeight;
    UIButton *deleteBtn;
    
    NSUInteger deleteViewTag;
    
    BOOL isVideoImage;
}
@property (nonatomic, readwrite)NSMutableArray *images;//已存在图片
@property (nonatomic, strong)   UIButton *addImageBtn;
@end

@implementation BBChooseImgViewInPostPage
- (NSMutableArray *)images
{
    if (! _images) _images = [[NSMutableArray alloc] initWithCapacity:7];
    return _images;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *closeGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [self addGestureRecognizer:closeGes];
    }
    
    return self;
}
//添加一张图片
- (void)addImage:(UIImage *)image
{
    if (image) {
        [self.images addObject:image];
        [self setNeedsDisplay];
    }
}
//添加多张图片
- (void)addImages:(NSArray *)images
{
    if (images && images.count && images.count <= _maxImages) {
        [self.images addObjectsFromArray:images];
        [self setNeedsDisplay];
    }
}

- (void)removeImage:(NSInteger)index
{
    [self deleteImage:index];
    [self setNeedsDisplay];
}

- (void)addVideoImage:(UIImage *)image
{
    if (image) {
        [self.images addObject:image];
        isVideoImage = YES;
        
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i < self.images.count+1; i++) {
        
        CGFloat spacing = (self.frame.size.width - IMAGE_WIDTH*4 - IMAGE_INTERVAL*3)/2;
        
        CGRect frame =CGRectMake(
                                 spacing + (IMAGE_WIDTH + IMAGE_INTERVAL)*(i-i/4*4),
                                 IMAGE_INTERVAL + (IMAGE_HEIGHT+IMAGE_INTERVAL)*(i/4),
                                 IMAGE_WIDTH, IMAGE_HEIGHT);
        
        
         if (i == self.images.count || !self.images.count ) {
            if (isVideoImage) {
                [_addImageBtn removeFromSuperview];
                _addImageBtn = nil;
                break;
            }
            
            //add
            if (!_addImageBtn) {
                _addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [_addImageBtn setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
                
                [_addImageBtn addTarget:self action:@selector(addImageAction:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:_addImageBtn];
            }
            [_addImageBtn setFrame:frame];
            
            CGRect selfFrame = self.frame;
            selfFrame.size.height = CGRectGetMaxY(_addImageBtn.frame)+IMAGE_INTERVAL;
            self.frame = selfFrame;
            if (cacheViewHeight != selfFrame.size.height) {
                cacheViewHeight = selfFrame.size.height;
                if ([self.delegate respondsToSelector:@selector(viewBoundsChanged:)]) {
                    [self.delegate viewBoundsChanged:selfFrame];
                }
            }
             
             if (self.images.count == 9) {
                 [_addImageBtn removeFromSuperview];
                 _addImageBtn = nil;
             }
        }else
        {
            EGOImageView *imageview = (EGOImageView *)[self viewWithTag:1000+i];
            if (!imageview) {
                
                imageview = [[EGOImageView alloc] init];
                imageview.userInteractionEnabled = YES;
                [self addSubview:imageview];
                
                if (isVideoImage) {
                    UIImageView *palyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
                    [palyImage setFrame:CGRectMake((IMAGE_WIDTH-35)/2, (IMAGE_HEIGHT-35.f)/2, 35.f, 35.f)];
                    [imageview addSubview:palyImage];
                }
                
                UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addDeleteBtn:)];
                [imageview addGestureRecognizer:longGes];
                
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
                [imageview addGestureRecognizer:tapGes];
            }
            
            UIImage *tempImage = [self.images objectAtIndex:i];
            [imageview setTag:1000+i];
            [imageview setImage:tempImage];
            [imageview setFrame:frame];

        }
    }
}

- (void)closeImageBtn
{
    if (deleteBtn) {
        [deleteBtn removeFromSuperview];
    }
}

- (void)deleteImage : (NSInteger)index
{
    [[self viewWithTag:index+1000] removeFromSuperview];
    for (int i = index+1 ; i < self.images.count; i++) {
        EGOImageView *imageview = (EGOImageView *)[self viewWithTag:1000+i];
        imageview.tag = 1000+i-1;
    }
    [self.images removeObjectAtIndex:index];
    [self closeImageBtn];
    
    if ([self.delegate respondsToSelector:@selector(imageDidDelete)]) {
        [self.delegate imageDidDelete];
    }
}
#pragma mark - actions
- (void)addImageAction:(UIButton *)sender
{
    [self closeImageBtn];
    if (self.images.count >= _maxImages) {
        if ([self.delegate respondsToSelector:@selector(cannotAddImage)]) {
            [self.delegate cannotAddImage];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(shouldAddImage:)]) {
        [self.delegate shouldAddImage:self.images.count];
    }
    
}

- (void)addDeleteBtn:(UILongPressGestureRecognizer *)ges
{
    NSInteger gesTag = ges.view.tag-1000;
    if (self.images.count > gesTag) {
        [self closeImageBtn];
        
        deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setFrame:CGRectMake(CGRectGetMaxX(ges.view.frame)-10.f, CGRectGetMinY(ges.view.frame)-10.f, 22.f, 22.f)];
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"imageClose"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        
        deleteViewTag = gesTag;
    }
}

- (void)deleteImageAction:(UIButton *)sender
{
    [self deleteImage:deleteViewTag];
    if (isVideoImage) {
        isVideoImage = NO;
    }
    [self setNeedsDisplay];
}

- (void)tapAction:(UITapGestureRecognizer *)ges
{
    if ([self.delegate respondsToSelector:@selector(imageDidTapped:andIndex:)]) {
        [self.delegate imageDidTapped:self.images andIndex:ges.view.tag-1000];
    }
}

- (void)close
{
    [self closeImageBtn];
}
@end
