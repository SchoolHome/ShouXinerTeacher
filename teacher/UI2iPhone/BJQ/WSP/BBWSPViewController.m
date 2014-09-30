//
//  BBWSPViewController.m
//  teacher
//
//  Created by ZhangQing on 14-9-27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBWSPViewController.h"
#import "BBStudentsListViewController.h"
#import "BBRecommendedRangeViewController.h"

#import "EGOImageButton.h"

@interface BBWSPViewController ()<EGOImageButtonDelegate>
{
    UILabel *studentList;
    UILabel *reCommendedList;
    UITextView *videoDescribe;
    EGOImageButton *videoPreview;
    
    NSArray *selectedStuArray;
    NSArray *selectedRangeArray;
    
}
@property (nonatomic, strong)TouchScrollview *contentScrollview;
@end

@implementation BBWSPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"拍表现";
    
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 15.f, 40.f, 24.f)];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [backButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(8, 0, 0, 0)];
    [backButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0.f, 15.f, 40.f, 24.f)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [sendButton setTitleEdgeInsets:UIEdgeInsetsMake(8, 0, 0, 0)];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];

    _contentScrollview = [[TouchScrollview alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.view.bounds.size.height-40.f)];
    _contentScrollview.touchDelegate = self;
    _contentScrollview.delegate = self;
    _contentScrollview.showsVerticalScrollIndicator = NO;
    _contentScrollview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentScrollview];
    
    UIView *videoView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 30.f, 320-30.f, 140.f)];
    videoView.layer.masksToBounds = YES;
    videoView.layer.borderWidth = 1.f;
    videoView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [_contentScrollview addSubview:videoView];
    
    videoDescribe = [[UITextView alloc] initWithFrame:CGRectMake(20.f, 20.f, CGRectGetWidth(videoView.frame)-150.f, 100.f)];
    videoDescribe.backgroundColor = [UIColor clearColor];
    videoDescribe.text = @"描述下你的视频...";
    [videoView addSubview:videoDescribe];
    
    videoPreview = [[EGOImageButton alloc] initWithPlaceholderImage:[UIImage imageNamed:@""] delegate:self];
    [videoPreview setFrame:CGRectMake(CGRectGetWidth(videoDescribe.frame)+30.f, 20.f, 100.f, 100.f)];
    [videoPreview addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [videoView addSubview:videoPreview];
    
    //学生列表
    UIView *listBack = [[UIView alloc] initWithFrame:CGRectMake(15.f, 205.f, CGRectGetHeight(videoView.frame), 40.f)];
    listBack.tag = 1001;
    [_contentScrollview addSubview:listBack];
    
    CALayer *roundedLayerList = [listBack layer];
    [roundedLayerList setMasksToBounds:YES];
    roundedLayerList.cornerRadius = 8.0;
    roundedLayerList.borderWidth = 1;
    roundedLayerList.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UIButton *turnStudentList = [UIButton buttonWithType:UIButtonTypeCustom];
    [turnStudentList setFrame:CGRectMake(5, 5, 320-40, 30)];
    [turnStudentList addTarget:self action:@selector(turnStudentList) forControlEvents:UIControlEventTouchUpInside];
    turnStudentList.titleLabel.textAlignment = NSTextAlignmentLeft;
    [listBack addSubview:turnStudentList];
    
    studentList = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, 190, 20.f)];
    studentList.backgroundColor = [UIColor clearColor];
    studentList.text = @"@:点名表扬";
    studentList.numberOfLines = 50;
    studentList.font = [UIFont boldSystemFontOfSize:14.f];
    studentList.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [turnStudentList addSubview:studentList];
    
    UILabel *studentListTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(listBack.frame)-50.f, 5.f, 30, 20.f)];
    studentListTitle.backgroundColor = [UIColor clearColor];
    studentListTitle.text = @">";
    studentListTitle.textAlignment = NSTextAlignmentRight;
    studentListTitle.font = [UIFont boldSystemFontOfSize:14.f];
    studentListTitle.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [turnStudentList addSubview:studentListTitle];
    // Do any additional setup after loading the view.
    
    //推荐到
    UIView *reCommendedBack = [[UIView alloc] initWithFrame:CGRectMake(15,listBack.frame.origin.y+listBack.frame.size.height+30, 320-30, 40)];
    reCommendedBack.tag = 1003;
    [_contentScrollview addSubview:reCommendedBack];
    CALayer *roundedLayer3 = [reCommendedBack layer];
    [roundedLayer3 setMasksToBounds:YES];
    roundedLayer3.cornerRadius = 8.0;
    roundedLayer3.borderWidth = 1;
    roundedLayer3.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UIButton *turnReCommendedList = [UIButton buttonWithType:UIButtonTypeCustom];
    [turnReCommendedList setFrame:CGRectMake(5, 5, 320-40, 30)];
    [turnReCommendedList addTarget:self action:@selector(turnReCommendedList) forControlEvents:UIControlEventTouchUpInside];
    [reCommendedBack addSubview:turnReCommendedList];
    
    
    reCommendedList = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, 200, 20.f)];
    reCommendedList.backgroundColor = [UIColor clearColor];
    reCommendedList.text = @"推荐到:";
    reCommendedList.font = [UIFont boldSystemFontOfSize:14.f];
    reCommendedList.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [turnReCommendedList addSubview:reCommendedList];
    
    UILabel *reCommendedListTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(listBack.frame)-50.f, 5.f, 30, 20.f)];
    reCommendedListTitle.backgroundColor = [UIColor clearColor];
    reCommendedListTitle.text = @">";
    reCommendedListTitle.textAlignment = NSTextAlignmentRight;
    reCommendedListTitle.font = [UIFont boldSystemFontOfSize:14.f];
    reCommendedListTitle.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [reCommendedBack addSubview:reCommendedListTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedStudentList:) name:@"SelectedStudentList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedRangeList:) name:@"SeletedRangeList" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ViewControllerMethod
