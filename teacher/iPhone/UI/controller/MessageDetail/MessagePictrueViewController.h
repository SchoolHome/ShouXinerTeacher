//
//  MessagePictrueViewController.h
//  iCouple
//
//  Created by shuo wang on 12-5-8.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//


#define ANIMATIONDELAY 0.1f
#define ANIMATIONDURATION 20.0f
// 播放动画的时间
#define ANIMATIONTIME 0.4f

@protocol UserMessageImageDelegate <NSObject>

@required
-(void) beganCloseImageAnimation;
-(void) endCloseImageAnimation;
@end

#import <UIKit/UIKit.h>
#import "HPStatusBarTipView.h"
@interface MessagePictrueViewController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate>

// 展示图片的UIImageView
@property (nonatomic,strong) UIImageView *imageView;
// scrollView
@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic) CGRect imageViewRect;
// 用户是否正在保存照片
@property (nonatomic) BOOL isSaveing;

// 用户是否是关闭图片展示
@property (nonatomic) BOOL isuserCloseImageView;
// 是否正在显示开始动画
@property (nonatomic) BOOL isBeganShowAnimation;
// 是否正在显示结束动画
@property (nonatomic) BOOL isEndCloseAnimation;

// 关闭动画的委托
@property (nonatomic,assign) id<UserMessageImageDelegate> delegate;

-(id) initWithPictruePath : (NSString *) pictruePath withRect : (CGRect) rect;

@end
