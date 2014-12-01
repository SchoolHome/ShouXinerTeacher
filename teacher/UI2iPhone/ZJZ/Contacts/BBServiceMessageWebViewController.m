//
//  BBServiceMessageWebViewController.m
//  teacher
//
//  Created by ZhangQing on 14/11/29.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBServiceMessageWebViewController.h"
#import "BBServiceMessageShareViewController.h"
@interface BBServiceMessageWebViewController ()

@end

@implementation BBServiceMessageWebViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *share = [UIButton buttonWithType:UIButtonTypeCustom];
    [share setFrame:CGRectMake(0.f, 7.f, 60.f, 24.f)];
    //[share setBackgroundImage:[UIImage imageNamed:@"user_alt"] forState:UIControlStateNormal];
    [share setTitle:@"分享" forState:UIControlStateNormal];
    [share setTitleColor:[UIColor colorWithRed:251/255.f green:76/255.f blue:7/255.f alpha:1.f] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(shareButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:share];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.screenHeight-44)];
    [self.view addSubview:webView];
    

}

- (void)viewDidAppear:(BOOL)animated
{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.model.link]];
    [webView loadRequest:req];
}

- (void)setModel:(BBServiceMessageDetailModel *)model
{
    _model = model;
}

- (void)backButtonTaped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareButtonTaped
{
    BBServiceMessageShareViewController *messageShare = [[BBServiceMessageShareViewController alloc] initWithModel:self.model];
    [self.navigationController pushViewController:messageShare animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
