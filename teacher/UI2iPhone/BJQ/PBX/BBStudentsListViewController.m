//
//  BBStudentsListViewController.m
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBStudentsListViewController.h"

@interface BBStudentsListViewController ()
{
    //searchBar
    UISearchBar *searchBar;
    //Tableview
    UITableView *tableview;
    //SelectedDisplay
    
}
@property (nonatomic, strong)NSArray *selectedStudentList;
@end

@implementation BBStudentsListViewController
@synthesize studentList = _studentList;
-(NSArray *)selectedStudentList
{
    if (!_selectedStudentList) {
        _selectedStudentList = [[NSArray alloc] init];
    }
    return _selectedStudentList;
}
-(NSArray *)studentList
{
    if(!_studentList)
    {
        _studentList = [[NSArray alloc] init];
    }
    return _studentList;
}
-(void)setStudentList:(NSArray *)studentList
{
    if (studentList.count == 0 || !studentList) {
        _studentList = [[NSArray alloc] initWithObjects:@"张三",@"张三",@"张三",@"张三", nil];
    }else
    {
        _studentList = studentList;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"学生列表";
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
        [back setBackgroundImage:[UIImage imageNamed:@"ZJZBack"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //searchBar
    
    //Tableview
    
    //SelectedStudentsDisplay
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ViewControllerMethod
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
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
