//
//  HomePageSelfProfileViewController.m
//  iCouple
//
//  Created by ming bright on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomePageSelfProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "HPStatusBarTipView.h"
#import "HPTopTipView.h"

#import "ColorUtil.h"
#import "ImageUtil.h"

#import "CoreUtils.h"
#import "TPCMToAMR.h"

#import "AppDelegate.h"
#import "HomePageViewController.h"

#import "AlarmClockHelper.h"

#define kRecentStatusDefaultHeight    38
#define kRecentStatusDefaultWidth     193.5
#define kRecentStatusMaxHeight        55

#define kNickNameHeight     25
#define kNickNameMinWidth   70
#define kNickNameMaxWidth   160

#define kNickNameMoveUp         (66+5)
#define kRecentStatusMoveUp     (120+7)

#define kAvatarSelfOriginY      170

#define kNickNameOriginY        248
#define kRecentStatusOriginY    (285+7)
#define kSexPickerOriginY       370

#define kDefaultNickName      @"匿名"

@interface HomePageSelfProfileViewController ()
-(void)setNickName:(NSString *)name;
-(void)setTextRecentStatus:(NSString *)text;
-(void)layoutNickName;
-(void)layoutStatusAndInfo;

-(void)resetBaseView;
-(void)baseViewNickUp;
-(void)baseViewStatusUp;
-(void)reloadData;
@end

@implementation HomePageSelfProfileViewController
@synthesize cacheBgImage;
@synthesize cacheSelfAvatarImage;
@synthesize casheBabyAvatarImage;
@synthesize isUpdateTaped;

-(id)init{
    self = [super init];
    if (self) {
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"uiPersonalInfoTag" options:0 context:NULL];
    }
    
    return self;
}

#pragma mark -
#pragma mark observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqual:@"uiPersonalInfoTag"]) {
        CPLogInfo(@"uiPersonalInfoTag");
        
        
        if (!isBgChanged&&
            !isSelfAvatarChanged&&
            !isBabyAvatarChanged&&
            !isRecentChanged&&
            !isRecentChanged&&
            !isNickSexBabyChanged
            ) {
            [self reloadData];
        }
        
        
    }
    
}

#pragma mark -
#pragma mark layout dynamic controls

-(void)layoutNickName{
    
    // 根据nickname 文字内容，设置位置大小
    
    if ([nickNameTextField.text length] == 0) {  //一个文字都没有
        CGFloat w = kNickNameMinWidth;
        nickNameTextField.frame = CGRectMake((320 - w)/2, kNickNameOriginY, w, kNickNameHeight);
        nickNameBackground.frame = CGRectMake((320 - w-20)/2, kNickNameOriginY-3, w+20, 32);
        return;
    }
    
    [nickNameTextField sizeToFit];
    CGFloat w = nickNameTextField.frame.size.width;
    if (w<kNickNameMinWidth) {
        w = kNickNameMinWidth;
    }
    if (w>kNickNameMaxWidth) {
        w = kNickNameMaxWidth;
    }
    nickNameTextField.frame = CGRectMake((320 - w)/2, kNickNameOriginY, w, kNickNameHeight);
    
    nickNameBackground.frame = CGRectMake((320 - w-20)/2, kNickNameOriginY-3, w+20, 32);
    
    sexPickerView.frame = CGRectMake(nickNameBackground.frame.origin.x+nickNameBackground.frame.size.width+5, 242, 34, 34);
}

-(void)layoutStatusAndInfo{
    
    // 根据近况的文字，设置recentStatusTexiView 位置大小
    CGFloat h = recentStatusTexiView.contentSize.height;
    if (h>kRecentStatusMaxHeight) {
        h = kRecentStatusMaxHeight;
    }
    
    if (convertButton.hidden) {  //文字居中
        recentStatusTexiView.frame = CGRectMake((320-kRecentStatusDefaultWidth+10)/2, kRecentStatusOriginY, kRecentStatusDefaultWidth-10, h);
    }else {
        recentStatusTexiView.frame = CGRectMake((320-kRecentStatusDefaultWidth+10)/2, kRecentStatusOriginY, kRecentStatusDefaultWidth-40, h);
    }
    
    
    recentStatusTexiView.backgroundColor = [UIColor clearColor];
    recentStatusBackground.frame = CGRectMake((320-kRecentStatusDefaultWidth)/2, kRecentStatusOriginY-7, kRecentStatusDefaultWidth, h+10);// recentStatusTexiView.frame;
    
    //根据recentStatusTexiView位置，计算infoLabel的位置
    infoLabel.frame = CGRectMake(infoLabel.frame.origin.x, 
                                 (recentStatusTexiView.frame.origin.y+h), infoLabel.frame.size.width, infoLabel.frame.size.height);
    
    convertButton.frame = CGRectMake(recentStatusBackground.frame.origin.x+recentStatusBackground.frame.size.width-31, kRecentStatusOriginY+recentStatusBackground.frame.size.height - 30.5-10, 31, 30.5);
    
    if ([recentStatusTexiView.text length]>0) {
        recentStatusPlaceholder.hidden = YES;
    }else {
        recentStatusPlaceholder.hidden = NO;
    }
}


#pragma mark -
#pragma mark baseView animations

-(void)resetBaseView{
    [UIView animateWithDuration:0.3 
                     animations:^{
                         baseView.center = CGPointMake(baseView.center.x, 240);
                     } completion:^(BOOL finished) {
                         
                     }];
}

-(void)baseViewNickUp{
    [UIView animateWithDuration:0.3 
                     animations:^{
                         baseView.center = CGPointMake(baseView.center.x, 240-kNickNameMoveUp);
                     } completion:^(BOOL finished) {
                     }];
}


