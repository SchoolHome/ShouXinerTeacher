//
//  HomeMainViewController.m
//  iCouple
//
//  Created by qing zhang on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeMainViewController.h"
#import "HomeInfo.h"
#import "HomePageSelfProfileViewController.h"
#import "AddContactViewController.h"
#import "HomePageViewController.h"
#import "SingleIMViewController.h"
#import "MutilIMViewController.h"
#import "XiaoShuangIMViewController.h"
#import "SystemIMViewController.h"
#import "ShuangShuangTeamViewController.h"
#import "AllFriendsViewController.h"
#import "CoupleBreakIcePageViewController.h"

#define CoupleBreakIcePageViewTag 90000
#define ActionSheetTag 89999
@interface HomeMainViewController ()
{
    BOOL swipeFlag;
}

@property (nonatomic , strong) UIScrollView *scrollMainView;
@property (nonatomic , strong) NSMutableArray *mutableArrViews;
@property (nonatomic , strong) UIPageControl *pageControl;
//@property (nonatomic , strong) CoupleIMViewController *coupleIMController;
@property (nonatomic ) BOOL needRemoveObserver;
@property (nonatomic , strong) NSString *userName;
@property (nonatomic , strong) NSString *actionsheetButtontitle;
//logo底图
@property (nonatomic , strong) UIImageView *imageviewBackground;
@end

@implementation HomeMainViewController
@synthesize  scrollMainView = _scrollMainView,
          mutableArrViews= _mutableArrViews,
          pageControl = _pageControl,
   needRemoveObserver = _needRemoveObserver,
//   coupleIMController = _coupleIMController,
             userName = _userName,
actionsheetButtontitle= _actionsheetButtontitle,
  imageviewBackground = _imageviewBackground,
needBreakIceWhenCoupleMessageGroupNil = _needBreakIceWhenCoupleMessageGroupNil;
          
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)init
{
    self = [super init];
    if (self) {
        UIImageView *imageviewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 160.f, 460)];
        [imageviewLeft setImage:[UIImage imageNamed:@"bg_close.png"]];
        [self.view addSubview:imageviewLeft];

