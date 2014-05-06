//
//  SystemIMViewController.m
//  iCouple
//
//  Created by qing zhang on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SystemIMViewController.h"
#import "SystemProfileView.h"
@interface SystemIMViewController ()

@end

@implementation SystemIMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init : (CPUIModelMessageGroup *)messageGroup
{
    self = [super init:messageGroup];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //获取头像昵称
    [self.imageviewHeadImg setBackImage:[self returnCircleHeadImg]];
    
    
    
    SystemProfileView *systemProfile = [[SystemProfileView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 460+upHidedPartInStatusMid)];
    [self.mainBGView addSubview:systemProfile];
    
    [self.IMView setFrame:CGRectMake(CGRect_IMViewInStatusMid.origin.x, CGRect_IMViewInStatusMid.origin.y, 320, 460-CGRect_IMViewInStatusMid.origin.y)];
    
    //隐藏键盘   
    [self.keybordView dismiss];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[CPUIModelManagement sharedInstance] setCurrentMsgGroup:[[CPUIModelManagement sharedInstance] getMsgGroupWithUserName:@"system"]];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
// 移动tableView
-(void) movedMessageTableView : (UITableView *) tableView
{
    
}
// 点击tableView Cell
-(void) clickMessageTableView : (UITableView *) tableView
{
    
}
- (void)keyboardViewDidDisappear
{
    
}
@end
