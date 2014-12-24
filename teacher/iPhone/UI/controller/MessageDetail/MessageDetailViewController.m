//
//  MessageDetailViewController.m
//  iCouple
//
//  Created by wang shuo on 12-5-2.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#define ActivityIndicatorTag 1000;
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#import "MessageDetailViewController.h"
#import "MessageSoundPlayer.h"
#import "MediaStatusManager.h"
#import "TPCMToAMR.h"
#import "TimeDetector.h"
#import "TimeParser.h"
#import "Reachability.h"

//#import "SJAvatarBrowser.h"

@interface MessageDetailViewController ()

#pragma mark - 私有属性声明

@property (nonatomic, strong) CPUIModelMessageGroup *messageGroup;
// 风火轮
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
// load head view
@property (nonatomic,strong) UIView *loadHeaderView;
// 动画通用
@property (nonatomic,strong) MessageExpressionViewController *messageExpressionViewController;
// 魔法表情
@property (nonatomic,strong) MessagePetViewController *petViewController;
// 缓存的数据字典
@property (nonatomic,strong) NSMutableDictionary *exModelDictionary;
// 缓存的魔法表情传情的下载信息
@property (nonatomic,strong) NSMutableDictionary *animationDictionary;
// 是否有历史数据
@property (nonatomic) BOOL hasHistoryMessageData;
// 是否是初始化
@property (nonatomic) BOOL isFirstShow;
// 是否是历史消息
@property (nonatomic) BOOL isHistory;
// reload的索引
@property (nonatomic,strong) NSMutableArray *reloadIndex;

@property (nonatomic,strong) NSDateFormatter *dateFormatter;

// 显示图片的view
@property (nonatomic,strong) MessagePictrueViewController *messagePictrueController;
// 视频显示的view
@property (nonatomic,strong) MessageVideoViewController *messageVideoController;

// 保存用户点选闹钟的exMessageModel
@property (nonatomic,strong) ExMessageModel *alarmMessageModel;
// 闹铃第一次出现的引导图片
@property (nonatomic,strong) UIImageView *firstAlarm;
@property (nonatomic,strong) AlarmDatePickerView *datepicker;
#pragma mark - 私有方法声明

// 更新底层message数据
-(void) refreshMessageModel;

-(ChatInforCellBase *) createMessageCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
// 获取显示的时间标题 －－ 昨天或日期
-(NSString *) getMessageHeaderDate : (NSDate *) messageDate withCurrentDate : (NSDate *) currentDate;
// 该文件是否存在
-(BOOL) hasFile : (NSString *)filePath;

// 获得当前网络状态
-(NetworkStatus) getCurrentNetworkState;
// 判断当前魔法表情或传情动画本地是否存在
-(BOOL) checkMagicOrFeelingAnimationWithResID : (NSString *) resID withPetID : (NSString *) petID withType : (MsgContentType) contentType;
// 判断魔法表情或传情动画状态
-(AnimationState) magicOrFeelingAnimationState : (NSString *) resID withPetID : (NSString *) petID withType : (MsgContentType) contentType;

-(void) playMagicResID : (NSString *) resID withPetID : (NSString *) petID;

// 分析是否有日期
-(BOOL) analysisDate : (NSString *) text;
@end

@implementation MessageDetailViewController
@synthesize messageTable = _messageTable , exMessageModelArray = _exMessageModelArray , messageGroup = _messageGroup; 
@synthesize isGroupMessageTable = _isGroupMessageTable;
@synthesize activityIndicator = _activityIndicator , loadHeaderView = _loadHeaderView;
@synthesize delegate = _delegate , petViewController = _petViewController;
@synthesize isNotificationLoadMessage = _isNotificationLoadMessage , exModelDictionary = _exModelDictionary;
@synthesize messageExpressionViewController = _messageExpressionViewController;
@synthesize hasHistoryMessageData = _hasHistoryMessageData;
@synthesize animationDictionary = _animationDictionary;
@synthesize messagePictrueController = _messagePictrueController , messageVideoController = _messageVideoController;
@synthesize isFirstShow = _isFirstShow , isHistory = _isHistory;
@synthesize canPlayMagic = _canPlayMagic;
@synthesize reloadIndex = _reloadIndex;
@synthesize alarmMessageModel = _alarmMessageModel;
@synthesize firstAlarm = _firstAlarm , datepicker = _datepicker , dateFormatter = _dateFormatter;

-(NetworkStatus) getCurrentNetworkState{
    return [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus];
}

#pragma mark - 聊天初始化
-(id) init{
    self = [super init];
    if (self) {
        self.exMessageModelArray = [NSMutableArray arrayWithCapacity:100];
        self.animationDictionary = [NSMutableDictionary dictionaryWithCapacity:100];
        self.isNotificationLoadMessage = NO;
        self.isFirstShow = YES;
        self.reloadIndex = [[NSMutableArray alloc] initWithCapacity:30];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT+8"]];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"petDataDict" options:0 context:@"MessageDetailViewController"];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // 初始化聊天table
    self.messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStyleGrouped];
//    self.messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f) style:UITableViewStylePlain];
    
    self.messageTable.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | 
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | 
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.messageTable setBackgroundColor:[UIColor whiteColor]];
    self.messageTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageTable.separatorColor = [UIColor clearColor];
    self.exModelDictionary = [NSMutableDictionary dictionaryWithCapacity:100];
    [self.view addSubview:self.messageTable];
    self.messageTable.delegate = self;
    self.messageTable.dataSource = self;
    self.messageTable.backgroundColor = [UIColor clearColor];
    self.messageTable.backgroundView = nil;
    
    self.loadHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    // 风火轮
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityIndicator.tag = ActivityIndicatorTag;
    self.activityIndicator.frame = CGRectMake(160.0f - 8.0f, 20.0f - 8.0f, 16.0f, 16.0f);
    [self.activityIndicator startAnimating];
//    [self.messageTable setTableHeaderView:self.loadHeaderView];
    self.hasHistoryMessageData = YES;
    
}

#pragma mark - 下载魔法表情或传情

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"petDataDict"]) {
        NSNumber *type = (NSNumber *)[[CPUIModelManagement sharedInstance].petDataDict objectForKey:pet_datachange_type];
        // 成功还是失败
        NSNumber *petResult = (NSNumber *)[[CPUIModelManagement sharedInstance].petDataDict objectForKey:pet_datachange_result];
        // petid
        NSString *petID = (NSString *)[[CPUIModelManagement sharedInstance].petDataDict objectForKey:pet_datachange_petid];
        // resid
        NSString *petResID = (NSString *)[[CPUIModelManagement sharedInstance].petDataDict objectForKey:pet_datachange_id];
        
        AnimationState animationState = AnimationInvalidate;
        
        if ([type intValue] == PET_DATACHANGE_TYPE_DOWNLOADING) {
            animationState = AnimationDownloading;
            
            for (ExMessageModel *exModel in self.exMessageModelArray) {
                if ([exModel.messageModel.magicMsgID isEqualToString:petResID] && [exModel.messageModel.petMsgID isEqualToString:petID]) {
                    exModel.animationsState = animationState;
                }
            }
            
            [self.messageTable reloadData];
            return;
        }
        
        switch ([petResult intValue]) {
            case PET_DATACHANGE_RESULT_FAIL:
                animationState = AnimationDownloadingError;
                break;
            case PET_DATACHANGE_RESULT_SUC:
                animationState = AnimationSucceed;
                break;
            default:
                break;
        }
        
        for (ExMessageModel *exModel in self.exMessageModelArray) {
            if ([exModel.messageModel.magicMsgID isEqualToString:petResID] && [exModel.messageModel.petMsgID isEqualToString:petID]) {
                exModel.animationsState = animationState;
            }
        }
        
        [self.messageTable reloadData];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 初始化聊天数据信息
    [self refreshMessageTableToBottom:YES withAnimated:NO];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(clickMessageTableView:)]) {
        [self.delegate clickMessageTableView:self.messageTable];
    }
}

#pragma mark - 刷新聊天页面及聊天页面移动

// 刷新数据，并设置是否移动到最底层
-(void) refreshMessageData : (CPUIModelMessageGroup *) modelMessageGroup withMove : (BOOL) isMove withAnimated : (BOOL) animated withImportData : (BOOL) isImportData withRefreshMessage : (BOOL) isRefresh{
    
//    CPLogInfo(@"加载消息 是否移动:%@ 是否有动画:%@ 是否重新导入数据:%@ 是否刷新数据:%@",isMove?@"YES":@"NO",animated?@"YES":@"NO",isImportData?@"YES":@"NO",isRefresh ? @"YES":@"NO");
    NSLog(@"加载消息 是否移动:%@ 是否有动画:%@ 是否重新导入数据:%@ 是否刷新数据:%@",isMove?@"YES":@"NO",animated?@"YES":@"NO",isImportData?@"YES":@"NO",isRefresh ? @"YES":@"NO");
    
    if (isImportData) {
        [self refreshMessageTable:modelMessageGroup];
    }
    if (isRefresh) {
        [self.messageTable reloadData];
    }
    [self refreshMessageTableToBottom:isMove withAnimated:animated];
}

