//
//  BBShareWebViewController.h
//  teacher
//
//  Created by singlew on 14/12/15.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

@interface BBShareWebViewController : PalmViewController
{
    
    UIWebView *webView;
}

@property(nonatomic,strong) NSURL *url;

@end
