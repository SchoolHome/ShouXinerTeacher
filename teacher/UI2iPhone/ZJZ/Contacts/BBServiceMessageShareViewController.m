//
//  BBServiceMessageShareViewController.m
//  teacher
//
//  Created by ZhangQing on 14/11/26.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define ThingsTextViewHeight 60.f
#define ThingsTextViewSpaceing 10.f



#import "BBServiceMessageShareViewController.h"
#import "ChooseClassViewController.h"

#import "EGOImageView.h"

#import "AppDelegate.h"
@interface BBServiceMessageShareViewController ()<UITableViewDataSource,UITableViewDelegate,ChooseClassDelegate>
{
    UIPlaceHolderTextView *thingsTextView;
    BBServiceMessageDetailModel *shareModel;
}
@property (nonatomic, strong) BBServiceMessageShareTableview *shareTableview;
@property (nonatomic, readwrite) BBGroupModel *currentGroup;
@property (nonatomic, strong) NSArray *classModels;
@end

@implementation BBServiceMessageShareViewController

- (id)initWithModel:(BBServiceMessageDetailModel *)model
{
    self = [super init];
    if (self) {
        shareModel = model;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([@"groupListResult" isEqualToString:keyPath])  // 班级列表
    {
        NSDictionary *result = [PalmUIManagement sharedInstance].groupListResult;
        
        if (![result[@"hasError"] boolValue]) { // 没错
            self.classModels = [NSArray arrayWithArray:result[@"data"]];
            /*
            if (self.classModels.count > 0) {
                self.currentGroup = self.classModels[0];
            }
            [self.shareTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             */
        }else{
           // [self showProgressWithText:@"班级列表加载失败" withDelayTime:0.1];
        }
    }else if ([@"publicMessageForwardResult" isEqualToString:keyPath])//转发
    {
        [self closeProgress];
        NSDictionary *result = [PalmUIManagement sharedInstance].publicMessageForwardResult;
         if (![result[@"hasError"] boolValue]) { 
             [self.navigationController popViewControllerAnimated:YES];
         }else{
             [self showProgressWithText:result[@"error"] withDelayTime:0.1];
         }
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupListResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"publicMessageForwardResult" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupListResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"publicMessageForwardResult"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"分享";
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0.f, 7.f, 60.f, 30.f)];
    [sendButton setTitle:@"确定" forState:UIControlStateNormal];
    //sendButton.backgroundColor = [UIColor blackColor];
    [sendButton setTitleColor:[UIColor colorWithRed:251/255.f green:76/255.f blue:7/255.f alpha:1.f] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    self.shareTableview = [[BBServiceMessageShareTableview alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight-44.f) style:UITableViewStyleGrouped];
    self.shareTableview.dataSource = self;
    self.shareTableview.delegate = self;
    self.shareTableview.touchDelegate = self;
    self.shareTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shareTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
    self.shareTableview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.shareTableview];
    
    
    [[PalmUIManagement sharedInstance] getGroupList];
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
#pragma mark - UITableview

- (void)tableviewTouched
{
    [thingsTextView resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [thingsTextView resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ? 140 : 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        case 1:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *classCellIden = @"CellIdentifierTitle";
    static NSString *textCellIden = @"CellIdentifierText";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indexPath.section == 1 ? classCellIden : textCellIden];
    if (!cell) {
        
        switch (indexPath.section) {
            case 0:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:classCellIden];
                cell.textLabel.text = @"当前班级";
                cell.textLabel.backgroundColor = [UIColor blackColor];
                cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 1:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIden];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                thingsTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(ThingsTextViewSpaceing, ThingsTextViewSpaceing,self.screenWidth-2*ThingsTextViewSpaceing-20.f, ThingsTextViewHeight)];
                thingsTextView.placeholder = @"想说的话...";
                thingsTextView.font = [UIFont systemFontOfSize:14.f];
                thingsTextView.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:thingsTextView];
                
                UIView *shareContentBG = [[UIView alloc] initWithFrame:CGRectMake(ThingsTextViewSpaceing, CGRectGetMaxY(thingsTextView.frame)+4.f, CGRectGetWidth(thingsTextView.frame), 50.f)];
                shareContentBG.backgroundColor = [UIColor colorWithRed:225/255.f green:225/255.f blue:225/255.f alpha:1.f];
                [cell.contentView addSubview:shareContentBG];
                
                EGOImageView *messageImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(ThingsTextViewSpaceing+5.f, CGRectGetMinY(shareContentBG.frame)+5.f, 40.f, 40.f)];
                [messageImageView setImageURL:[NSURL URLWithString:shareModel.avatar]];
                [cell.contentView addSubview:messageImageView];
                
                UILabel *messageTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(messageImageView.frame)+5.f,
                    CGRectGetMinY(shareContentBG.frame)+5.f,
                    CGRectGetWidth(shareContentBG.frame)-CGRectGetMaxX(messageImageView.frame)-5.f,
                    CGRectGetHeight(messageImageView.frame))];
                messageTitle.font = [UIFont systemFontOfSize:12.f];
                messageTitle.backgroundColor = [UIColor clearColor];
                messageTitle.text = shareModel.content;
                messageTitle.numberOfLines = 2;
                [cell.contentView addSubview:messageTitle];
                

            }
                break;
            default:
                
                break;
        }
    }
    
    if (indexPath.section == 0) {
        cell.detailTextLabel.text = self.currentGroup ? self.currentGroup.alias : [PalmUIManagement sharedInstance].currentGroupInfo.alias;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [thingsTextView resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 1) {
        return;
    }else
    {
        if (self.classModels.count > 0) {
            ChooseClassViewController *chooseClass = [[ChooseClassViewController alloc] initWithClasses:self.classModels];
            chooseClass.delegate = self;
            [self.navigationController pushViewController:chooseClass animated:YES];
        }else
        {
            [self showProgressWithText:@"没有可选择的班级" withDelayTime:2.f];
        }
        
    }
}

#pragma mark - ViewControllerMethod
- (void)closeThingsText
{
    [thingsTextView resignFirstResponder];
}

- (void)backButtonTaped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendButtonTaped
{
    if ([thingsTextView.text length]==0) {  // 没有输入文本
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
        
        return;
    }
    
    [self showProgressWithText:@"正在提交..."];
    [[PalmUIManagement sharedInstance] postPublicMessageForward:shareModel.mid  withGroupID:self.currentGroup ? self.currentGroup.groupid.integerValue :
     [PalmUIManagement sharedInstance].currentGroupInfo.groupid.integerValue withMessage:thingsTextView.text];
}
#pragma mark - ChooseClassViewControllerDelegate
- (void)classChoose:(NSInteger)index
{
    self.currentGroup = self.classModels[index];
    [self.shareTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end


@implementation BBServiceMessageShareTableview
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableview:)];
        tapGes.delegate = self;
        [self addGestureRecognizer:tapGes];
    }
    return self;
}



- (void)tapTableview:(UITapGestureRecognizer *)ges
{
    if ([self.touchDelegate respondsToSelector:@selector(tableviewTouched)]) {
        [self.touchDelegate tableviewTouched];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

@end