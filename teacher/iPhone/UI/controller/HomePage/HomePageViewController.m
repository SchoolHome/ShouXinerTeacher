//
//  HomePageViewController.m
//  MainPage_dev
//
//  Created by ming bright on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomePageViewController.h"

#import "ColorUtil.h"
#import "DateUtil.h"

#import "TPCMToAMR.h"
#import "AlarmClockHelper.h"

#import "CoupleBreakIcePageViewController.h"
#import "AllFriendsViewController.h"
#import "HomePageModifyPasswordViewController.h"
#import "AddContactViewController.h"

#import "ShuangShuangTeamViewController.h"
#import "SystemIMViewController.h"
#import "XiaoShuangIMViewController.h"
#import "SingleIMViewController.h"



#define kRemovedRecentControlTag 321
#define kSelfCityName @"self_city_name"



#define kSingleNoBabyX   180
#define kSingleHasBabyX  255
#define kSingleCurseX    280


#define kAvatarAndRecentPadding 20


typedef enum {
    ALERT_TAG_HAVE_NEW_VERSION = 1,
    ALERT_TAG_NO_NEW_VERSION
} ALERT_TAG;

@implementation HomePageViewController

@synthesize profileViewController;

static HomePageViewController *homepage = nil;

#pragma mark -
#pragma mark init

-(id)init{
    self = [super init];
    if (self) {
        
        NSString *city = [[NSUserDefaults standardUserDefaults] valueForKey:kSelfCityName];
        
        if (!city) {
            [[NSUserDefaults standardUserDefaults] setObject:@"这里" forKey:kSelfCityName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        
        
        // me
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"uiPersonalInfoTag" options:0 context:NULL];
        
        // couple
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"friendMsgUnReadedCount" options:0 context:NULL];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"coupleMsgUnReadedCount" options:0 context:NULL];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"closedMsgUnReadedCount" options:0 context:NULL];
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"coupleTag" options:0 context:NULL];
        
        // tips
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"tipsNewMsgDic" options:0 context:NULL];
        
        // update
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"checkUpdateResponseDic" options:0 context:NULL];
        
    }
    
    return self;
}

+(HomePageViewController *)sharedHomePageViewController{
    
    @synchronized(self){
        if (!homepage) {
            homepage = [[HomePageViewController alloc] init];
        }
    }
    return homepage;
}

-(HomeMainViewController *)homeMainViewController{
    return homeMainViewController;
}

#pragma mark -
#pragma mark play audio

