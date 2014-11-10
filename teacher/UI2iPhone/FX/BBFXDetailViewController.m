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
}
@end

@implementation BBFXDetailViewController

-(id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    adWebview = [[UIWebView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.screenHeight)];
    adWebview.scalesPageToFit = YES;
    adWebview.delegate = (id<UIWebViewDelegate>)self;
    [adWebview.scrollView setMaximumZoomScale:4.f];
    NSURLRequest *request =[NSURLRequest requestWithURL:self.url];
    [adWebview loadRequest:request];
    [self.view addSubview:adWebview];
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
