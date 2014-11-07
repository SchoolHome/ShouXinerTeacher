//
//  BBFXViewController.m
//  teacher
//
//  Created by mac on 14/11/7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFXViewController.h"

@interface BBFXViewController ()
@property (nonatomic, strong) NSMutableArray *fxArray;
@end

@implementation BBFXViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([@"discoverResult" isEqualToString:keyPath]){
        
    }
}

-(id)init{
    self = [super init];
    if (self) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"discoverResult" options:0 context:nil];
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.navigationItem.title = @"发现";
    CGFloat heightFix = 20.f;
    if (IOS7) {
        heightFix = 20.f;
    }else{
        heightFix = 0;
    }
    fxTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, heightFix, self.view.frame.size.width, self.screenHeight-44-49) style:UITableViewStylePlain];
    [fxTableView setDelegate:(id<UITableViewDelegate>)self];
    [fxTableView setDataSource:(id<UITableViewDataSource>)self];
    [self.view addSubview:fxTableView];
    
    [[PalmUIManagement sharedInstance] getDiscoverData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fxArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FXCellIdentifier = @"FXCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FXCellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FXCellIdentifier];
    }
    
    return cell;
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
