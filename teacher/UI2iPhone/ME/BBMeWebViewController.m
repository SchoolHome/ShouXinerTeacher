//
//  BBMeWebViewController.m
//  teacher
//
//  Created by mac on 14/11/14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeWebViewController.h"

@interface BBMeWebViewController ()
{
    UIWebView *setWebview;
}
@end

@implementation BBMeWebViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isHiddenHeader) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isHiddenHeader) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

-(void)loadView
{
    [super loadView];
    CGFloat height = 0, fixHeight = 0;
    if (IOS7) {
        height = 20;
        fixHeight = 0;
    }
    if (!self.isHiddenHeader) {
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
        [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
        height = 0;
        fixHeight = IOS7?64:44;
    }
    
    setWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.f, height, self.view.frame.size.width, self.view.frame.size.height-height-fixHeight)];
    setWebview.scalesPageToFit = YES;
    setWebview.delegate = (id<UIWebViewDelegate>)self;
    [setWebview.scrollView setMaximumZoomScale:4.f];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url];
    [setWebview loadRequest:request];
    [self.view addSubview:setWebview];
}

-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) {
        NSURL *url = [request URL];
        NSString *backUrl= [url absoluteString];
        if ([backUrl rangeOfString:@"nativeMethod=goBack"].location != NSNotFound) {
            [self.navigationController popViewControllerAnimated:YES];
            return NO;
        }
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code < 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