//        UIImageView *imageviewRight = [[UIImageView alloc] initWithFrame:CGRectMake(160.f, 0.f, 160.f, 460)];
//        [imageviewRight setImage:[UIImage imageNamed:@"bg_close.png"]];
//        [self.view addSubview:imageviewRight];
        
        self.imageviewBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320.f, 194/2)];
        [self.imageviewBackground setImage:[UIImage imageNamed:@"bg_profileeeee.jpg"]];
        [self.view addSubview:self.imageviewBackground];
        
        self.scrollMainView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.scrollMainView.pagingEnabled = YES;
        self.scrollMainView.contentSize = CGSizeMake(self.scrollMainView.frame.size.width * self.mutableArrViews.count, self.scrollMainView.frame.size.height);
        self.scrollMainView.showsHorizontalScrollIndicator = NO;
        self.scrollMainView.showsVerticalScrollIndicator = NO;
        self.scrollMainView.scrollsToTop = NO;
        self.scrollMainView.delegate = self;
        [self.view addSubview:self.scrollMainView];
        
        for (int i = 0; i <self.mutableArrViews.count ; i++) {
            [self.scrollMainView addSubview:[self.mutableArrViews objectAtIndex:i]];            
        }
        
        switchButton = [FriendWallSwitchButton buttonWithType:UIButtonTypeCustom];
        [switchButton addTarget:self action:@selector(switchFriendWall:) forControlEvents:UIControlEventTouchUpInside];
        switchButton.hidden = YES;
        [self.scrollMainView addSubview:switchButton];
        
        UIButton *btnPeople = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPeople setFrame:CGRectMake(320.f-60.f, 0.f, 60.f, 60.f)];
        [btnPeople setBackgroundImage:[UIImage imageNamed:@"btn_people.png"] forState:UIControlStateNormal];
        [btnPeople setBackgroundImage:[UIImage imageNamed:@"btn_people_press.png"] forState:UIControlStateHighlighted];
        [btnPeople addTarget:self action:@selector(goPeopleController) forControlEvents:UIControlEventTouchUpInside];
        //self.btnPeopleAndDelete.tag = 90001;
        [self.view addSubview:btnPeople];
        
        UIButton *btnToHome = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnToHome setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.f)];
        [btnToHome setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_back.png"] forState:UIControlStateNormal];
        [btnToHome setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_backpress.png"] forState:UIControlStateHighlighted];
        [btnToHome addTarget:self action:@selector(goHomeController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnToHome];
    }
    return self;
}
-(void)breakIngIce
{
    //好友
    HomeFriendsView *friendview = [self.mutableArrViews objectAtIndex:0];
    
    BOOL friendIceBreak = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friendIceBreak"] boolValue];
    
    
    if (friendIceBreak) {
        [friendview endBreakIcePageView];
    }else {
        [friendview beginBreakIcePageView];
        
    }
    //蜜友
    
    HomeCloseFriendView *closefriendview = [self.mutableArrViews objectAtIndex:1];
    BOOL closeFriendIceBreak = [[[NSUserDefaults standardUserDefaults] objectForKey:@"closeFriendIceBreak"] boolValue];
    if (closeFriendIceBreak) {
        [closefriendview endBreakIcePageView];
        
    }else {
        [closefriendview beginBreakIcePageView];
        
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"userMsgGroupListTag"]) {
        [[HomeInfo shareObject] updateData];
        [self refreshData];
        

        
        HomeFriendsView *friendview = [self.mutableArrViews objectAtIndex:0];
    
        if ([HomeInfo shareObject].friendMessageArray.count == 0 && [HomeInfo shareObject].isDeletingInCell) {
            [friendview recoverDeletingStatus];
        }
        
        for (int i = 0;  i <[HomeInfo shareObject].friendMessageArray.count; i++) {
            CPUIModelMessageGroup *group = [[HomeInfo shareObject].friendMessageArray objectAtIndex:i];
            if ([group.msgGroupID integerValue] != [HomeInfo shareObject].deletedCellIndexRow && [HomeInfo shareObject].deletedCellIndexRow != -1)  {
                if (i == [HomeInfo shareObject].friendMessageArray.count -1) {
            
                    [friendview recoverDeletingStatus];
                }   
                
            }else {
            break;
            }
        }
        
        HomeCloseFriendView *closefriendview = [self.mutableArrViews objectAtIndex:1];


    
        for (int i = 0;  i <[HomeInfo shareObject].homeCloseMessageGroups.count; i++) {
            CPUIModelMessageGroup *group = [[HomeInfo shareObject].homeCloseMessageGroups objectAtIndex:i];
            if ([group.msgGroupID integerValue] != [HomeInfo shareObject].deletedCellIndexRow && [HomeInfo shareObject].deletedCellIndexRow != -1) {
                if (i == [HomeInfo shareObject].homeCloseMessageGroups.count -1) {
                   // HomeCloseFriendView *closefriendview = [self.mutableArrViews objectAtIndex:2];
                    [closefriendview beignChangeDeleteStatusFromCloseFriend:NO];
                }   
                
            }else {
                break;
            }
        }
        [self breakIngIce];
        [self refreshUnreadedNumber];
    }
//    else if([keyPath isEqualToString:@"coupleMsgGroupTag"])
//    {
//        switch ([CPUIModelManagement sharedInstance].coupleMsgGroupTag) {
//            case UPDATE_USER_GROUP_TAG_DEFAULT:{
//                CPUIModelMessageGroup *modelMessageGroup = [CPUIModelManagement sharedInstance].coupleMsgGroup;
//                if (modelMessageGroup) {
//                    if ([HomeInfo shareObject].coupleNeededBreakIce == COUPLEICEBREAK_STATUS_InIceBreak) {
//                        //[self changeCoupleNormalStatus];
//                        if (self.coupleIMController.isInCoupleImViewController) {
//                       // [self.coupleIMController getLoveMessage];    
//                        }
//                        
//                    }
//                }else {
//                    if ([HomeInfo shareObject].coupleNeededBreakIce == COUPLEICEBREAK_STATUS_InNormal) {
//                            [self changeCoupleBreakIceStatus];
//                    }
//                }
//            }
//        }
//    }

}

