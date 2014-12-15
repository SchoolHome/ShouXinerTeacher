
#import "BBBJQViewController.h"
#import "BBXXXViewController.h"
#import "BBJFViewController.h"
#import "BBRecommendedRangeViewController.h"

#import "BBCellHeight.h"
#import "BBBJQManager.h"
#import "CoreUtils.h"

#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"
#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "BBPBXViewController.h"
#import "BBPBXTableViewCell.h"
#import "ADImageview.h"
#import "ADDetailViewController.h"
#import "ColorUtil.h"
#import "BBVideoTableViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BBShareWebViewController.h"

@class BBWSPViewController;
@interface BBBJQViewController ()<ADImageviewDelegate,OHAttributedLabelDelegate>
{
}
@property (nonatomic,strong) BBTopicModel *tempTopModel;
@property (nonatomic,strong) BBTopicModel *tempTopModelInput;
@property (nonatomic,copy) NSString *inputText;

@property (nonatomic,strong) MessagePictrueViewController *messagePictrueController;
@property (nonatomic,strong) BBCommentModel *model;
@property (nonatomic,strong) BBBaseTableViewCell *tempCell;
@property (nonatomic,strong) UIImageView *tempMoreImage;
@property (nonatomic,strong) NSString *contentText;
@property (nonatomic,strong) BBTopicModel *recommendUsed;
@property (nonatomic,strong) UIButton *notifyButton;
//如果为2则获取作业类型，否则取全部类型数据
@property (nonatomic) int type;

@property(nonatomic,strong) BBBaseTableViewCell *deleteCell;

@property (nonatomic,strong) NSString *videoFilePath;
-(void) playVideo : (NSString *) videoPath withCell : (BBVideoTableViewCell *) cell;
-(void) needRefresh;
-(void) needRefreshBJQData;
@end

