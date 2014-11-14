//
//  BBMeSettingViewController.m
//  teacher
//
//  Created by mac on 14/11/11.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeSettingViewController.h"

@interface BBMeSettingViewController ()
{
    NSArray *settingList;
    UITableView *tbvSetting;
}
@end

@implementation BBMeSettingViewController

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"设置";
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    settingList = [[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"响铃提示", @"title", @"ring.png", @"icon", nil],
                                                    [NSDictionary dictionaryWithObjectsAndKeys:@"震动提示", @"title", @"activity-stream.png", @"icon", nil], nil],
                   [NSArray arrayWithObjects: [NSDictionary dictionaryWithObjectsAndKeys:@"软件更新", @"title", @"", @"url", @"checkversion.png", @"icon", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"帮助中心", @"title", @"http://www.shouxiner.com/res/mobilemall/helpl.html", @"url", @"help.png", @"icon", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"反馈建议", @"title", @"http://www.shouxiner.com/advicebox/mobile_web_advice", @"url", @"file.png", @"icon", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"关于手心", @"title", @"", @"ulr", @"about.png", @"icon",nil] ,nil],
                   nil];
    
    tbvSetting = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.screenHeight-44) style:UITableViewStyleGrouped];
    [tbvSetting setRowHeight:44];
    [tbvSetting setScrollEnabled:NO];
    [tbvSetting setDelegate:(id<UITableViewDelegate>)self];
    [tbvSetting setDataSource:(id<UITableViewDataSource>)self];
    [self.view addSubview:tbvSetting];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [settingList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[settingList objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *SettingCell = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCell];
    if (nil ==cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingCell];
    }
    NSDictionary *infoDic = [[settingList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell.textLabel setText:[infoDic objectForKey:@"title"]];
    [cell.imageView setImage:[UIImage imageNamed:[infoDic objectForKey:@"icon"]]];
    if (indexPath.section == 0) {
        CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *setDic = (NSMutableDictionary *)[userDefault objectForKey:account.loginName];
        if (indexPath.row == 0) {
            UISwitch *vibSwith = [[UISwitch alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width-100, 10, 80, 40)];
            [vibSwith addTarget:self action:@selector(vibrationSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:vibSwith];
            if ([[setDic objectForKey:@"Vibration"] boolValue] || [[setDic objectForKey:@"Vibration"] isKindOfClass:[NSNull class]]) {
                [vibSwith setOn:YES];
            }else{
                [vibSwith setOn:NO];
            }
        }else{
            UISwitch *vibSwith = [[UISwitch alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width-100, 10, 80, 40)];
            [vibSwith addTarget:self action:@selector(alertSwitch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:vibSwith];
            if ([[setDic objectForKey:@"Alert"] boolValue] || [[setDic objectForKey:@"Alert"] isKindOfClass:[NSNull class]]) {
                [vibSwith setOn:YES];
            }else{
                [vibSwith setOn:NO];
            }
        }
    }
    return cell;
}

-(void)vibrationSwitch:(UISwitch *)_switch
{
    BOOL isOn = YES;
    if (_switch.on) {
        isOn = YES;
    }else{
        isOn = NO;
    }
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *setDic = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:account.loginName]];
    if (!setDic) {
        setDic = [NSMutableDictionary dictionary];
    }
    [setDic setValue:[NSNumber numberWithBool:isOn] forKey:@"Vibration"];
    [userDefault setObject:setDic forKey:account.loginName];
    [userDefault synchronize];
}

-(void)alertSwitch:(UISwitch *)_switch
{
    BOOL isOn = YES;
    if (_switch.on) {
        isOn = YES;
    }else{
        isOn = NO;
    }
    
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *setDic = [NSMutableDictionary dictionaryWithDictionary:[userDefault objectForKey:account.loginName]];
    if (!setDic) {
        setDic = [NSMutableDictionary dictionary];
    }
    [setDic setValue:[NSNumber numberWithBool:isOn] forKey:@"Alert"];
    [userDefault setObject:setDic forKey:account.loginName];
    [userDefault synchronize];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
