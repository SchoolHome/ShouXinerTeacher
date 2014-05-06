//
//  IMViewController.h
//  iCouple
//
//  Created by qing zhang on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "messageMainViewController.h"
#import "MessageDetailViewController.h"
#import "RecentView.h"
#import "PetView.h"
#import "HomePageSelfProfileViewController.h"
#import "SingleIndependentProfileViewController.h"
#import "CustomAlertView.h"
#import "FXBlockViewSubmit.h"

//typedef enum {
//    MAGIC_DOWNLOAD_TYPE_NONE_IM,
//    MAGIC_DOWNLOAD_TYPE_SINGLE_IM,
//    MAGIC_DOWNLOAD_TYPE_ALL_IM
//}MAGIC_DOWNLOAD_TYPE_IM;
//
//
//typedef enum {
//    MAGIC_DOWNLOAD_TYPE_NONE,
//    MAGIC_DOWNLOAD_TYPE_SINGLE,
//    MAGIC_DOWNLOAD_TYPE_MULTI
//}MAGIC_DOWNLOAD_TYPE;

@interface IMViewController : messageMainViewController <RecentViewDelegate,MessageInforDelegate,MusicPlayerManagerDelegate,PetViewDelegate,UIImagePickerControllerDelegate,CheckMessageDelegate,FXBlockViewSubmitDelegate>
{
    CheckMessageView *check;
    FXBlockViewSubmit * block_view_submit;
    BOOL _hideAlert;
    NSString * _magicID;
    NSString * _petID;
//    MAGIC_DOWNLOAD_TYPE _magicDownloadType;
    

}
//是否删除messagegroup
@property (nonatomic )BOOL    msgGroupNeedRemove;
@property (nonatomic , strong)MessageDetailViewController *detailViewController;

@property (nonatomic , strong)CPUIModelMessageGroup *modelMessageGroup;
//右上角跳转初始化
-(id)initByUnreadedMessage:(CPUIModelMessageGroup *)messageGroup;
-(id)init : (CPUIModelMessageGroup *)messageGroup;
//页面退出时需要设置的属性
-(void)needResetProperty:(BOOL)needRemoveMsgGroup andNeedResetKeybord:(BOOL)needReset;
//返回单人头像Image
-(UIImage *)returnCircleHeadImg;
//关闭内容区声音
-(void)stopMessageDetailSound;
//跳转到陌生人profile(CPUIModelUserInfo)
-(void)turnToContactProfileWithCPUIModelUserInfo:(CPUIModelUserInfo *)userInfo;
//跳转到陌生人profile(UserInfoModel)
-(void)turnToContactProfileWithUserInfoModel:(UserInforModel *)userInfo;
//跳转到自己的profile
-(void)turnToMySelfProfile;
//跳转到好友的独立profile
-(void)turnToFriendProfileWithUserInfo:(CPUIModelUserInfo *)friendUserInfo;
//返回
-(void)backToHome:(UIButton *)sender;
//停止语音
-(void)stopMusicPlayer;
@end