@implementation BBBJQViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([@"groupListResult" isEqualToString:keyPath])  // 班级列表
    {
        self.isLoading = NO;
        NSDictionary *result = [PalmUIManagement sharedInstance].groupListResult;
        
        if (![result[@"hasError"] boolValue]) { // 没错
            bjDropdownView.listData = [NSArray arrayWithArray:result[@"data"]];
            if ([bjDropdownView.listData count]>0) {
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                int index = [def integerForKey:@"saved_topic_group_index"];  // 上次选中的班级
                
                if ([bjDropdownView.listData count]>index) {
                    _currentGroup = bjDropdownView.listData[index];
                    [titleButton setTitle:_currentGroup.alias forState:UIControlStateNormal];
                }else{
                    _currentGroup = bjDropdownView.listData[0];
                    [titleButton setTitle:_currentGroup.alias forState:UIControlStateNormal];
                }
                [PalmUIManagement sharedInstance].currentGroupInfo = _currentGroup;
                [bjqTableView triggerPullToRefresh];
            }
        }else{
            [self showProgressWithText:@"班级列表加载失败" withDelayTime:0.1];
        }
    }
    if ([@"groupTopicListResult" isEqualToString:keyPath])  // 圈信息列表
    {
        self.isLoading = NO;
        NSDictionary *result = [PalmUIManagement sharedInstance].groupTopicListResult;
        switch (self.loadStatus) {
            case TopicLoadStatusRefresh:
                //
            {
                if ([result[@"hasError"] boolValue]) { // 有错
                    [bjqTableView.pullToRefreshView stopAnimating];
                }else{
                
                    NSArray *arr = [NSArray arrayWithArray:result[@"data"]];
                    [self.allTopicList removeAllObjects];
                    [self.allTopicList addObjectsFromArray:arr];
                    
                    [bjqTableView.pullToRefreshView stopAnimating];
                    NSLog(@"123456789");
                    NSDate *now = [CoreUtils convertDateToLocalTime:[NSDate date]];
                    NSString *date = [NSString stringWithFormat:@"最近更新: %@",[[now description] substringToIndex:16]];
                    [bjqTableView.pullToRefreshView setSubtitle:date forState:SVPullToRefreshStateAll];
                }
            }
                break;
            case TopicLoadStatusAppend:
                //
            {
                if ([result[@"hasError"] boolValue]) { // 有错
                    [bjqTableView.infiniteScrollingView stopAnimating];
                }else{
                    NSArray *arr = [NSArray arrayWithArray:result[@"data"]];
                    [self.allTopicList addObjectsFromArray:arr];
                    
                    [bjqTableView.infiniteScrollingView stopAnimating];
                }
                
            }
                break;
            default:
                break;
        }
        if ([self.allTopicList count] >= 30) {
            bjqTableView.showsInfiniteScrolling = YES;
        }else{
            bjqTableView.showsInfiniteScrolling = NO;
        }
        [bjqTableView reloadData];
        [bjqTableView bringSubviewToFront:avatar];
    }
    
    if ([@"notifyCount" isEqualToString:keyPath])  // 新消息
    {
        NSDictionary *dict = [PalmUIManagement sharedInstance].notifyCount;
        int count = [dict[@"data"][@"count"] intValue];
        notifyCount = count;
        if (count > 0) {
            if (self.notifyButton != nil) {
                self.notifyButton.titleLabel.text = [NSString stringWithFormat:@"您有%d条新消息",notifyCount];
                [bjqTableView reloadData];
            }else{
                self.notifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
                self.notifyButton.frame = CGRectMake((320.0f - 128.0f)/2.0f, 156, 128, 31);
                [self.notifyButton setBackgroundImage:[UIImage imageNamed:@"BBNewMessage"] forState:UIControlStateNormal];
                self.notifyButton.backgroundColor = [UIColor clearColor];
                self.notifyButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
                self.notifyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                [self.notifyButton setTitle:[NSString stringWithFormat:@"您有%d条新消息",notifyCount] forState:UIControlStateNormal];
                [self.notifyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                bjqTableView.tableHeaderView.frame = CGRectMake(0, 0, 320, 188);
                [bjqTableView.tableHeaderView addSubview:self.notifyButton];
                [self.notifyButton addTarget:self action:@selector(newNotifyTaped:) forControlEvents:UIControlEventTouchUpInside];
                [bjqTableView reloadData];
            }
        }else{
            if (self.notifyButton != nil) {
                [self.notifyButton removeTarget:self action:@selector(newNotifyTaped:) forControlEvents:UIControlEventTouchUpInside];
                [self.notifyButton removeFromSuperview];
                self.notifyButton = nil;
                bjqTableView.tableHeaderView.frame = CGRectMake(0, 0, 320, 147);
                [bjqTableView reloadData];
            }
        }
    }
    
    if ([@"userCredits" isEqualToString:keyPath])  // 刷新积分
    {
        NSDictionary *dict = [PalmUIManagement sharedInstance].userCredits;
        NSNumber *credits = dict[@"data"][@"credits"];
        NSString *txt = [NSString stringWithFormat:@"您有 %d 手心币",[credits intValue]];
        NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
        [attrStr setTextColor:[UIColor grayColor]];
        [attrStr setTextColor:[UIColor orangeColor] range:[txt rangeOfString:[NSString stringWithFormat:@"%d",[credits intValue]]]];
        [attrStr setTextAlignment:kCTTextAlignmentCenter lineBreakMode:kCTLineBreakByWordWrapping range:NSMakeRange(0, txt.length)];
        point.attributedText = attrStr;
    }
    
    if ([@"praiseResult" isEqualToString:keyPath])  // 赞
    {
        if ([[[PalmUIManagement sharedInstance].praiseResult objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
            return;
        }
        NSDictionary *result = [[PalmUIManagement sharedInstance].praiseResult objectForKey:ASI_REQUEST_DATA];
        if ([result[@"errno"] intValue] == 0) {
            BBPraiseModel *praise = [[BBPraiseModel alloc] init];
            CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
            praise.uid = [NSNumber numberWithInteger:[account.uid integerValue]];;
            praise.username = [CPUIModelManagement sharedInstance].uiPersonalInfo.nickName;
            
            self.tempTopModel.am_i_like = [NSNumber numberWithBool:1];
            NSMutableArray *p = [[NSMutableArray alloc] initWithArray:self.tempTopModel.praises];
            [p addObject:praise];
            self.tempTopModel.praises = [NSArray arrayWithArray:p];
            if ([self.tempTopModel.praisesStr length]>0) {
                self.tempTopModel.praisesStr = [NSString stringWithFormat:@"%@,%@",self.tempTopModel.praisesStr,praise.username];
            }else{
            
                self.tempTopModel.praisesStr = [NSString stringWithFormat:@"%@",praise.username];
            }
            
            [bjqTableView reloadData];
            [bjqTableView bringSubviewToFront:avatar];
        }
    }
    
    if ([@"commentResult" isEqualToString:keyPath])  // 评论
    {
        /*
         @property(nonatomic,strong) NSString *comment;
         @property(nonatomic,strong) NSNumber *id;
         @property(nonatomic,strong) NSNumber *replyto;
         @property(nonatomic,strong) NSString *replyto_username;
         @property(nonatomic,strong) NSNumber *timestamp;
         @property(nonatomic,strong) NSNumber *uid;
         @property(nonatomic,strong) NSString *username;
         */
        if ([[[PalmUIManagement sharedInstance].commentResult objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
            return;
        }
        NSDictionary *result = [[PalmUIManagement sharedInstance].commentResult objectForKey:ASI_REQUEST_DATA];
        if ([result[@"errno"] intValue] == 0) {
            BBCommentModel *comment = [[BBCommentModel alloc] init];
            CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
            comment.comment = self.inputText;
            comment.replyto = self.tempTopModelInput.author_uid;
            comment.replyto_username = self.model.username;
            comment.uid = [NSNumber numberWithInteger:[account.uid integerValue]];;
            comment.username = [CPUIModelManagement sharedInstance].uiPersonalInfo.nickName;
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:self.tempTopModelInput.comments];
            [arr addObject:comment];
            self.tempTopModelInput.comments = arr;
            
            NSUInteger len = [comment.username length]+1;
            NSMutableAttributedString *attributedText;
            if ([comment.username isEqualToString:comment.replyto_username] || comment.replyto_username == nil) {
                NSString *text = [NSString stringWithFormat:@"%@: %@",comment.username,comment.comment];
                attributedText = [[NSMutableAttributedString alloc] initWithString:text];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6) {
                    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(0,len)];
                }
                [self.tempTopModelInput.commentText appendString:text];
                [self.tempTopModelInput.commentTextArray addObject:text];
            }else{
                NSString *text = [NSString stringWithFormat:@"%@ 回复 %@: %@",comment.username,comment.replyto_username,comment.comment];
                attributedText = [[NSMutableAttributedString alloc] initWithString:text];
                NSUInteger len1 = [comment.replyto_username length];
                NSUInteger temp = [[NSString stringWithFormat:@"%@ 回复 ",comment.username] length];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6) {
                    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(0,len)];
                    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(temp,len1)];
                }
                [self.tempTopModelInput.commentText appendString:text];
                [self.tempTopModelInput.commentTextArray addObject:text];
            }
            [self.tempTopModelInput.commentStr addObject:attributedText];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:self.tempTopModelInput.commentsStr];
            [str appendAttributedString:attributedText];
            self.tempTopModelInput.commentsStr = str;
            [bjqTableView reloadData];
            [bjqTableView bringSubviewToFront:avatar];
        }
    }
    
    if ([@"uiPersonalInfoTag" isEqualToString:keyPath]) {
        NSLog(@"%@",[CPUIModelManagement sharedInstance].uiPersonalInfo);
        NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
        if (path) {
            avatar.image = [UIImage imageWithContentsOfFile:path];
        }

    }
    
    if ([@"advWithGroupResult" isEqualToString:keyPath]) {
        if (![[[PalmUIManagement sharedInstance].advWithGroupResult objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
            NSDictionary *result = [[[PalmUIManagement sharedInstance].advWithGroupResult objectForKey:ASI_REQUEST_DATA] objectForKey:@"content"];
            self.webUrl = result[@"url"];
            self.imageUrl = result[@"image"];
            ADImageview *adImage = [[ADImageview alloc] initWithUrl:[NSURL URLWithString:self.imageUrl]];
            adImage.adDelegate = self;
            [[UIApplication sharedApplication].keyWindow addSubview:adImage];
        }
    }
    
    if ([@"deleteTopicResult" isEqualToString:keyPath]) {
        if ([[[PalmUIManagement sharedInstance].deleteTopicResult objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
            return;
        }
        NSDictionary *result = [[PalmUIManagement sharedInstance].deleteTopicResult objectForKey:ASI_REQUEST_DATA];
        long long topicID = [[result objectForKey:@"topicid"] longLongValue];
        for (BBTopicModel *model in self.allTopicList) {
            if ([model.topicid longLongValue] == topicID) {
                [self.allTopicList removeObject:model];
                break;
            }
        }
        if ([self.allTopicList count] >= 30) {
            bjqTableView.showsInfiniteScrolling = YES;
        }else{
            bjqTableView.showsInfiniteScrolling = NO;
        }
        [bjqTableView reloadData];
    }
    
    if ([keyPath isEqualToString:@"downloadVideoResult"]){
        NSDictionary *dic = [PalmUIManagement sharedInstance].downloadVideoResult;
        if (![dic objectForKey:ASI_REQUEST_HAS_ERROR]) {
            [self showProgressWithText:[dic objectForKey:ASI_REQUEST_ERROR_MESSAGE] withDelayTime:3];
        }else{
            [self closeProgress];
            [self playVideo:self.videoFilePath];
        }
    }
}

-(void)imageTapped{
    ADDetailViewController *adDetailVC = [[ADDetailViewController alloc] initWithUrl:[NSURL URLWithString:self.webUrl]andADType:AD_TYPE_SCREEN];
    adDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:adDetailVC animated:YES];
}

-(void)addObservers{
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupListResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupTopicListResult" options:0 context:NULL];
    
    // 积分
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"userCredits" options:0 context:NULL];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"notifyCount" options:0 context:NULL];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"praiseResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"commentResult" options:0 context:NULL];
    
    // 广告
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"advWithGroupResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"deleteTopicResult" options:0 context:NULL];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"downloadVideoResult" options:0 context:nil];
    
    
}

