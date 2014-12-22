//
//  BBFXDetailViewController.m
//  teacher
//
//  Created by mac on 14/11/10.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFXDetailViewController.h"

@interface BBFXDetailViewController ()
{
    UIWebView  *adWebview;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation BBFXDetailViewController

-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)loadView
{
    [super loadView];
    self.navigationItem.title = @"详情";
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    CGFloat fix = 0;
    if (IOS7) {
        fix = 20;
    }
    
    adWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.f, 0, self.view.frame.size.width, self.screenHeight-fix-44)];
    adWebview.scalesPageToFit = YES;
    adWebview.delegate = (id<UIWebViewDelegate>)self;
    [adWebview.scrollView setMaximumZoomScale:4.f];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url];
    [adWebview loadRequest:request];
    [self.view addSubview:adWebview];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.screenHeight-44-fix)];
    [view setTag:103];
    [view setBackgroundColor:[UIColor blackColor]];
    [view setAlpha:0.5f];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [activityIndicator setCenter:view.center];
    [activityIndicator startAnimating];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [view addSubview:activityIndicator];
    [self.view addSubview:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityIndicator stopAnimating];
    UIView *view = (UIView *)[self.view viewWithTag:103];
    [view removeFromSuperview];
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
        [self showProgressWithText:@"加载失败" withDelayTime:1.f];
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

-(void)dealloc
{
    [adWebview setDelegate:nil];
}

@end