// 刷新数据，并设置是否移动到最底层 － 优化版
-(void) refreshMessageData:(CPUIModelMessageGroup *)modelMessageGroup withRefreshType:(refreshType)type{
    if (type == AppendOneMessage) {
        self.messageGroup = modelMessageGroup;
        if ([self.messageGroup.type intValue] == MSG_GROUP_UI_TYPE_SINGLE) {
            self.isGroupMessageTable = NO;
        }else if ([self.messageGroup.type intValue] == MSG_GROUP_UI_TYPE_MULTI || [self.messageGroup.type intValue] == MSG_GROUP_UI_TYPE_CONVER) {
            self.isGroupMessageTable = YES;
        }else {
            self.isGroupMessageTable = NO;
        }
        [self refreshMessageTableToBottom:YES withAnimated:NO];
        [self refreshMessageModel];
        
        
        [self.messageTable beginUpdates];
        NSNumber *temp = [self.reloadIndex objectAtIndex:0];
        NSUInteger indexSetction = [temp unsignedIntValue];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexSetction];
        [self.messageTable insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
        [self.messageTable endUpdates];
        
        [self refreshMessageTableToBottom:YES withAnimated:YES];
    }
}

// 不移动到最底层，仅仅刷新消息数据
-(void) refreshMessageTable : (CPUIModelMessageGroup *) modelMessageGroup{
    self.messageGroup = modelMessageGroup;
    if ([self.messageGroup.type intValue] == MSG_GROUP_UI_TYPE_SINGLE) {
        self.isGroupMessageTable = NO;
    }else if ([self.messageGroup.type intValue] == MSG_GROUP_UI_TYPE_MULTI || [self.messageGroup.type intValue] == MSG_GROUP_UI_TYPE_CONVER) {
        self.isGroupMessageTable = YES;
    }else {
        self.isGroupMessageTable = NO;
    }
    [self refreshMessageModel];
    
//    
    if ([self.reloadIndex count] >=2) {
        [self.messageTable reloadData];
    }else if ([self.reloadIndex count] == 1) {
//        [self.messageTable beginUpdates];
//        NSNumber *temp = [self.reloadIndex objectAtIndex:0];
//        NSUInteger indexSetction = [temp unsignedIntValue];
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexSetction];
//        [self.messageTable insertSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
//        [self.messageTable endUpdates];
        
        [self.messageTable reloadData];
    }else {
        [self.messageTable reloadData];
    }
//    
//    [self.messageTable reloadData];
    
}

// 移动到最底层
-(void) refreshMessageTableToBottom : (BOOL) isMove withAnimated : (BOOL) animated{
    
    if (!isMove) {
        return;
    }
    
    if ([self.exMessageModelArray count] == 0) {
        self.messageTable.tableHeaderView = nil;
        return;
    }
    
    if (self.messageTable.contentSize.height > self.messageTable.frame.size.height + 40.0f) {
        if (!self.hasHistoryMessageData) {
            if (nil != self.messageTable.tableHeaderView) {
                self.messageTable.tableHeaderView = nil;
            }
        } else if ( nil == self.messageTable.tableHeaderView ) {
            [self.messageTable setTableHeaderView:self.loadHeaderView];
        }
        
        NSIndexPath *bottomIndexPath = [NSIndexPath indexPathForRow:0 inSection:[self.exMessageModelArray count] - 1];
        [self.messageTable scrollToRowAtIndexPath:bottomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }else {
        CPLogInfo(@"-------------------------------%f",self.messageTable.contentSize.height);
        CPLogInfo(@"%@",self.messageTable.tableHeaderView);
        if (nil != self.messageTable.tableHeaderView) {
            self.messageTable.tableHeaderView = nil;
        }
//        self.messageTable.tableHeaderView = nil;
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //    CPLogInfo(@"MessageDetailViewController touchesBegan");
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //    CPLogInfo(@"MessageDetailViewController touchesMoved");
}

// 刷新聊天数据信息
-(void) refreshMessageModel{
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // 保存的时间
    NSString *dateString = @"";
    
    NSMutableArray *newMessageArray = [NSMutableArray arrayWithCapacity:100];
    ExMessageModel *newMessage = nil;
    self.reloadIndex = [[NSMutableArray alloc] initWithCapacity:30];
    NSUInteger messageCount = 0;
    // 重新加载数据集
    for (CPUIModelMessage *message in self.messageGroup.msgList) {
        messageCount += 1;
        ExMessageModel *exMessage = (ExMessageModel *)[self.exModelDictionary objectForKey:message.msgID];

        if (exMessage){
            // 如果是不新的消息
            [exMessage setMessageModel:message];
            [newMessageArray addObject:exMessage];
        }else {
            // 此条是新的消息
            [self.reloadIndex addObject:[NSNumber numberWithInt:messageCount - 1]];
            
            exMessage = [[ExMessageModel alloc] init];
            exMessage.isGroupMessageTable = self.isGroupMessageTable;
            [exMessage setMessageModel:message];
            [newMessageArray addObject:exMessage];
            [self.exModelDictionary setObject:exMessage forKey:exMessage.messageModel.msgID];
            if ([message.contentType intValue] == MSG_CONTENT_TYPE_MAGIC) {
                exMessage.animationsState = [self magicOrFeelingAnimationState:exMessage.messageModel.magicMsgID withPetID:exMessage.messageModel.petMsgID withType:MSG_CONTENT_TYPE_MAGIC];
            }else if ([message.contentType intValue] == MSG_CONTENT_TYPE_CQ) {
                exMessage.animationsState = [self magicOrFeelingAnimationState:exMessage.messageModel.magicMsgID withPetID:exMessage.messageModel.petMsgID withType:MSG_CONTENT_TYPE_CQ];
            }else if([message.contentType intValue] == MSG_CONTENT_TYPE_TEXT && !self.isHistory && !self.isFirstShow){
                if ([TimeDetector containTimeInfo:message.msgText]) {
                    exMessage.isShowAlarmTip = YES;
                    NSDate * date = [[TimeParser getInstance]process:message.msgText];
//                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
//                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                    NSLog(@"%@---%@",message.msgText,[dateFormatter stringFromDate:date]);
                    exMessage.alarmDate = date;
                    // 如果分析为闹钟类型，并且是第一次出现，则显示引导图片
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSString *allow = [defaults objectForKey:@"FirstAlarm"];
                    if (nil == allow || [allow isEqualToString:@""]){
                        if ([exMessage.messageModel.flag intValue] != MSG_FLAG_RECEIVE && self.isGroupMessageTable == NO) {
                            if ([self.delegate respondsToSelector:@selector(alarmFirstShow)]) {
                                [self.delegate alarmFirstShow];
                            }
                            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"FirstAlarm"];
                        }
                    }
                }
            }else if ([message.contentType intValue] == MSG_CONTENT_TYPE_ALARM_AUDIO){
                exMessage.isResoureBreak = YES;
            }
            
            if (!self.isFirstShow) {
                // 如果不是第一次进入
                newMessage = exMessage;
                if (!self.isHistory) {
                    //如果不是历史消息
                    exMessage.isPlayAnimation = YES;
                }
            }
        }
        // 转换时间为日期类型
        NSDate *tempDate = [NSDate dateWithTimeIntervalSince1970:[message.date longLongValue]/1000];

        // 获取日期
        NSString *str = [self getMessageHeaderDate:tempDate withCurrentDate:[NSDate date]];
        
        // 如果日期不存在，呈现日期，并且缓存呈现的日期
        if (![dateString isEqualToString:str]) {
            exMessage.headerDate = str;
            exMessage.isShowHeaderDate = YES;
            dateString = str;
        }else {
            exMessage.headerDate = @"";
            exMessage.isShowHeaderDate = NO;
        }
    }
    
    if ([newMessage.messageModel.contentType intValue] == MSG_CONTENT_TYPE_MAGIC) {
        if (self.canPlayMagic && newMessage.animationsState == AnimationSucceed) {
            if ([newMessage.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
                self.canPlayMagic = NO;
                [MediaStatusManager sharedInstance].isAudioPlaying = YES;
                [self playMagicResID:newMessage.messageModel.magicMsgID withPetID:newMessage.messageModel.petMsgID];
            }
        }
    }
    
    if (self.isFirstShow) {
        self.isFirstShow = NO;
    }
    
    self.exMessageModelArray = newMessageArray;
}

//// 动画的结束回调，回调方法内
//- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
//    if ([animationID isEqualToString:@"show"]) {
//        [UIImageView beginAnimations:@"show" context:nil];
//        [UIImageView setAnimationDuration:0.5f];
//        [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//        
//        // 动画的结束回调，回调方法内
//        [UIImageView setAnimationDelegate:self];
//        [UIImageView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//        
//        [self.firstAlarm setAlpha:0.0f];
//        
//        [UIImageView commitAnimations];
//    }
//}


#pragma mark - 消息的时间头显示
-(NSString *) getMessageHeaderDate:(NSDate *)messageDate withCurrentDate:(NSDate *)currentDate{
    
    NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
    
    NSString *messageYMD = [self.dateFormatter stringFromDate:messageDate];
    NSString *currentYMD = [self.dateFormatter stringFromDate:currentDate];
    NSString *yestodayYMD = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:(currentTimeInterval - (24*60*60))]];
    
    if ([messageYMD isEqualToString:currentYMD]) {
        return @"以下是 今天";
    }else if ([messageYMD isEqualToString: yestodayYMD]) {
        return @"以下是 昨天";
    }else {
        return [NSString stringWithFormat:@"以下是 %@",[self.dateFormatter stringFromDate:messageDate]];
    }
}