-(NSMutableArray *)mutableArrViews
{
    
    if (!_mutableArrViews) {

        _mutableArrViews = [[NSMutableArray alloc] initWithCapacity:3];
        for (int i = 0; i<2; i++) {
            
                switch (i+1) {
                    case home_viewcontrollers_friends:
                    {
                        
                       HomeFriendsView *friendView = [[HomeFriendsView alloc] initWithFrame:CGRectMake(320*i, 0, 320, 460) ];
                        friendView.homeMainViewDelegate = self;
                        [self.mutableArrViews addObject:friendView];
                    }
                        break;
//                    case home_viewcontrollers_couple:
//                    {
//                        [self changeCoupleIceBreak];
//                    }
//                        break;
                    case home_viewcontrollers_closefriend:
                    {
                      HomeCloseFriendView*  closeFriendView = [[HomeCloseFriendView alloc] initWithFrame:CGRectMake(320*i, 0, 320, 460) ];
                        closeFriendView.homeMainViewDelegate = self;
                        [self.mutableArrViews addObject:closeFriendView];
                    }
                        break;
                    default:
                        break;
                }
                
            }        

    }
   
    return _mutableArrViews;
}
-(void)changeCoupleIceBreak:(BOOL)isChanged
{

}
/*
//根据状态改变couple破冰,YES:进入破冰，NO:进入coupleIM
-(void)changeCoupleIceBreak:(BOOL)isChanged
{
    if (isChanged) {
        if (self.coupleIMController.view) {
            [self.coupleIMController.view removeFromSuperview];
        }
        if (![self.view viewWithTag:CoupleBreakIcePageViewTag]) {
            CoupleBreakIcePageView *coupleIceBreak = [[CoupleBreakIcePageView alloc] initWithFrame:CGRectMake(320, 0, 320, 460)];
            coupleIceBreak.tag = CoupleBreakIcePageViewTag;
            coupleIceBreak.coupleBreakIcePageViewDelegate = self;
            [self.scrollMainView addSubview:coupleIceBreak];
            if (self.mutableArrViews.count > 1) {
                [self.mutableArrViews replaceObjectAtIndex:1 withObject:coupleIceBreak];    
            }else {
                [self.mutableArrViews addObject:coupleIceBreak];
            }
        }
        [HomeInfo shareObject].coupleNeededBreakIce = COUPLEICEBREAK_STATUS_InIceBreak;
    }else {
        if ([self.view viewWithTag:CoupleBreakIcePageViewTag]) {
            [[self.view viewWithTag:CoupleBreakIcePageViewTag] removeFromSuperview];
        }

        //如果coupleImController不存在才生成
        if (self.scrollMainView.subviews.count == 2) {
            if (!self.coupleIMController) {
                self.coupleIMController = [[CoupleIMViewController alloc] init:[CPUIModelManagement sharedInstance].coupleMsgGroup ISNeedProfileStatus:self.coupleIMController.profileIsNeededSave];        
            }
            [self.coupleIMController.view setFrame:CGRectMake(320, 0, 320.f, 460.f)];
            self.coupleIMController.messageDelegate = self;
            [self.scrollMainView addSubview:self.coupleIMController.view];
            if (self.mutableArrViews.count > 1) {
                [self.mutableArrViews replaceObjectAtIndex:1 withObject:self.coupleIMController.view];    
            }else {
                [self.mutableArrViews addObject:self.coupleIMController.view];
            }            
        }
       
        [HomeInfo shareObject].coupleNeededBreakIce = COUPLEICEBREAK_STATUS_InNormal;
    }

}
//切换couple破冰是否
-(void)changeCoupleIceBreak
{
    if (self.coupleIMController.view) {
        [self.coupleIMController.view removeFromSuperview];
    }
    if ([self.view viewWithTag:CoupleBreakIcePageViewTag]) {
        [[self.view viewWithTag:CoupleBreakIcePageViewTag] removeFromSuperview];
    }
    CoupleBreakIcePageView *coupleIceBreak = [[CoupleBreakIcePageView alloc] initWithFrame:CGRectMake(320, 0, 320, 460)];
    coupleIceBreak.tag = CoupleBreakIcePageViewTag;
    coupleIceBreak.coupleBreakIcePageViewDelegate = self;
    [self.scrollMainView addSubview:coupleIceBreak];
    if (self.mutableArrViews.count > 1) {
        [self.mutableArrViews replaceObjectAtIndex:1 withObject:coupleIceBreak];    
    }else {
        [self.mutableArrViews addObject:coupleIceBreak];
    }
    [HomeInfo shareObject].coupleNeededBreakIce = COUPLEICEBREAK_STATUS_InIceBreak;
    
    if (![CPUIModelManagement sharedInstance].coupleMsgGroup) {
        if (self.coupleIMController.view) {
            [self.coupleIMController.view removeFromSuperview];
        }
        if ([self.view viewWithTag:CoupleBreakIcePageViewTag]) {
            [[self.view viewWithTag:CoupleBreakIcePageViewTag] removeFromSuperview];
        }
            CoupleBreakIcePageView *coupleIceBreak = [[CoupleBreakIcePageView alloc] initWithFrame:CGRectMake(320, 0, 320, 460)];
            coupleIceBreak.tag = CoupleBreakIcePageViewTag;
            coupleIceBreak.coupleBreakIcePageViewDelegate = self;
            [self.scrollMainView addSubview:coupleIceBreak];
            if (self.mutableArrViews.count > 1) {
                [self.mutableArrViews replaceObjectAtIndex:1 withObject:coupleIceBreak];    
            }else {
                [self.mutableArrViews addObject:coupleIceBreak];
            }
        [HomeInfo shareObject].coupleNeededBreakIce = COUPLEICEBREAK_STATUS_InIceBreak;
    }else {

        if ([self.scrollMainView viewWithTag:CoupleBreakIcePageViewTag]) {
            [[self.scrollMainView viewWithTag:CoupleBreakIcePageViewTag] removeFromSuperview];
        }
        //如果coupleImController不存在才生成
        if (self.scrollMainView.subviews.count == 2) {
            if (!self.coupleIMController) {
                self.coupleIMController = [[CoupleIMViewController alloc] init:[CPUIModelManagement sharedInstance].coupleMsgGroup ISNeedProfileStatus:self.coupleIMController.profileIsNeededSave];        
            }
            [self.coupleIMController.view setFrame:CGRectMake(320, 0, 320.f, 460.f)];
            self.coupleIMController.messageDelegate = self;
            [self.scrollMainView addSubview:self.coupleIMController.view];
            if (self.mutableArrViews.count > 1) {
                [self.mutableArrViews replaceObjectAtIndex:1 withObject:self.coupleIMController.view];    
            }else {
                [self.mutableArrViews addObject:self.coupleIMController.view];
            }            
        }
        [HomeInfo shareObject].coupleNeededBreakIce = COUPLEICEBREAK_STATUS_InNormal;
        
    }
     
}
*/
-(void)viewDidAppear:(BOOL)animated
{

    
//    [self changeCoupleIceBreak];
//    [self.coupleIMController addKeybordWhenKeybordDisappear:self.coupleIMController.profileIsNeededSave];
//    [self.coupleIMController changeButtonImageByStatus:Btn_Back_Couple];
//    self.coupleIMController.isInCoupleImViewController = NO;
    
//    if ([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_Couple ) {
//        self.coupleIMController.isInCoupleImViewController = YES;
//        if (self.coupleIMController.view) {
//            [self.coupleIMController getLoveMessage];
//        }
//    }else
        if([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_CloseFriend)
    {
    }else if([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_NormalFriend)
    {
    }
    CGFloat time = [[[NSUserDefaults standardUserDefaults] objectForKey:alertMessageWhenFristTime] floatValue];
    if (time < 5.0) {
        UIImageView *alertMessageView = [[UIImageView alloc] initWithFrame:CGRectMake(88, 158, 143, 143)];
        [alertMessageView setImage:[UIImage imageNamed:@"wall_float_guide01.png"]];
        alertMessageView.tag = alertMessageViewTag;
        alertMessageView.userInteractionEnabled = NO;
        [self.view addSubview:alertMessageView];
        
        
        timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(removeAlertMessageView) userInfo:nil repeats:NO];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groupPicNameDic"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"groupIdDic"];
    }
    
    swipeFlag = YES;
}   
-(void)viewWillAppear:(BOOL)animated
{
    
    self.needRemoveObserver = YES;
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"userMsgGroupListTag" options:0 context:@""];
    
    [[HomeInfo shareObject] updateData];
    [self refreshData];
    //检查是否是破冰状态
    [self breakIngIce];
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (self.needRemoveObserver) {
        [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"userMsgGroupListTag"];  
        //[[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"coupleMsgGroupTag"];
    }
    
    if (timer) {
        [timer invalidate];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
//   self.coupleIMController.isInCoupleImViewController = NO;
//    if ([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_Couple ) {
//    }else
        if([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_CloseFriend)
    {
    }else if([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_NormalFriend)
    {
    }
    
    
    [self removeAlertMessageView];
    if([HomeInfo shareObject].isDeletingInCell)
    {
        HomeFriendsView *friendView = [self.mutableArrViews objectAtIndex:0];
        [friendView recoverDeletingStatus];
    }
    if ([HomeInfo shareObject].isDeletingInCloseFriendCell) {
        HomeCloseFriendView *closeView = [self.mutableArrViews objectAtIndex:1];
        [closeView beignChangeDeleteStatusFromCloseFriend:NO];        
    }

    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, 320, 460)];

    

    
    //[[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"coupleMsgGroupTag" options:0 context:@""];
    
   
    
//    HomeCloseFriendViewController *closeFriendController = [[HomeCloseFriendViewController alloc] init];
//    closeFriendController.homeCloseFriendViewControllerDelegate = self;

    


	// Do any additional setup after loading the view.
}
-(void)dealloc
{

    
}
-(void)viewDidUnload
{
    [super viewDidUnload];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark ScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    swipeFlag = YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 321 && swipeFlag) {
        [self goHomeController];
        return;
    }
    
    CGFloat viewWidth = scrollView.frame.size.width;
    int page = floor(scrollView.contentOffset.x-viewWidth/2)/viewWidth+1;
    //当页面发生改变
    if (page != [HomeInfo shareObject].currentViewControllerIndex) {
        swipeFlag = NO;
        [HomeInfo shareObject].currentViewControllerIndex = page;

//        [self.coupleIMController.detailViewController stopSound];
        switch ([HomeInfo shareObject].currentViewControllerIndex) {
            case ContactFriend_NormalFriend:
            {
//                UITableView *tableFriend = (UITableView *)[[self.mutableArrViews objectAtIndex:0] viewWithTag:90011];
//                
//                [tableFriend reloadData];
 //               self.coupleIMController.isInCoupleImViewController = NO;
                [switchButton setFriendStyle];
                
            }
                break;
            case ContactFriend_CloseFriend:
            {
//                UITableView *tableCloseFriend = (UITableView *)[[self.mutableArrViews objectAtIndex:2] viewWithTag:90010];
//                [tableCloseFriend reloadData];
//                self.coupleIMController.isInCoupleImViewController = NO;
                [switchButton setCloseFriendStyle];
            }
                break;
//            case ContactFriend_Couple:
//            {
//                
//                self.coupleIMController.isInCoupleImViewController = YES;
//                if ([HomeInfo shareObject].isDeletingInCell) {
//                    HomeFriendsView *friendView = [self.mutableArrViews objectAtIndex:0];
//                    [friendView recoverDeletingStatus];
//                }
//                if ([HomeInfo shareObject].isDeletingInCloseFriendCell) {
//                    HomeCloseFriendView *closeFriendView = [self.mutableArrViews objectAtIndex:2];
//                    [closeFriendView beignChangeDeleteStatusFromCloseFriend:NO];                    
//                }
//                [self.coupleIMController getLoveMessage];
//                if (self.coupleIMController.view) {
//                    [self.coupleIMController refreshUnreadedMessagesNumber];
//                }
//                
//
//            }
//                break;
            default:
                break;
        }
        

    }
   
}

