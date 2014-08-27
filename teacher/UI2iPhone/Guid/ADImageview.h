//
//  ADImageview.h
//  teacher
//
//  Created by ZhangQing on 14-8-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "EGOImageView.h"
@protocol ADImageviewDelegate <NSObject>
-(void)imageTapped;
@end
@interface ADImageview : UIView<EGOImageViewDelegate>
@property (nonatomic, assign) id<ADImageviewDelegate> adDelegate;


-(id)initWithUrl:(NSURL *)url;
@end
