//
//  BBMeWebViewController.m
//  teacher
//
//  Created by mac on 14/11/14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeWebViewController.h"
#import "BBBasePostViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface BBMeWebViewController ()
{
    UIWebView *setWebview;
    UIActivityIndicatorView *activityIndicator;
    BOOL isShowNavBar;//根据js判断是否隐藏nav
    CLLocationManager *locationManager;//给js提供定位数据
}
@end

@implementation BBMeWebViewController

-(id)init{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    // Do any additional setup after loading the view.
}

-(void)loadView
{
    [super loadView];
    CGFloat height = 0, fixHeight = 0;
    if (IOS7) {
        height = 20;
        fixHeight = 0;
    }
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    height = 0;
    fixHeight = IOS7?64:44;
    
    setWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.f, height, self.view.frame.size.width, self.view.frame.size.height-height-fixHeight)];
    setWebview.scalesPageToFit = YES;
    setWebview.delegate = (id<UIWebViewDelegate>)self;
    [setWebview.scrollView setMaximumZoomScale:4.f];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url];
    [setWebview loadRequest:request];
    [self.view addSubview:setWebview];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, setWebview.frame.size.width, setWebview.frame.size.height)];
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

-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [setWebview setFrame:CGRectMake(0.f, 0, self.view.frame.size.width, self.screenHeight-44)];
    }else{
        [setWebview setFrame:CGRectMake(0.f, 0, self.view.frame.size.width, self.screenHeight)];
    }
    [self.navigationController setNavigationBarHidden:(!isShowNavBar) animated:YES];
    [setWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onShouxinerSetTitleBarVisibleComplete(true)"]];
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
    [setWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onShouxinerLocaterComplete(true, %@, %@)", lon, lat]];
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
    [setWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"onShouxinerPublishTopicComplete(true, %@)", [notification object]]];
}

-(void) close:(NSArray *)args
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)dealloc
{
    [setWebview setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WebDetailNeedCallBack" object:nil];
}

@end