-(void)removeObservers{

    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupListResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupTopicListResult"];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"userCredits"];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"notifyCount"];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"praiseResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"commentResult"];

    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"advWithGroupResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"deleteTopicResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"downloadVideoResult"];
    
    
}

-(void)checkNotify{

    [[PalmUIManagement sharedInstance] getNotiCount];
    [self performSelector:@selector(checkNotify) withObject:nil afterDelay:35.0f];

}

-(void)addNewTaped:(id)sender{
    [[UIApplication sharedApplication].keyWindow addSubview:fsDropdownView];
    [fsDropdownView show];
}

-(void)newNotifyTaped:(id)sender{
    notifyCount = 0;
    BBXXXViewController *xxx = [[BBXXXViewController alloc] init];
    xxx.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:xxx animated:YES];
    [self.notifyButton removeTarget:self action:@selector(newNotifyTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.notifyButton removeFromSuperview];
    self.notifyButton = nil;
    bjqTableView.tableHeaderView.frame = CGRectMake(0, 0, 320, 147);
    [bjqTableView reloadData];
}

-(void)bjButtonTaped:(id)sender{

    if (self.isLoading) {  // 屏蔽事件
        return;
    }
    
    if ([bjDropdownView.listData count] == 1) {
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:bjDropdownView];
    if (bjDropdownView.unfolded) {
        [bjDropdownView dismiss];
    }else{
        [bjDropdownView show];
    }
}