-(void)baseViewStatusUp{
    if (recentStatusTexiView.frame.size.height > kRecentStatusDefaultHeight+1) {  // 多行文字的时候
        [UIView animateWithDuration:0.3 
                         animations:^{
                             baseView.center = CGPointMake(baseView.center.x, 
                                                           240-kRecentStatusMoveUp-recentStatusTexiView.frame.size.height+kRecentStatusDefaultHeight);
                         } completion:^(BOOL finished) {
                         }];
    }else {   // 默认一行文字的时候
        [UIView animateWithDuration:0.3 
                         animations:^{
                             baseView.center = CGPointMake(baseView.center.x, 240-kRecentStatusMoveUp+6);
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}


#pragma mark -
#pragma mark set contents

-(void)setNickName:(NSString *)name{
    nickNameTextField.text = name;
    [self layoutNickName];
}

-(void)setTextRecentStatus:(NSString *)text{
    recentStatusTexiView.text = text;
    [self layoutStatusAndInfo];
}


- (void)shake:(UIView *)view{
    CABasicAnimation *animation = 
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.05];
    [animation setRepeatCount:3];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([view center].x - 20.0, [view center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([view center].x + 20.0, [view center].y)]];
    [[view layer] addAnimation:animation forKey:@"position"];

}

#pragma mark -
#pragma mark button Actions

-(void)backButtonTaped:(UIButton *)sender{
    [self baseViewTaped:nil];
    self.isUpdateTaped = NO;
    // 更新数据
    [self saveProfile];
    
    
    
}
-(void)changePwdButtonTaped:(UIButton *)sender{
    

    HomePageModifyPasswordViewController *modifyController = [[HomePageModifyPasswordViewController alloc] init];
    [self.navigationController pushViewController:modifyController animated:YES];
    modifyController = nil;
    
    
}

-(void)logoutButtonTaped:(UIButton *)sender{


    // 退出帐号时，务必清除消息提示
    [[HPStatusBarTipView shareInstance] dismiss];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确定退出登录吗？" 
                                                       delegate:self 
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:@"确定退出" 
                                              otherButtonTitles:nil];
    sheet.tag = ProfileAlertTagLogout;
    [sheet showInView:self.view];


}


-(void)weiboButtonTaped:(UIButton *)sender{
    [self baseViewTaped:nil];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"干啥呢？" 
                                                       delegate:self 
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:@"关注“凡想双双”",@"检查新版本",@"给个好评",nil];
    sheet.tag = ProfileAlertTagWeibo;
    [sheet showInView:self.view];
}

