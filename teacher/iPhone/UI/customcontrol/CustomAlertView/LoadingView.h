//
//  LoadingView.h
//  iCouple
//
//  Created by shuo wang on 12-5-17.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertDelegate.h"

@interface LoadingView : UIView

@property (nonatomic,strong) NSString *messageString;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) id<LoadMessageDelegate> delegate;
@property (nonatomic) BOOL isClose;  // 2012.11.1 by xxx 外部需要调用是否关闭的状态

-(id) initWithMessageString : (NSString *) messageString;
-(id) initWithMessageString : (NSString *) messageString withTimeOut : (NSTimeInterval) timeOut;
-(void) close;

@end
