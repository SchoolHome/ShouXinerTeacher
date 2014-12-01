//
//  BBServiceMessageWebViewController.h
//  teacher
//
//  Created by ZhangQing on 14/11/29.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBServiceMessageDetailModel.h"

@interface BBServiceMessageWebViewController : PalmViewController
{
    UIWebView *webView;
}

@property (nonatomic ,strong) BBServiceMessageDetailModel *model;
@end
