//
//  SingleChatInforCellBase.m
//  iCouple
//
//  Created by yong wei on 12-5-1.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "SingleChatInforCellBase.h"

@interface SingleChatInforCellBase(private)
- (void)createellipticalBackground;
- (void)createResendButton;
- (void)createTimestampLabel;
@end


@implementation SingleChatInforCellBase
@synthesize ellipticalBackground;
@synthesize avatar;
@synthesize resendButton;
@synthesize timestampLabel;
@synthesize alarmTip = _alarmTip;

-(NSString *)timeStringFromNumber:(NSNumber *) number{
    NSDate *date =  [CoreUtils getDateFormatWithLong:number];
    date = [CoreUtils convertDateToLocalTime:date];
    
    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
    [inputFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [inputFormat setDateFormat:@"HH:mm"];
    
    NSString *dateStr = [inputFormat stringFromDate:date];
    
    return dateStr;
}

-(void)resendButtonTaped:(UIButton *)sender{
    
    ExMessageModel *exModel = (ExMessageModel *)self.data;
    
    if ([exModel.messageModel.flag intValue] == MSG_FLAG_SEND) {
        // 如果是发送方
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(resendFailedMessage: )]) {
            [self.delegate resendFailedMessage:self];
        }
    }else if ([exModel.messageModel.flag intValue] == MSG_FLAG_RECEIVE) {
        // 如果是接收方
        if (nil != self.delegate && [self.delegate respondsToSelector:@selector(reDownLoadFailedMessage: )]) {
            [self.delegate reDownLoadFailedMessage:self];
        }
    }
}

- (void)avatarTaped:(HPHeadView *)sender{
    //头像事件,子类实现
    ChatInforCellBase *chatInforCellBase = (ChatInforCellBase *)[sender superview];
    ExMessageModel *exMessage = (ExMessageModel *)chatInforCellBase.data;
    if ([self.delegate respondsToSelector:@selector(clickedAvatar: )]) {
        [self.delegate clickedAvatar:exMessage.messageModel.msgSenderName];
    }
}

- (void)createEllipticalBackground;{
    UIButton *ellipticalBackground1 = [[UIButton alloc] initWithFrame:CGRectZero];
    self.ellipticalBackground = ellipticalBackground1;
    ellipticalBackground1 = nil;
}