-(void)musicPlayerDidFinishPlaying:(MusicPlayerManager *) player playerName:(NSString *)name{
    CPLogInfo(@"musicPlayerDidFinishPlaying");
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    CPUIModelUserInfo *coupleInfo = [CPUIModelManagement sharedInstance].coupleModel;
    
    NSString *amrPath1 = personalInfo.recentContent;
    NSString *amrPath2 = coupleInfo.recentContent;
    
    NSString *selfPath;
    if (amrPath1) {
        selfPath = [[amrPath1 stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    }
    
    NSString *couplePath;
    if (amrPath2) {
        couplePath = [[amrPath2 stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    }
    
    if ([name isEqualToString:selfPath]) {
        [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
        [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
    }else if([name isEqualToString:couplePath]) {
        [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
        [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
    }
}

-(void)musicPlayerDecodeErrorDidOccur:(MusicPlayerManager *) player error:(NSError *)error playerName:(NSString *)name{
    CPLogError(@"musicPlayerDecodeErrorDidOccur");
}


-(void)playSelfAudioRecent{
    
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    
    if (personalInfo.recentType == PERSONAL_RECENT_TYPE_AUDIO) {
        
        NSString *amrPath = personalInfo.recentContent;
        
        NSString *wavPath;
        if (amrPath) {
            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {  // 转网络的amr－> wav
                [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
            }
        }
        
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
            if ([[MusicPlayerManager sharedInstance] isPlaying]) {
                [[MusicPlayerManager sharedInstance] stop];
                
                [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
                [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
            }else {
                [MusicPlayerManager sharedInstance].delegate = self;
                [[MusicPlayerManager sharedInstance] playMusic:wavPath playerName:wavPath];
                
                [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_state_stop_little_white"] forState:UIControlStateNormal];
                [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_state__stop_little_grey"] forState:UIControlStateHighlighted];
            }
        }
    }
}



-(void)playCoupleAudioRecent{
    
    CPUIModelUserInfo *coupleinfo = [CPUIModelManagement sharedInstance].coupleModel;
    
    if (coupleinfo.recentType == PERSONAL_RECENT_TYPE_AUDIO) {
        
        NSString *amrPath = coupleinfo.recentContent;
        NSString *wavPath;
        if (amrPath) {
            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {  // 转网络的amr－> wav
                [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
            }
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
            if ([[MusicPlayerManager sharedInstance] isPlaying]) {
                [[MusicPlayerManager sharedInstance] stop];
                
                [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
                [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
            }else {
                [MusicPlayerManager sharedInstance].delegate = self;
                [[MusicPlayerManager sharedInstance] playMusic:wavPath playerName:wavPath];
                
                [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_state_stop_little_white"] forState:UIControlStateNormal];
                [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_state__stop_little_grey"] forState:UIControlStateHighlighted];
            }
        }
    }
}


#pragma mark -
#pragma mark update location

-(void)updateLocation{

    BKLocationManager *manager = [BKLocationManager sharedManager];
    
    [manager setDidUpdateLocationBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        //CPLogInfo(@"didUpdateLocation");
        [SVGeocoder reverseGeocode:newLocation.coordinate
                        completion:^(NSArray *placemarks, NSError *error) {
                            if(!error && placemarks) {
                                SVPlacemark *placemark = [placemarks objectAtIndex:0];
                                [[NSUserDefaults standardUserDefaults] setValue:[placemark.addressDictionary objectForKey:@"City"] forKey:kSelfCityName];
                                [self updateDocuments];

                            } else {
                                //CPLogError(@"reverseGeocode %@",error);
                            }
                        }];
        [manager stopUpdatingLocation];
    }];
    
    [manager setDidFailBlock:^(CLLocationManager *manager, NSError *error) {
        //CPLogError(@"didFailUpdateLocation %@",error);
        [manager stopUpdatingLocation];
    }];
    
    [manager startUpdatingLocationWithAccuracy:kCLLocationAccuracyHundredMeters];

}



#pragma mark -
#pragma mark update avatars

-(void)updateAvatars{
    //关系变更
    [avatarView layoutAvatars];
}


#pragma mark -
#pragma mark update documents

-(void)updateDocuments{
    
    

    
    NSArray *contentsArray1 = [NSArray arrayWithObjects:
                               @"我",
                               @"生活在[位置]",
                               @"欢乐有时孤单有时",
                               @"下一站会遇见...谁？", nil];
    
    NSArray *contentsArray2 = [NSArray arrayWithObjects:
                               @"喜欢你[时长]",
                               @"我在[位置]默默坚守",
                               @"也许有一天会勇敢说出",
                               @"做我的双双吧", nil];
    NSArray *contentsArray3 = [NSArray arrayWithObjects:
                               @"爱",
                               @"和你在一起",
                               @"连[位置]都变得热切生动起来",
                               @"牵手[时长] 甜蜜都是双份", nil];
    
    NSArray *contentsArray4 = [NSArray arrayWithObjects:
                               @"因为有你 二人成双",
                               @"[时长]不舍昼夜",
                               @"生活在[位置]",
                               @"记录爱与感动", nil];
    
    /*
    NSArray *contentsArray5 = [NSArray arrayWithObjects:
                               @"有人计算过",
                               @"[位置1]和[位置2]相距[距离]公里",
                               @"我想你",
                               @"[时长]的每一天",
                               @"双双里我们在一起", nil];
    
    */
    
    NSMutableArray *contens = [[NSMutableArray alloc] init];
    [contens addObject:contentsArray1];
    [contens addObject:contentsArray2];
    [contens addObject:contentsArray3];
    [contens addObject:contentsArray4];
    //[contens addObject:contentsArray5];

    
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    
    
    NSTimeInterval fromTime = [personalInfo.singleTime doubleValue]/1000;
    NSTimeInterval toTime = [[NSDate date] timeIntervalSince1970];
    NSString *date = [DateUtil dateStrFrom:fromTime to:toTime];
    
    
    //CPLogInfo(@"fromTime == %f",fromTime);
    
    if (0==[personalInfo.singleTime intValue]) {
        date = @"1天";
    }

    int lifeStatus = [personalInfo.lifeStatus intValue];
    
    switch (lifeStatus) {
        case PERSONAL_LIFE_STATUS_DEFAULT:
        case PERSONAL_LIFE_STATUS_SINGLE:     //1,单身
        {
            documentView.contents = [contens objectAtIndex:0];
            documentView.textAlignment = HPTextAlignmentRight;
        }
            break;
            
        case PERSONAL_LIFE_STATUS_CURSE:     //2,喜欢
        {
            documentView.contents = [contens objectAtIndex:1];
            documentView.textAlignment = HPTextAlignmentRight;
        }
            
            break;
        case PERSONAL_LIFE_STATUS_COUPLE:{  //3,couple  热恋
            documentView.contents = [contens objectAtIndex:2];
            documentView.textAlignment = HPTextAlignmentCenter;
        }
            break;
        case PERSONAL_LIFE_STATUS_COUPLE_MARRIED:
        case PERSONAL_LIFE_STATUS_HAS_BABY:   //3,couple 结婚
        {
            documentView.contents = [contens objectAtIndex:3];
            documentView.textAlignment = HPTextAlignmentCenter;
        }
            break;
        default:
            break;
    } 

    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithCapacity:5];
    [settings setObject:[[NSUserDefaults standardUserDefaults] valueForKey:kSelfCityName] forKey:kHomePageLocation];
    [settings setObject:date forKey:kHomePageDuration];
    documentView.settings = settings;
}

#pragma mark -
#pragma mark update tabbar

-(void)updateBadges{
    // 消息数量
    [coupleButton updateCoupleBadge:[CPUIModelManagement sharedInstance].coupleMsgUnReadedCount];
    int msgCount = [CPUIModelManagement sharedInstance].friendMsgUnReadedCount + [CPUIModelManagement sharedInstance].closedMsgUnReadedCount;
    [ncButton updateCoupleBadge:msgCount];
}

-(void)updateRelation{
    [coupleButton layoutCoupleButton];
}


#pragma mark -
#pragma mark update recent

-(void)clearRecentControls{
    for (UIView *aView in [self.view subviews]) {
        if (aView.tag == kRemovedRecentControlTag) {
            [aView removeFromSuperview];
        }
    }
}

-(void)updateRecent{
    
    [self clearRecentControls];
    
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    CPUIModelUserInfo *coupleInfo = [CPUIModelManagement sharedInstance].coupleModel;
    
    
    if (personalInfo.recentType == USER_RECENT_TYPE_AUDIO) {
        NSString *amrPath = personalInfo.recentContent;
        
        NSString *wavPath;
        if (amrPath) {
            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {  // 转网络的amr－> wav
                [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
            }
        }
        
    }    
    
    
    if (coupleInfo.recentType == USER_RECENT_TYPE_AUDIO) {
        
        NSString *amrPath = coupleInfo.recentContent;
        NSString *wavPath;
        if (amrPath) {
            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {  // 转网络的amr－> wav
                [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
            }
        }

    }
     
    int lifeStatus = [personalInfo.lifeStatus intValue];
    switch (lifeStatus) {
        case PERSONAL_LIFE_STATUS_DEFAULT:
        case PERSONAL_LIFE_STATUS_SINGLE:     //1,单身
        {
            
            switch (personalInfo.recentType) {
                case USER_RECENT_TYPE_TEXT:
                {
                    
                    HomePageArrowView *recentContentBack = [[HomePageArrowView alloc] initWithFrame:CGRectZero];
                    recentContentBack.tag = kRemovedRecentControlTag;
                    //recentContentBack.frame = CGRectMake(140, 55, 150, 55);
                    [self.view addSubview:recentContentBack];
                    
                    UILabel *recentContent = [[UILabel alloc] initWithFrame:CGRectMake(18, 8, 130, 45)];
                    recentContent.tag = kRemovedRecentControlTag;
                    recentContent.backgroundColor = [UIColor clearColor];
                    recentContent.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                    recentContent.font = [UIFont systemFontOfSize:13];
                    recentContent.textAlignment = UITextAlignmentLeft;
                    recentContent.numberOfLines = 0;
                    [recentContentBack addSubview:recentContent];
                    recentContent.text = personalInfo.recentContent;
                    //recentContent.numberOfLines = 3;
                    [recentContent sizeToFit];
                    
                    recentContent.frame = CGRectMake(18, 8, recentContent.frame.size.width, recentContent.frame.size.height);
                    if (recentContent.frame.size.height>=48.0) {
                        recentContent.frame = CGRectMake(18, 8, recentContent.frame.size.width, 48);
                    }
                    
                    
                    recentContentBack.frame = CGRectMake(0, 0, recentContent.frame.size.width+26, recentContent.frame.size.height+16);
                    
                    //CPLogInfo(@"recentContent.frame.size.height %f",recentContent.frame.size.height);
                    
                    
                    if ([personalInfo.hasBaby boolValue]) {  //隐藏宝宝
                        recentContentBack.center = CGPointMake( (kSingleNoBabyX + recentContentBack.frame.size.width)/2, 90+kAvatarAndRecentPadding);
                    }else {

                        recentContentBack.center = CGPointMake( (kSingleHasBabyX + recentContentBack.frame.size.width)/2, 90+kAvatarAndRecentPadding);
                    }
                    
                    if (![CoreUtils stringIsNotNull:personalInfo.recentContent]){ //近况空
                        [recentContentBack removeFromSuperview];
                    }
                    
                    
                }
                    
                    break;
                case USER_RECENT_TYPE_AUDIO:
                {
                    
                    HomePageArrowView *recentContentBack = [[HomePageArrowView alloc] initWithFrame:CGRectZero];
                    recentContentBack.tag = kRemovedRecentControlTag;
                    recentContentBack.frame = CGRectMake(0, 0, 75, 40);
                    [self.view addSubview:recentContentBack];
                    
                    [recentContentBack addSubview:selfAudioButton];

                    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                    lengthLabel.backgroundColor = [UIColor clearColor];
                    lengthLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                    lengthLabel.font = [UIFont systemFontOfSize:13];
                    lengthLabel.tag = kRemovedRecentControlTag;
                    [recentContentBack addSubview:lengthLabel];
                    
                    NSString *amrPath = personalInfo.recentContent;
                    NSString *wavPath;
                    if (amrPath) {
                        wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
                    }
                    
                    int length = 0;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
                        
                        length = (int) [[MusicPlayerManager sharedInstance] musicLength:wavPath];
                    }
                    lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
                    
                    selfAudioButton.frame = CGRectMake(20, (recentContentBack.frame.size.height -24)/2, 24, 24);
                    lengthLabel.frame = CGRectMake(50, (recentContentBack.frame.size.height -24)/2, 30, 24);
                    
                    if ([personalInfo.hasBaby boolValue]) {  //隐藏宝宝
                        recentContentBack.center = CGPointMake( (kSingleNoBabyX + recentContentBack.frame.size.width)/2, 90+kAvatarAndRecentPadding);
                       
                    }else {
                        recentContentBack.center = CGPointMake( (kSingleHasBabyX + recentContentBack.frame.size.width)/2, 90+kAvatarAndRecentPadding);
                    }
                    
                }
                    break; 
                default:
                    break;
            }
            
        }
            
            break;
            
        /////////////////////////////////////////////////////////////////////////////////////////////   
            
        case PERSONAL_LIFE_STATUS_CURSE:     //2,喜欢
        {

            //coupleInfo
            /////********************************************************************************/////
            
            //coupleInfo.recentType
            switch (coupleInfo.recentType) {      // couple近况
                case USER_RECENT_TYPE_TEXT:
                {
                    HomePageArrowView *recentContentBack = [[HomePageArrowView alloc] initWithFrame:CGRectZero];
                    recentContentBack.tag = kRemovedRecentControlTag;
                    [self.view addSubview:recentContentBack];
                    
                    UILabel *recentContent = [[UILabel alloc] initWithFrame:CGRectMake(18, 8, 130, 45)];
                    recentContent.tag = kRemovedRecentControlTag;
                    recentContent.backgroundColor = [UIColor clearColor];
                    recentContent.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                    recentContent.font = [UIFont systemFontOfSize:13];
                    recentContent.textAlignment = UITextAlignmentLeft;
                    recentContent.numberOfLines = 0;
                    [recentContentBack addSubview:recentContent];
                    
                    if ([CoreUtils stringIsNotNull:coupleInfo.recentContent]) {
                        recentContent.text = coupleInfo.recentContent;
                    }else {
                        
                        recentContent.text = @"唉...没有近况，好空旷啊";

                    }
                    //recentContent.numberOfLines = 3;
                    [recentContent sizeToFit];
                    
                    recentContent.frame = CGRectMake(18, 8, recentContent.frame.size.width, recentContent.frame.size.height);
                    if (recentContent.frame.size.height>=48.0) {
                        recentContent.frame = CGRectMake(18, 8, recentContent.frame.size.width, 48);
                    }
                    
                    recentContentBack.frame = CGRectMake(0, 0, recentContent.frame.size.width+26, recentContent.frame.size.height+16);
                    recentContentBack.center = CGPointMake( (kSingleCurseX + recentContentBack.frame.size.width)/2, 90+kAvatarAndRecentPadding);

                }
                    
                    break;
                case USER_RECENT_TYPE_AUDIO:
                {
                    HomePageArrowView *recentContentBack = [[HomePageArrowView alloc] initWithFrame:CGRectZero];
                    recentContentBack.tag = kRemovedRecentControlTag;
                    recentContentBack.frame = CGRectMake(0, 0, 75, 40);
                    [self.view addSubview:recentContentBack];
                    
                    [recentContentBack addSubview:coupleAudioButton];

                    UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                    lengthLabel.backgroundColor = [UIColor clearColor];
                    lengthLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                    lengthLabel.font = [UIFont systemFontOfSize:13];
                    lengthLabel.tag = kRemovedRecentControlTag;
                    [recentContentBack addSubview:lengthLabel];
                    
                    NSString *amrPath = coupleInfo.recentContent;
                    NSString *wavPath;
                    if (amrPath) {
                        wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
                    }
                    
                    
                    int length = 0;
                    if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
                        
                        length = (int) [[MusicPlayerManager sharedInstance] musicLength:wavPath];
                    }
                    lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
                    
                    coupleAudioButton.frame = CGRectMake(20, (recentContentBack.frame.size.height -24)/2, 24, 24);
                    lengthLabel.frame = CGRectMake(50, (recentContentBack.frame.size.height -24)/2, 30, 24);
                    recentContentBack.center = CGPointMake( (kSingleCurseX + recentContentBack.frame.size.width)/2, 90+kAvatarAndRecentPadding);
                    
                }
                    break; 
                default:
                    break;
            }
            
            /////********************************************************************************/////
        }
            
            break;
        /////////////////////////////////////////////////////////////////////////////////////////////    
            
        case PERSONAL_LIFE_STATUS_COUPLE:
        case PERSONAL_LIFE_STATUS_COUPLE_MARRIED:
        case PERSONAL_LIFE_STATUS_HAS_BABY:   //3,couple   
        {
            
            
            if ((![CoreUtils stringIsNotNull:personalInfo.recentContent])&&(![CoreUtils stringIsNotNull:coupleInfo.recentContent])) { // 都没有近况
                // 不显示
            }else {
                // personalInfo
                /////********************************************************************************/////
                switch (personalInfo.recentType) {      // 自己近况
                    case USER_RECENT_TYPE_TEXT:
                    {
                        [self.view insertSubview:coupleContentBack belowSubview:avatarView];
                        
                        UILabel *recentContent = [[UILabel alloc] initWithFrame:CGRectZero];
                        recentContent.tag = kRemovedRecentControlTag;
                        recentContent.backgroundColor = [UIColor clearColor];
                        recentContent.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                        recentContent.font = [UIFont systemFontOfSize:13];
                        recentContent.textAlignment = UITextAlignmentCenter;
                        recentContent.numberOfLines = 3;
                        [self.view addSubview:recentContent];
                        
                        recentContent.text = personalInfo.recentContent;
                        if ([personalInfo.hasBaby boolValue]){  //隐藏宝宝
                            recentContent.numberOfLines = 3;
                            recentContent.frame = CGRectMake(7, 55+kAvatarAndRecentPadding, 85, 55);
                            
                        }else {
                            
                            recentContent.numberOfLines = 3;
                            recentContent.frame = CGRectMake(5, 55+kAvatarAndRecentPadding, 65, 55);
                        }
                    }
                        
                        break;
                    case USER_RECENT_TYPE_AUDIO:
                    {
                        [self.view insertSubview:coupleContentBack belowSubview:avatarView];
                        [self.view addSubview:selfAudioButton];
                        
                        UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        lengthLabel.backgroundColor = [UIColor clearColor];
                        lengthLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                        lengthLabel.font = [UIFont systemFontOfSize:13];
                        lengthLabel.tag = kRemovedRecentControlTag;
                        [self.view addSubview:lengthLabel];
                        
                        NSString *amrPath = personalInfo.recentContent;
                        NSString *wavPath;
                        if (amrPath) {
                            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
                        }
                        
                        int length = 0;
                        if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
                            
                            length = (int) [[MusicPlayerManager sharedInstance] musicLength:wavPath];
                        }
                        lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
                        
                        if ([personalInfo.hasBaby boolValue]){  //隐藏宝宝
                            selfAudioButton.frame = CGRectMake(35, 75+kAvatarAndRecentPadding, 24, 24);
                            lengthLabel.frame = CGRectMake(65, 75+kAvatarAndRecentPadding, 30, 24);
                            
                        }else {
                            selfAudioButton.frame = CGRectMake(20, 75+kAvatarAndRecentPadding, 24, 24);
                            lengthLabel.frame = CGRectMake(50, 75+kAvatarAndRecentPadding, 30, 24);
                        }
                        
                    }
                        break; 
                    default:
                        break;
                }
                
                //coupleInfo
                /////********************************************************************************/////
                
                switch (coupleInfo.recentType) {      // couple近况
                    case USER_RECENT_TYPE_TEXT:
                    {
                        [self.view insertSubview:coupleContentBack belowSubview:avatarView];
                        
                        UILabel *recentContent = [[UILabel alloc] initWithFrame:CGRectZero];
                        recentContent.tag = kRemovedRecentControlTag;
                        recentContent.backgroundColor = [UIColor clearColor];
                        recentContent.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                        recentContent.font = [UIFont systemFontOfSize:13];
                        recentContent.textAlignment = UITextAlignmentCenter;
                        recentContent.numberOfLines = 3;
                        [self.view addSubview:recentContent];
                        
                        if ([CoreUtils stringIsNotNull:coupleInfo.recentContent]) {
                            
                            recentContent.text = coupleInfo.recentContent;
                        }else {
                            
                            recentContent.text = @"唉...没有近况，好空旷啊";
                        }
                        
                        if ([personalInfo.hasBaby boolValue]){  //隐藏宝宝
                            recentContent.numberOfLines = 3;
                            recentContent.frame = CGRectMake(320-92, 55+kAvatarAndRecentPadding, 85, 55);
                            
                        }else {
                            recentContent.numberOfLines = 3;
                            recentContent.frame = CGRectMake(320-70, 55+kAvatarAndRecentPadding, 65, 55);
                            
                        }
                    }
                        
                        break;
                    case USER_RECENT_TYPE_AUDIO:
                    {
                        [self.view insertSubview:coupleContentBack belowSubview:avatarView];
                        
                        [self.view addSubview:coupleAudioButton];
                        
                        
                        UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                        lengthLabel.backgroundColor = [UIColor clearColor];
                        lengthLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                        lengthLabel.font = [UIFont systemFontOfSize:13];
                        lengthLabel.textAlignment = UITextAlignmentLeft;
                        lengthLabel.tag = kRemovedRecentControlTag;
                        [self.view addSubview:lengthLabel];
                        
                        NSString *amrPath = coupleInfo.recentContent;
                        NSString *wavPath;
                        if (amrPath) {
                            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
                        }
                        
                        int length = 0;
                        if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
                            
                            length = (int) [[MusicPlayerManager sharedInstance] musicLength:wavPath];
                        }
                        lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
                        
                        if ([personalInfo.hasBaby boolValue]){  //隐藏宝宝
                            
                            coupleAudioButton.frame = CGRectMake(320-80, 75+kAvatarAndRecentPadding, 24, 24);
                            lengthLabel.frame = CGRectMake(320-50, 75+kAvatarAndRecentPadding, 30, 24);
                            
                        }else {
                            coupleAudioButton.frame = CGRectMake(320-70, 75+kAvatarAndRecentPadding, 24, 24);
                            lengthLabel.frame = CGRectMake(320-40, 75+kAvatarAndRecentPadding, 30, 24);
                        }
                        
                    }
                        break; 
                    default:   //近况类型没有匹配
                    {
                        [self.view insertSubview:coupleContentBack belowSubview:avatarView];
                        
                        UILabel *recentContent = [[UILabel alloc] initWithFrame:CGRectZero];
                        recentContent.tag = kRemovedRecentControlTag;
                        recentContent.backgroundColor = [UIColor clearColor];
                        recentContent.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
                        recentContent.font = [UIFont systemFontOfSize:13];
                        recentContent.textAlignment = UITextAlignmentCenter;
                        recentContent.numberOfLines = 3;
                        [self.view addSubview:recentContent];
                        
                        if ([CoreUtils stringIsNotNull:coupleInfo.recentContent]) {
                            
                            recentContent.text = coupleInfo.recentContent;
                        }else {
                            
                            recentContent.text = @"唉...没有近况，好空旷啊";
                        }
                        
                        if ([personalInfo.hasBaby boolValue]){  //隐藏宝宝
                            recentContent.numberOfLines = 3;
                            recentContent.frame = CGRectMake(320-92, 55+kAvatarAndRecentPadding, 85, 55);
                            
                        }else {
                            recentContent.numberOfLines = 3;
                            recentContent.frame = CGRectMake(320-70, 55+kAvatarAndRecentPadding, 65, 55);
                            
                        }
                    }
                        break;
                }

            }

            /////********************************************************************************/////

        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark update all

-(void)reloadData{
    [self updateAvatars];
    [self updateDocuments];
    [self updateRecent];
    [self updateBadges];
    [self updateRelation];
    [self updateLocation];
}



#pragma mark -
#pragma mark observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    // 更新 Badges
    if ([keyPath isEqualToString:@"friendMsgUnReadedCount"]||[keyPath isEqualToString:@"coupleMsgUnReadedCount"]||[keyPath isEqualToString:@"closedMsgUnReadedCount"]) {
        //CPLogInfo(@"MsgUnReadedCount");
        [self updateBadges];
    }
    
    // 更新 头像。。。
    if ([keyPath isEqualToString:@"coupleTag"]) {  // couple有更新
        //CPLogInfo(@"coupleTag");
        [self updateRelation];
        [self updateAvatars];
        [self updateRecent];
        [self updateDocuments];
    }
    
    //  自己的信息被修改的时候
    if ([keyPath isEqualToString:@"uiPersonalInfoTag"]) {
        //CPLogInfo(@"uiPersonalInfoTag");
        
        [self reloadData];
        
        if (personalLifeStatus != [[CPUIModelManagement sharedInstance].uiPersonalInfo.lifeStatus intValue]|
            hasBaby != [[[CPUIModelManagement sharedInstance].uiPersonalInfo hasBaby] boolValue]
            ) {  // 减少背景刷新次数
            personalLifeStatus = [[CPUIModelManagement sharedInstance].uiPersonalInfo.lifeStatus intValue];
            hasBaby = [[[CPUIModelManagement sharedInstance].uiPersonalInfo hasBaby] boolValue];
            [self startAnim];
        }
    }
    
    // tips
    if ([keyPath isEqualToString:@"tipsNewMsgDic"]) {  //  右上角消息
        //CPLogInfo(@"tipsNewMsgDic");
        
        NSDictionary *tipsMsg = [CPUIModelManagement sharedInstance].tipsNewMsgDic;
        NSString *nickName = [tipsMsg valueForKey:new_msg_tip_nick_name];
        int count = [[tipsMsg valueForKey:new_msg_tip_un_readed_count] intValue];
        
        CPUIModelMessageGroup *msgGroup = [tipsMsg valueForKey:new_msg_tip_msg_group];
        
        if (count>0) {
            //
            [HPStatusBarTipView shareInstance].delegate = self;
            [[HPStatusBarTipView shareInstance] showMessage:nickName msgGroup:msgGroup infoCount:count];
        }else {
            [[HPStatusBarTipView shareInstance] dismiss];
        }
    }
    
    // update
    if ([keyPath isEqualToString:@"checkUpdateResponseDic"]) {
        //
        //CPLogInfo(@"checkUpdateResponseDic");
        
        NSDictionary *updateMsg = [CPUIModelManagement sharedInstance].checkUpdateResponseDic;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"last_update_showing"])
            return;

        if (RESPONSE_CODE_SUCESS==[[updateMsg valueForKey:check_update_res_code] intValue]) {
            //
            //if ([self.navigationController.topViewController isKindOfClass:[HomePageMoreViewController class]]) {  // 在更多界面
            if (self.profileViewController.isUpdateTaped) { // 在更多界面,update
                if ([updateMsg valueForKey:check_update_version]) { // 有更新
                    [[NSUserDefaults standardUserDefaults] setValue:@"OK" forKey:@"last_update_showing"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[updateMsg valueForKey:check_update_subject]
                                                                    message:[updateMsg valueForKey:check_update_content]  
                                                                   delegate:self 
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"以后再说",@"更新", nil];
                    alert.tag = ALERT_TAG_HAVE_NEW_VERSION;
                    [alert show];
                }else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"已经是最新版本啦"  
                                                                   delegate:self 
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"确定", nil];
                    alert.tag = ALERT_TAG_NO_NEW_VERSION;
                    [alert show];
                }
            }else {   // 
                if ([updateMsg valueForKey:check_update_version]) {
                    
                    BOOL showAlert = NO;
                    
                    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"last_update_date"]) { // 原来没有保存过
                        showAlert = YES;
                    }else {
                        double oldTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"last_update_date"] doubleValue];
                        double now = [[NSDate date] timeIntervalSince1970];
                        
                        //CPLogInfo(@"now-oldTime   %f",now-oldTime);
                        
                        if ((now-oldTime)>=60*60*24*7) { // 一周
                            showAlert = YES;
                        }
                    }

                    if (showAlert) {
                        [[NSUserDefaults standardUserDefaults] setValue:@"OK" forKey:@"last_update_showing"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[updateMsg valueForKey:check_update_subject] 
                                                                        message:[updateMsg valueForKey:check_update_content]  
                                                                       delegate:self 
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"以后再说",@"更新", nil];
                        alert.tag = ALERT_TAG_HAVE_NEW_VERSION;
                        [alert show];
                    }
                }
            }

        }else {
            // 网络错误
            if ([self.navigationController.visibleViewController isKindOfClass:[HomePageSelfProfileViewController class]]) {  // 个人profile 更新联网失败
                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
            }
        }
    }
    //[self.view bringSubviewToFront:loadingView];
}

#pragma mark -
#pragma mark button actions

- (void)animateFromViewController:(UIViewController*)fromController toViewController:(UIViewController*)toController{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}

-(void)ncButtonTaped:(id)sender{
    
    CPLogInfo(@"TabBarItemNormalFriends");
    

    homeMainViewController = [[HomeMainViewController alloc] init];
    [homeMainViewController scrollToCloseFriendRect];
    
    [self animateFromViewController:self toViewController:homeMainViewController];
    [self.navigationController pushViewController:homeMainViewController animated:NO];
}

-(void)addButtonTaped:(id)sender{
    
    
    AddContactViewController *addContactViewController = [[AddContactViewController alloc] initWithUIAddContract:UIAddFriends];
    [self.navigationController pushViewController:addContactViewController animated:YES];
}

-(void)coupleButtonTaped:(id)sender{
    
    if ([[CPUIModelManagement sharedInstance] hasCouple]) {
        SingleIMViewController *single = [[SingleIMViewController alloc] init:[CPUIModelManagement sharedInstance].coupleMsgGroup];
        [self.navigationController pushViewController:single animated:YES];
    }else {
        CoupleBreakIcePageViewController *coupleBreakIce = [[CoupleBreakIcePageViewController alloc] init];
        [self.navigationController pushViewController:coupleBreakIce animated:YES];
        
    }
}

-(void)avatarTaped:(UIButton *)sender{

    switch (sender.tag) {
        case AvatarButtonSelf:
        {
            [animView hideBackground];
            
            HomePageSelfProfileViewController *profile = [[HomePageSelfProfileViewController alloc] init];
            self.profileViewController = profile;
            [self.navigationController pushViewController:self.profileViewController animated:YES];
        }
            break;
        case AvatarButtonBaby:
        {

        }
            break;        
        case AvatarButtonCouple:
        {
            [animView hideBackground];
            
            
            //SingleIMViewController *single = [[SingleIMViewController alloc] init:[CPUIModelManagement sharedInstance].coupleMsgGroup];
            //[self.navigationController pushViewController:single animated:YES];
            
            SingleIndependentProfileViewController *singleIndependentProfile = [[SingleIndependentProfileViewController alloc] initWithUserInfo:[CPUIModelManagement sharedInstance].coupleModel];
            [self.navigationController pushViewController:singleIndependentProfile animated:YES];
            
            
        }
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark controller delegate

-(void)initRecentControls{
    selfAudioButton = [[UIButton alloc] initWithFrame:CGRectZero];
    selfAudioButton.exclusiveTouch = YES;
    coupleAudioButton = [[UIButton alloc] initWithFrame:CGRectZero];
    coupleAudioButton.exclusiveTouch = YES;
    
    [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
    [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
    
    [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
    [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
    
    selfAudioButton.tag = kRemovedRecentControlTag;
    coupleAudioButton.tag = kRemovedRecentControlTag;
    
    [selfAudioButton addTarget:self action:@selector(playSelfAudioRecent) forControlEvents:UIControlEventTouchUpInside];
    [coupleAudioButton addTarget:self action:@selector(playCoupleAudioRecent) forControlEvents:UIControlEventTouchUpInside];
}

-(void)stopAnim{
    if (animView) {
        [animView stop];
    }
}

-(void)startAnim{
    
    if (animView) {
        [animView stop];
        
        NSMutableArray *animPics = [[NSMutableArray alloc] initWithObjects:
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:HP_ANIMI_TYPE_ZOOM_OUT],kAnimType,
                                     @"pic_index_normal01@2x.jpg",kImageName,
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:HP_ANIMI_TYPE_LEFT2RIGHT_UP],kAnimType,
                                     @"pic_index_normal02@2x.jpg",kImageName,
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:HP_ANIMI_TYPE_DOWN],kAnimType,
                                     @"pic_index_normal03@2x.jpg",kImageName,
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:HP_ANIMI_TYPE_ZOOM_IN],kAnimType,
                                     @"pic_index_normal04@2x.jpg",kImageName,
                                     nil],
                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInt:HP_ANIMI_TYPE_RIGHT2LEFT],kAnimType,
                                     @"pic_index_normal05@2x.jpg",kImageName,
                                     nil],
                                    nil];
        
        [animView setImages:animPics];
        [animView run];
    }
}

-(void)swipeLeft:(UISwipeGestureRecognizer *)guesture{
    [self addButtonTaped:nil];
}

-(void)swipeRight:(UISwipeGestureRecognizer *)guesture{
    [self ncButtonTaped:nil];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
 
    animView = [[HomePageAnimView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:animView];
    


    avatarView=[[HomePageAvatarView alloc] initWithFrame:CGRectMake(0, 52+kAvatarAndRecentPadding, 320, 120)];  // 52
    avatarView.backgroundColor = [UIColor clearColor];
    avatarView.delegate = self;
    [self.view addSubview:avatarView];
    
    
    documentView = [[HomePageDocumentView alloc] initWithFrame:CGRectMake(0, 180, 320, 240) contents:nil];
    documentView.delegate = self;
    documentView.textAlignment = HPTextAlignmentCenter;
    [self.view addSubview:documentView];
    
    
    coupleButton = [[HPCoupleButton alloc] initWithFrame:CGRectMake((320-131)/2, 460-51, 131, 51)];
    [self.view addSubview:coupleButton];
    coupleButton.exclusiveTouch = YES;
    [coupleButton addTarget:self action:@selector(coupleButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [coupleButton setBackgroundImage:[UIImage imageNamed:@"menu_btn_dear"] forState:UIControlStateNormal];
    [coupleButton setBackgroundImage:[UIImage imageNamed:@"menu_btn_dear_press"] forState:UIControlStateHighlighted];
    [coupleButton layoutCoupleButton];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(0, 300, 50, 50);
    //[self.view addSubview:back];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [back setTitle:@"update" forState:UIControlStateNormal];
    
    coupleContentBack = [[UIImageView alloc] initWithFrame:CGRectZero];
    coupleContentBack.frame = CGRectMake(0, avatarView.frame.origin.y-8, 320, 87);
    coupleContentBack.image = [[UIImage imageNamed:@"item_index_backgrey"] stretchableImageWithLeftCapWidth:30 topCapHeight:0];
    coupleContentBack.tag = kRemovedRecentControlTag;

    // 第一次启动，上传时间
    /*
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    if (0==personalInfo.singleTime) {
        [[CPUIModelManagement sharedInstance] setSingleTimeWithDate:[NSDate date]];
    }
    */
    //[self reloadData];
    
    [self initRecentControls];
    
    personalLifeStatus = [[CPUIModelManagement sharedInstance].uiPersonalInfo.lifeStatus intValue];
    
    hasBaby = [[[CPUIModelManagement sharedInstance].uiPersonalInfo hasBaby] boolValue];
    
    [self startAnim];
    
    //[[HPStatusBarTipView shareInstance] setHidden:YES];
    //[self showLoadingView];
    
    
    ///////////////////////////////////////////
    
//    UIButton *kbTest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [self.view addSubview:kbTest];
//    [kbTest setTitle:@"keyb" forState:UIControlStateNormal];
//    kbTest.frame = CGRectMake(80, 20, 60, 40);
//    [kbTest addTarget:self action:@selector(kbTestTap) forControlEvents:UIControlEventTouchUpInside];
//    
    keyboard = [KeyboardView sharedKeyboardView];//[[KeyboardView alloc] initWithFrame:CGRectMake(0, 503/2, 320, 460)];
    //keyboard.backgroundColor = [UIColor clearColor];
    //keyboard.hidden = YES;
    
    ncButton  = [[HPNCButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [self.view addSubview:ncButton];
    ncButton.exclusiveTouch = YES;
    [ncButton addTarget:self action:@selector(ncButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [ncButton setBackgroundImage:[UIImage imageNamed:@"index_top_btn_friends"] forState:UIControlStateNormal];
    [ncButton setBackgroundImage:[UIImage imageNamed:@"index_top_btn_friends_press"] forState:UIControlStateHighlighted];
    
    //[ncButton updateCoupleBadge:5];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addButton];
    addButton.exclusiveTouch = YES;
    addButton.frame = CGRectMake(320-60, 0, 60, 60);
    [addButton addTarget:self action:@selector(addButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setBackgroundImage:[UIImage imageNamed:@"index_top_btn_addressbook"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"index_top_btn_addressbook_press"] forState:UIControlStateHighlighted];
    
    //////////////////////////////////////////////    
}



-(void)kbTestTap{
    
    //[self.view addSubview:keyboard];
    

    static BOOL show = YES;
    
    if (show) {
        [[KeyboardView sharedKeyboardView] showInView:self.view];
    }else {
        [[KeyboardView sharedKeyboardView] dismiss];
    }
    
    show = !show;
    
    //keyboard.hidden = !keyboard.hidden;
}

-(void)allFriendTest{
    
    /*
    ALL_FRIENDS_STATE_PROFILE, // profle
    ALL_FRIENDS_STATE_CHAT 
    */
    AllFriendsViewController *controller = [[AllFriendsViewController alloc] initWithState:ALL_FRIENDS_STATE_PROFILE group:nil];
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

-(void)clearHomePage{
    [coupleButton updateCoupleBadge:0];
    // do something?
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadData];
    
    [animView showBackground];
    
    [[AlarmClockHelper sharedInstance] reloadData];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[[HPStatusBarTipView shareInstance] setHidden:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[MusicPlayerManager sharedInstance] stop];
    [MusicPlayerManager sharedInstance].delegate = nil;
    
    [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
    [selfAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
    [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_white"] forState:UIControlStateNormal];
    [coupleAudioButton setBackgroundImage:[UIImage imageNamed:@"btn_im_play_little_grey"] forState:UIControlStateHighlighted];
    
    [animView hideBackground];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //[[HPStatusBarTipView shareInstance] setHidden:NO];
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark document delegate

-(void)dateDidTaped:(HomePageDocumentView *)dcView{
    
    HomePageDatePickerView *datepicker = [[HomePageDatePickerView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
    
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    
    int lifeStatus = [personalInfo.lifeStatus intValue];
    /** 三种类型 
     1,单身     PERSONAL_LIFE_STATUS_DEFAULT  PERSONAL_LIFE_STATUS_SINGLE
     2,喜欢     PERSONAL_LIFE_STATUS_CURSE
     3,couple  PERSONAL_LIFE_STATUS_COUPLE   PERSONAL_LIFE_STATUS_COUPLE_MARRIED PERSONAL_LIFE_STATUS_HAS_BABY
     */
    
    switch (lifeStatus) {
        case PERSONAL_LIFE_STATUS_DEFAULT:
        case PERSONAL_LIFE_STATUS_SINGLE:     //1,单身
        {
            [datepicker setTitle:@"从哪天开始单身的？"];
        }
            
            break;
            
        case PERSONAL_LIFE_STATUS_CURSE:     //2,喜欢
        {
            [datepicker setTitle:@"还记得从哪天开始喜欢Ta的吗？"];
        }
            
            break;
        case PERSONAL_LIFE_STATUS_COUPLE:
        {
            [datepicker setTitle:@"决定在一起的那天是？"];
        }
            break;
        case PERSONAL_LIFE_STATUS_COUPLE_MARRIED:
        {
            [datepicker setTitle:@"结婚纪念日是？"];
        }
            break;
        case PERSONAL_LIFE_STATUS_HAS_BABY:   //3,couple   
        {
            [datepicker setTitle:@"宝宝的生日是？"];

        }
            break;
        default:
            break;
    }

    
    datepicker.delegate =self;
    [datepicker showInView:self.view];
}

#pragma mark -
#pragma mark datepicker delegate

-(void)datePickerDidPickedDate:(NSDate*) date{

    //CPLogInfo(@"[date timeIntervalSinceNow %f",[date timeIntervalSinceNow]);
    
    if ([date timeIntervalSinceNow]<0) {
        
        // 上传时间
        [[CPUIModelManagement sharedInstance] setSingleTimeWithDate:date];
        
        // 刷新时间
        CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
        
        NSTimeInterval fromTime = [personalInfo.singleTime doubleValue]/1000;
        NSTimeInterval toTime = [[NSDate date] timeIntervalSince1970];
        NSString *length = [DateUtil dateStrFrom:fromTime to:toTime];
        
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithCapacity:5];
        [settings setObject:[[NSUserDefaults standardUserDefaults] valueForKey:kSelfCityName] forKey:kHomePageLocation];
        [settings setObject:length forKey:kHomePageDuration];
        documentView.settings = settings; 
    }else {
        [[HPTopTipView shareInstance] showMessage:@"请设置一个过去的时间" duration:2.5f];
    }
}

#pragma mark -
#pragma mark HPStatusBarTipView delegate

-(void)launchIMWithMsgGroup:(CPUIModelMessageGroup *) group{
    [[KeyboardView sharedKeyboardView] clearText];
    CPUIModelMessageGroup *currMsgGroup = group;
    if ([currMsgGroup isMsgMultiGroup]) {   // 群
        
        CPLogInfo(@"isMsgMultiGroup");
        MutilIMViewController *mutil = [[MutilIMViewController alloc] initByUnreadedMessage:group];
        [self.navigationController pushViewController:mutil animated:YES];
        
        return;
    }
    
    if([currMsgGroup.relationType integerValue]==MSG_GROUP_UI_RELATION_TYPE_COUPLE){   // couple
        
        CPLogInfo(@"couple");
        SingleIMViewController *single = [[SingleIMViewController alloc] initByUnreadedMessage:currMsgGroup];
        [self.navigationController pushViewController:single animated:YES];
        
    }/*else if([currMsgGroup.relationType integerValue]==MSG_GROUP_UI_RELATION_TYPE_CLOSER){ // 密友
        
        CPLogInfo(@"closer");

        
        CPUIModelMessageGroupMember *member = [currMsgGroup.memberList objectAtIndex:0]; //只有一个成员
        if ([member.userInfo.type intValue] == USER_MANAGER_XIAOSHUANG) {  // 小双也是特殊密友
            XiaoShuangIMViewController *xiaoshuang = [[XiaoShuangIMViewController alloc] init:currMsgGroup];
            [self.navigationController pushViewController:xiaoshuang animated:YES];
        }else {
            SingleIMViewController *single = [[SingleIMViewController alloc] init:currMsgGroup];
            [self.navigationController pushViewController:single animated:YES];
        }
        
    }*/else{
        CPUIModelMessageGroupMember *member = [currMsgGroup.memberList objectAtIndex:0]; //只有一个成员
        switch ([member.userInfo.type intValue]) {
            case USER_MANAGER_FANXER:  // 凡想团队
            {
                ShuangShuangTeamViewController *team = [[ShuangShuangTeamViewController alloc] initByUnreadedMessage:currMsgGroup];
                [self.navigationController pushViewController:team animated:YES];
            }
                break;
            case USER_MANAGER_SYSTEM:  // 系统消息
            {
                SystemIMViewController *system = [[SystemIMViewController alloc] initByUnreadedMessage:currMsgGroup];
                [self.navigationController pushViewController:system animated:YES];
            }
                break;
            case USER_MANAGER_XIAOSHUANG: // 小双
            {
                XiaoShuangIMViewController *xiaoshuang = [[XiaoShuangIMViewController alloc] initByUnreadedMessage:currMsgGroup];
                [self.navigationController pushViewController:xiaoshuang animated:YES];
            }
                break;
                
            default:
            {
                SingleIMViewController *single = [[SingleIMViewController alloc] initByUnreadedMessage:currMsgGroup];
                [self.navigationController pushViewController:single animated:YES];
            }
                break;
        }
    }

}

-(void)launchIM{
    if ([HPStatusBarTipView shareInstance].modeMsgGroup) {
        [self launchIMWithMsgGroup:[HPStatusBarTipView shareInstance].modeMsgGroup];
    }
}


-(void)launchShuangTeamIM{
    
    CPUIModelMessageGroup *currMsgGroup = [[CPUIModelManagement sharedInstance] getMsgGroupWithUserName:@"shuangshuang"];
//    
//    
    ShuangShuangTeamViewController *team = [[ShuangShuangTeamViewController alloc] init:currMsgGroup];
    [self.navigationController pushViewController:team animated:YES];
//    homeMainViewController = [[HomeMainViewController alloc] init];
//    [homeMainViewController scrollToRect:ContactFriend_NormalFriend];
    
//    [self animateFromViewController:self toViewController:homeMainViewController];
//    [self.navigationController pushViewController:homeMainViewController animated:NO];
}


-(void)statusBarTipViewTaped:(HPStatusBarTipView *)tipView{
    CPLogInfo(@"statusBarTipViewTaped");
    if (tipView.modeMsgGroup) {
        [self launchIMWithMsgGroup:tipView.modeMsgGroup];
    }
}

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    //NSLog(@"alertView.superview      %@",alertView.superview);
    
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"last_update_showing"];
    if (alertView.tag == ALERT_TAG_HAVE_NEW_VERSION) { // 有新版本
        switch (buttonIndex) {
            case 0:  // 以后再说,保存当前时间
                //
            {
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:time] forKey:@"last_update_date"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
                break;
            case 1:  //更新
                //
            {
                NSDictionary *updateMsg = [CPUIModelManagement sharedInstance].checkUpdateResponseDic;
                
                NSString *urlStr = [updateMsg valueForKey:check_update_url];
                
                if (urlStr) {
                    NSURL *url = [NSURL URLWithString:urlStr]; //
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
                break;  
            default:
                break;
        }
    }
    
    if (alertView.tag == ALERT_TAG_NO_NEW_VERSION) {  //已经是最新版本
        // do nothing
    }
}

#pragma mark -
#pragma mark dealloc

-(void)dealloc{

    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"friendMsgUnReadedCount" context:NULL];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"coupleMsgUnReadedCount" context:NULL];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"closedMsgUnReadedCount" context:NULL];
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"coupleTag" context:NULL];
    
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"uiPersonalInfoTag" context:NULL];
    
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"tipsNewMsgDic" context:NULL];
    
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"checkUpdateResponseDic" context:NULL];
    
}

@end
