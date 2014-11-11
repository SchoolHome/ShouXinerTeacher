//
//  SingleChatInforCellBase.h
//  iCouple
//
//  Created by yong wei on 12-5-1.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ChatInforCellBase.h"
#import "ColorUtil.h"

#import "HomePageAvatarView.h"
#import "HPHeadView.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPetSmallAnim.h"
#import "CPUIModelPetMagicAnim.h"
#import "CPUIModelPetFeelingAnim.h"
/*cell顶部的距离*/
#define kCellTopPadding 4

/*重新发送按钮的宽高*/
#define kResendButtonWidth  35.0f
#define kResendButtonHeight 35.0f

/*背景图截取位置*/
#define kBackgroundLeftCapWidth  20.5
#define kBackgroundtopCapHeight  18

/*头像的宽高*/
#define kAvatarWidth    50
#define kAvatarHeight   50

/*声音按钮固定宽高*/
#define kWidthOfSound  48
#define kHeightOfSound 36

/*图片上下左右与外框的距离*/
#define kTopAndButtomPadding (8+3)  //上下距离 ＋ 阴影宽度
#define kLeftAndRightPadding (11+3) //左右距离 ＋ 阴影宽度

/*图片最大宽高*/
#define kMaxImageWidth  124.0f
#define kMaxImageHeight 187.0f

//时间标签高度
//#define kTimestampLabelHeight 15
#define kTimestampLabelHeight 10

//魔法表情气泡最大高度
#define kMagicBackgroundHeight 143

//语音闹钟气泡最大高度
#define kSoundAlarmHeight 167

//神秘语音闹钟气泡最大高度
#define kMysticalSoundAlarmHeight 182

// 损坏闹钟的最大高度
#define kBreakSoundAlarmHeight 80.0f

//闹钟提醒完成气泡高度
#define kSoundAlarmedHeight 179

// 文本闹钟消息上方提醒的高度
#define kTextDateHeight 20.0f

// 闹钟和顶边距离
#define AlarmTopHeight 8.0f

//闹钟和日期的间隔
#define AlarmAndDateDistance 4.0f

// SingleChatInforCellBase单人聊天基础类，仅仅封装单人聊天所共有的行为
@interface SingleChatInforCellBase : ChatInforCellBase<ChatInforInterface>

{
    UIButton *ellipticalBackground;   //圆形背景
    HPHeadView *avatar;                 //头像
    UIButton    *resendButton;           //重新发送按钮
    UILabel     *timestampLabel;         //消息发送时间
}
@property(nonatomic,strong) UIButton *ellipticalBackground;
@property(nonatomic,strong) HPHeadView *avatar;
@property(nonatomic,strong) UIButton    *resendButton;
@property(nonatomic,strong) UILabel     *timestampLabel;

// 闹钟提醒标示
@property(nonatomic,strong) UIButton *alarmTip;

- (id)initWithType : (MessageCellType) messageCellType withBelongMe:(BOOL)isBelongMe withKey:(NSString *)key;
- (void)createAvatarControl;
- (void)createAvatar;
- (void)avatarTaped:(HPHeadView *)sender;
- (void)resendButtonTaped:(UIButton *)sender;

- (void) createAlarmTip;
- (void) showAlarmTip;
- (void) alarmTipTaped : (HPHeadView *)sender;

- (void)adaptEllipticalBackgroundImage;

// 刷新基本控件的位置
- (void)layoutBaseControls;

-(NSString *)timeStringFromNumber:(NSNumber *) number;

-(void)clearResendButton;
-(void)resetResendButton;

@end