// 设置每个section的头部名称
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    // 获取聊天数据
    ExMessageModel *exMessage = [self.exMessageModelArray objectAtIndex:section];
    if (!exMessage.isShowHeaderDate) {
        return nil;
    }
    // create section header view
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    timeView.backgroundColor = [UIColor clearColor];
    
    // 显示的时间标签
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textAlignment = UITextAlignmentCenter;
    if ([exMessage.headerDate isEqualToString:@"昨天"]) {
        timeLabel.font = [UIFont boldSystemFontOfSize:10.0f];
    }else{
        timeLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    
    timeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    timeLabel.text = exMessage.headerDate;
    [timeLabel sizeToFit];
    
    UIImage *lineImage = [UIImage imageNamed:@"line03_im.png"];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 17.0f + (19.0f / 2.0f), 320.0f, 1.0f)];
    lineImageView.image = lineImage;
    
    
    // 创建背景imageView
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    UIImage *bgImage = [UIImage imageNamed:@"bg_im_system_gray.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:20 topCapHeight:16];
    bgImageView.image = bgImage;
    bgImageView.frame = CGRectMake((320.0f - timeLabel.frame.size.width - 22.0f)/2, 17.0f, timeLabel.frame.size.width + 22.0f, 18.0f);
    
    [bgImageView addSubview:timeLabel];
    timeLabel.frame = CGRectMake(11.0f, 2.5f, timeLabel.frame.size.width,timeLabel.frame.size.height);
    [timeView addSubview:lineImageView];
    [timeView addSubview:bgImageView];
    //    [timeView setBackgroundColor:[UIColor redColor]];
    
    return timeView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // 获取聊天数据
    ExMessageModel *exMessage = [self.exMessageModelArray objectAtIndex:section];
    if (!exMessage.isShowHeaderDate) {
        return 0.01f;
    }else {
        return 44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
//    CPLogInfo(@"----------Message Count : %d------------",[self.exMessageModelArray count]);
    return [self.exMessageModelArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatInforCellBase *cell = [self createMessageCell:tableView cellForRowAtIndexPath:indexPath];
    
    if ( nil == cell) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *tempView = [[UIView alloc] init];
    [cell setBackgroundView:tempView];
//    [tempView setBackgroundColor:[UIColor redColor]];
//    [cell.contentView setBackgroundColor:[UIColor greenColor]];
    cell.delegate = self;
//    for (UIView *view in self.messageTable.subviews) {
//        if ([view isMemberOfClass:[UIImageView class]]) {
//            [view removeFromSuperview];
//        }
//    }
//    NSLog(@"%@",self.messageTable.subviews);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 获取聊天数据
    ExMessageModel *exMessage = [self.exMessageModelArray objectAtIndex:indexPath.section];
    
    float cellHeight = 0.0f;
    switch ([exMessage.messageModel.contentType intValue]) 
    {
        case MSG_CONTENT_TYPE_UNKNOWN:
            cellHeight = [CalculateCellHeight heightOfSystemTextActionCell:exMessage.messageModel.msgText];
            break;
            // 如果是图文混排信息
        case MSG_CONTENT_TYPE_TEXT:{
                if (exMessage.departedheight != 0.0f) {
                    cellHeight = exMessage.departedheight;
                }else {
                    ExpressionsParser *expressionsParser = [[ExpressionsParser alloc] initWithMessage:exMessage.messageModel.msgText];
                
                    [expressionsParser parse];
                    exMessage.expressionsParser = expressionsParser;
                    cellHeight = [CalculateCellHeight heightOfSmallExpressionCell:expressionsParser.departedHeightArray];
                    exMessage.departedheight = cellHeight;
                
                }
            }
            break;
        case MSG_CONTENT_TYPE_ALARM_TEXT:
            // 如果是闹钟未提醒消息
            if (exMessage.departedheight != 0.0f) {
                cellHeight = exMessage.departedheight;
            }else {
                ExpressionsParser *expressionsParser = [[ExpressionsParser alloc] initWithMessage:exMessage.messageModel.msgText];
                
                [expressionsParser parse];
                exMessage.expressionsParser = expressionsParser;
                cellHeight = [CalculateCellHeight heightOfTextAlarmExpressionCell:expressionsParser.departedHeightArray];
                exMessage.departedheight = cellHeight;
            }
            break;
        case MSG_CONTENT_TYPE_ALARMED_TEXT:
            // 如果是闹钟已提醒的消息
            if (exMessage.departedheight != 0.0f) {
                cellHeight = exMessage.departedheight;
            }else {
                ExpressionsParser *expressionsParser = [[ExpressionsParser alloc] initWithMessage:exMessage.messageModel.msgText];
                
                [expressionsParser parse];
                exMessage.expressionsParser = expressionsParser;
                cellHeight = [CalculateCellHeight heightOfTextAlarmedExpressionCell:expressionsParser.departedHeightArray];
                exMessage.departedheight = cellHeight;
            }
            break;
        case MSG_CONTENT_TYPE_ALARM_AUDIO:
            
            if (exMessage.alarmHeight != 0.0f) {
                cellHeight = exMessage.alarmHeight;
            }else{
                if ([exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_DOWNING) {
                    cellHeight = [CalculateCellHeight heightOfSoundAlarmCell : [exMessage.messageModel.isAlarmHidden boolValue]];
                }else if ([exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_DEFAULT
                          || [exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_SENDING
                          || [exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_SEND_SUCESS
                          || [exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_SEND_ERROR){
                    cellHeight = [CalculateCellHeight heightOfSoundAlarmCell : [exMessage.messageModel.isAlarmHidden boolValue]];
                    exMessage.isResoureBreak = NO;
                    exMessage.alarmHeight = cellHeight;
                }else if ([exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_DOWN_SUCESS){
                
                    // 如果声音文件不存在，返回
                    if (![self hasFile:exMessage.messageModel.filePath]) {
                        cellHeight = [CalculateCellHeight heightOfBreakSoundAlarmCell];
                        exMessage.isResoureBreak = YES;
                    }else{
                        NSString *pcmPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"1.wav"];
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        if ([fileManager fileExistsAtPath:pcmPath]) {
                            [fileManager removeItemAtPath:pcmPath error:nil];
                            pcmPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"2.wav"];
                        }
                
                        int succeed = [TPCMToAMR doConvertAMRFromPath:exMessage.messageModel.filePath toPCMPath:pcmPath];
                        // 返回值如果小于零，则转换不成功，不做任何操作
                        if (succeed <= 0) {
                            cellHeight = [CalculateCellHeight heightOfBreakSoundAlarmCell];
                            exMessage.isResoureBreak = YES;
                        }else{
                            cellHeight = [CalculateCellHeight heightOfSoundAlarmCell : [exMessage.messageModel.isAlarmHidden boolValue]];
                            exMessage.isResoureBreak = NO;
                        }
                    }
                    exMessage.alarmHeight = cellHeight;
                }else if ([exMessage.messageModel.sendState intValue] == MSG_SEND_STATE_DOWN_ERROR){
                    cellHeight = [CalculateCellHeight heightOfBreakSoundAlarmCell];
                    exMessage.isResoureBreak = YES;
                    exMessage.alarmHeight = cellHeight;
                }
            }
            break;
        case MSG_CONTENT_TYPE_ALARMED_AUDIO:
            cellHeight = [CalculateCellHeight heightOfSoundAlarmedCell];
            break;
            // 如果是图片消息
        case MSG_CONTENT_TYPE_IMG:{
                UIImage *userImage = [exMessage getUserImage];
                cellHeight = [CalculateCellHeight heightOfImageCell:userImage];
            }
            break;
            // 如果是魔法表情消息
        case MSG_CONTENT_TYPE_MAGIC:{
                cellHeight = [CalculateCellHeight heightOfMagicExpressionCell];
            }
            break;
            // 如果是声音消息
        case MSG_CONTENT_TYPE_AUDIO:{
                cellHeight = [CalculateCellHeight heightOfSoundCell];
            }
            break;
            // 如果是视频消息
        case MSG_CONTENT_TYPE_VIDEO:{
                //cellHeight = [CalculateCellHeight heightOfVideoCell];
                UIImage *userImage = [exMessage getUserVideoImage];
                cellHeight = [CalculateCellHeight heightOfVideoCell:userImage];
            }
            break;
            // 如果是传情消息
        case MSG_CONTENT_TYPE_CQ:{
            switch ([exMessage.messageModel.flag intValue]) {
                case MSG_FLAG_SEND:{
                    cellHeight = [CalculateCellHeight heightOfMagicExpressionCell];
                }
                    break;
                case MSG_FLAG_RECEIVE:{
                    CPUIModelPetFeelingAnim *anim = [[CPUIModelManagement sharedInstance] feelingObjectOfID:exMessage.messageModel.magicMsgID fromPet:exMessage.messageModel.petMsgID];

                    
                    NSData *data = [NSData dataWithContentsOfFile:anim.thumbNail];
                    UIImage *image;
                    if ([anim isAvailable]) {
                        image= [[UIImage alloc] initWithData:data];
                    }else {
                        
                        image = [[UIImage alloc] initWithData:data];
                        
                        if (!image) {
                            image= [UIImage imageNamed:@"xiazai_QP@2x.gif"];
                        } 
                    }
                    
                    cellHeight = [CalculateCellHeight heightOfMagicExpressionCell:image text:anim.receiverDesc];
                }
                    break;    
                default:
                    break;
            }
            //                if (nil == [self.exModelDictionary objectForKey:exMessage.messageModel.msgID]) {
            //                    [self.exModelDictionary setObject:exMessage forKey:exMessage.messageModel.msgID];
            //                }
            }
            break;
            // 如果是传声消息
        case MSG_CONTENT_TYPE_CS:{
                cellHeight = [CalculateCellHeight heightOfMagicExpressionCell];
            }
            break;
            // 如果是偷偷问、答消息
        case MSG_CONTENT_TYPE_TTD:{
            
//            MSG_FLAG_SEND = 1,//发送方
//            MSG_FLAG_RECEIVE = 2,//接收方
            
            UIImage *image = [UIImage imageNamed:@"toutouwen_QP@2x.gif"];
            NSString *desc;
            
            if (MSG_FLAG_SEND == [exMessage.messageModel.flag intValue]) {
                desc = @"小双已经捎去你的回答啦";
                
            }else if (MSG_FLAG_RECEIVE == [exMessage.messageModel.flag intValue]){
                desc = @"小双喊你快来收偷偷问的答案";
            }
            
             cellHeight = [CalculateCellHeight heightOfMagicExpressionCell:image text:desc];
            
            
        }
            break;
        case MSG_CONTENT_TYPE_TTW:{
            
            UIImage *image = [UIImage imageNamed:@"toutouwen_QP@2x.gif"];
            NSString *desc;
            
            if (MSG_FLAG_SEND == [exMessage.messageModel.flag intValue]) {
                desc = @"小双已经匿名去偷偷打听啦";
                
                
            }else if (MSG_FLAG_RECEIVE == [exMessage.messageModel.flag intValue]){
                desc = @"有好友托小双偷偷提问哦";
            }
            
                cellHeight = [CalculateCellHeight heightOfMagicExpressionCell:image text:desc];
            }
            break;
        default:
            if ([exMessage.messageModel isSysDefault]) {
                // 如果是系统消息
                cellHeight = [CalculateCellHeight heightOfSystemTextCell];
                cellHeight = [CalculateCellHeight heightOfSystemTextCell:exMessage.messageModel.msgText];
            }else if ([exMessage.messageModel isSysSpecial]) {
                // 如果是系统跳转消息
                //cellHeight = [CalculateCellHeight heightOfSystemTextActionCell];
                
                cellHeight = [CalculateCellHeight heightOfSystemTextActionCell:exMessage.messageModel.msgText];
            }
            break;
    }
    //CPLogInfo(@"cellHeight : %f",cellHeight);
    return cellHeight;
}

#pragma mark - Table view delegate

// 根据工厂构造cell对象
-(ChatInforCellBase *) createMessageCell : (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *singleSmallExpressionCell = @"singleSmallExpressionCell";
    static NSString *singleMagicExpressionCell = @"singleMagicExpressionCell";
    static NSString *singleSoundCell = @"SingleSoundCell";
    static NSString *singleImageCell = @"SingleImageCell";
    static NSString *singleVideoCell = @"SingleVideoCell";
    static NSString *singleSystemTextCell = @"SingleSystemTextCell";
    static NSString *singleSystemTextActionCell = @"singleSystemTextActionCell";
    static NSString *singleLoveExpressionCell = @"singleLoveExpressionCell";
    static NSString *singleSoundExpressionCell = @"singleSoundExpressionCell";
    static NSString *singleAskExpressionCell = @"singleAskExpressionCell";
    static NSString *singleSystemUnknowCell = @"singleSystemUnknowCell";
    static NSString *singleTextAlarmCell = @"singleTextAlarmCell";
    static NSString *singleTextAlarmedCell = @"singleTextAlarmedCell";
    static NSString *singleSoundAlarmCell = @"singleSoundAlarmCell";
    static NSString *singleSoundAlarmedCell = @"singleSoundAlarmedCell";
    
    static NSString *groupSmallExpressionCell = @"groupSmallExpressionCell";
    static NSString *groupMagicExpressionCell = @"groupMagicExpressionCell";
    static NSString *groupSoundCell = @"groupSoundCell";
    static NSString *groupImageCell = @"groupImageCell";
    static NSString *groupVideoCell = @"groupVideoCell";
    static NSString *groupSystemTextCell = @"groupSystemTextCell";
    static NSString *groupSystemTextActionCell = @"groupSystemTextActionCell";
    static NSString *groupLoveExpressionCell = @"groupLoveExpressionCell";
    static NSString *groupSoundExpressionCell = @"groupSoundExpressionCell";
    static NSString *groupAskExpressionCell = @"groupAskExpressionCell";
    static NSString *groupSystemUnknowCell = @"groupSystemUnknowCell";
    
    // 获取聊天数据
    ExMessageModel *exMessage = [self.exMessageModelArray objectAtIndex:indexPath.section];
    ChatInforCellBase * base = nil;
    
    // 获取是否是自己发送得消息
    BOOL isBelongMe = [exMessage.messageModel.flag intValue] == MSG_FLAG_SEND ? YES : NO;
    //BOOL isBelongMe = YES;
    //CPLogInfo(@"消息的类型为:%d",[exMessage.messageModel.contentType intValue]);
    // 构造cell
    switch ([exMessage.messageModel.contentType intValue]) 
    {
        case MSG_CONTENT_TYPE_UNKNOWN:
        {
            //如果是未知的消息－升级消息
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSystemUnknowCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSystemUnknowCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if ( nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageUnKnown
                                                                              isBelongMe:isBelongMe 
                                                                          isGroupMessage:self.isGroupMessageTable 
                                                                                 withKey:groupSystemUnknowCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageUnKnown 
                                                                              isBelongMe:isBelongMe 
                                                                          isGroupMessage:self.isGroupMessageTable 
                                                                                 withKey:singleSystemUnknowCell];
                }
            }
        }
            break;
            // 如果是图文混排信息
        case MSG_CONTENT_TYPE_TEXT:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSmallExpressionCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSmallExpressionCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if ( nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSmallExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSmallExpressionCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSmallExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSmallExpressionCell];
                }
            }
            break;
            // 如果是图片消息
        case MSG_CONTENT_TYPE_IMG:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupImageCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleImageCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageImage isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupImageCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageImage isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleImageCell];
                }
            }
            break;
            // 如果是魔法表情消息
        case MSG_CONTENT_TYPE_MAGIC:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupMagicExpressionCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleMagicExpressionCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageMagicExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupMagicExpressionCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageMagicExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleMagicExpressionCell];
                }
            }
            break;
            // 如果是声音消息
        case MSG_CONTENT_TYPE_AUDIO:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSoundCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSoundCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSound isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSoundCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSound isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSoundCell];
                }
            }
            break;
            // 如果是视频消息
        case MSG_CONTENT_TYPE_VIDEO:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupVideoCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleVideoCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageVideo isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupVideoCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageVideo isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleVideoCell];
                }
            }
            break;
            // 如果是传情消息
        case MSG_CONTENT_TYPE_CQ:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupLoveExpressionCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleLoveExpressionCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageLoveExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupLoveExpressionCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageLoveExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleLoveExpressionCell];
                }
            }
            break;
            // 如果是传声消息
        case MSG_CONTENT_TYPE_CS:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSoundExpressionCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSoundExpressionCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSoundExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSoundExpressionCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSoundExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSoundExpressionCell];
                }
            }
            break;
            // 如果是偷偷问、答消息
        case MSG_CONTENT_TYPE_TTD:
        case MSG_CONTENT_TYPE_TTW:
            if (self.isGroupMessageTable) {
                // 从队列里取得群组类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupAskExpressionCell];
            }else {
                // 从队列里取得单聊类型对象
                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleAskExpressionCell];
            }
            // 队列里未存在此类型对象，则创建此类型对象
            if (nil == base) {
                if (self.isGroupMessageTable) {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageAskExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupAskExpressionCell];
                }else {
                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageAskExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleAskExpressionCell];
                }
            }
            break;
        case MSG_CONTENT_TYPE_ALARM_TEXT:
              // 如果是闹钟未提醒类型
              base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleTextAlarmCell];
              if ( nil == base) {
                  base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageTextAlarmExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleTextAlarmCell];
              }
              break;
        case MSG_CONTENT_TYPE_ALARMED_TEXT:
              // 如果是闹钟未提醒类型
              base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleTextAlarmedCell];
              if ( nil == base) {
                  base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageTextAlarmedExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleTextAlarmedCell];
              }
              break;
        case MSG_CONTENT_TYPE_ALARM_AUDIO:
            // 如果是语音闹钟未提醒类型
            base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSoundAlarmCell];
            if ( nil == base ) {
                base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSoundAlarmExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSoundAlarmCell];
            }
            break;
        case MSG_CONTENT_TYPE_ALARMED_AUDIO:
            // 如果是语音闹钟已提醒类型
            base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSoundAlarmedCell];
            if ( nil == base) {
                base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSoundAlarmedExpression isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSoundAlarmedCell];
            }
            break;
