//
//  BBJFViewController.m
//  teacher
//
//  Created by mtf on 14-4-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBJFViewController.h"

@interface BBJFViewController ()

@end

@implementation BBJFViewController

-(void)backButtonTaped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"BBBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.title = @"手心商城";
    int heightFix = 20;
    if (IOS7) {
        heightFix = 20;
    }else{
        heightFix = 0;
    }
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-44-heightFix)];
    [self.view addSubview:webView];
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:_url];
    [webView loadRequest:req];
}

-(void)setUrl:(NSURL *)url{
    _url = url;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
