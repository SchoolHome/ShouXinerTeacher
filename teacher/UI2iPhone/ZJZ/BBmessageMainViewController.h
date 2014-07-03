//
//  messageMainViewController.h
//  testSearchBar
//
//  Created by qing zhang on 4/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
//上部分隐藏区域
#define upHidedPartInStatusMid 50.f
//底部隐藏区域
#define bottomHidedPartInStatusMid 30.f
//背景图大小
#define imageviewUpBGInStatusMid 150.f
//头像大小
#define imageviewSingleHeadImageInStatusMid 70.f
#define imageviewHeadImageInStatusMid CGRect_imageviewHeadImgInStatusMid.size.height
#define imageviewGroupHeadImage 70.f
//键盘的y坐标
#define keybordPointY  (460-56)//480-56
//键盘小双帽的高度
#define xiaoshuangNeedHidedHeight 16.f
//键盘显示时候的CGRect
#define CGRect_whenKeybordViewd CGRectMake(0,keybordPointY , 320, 503/2.f+56)

//键盘隐藏时的CGRect
#define CGRect_whenKeybordHided CGRectMake(0,keybordPointY+[self.keybordView currentHeight]+xiaoshuangNeedHidedHeight,0,503/2.f+56)
//下部分view大小，即C区
#define viewDownPartInStatusMid 240.f
//头像后面的横条
#define imageviewHeadImageBGViewInStatusMid 30.f
//在statusMiddle的时候下拖动回弹的范围
#define offsetValueInStatusMid 100.f
//在statusMiddle的时候上拖动回弹的范围
#define offsetValueForUpSwipeInStatusMid 20.f
//在除statusMiddle的时候上下拖动回弹的范围
#define offsetValueInWithoutStatusMid 20.f
//改变状态时的偏移值
//#define offsetValueForChangeStatus 121.f
#define offsetValueForChangeStatus  CGRect_imageviewHeadImgInStatusMid.origin.y - CGRect_imageviewHeadImgInStatusUp.origin.y
//shake动画时下移的偏移值
#define offsetValueDownWhenShaked 89.f

/*
 bug467 改变区域
 */
//当statusDown时上拖头像到X开始隐藏背景
#define offsetValueForDragImageviewHeadInStatusDown 215.f
//背景view在statusMid时的rect
#define CGRect_mainBGViewInStatusMid CGRectMake(0, 0, 320, 460)
//昵称在statusMid时的rect
#define CGRect_nickNameInStatusMid CGRectMake(320-imageviewHeadImageInStatusMid-118,imageviewUpBGInStatusMid+imageviewHeadImageBGViewInStatusMid-imageviewHeadImageInStatusMid/2-21 ,88 , 16.f)
//好友通讯录名字
#define CGRect_contactNameInStatusDown CGRectMake(320-175.f, 460-37.f, 70.f , 11.f)
//背景中的图在statusMid时的rect