#pragma mark Method
-(void)refreshData
{
    UITableView *tableFriend = (UITableView *)[[self.mutableArrViews objectAtIndex:0] viewWithTag:90011];
    [tableFriend reloadData];
    
    HomeCloseFriendView *closefriendview = [self.mutableArrViews objectAtIndex:1];
    UITableView *tableCloseFriend = (UITableView *)[closefriendview viewWithTag:90010];
    [tableCloseFriend reloadData];
    

}
-(void)removeAlertMessageView
{
    [[self.view viewWithTag:alertMessageViewTag] removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:5.0] forKey:alertMessageWhenFristTime];
}
-(void)refreshUnreadedNumber
{
    if ([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_NormalFriend) {
        [switchButton setUnreadedNumberByStyle:SWITCH_BUTTON_TYPE_FRIEND];
    }else if([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_CloseFriend)
    {
        [switchButton setUnreadedNumberByStyle:SWITCH_BUTTON_TYPE_CLOSEFRIEND];
    }
}
-(void)switchFriendWall:(FriendWallSwitchButton *)sender
{
    if ([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_NormalFriend) {
        [self scrollToRect:ContactFriend_CloseFriend withAnimation:YES];
    }else if([HomeInfo shareObject].currentViewControllerIndex == ContactFriend_CloseFriend)
    {
        [self scrollToRect:ContactFriend_NormalFriend withAnimation:YES];
    }
}

-(void)scrollToCloseFriendRect
{
    if ([CPUIModelManagement sharedInstance].closedMsgUnReadedCount == 0 && [CPUIModelManagement sharedInstance].friendMsgUnReadedCount > 0) {
        [self scrollToRect:ContactFriend_NormalFriend withAnimation:YES];
    }else {
        [self scrollToRect:ContactFriend_CloseFriend withAnimation:NO];    
    }
    
}
-(void)scrollToRect : (NSInteger)viewcontrollerIndex 
{
    [self scrollToRect:viewcontrollerIndex withAnimation:NO];
}
//滚动到指定区域
-(void)scrollToRect : (NSInteger)viewcontrollerIndex withAnimation :(BOOL)isNeeded
{
    [HomeInfo shareObject].currentViewControllerIndex = viewcontrollerIndex;
   // [self.coupleIMController.view setFrame:CGRectMake(320.f, 0.f, 320.f, 460.f)];
    if (viewcontrollerIndex != ContactFriend_Default) {
        UIView *controllerView = [self.mutableArrViews objectAtIndex:viewcontrollerIndex] ;
        [self.scrollMainView scrollRectToVisible:controllerView.frame animated:isNeeded];   
        
        if (viewcontrollerIndex == ContactFriend_CloseFriend) {
            [switchButton setCloseFriendStyle];
        }else if(viewcontrollerIndex == ContactFriend_NormalFriend)
        {
            [switchButton setFriendStyle];
        }
    }
}
//根据名字初始化
- (void)initViewControllerByName:(NSInteger )type
{    

    [HomeInfo shareObject].currentViewControllerIndex = type; 
    [self scrollToRect:type];

    

}

-(void)turnToCloseFriendView
{
    AddContactViewController *addContact = [[AddContactViewController alloc] initWithUIAddContract:UIAddCloseFriends];
    [self.navigationController pushViewController:addContact animated:YES];
}
-(void)turnToContactFriendController
{
    AddContactViewController *addContact = [[AddContactViewController alloc] initWithUIAddContract:UIAddFriends];
    [self.navigationController pushViewController:addContact animated:YES];
}
//yes == 显示 ,NO == 隐藏
-(void)viewOrHideTopBackground:(BOOL)isNeedHided
{
    if (isNeedHided) {
        self.imageviewBackground.hidden = NO;
    }else {
        self.imageviewBackground.hidden = YES;
    }
}
-(void)turnOffScrollviewScrollable
{

    if (self.scrollMainView.scrollEnabled) {

    [self.scrollMainView setScrollEnabled:NO];    
    }
    
}
-(void)turnOnScrollviewScrollable
{
    [self.scrollMainView setScrollEnabled:YES];
}
/*****
 profile:
 Navigation栈中倒数第2个是否是大家页面，是则返回
 IM:
 返回到首页
******/
-(void)goHomeController
{
    // added by xxx 2012.9.14
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
 //   [self dismissModalViewControllerAnimated:YES];
}
-(void)goHomeController:(NSInteger)BackTag
{
     [self dismissModalViewControllerAnimated:YES];
}
-(void)goPeopleController
{
    AllFriendsViewController *friend = [[AllFriendsViewController alloc] initWithState:ALL_FRIENDS_STATE_PROFILE group:nil];
    [self.navigationController pushViewController:friend animated:YES];
}

-(void)goImController:(CPUIModelMessageGroup *)messageGroup :(BOOL)isProfileNeeded :(NSInteger)btnBackType
{
    if ([messageGroup isMsgSingleGroup]) {
        if (messageGroup.memberList.count > 0) {
            CPUIModelMessageGroupMember *member = [messageGroup.memberList objectAtIndex:0];
            CPUIModelUserInfo *userInfo = member.userInfo;
            
            if ([userInfo.type integerValue] == USER_MANAGER_FANXER) {
                ShuangShuangTeamViewController *shuangshuangTeam = [[ShuangShuangTeamViewController alloc] init:messageGroup];
                [self.navigationController pushViewController:shuangshuangTeam animated:YES];
            }else if([userInfo.type integerValue] == USER_MANAGER_SYSTEM)
            {
                SystemIMViewController *system = [[SystemIMViewController alloc] init:messageGroup];
                [self.navigationController pushViewController:system animated:YES];
            }else if([userInfo.type integerValue] == USER_MANAGER_XIAOSHUANG)
            {
                XiaoShuangIMViewController *xiaoshuang = [[XiaoShuangIMViewController alloc] init:messageGroup];
                [self.navigationController pushViewController:xiaoshuang animated:YES];
            }else {
                SingleIMViewController *singleIM = [[SingleIMViewController alloc] init:messageGroup];
                [self.navigationController pushViewController:singleIM animated:YES];                
            }
        }
        

    }else if([messageGroup isMsgMultiGroup])
    {
        MutilIMViewController *mutilIM = [[MutilIMViewController alloc] init:messageGroup];
        [self.navigationController pushViewController:mutilIM animated:YES];
    }
}
@end
