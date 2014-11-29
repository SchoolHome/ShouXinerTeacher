//
//  BBRecommendedRangeViewController.m
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBRecommendedRangeViewController.h"

@interface BBRecommendedRangeViewController ()
{
    UITableView *rangeTableview;
    
    BBdisplaySelectedRangeView *selectedView;
    
    
}
@property (nonatomic, strong)NSMutableArray *selectedRanges;
@end

@implementation BBRecommendedRangeViewController

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}

-(NSMutableArray *)selectedRanges
{
    if (!_selectedRanges) {
        _selectedRanges = [[NSMutableArray alloc] init];
    }
    return _selectedRanges;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithRanges:(NSArray *)ranges
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"推荐范围";
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        self.selectedRanges = [[NSMutableArray alloc] initWithArray:ranges];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
    
    //Tableview
    rangeTableview = [[UITableView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, [UIScreen mainScreen].bounds.size.height-114.f ) style:UITableViewStylePlain];
    rangeTableview.delegate = self;
    rangeTableview.dataSource = self;
    rangeTableview.backgroundColor = [UIColor clearColor];
    rangeTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:rangeTableview];
    
    
    UIImageView *lineImageview = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, rangeTableview.frame.origin.y+rangeTableview.frame.size.height, 320.f, 2.f)];
    lineImageview.backgroundColor = [UIColor colorWithRed:138/255.f green:136/255.f blue:135/255.f alpha:1.f];
    [self.view addSubview:lineImageview];
    
    //SelectedStudentsDisplay
    selectedView =  [[BBdisplaySelectedRangeView alloc] initWithFrame:CGRectMake(0.f, rangeTableview.frame.origin.y+rangeTableview.frame.size.height+2, 320.f, 50.f)];
    selectedView.delegate = self;
    if (self.selectedRanges.count > 0) {
        [selectedView setRanges:self.selectedRanges];
    }
    
    [self.view addSubview:selectedView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)changeSelectedItemArray:(NSIndexPath *)indexpath
{
    BBRecommendedRangeTableViewCell *cell = (BBRecommendedRangeTableViewCell *)[rangeTableview cellForRowAtIndexPath:indexpath];
    
    cell.selectedBtn.selected = !cell.selectedBtn.selected;
    
    
    if (cell.selectedBtn.selected) {
        [self.selectedRanges addObject:cell.rangeLabel.text];
    }else
    {
        for (int i =0; i<self.selectedRanges.count; i++) {
            NSString *tempRangeStr = [self.selectedRanges objectAtIndex:i];
            if ([tempRangeStr isEqualToString:cell.rangeLabel.text] ) {
                [self.selectedRanges removeObjectAtIndex:i];
                break;
            }
        }
    }

    [rangeTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexpath] withRowAnimation:UITableViewRowAnimationNone];
    
    //修改UI
    [selectedView setRanges:self.selectedRanges];
}
#pragma mark - ViewControllerMethod
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - SelectedViewDelegate
-(void)confirmBtnTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SeletedRangeList" object:self.selectedRanges];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - CellDelegate
-(void)selectedRange:(NSIndexPath *)indexPath
{
    [self changeSelectedItemArray:indexPath];
}
#pragma mark - UITableviewDelegate && Datasouce
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self changeSelectedItemArray:indexPath];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectZero];
    sectionView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 6.f, 200.f, 20.f)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont boldSystemFontOfSize:14.f];
    title.textColor = [UIColor lightGrayColor];
    title.text = @"可单选、多选";
    [sectionView addSubview:title];
    return sectionView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *rangeTableviewCellIden = @"rangeTableviewCellIden";
    BBRecommendedRangeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rangeTableviewCellIden];
    if (!cell) {
        cell = [[BBRecommendedRangeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:rangeTableviewCellIden];
        cell.delegate = self;
    }
    
    
    cell.selectedBtn.selected = NO;
    for (int i = 0 ; i< self.selectedRanges.count ; i++) {
        NSString *tempRangeStr = [self.selectedRanges objectAtIndex:i];
        if ([tempRangeStr isEqualToString:@"校园圈"] && indexPath.row == 0) {
            cell.selectedBtn.selected = YES;
        }else if ([tempRangeStr isEqualToString:@"手心网"] && indexPath.row == 1)
            cell.selectedBtn.selected = YES;
    }
    
    
    [cell setContent:indexPath];
  
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
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

@implementation BBRecommendedRangeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //self.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        //selectedBtn
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setFrame:CGRectMake(5.f, 19.f, 22.f, 22.f)];
        [_selectedBtn addTarget:self action:@selector(selectRange:) forControlEvents:UIControlEventTouchUpInside];
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"ZJZUnCheck"] forState:UIControlStateNormal];
        [_selectedBtn setBackgroundImage:[UIImage imageNamed:@"ZJZChecked"] forState:UIControlStateSelected];
        [self.contentView addSubview:_selectedBtn];
        //姓名
        _rangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 21.f, 120.f, 18.f)];
        _rangeLabel.backgroundColor = [UIColor clearColor];
        _rangeLabel.textColor = [UIColor colorWithRed:59/255.f green:107/255.f blue:139/255.f alpha:1.f];
        _rangeLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_rangeLabel];
    }
    return self;
}
-(void)selectRange:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(selectedRange:)]) {
        [self.delegate selectedRange:self.indexPath];
    }
}
-(void)setContent:(NSIndexPath *)indexpath
{
    self.indexPath = indexpath;
    switch (indexpath.row) {
        case 0:
            self.rangeLabel.text = @"校园圈";
            break;
        case 1:
            self.rangeLabel.text = @"手心网";
            break;
        default:
            break;
    }
}
@end

@implementation BBdisplaySelectedRangeView

-(void)setRanges:(NSArray *)ranges
{
    if (ranges.count == 0) {
        studentNamesLabel.text = @"";
        
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        //confirmBtn.enabled = NO;
        return;
    }
    
    NSString *rangeNames = @"推荐到：";
    for (int i =0 ; i< ranges.count ; i++) {
        NSString *tempRangeName = [ranges objectAtIndex:i];
        if (i == 0) rangeNames = [rangeNames stringByAppendingString:tempRangeName];
        else rangeNames = [rangeNames stringByAppendingFormat:@"、%@",tempRangeName];
        
    }
    
    [studentNamesLabel setFrame:CGRectMake(2.f, 0.f, 200.f, selectedStudentsScrollview.frame.size.height)];
    studentNamesLabel.text = rangeNames;
    
    
    [confirmBtn setTitle:[NSString stringWithFormat:@"确定(%d)",ranges.count] forState:UIControlStateNormal];
    confirmBtn.enabled = YES;
    
}


@end