//头像的在statusMid时rect
//#define CGRect_imageviewHeadImgInStatusMid CGRectMake(320-imageviewHeadImageInStatusMid-26.5,imageviewUpBGInStatusMid-imageviewHeadImageInStatusMid+21.f , imageviewHeadImageInStatusMid, imageviewHeadImageInStatusMid+2.f)
#define CGRect_imageviewHeadImgInStatusMid CGRectMake(320-self.imageviewHeadImg.frame.size.width-26.5,imageviewUpBGInStatusMid-self.imageviewHeadImg.frame.size.width+21.f , self.imageviewHeadImg.frame.size.width, self.imageviewHeadImg.frame.size.width)
//头像下面横条在statusMid时的rect
#define CGRect_imageviewHeadImgBGViewInStatusMid CGRectMake(0.f, imageviewUpBGInStatusMid-10, 320.f, imageviewHeadImageBGViewInStatusMid)
//IMView在statusMid时的rect
#define CGRect_IMViewInStatusMid CGRectMake(0, imageviewUpBGInStatusMid+imageviewHeadImageBGViewInStatusMid-10, 320, 460-imageviewUpBGInStatusMid-imageviewHeadImageBGViewInStatusMid-CGRect_editpanel.size.height+11)
#define CGRect_editpanel CGRectMake(0.f, 460-[self.keybordView currentHeight], 320.f,[self.keybordView currentHeight])
//昵称在statusUp时的rect
#define CGRect_nickNameInStatusUp CGRectMake(320-imageviewHeadImageInStatusMid-118,imageviewHeadImageInStatusMid/2-10.f ,88 , 16)
#define CGRect_imageviewHeadImgBGViewInStatusUp CGRectMake(0.f,imageviewHeadImageInStatusMid-imageviewHeadImageBGViewInStatusMid, 320.f, imageviewHeadImageBGViewInStatusMid)
//#define CGRect_imageviewHeadImgInStatusUp CGRectMake(320-imageviewHeadImageInStatusMid-26.5, 0, imageviewHeadImageInStatusMid, imageviewHeadImageInStatusMid+2.f)
#define CGRect_imageviewHeadImgInStatusUp CGRectMake(320-self.imageviewHeadImg.frame.size.width-26.5, 0 , self.imageviewHeadImg.frame.size.width, self.imageviewHeadImg.frame.size.width)
#define CGRect_IMViewInStatusUp CGRectMake(0, imageviewHeadImageInStatusMid, 320, 460-imageviewHeadImageInStatusMid-CGRect_editpanel.size.height+1)
#define CGRect_IMViewInStatusDown CGRectMake(0, 460, 320.f, 460-imageviewUpBGInStatusMid-imageviewHeadImageBGViewInStatusMid)
//#define CGRect_imageviewHeadImgInStatusDown  CGRectMake(320-imageviewHeadImageInStatusMid-26.5, 460-imageviewHeadImageInStatusMid, imageviewHeadImageInStatusMid, imageviewHeadImageInStatusMid+2.f)
#define CGRect_imageviewHeadImgInStatusDown CGRectMake(320-self.imageviewHeadImg.frame.size.width-26.5, 460-imageviewHeadImageInStatusMid , self.imageviewHeadImg.frame.size.width, self.imageviewHeadImg.frame.size.width)
#define CGRect_imageviewHeadImgBGViewInStatusDown CGRectMake(0.f, 460-29.f, 320.f, imageviewHeadImageBGViewInStatusMid)
//近况文字frame
#define CGRect_recentTextView CGRectMake(115.f, imageviewUpBGInStatusMid-self.imageviewHeadImg.frame.size.width-25, 180, 50)
//近况语音frame
#define CGRect_recentAudioView CGRectMake(165.f, imageviewUpBGInStatusMid-self.imageviewHeadImg.frame.size.width-25, 130, 50)
#define Btn_Back_ProfileTag 9001
#define Btn_Back_IM 9002
#define Btn_Back_Couple 9003
#define UnReadedLabel 9004
#define CoupleFlagImageview 9005
#define CustomAlertViewTag 9006
#define CoupleAnimationCompleteViewTag 9007
#define labelRecentTextTag 9008
#define labelAudioLengthTag 9009
#define deleteFriendsAlertTag 9010
#define quitGroupAlertTag 9011
#define imageviewKeybordTag 9012
#define selfQuitGroupAlertTag 9013
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AGMedallionView.h"
#import "CPUIModelManagement.h"
#import "CPUIModelMessageGroup.h"
#import "MessageDetailViewController.h"
#import "CPUIModelUserInfo.h"
#import "CPUIModelMessage.h"
#import "CPUIModelMessageGroupMember.h"
#import "HomeInfo.h"
#import "CPUIModelPetSmallAnim.h"
#import "CPUIModelPetMagicAnim.h"
#import "SingleProfileView.h"
#import "GroupProfileView.h"
#import "ProfileView.h"
#import "ImageUtil.h"
#import "CoreUtils.h"
#import "ChangeContactRelation.h"
#import "HPTopTipView.h"
#import "CustomAlertView.h"
#import "LoadingView.h"
#import "ChooseCoupleTypeViewController.h"
#import "ChooseCoupleModel.h"
#import "CoupleCompletedView.h"
#import "RecentView.h"
#import "HPHeadView.h"
#import "MSHeadView.h"
#import "KeyboardView.h"
#import "PalmViewController.h"
//typedef enum
//{
//    message_view_Status_up = 1,
//    message_view_Status_Middle = 2,
//    message_view_Status_Down = 3
//}ViewStatus;
//
//typedef enum
//{
//    IM_Chat_Type_Single = 1,
//    IM_Chat_Type_Group = 2,
//    IM_Chat_Type_Couple = 3
//}IM_Chat_Type;

@interface BBmessageMainViewController :  PalmViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,HeadViewTouchDelegate,KeyboardViewDelegate>
{
    
    //开始的坐标点
    CGPoint beginPoint;
    //判断键盘当前状态
    BOOL    keybordViewed;
    
    //shake动画是否完成
    BOOL    isShakeEnded;
    
    BOOL    isBelongForMe;
    //当前IM类型
    NSInteger userInfoType;
    
