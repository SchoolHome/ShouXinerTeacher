//
//  ADDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14-8-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ADDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BBBasePostViewController.h"

@interface ADDetailViewController ()
{
    UIWebView  *adWebview;
    UIActivityIndicatorView *activityIndicator;
    BOOL isShowNavBar;//根据js判断是否隐藏nav
    CLLocationManager *locationManager;//给js提供定位数据
}
@end

@implementation ADDetailViewController

-(id)init
{
    self = [super init];
    if (self) {
        isShowNavBar = YES;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:(!isShowNavBar)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(id)initWithUrl:(NSURL *)url andADType:(AD_TYPE)type
{
    self = [super init];
    if (self) {
        adType = type;
        CGFloat navigationBarHeight = 0;
        CGFloat webviewOriginY = 0;
        if (type == AD_TYPE_SCREEN) {
            UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
            [back setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
            [back setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
            [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
            
            navigationBarHeight += 64.f;
        }else if (type == AD_TYPE_BANNER)
        {
            UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, -24.0, 320, 44)];
            [self.view addSubview:navigationBar];
            
            webviewOriginY = IOS7?20:0;
        }
        
        adWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.f,webviewOriginY, 320.f, self.screenHeight-navigationBarHeight-webviewOriginY)];
        adWebview.scalesPageToFit = YES;
        adWebview.delegate = self;
        [adWebview.scrollView setMaximumZoomScale:4.f];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        adWebview.delegate = self;
        [adWebview loadRequest:request];

        [self.view addSubview:adWebview];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adWebview.frame.size.width, adWebview.frame.size.height)];
        [view setTag:103];
        [view setBackgroundColor:[UIColor blackColor]];
        [view setAlpha:0.5f];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [activityIndicator setCenter:view.center];
        [activityIndicator startAnimating];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [view addSubview:activityIndicator];
        [self.view addSubview:view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successCallBack:) name:@"WebDetailNeedCallBack" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)backAction
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

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code < 0) {
        [self showProgressWithText:@"加载失败" withDelayTime:1.f];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther || navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = [request URL];
        NSString *funcUrl= [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([funcUrl rangeOfString:@"nativeMethod=goBack"].location != NSNotFound) {
            [self.navigationController popViewControllerAnimated:YES];
            return NO;
        }
        if ([funcUrl rangeOfString:@"shouxiner://function:"].location != NSNotFound) {
            NSRange range = [funcUrl rangeOfString:@"shouxiner://function:"];
            NSString *subUrl = [funcUrl substringFromIndex:range.length];
            NSData* data = [subUrl dataUsingEncoding:NSUTF8StringEncoding];
            NSError* error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSDictionary *objDic = result;
            NSString *funcName = [NSString stringWithFormat:@"%@:", objDic[@"function"]];
            NSArray *args = objDic[@"args"];
            SEL selector = NSSelectorFromString(funcName);
            [self performSelector:selector withObject:args];
            return NO;
        }
    }
    return YES;
}

//隐藏nav
-(void)setTitleBarVisible:(NSArray *)args
{
    isShowNavBar = [args[0] boolValue];
    if (isShowNavBar) {
        [adWebview setFrame:CGRectMake(0.f, 0, self.view.frame.size.width, self.screenHeight-44)];
    }else{
        [adWebview setFrame:CGRectMake(0.f, 0, self.view.frame.size.width, self.screenHeight)];
    }
    [self.navigationController setNavigationBarHidden:(!isShowNavBar) animated:YES];
}
//定位
-(void)getLocate:(NSArray *)args
{
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc]init];
    }
    [locationManager setDelegate:(id<CLLocationManagerDelegate>)self];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
//发表话题
-(void)publishTopic:(NSArray *)args
{
    BBBasePostViewController *shareVC = [[BBBasePostViewController alloc] initWithPostType:POST_TYPE_HDFX];
    shareVC.activeTitle = args[0];
    shareVC.activeID = args[2];
    shareVC.activeContent = args[1];
    [self.navigationController pushViewController:shareVC animated:YES];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //经度
    NSString *lon = [[NSString alloc]initWithFormat:@"%g",newLocation.coordinate.longitude];
    //纬度
    NSString *lat = [[NSString alloc]initWithFormat:@"%g",newLocation.coordinate.latitude];
    [adWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onShouxinerLocaterComplete(true, %@, %@)", lon, lat]];
    [locationManager stopUpdatingLocation];
    locationManager = nil;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorType = (error.code == kCLErrorDenied)?@"Access Denied":@"Unkown Error";
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"定位失败" message:errorType delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)successCallBack:(NSNotification *)notification
{
    [adWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onShouxinerPublishTopicComplete(true, %@)", [notification object]]];
}

-(void)dealloc
{
    [adWebview setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WebDetailNeedCallBack" object:nil];
}
@end
