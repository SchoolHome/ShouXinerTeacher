//
//  ADDetailViewController.m
//  teacher
//
//  Created by ZhangQing on 14-8-13.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ADDetailViewController.h"

@interface ADDetailViewController ()

@end

@implementation ADDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
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
            [back setBackgroundImage:[UIImage imageNamed:@"ZJZBack"] forState:UIControlStateNormal];
            [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
            
            navigationBarHeight += 64.f;
        }else if (type == AD_TYPE_BANNER)
        {
            UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, -24.0, 320, 44)];
            [self.view addSubview:navigationBar];
            
            webviewOriginY = IOS7?20:0;
        }

        
        
        UIWebView  *adWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.f,webviewOriginY, 320.f, self.screenHeight-navigationBarHeight-webviewOriginY)];
        adWebview.scalesPageToFit = YES;
        adWebview.delegate = self;
        [adWebview.scrollView setMaximumZoomScale:4.f];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        adWebview.delegate = self;
        [adWebview loadRequest:request];

        [self.view addSubview:adWebview];
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
-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