-(void)saveProfile{
    
    if ([nickNameTextField.text length]<1) {
        [self shake:nickNameTextField];
        [self shake:nickNameBackground];
        [[HPTopTipView shareInstance] showMessage:@"稍等！输入昵称再离开"];
        return;
    }
    
    // 近况
    
    if (isRecentChanged) {
        if (isStatusText) {  //当前是文本近况
            [[CPUIModelManagement sharedInstance] updateMyRecentInfoWithContent:recentStatusTexiView.text andType:PERSONAL_RECENT_TYPE_TEXT];
            
        }else {
            CPLogInfo(@"upload audio!!");
            //NSString *path = [[CoreUtils getDocumentPath] stringByAppendingPathComponent:@"/audio_recent_amr.amr"];
            //NSString *path = [[CoreUtils getDocumentPath] stringByAppendingPathComponent:@"/audio_recent_wav.wav"];
            NSString *path = [[[CPUIModelManagement sharedInstance] getAccountFilePath]  stringByAppendingPathComponent:@"/audio_recent_wav.wav"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {  //文件存在才更新语音近况
                [[CPUIModelManagement sharedInstance] updateMyRecentInfoWithContent:path andType:PERSONAL_RECENT_TYPE_AUDIO];
            }else {
                [[CPUIModelManagement sharedInstance] updateMyRecentInfoWithContent:recentStatusTexiView.text andType:PERSONAL_RECENT_TYPE_TEXT];
            }
        }
    }
    
    // 背景
    if (isBgChanged) {
//        [[CPUIModelManagement sharedInstance] uploadPersonalBgImgWithData:UIImagePNGRepresentation(self.cacheBgImage)];
        [[CPUIModelManagement sharedInstance] uploadPersonalBgImgWithData:UIImageJPEGRepresentation(self.cacheBgImage, 0.8f)];
    }

    // 头像
    if (isSelfAvatarChanged) {
//        [[CPUIModelManagement sharedInstance] uploadPersonalHeaderImgWithData:UIImagePNGRepresentation(self.cacheSelfAvatarImage)];
        [[CPUIModelManagement sharedInstance] uploadPersonalHeaderImgWithData:UIImageJPEGRepresentation(self.cacheSelfAvatarImage, 0.8f)];
    }
    
    if (isBabyAvatarChanged) {
        [[CPUIModelManagement sharedInstance] uploadPersonalBabyImgWithData:UIImagePNGRepresentation(self.casheBabyAvatarImage)];
    }
    
    // 昵称，性别 ，宝宝
    
    if (isNickSexBabyChanged) {
        
        if ((!self.casheBabyAvatarImage)&&switcher.on) {  // 没有头像,开关打开，还是没有宝宝
            [[CPUIModelManagement sharedInstance] updatePersonalInfoWithNickName:nickNameTextField.text 
                                                                          andSex:sexPickerView.sex 
                                                                   andHiddenBaby:[NSNumber numberWithBool:YES]];
        }else {
            [[CPUIModelManagement sharedInstance] updatePersonalInfoWithNickName:nickNameTextField.text 
                                                                          andSex:sexPickerView.sex 
                                                                   andHiddenBaby:[NSNumber numberWithBool:switcher.on]];
        }
        
        

    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveButtonTaped:(UIButton *)sender{

    
}

-(void)showActionSheet{
    UIActionSheet *actionsheet=[[UIActionSheet alloc] initWithTitle:@"选择照片" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"取  消" 
                                             destructiveButtonTitle:nil 
                                                  otherButtonTitles:@"拍  照",@"从相册选择", nil];
    actionsheet.tag = ProfileAlertTagImage;
    [actionsheet showInView:self.view];
}


-(void)profileBackgroundTaped:(UITapGestureRecognizer *) guesture{
    [self baseViewTaped:nil];
    imageType = ImageSelectedTypeBackground;
    [self showActionSheet];
}

//-(void)changeButtonTaped:(UIButton *)sender{
//    
//    imageType = ImageSelectedTypeBackground;
//    
//    [self showActionSheet];
//}



-(void)avatarSelfTaped:(UIButton *)sender{

    imageType = ImageSelectedTypeAvatarSelf;
    
    [self showActionSheet];
}


-(void)avatarBabyTaped:(UIButton *)sender{

    
    imageType = ImageSelectedTypeAvatarBaby;

    [self showActionSheet];
}

/*
-(void)avatarCoupleTaped:(UIButton *)sender{
    imageType = ImageSelectedTypeAvatarCouple;
      
    [self showActionSheet];
}
*/

-(void)clearButtonTaped:(UIButton *)sender{
    
    if (isStatusText) {
        //
        recentStatusTexiView.text = nil;
    }else {
        //
        
    }
}

-(void)refreshButtonTaped:(UIButton *)sender{
    
    isRecentChanged = YES;
    
    [recentStatusTexiView resignFirstResponder];
    [self resetBaseView];
    isNickNameUp = NO;
    isRecentStatusUp = NO;
    
    // 准备录音状态
    [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_playbegin"] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_playbeginpress"] forState:UIControlStateHighlighted];
    
    
    //remove
    [recordButton removeTarget:self action:@selector(playRecentAudio) forControlEvents:UIControlEventTouchUpInside];
    
    //add
    [recordButton addTarget:self action:@selector(recordDidBegin) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpOutside];
    [recordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchCancel];
    
    
    //isStatusText = YES;
    
    // 点击更新时 清除原来的语音近况，然后开始进入编辑状态
    convertButton.hidden = NO;
    refreshButton.hidden = YES;
    lengthLabel.hidden = YES;
    
    // 必要时停止播放
    [[MusicPlayerManager sharedInstance] stop];
    
    // 删除文件
    NSString *path2 = [[[CPUIModelManagement sharedInstance] getAccountFilePath]  stringByAppendingPathComponent:@"/audio_recent_wav.wav"];
    [[NSFileManager defaultManager] removeItemAtPath:path2 error:nil];
}


-(void)baseViewTaped:(UIButton *)sender{
    [nickNameTextField resignFirstResponder];
    [recentStatusTexiView resignFirstResponder];
    
    if (isNickNameUp||isRecentStatusUp) {
        [self resetBaseView];
    }
    
    isNickNameUp = NO;
    isRecentStatusUp = NO;
    
    
    if (isStatusText) {
        convertButton.hidden = YES;
    }
    
    [self layoutStatusAndInfo];
    
    if (recordButton.hidden == NO) {  //录音状态，重置convert按钮
        convertButton.frame = CGRectMake((320-kRecentStatusDefaultWidth)/2+kRecentStatusDefaultWidth-31, kRecentStatusOriginY, 31, 30.5);
    }
    
    if (!recordButton.hidden) {
        infoLabel.frame = CGRectMake(0, 325, 320, 20);
    }
}


-(void)convertButtonTaped:(UIButton *)sender{
    
    
//    if (isStatusText) {
//        self.oldTextRecent = recentStatusTexiView.text;
//    }
    
    isStatusText = !isStatusText;
    
    
    //recentStatusTexiView.text = nil;
    
    
    // 重置所有控件位置
    
    convertButton.frame = CGRectMake((320-kRecentStatusDefaultWidth)/2+kRecentStatusDefaultWidth-31, kRecentStatusOriginY, 31, 30.5);
    if (isStatusText) {
        [self layoutStatusAndInfo];
    }

    // 设置可见状态
    [self convert:isStatusText];
    
    // 控制键盘状态
    if (isStatusText) {
        refreshButton.hidden = YES;
        [recentStatusTexiView becomeFirstResponder];

    }else {
        refreshButton.hidden = NO;
        [recentStatusTexiView resignFirstResponder];
        [self resetBaseView];
        isNickNameUp = NO;
        isRecentStatusUp = NO;
    }
    refreshButton.hidden = YES;
    
    if (!recordButton.hidden) {
        infoLabel.frame = CGRectMake(0, 325, 320, 20);
    }
    
}


-(void)convert:(BOOL) isStatusText_{
    if (isStatusText) {
        [convertButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_speak"] forState:UIControlStateNormal];
        recentStatusTexiView.hidden = NO;
        recentStatusBackground.hidden = NO;
        recordButton.hidden = YES;
 
    }else {
        [convertButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_write"] forState:UIControlStateNormal];
        recentStatusTexiView.hidden = YES;
        recentStatusBackground.hidden = YES;
        recordButton.hidden = NO;
    }
}

//-(void) audioPlayerDidFinishPlaying{
//    CPLogInfo(@"audioPlayerDidFinishPlaying");
//    [[AudioPlayerManager sharedManager] stopBackgroundMusic];
//}
#pragma mark -
#pragma mark audio

//-(void)musicPlayer:(MusicPlayerManager *) player playToTime:(NSTimeInterval) time playerName:(NSString *)name{
//    
//    lengthLabel.text = [NSString stringWithFormat:@"%ds",musicLength - (int)time];
//
//}

-(void)musicPlayerDidFinishPlaying:(MusicPlayerManager *) player playerName:(NSString *)name{
     CPLogInfo(@"musicPlayerDidFinishPlaying");
    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:name]) {
//        int length = (int)[[MusicPlayerManager sharedInstance] musicLength:name];
//        lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
//    }
    
    [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_play"] forState:UIControlStateNormal];
}

-(void)musicPlayerDecodeErrorDidOccur:(MusicPlayerManager *) player error:(NSError *)error playerName:(NSString *)name{
    CPLogError(@"musicPlayerDidFinishPlaying");
    
    [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_play"] forState:UIControlStateNormal];
}


-(void)playRecentAudio{
    
    CPLogInfo(@"playRecentAudio");
    
    NSString *path2 = [[[CPUIModelManagement sharedInstance] getAccountFilePath]  stringByAppendingPathComponent:@"/audio_recent_wav.wav"];
    NSString *amrPath = [CPUIModelManagement sharedInstance].uiPersonalInfo.recentContent;
    
    NSString *wavPath;
    if (amrPath) {
        wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {  // 转网络的amr－> wav
            [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
        }
    }

    NSString *playPath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path2]) {
        playPath = path2;
    }
    
    if (!isRecordFinished) {   // 这次操作没有录音，以网络的为准
        if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
            playPath = wavPath;     
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:playPath]) {
        CPLogInfo(@"play");
        if ([[MusicPlayerManager sharedInstance] isPlaying]) {
            [[MusicPlayerManager sharedInstance] stop];
            [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_play"] forState:UIControlStateNormal];

        }else {
            [MusicPlayerManager sharedInstance].delegate = self;
            [[MusicPlayerManager sharedInstance] playMusic:playPath playerName:playPath];
            [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_pause"] forState:UIControlStateNormal];
        }

    }
}

-(void)recordDidBegin{

    if (convertButton.hidden == NO) {       // 开始录音
        
         CPLogInfo(@"doBeginRecord");
        
        [[MusicPlayerManager sharedInstance] stop];
        
//        [self.view addSubview:micMeter];
//        [micMeter doBeginCountDown];
        [micView startRecord];

    }else {                            // 播放录音
        //
        
        CPLogInfo(@"do nothing");
    }
}

-(void)recordDidFinish{

     CPLogInfo(@"recordDidFinish");
    [micView stopRecord];


}



-(UIImage *)imageFromPath:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:data];
    if (!image) {
        return [UIImage imageNamed:@"headpic_index_normal_120x120"];
    }
    return image;
}

-(UIImage *)babyImageFromPath:(NSString *)path{
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    if (!image) { 
        return [UIImage imageNamed:@"headpic_gray_baby_120x120"];
    }
    return image;
}


-(void)layoutBaby{
    [UIView animateWithDuration:0.2 animations:^{
        if (switcher.on) {
            babyNickNameLabel.frame = CGRectMake(130, 215, 40, 15);
            avatarBaby.frame = CGRectMake((320-70)/2.0f - 55+5+55, kAvatarSelfOriginY+15, 55, 55);
        }else {
            babyNickNameLabel.frame = CGRectMake(40, 215, 40, 15);
            avatarBaby.frame = CGRectMake((320-70)/2.0f - 55+10, kAvatarSelfOriginY+15, 55, 55);
        }
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)layoutRecordButton{
    
    if (isStatusText) {
        [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_playbegin"] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_playbeginpress"] forState:UIControlStateHighlighted];
        
        
        // remove
        [recordButton removeTarget:self action:@selector(playRecentAudio) forControlEvents:UIControlEventTouchUpInside];
        
        
        [recordButton addTarget:self action:@selector(recordDidBegin) forControlEvents:UIControlEventTouchDown];
        [recordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpInside];
        [recordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpOutside];
        [recordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchCancel];
        
        lengthLabel.hidden = YES;
        
    }else {
        [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_play"] forState:UIControlStateNormal];
        [recordButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        
        [recordButton removeTarget:self action:@selector(recordDidBegin) forControlEvents:UIControlEventTouchDown];
        [recordButton removeTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpInside];
        [recordButton removeTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpOutside];
        [recordButton removeTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchCancel];
        
        // add
        [recordButton addTarget:self action:@selector(playRecentAudio) forControlEvents:UIControlEventTouchUpInside];
        
        convertButton.hidden = YES;
        lengthLabel.hidden = NO;
        

        
        NSString *path2 = [[[CPUIModelManagement sharedInstance] getAccountFilePath]  stringByAppendingPathComponent:@"/audio_recent_wav.wav"];
        NSString *amrPath = [CPUIModelManagement sharedInstance].uiPersonalInfo.recentContent;
        
        NSString *wavPath;
        if (amrPath) {
            wavPath = [[amrPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {  // 转网络的amr－> wav
                [TPCMToAMR doConvertAMRFromPath:amrPath toPCMPath:wavPath];
            }
        }
        
        NSString *playPath;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path2]) {
            playPath = path2;
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:wavPath]) {
            playPath = wavPath;     // 以网络的为准
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:playPath]) {
            int length = (int)[[MusicPlayerManager sharedInstance] musicLength:playPath];
            musicLength = length;
            
            lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
        }
    }
}

-(void)reloadData{
    
    CPUIModelPersonalInfo *personalInfo = [CPUIModelManagement sharedInstance].uiPersonalInfo;
    CPUIModelUserInfo *coupleInfo = [CPUIModelManagement sharedInstance].coupleModel;
    
    CPLogInfo(@"selfCoupleHeaderImgPath %@",personalInfo.selfCoupleHeaderImgPath);
    CPLogInfo(@"selfHeaderImgPath %@",personalInfo.selfHeaderImgPath);
    CPLogInfo(@"selfBabyHeaderImgPath %@",personalInfo.selfBabyHeaderImgPath);
    
    // 背景图
    
    NSData *data = [NSData dataWithContentsOfFile:personalInfo.selfBgImgPath];
    UIImage *image = [[UIImage alloc] initWithData:data];
    profileBackground.image = image;
    if (!image) {
        profileBackground.image = [UIImage imageNamed:@"bg_default.jpg"];
    }
    
    // 头像
    
    [avatarSelf setBackImage:[self imageFromPath:personalInfo.selfHeaderImgPath]];
    [avatarCouple setBackImage:[self imageFromPath:coupleInfo.selfHeaderImgPath]];
    [avatarBaby setBackImage:[self babyImageFromPath:personalInfo.selfBabyHeaderImgPath]];
    
    // 近况
    if (PERSONAL_RECENT_TYPE_TEXT ==  personalInfo.recentType) {
        [self setTextRecentStatus:personalInfo.recentContent];
    }else {
        //
    }
    
    // 昵称
    if (personalInfo.nickName) {
        [self setNickName:personalInfo.nickName];
    }else {
        [self setNickName:kDefaultNickName];
    }
    
    //CPUIModelUserInfo *coupleModel = [CPUIModelManagement sharedInstance].coupleModel;
    babyNickNameLabel.text = @"宝宝";
    coupleNickNameLabel.text = coupleInfo.nickName;
    
    // 性别
    [sexPickerView setSex:[personalInfo.sex intValue]];
    
    switcher.on = [personalInfo.hasBaby boolValue];  // yes 隐藏

    
    [self layoutStatusAndInfo];
    [self layoutBaby];
    [self layoutRecordButton];
    
    [avatarCouple removeFromSuperview];
    [coupleNickNameLabel removeFromSuperview];
    int lifeStatus = [[CPUIModelManagement sharedInstance].uiPersonalInfo.lifeStatus intValue];
    
    if (lifeStatus == PERSONAL_LIFE_STATUS_COUPLE||
        lifeStatus == PERSONAL_LIFE_STATUS_COUPLE_MARRIED||
        lifeStatus == PERSONAL_LIFE_STATUS_HAS_BABY) {  // 成为couple，才显示couple头像 
        [baseView addSubview:avatarCouple];
        [baseView addSubview:coupleNickNameLabel];
        
        [baseView bringSubviewToFront:avatarSelf];
    }
}

#pragma mark -
#pragma mark init controls

-(void)initCommon{
    
    isStatusText = YES;
    
    if ([CPUIModelManagement sharedInstance].uiPersonalInfo.recentType == USER_RECENT_TYPE_AUDIO) {
        isStatusText = NO;
    } else {
        isStatusText = YES;
    }
    
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 60, 60);
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_back"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_backpress"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    weiboButton = [UIButton buttonWithType:UIButtonTypeCustom];
    weiboButton.frame = CGRectMake(320-60, 0, 60, 60);
    //moreButton.backgroundColor = [UIColor orangeColor];
    
    [weiboButton addTarget:self action:@selector(weiboButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [weiboButton setImage:[UIImage imageNamed:@"btn_index_about"] forState:UIControlStateNormal];
    [weiboButton setImage:[UIImage imageNamed:@"btn_index_about_press"] forState:UIControlStateHighlighted];
    
    
    saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(240, 10, 69, 36);
    [saveButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_save"] forState:UIControlStateNormal];
    [saveButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_savepress"] forState:UIControlStateHighlighted];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    saveButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [saveButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    baseView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    baseView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:baseView];
    [baseView addTarget:self action:@selector(baseViewTaped:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];
    [self.view addSubview:weiboButton];
    //[self.view addSubview:saveButton];
    
    profileBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 230)];
    profileBackground.backgroundColor = [UIColor grayColor];
    [baseView addSubview:profileBackground];
    //profileBackground.image = [UIImage imageNamed:@"pic_registration@2x.jpg"];
    profileBackground.image = [UIImage imageNamed:@"bg_default.jpg"];
    

    profileBackground.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                        action:@selector(profileBackgroundTaped:)];
    [profileBackground addGestureRecognizer:gestureRecognizer];
    
    
    UIImageView *bar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 215, 320, 15)];
    bar.image = [UIImage imageNamed:@"sign_step1_image_bar"];
    [baseView addSubview:bar];
    
    
    UIImageView *graybackround = [[UIImageView alloc] initWithFrame:CGRectMake(0, 230, 320, 230)];
    graybackround.image = [UIImage imageNamed:@"bg_im_graybackround"];
    [baseView addSubview:graybackround];
    graybackround = nil;
    
    /*
    changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake((320-140.5)/2.0f, 100, 140.5, 50);
    changeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    changeButton.titleLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    changeButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    changeButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [changeButton setTitle:@"换个背景" forState:UIControlStateNormal];
    [changeButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_changebackground"] forState:UIControlStateNormal];
    [changeButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_changebackgroundpress"] forState:UIControlStateHighlighted];
    [baseView addSubview:changeButton];
    [changeButton addTarget:self action:@selector(changeButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    */
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    avatarBaby = [[HPHeadView alloc] initWithFrame:CGRectZero];
    avatarBaby.frame = CGRectMake((320-70)/2.0f - 55+10, kAvatarSelfOriginY+15, 55, 55);
    avatarBaby.cycleImage = [UIImage imageNamed:@"headpic_index_90x90"];
    //avatarBaby.maskImage = [UIImage imageNamed:@"headpic_index_press_120x120"];
    avatarBaby.borderWidth = 5;
    [baseView addSubview:avatarBaby];
    [avatarBaby addTarget:self action:@selector(avatarBabyTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    babyNickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 215, 40, 15)];
    babyNickNameLabel.backgroundColor = [UIColor clearColor];
    babyNickNameLabel.textColor = [UIColor whiteColor];
    babyNickNameLabel.font = [UIFont systemFontOfSize:12];
    babyNickNameLabel.textAlignment = UITextAlignmentRight;
    [baseView addSubview:babyNickNameLabel];
    
    avatarCouple = [[HPHeadView alloc] initWithFrame:CGRectZero];
    avatarCouple.frame = CGRectMake((320-70)/2.0f + 55 +5, kAvatarSelfOriginY+15, 55, 55);
    avatarCouple.borderWidth = 5;
    avatarCouple.cycleImage = [UIImage imageNamed:@"headpic_index_90x90"];
    //avatarCouple.maskImage = [UIImage imageNamed:@"headpic_index_press_120x120"];
    coupleNickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 215, 80, 15)];
    coupleNickNameLabel.backgroundColor = [UIColor clearColor];
    coupleNickNameLabel.textColor = [UIColor whiteColor];
    coupleNickNameLabel.font = [UIFont systemFontOfSize:12];
    
    
    int lifeStatus = [[CPUIModelManagement sharedInstance].uiPersonalInfo.lifeStatus intValue];
    
    if (lifeStatus == PERSONAL_LIFE_STATUS_COUPLE||
        lifeStatus == PERSONAL_LIFE_STATUS_COUPLE_MARRIED||
        lifeStatus == PERSONAL_LIFE_STATUS_HAS_BABY) {  // 成为couple，才显示couple头像 
        [baseView addSubview:avatarCouple];
        [baseView addSubview:coupleNickNameLabel];
    }

    avatarSelf = [[HPHeadView alloc] initWithFrame:CGRectZero];
    avatarSelf.frame = CGRectMake((320-70)/2.0f, kAvatarSelfOriginY, 70, 70);
    avatarSelf.borderWidth = 5;
    avatarSelf.cycleImage = [UIImage imageNamed:@"headpic_index_120x120"];
    //avatarSelf.maskImage = [UIImage imageNamed:@"headpic_index_press_120x120"];
    [baseView addSubview:avatarSelf];
    [avatarSelf addTarget:self action:@selector(avatarSelfTaped:) forControlEvents:UIControlEventTouchUpInside];
    

    avatarBaby.backgroundColor = [UIColor clearColor];
    avatarCouple.backgroundColor = [UIColor clearColor];
    avatarSelf.backgroundColor = [UIColor clearColor];

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    nickNameBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
    recentStatusBackground = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [baseView addSubview:nickNameBackground];
    [baseView addSubview:recentStatusBackground];
    
    
    nickNameBackground.image = [[UIImage imageNamed:@"bt_im_profile_inputname"] stretchableImageWithLeftCapWidth:42 topCapHeight:0];
    recentStatusBackground.image = [[UIImage imageNamed:@"bt_im_profile_inputsth"] stretchableImageWithLeftCapWidth:0 topCapHeight:24];
    
    nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(130, kNickNameOriginY, 60, kNickNameHeight)];
    nickNameTextField.delegate = self;
    nickNameTextField.backgroundColor = [UIColor clearColor];
    nickNameTextField.textColor = [UIColor whiteColor];
    nickNameTextField.textAlignment = UITextAlignmentCenter;
    nickNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nickNameTextField.font = [UIFont boldSystemFontOfSize:14];
    nickNameTextField.text = @"";
    nickNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    [baseView addSubview:nickNameTextField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nickNameTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nickNameTextField];
    
    recentStatusTexiView  = [[UITextView alloc] initWithFrame:CGRectMake(50, kRecentStatusOriginY, kRecentStatusDefaultWidth, kRecentStatusDefaultHeight)];
    recentStatusTexiView.backgroundColor = [UIColor clearColor];
    recentStatusTexiView.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    recentStatusTexiView.textAlignment = UITextAlignmentCenter;
    recentStatusTexiView.font = [UIFont systemFontOfSize:12];
    recentStatusTexiView.delegate = self;
    recentStatusTexiView.autocorrectionType = UITextAutocorrectionTypeNo;
    [baseView addSubview:recentStatusTexiView];
    
    recentStatusPlaceholder = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, kRecentStatusDefaultWidth, 20)];
    [recentStatusTexiView addSubview:recentStatusPlaceholder];
    recentStatusPlaceholder.textColor = [UIColor colorWithHexString:@"#999999"];
    recentStatusPlaceholder.backgroundColor = [UIColor clearColor];
    recentStatusPlaceholder.textAlignment = UITextAlignmentLeft;
    recentStatusPlaceholder.font = [UIFont systemFontOfSize:12];
    recentStatusPlaceholder.text = @"       唉...没有近况，好空旷啊";
    
    
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    recordButton.frame = CGRectMake((320-kRecentStatusDefaultWidth)/2, kRecentStatusOriginY+1, kRecentStatusDefaultWidth, 32.5);
    [baseView addSubview:recordButton];
    //[recordButton setTitle:@"长按住告诉朋友们你的近况" forState:UIControlStateNormal];
    recordButton.titleLabel.font = [UIFont systemFontOfSize:10];
    recordButton.exclusiveTouch = YES;

    
    
    convertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    convertButton.frame = CGRectMake(50+kRecentStatusDefaultWidth, kRecentStatusOriginY, 31, 30.5);
    [convertButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_speak"] forState:UIControlStateNormal];
    [baseView addSubview:convertButton];
    [convertButton addTarget:self action:@selector(convertButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    convertButton.hidden = YES;
    
    lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 40, 32.5)];
    lengthLabel.backgroundColor = [UIColor clearColor];
    lengthLabel.font = [UIFont fontWithName:@"Helvatica CE" size:11];
    lengthLabel.textColor = [UIColor whiteColor];
    lengthLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    lengthLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    lengthLabel.text = @"0s";
    [recordButton addSubview:lengthLabel];
    lengthLabel.hidden = YES;

    
    refreshButton= [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(260, kRecentStatusOriginY, 48, 30);
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_refresh"] forState:UIControlStateNormal];
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_refreshpress"] forState:UIControlStateHighlighted];
    refreshButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [refreshButton setTitle:@"重录" forState:UIControlStateNormal];
    //refreshButton.titleLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
    [refreshButton setTitleColor:[UIColor colorWithHexString:@"#CCCCCC"] forState:UIControlStateNormal];
    refreshButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    refreshButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    [baseView addSubview:refreshButton];
    if (isStatusText) {   //文本状态不显示更新按钮
        refreshButton.hidden = YES;
    }
    
    
    [refreshButton addTarget:self action:@selector(refreshButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 290, 320, 20)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor colorWithHexString:@"#111111"];
    infoLabel.shadowColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    infoLabel.shadowOffset = CGSizeMake(0, 1);
    infoLabel.textAlignment = UITextAlignmentCenter;
    infoLabel.font = [UIFont systemFontOfSize:10];
    [baseView addSubview:infoLabel];
    infoLabel.alpha = 0.9;
    infoLabel.text = @"大家都很关心你，更新个近况呗";
    

    
    sexPickerView = [[HPSexPicker alloc] initWithFrame:CGRectMake(260, 242,34,34) sex:PERSONAL_INFO_SEX_MALE];
    [sexPickerView setMaleImage:[UIImage imageNamed:@"profile_btn_male"]];
    [sexPickerView setFemaleImage:[UIImage imageNamed:@"profile_btn_female"]];
    sexPickerView.backgroundColor = [UIColor clearColor];
    [baseView addSubview:sexPickerView];
    [sexPickerView addTarget:self action:@selector(sexPickerAction:) forControlEvents:UIControlEventValueChanged];
    
    
    switcher = [[HPSwitch alloc] initWithFrame:CGRectMake(5, 185, 130/2, 44/2)];
    switcher.backgroundColor = [UIColor clearColor];
    [switcher addTarget:self action:@selector(switcherAction:) forControlEvents:UIControlEventValueChanged];
    [baseView addSubview:switcher];
    [switcher setThumbImage:[UIImage imageNamed:@"profile_item_circle_nor"] forState:UIControlStateNormal];
    [switcher setThumbImage:[UIImage imageNamed:@"profile_item_circle_press"] forState:UIControlStateHighlighted];
    
    UIImage *image = [UIImage imageNamed:@"profile_item_display"];
    image = [image stretchableImageWithLeftCapWidth:25 topCapHeight:0];
    
    UIImage *image1 = [UIImage imageNamed:@"profile_item_hide"];
    image1 = [image1 stretchableImageWithLeftCapWidth:25 topCapHeight:0];
	[switcher setMinimumTrackImage:image forState:UIControlStateNormal];
	[switcher setMaximumTrackImage:image1 forState:UIControlStateNormal];
    
    switcher.leftLabel.text = @"显示";
    switcher.rightLabel.text = @"隐藏";
    
    micView = [[ARMicView alloc] initWithCenter:CGPointMake(160, 140)];
    micView.delegate = self;

    changePwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changePwdButton.frame = CGRectMake(0, 460-72, 320, 36);
    [baseView addSubview:changePwdButton];
    [changePwdButton addTarget:self action:@selector(changePwdButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    [changePwdButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_bar_psd"] forState:UIControlStateNormal];
    [changePwdButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_bar_psd_press"] forState:UIControlStateHighlighted];
    
    
    logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = CGRectMake(0, 460-36, 320, 36);
    [baseView addSubview:logoutButton];
    [logoutButton addTarget:self action:@selector(logoutButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_bar_out"] forState:UIControlStateNormal];
    [logoutButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_bar_out_press"] forState:UIControlStateHighlighted];
    
    [self layoutStatusAndInfo];
    [self layoutNickName];
    [self convert:isStatusText];

}


- (void)viewDidLoad{
    [super viewDidLoad];


    isNickNameUp = NO;
    isRecentStatusUp = NO;
    
    [self initCommon];
    [self reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /*
    [self reloadData];
    
    if (cacheBgImage) {
        profileBackground.image = self.cacheBgImage;
    }
    
    
    [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_play"] forState:UIControlStateNormal];
     */
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    self.isUpdateTaped = NO;

    
    [[MusicPlayerManager sharedInstance] stop];
    [MusicPlayerManager sharedInstance].delegate = nil;
}

#pragma mark -
#pragma mark sexPicker Action

-(void)sexPickerAction:(HPSexPicker *)picker{
    CPLogInfo(@"%d",[picker sex]);
    
    isNickSexBabyChanged = YES;
}

#pragma mark -
#pragma mark switcher Action

-(void)switcherAction:(HPSwitch *)sw{
    CPLogInfo(@"%d",sw.on);
    [self layoutBaby];
    
    isNickSexBabyChanged = YES;
}


#pragma mark -
#pragma mark textfield delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (!isNickNameUp) {
        [self baseViewNickUp];
    }
    isNickNameUp = YES;
    isRecentStatusUp = NO;
    
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [nickNameTextField resignFirstResponder];
    if (isNickNameUp) {
        [self resetBaseView];
    }
    
    isNickNameUp = NO;
    isRecentStatusUp = NO;
    return YES;
}   

-(void)nickNameTextFieldTextDidChangeNotification:(NSNotification *)notify{
    
    if ([nickNameTextField.text length]>30) {
        nickNameTextField.text = [nickNameTextField.text substringToIndex:30];
    }
    
    [self layoutNickName];
    
    isNickSexBabyChanged = YES;
}

#pragma mark -
#pragma mark textview delegate

- (void)textViewDidEndEditing:(UITextView *)textView{
    [nickNameTextField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    

    
    convertButton.hidden = NO;

    
    recentStatusTexiView.selectedRange = NSMakeRange([recentStatusTexiView.text length],0);
    
    if (!isRecentStatusUp) {
        [self baseViewStatusUp];
    }
    isRecentStatusUp = YES;
    isNickNameUp = NO;
    
    [self layoutStatusAndInfo];
    
    recentStatusPlaceholder.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    

    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    [self layoutStatusAndInfo];
    [self baseViewStatusUp];
    
    isRecentChanged = YES;
    

    if ([recentStatusTexiView.text length]>30) {
        recentStatusTexiView.text = [recentStatusTexiView.text substringToIndex:30];
    }
    
    recentStatusPlaceholder.hidden = YES;
}


#pragma mark -
#pragma mark actionSheet delegate

//微博链接
#define kSinaWeiboURL    @"http://weibo.com/u/2596921271?topnav=1"
#define kTecentWeiboURL  @"http://t.qq.com/couplecouple"

//评分链接
#define kAppleReviewURL  @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=545951011" 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    
    typedef enum{
        ProfileAlertTagImage,
        ProfileAlertTagLogout,
        ProfileAlertTagWeibo
        
    }ProfileAlertTag;
    
    
    if(actionSheet.tag == ProfileAlertTagImage){
        UIImagePickerController *picker=[[UIImagePickerController alloc] init];
        picker.delegate=  self;
        picker.allowsEditing=YES;
        
        // 隐藏提示
        [[HPStatusBarTipView shareInstance] setHidden:YES];
        
        switch (buttonIndex) {
            case 0:
                
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
                    [self.navigationController presentModalViewController:picker animated:YES];
                }
                
                break;
            case 1:   
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    [self.navigationController presentModalViewController:picker animated:YES];
                }
                
                break;
            default:
                break;
        }
        
        return;
    }
    
    if(actionSheet.tag == ProfileAlertTagLogout){
 
        switch (buttonIndex) {
            case 0:
            {
                [[HPStatusBarTipView shareInstance] dismiss];
                [[HomePageViewController sharedHomePageViewController] clearHomePage]; //清理页面
                [[CPUIModelManagement sharedInstance] logout];
                [[AlarmClockHelper sharedInstance] changeUser];
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate; 
                [appDelegate launchLogin];
            }
                
                break;
            case 1:   
                
                break;
            default:
                break;
        }
        
        return;
    }
    
    if(actionSheet.tag == ProfileAlertTagWeibo){

        NSLog(@"## %d",buttonIndex);
        
        switch (buttonIndex) {
            case 0:
            {
                NSURL *url = [NSURL URLWithString:kSinaWeiboURL];
                [[UIApplication sharedApplication] openURL:url];
            }
                break;
            case 1:
            {
                
                [[CPUIModelManagement sharedInstance] checkUpdate];
                self.isUpdateTaped = YES;
            }
                break;
            case 2:
            {
                NSURL *url = [NSURL URLWithString:kAppleReviewURL];
                [[UIApplication sharedApplication] openURL:url];
            }
                break;
            case 3:
            {
                
            }
                break;
                
            default:
                break;
        }
        
        
        return;
    }

    
}

#pragma mark -
#pragma mark imagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    
    
    switch (imageType) {
        case ImageSelectedTypeBackground:
        {

//            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, 400, 300));
            
//            UIImage *cropped = [UIImage imageWithCGImage:imageRef];
            UIImage *cropped=[image imageByScalingAndCroppingForSize:CGSizeMake(400.0, 300.0)];
            profileBackground.image = cropped;
            
            self.cacheBgImage = cropped;
            
            isBgChanged = YES;
            
        }
            break;
        case ImageSelectedTypeAvatarSelf:
        {

            
            self.cacheSelfAvatarImage = [image imageByScalingAndCroppingForSize:CGSizeMake(120, 120)];
            [avatarSelf setBackImage:self.cacheSelfAvatarImage];
            
            isSelfAvatarChanged = YES;
        }
            break; 
        case ImageSelectedTypeAvatarCouple:
        {

        }
            break; 
        case ImageSelectedTypeAvatarBaby:
        {

            self.casheBabyAvatarImage = [image imageByScalingAndCroppingForSize:CGSizeMake(70, 70)];
            [avatarBaby setBackImage:self.casheBabyAvatarImage];
            
            isBabyAvatarChanged = YES;
        }
            break; 
        default:
            break;
    }
    
    [picker dismissModalViewControllerAnimated:YES];
    
    [[HPStatusBarTipView shareInstance] setHidden:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissModalViewControllerAnimated:YES];
    
    [[HPStatusBarTipView shareInstance] setHidden:NO];
}


#pragma mark -
#pragma mark MicMete delegate

// 开始
-(void)arMicViewRecordDidStarted:(id) arMicView_{
    CPLogInfo(@"arMicViewRecordDidStarted");
}

// 录音太短
-(void)arMicViewRecordTooShort:(id) arMicView_{
    CPLogInfo(@"arMicViewRecordTooShort");

}

// 正确录音
-(void)arMicViewRecordDidEnd:(id) arMicView_ pcmPath:(NSString *)pcmPath_ length:(CGFloat) audioLength_{
    CPLogInfo(@"arMicViewRecordDidEnd");
    [recordButton setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_play"] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    
    // remove
    [recordButton removeTarget:self action:@selector(recordDidBegin) forControlEvents:UIControlEventTouchDown];
    [recordButton removeTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpInside];
    [recordButton removeTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpOutside];
    [recordButton removeTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchCancel];
    
    // add
    [recordButton addTarget:self action:@selector(playRecentAudio) forControlEvents:UIControlEventTouchUpInside];
    
    convertButton.hidden = YES;
    //lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
    lengthLabel.hidden = NO;
    refreshButton.hidden = NO;
    
    isRecentChanged = YES;
    isStatusText = NO;
    
    // 转化
    NSString *path2 = [[[CPUIModelManagement sharedInstance] getAccountFilePath]  stringByAppendingPathComponent:@"/audio_recent_wav.wav"];
    [[NSFileManager defaultManager] copyItemAtPath:pcmPath_ toPath:path2 error:NULL];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path2]) {
        int length = (int)[[MusicPlayerManager sharedInstance] musicLength:path2];
        
        musicLength = length;
        
        lengthLabel.text = [NSString stringWithFormat:@"%ds",length];
    }
    
    isRecordFinished = YES;
}

// 录音转码失败或者被中断
-(void)arMicViewRecordErrorDidOccur:(id) arMicView_ error:(NSError *)error{
    CPLogInfo(@"arMicViewRecordErrorDidOccur");
    [[HPTopTipView shareInstance] showMessage:@"录音失败！"];

}

#pragma mark -
#pragma mark dealloc

-(void)dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"uiPersonalInfoTag" context:NULL];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil]; 
}

@end