- (void)attributedLabelTapped
{
#ifdef IS_TEACHER
    BBJFViewController *jf = [[BBJFViewController alloc] init];
    jf.hidesBottomBarWhenPushed = YES;
    jf.url = [NSURL URLWithString:@"http://www.shouxiner.com/teacher_jfen/mobile_web_shop"];
    [self.navigationController pushViewController:jf animated:YES];
#endif
}

-(void)pointTaped:(UITapGestureRecognizer *)gesture{
#ifdef IS_TEACHER
    BBJFViewController *jf = [[BBJFViewController alloc] init];
    jf.hidesBottomBarWhenPushed = YES;
    jf.url = [NSURL URLWithString:@"http://www.shouxiner.com/teacher_jfen/mobile_web_shop"];
    [self.navigationController pushViewController:jf animated:YES];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.allTopicList = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeVC) name:@"changeVC" object:nil];
    // 不要移除，用户其他页面更新头像后，此页面同步更新
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"uiPersonalInfoTag" options:0 context:NULL];
    
    notifyCount = 0;
    
    hasNew = YES;
    self.type = 0;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    bjqTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0.0f, 320, self.screenHeight-64.0f-48.0f) style:UITableViewStyleGrouped];
    bjqTableView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    [bjqTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    bjqTableView.separatorColor = [UIColor clearColor];
    bjqTableView.dataSource = self;
    bjqTableView.delegate = self;
    [self.view addSubview:bjqTableView];
    [bjqTableView reloadData];
    
    
    
    UIView *bjqBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bjqTableView.frame.size.width, bjqTableView.frame.size.height)];
    [bjqBgView setBackgroundColor:[UIColor clearColor]];
    [bjqTableView setBackgroundView:bjqBgView];
    bjqBgView = nil;
    
    __weak BBBJQViewController *weakSelf = self;
    // 刷新
    [bjqTableView addPullToRefreshWithActionHandler:^{
        weakSelf.isLoading = YES;
        weakSelf.loadStatus = TopicLoadStatusRefresh;
        [[PalmUIManagement sharedInstance] getGroupTopic:[weakSelf.currentGroup.groupid intValue] withTimeStamp:1 withOffset:0 withLimit:30 withType:weakSelf.type];
    }];
    
    // 追加
    [bjqTableView addInfiniteScrollingWithActionHandler:^{
        weakSelf.isLoading = YES;
        weakSelf.loadStatus = TopicLoadStatusAppend;
        int offset = [weakSelf.allTopicList count];
        [[PalmUIManagement sharedInstance] getGroupTopic:[weakSelf.currentGroup.groupid intValue] withTimeStamp:1 withOffset:offset withLimit:30 withType:weakSelf.type];
    }];
    bjqTableView.showsInfiniteScrolling = NO;
    
    UIImageView *head = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 147)];
    head.backgroundColor = [UIColor clearColor];
    head.userInteractionEnabled = YES;
    
    
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    headImage.image = [UIImage imageNamed:@"BBTopBGNew"];
    headImage.userInteractionEnabled = YES;
    [head addSubview:headImage];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(pointTaped:)];
    UIImageView *scoreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BBScoreBG"]];
    scoreImageView.frame = CGRectMake(320.0f - 108.0f, 24.0f, 108.0f, 35.0f);
    scoreImageView.userInteractionEnabled = YES;
    [headImage addSubview:scoreImageView];
    
    point = [[OHAttributedLabel alloc] initWithFrame:CGRectMake(0, 9, 108, 35)];
    point.backgroundColor = [UIColor clearColor];
    point.userInteractionEnabled = YES;
    [scoreImageView addSubview:point];
    point.text = @"您有 0 手心币";
    point.delegate = self;
    point.textAlignment = NSTextAlignmentCenter;
    point.font = [UIFont boldSystemFontOfSize:11];
    point.textColor = [UIColor grayColor];
    point.userInteractionEnabled = YES;
    [point addGestureRecognizer:gesture];
    bjqTableView.tableHeaderView = head;
    bjqTableView.tableHeaderView.userInteractionEnabled = YES;
    
