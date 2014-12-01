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
    UISearchDisplayController *studentListSearchDisplay;
    //Tableview
    UITableView *studentListTableview;
    //SelectedDisplay
    BBDisplaySelectedStudentsView *selectedView;
    
    NSMutableArray *searchResultList;
    //是否处于搜索状态
    BOOL searchStatusActive;
    
    NSArray *tempStudentList;
}

@property (nonatomic, strong)NSMutableArray *sectionArray;
@property (nonatomic, strong)NSMutableArray *selectedStudentList;
@end

@implementation BBStudentsListViewController
@synthesize selectedStudentList = _selectedStudentList;


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

}


-(NSMutableArray *)sectionArray
{
    if (!_sectionArray) {
        _sectionArray = [[NSMutableArray alloc] init];
    }
    return _sectionArray;
}
-(NSMutableArray *)selectedStudentList
{
    if (!_selectedStudentList) {
        _selectedStudentList = [[NSMutableArray alloc] init];
    }
    return _selectedStudentList;
}

/*
-(void)setStudentList:(NSArray *)studentList
{
    if (!studentList) {
        
        _studentList = [[NSArray alloc] initWithArray:[self getStudentModelArray]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            if (self.selectedStudentList.count > 0) {
                
                //设置选择状态
                for (BBStudentModel *studentModel in _studentList) {
                    for (BBStudentModel *selectedStudentModel in self.selectedStudentList) {
                        if (studentModel.studentID == selectedStudentModel.studentID) {
                            studentModel.isSelected = YES;
                        }
                    }
                }
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(),  ^{
                tempStudentList = _studentList;
                 [self.searchDisplayController.searchResultsTableView  reloadData];
            });
        });
    }else
    {
        _studentList = studentList;
         [self.searchDisplayController.searchResultsTableView  reloadData];
    }
   
}
 */