//        case MSG_CONTENT_TYPE_SYS:
//            if (self.isGroupMessageTable) {
//                // 从队列里取得群组类型对象
//                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSystemTextCell];
//            }else {
//                // 从队列里取得单聊类型对象
//                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSystemTextCell];
//            }
//            // 队列里未存在此类型对象，则创建此类型对象
//            if (nil == base) {
//                if (self.isGroupMessageTable) {
//                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemText isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSystemTextCell];
//                }else {
//                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemText isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSystemTextCell];
//                }
//                
//            }
//            break;
//            // 如果是系统跳转消息
//        case MSG_CONTENT_TYPE_SYS_SPECIAL:
//            if (self.isGroupMessageTable) {
//                // 从队列里取得群组类型对象
//                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSystemTextActionCell];
//            }else {
//                // 从队列里取得单聊类型对象
//                base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSystemTextActionCell];
//            }
//            // 队列里未存在此类型对象，则创建此类型对象
//            if (nil == base) {
//                if (self.isGroupMessageTable) {
//                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemTextAction isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSystemTextActionCell];
//                }else {
//                    base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemTextAction isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSystemTextActionCell];
//                }
//                
//            }
//            break;
        default:
            if ([exMessage.messageModel isSysDefault]) {
                // 如果是系统消息
                if (self.isGroupMessageTable) {
                    // 从队列里取得群组类型对象
                    base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSystemTextCell];
                }else {
                    // 从队列里取得单聊类型对象
                    base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSystemTextCell];
                }
                // 队列里未存在此类型对象，则创建此类型对象
                if (nil == base) {
                    if (self.isGroupMessageTable) {
                        base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemText isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSystemTextCell];
                    }else {
                        base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemText isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSystemTextCell];
                    }
                    
                }
            }else if ([exMessage.messageModel isSysSpecial]) {
                // 如果是系统跳转消息
                if (self.isGroupMessageTable) {
                    // 从队列里取得群组类型对象
                    base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:groupSystemTextActionCell];
                }else {
                    // 从队列里取得单聊类型对象
                    base = (ChatInforCellBase *)[tableView dequeueReusableCellWithIdentifier:singleSystemTextActionCell];
                }
                // 队列里未存在此类型对象，则创建此类型对象
                if (nil == base) {
                    if (self.isGroupMessageTable) {
                        base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemTextAction isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:groupSystemTextActionCell];
                    }else {
                        base = [[MessageCellFactory sharedInstance] createMessageCellFactory:UISingleMultiMessageSystemTextAction isBelongMe:isBelongMe isGroupMessage:self.isGroupMessageTable withKey:singleSystemTextActionCell];
                    }
                    
                }
            }else {
                CPLogInfo(@"message type is not available");
                break;
            }
            break;
    }

    if ( nil == base) {
        return nil;
    }
    