-(void)playVideo
{
    
}
-(void)receiveSeletedRangeList:(NSNotification *)noti
{
    NSArray *selectedRanges = (NSArray *)[noti object];
    selectedRangeArray = [[NSArray alloc] initWithArray:selectedRanges];
    
    if (selectedRanges.count == 0) {
        reCommendedList.text = @"推荐到:可不选...";
        return;
    }
    
    NSString *rangeNames = @"推荐到：";
    for (int i =0 ; i< selectedRanges.count ; i++) {
        NSString *tempRangeName = [selectedRanges objectAtIndex:i];
        if (i == 0) rangeNames = [rangeNames stringByAppendingString:tempRangeName];
        else rangeNames = [rangeNames stringByAppendingFormat:@"、%@",tempRangeName];
        
    }
    
    if (IOS6) {
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:rangeNames];
        
        [attributedStr addAttribute:NSForegroundColorAttributeName
                              value:[UIColor colorWithRed:59/255.f green:107/255.f blue:139/255.f alpha:1.f] range:NSMakeRange(4, attributedStr.length-4)];
        reCommendedList.attributedText = attributedStr;
    }else
    {
        reCommendedList.text = rangeNames;
    }
}
-(void)receiveSeletedStudentList:(NSNotification *)noti
{
    NSArray *selectedStudents = (NSArray *)[noti object];
    
    selectedStuArray = [[NSArray alloc] initWithArray:selectedStudents];
    
    NSMutableString *studentListText = [NSMutableString string];
    for ( int i = 0; i< selectedStudents.count; i++) {
        BBStudentModel *tempModel = [selectedStudents objectAtIndex:i];
        if (i == 0) {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"@:%@",tempModel.studentName]];
        }else
        {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"、%@",tempModel.studentName]];
        }
        
    }
    NSLog(@"%d",studentListText.length);
    //    for (int i = 18; i<studentListText.length; i++) {
    //        if (i % 20 == 0) {
    //            [studentListText insertString:@"\n" atIndex:i];
    //        }
    //
    //    }
    
    //CGSize strSize = [studentListText sizeWithFont:[UIFont boldSystemFontOfSize:14.f] forWidth:190.f lineBreakMode:UILineBreakModeWordWrap];
    CGSize strSize = [studentListText sizeWithFont:[UIFont boldSystemFontOfSize:14.f] constrainedToSize:CGSizeMake(220.f, 800.f)];
    if (strSize.height < 20) strSize.height = 20;
    
    
    CGRect tempStudentListFrame = studentList.frame;
    tempStudentListFrame.size.height = strSize.height;
    
    
    
    if (selectedStudents.count == 0) {
        studentList.text = @"@:点名表扬,可不选...";
        studentList.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
        tempStudentListFrame.size.width = 190.f;
    }else
    {
        if (IOS6) {
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:studentListText];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 2)];
            [attributedStr addAttribute:NSForegroundColorAttributeName
                                  value:[UIColor colorWithRed:59/255.f green:107/255.f blue:139/255.f alpha:1.f] range:NSMakeRange(2, attributedStr.length-2)];
            studentList.attributedText = attributedStr;
        }else
        {
            studentList.text = studentListText;
        }
        
        
        tempStudentListFrame.size.width = 240.f;
    }
    
    studentList.frame = tempStudentListFrame;
    
    
    
    NSInteger offsetY ;
    for (UIView *tempView in self.contentScrollview.subviews) {
        if (tempView.tag == 1001) {
            NSInteger tempViewHeight = tempView.frame.size.height;
            CGRect tempViewFrame = tempView.frame;
            tempViewFrame.size.height = strSize.height + 20;
            tempView.frame = tempViewFrame;
            offsetY = tempView.frame.size.height - tempViewHeight;
        }else
        {
            
            tempView.center = CGPointMake(tempView.center.x, tempView.center.y+offsetY);
            if (tempView.tag == 1003) {
                self.contentScrollview.contentSize = CGSizeMake(320.f, tempView.frame.origin.y+tempView.frame.size.height + 40);
            }
        }
    }
    
    
}
-(void)turnStudentList
{
    [[PalmUIManagement sharedInstance] getGroupStudents:[self.currentGroup.groupid stringValue]];
    [self showProgressWithText:@"正在获取..."];
    
    //    BBStudentsListViewController *studentListVC = [[BBStudentsListViewController alloc] initWithSelectedStudents:selectedStuArray];
    //    //[studentList setStudentList:nil];
    //    [self.navigationController pushViewController:studentListVC animated:YES];
}
-(void)turnReCommendedList
{
    BBRecommendedRangeViewController *recommendedRangeVC = [[BBRecommendedRangeViewController alloc] initWithRanges:selectedRangeArray];
    [self.navigationController pushViewController:recommendedRangeVC animated:YES];
}


#pragma mark NavAction
-(void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)send
{
 
}

-(NSString *)getAward
{

    NSMutableString *studentListText = [NSMutableString string];
    for ( int i = 0; i< selectedStuArray.count; i++) {
        BBStudentModel *tempModel = [selectedStuArray objectAtIndex:i];
        if (i == 0) {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"%d",tempModel.studentID]];
        }else
        {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@",%d",tempModel.studentID]];
        }
        
    }
    return [NSString stringWithFormat:@"%@",studentListText];
}

#pragma mark - ReachTouchScrolviewDelegate
-(void)scrollviewTouched
{

    
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


@implementation TouchScrollview

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if ([self.touchDelegate respondsToSelector:@selector(scrollviewTouched)]) {
        [self.touchDelegate scrollviewTouched];
    }
}

@end