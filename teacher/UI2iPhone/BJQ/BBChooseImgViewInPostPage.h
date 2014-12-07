//
//  BBChooseImgViewInPostPage.h
//  teacher
//
//  Created by ZhangQing on 14-10-30.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define IMAGE_WIDTH 65.f
#define IMAGE_HEIGHT 65.f
#define IMAGE_INTERVAL 10.f

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@protocol BBChooseImgViewInPostPageDelegate <NSObject>

- (void)shouldAddImage:(NSInteger)imagesCount;

@optional
//boundsChanged
- (void)viewBoundsChanged:(CGRect )viewframe;

//已超过最大照片数
- (void)cannotAddImage;

- (void)imageDidDelete;

- (void)imageDidTapped:(NSArray *)images andIndex:(NSInteger)index;
@end
@interface BBChooseImgViewInPostPage : UIView <UIActionSheetDelegate>
{
    
}
@property (nonatomic, weak) id<BBChooseImgViewInPostPageDelegate> delegate;

@property (nonatomic)NSUInteger maxImages;//最多图片数,默认是7张
@property (nonatomic, readonly)NSMutableArray *images;//已存在图片

//添加一张图片
- (void)addImage:(UIImage *)image;
//添加多张图片
- (void)addImages:(NSArray *)images;

- (void)addVideoImage:(UIImage *)image;

- (void)closeImageBtn;

- (void)removeImage:(NSInteger)index;
@end