//    if (self.isGroupMessageTable) {
//        base.userHeadImage = [self getUserHeadImage:exMessage.messageModel.msgSenderName];
//    }else if ([exMessage.messageModel.contentType intValue] == MSG_CONTENT_TYPE_ALARMED_AUDIO){
//        base.userHeadImage = [self getuserHeadImageWithShuangShuang:exMessage.messageModel.msgSenderName];
//    }
    base.userHeadImage = [self getUserHeadImage:exMessage.messageModel.msgSenderName];
    base.isBelongMe = isBelongMe;
    [base setData:exMessage];
//    CPLogInfo(@"exMessage.isPlayAnimation is %@",exMessage.isPlayAnimation ? @"YES" : @"NO");
    return base;
}

// 沉淀在小双里的闹钟取头像
-(UIImage *) getuserHeadImageWithShuangShuang : (NSString *) userName{
    UIImage *image = nil;
    CPUIModelUserInfo *userInfor = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:userName];
    
    // 如果取得路径失败，返回默认头像
    if ( nil == userInfor) {
        image = [UIImage imageNamed:@"group_man.png"];
        return image;
    }
    
    if (nil == userInfor.headerPath || [userInfor.headerPath isEqualToString:@""]) {
        image = [UIImage imageNamed:@"group_man.png"];
        return image;
    }
    image = [UIImage imageWithContentsOfFile:userInfor.headerPath];
    return image;
}

// 群组聊天时获得用户头像
-(UIImage *) getUserHeadImage : (NSString *)userName{
    //NSLog(@"%@",userName);
    UIImage *image = nil;
    
    NSString *userHeadImagePath = [self.messageGroup getMemHeaderWithName:userName];
    
    // 如果取得路径失败，返回默认头像
    if ( nil == userHeadImagePath || [userHeadImagePath isEqualToString:@""]) {
        image = [UIImage imageNamed:@"group_man.png"];
        return image;
    }
    
    image = [UIImage imageWithContentsOfFile:userHeadImagePath];
    return image;
}

#pragma mark - 文本消息中的时间分析、及实现
// 分析是否有日期
-(BOOL) analysisDate:(NSString *)text{
    return YES;
}

// 点击闹钟标示，发送闹钟
-(void) clickedAlarmTip:(id)sender{
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    self.alarmMessageModel = (ExMessageModel*)sender;
    if ( nil != self.datepicker) {
        [self.datepicker closeInView];
    }
    
    
    self.datepicker = [[AlarmDatePickerView alloc] initWithFrame:CGRectMake(0, 460, 320, 460)];
    [self.datepicker setTitle:@"闹闹：把这句话设个时间定时提醒Ta"];
    [self.datepicker setDateMode:UIDatePickerModeDateAndTime];
    //    [datepicker setDate:self.alarmMessageModel.alarmDate];
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSLog(@"%@",[dateFormatter stringFromDate:self.alarmMessageModel.alarmDate]);
    self.datepicker.delegate =self;
    [self.datepicker showInView:[UIApplication sharedApplication].keyWindow];
    [self.datepicker setDate:self.alarmMessageModel.alarmDate];
}

-(void)datePickerDidPickedDate:(NSDate*) date{
    
//     ExMessageModel *exModel = (ExMessageModel*)sender;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
     
//     NSDate *date = [NSDate date];
//     date = [date dateByAddingTimeInterval:20];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSLog(@"alarm time 转换前: %@",dateStr);
    date = [dateFormatter dateFromString:dateStr];
    NSLog(@"alarm time 转换过: %@",dateStr);
    
    NSComparisonResult result = [date compare:[NSDate date]];
    if (result == NSOrderedAscending) {
        [[HPTopTipView shareInstance] showMessage:@"时光不能倒流，不能对历史时间设提醒"];
        return;
    }
    
    // 发送文字闹钟
    CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
    [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARM_TEXT]];
    [message setMsgText:self.alarmMessageModel.messageModel.msgText];
    NSNumber *dateNumber = [NSNumber numberWithLongLong:[date timeIntervalSince1970] * 1000];
    [message setAlarmTime: dateNumber];
    [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.messageGroup andMsg:message];
    
    
    // 发送小双闹钟
    /*
    CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
    [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARM_AUDIO]];
    [message setMsgText:self.alarmMessageModel.messageModel.msgText];
    [message setFilePath: [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"1.wav"]];
    [message setPetMsgID:@"pet_default"];
    [message setIsAlarmHidden:[NSNumber numberWithBool:YES]];
    NSNumber *dateNumber = [NSNumber numberWithLongLong:[date timeIntervalSince1970] * 1000];
    [message setAlarmTime: dateNumber];
    [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.messageGroup andMsg:message];
    */
}

#pragma mark - 小双闹钟的点击实现 -- 废弃
-(void) clickedSoundAlarmTip : (id)sender{
//    self.canPlayMagic = NO;
//    SingleSoundAlarmCell *soundAlarmCell = (SingleSoundAlarmCell *)sender;
//    ExMessageModel *exModel = (ExMessageModel *)soundAlarmCell.data;
//    
//    if ([exModel.messageModel.isAlarmHidden boolValue] == YES) {
//        NSNumber *alarmTime = exModel.messageModel.alarmTime;
//        NSNumber *currentTime = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
//        if ([alarmTime longLongValue] > [currentTime longLongValue]) {
//            [[HPTopTipView shareInstance] showMessage:@"啊哦时间还没到，神秘就快揭晓啦"];
//            self.canPlayMagic = YES;
//            return;
//        }
//    }
    
//    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
//        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS) {
//            CPLogInfo(@"音频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
//            self.canPlayMagic = YES;
//            return;
//        }
//    }
//    
//    // 如果声音文件不存在，返回
//    if (![self hasFile:exModel.messageModel.filePath]) {
//        CPLogInfo(@"本地不存在音频文件，返回。音频文件为:%@",exModel.messageModel.filePath);
//        self.canPlayMagic = YES;
//        return;
//    }
    
    // 验证动画是否存在
//    CPUIModelPetActionAnim *soundExpression = [[CPUIModelManagement sharedInstance] actionObjectOfID:@"shuohua"];
//    if ( nil == soundExpression) {
//        self.canPlayMagic = YES;
//        return;
//    }
//    
//    [self stopSound];
//    
//    // 加载播放管理
//    MessageSoundExpressionViewController *sound = [[MessageSoundExpressionViewController alloc] initWithPetResID:@"shuohua" withPetID:exModel.messageModel.petMsgID withSoundPath:exModel.messageModel.filePath];
//    self.messageExpressionViewController = sound;
//    self.messageExpressionViewController.delegate = self;
//    sound = nil;
//    // 播放管理不成功 返回
//    if ( nil == self.messageExpressionViewController) {
//        self.canPlayMagic = YES;
//        return;
//    }
//    
//    [MediaStatusManager sharedInstance].isAudioPlaying = YES;
//    // 调用委托关闭键盘
//    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
//        [self.delegate clickedMessageCell];
//    }
//    
//    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

#pragma mark - 加载历史消息的机制
// 加载历史消息数据
-(void) loadHistoryMessageData : (CPUIModelMessageGroup *) modelMessageGroup{
    self.isHistory = YES;
    CGSize oldSize = self.messageTable.contentSize;
    self.messageGroup = modelMessageGroup;
    [self refreshMessageModel];
    [self.activityIndicator removeFromSuperview];
    [self.messageTable reloadData];
    CGSize newSize = self.messageTable.contentSize;
    
    CGPoint point = self.messageTable.contentOffset;
    point.y = newSize.height - oldSize.height;
    self.messageTable.contentOffset = point;
    self.isNotificationLoadMessage = NO;
    self.isHistory = NO;
}

-(void) loadHIstoryMessageDataIsNull{
    self.hasHistoryMessageData = NO;
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    self.messageTable.tableHeaderView = nil;
}

// 当用户拖动tableview时的处理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
//    if (self.messageTable.contentOffset.y < 0.0f && self.messageTable.contentSize.height > self.messageTable.frame.size.height) {
    if (self.messageTable.contentOffset.y < 0.0f) {
        if (self.isNotificationLoadMessage) {
            return;
        }
        self.isNotificationLoadMessage = YES;
        [self.loadHeaderView addSubview:self.activityIndicator];
    }
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (!self.hasHistoryMessageData) {
        return;
    }
    if (self.isNotificationLoadMessage) {
        // 通知刷新数据事件
        [[CPUIModelManagement sharedInstance] getMsgListByPageWithMsgGroup:self.messageGroup];
    }
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.delegate respondsToSelector:@selector(movedMessageTableView:)]) {
        [self.delegate movedMessageTableView:self.messageTable];
    }
}
#pragma mark - 点击图片时的处理
// 展示大图
-(void)imageCellTaped:(id)sender{
    
    SingleImageCell *imageCell = (SingleImageCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)imageCell.data;
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS) {
            CPLogInfo(@"图片文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:exModel.messageModel.filePath];
    if (nil == image) {
        CPLogInfo(@"图片转换失败，图片地址为：%@",exModel.messageModel.filePath);
        return;
    }
    
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    float height = 0.0f;
    if (isIPhone5) {
        height = 568.0f;
    }else{
        height = 480.0f;
    }
    
    CGRect imageRect = imageCell.displayImageView.frame;
    CGRect superViewRect = [imageCell convertRect:imageRect toView:nil];
    self.messagePictrueController = [[MessagePictrueViewController alloc] initWithPictruePath:exModel.messageModel.filePath withRect:superViewRect];
    self.messagePictrueController.delegate = self;
    self.messagePictrueController.view.frame = CGRectMake(0.0f, 0.0f, 320.0f, height);
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication].keyWindow addSubview:self.messagePictrueController.view];
    self.canPlayMagic = NO;
}