#ifdef IS_TEACHER
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(0.f, 14.f, 23.f, 23.f)];
    [addButton setBackgroundImage:[UIImage imageNamed:@"BBAdd"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addNewTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
#else
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setFrame:CGRectMake(0.f, 7.f, 40.f, 30.f)];
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
#endif
    
    titleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 125, 44)];
    [titleButton setTitle:@"班级" forState:UIControlStateNormal];
    self.navigationItem.titleView = titleButton;
    titleButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [titleButton addTarget:self action:@selector(bjButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(125, 12, 22, 22)];
    [titleButton addSubview:arrow];
    arrow.image = [UIImage imageNamed:@"BBDown"];
    
    CGRect rect = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 280.0f);
    bjDropdownView = [[BBBJDropdownView alloc] initWithFrame:rect];
    bjDropdownView.delegate = self;
    
    fsDropdownView = [[BBFSDropdownView alloc] initWithFrame:rect];
    fsDropdownView.delegate = self;
    
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    inputBar = [[BBInputView alloc] initWithFrame:CGRectMake(0, h, 320, 44)];
    inputBar.delegate = self;
    
    [[PalmUIManagement sharedInstance] getGroupList];
    
    [[PalmUIManagement sharedInstance] getUserCredits];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedRangeList:) name:@"SeletedRangeList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needRefresh) name:@"BJQNeedRefresh" object:nil];
    [self checkNotify];
    
  
    
    avatar = [[EGOImageView alloc] initWithFrame:CGRectMake(18, 65, 80, 80)];
    avatar.backgroundColor = [UIColor grayColor];
    NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
    if (path) {
        avatar.image = [UIImage imageWithContentsOfFile:path];
    }
    [bjqTableView addSubview:avatar];
    [bjqTableView bringSubviewToFront:avatar];
    CALayer *roundedLayer = [avatar layer];
    [roundedLayer setMasksToBounds:YES];
    roundedLayer.cornerRadius = 40.0;
    roundedLayer.borderWidth = 2;
    roundedLayer.borderColor = [[UIColor whiteColor] CGColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.isLoading = NO;
    [self addObservers];
    
//    [bjqTableView triggerPullToRefresh];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [inputBar endEdit];
    [self removeObservers];
}

-(void) changeVC{
    if (bjDropdownView.unfolded) {
        [bjDropdownView dismiss];
    }
    if (fsDropdownView.unfolded) {
        [fsDropdownView dismiss];
    }
    
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }
    if (nil != copyContentButton) {
        [copyContentButton removeFromSuperview];
        self.contentText = @"";
        copyContentButton = nil;
    }
}

-(void) needRefresh{
    NSLog(@"needRefresh");
    [self performSelector:@selector(needRefreshBJQData) withObject:nil afterDelay:1.0f];
}

-(void) needRefreshBJQData{
    [bjqTableView triggerPullToRefresh];
}

