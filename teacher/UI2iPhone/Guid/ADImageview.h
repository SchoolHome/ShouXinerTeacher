//
//  ADImageview.h
//  teacher
//
//  Created by ZhangQing on 14-8-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "EGOImageView.h"
@protocol ADImageviewDelegate <NSObject>
-(void)imageTappedURL:(NSURL *)url;
@end
@interface ADImageview : UIView<EGOImageViewDelegate>
@property (nonatomic, assign) id<ADImageviewDelegate> adDelegate;
@property (nonatomic, strong) NSURL *imgUrl;
@property (nonatomic, strong) NSURL *webUrl;
-(id)initWithAdvDic:(NSDictionary *)advDic;
@end
