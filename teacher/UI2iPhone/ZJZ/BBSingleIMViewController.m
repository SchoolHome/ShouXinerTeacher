//
//  SingleIMViewController.m
//  iCouple
//
//  Created by qing zhang on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSingleIMViewController.h"
#import "SingleIndependentProfileViewController.h"
#import "CoupleBreakIcePageViewController.h"
#import "ContactsStartGroupChatViewController.h"
@interface BBSingleIMViewController ()
@property (nonatomic,strong) CPUIModelUserInfo *userInfor;
@end

@implementation BBSingleIMViewController

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
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCoupleType:) name:@"ChooseCoupleNotification" object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.navigationController setNavigationBarHidden:YES];
    
//    self.modelMessageGroup.memberList
    NSArray *array = [NSArray arrayWithArray:self.modelMessageGroup.memberList];;
    NSString *title = @"";
    for (CPUIModelUserInfo *user in array) {
        if (![user.nickName isEqualToString:[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName]) {
            title = user.nickName;
        }
    }
    
    self.title = title;
    if (self.modelMessageGroup.memberList > 0) {
        CPUIModelMessageGroupMember *member = [self.modelMessageGroup.memberList objectAtIndex:0];
        CPUIModelUserInfo *userInfo = member.userInfo;
        self.userInfor = userInfo;
        
        //性别
        UIImageView *imageviewSex = (UIImageView *)[self.view viewWithTag:imageviewSexTag];
        if (!imageviewSex) {
            //213是nickname结束x坐标
            imageviewSex = [[UIImageView alloc] initWithFrame:CGRectMake(288, 412, 23.f, 23.f)];
            imageviewSex.tag = imageviewSexTag;
            [self.view insertSubview:imageviewSex belowSubview:self.IMView];
        }
        if ([userInfo.sex integerValue] == USER_INFO_SEX_FEMALE) {
            [imageviewSex setImage:[UIImage imageNamed:@"im_profile_sex1.png"]];
        }else if([userInfo.sex integerValue] == USER_INFO_SEX_MALE)
        {
            [imageviewSex setImage:[UIImage imageNamed:@"im_profile_sex2.png"]];
        }
        
        
        
        //单人profile
        self.profileView = [[SingleProfileView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320, 460+upHidedPartInStatusMid) andProfileType:[self.modelMessageGroup.type integerValue] andModelMessageGroup:self.modelMessageGroup ];
        self.profileView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
//        [self.mainBGView addSubview:self.profileView];
        self.singleProfileView = (SingleProfileView *)self.profileView;
        self.singleProfileView.profileViewDelegate = self;
        self.singleProfileView.singleProfileDelegate = self;
        [self.singleProfileView refreshSingleProfile:self.modelMessageGroup];
        
        //获取头像昵称
        [self.imageviewHeadImg setBackImage:[self returnCircleHeadImg]];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
        [back setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
        
        UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
        [add setFrame:CGRectMake(0.0f, 7.0f, 22.0f, 22.0f)];
        [add setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [add addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:add];
    }
    
	// Do any additional setup after loading the view.
}

-(void) backClick{
//    [self.navigationController popViewControllerAnimated:YES];
    [self .navigationController popToRootViewControllerAnimated:YES];
}

-(void) add{
    ContactsStartGroupChatViewController *c = [[ContactsStartGroupChatViewController alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:self.userInfor, nil];
    [c filterExistUserInfo:NO WithSelectedArray:array];
    [self.navigationController pushViewController:c animated:YES];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
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

#pragma mark Observer
-(void)refreshMsgGroup{
    if ([CPUIModelManagement sharedInstance].userMsgGroup) {
        self.modelMessageGroup = [CPUIModelManagement sharedInstance].userMsgGroup;
        [self.singleProfileView refreshSingleProfile:[CPUIModelManagement sharedInstance].userMsgGroup];
    }
}
//Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.singleProfileView.modelMessageGroup = self.modelMessageGroup;
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:@"userMsgGroupTag"]) {
        
        switch ([CPUIModelManagement sharedInstance].userMsgGroupTag) {
            case UPDATE_USER_GROUP_TAG_MSG_LIST_APPEND:{
            }
                break;
            case UPDATE_USER_GROUP_TAG_MEM_LIST:{
                [self.singleProfileView refreshSingleProfile:[CPUIModelManagement sharedInstance].userMsgGroup];
            }
                break;
            default:
            {
                
            }
                break;
        }
    }
    //被删除
    else if ([keyPath isEqualToString:@"deleteFriendDic"])
    {
    }
}

#pragma mark Method


#pragma mark ProfileDelegate
//播放profile中的音频关闭其他地方音频
-(void)palyAudioFromSingleProfileView:(UIButton *)sender{
    [self stopMusicPlayer];
    [self.detailViewController stopSound];
}

//了解更多，进入对方独立profile
-(void)turnToFriendProfile:(CPUIModelUserInfo *)friendUserInfo{
}

//跳转到好友Couple独立profile或陌生人profile
-(void)turnToFriendCoupleProfile:(CPUIModelUserInfo *)coupleUserInfo{

}
@end
