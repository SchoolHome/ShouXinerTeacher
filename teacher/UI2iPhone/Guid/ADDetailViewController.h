//
//  ADDetailViewController.h
//  teacher
//
//  Created by ZhangQing on 14-8-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
typedef enum
{
    AD_TYPE_BANNER = 1,
    AD_TYPE_SCREEN = 2
}AD_TYPE;
@interface ADDetailViewController : PalmViewController<UIWebViewDelegate>
{
    NSInteger adType;
}
-(id)initWithUrl:(NSURL *)url andADType:(AD_TYPE)type;

@end