-(void)receiveSeletedRangeList:(NSNotification *)noti
{
    NSArray *selectedRanges = (NSArray *)[noti object];
    
    BOOL hasHomePage = NO;
    BOOL hasTopGroup = NO;
    for (NSString *tempRange in selectedRanges) {
        if ([tempRange isEqualToString:@"校园圈"]) {
            hasTopGroup = YES;
        }else if ([tempRange isEqualToString:@"手心网"])
        {
            hasHomePage = YES;
        }
    }
    
    if (hasHomePage || hasTopGroup) {
        if (self.recommendUsed != nil) {
            [[PalmUIManagement sharedInstance] postRecommend:[self.recommendUsed.topicid longLongValue] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
            self.recommendUsed.recommendToHomepage = hasHomePage;
            self.recommendUsed.recommendToGroups = hasTopGroup;
            [bjqTableView reloadData];
            [bjqTableView bringSubviewToFront:avatar];
        }
    }else{
        self.recommendUsed = nil;
    }
}

#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allTopicList count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier1 = @"linkCell";
    static NSString *cellIdentifier2 = @"replyCell";
    static NSString *cellIdentifier3 = @"imageCell";
    static NSString *cellIdentifier4 = @"pbxCell";
    static NSString *cellIdentifier5 = @"noticeCell";
    static NSString *cellIdentifier6 = @"videoCell";
    BBTopicModel *model = self.allTopicList[indexPath.row];
    /*
    1 班级通知
    2 家庭作业
    3 安全教育
    4 班级生活
    6 安全作业
    7 转发“有指示”
    */
    
    // 发作业2，发通知1，拍表现4，随便说4
    
    switch ([model.topictype intValue]) {
        case 1:  // 发通知1
            //
        {
        
            BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier5];
            if (!cell) {
                cell = [[BBNoticeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier5];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [cell setData:model];
            cell.delegate = self;
            return cell;
        }
            break;
        case 2:  // 发作业2
            //
        {
            
            BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
            if (!cell) {
                cell = [[BBWorkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [cell setData:model];
            cell.delegate = self;
            return cell;
        }
            break;
        case 4:  // 拍表现4，随便说4
            //
        {
            if ([model.subject integerValue] == 1) {
                if (model.imageList != nil && [model.imageList count] != 0) {
                    BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
                    if (!cell) {
                        cell = [[BBPBXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
                        cell.delegate = self;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    [cell setData:model];
                    cell.delegate = self;
                    return cell;
                }else if(model.videoList != nil && [model.videoList count] != 0){
                    BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier6];
                    if (!cell) {
                        cell = [[BBVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier6];
                        cell.delegate = self;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    [cell setData:model];
                    cell.delegate = self;
                    return cell;
                }else{
                    BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
                    if (!cell) {
                        cell = [[BBPBXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
                        cell.delegate = self;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    [cell setData:model];
                    cell.delegate = self;
                    return cell;
                }
            }else{
                BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
                if (!cell) {
                    cell = [[BBImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
                    cell.delegate = self;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell setData:model];
                cell.delegate = self;
                return cell;
            }
        }
            break;

        case 7:  // 转发 forword
            //
        {
            BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
            
            if (!cell) {
                cell = [[BBLinkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setData:model];
            cell.delegate = self;
            return cell;
        }
            break;
        default:   // 默认，随便说
            
            //
        {
            BBBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
            if (!cell) {
                cell = [[BBImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
                cell.delegate = self;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [cell setData:model];
            cell.delegate = self;
            return cell;
        }
            
            break;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 340;
    return [BBCellHeight heightOfData:self.allTopicList[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (notifyCount>0) { // hasNew
        return 76;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [inputBar endEdit];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView bringSubviewToFront:avatar];
}

#pragma mark - BBFSDropdownViewDelegate

-(void)bbFSDropdownView:(BBFSDropdownView *) dropdownView_ didSelectedAtIndex:(NSInteger) index_{
    
    /*
     显示全部
     显示作业
     刷新
     */
    if (index_ == 0) {
        self.type = 0;
        [bjqTableView triggerPullToRefresh];
    }else if(index_ == 1){
        self.type = 2;
        [bjqTableView triggerPullToRefresh];
    }else{
        [bjqTableView triggerPullToRefresh];
    }
    
//    if (index_ == 0) {
//        BBPBXViewController *pbx = [[BBPBXViewController alloc] init];
//        pbx.hidesBottomBarWhenPushed = YES;
//        pbx.currentGroup = _currentGroup;
//        [self.navigationController pushViewController:pbx animated:YES];
//    }else
//    {
//        BBFZYViewController *fzy = [[BBFZYViewController alloc] init];
//        fzy.hidesBottomBarWhenPushed = YES;
//        if (index_ == 1) {
//            fzy.style = 0;
//        }else if (index_ == 2){
//            fzy.style = 1;
//        }else{
//            fzy.style = 3;
//        }
//        fzy.currentGroup = _currentGroup;
//        [self.navigationController pushViewController:fzy animated:YES];
//    }
}

-(void)bbFSDropdownViewTaped:(BBFSDropdownView *) dropdownView_{

}

#pragma mark - BBBJDropdownViewDelegate
-(void)bbBJDropdownView:(BBBJDropdownView *) dropdownView_ didSelectedAtIndex:(NSInteger) index_{
    _currentGroup = dropdownView_.listData[index_];
    [PalmUIManagement sharedInstance].currentGroupInfo = _currentGroup;
    [titleButton setTitle:_currentGroup.alias forState:UIControlStateNormal];
    
    [bjqTableView triggerPullToRefresh];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setInteger:index_ forKey:@"saved_topic_group_index"];
    [def synchronize];
    
}

-(void)bbBJDropdownViewTaped:(BBBJDropdownView *) dropdownView_{

}

-(void)shareTaped:(id)sender{
    BBFZYViewController *fzy = [[BBFZYViewController alloc] init];
    fzy.hidesBottomBarWhenPushed = YES;
    fzy.style = 3;
    fzy.currentGroup = _currentGroup;
    [self.navigationController pushViewController:fzy animated:YES];
}


#pragma mark - BBBaseTableViewCellDelegate

// 赞
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell likeButtonTaped:(UIButton *)sender{
    self.tempTopModel = cell.data;
    if ([self.tempTopModel.am_i_like boolValue]) {
        return;
    }
    [[PalmUIManagement sharedInstance] postPraise:[self.tempTopModel.topicid longLongValue]];
}


// 更多
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell moreButtonTaped:(UIButton *)sender{
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
        return;
    }
    if (nil != copyContentButton) {
        [copyContentButton removeFromSuperview];
        self.contentText = @"";
        copyContentButton = nil;
    }
    
    CGRect superViewRect = [cell convertRect:sender.frame toView:self.view];
    self.tempCell = cell;
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(superViewRect.origin.x - 128.0f, superViewRect.origin.y-2.0f, 125.0f, 30.0f)];
    bgImageView.image = [UIImage imageNamed:@"BJQMoreBg"];
    bgImageView.userInteractionEnabled = YES;
    bgImageView.hidden = YES;
    bgImageView.alpha = 0.0f;
    [self.view addSubview:bgImageView];
    self.tempMoreImage = bgImageView;
    
    UIButton *like = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 62.0f, 30.0f)];
    if ([cell.data.am_i_like boolValue]) {
        [like setBackgroundImage:[UIImage imageNamed:@"BJQHasZanButton"] forState:UIControlStateNormal];
    }else{
        [like setBackgroundImage:[UIImage imageNamed:@"BJQHaveNotZanButton"] forState:UIControlStateNormal];
        [like addTarget:self action:@selector(likeTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    [bgImageView addSubview:like];
    
    UIButton *reply = [[UIButton alloc] initWithFrame:CGRectMake(63.0f, 0.0f, 62.0f, 30.0f)];
    [reply setBackgroundImage:[UIImage imageNamed:@"BJQPingLunButton"] forState:UIControlStateNormal];
    [reply setBackgroundImage:[UIImage imageNamed:@"BJQPingLunButtonPressed"] forState:UIControlStateHighlighted];
    
    [bgImageView addSubview:reply];
    
    [UIImageView animateWithDuration:0.3f animations:^{
        bgImageView.alpha = 1.0f;
        bgImageView.hidden = NO;
    } completion:^(BOOL finished) {
        [reply addTarget:self action:@selector(replyTaped:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

// 复制
-(void) bbBaseTableViewCell:(BBBaseTableViewCell *)cell touchPoint:(CGPoint)touchPoint longPressText:(NSString *)text{
    if (nil != copyContentButton) {
        [copyContentButton removeFromSuperview];
        self.contentText = @"";
        copyContentButton = nil;
    }
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }

    CGPoint superPointaa = [cell convertPoint:touchPoint toView:self.view];
    copyContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyContentButton setBackgroundImage:[UIImage imageNamed:@"BBCopyContent"] forState:UIControlStateNormal];
    [copyContentButton setBackgroundImage:[UIImage imageNamed:@"BBCopyContent"] forState:UIControlStateHighlighted];
    copyContentButton.frame = CGRectMake(superPointaa.x - 32.0f, superPointaa.y - 60.0f, 64.0f, 37.0f);
    [copyContentButton addTarget:self action:@selector(copyContent) forControlEvents:UIControlEventTouchUpInside];
    self.contentText = text;
    [self.view addSubview:copyContentButton];
}

-(void) copyContent{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:self.contentText];
    if (nil != copyContentButton) {
        [copyContentButton removeFromSuperview];
        self.contentText = @"";
        copyContentButton = nil;
    }
}

// 推荐
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell recommendButtonTaped:(UIButton *)sender{
    self.recommendUsed = cell.data;
    BBRecommendedRangeViewController *recommendedRangeVC = [[BBRecommendedRangeViewController alloc] initWithRanges:nil];
    recommendedRangeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommendedRangeVC animated:YES];
}

-(void)replyTaped:(id)sender{
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }
    [self bbBaseTableViewCell:self.tempCell replyButtonTaped:nil];
}

-(void)likeTaped:(id)sender{
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }
    [self bbBaseTableViewCell:self.tempCell likeButtonTaped:nil];
}


// 评论
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell replyButtonTaped:(UIButton *)sender{

    [[UIApplication sharedApplication].keyWindow addSubview:inputBar];
    inputBar.data = cell.data;
    [inputBar beginEdit];
    self.model = nil;
    NSIndexPath *indexPath = [bjqTableView indexPathForCell:cell];
    CGRect r0 = [bjqTableView rectForRowAtIndexPath:indexPath];
    CGRect r1 = [bjqTableView convertRect:r0 toView:nil];
    int x = [UIScreen mainScreen].bounds.size.height-260-r1.origin.y-r1.size.height;
    CGPoint p = CGPointMake(0, bjqTableView.contentOffset.y-x);
    
    [bjqTableView setContentOffset:p animated:YES];
}

-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell commentButtonTaped:(UIButton *)sender{
    [[UIApplication sharedApplication].keyWindow addSubview:inputBar];
    inputBar.data = cell.data;
    self.model = [cell.data.comments objectAtIndex:sender.tag-1];
    [inputBar beginEdit:[NSString stringWithFormat:@"回复%@：",self.model.username]];
    
    NSIndexPath *indexPath = [bjqTableView indexPathForCell:cell];
    CGRect r0 = [bjqTableView rectForRowAtIndexPath:indexPath];
    CGRect r1 = [bjqTableView convertRect:r0 toView:nil];
    int x = [UIScreen mainScreen].bounds.size.height-260-r1.origin.y-r1.size.height;
    CGPoint p = CGPointMake(0, bjqTableView.contentOffset.y-x);
    
    [bjqTableView setContentOffset:p animated:YES];

}

// 点击大图
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell imageButtonTaped:(EGOImageButton *)sender{

    [inputBar endEdit];
    BBTopicModel *model = cell.data;
    
    int count = model.imageList.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [NSString stringWithFormat:@"%@",model.imageList[i]];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        BBImageTableViewCell *c =(BBImageTableViewCell*)cell;
        EGOImageButton *temp = [c imageContentWithIndex:i];
        CGRect superViewRect = [cell convertRect:temp.frame toView:nil];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:superViewRect];
        imageview.image = [temp currentBackgroundImage];
        imageview.hidden = YES;
        [self.view addSubview:imageview];
        photo.srcImageView = imageview; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = sender.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell linkButtonTaped:(UIButton *)sender{
    if (cell.data.forward.url) {
        BBShareWebViewController *jf = [[BBShareWebViewController alloc] init];
        jf.hidesBottomBarWhenPushed = YES;
        jf.url = [NSURL URLWithString:cell.data.forward.url];
        [self.navigationController pushViewController:jf animated:YES];
    }
}

-(void) bbBaseTableViewCell:(BBBaseTableViewCell *)cell deleteButtonTaped:(UIButton *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除" message:@"是否删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.delegate = self;
    self.deleteCell = cell;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        [[PalmUIManagement sharedInstance] deleteTopic:[self.deleteCell.data.topicid longLongValue]];
    }
}

-(void) bbBaseTableViewCell:(BBVideoTableViewCell *)cell playVideoTaped:(EGOImageButton *)sender{
    NSArray *array = [cell.data.videoList[0] componentsSeparatedByString:@","];
    NSString *url = array[0];
    url = [url substringToIndex:url.length - 1];
    NSString *key = [[url componentsSeparatedByString:@"/"] lastObject];
    url = [NSString stringWithFormat:@"%@/mp4",url];
    
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSString *writeFileName = [NSString stringWithFormat:@"%@.%@",key,@".mp4"];
    NSString *fileDir = [NSString stringWithFormat:@"%@/Video/",account.loginName];
    self.videoFilePath = [NSString stringWithFormat:@"%@/%@%@",[CoreUtils getDocumentPath],fileDir,writeFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.videoFilePath]) {
        [self playVideo:self.videoFilePath];
    }else{
        [self showProgressWithText:@"正在下载"];
        [[PalmUIManagement sharedInstance] downLoadUserVideoFile:url withKey:key];
    }
}

-(void) playVideo:(NSString *)videoPath{
    if (videoPath == nil || [videoPath isEqualToString:@""]) {
        return;
    }
    NSURL*videoPathURL=[[NSURL alloc] initFileURLWithPath:videoPath];
    MPMoviePlayerViewController *playViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoPathURL];
    MPMoviePlayerController *player = [playViewController moviePlayer];
    player.scalingMode = MPMovieScalingModeNone;
    player.controlStyle = MPMovieControlStyleFullscreen;
    [self.navigationController presentViewController:playViewController animated:NO completion:nil];
    [player play];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [inputBar endEdit];
    self.model = nil;
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }
    if (bjDropdownView.unfolded) {
        [bjDropdownView dismiss];
    }
    if (fsDropdownView.unfolded) {
        [fsDropdownView dismiss];
    }
    
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }
    if (nil != copyContentButton) {
        [copyContentButton removeFromSuperview];
        self.contentText = @"";
        copyContentButton = nil;
    }
}

#pragma mark - BBInputViewDelegate

-(void)bbInputView:(BBInputView *)view sendText:(NSString *)text{
    // send
    
//    BBTopicModel *model = view.data;
    self.tempTopModelInput = view.data;
    self.inputText = text;
    int replyUid = [self.tempTopModelInput.author_uid intValue];
    if (self.model != nil) {
        replyUid = [self.model.uid integerValue];
    }
    [[PalmUIManagement sharedInstance] postComment:text
                                    withReplyToUid:replyUid
                                       withTopicID:[self.tempTopModelInput.topicid longLongValue]];
}

#pragma 展示图片的委托实现开始
-(void)beganCloseImageAnimation{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
-(void)endCloseImageAnimation{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (nil != copyContentButton) {
        [copyContentButton removeFromSuperview];
        self.contentText = @"";
        copyContentButton = nil;
    }
    if (self.tempMoreImage != nil) {
        [self.tempMoreImage removeFromSuperview];
        self.tempMoreImage = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void) dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"uiPersonalInfoTag"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeVC" object:nil];
}
@end