#pragma 展示图片的委托实现开始
-(void)beganCloseImageAnimation{
//    [[HPStatusBarTipView shareInstance] setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; 
}
-(void)endCloseImageAnimation{
    [self.messagePictrueController.view removeFromSuperview];
    [self.messagePictrueController removeFromParentViewController];
    self.canPlayMagic = YES;
    CPLogInfo(@"endCloseImageAnimation");
}

#pragma mark - 展示图片的委托实现结束

// 展示视频
-(void) videoCellTaped:(id)sender{
    SingleVideoCell *videoCell = (SingleVideoCell *)sender;
    
    ExMessageModel *exModel = (ExMessageModel *)videoCell.data;
    if (![UIImage imageWithContentsOfFile:exModel.messageModel.thubFilePath]) {
        return;
    }
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        // 如果发送状态不等于安全或不等于已读返回
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS ) {
            CPLogInfo(@"视频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            return;
        }
    }
    
    if (![self hasFile:exModel.messageModel.filePath]) {
        return;
    }
    
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    [self stopSound];
    
    CGRect imageRect = videoCell.displayImageView.frame;
    CGRect superViewRect = [videoCell convertRect:imageRect toView:nil];
    self.messageVideoController = [[MessageVideoViewController alloc] initWithVideoPath:exModel.messageModel.filePath withImagePath:exModel.messageModel.thubFilePath withRect:superViewRect];
    self.messageVideoController.delegate = self;
    [self.messageVideoController.view setFrame:CGRectMake(0.f, 0.f, 320.f, 480.f)];
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageVideoController.view];
    self.canPlayMagic = NO;
    [MediaStatusManager sharedInstance].isVideoPlaying = YES;
//    if ([self.delegate respondsToSelector:@selector(clickVideoToPlayMessage:withPictrueInViewRect:)]) {
//        [self stopSound];
//        CGRect imageRect = videoCell.displayImageView.frame;
//        CGRect superViewRect = [videoCell convertRect:imageRect toView:nil];
//        [self.delegate clickVideoToPlayMessage:videoCell withPictrueInViewRect:superViewRect];
//    }
}

#pragma 展示视频的委托实现开始