//************TestMethod*********************//
-(NSMutableArray *)getStudentModelArray
{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (int i =0 ; i<100; i++) {
        BBStudentModel *model = [[BBStudentModel alloc] init];
        model.studentID = i;
        model.studentName = [NSString stringWithFormat:@"张三%d",i];
        model.isSelected = NO;
        if (i%2 == 0) {
            model.indexStr = [NSString stringWithFormat:@"王"];
        }else{
            model.indexStr = [NSString stringWithFormat:@"李"];
        }
        
        [tempArr addObject:model];
    }
    return tempArr;
}
//************TestMethod*********************//
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"学生列表";
        
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        searchResultList = [[NSMutableArray alloc] init];
    }
    return self;
}
-(id)initWithSelectedStudents:(NSArray *)selectedStu withStudentModel:(NSDictionary  *)models
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        if (!models) {
            return self;
        }
        self.selectedStudentList = [[NSMutableArray alloc] initWithArray:selectedStu];
        NSMutableArray *tempStudentsArr = [[NSMutableArray alloc] init];
        for (NSString *studentID in models.allKeys) {
            NSDictionary *studentModel = [models objectForKey:studentID];
            BBStudentModel *model = [[BBStudentModel alloc] init];
            model.studentID = [studentID integerValue];
            model.studentName = [studentModel objectForKey:@"uname"];
            for (BBStudentModel *tempSelectedStu in self.selectedStudentList) {
                if (model.studentID == tempSelectedStu.studentID) {
                    model.isSelected = YES;
                }
            }
            [tempStudentsArr addObject:model];
        }
        [self sortDataByModels:tempStudentsArr];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
    
    //Tableview
    studentListTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 40.f, 320.f, [UIScreen mainScreen].bounds.size.height-154.f ) style:UITableViewStylePlain];
    studentListTableview.delegate = self;
    studentListTableview.dataSource = self;
    studentListTableview.backgroundColor = [UIColor clearColor];
    studentListTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:studentListTableview];
    
    //searchBar
    studentListSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    studentListSearchBar.placeholder = @"搜索";
    studentListSearchBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:studentListSearchBar];
    studentListSearchBar.delegate = self;
    
    studentListSearchDisplay = [[UISearchDisplayController alloc] initWithSearchBar:studentListSearchBar contentsController:self];
    studentListSearchDisplay.delegate = self;
    studentListSearchDisplay.searchResultsDelegate = self;
    studentListSearchDisplay.searchResultsDataSource = self;
    studentListSearchDisplay.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    

    
    UIImageView *lineImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, studentListTableview.frame.origin.y+studentListTableview.frame.size.height, 320.f, 2.f)];
    lineImageview.backgroundColor = [UIColor colorWithRed:138/255.f green:136/255.f blue:135/255.f alpha:1.f];
    [self.view addSubview:lineImageview];
    
    //SelectedStudentsDisplay
    selectedView =  [[BBDisplaySelectedStudentsView alloc] initWithFrame:CGRectMake(0.f, studentListTableview.frame.origin.y+studentListTableview.frame.size.height+2, 320.f, 50.f)];
    selectedView.delegate = self;
    if (self.selectedStudentList.count > 0) {
        [selectedView setStudentNames:self.selectedStudentList];
    }
    
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
    }else studentListTableview.sectionIndexBackgroundColor = [UIColor clearColor];
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{

}
-(void)viewDidDisappear:(BOOL)animated
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ViewControllerMethod
-(void)sortDataByModels:(NSArray *)studentModels
{
    
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    for (BBStudentModel *tempModel in studentModels) {
        NSInteger sect = [theCollation sectionForObject:tempModel
                                collationStringSelector:@selector(studentName)];
        NSLog(@"%d",sect);
        tempModel.sectionNumber = sect;
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
    for (BBStudentModel *tempModel in studentModels) {
        if (![tempModel.studentName isEqualToString:@""]) {
            [(NSMutableArray *)[sectionArrays objectAtIndex:tempModel.sectionNumber] addObject:tempModel];
        }

    }
    
    for (NSMutableArray *sectionArray in sectionArrays) {
        // if (sectionArray.count > 0) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(studentName)];
        [self.sectionArray addObject:sortedSection];
        //}
        
    }
    
    // [selectedView setStudentNames:selectedStu];
    
    
    
}
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

    
//    for (BBStudentModel *studentModel in tempStudentList) {
//        NSString *tempStudentName = studentModel.studentName;
//        NSRange containStrRange = [tempStudentName rangeOfString:keyword options:NSCaseInsensitiveSearch];
//        if (containStrRange.length > 0) {
//            //有当前关键字结果
//            [tempSearchResult addObject:studentModel];
//        }else
//        {
//            //没有
//            
//        }
//  }
    for (NSArray *section in self.sectionArray) {
        for (BBStudentModel  *studentModel in section){
            NSString *tempStudentName = studentModel.studentName;
            NSRange containStrRange = [tempStudentName rangeOfString:keyword options:NSCaseInsensitiveSearch];
            if (containStrRange.length > 0) {
                //有当前关键字结果
                [tempSearchResult addObject:studentModel];
            }else
            {
                //没有
                
            }
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
        for (int i =0; i<self.selectedStudentList.count; i++) {
            BBStudentModel *tempModel = [self.selectedStudentList objectAtIndex:i];
            if (model.studentID == tempModel.studentID) {
                [self.selectedStudentList removeObjectAtIndex:i];
                break;
            }
        }
    }
    
//    [studentListTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:model.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (searchStatusActive) [studentListSearchDisplay.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:model.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    else [studentListTableview reloadData];
        //[studentListTableview  reloadRowsAtIndexPaths:[NSArray arrayWithObject:model.currentIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    //修改UI
    [selectedView setStudentNames:self.selectedStudentList];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
	[searchResultList removeAllObjects];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *searchResult =  [self searchResultListByKeyWord:searchText];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            [searchResultList addObjectsFromArray:searchResult];
            [self.searchDisplayController.searchResultsTableView reloadData];
            //[self setStudentList:searchResult];
        });
    });
}
#pragma mark BBDisplaySelectedStudentsDelegate
-(void)confirmBtnTapped
{
    NSLog(@"%@",self.selectedStudentList);
//    for (NSArray *section in self.sectionArray) {
//        for (BBStudentModel  *studentModel in section){
//            [self.selectedStudentList addObject:studentModel];
//        }
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedStudentList" object:self.selectedStudentList];
    [self.navigationController popViewControllerAnimated:YES];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselected");
}
-(void)itemIsSelected:(BBStudentModel *)studentModel
{
    
    [self changeSelectedItemArray:studentModel];
    
}
#pragma mark UItableviewDatasouce
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
       return  [[self.sectionArray objectAtIndex:section] count] ? 30 : 0;
    }

}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    } else {
        
        
        UIView *sectionView = [[UIView alloc] initWithFrame:CGRectZero];
        sectionView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, 200.f, 20.f)];
        title.backgroundColor = [UIColor clearColor];
        title.font = [UIFont boldSystemFontOfSize:14.f];
        title.textColor = [UIColor lightGrayColor];
        title.text = [[self.sectionArray objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
        [sectionView addSubview:title];
        return sectionView;
    }

}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
	} else {
        return self.sectionArray.count;
    }
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"手心网家长用户";
//}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResultList.count;
	} else {
        return [[self.sectionArray objectAtIndex:section] count];
    }
   
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
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BBStudentModel *studentModel = [searchResultList objectAtIndex:indexPath.row];
        studentModel.currentIndexPath = indexPath;
        [cell setModel:studentModel];
	} else {
      BBStudentModel *studentModel =  [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        studentModel.currentIndexPath = indexPath;
        [cell setModel:studentModel];
    }


    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

#pragma mark SearchBarDelegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchDisplayController setActive:YES animated:YES];

    return YES;
}
/*
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        self.studentList = nil;
    }else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *searchResult =  [self searchResultListByKeyWord:searchText];
            
            dispatch_async(dispatch_get_main_queue(),  ^{

                [self setStudentList:searchResult];
            });
        });
    }
}
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[studentListTableview reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    if ([searchBar isFirstResponder]) {
//        [searchBar resignFirstResponder];
//    }
//    [self.searchDisplayController setActive:NO animated:YES];
//    [studentListTableview reloadData];
}
#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
//    scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
        [self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    searchStatusActive = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    searchStatusActive = NO;
}
@end