    UIImagePickerController *imagePicker;
    //是否重置键盘标示
    BOOL    keybordNeedResetFlag;
    
}
//键盘
@property (nonatomic , strong) KeyboardView *keybordView;
//判断动画已经播过
@property (nonatomic) BOOL animationIsPlayed;
//键盘偏移高度，editPanel的偏移值
@property (nonatomic) CGFloat keybordHeight;
//昵称
//@property (nonatomic , strong) UILabel *nickName;
//@property (nonatomic , strong) UILabel *contactName;
//近况view
//@property (nonatomic , strong) RecentView *recentView;
//头像view (头像imageview+黄条，即A区)
@property (nonatomic , strong) UIImageView *imageviewHeadImgBGView;
//@property (nonatomic , strong) UIImageView *imageviewHeadImg;
@property (nonatomic , strong) MSHeadView *imageviewHeadImg;
//当在statusDown时的未读消息数
@property (nonatomic , strong) UIImageView *unReadedAlert;
@property (nonatomic , strong) UIImageView *unCoupleReadedAlert;
//背景view（个人profile，即B区）
@property (nonatomic , strong)ProfileView *profileView;
@property (nonatomic , strong)SingleProfileView *singleProfileView;
@property (nonatomic , strong)GroupProfileView *groupProfileView;
//背景图
//@property (nonatomic , strong) UIView *mainBGView;
//IM View  (即C区)
@property (nonatomic , strong) UIView *IMView;
////键盘区
//@property (nonatomic , strong) FXEditContainer *editpanel;
//单击or滑动 NO:单击, YES:滑动
@property (nonatomic) BOOL isMoved;
//当前status
@property (nonatomic) NSInteger currentStatus;
//返回按钮
@property (nonatomic , strong)UIButton *buttonBack;
//菊花
@property (nonatomic , strong)LoadingView *loadingView;

//滑动
/****
 statusMid时:上滑动>=120px时会进入statusUp
 下滑动>=120px时会进入statusDown
 statusUp时：下滑动>=40并且<120会进入statusMid
 下滑动>=120时进入statusDown
 statusDown时：上滑动 >= 40并且<120会进入statusMid
 上滑动 >=120进入statusUp
 ****/
//1为靠上，2为靠下
- (void)changeStatusBySwipeLevel : (NSInteger)swipeLevel;
//回弹
/****
 statusMid:上下滑动距离<120px会回弹
 statusUp:下滑动<40会回弹
 statusDown:上滑动<40会回弹
 ****/
- (void)reBoundByCurrentStatus;
//touchMoved时A，B的运行轨迹
/****
 statusMid:  拖动a时:上：B不动，A上移，C上移
 下：B下移，A下移，C下移
 拖动b时：上：没动作
 下：B下移，A下移，C下移
 statusUp：  拖动a时：下：b不动，A下移，当进入statusMid时开始statusMid时的动作
 拖动B时：下：与拖动a一样
 statusDown： 拖动a时：上：b不动，a上移，当>=40后B开始上移直到隐藏部分=100px时B停
 拖动B  ：无反应
 ****/
- (void) scrolledViewWhenViewDraged : (CGFloat)offsetValue;
//是A区域还是B区域,return 1 = B区， return 2 = A区
-(NSInteger) isInUpBGRectOrInHeadImgRect : (CGPoint)tapPoint;
//当需要移动b时调用
-(void) scrolledViewWhenNeedViewTopView;
-(void) scrolledViewWhenNeedHideTopView;
//动画时设置frame
-(void) setFrameWhenAnimationed : (NSUInteger)type;
//拖动是设置frame
-(void) setFrameWhenDraged : (NSInteger)type  : (CGFloat)offsetValue;
//到两边的回弹效果
-(void)setFrameWhenScrollToEnd;
//当statusDown时上滑B区，移动个人profile区,TouchStatus:YES==Move,NO = End
-(void)changeFrameWhenUpSwipeInStatusDown : (CGFloat)offsetValue TouchStatus:(BOOL)statusMoveOrEnd;

- (void)shakeAnimation;


//键盘弹起
-(void)keybordAppear;
-(void)keybordWillDisappear:(NSNotification *)notification;
- (void)keyboardWillShow:(NSNotification *)notification;
//shake动画结束
-(void)endShaked;
//判断point在哪个区域
-(NSInteger) isInUpBGRectOrInHeadImgRect : (CGPoint)tapPoint;
//
-(id)initWithStatus : (NSInteger)status;

//根据button状态改变图
-(void)changeButtonImageByStatus : (NSInteger)btnStatus;
//设置未读数
-(void)setunReadedAlertStatus;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