- (void)createResendButton{
    self.resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resendButton addTarget:self action:@selector(resendButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [resendButton setBackgroundImage:[UIImage imageNamed:@"icon_losemessage_red.png"] forState:UIControlStateNormal];
    [resendButton setBackgroundImage:[UIImage imageNamed:@"icon_losemessage_darkenred.png"] forState:UIControlStateHighlighted];
    resendButton.exclusiveTouch = YES;
}

-(void)clearResendButton{
    [resendButton setBackgroundImage:nil forState:UIControlStateNormal];
    [resendButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    
    for (UIView *aView in [resendButton subviews]) {
        if ([aView isKindOfClass:[UIActivityIndicatorView class]]) {
            [aView removeFromSuperview];
        }
    }
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.frame = CGRectMake(0, 0, kResendButtonWidth, kResendButtonHeight);
    [resendButton addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
}

-(void)resetResendButton{
    [resendButton setBackgroundImage:[UIImage imageNamed:@"icon_losemessage_red.png"] forState:UIControlStateNormal];
    [resendButton setBackgroundImage:[UIImage imageNamed:@"icon_losemessage_darkenred.png"] forState:UIControlStateHighlighted];
    
    for (UIView *aView in [resendButton subviews]) {
        if ([aView isKindOfClass:[UIActivityIndicatorView class]]) {
            [aView removeFromSuperview];
        }
    }
}

- (void)createTimestampLabel{
    UILabel *timestampLabel1 = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timestampLabel = timestampLabel1;
    timestampLabel1 = nil;
    timestampLabel.textAlignment = UITextAlignmentCenter;
    timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
    timestampLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    timestampLabel.shadowColor = [UIColor whiteColor];
    timestampLabel.shadowOffset = CGSizeMake(0, 1);
    timestampLabel.backgroundColor = [UIColor clearColor];
}

- (void)createAvatarControl{
    HPHeadView *avatar1 = [[HPHeadView alloc] initWithFrame:CGRectZero];
    avatar1.backgroundColor = [UIColor clearColor];
    self.avatar = avatar1;
    avatar1 = nil;
    [self addSubview:avatar];
//    [avatar addTarget:self action:@selector(avatarTaped:) forControlEvents:UIControlEventTouchUpInside];
//    avatar.layer.borderColor = [UIColor whiteColor].CGColor;
//    avatar.layer.borderWidth = 2;
//    avatar.layer.masksToBounds = YES;
//    avatar.layer.cornerRadius = kAvatarWidth/2.0f;
    avatar.borderWidth = 5;
    avatar.cycleImage = [UIImage imageNamed:@"headpic_index_50x50"];
//    avatar.maskImage = [UIImage imageNamed:@"headpic_index_press_120x120"];
}

- (void)createAlarmTip{
    
    self.alarmTip = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.alarmTip.frame = CGRectZero;
    [self.alarmTip addTarget:self action:@selector(alarmTipTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.alarmTip];
//    self.alarmTip = [[HPHeadView alloc] initWithFrame:CGRectZero];
//    self.alarmTip.backgroundColor = [UIColor clearColor];
//    
//    [self.alarmTip addTarget:self action:@selector(alarmTipTaped:) forControlEvents:UIControlEventTouchUpInside];
//    self.alarmTip.borderWidth = 5;
//    self.alarmTip.cycleImage = [UIImage imageNamed:@"headpic_index_50x50"];
}

-(void) showAlarmTip{
    
}

- (void) alarmTipTaped : (HPHeadView *)sender{
    
}

- (void)createAvatar{
    //子类实现

}

- (void)adaptEllipticalBackgroundImage{
    UIImage *ellipticalImage = nil;
    
    UIImage *ellipticalImagePress = nil;
    
    if (self.isBelongMe) {
        ellipticalImage = [UIImage imageNamed:@"i_talk"];  // bg_im_talk_gray_press
        
        ellipticalImagePress = [UIImage imageNamed:@"i_talk"];
        
    }else {
        ellipticalImage = [UIImage imageNamed:@"other_talk"];  // bg_im_talk_white_press
        
        ellipticalImagePress = [UIImage imageNamed:@"other_talk"];
    }
    ellipticalImage = [ellipticalImage stretchableImageWithLeftCapWidth:kBackgroundLeftCapWidth topCapHeight:kBackgroundtopCapHeight];
    
    ellipticalImagePress = [ellipticalImagePress stretchableImageWithLeftCapWidth:kBackgroundLeftCapWidth topCapHeight:kBackgroundtopCapHeight];
    
    //ellipticalBackground.image = ellipticalImage;
    
    [ellipticalBackground setBackgroundImage:ellipticalImage forState:UIControlStateNormal];
    [ellipticalBackground setBackgroundImage:ellipticalImagePress forState:UIControlStateHighlighted];
    
}

- (id)initWithType : (MessageCellType) messageCellType withBelongMe:(BOOL)isBelongMe withKey : (NSString *) key{
    self = [super initWithType:messageCellType withBelongMe:isBelongMe withKey:key];
    if (self) {
        
        //创建头像
        [self createAvatar];
        
        //创建椭圆背景
        [self createEllipticalBackground];
        
        //当是自己发的消息的时候，才需要创建按钮
        if (isBelongMe) {    
            [self createResendButton];
        }
        //创建时间戳
        [self createTimestampLabel];
    }
    return self;
}


-(void)refreshCell{
    [super refreshCell];
    
    //按顺序添加控件，子类只修改其frame
    [self addSubview:ellipticalBackground];
    [self addSubview:avatar];
    [self addSubview:resendButton];
    [self addSubview:timestampLabel];
    [self layoutBaseControls];
}


- (void)refreshResendButton{
    //子类实现

    /*
     MSG_SEND_STATE_SENDING = 1,//发送中
     MSG_SEND_STATE_SEND_SUCESS = 2,//发送成功
     MSG_SEND_STATE_SEND_ERROR = 3,//发送失败
     
     MSG_SEND_STATE_DOWNING = 4,//下载中
     MSG_SEND_STATE_DOWN_SUCESS = 5,//下载成功
     MSG_SEND_STATE_DOWN_ERROR = 6,//下载失败
    */
    
    ExMessageModel *model = (ExMessageModel*)self.data;
    
    if (nil == resendButton) {
        self.resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.resendButton addTarget:self action:@selector(resendButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [resendButton setBackgroundImage:[UIImage imageNamed:@"icon_losemessage_red.png"] forState:UIControlStateNormal];
        [resendButton setBackgroundImage:[UIImage imageNamed:@"icon_losemessage_darkenred.png"] forState:UIControlStateHighlighted];
        resendButton.exclusiveTouch = YES;
    }
    
    resendButton.hidden = NO;
    resendButton.userInteractionEnabled = YES;
    
    switch ([model.messageModel.sendState intValue]) {
        case MSG_SEND_STATE_SENDING:
            resendButton.userInteractionEnabled = NO;
            [self clearResendButton];
            CPLogInfo(@"-------------------------发送中");
            break;
        case MSG_SEND_STATE_SEND_SUCESS:
            resendButton.hidden = YES;
            CPLogInfo(@"-------------------------发送安全");
            break;
        case MSG_SEND_STATE_SEND_ERROR:
            [self resetResendButton];
            resendButton.hidden = NO;
            CPLogInfo(@"-------------------------发送错误");
            break;
        case MSG_SEND_STATE_DOWNING:
            resendButton.userInteractionEnabled = NO;
            [self clearResendButton];
            CPLogInfo(@"-------------------------下载中");
            break;
        case MSG_SEND_STATE_DOWN_SUCESS:
            resendButton.hidden = YES;
            CPLogInfo(@"-------------------------下载成功");
            break;
        case MSG_SEND_STATE_DOWN_ERROR:
            [self resetResendButton];
            resendButton.hidden = NO;
            CPLogInfo(@"-------------------------下载失败");
        default:
            resendButton.hidden = YES;
            break;
    }
}

-(void)layoutBaseControls{
    //子类实现
    resendButton.frame = CGRectMake(320 - kResendButtonWidth - 5, 5, kResendButtonWidth, kResendButtonHeight);
}

// 计算cell的高度
-(float) CalculateCellHeight{
    return 0.0f;
}

@end