-(void) beganOpenVideoAnimation{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

-(void) beganCloseVideoAnimation{
    [[HPStatusBarTipView shareInstance] setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
-(void) endCloseVideoAnimation{
    self.canPlayMagic = YES;
    [MediaStatusManager sharedInstance].isVideoPlaying = NO;
    CPLogInfo(@"endCloseVideoAnimation");
}

#pragma mark - 下载视频

// 下载视频
-(void) downloadVideo:(id)sender{
    
    SingleVideoCell *videoCell = (SingleVideoCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)videoCell.data;
    switch ([self getCurrentNetworkState]) {
        case NotReachable:{
                // 无网的情况
                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                return;
            }
            break;
        case ReachableViaWiFi:{
                // wifi的情况
                [[CPUIModelManagement sharedInstance] downloadResourceWithMsg:exModel.messageModel];
            }
            break;
        case ReachableViaWWAN:{
                // 3g的情况
                // 取得视频大小
                float size = [exModel.messageModel.fileSize floatValue] / 1024.0f;
                if (size < 1.0f) {
                    // 如果小于1.0mb
                    [[CPUIModelManagement sharedInstance] downloadResourceWithMsg:exModel.messageModel];
                    return;
                }
                NSString *tipStr = [NSString stringWithFormat:@"共%.1fM，你处于非wifi环境，现在下载么？",size];
                CustomAlertView *custom = [[CustomAlertView alloc] init];
                MessageBoxView *messageboxView = [custom showMessageBox:tipStr withButtonType:DownLoadingSource withContext:exModel];
                messageboxView.delegate = self;
            }
            break;
        default:
            break;
    }
}

// 当键盘发送魔法表情的时候，调用此方法，播放魔法表情
//-(void) firstSendMagicMessageWithID : (NSString *) resID{
//    
//}

#pragma mark - 展示魔法表情

// 当键盘发送魔法表情的时候，调用此方法，播放魔法表情
-(void) firstSendMagicMessageWithID : (NSString *) resID withPetID : (NSString *) petID{
//    
    // 验证魔法表情动画,如果返回NO return
    if (![self checkMagicOrFeelingAnimationWithResID:resID withPetID:petID withType:MSG_CONTENT_TYPE_MAGIC]) {
        self.canPlayMagic = YES;
        return;
    }
    
    if (!self.canPlayMagic) {
        self.canPlayMagic = YES;
        return;
    }
    
    
    self.canPlayMagic = NO;
    [MediaStatusManager sharedInstance].isAudioPlaying = YES;
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    [self stopSound];
    MessagePetViewController *petView = [[MessagePetViewController alloc] initWithPetResID:resID withPetID:petID];
    self.messageExpressionViewController = petView;
    self.messageExpressionViewController.delegate = self;
    petView = nil;
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

-(void)magicExpressionCellTaped:(id)sender{
    SingleMagicExpressionCell *magicCell = (SingleMagicExpressionCell *)sender;
    
    ExMessageModel *exModel = (ExMessageModel *)magicCell.data;
    if (exModel.animationsState != AnimationSucceed) {
        // 下载动画
        if (exModel.animationsState == AnimationInvalidate) {
            [self downloadAnimation:exModel withType:[exModel.messageModel.contentType intValue]];
        }else if (exModel.animationsState == AnimationDownloadingError) {
            [self downloadAnimation:exModel withType:[exModel.messageModel.contentType intValue]];
        }
        return;
    }
    [self firstSendMagicMessageWithID : exModel.messageModel.magicMsgID withPetID:exModel.messageModel.petMsgID];
}

// 当用户接受到魔法表情消息时，播放魔法表情
-(void) playMagicResID : (NSString *) resID withPetID : (NSString *) petID{
    // 验证魔法表情动画,如果返回NO return
    if (![self checkMagicOrFeelingAnimationWithResID:resID withPetID:petID withType:MSG_CONTENT_TYPE_MAGIC]) {
        return;
    }
    
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    
    [self stopSound];
    MessagePetViewController *petView = [[MessagePetViewController alloc] initWithPetResID:resID withPetID:petID];
    self.messageExpressionViewController = petView;
    self.messageExpressionViewController.delegate = self;
    petView = nil;
//    self.messageExpressionViewController = [[MessagePetViewController alloc] initWithPetResID:resID withPetID:petID];
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

#pragma mark - 展示传情
// 加载传情View
-(void)loveExpressionCellTaped:(id)sender{
    self.canPlayMagic = NO;
    SingleLoveExpressionCell *loveExpressionCell = (SingleLoveExpressionCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)loveExpressionCell.data;
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS) {
            CPLogInfo(@"音频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            self.canPlayMagic = YES;
            return;
        }
    }
    
    // 如果声音文件不存在，返回
    if (![self hasFile:exModel.messageModel.filePath]) {
        self.canPlayMagic = YES;
        return;
    }
    
    if (exModel.animationsState != AnimationSucceed) {
        // 下载动画
        if (exModel.animationsState == AnimationInvalidate) {
            [self downloadAnimation:exModel withType:[exModel.messageModel.contentType intValue]];
        }else if (exModel.animationsState == AnimationDownloadingError) {
            [self downloadAnimation:exModel withType:[exModel.messageModel.contentType intValue]];
        }
        self.canPlayMagic = YES;
        return;
    }
    
    // 验证传情动画,如果返回NO return
    if (![self checkMagicOrFeelingAnimationWithResID:exModel.messageModel.magicMsgID withPetID:exModel.messageModel.petMsgID withType:MSG_CONTENT_TYPE_CQ]) {
        self.canPlayMagic = YES;
        return;
    }
    [self stopSound];
    MessageLoveExpressionViewController *love = [[MessageLoveExpressionViewController alloc] initWithPetResID:exModel.messageModel.magicMsgID withPetID:exModel.messageModel.petMsgID withSoundPath:exModel.messageModel.filePath];
    self.messageExpressionViewController = love;
    self.messageExpressionViewController.delegate = self;
    love = nil;
    if ( nil == self.messageExpressionViewController) {
        self.canPlayMagic = YES;
        return;
    }
    
    [MediaStatusManager sharedInstance].isAudioPlaying = YES;
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    CPLogInfo(@"---------------------------petid : %@",exModel.messageModel.magicMsgID);
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

#pragma mark - 下载魔法表情、传情
// 下载动画
-(void) downloadAnimation:(ExMessageModel *)exModel withType : (MsgContentType) contentType{
    
    CPLogInfo(@"download animation msgicMsgID = %@ \n petMsgID = %@",exModel.messageModel.magicMsgID,exModel.messageModel.petMsgID);
    
    float size = 0.0f;
    NSString *str = @"";
    if (contentType == MSG_CONTENT_TYPE_MAGIC) {
        // 如果没有取得此魔法表情
        CPUIModelPetMagicAnim *magic = [[CPUIModelManagement sharedInstance] magicObjectOfID:exModel.messageModel.magicMsgID fromPet:exModel.messageModel.petMsgID];
        size = [magic.size floatValue] / 1024.0f;
        str = [NSString stringWithFormat:@"该表情%.1fM，你处于非wifi环境，现在下载么？",size];
    }else if (contentType == MSG_CONTENT_TYPE_CQ) {
        CPUIModelPetFeelingAnim *petFeeling = [[CPUIModelManagement sharedInstance] feelingObjectOfID:exModel.messageModel.magicMsgID fromPet:exModel.messageModel.petMsgID];
        size = [petFeeling.size floatValue] / 1024.0f;
        str = [NSString stringWithFormat:@"该传情%.1fM，你处于非wifi环境，现在下载么？",size];
    }
    
    switch ([self getCurrentNetworkState]) {
        case NotReachable:{
            // 无网的情况
            [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
            return;
        }
            break;
        case ReachableViaWiFi:{
            // wifi的情况
            [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
        }
            break;
        case ReachableViaWWAN:{
            // 3g的情况
            CustomAlertView *custom = [[CustomAlertView alloc] init];
//            MessageBoxView *messageboxView = [custom showMessageBox:str withContext:exModel];
            MessageBoxView *messageboxView = [custom showMessageBox:str withButtonType:DownLoadingSource withContext:exModel];
            messageboxView.delegate = self;
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            NSString *allow = [defaults objectForKey:@"AnimationDownLoad"];
//            
//            if (allow == nil || [allow isEqualToString:@""] || [allow isEqualToString:@"RemindMe"]){
//                CustomAlertView *custom = [[CustomAlertView alloc] init];
//                CheckMessageView *checkMessage = [custom showCheckMessage:str withContext:exModel];
//                checkMessage.delegate = self;
//            }else {
//                [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
//                return;
//            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 展示双双闹钟
// 加载双双闹钟
-(void) alarmExpressionCellTaped:(id)sender{
    self.canPlayMagic = NO;
    ChatInforCellBase *ExpressionCell = (ChatInforCellBase *)sender;
    ExMessageModel *exModel = (ExMessageModel *)ExpressionCell.data;
    
    // 如果这是个神秘闹钟
    if ([exModel.messageModel.isAlarmHidden boolValue] == YES) {
        // 如果是接收方
        if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
            NSDate *date = [CoreUtils getDateFormatWithLong:exModel.messageModel.alarmTime];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
            
            NSLog(@"------------%@",[dateFormatter stringFromDate:date]);
            
            NSComparisonResult result = [date compare:[NSDate date]];
            // 如果还没有到时间
            if (result == NSOrderedDescending) {
                [[HPTopTipView shareInstance] showMessage:@"啊哦～还没到时间哦，别心急嘛"];
                self.canPlayMagic = YES;
                return;
            }
        }
    }
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS && [exModel.messageModel.sendState intValue] !=MSG_SEND_STATE_DEFAULT) {
            CPLogInfo(@"音频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            self.canPlayMagic = YES;
            return;
        }
    }
    
    // 如果声音文件不存在，返回
    if (![self hasFile:exModel.messageModel.filePath]) {
        CPLogInfo(@"本地不存在音频文件，返回。音频文件为:%@",exModel.messageModel.filePath);
        self.canPlayMagic = YES;
        return;
    }
    
    // 验证动画是否存在
    CPUIModelPetActionAnim *soundExpression = [[CPUIModelManagement sharedInstance] actionObjectOfID:@"shuohua"];
    if ( nil == soundExpression) {
        self.canPlayMagic = YES;
        return;
    }
    
    [self stopSound];
    
    // 加载播放管理
    MessageAlarmExpressionViewController *alarm = [[MessageAlarmExpressionViewController alloc] initWithExModel:exModel];
    self.messageExpressionViewController = alarm;
    self.messageExpressionViewController.delegate = self;
    // 播放管理不成功 返回
    if ( nil == self.messageExpressionViewController) {
        self.canPlayMagic = YES;
        return;
    }
    
    [MediaStatusManager sharedInstance].isAudioPlaying = YES;
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

#pragma mark - 展示传声
// 加载传声View
-(void)soundExpressionCellTaped:(id)sender{
    self.canPlayMagic = NO;
    SingleSoundExpressionCell *soundExpressionCell = (SingleSoundExpressionCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)soundExpressionCell.data;
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS) {
            CPLogInfo(@"音频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            self.canPlayMagic = YES;
            return;
        }
    }
    
    // 如果声音文件不存在，返回
    if (![self hasFile:exModel.messageModel.filePath]) {
        CPLogInfo(@"本地不存在音频文件，返回。音频文件为:%@",exModel.messageModel.filePath);
        self.canPlayMagic = YES;
        return;
    }
    
    // 验证动画是否存在
    CPUIModelPetActionAnim *soundExpression = [[CPUIModelManagement sharedInstance] actionObjectOfID:@"shuohua"];
    if ( nil == soundExpression) {
        self.canPlayMagic = YES;
        return;
    }
    
    [self stopSound];
    
    // 加载播放管理
    MessageSoundExpressionViewController *sound = [[MessageSoundExpressionViewController alloc] initWithPetResID:@"shuohua" withPetID:exModel.messageModel.petMsgID withSoundPath:exModel.messageModel.filePath];
    self.messageExpressionViewController = sound;
    self.messageExpressionViewController.delegate = self;
    sound = nil;
    // 播放管理不成功 返回
    if ( nil == self.messageExpressionViewController) {
        self.canPlayMagic = YES;
        return;
    }
    
    [MediaStatusManager sharedInstance].isAudioPlaying = YES;
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

#pragma mark - 展示偷偷问、偷偷答
// 加载偷偷问View
-(void) askExpressionCellTaped:(id)sender{
    self.canPlayMagic = NO;
    SingleAskExpressionCell *askExpressionCell = (SingleAskExpressionCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)askExpressionCell.data;
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS) {
            CPLogInfo(@"音频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            self.canPlayMagic = YES;
            return;
        }
    }
    
    if (![self hasFile:exModel.messageModel.filePath]) {
        CPLogInfo(@"本地不存在音频文件，返回。音频文件为:%@",exModel.messageModel.filePath);
        self.canPlayMagic = YES;
        return;
    }
    
    CPUIModelPetActionAnim *soundExpression = [[CPUIModelManagement sharedInstance] actionObjectOfID:@"shuohua"];
    if ( nil == soundExpression) {
        CPLogInfo(@"shuohua动画不存在");
        self.canPlayMagic = YES;
        return;
    }
    
    [self stopSound];
    MessageAskExpressionViewController *ask = [[MessageAskExpressionViewController alloc] initWithExModel:exModel];
    self.messageExpressionViewController = ask;
    self.messageExpressionViewController.delegate = self;
    ask = nil;
    if (nil == self.messageExpressionViewController) {
        CPLogInfo(@"偷偷问管理器未成功初始化");
        self.canPlayMagic = YES;
        return;
    }
    
    
    [MediaStatusManager sharedInstance].isAudioPlaying = YES;
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    self.messageExpressionViewController.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:self.messageExpressionViewController.view];
}

// 发送偷偷答消息
-(void) sendTTDMessage:(CPUIModelMessage *)msg{
    [[CPUIModelManagement sharedInstance] sendMsgWithGroup:self.messageGroup andMsg:msg];
}

-(void) closeMessageExpressionView{
    self.canPlayMagic = YES;
    [MediaStatusManager sharedInstance].isAudioPlaying = NO;
}

#pragma mark - 播放音频
// 播放声音
-(void)soundCellTaped:(id)sender{
    
    SingleSoundCell *soundCell = (SingleSoundCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)soundCell.data;

    if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        // 如果发送状态不等于安全或不等于已读返回
        if ([exModel.messageModel.sendState intValue] != MSG_SEND_STATE_DOWN_SUCESS && [exModel.messageModel.sendState intValue] != MSG_SEND_STATE_AUDIO_READED) {
            CPLogInfo(@"音频文件下载状态为：%d -- 返回",[exModel.messageModel.sendState intValue]);
            return;
        }
    }
    
    if (![self hasFile:exModel.messageModel.filePath]) {
        CPLogInfo(@"本地不存在音频文件，返回。音频文件为:%@",exModel.messageModel.filePath);
        return;
    }
    
    // 调用委托关闭键盘
    if ([self.delegate respondsToSelector:@selector(clickedMessageCell)]) {
        [self.delegate clickedMessageCell];
    }
    
    // 关闭用户语音
    if ([self.delegate respondsToSelector:@selector(clickedSoundMessage)]) {
        [self.delegate clickedSoundMessage];
    }
    
    if (exModel.isPlaySound) {
        [[MessageSoundPlayer sharedInstance] stopSound];
    }else {
        [[MessageSoundPlayer sharedInstance] playSound:soundCell];
    }
    
}

// 停止用户播放的语音
-(void) stopSound{
    if ([self.delegate respondsToSelector:@selector(stopUserSound)]) {
        [self.delegate stopUserSound];
    }
    [[MessageSoundPlayer sharedInstance] stopSound];
    
}

#pragma mark - 点击系统消息时的处理
// 如果点击的是系统消息
-(void) systemTextActionCellTaped:(id)sender{
    SingleSystemTextActionCell *systemActionCell = (SingleSystemTextActionCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)systemActionCell.data;
    AddContactAnalysis analysis = [[RelationshipBrain sharedInstance] getContactAnalysis:exModel];
    
    
    if ([exModel.messageModel.contentType integerValue]==MSG_CONTENT_TYPE_UNKNOWN)
    {
        NSURL *url = [NSURL URLWithString:@"http://s2.tl/dl.htm?fr=im"];
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    //地用系统消息
    if ([self.delegate respondsToSelector:@selector(clickedSystemActionMessage:withModel:)]) {
        [self.delegate clickedSystemActionMessage:analysis withModel:exModel];
    }
}

#pragma mark - 点击群头像的处理
// 如果是群聊，点击群聊头像事件
-(void) clickedAvatar:(id)userID{
    CPLogInfo(@"%@",userID);
    CPUIModelMessageGroupMember *member = [self.messageGroup getGroupMemWithName:userID];
    if (nil == member) {
        return;
    }
    if (nil != self.delegate && [self.delegate respondsToSelector:@selector(clickedUserHeadOfMessage:)]) {
        [self.delegate clickedUserHeadOfMessage:member];
    }
}

#pragma mark - 点击小表情的处理
// 小表情被点击
-(void)smallExpressionCellTaped:(id)sender{
    SingleSmallExpressionCell *smallCell = (SingleSmallExpressionCell *)sender;
    ExMessageModel *exModel = (ExMessageModel *)smallCell.data;
    exModel.isPlayAnimation = !exModel.isPlayAnimation;
}

// 文件是否存在
-(BOOL) hasFile:(NSString *)filePath{
    BOOL result = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    result = [fileManager fileExistsAtPath:filePath];
    
    return result;
}


#pragma mark - 下载魔法表情及传情前判断

-(void) clickConfirm : (BOOL) isChecked withContext:(id)context{
    
//    NSString *key = @"";
//    ExMessageModel *exModel = (ExMessageModel *)context;
//    if ([exModel.messageModel.contentType intValue] == MSG_CONTENT_TYPE_MAGIC) {
//        // 如果是魔法表情，则下载魔法表情
//        key = @"AnimationDownLoad";
//        [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
//    }else if ([exModel.messageModel.contentType intValue] == MSG_CONTENT_TYPE_CQ) {
//        // 如果是传情，则下载传情
//        key = @"AnimationDownLoad";
//        [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
//    }else if ([exModel.messageModel.contentType intValue] == MSG_CONTENT_TYPE_VIDEO) {
//        // 如果是视频，则下载视频
//        key = @"VideoDownLoad";
//        [[CPUIModelManagement sharedInstance] downloadResourceWithMsg:exModel.messageModel];
//    }
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if (isChecked) {
//        [defaults setObject:@"DoNotRemindMe" forKey:key];
//        [defaults synchronize];
//    }else {
//        [defaults setObject:@"RemindMe" forKey:key];
//        [defaults synchronize];
//    }
    
}

-(void) clickConfirm : (id)context{
    ExMessageModel *exModel = (ExMessageModel *)context;
    if ([exModel.messageModel.contentType intValue] == MSG_CONTENT_TYPE_MAGIC) {
        // 如果是魔法表情，则下载魔法表情
        [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
    }else if ([exModel.messageModel.contentType intValue] == MSG_CONTENT_TYPE_CQ) {
        // 如果是传情，则下载传情
        [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
    }else if ([exModel.messageModel.contentType intValue] == MSG_CONTENT_TYPE_VIDEO) {
        // 如果是视频，则下载视频
        [[CPUIModelManagement sharedInstance] downloadResourceWithMsg:exModel.messageModel];
    }
}

-(void) clickCancel:(id)context{
    
}


// 判断当前魔法表情或传情动画本地是否存在
-(BOOL) checkMagicOrFeelingAnimationWithResID:(NSString *)resID withPetID:(NSString *)petID withType : (MsgContentType) contentType{
    BOOL result = YES;
    
    if (contentType == MSG_CONTENT_TYPE_MAGIC) {
        // 如果没有取得此魔法表情
        CPUIModelPetMagicAnim *magic = [[CPUIModelManagement sharedInstance] magicObjectOfID:resID fromPet:petID];
        if ( nil == magic) {
            CPLogInfo(@"没有取得此魔法表情 resID : %@ --------- petID : %@",resID,petID);
            result = NO;
        }
        // 如果此魔法表情验证失败
        if(magic.isAvailable == NO){
            CPLogInfo(@"没有取得此魔法表情 resID : %@ --------- petID : %@",resID,petID);
            result = NO;
        }
    }else if (contentType == MSG_CONTENT_TYPE_CQ) {
        CPUIModelPetFeelingAnim *petFeeling = [[CPUIModelManagement sharedInstance] feelingObjectOfID:resID fromPet:petID];
        // 如果没有取得此传情
        if ( nil == petFeeling) {
            CPLogInfo(@"没有取得此传情 resID : %@ --------- petID : %@",resID,petID);
            result = NO;
        }
        // 如果此传情验证失败
        if(petFeeling.isAvailable == NO){
            CPLogInfo(@"没有取得此传情 resID : %@ --------- petID : %@",resID,petID);
            result = NO;
        }
    }
    
    return result;
}

// 判断魔法表情或传情动画状态
-(AnimationState) magicOrFeelingAnimationState : (NSString *) resID withPetID : (NSString *) petID withType : (MsgContentType) contentType{
    AnimationState state = AnimationSucceed;
    
    if (contentType == MSG_CONTENT_TYPE_MAGIC) {
        // 如果没有取得此魔法表情
        CPUIModelPetMagicAnim *magic = [[CPUIModelManagement sharedInstance] magicObjectOfID:resID fromPet:petID];
        if ( nil == magic) {
            state = AnimationInvalidate;
            return state;
        }
        // 如果此魔法表情验证失败
        if(magic.isAvailable == NO){
            state = AnimationInvalidate;
            return state;
        }
        // 如果是下载中
        if(magic.downloadStatus == K_PETRES_DOWNLOD_STATUS_DOWNLOADING){
            state = AnimationDownloading;
            return state;
        }
        
    }else if (contentType == MSG_CONTENT_TYPE_CQ) {
        CPUIModelPetFeelingAnim *petFeeling = [[CPUIModelManagement sharedInstance] feelingObjectOfID:resID fromPet:petID];
        // 如果没有取得此传情
        if ( nil == petFeeling) {
            state = AnimationInvalidate;
            return state;
        }
        // 如果此传情验证失败
        if(petFeeling.isAvailable == NO){
            state = AnimationInvalidate;
        }
        // 如果是下载中
        if(petFeeling.downloadStatus == K_PETRES_DOWNLOD_STATUS_DOWNLOADING){
            state = AnimationDownloading;
            return state;
        }
    }
    
    return state;
}

#pragma mark - 重新下载、重新发送
-(void) resendFailedMessage:(ChatInforCellBase *)sender{
//#warning 须判断是否有网，是否是用户登录状态
    if( ![[Reachability reachabilityForInternetConnection] isReachable] )
    {
        [[HPTopTipView shareInstance] showMessage:@"网络不可用,请检查网络!"];
        return;
    }
    
    CPLogInfo(@"重新发送");
    ExMessageModel *exModel = (ExMessageModel *)sender.data;
    [[CPUIModelManagement sharedInstance] reSendMsg:exModel.messageModel andMsgGroup:self.messageGroup];
    [self.messageTable reloadData];
}

-(void) reDownLoadFailedMessage:(id)sender{
//    #warning 须判断是否有网，是否是用户登录状态
    if( ![[Reachability reachabilityForInternetConnection] isReachable] )
    {
        [[HPTopTipView shareInstance] showMessage:@"网络不可用,请检查网络!"];
        return;
    }
    
    CPLogInfo(@"重新下载");
    ChatInforCellBase *messageBase = (ChatInforCellBase *)sender;
    ExMessageModel *exModel = (ExMessageModel *)messageBase.data;
    
    switch ([exModel.messageModel.contentType intValue]) {
        case MSG_CONTENT_TYPE_CQ:
            if (exModel.animationsState == AnimationDownloadingError) {
                [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
            }else if ([exModel.messageModel.sendState intValue] == MSG_SEND_STATE_DOWN_ERROR) {
                [[CPUIModelManagement sharedInstance] downloadResourceWithMsg:exModel.messageModel];
            }
            break;
        case MSG_CONTENT_TYPE_MAGIC:
            if (exModel.animationsState == AnimationDownloadingError) {
                [[CPUIModelManagement sharedInstance] downloadPetRes:exModel.messageModel.magicMsgID ofPet:exModel.messageModel.petMsgID];
            }
            break;
        default:
            [[CPUIModelManagement sharedInstance] downloadResourceWithMsg:exModel.messageModel];
            break;
    }
    [self.messageTable reloadData];
}

-(void) dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"petDataDict" context:@"MessageDetailViewController"];
}

@end