//
//  BBStudentsListViewController.m
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBStudentsListViewController.h"
#import "BBDisplaySelectedStudentsView.h"
#import "BBStudentListTableViewCell.h"
#import "BBStudentModel.h"
@interface BBStudentsListViewController ()<BBDisplaySelectedStudentsViewDelegate,BBStudentListTableViewCellDelegate>
{
    //searchBar
    UISearchBar *studentListSearchBar;
    //Tableview
    UITableView *studentListTableview;
    //SelectedDisplay
    BBDisplaySelectedStudentsView *selectedView;
}
@property (nonatomic, strong)NSMutableArray *selectedStudentList;
@property (nonatomic, strong)NSArray *searchResultList;
@end

@implementation BBStudentsListViewController
@synthesize studentList = _studentList;
@synthesize searchResultList = _searchResultList;
-(NSArray *)searchResultList
{
    if (!_searchResultList) {
        _searchResultList = [[NSArray alloc] init];
    }
    return _searchResultList;
}
-(void)setSearchResultList:(NSArray *)searchResultList
{
    _searchResultList = [[NSArray alloc] initWithArray:searchResultList];
    [studentListTableview  reloadData];
}
-(NSMutableArray *)selectedStudentList
{
    if (!_selectedStudentList) {
        _selectedStudentList = [[NSMutableArray alloc] init];
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

        _studentList = [[NSArray alloc] initWithObjects:[self getStudentModel],[self getStudentModel],[self getStudentModel],[self getStudentModel], nil];
    }else
    {
        _studentList = studentList;
    }
}
//************TestMethod*********************//
-(BBStudentModel *)getStudentModel
{
    BBStudentModel *model = [[BBStudentModel alloc] init];
    model.isSelected = NO;
    model.studentName = @"张三";
    return model;
}
//************TestMethod*********************//
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
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
    //searchBar
    studentListSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    studentListSearchBar.placeholder = @"搜索";
    studentListSearchBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:studentListSearchBar];
    studentListSearchBar.delegate = self;
    
    //Tableview
    studentListTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 40.f, 320.f, [UIScreen mainScreen].bounds.size.height-154.f ) style:UITableViewStylePlain];
    studentListTableview.delegate = self;
    studentListTableview.dataSource = self;
    studentListTableview.backgroundColor = [UIColor clearColor];
    studentListTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:studentListTableview];
    
    UIImageView *lineImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, studentListTableview.frame.origin.y+studentListTableview.frame.size.height, 320.f, 2.f)];
    lineImageview.backgroundColor = [UIColor colorWithRed:138/255.f green:136/255.f blue:135/255.f alpha:1.f];
    [self.view addSubview:lineImageview];
    
    //SelectedStudentsDisplay
    selectedView =  [[BBDisplaySelectedStudentsView alloc] initWithFrame:CGRectMake(0.f, studentListTableview.frame.origin.y+studentListTableview.frame.size.height+2, 320.f, 50.f)];
    selectedView.delegate = self;
    [self.view addSubview:selectedView];
    
    
    if (!IOS7) {
        for (UIView *subview in studentListSearchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                [subview removeFromSuperview];
                break;
            }
        }
        
        //[_messageListTableSearchBar setScopeBarBackgroundImage:[UIImage imageNamed:@"ZJZSearch"]];
    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [self addObserver:self forKeyPath:@"selectedStudentList" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObserver:self forKeyPath:@"selectedStudentList"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedStudentList"]) {
            //改变selectedView
    }
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
-(NSMutableArray *)searchResultListByKeyWord:(NSString *)keyword
{
    NSMutableArray *tempSearchResult = [[NSMutableArray alloc] init];
    for (NSString *studentName in self.studentList) {
        NSRange containStrRange = [studentName rangeOfString:keyword options:NSCaseInsensitiveSearch];
        if (containStrRange.length > 0) {
            //有当前关键字结果
            [tempSearchResult addObject:studentName];
        }else
        {
            //没有
        }
        
    }
    return tempSearchResult;
}

//add or remove in selectedItemArray
-(void)changeSelectedItemArray:(BBStudentModel *)model
{
    model.isSelected = !model.isSelected;
    
    
    if (model.isSelected) {
        [self.selectedStudentList addObject:model];
    }else
    {
        if ([self.selectedStudentList containsObject:model])
            [self.selectedStudentList removeObject:model];


    }

    [studentListTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:model.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //修改UI
    [selectedView setStudentNames:self.selectedStudentList];
}
#pragma mark BBDisplaySelectedStudentsDelegate
-(void)ConfirmBtnTapped:(NSArray *)selectedStudentInfos
{
    
}
#pragma mark UITableviewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([studentListSearchBar isFirstResponder]) {
        [studentListSearchBar resignFirstResponder];
    }
    
}

-(void)tableviewHadTapped
{
    if ([studentListSearchBar isFirstResponder]) {
        [studentListSearchBar resignFirstResponder];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BBStudentListTableViewCell *cell = (BBStudentListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self changeSelectedItemArray:cell.model];
    
}
-(void)itemIsSelected:(BBStudentModel *)studentModel
{
    
    [self changeSelectedItemArray:studentModel];
    
}
#pragma mark UItableviewDatasouce
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectZero];
    sectionView.backgroundColor = [UIColor blackColor];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, 200.f, 20.f)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:14.f];
    title.textColor = [UIColor whiteColor];
    title.text = @"a";
    [sectionView addSubview:title];
    return sectionView;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"手心网家长用户";
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.studentList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIden = @"studentListCell";
    BBStudentListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIden];
    if (!cell) {
        cell = [[BBStudentListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIden];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    BBStudentModel *studentModel = [self.studentList objectAtIndex:indexPath.row];
    studentModel.currentIndexPath = indexPath;
    [cell setModel:studentModel];

    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

#pragma mark SearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.searchResultList = [[NSMutableArray alloc] initWithArray:self.studentList];
    }else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *searchResult =  [self searchResultListByKeyWord:searchText];
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                [self setSearchResultList:searchResult];

            });
        });
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
}

@end
