//
//  PetView.m
//  Pet_component_dev
//
//  Created by ming bright on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PetView.h"
#import "HPStatusBarTipView.h"
#import "TPCMToAMR.h"
#import "ColorUtil.h"

#import "Reachability.h"

#import "KeyboardView.h"
#import "DateUtil.h"
@interface PetView()
- (void)initMainItems;
- (void)initHappyItems;
- (void)initSadItems;
- (void)initLoveItems;

- (void)itemTaped:(PetActionItem *)item;

- (void)showMainItems;
- (void)showHappyItems;
- (void)showSadItems;
- (void)showLoveItems;

- (void)hideMainItems:(PetActionItem *)item;
- (void)hideHappyItems;
- (void)hideSadItems;
- (void)hideLoveItems;

- (void)showCycle;
- (void)hidePetView;

- (CAKeyframeAnimation *)animationFromAngle:(CGFloat)startAngle toAngle:(CGFloat)endAngle duration:(CGFloat)duration;

-(void)stopTimer;
@end


@implementation PetView
@synthesize delegate;
@synthesize currentResourceID;
@synthesize currentMsgContentType;

@synthesize alarmFilePath;
@synthesize alarmFileLength;

-(void)timeButtonTaped:(id)sender{
    
    [[UIApplication sharedApplication].keyWindow addSubview:datePicker];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, -245+20+20+10, self.frame.size.width, self.frame.size.height);
        datePicker.frame = CGRectMake(0, 245+20, 320, 300);
    } completion:^(BOOL finished) {
        //
    }];
    
    goHome.hidden = YES;
}


-(void)datePickerValueChanged:(UIDatePicker*) picker{
    NSLog(@"%@",picker.date);
    NSString *daterepresent=[[NSString alloc] init];
    NSDateFormatter *dateformate= [[NSDateFormatter alloc] init];
    [dateformate setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    daterepresent=[dateformate stringFromDate:datePicker.date];
    [timeButton setTitle:daterepresent forState:UIControlStateNormal];

}

-(void)sendButtonTaped:(id)sender{
    
    
    if ([datePicker.date timeIntervalSinceNow]>0) {
        
//        NSString *daterepresent=[[NSString alloc] init];
//        NSDateFormatter *dateformate= [[NSDateFormatter alloc] init];
//        [dateformate setDateFormat:@"yyyy年MM月dd日 K:mm"];
//        daterepresent=[dateformate stringFromDate:datePicker.date];
//        [timeButton setTitle:daterepresent forState:UIControlStateNormal]; 
    }else {
        [[HPTopTipView shareInstance] showMessage:@"时光不能倒流，不能对历史时间设提醒" duration:2.5f];
        return;
    }
    
    
    [UIView animateWithDuration:0.3 animations:^{
         self.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height);
        datePicker.frame = CGRectMake(0, 480, 320, 300);
    } completion:^(BOOL finished) {
        //
        [datePicker removeFromSuperview];
        [self goHomeTaped:nil];
    }];
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    NSString *dateStr = [dateFormatter stringFromDate:datePicker.date];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    
    CPUIModelMessage *msg = [[CPUIModelMessage alloc] init];
    //msg.msgData = data;
    msg.filePath = self.alarmFilePath;
    msg.mediaTime = [NSNumber numberWithFloat:self.alarmFileLength];
    msg.petMsgID = @"pet_default";
    msg.contentType = [NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARM_AUDIO];
    msg.alarmTime = [NSNumber numberWithLongLong:[date timeIntervalSince1970] * 1000];
    msg.isAlarmHidden = [NSNumber numberWithBool:switcher.on];
    if ([self.delegate respondsToSelector:@selector(petFeelingStartSend:message:)]) {
        [self.delegate petFeelingStartSend:self message:msg];
    }
    msg = nil;
    
}

-(void)replayAlermButtonTaped:(id)sender{  // 回放
    
    [[MusicPlayerManager sharedInstance] stop];
    [MusicPlayerManager sharedInstance].delegate = self;
    [[MusicPlayerManager sharedInstance] playMusic:self.alarmFilePath playerName:self.alarmFilePath];
    [animView pause];
    //[animView addAnimArray:shuohua forName:PET_ACTION_SHUOHUA];  //开始说话
}

-(void)switcherValueChanged:(id)sender{
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_alarm_secret_once"]) {
        [[HPTopTipView shareInstance] showMessage:@"对方事先不会知道提醒内容哦"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_alarm_secret_once"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"petDataDict"]) {
        NSDictionary *dic = [object valueForKey:@"petDataDict"];
        if (PET_DATACHANGE_TYPE_UPDATE_RES == [[dic valueForKey:pet_datachange_type] intValue]) {  //更新资源
            if (K_PET_DATA_TYPE_FEELING == [[dic valueForKey:pet_datachange_category] intValue]) {  //类别
                NSString *resid = [dic valueForKey:pet_datachange_id];
                for (UIView *aView in [self subviews]) {
                    if ([aView isKindOfClass:[PetActionItem class]]) {
                        PetActionItem *item = (PetActionItem *)aView;
                        if ([item.resourceID isEqualToString:resid]) {
                            
                            CPUIModelPetFeelingAnim *anim = [[CPUIModelManagement sharedInstance] feelingObjectOfID:item.resourceID fromPet:@"pet_default"];
                            [item setIsDownloaded:[anim isAvailable]];        //下载状态
                            //[item setDownloadStatus:anim.downloadStatus];
                            item.senderDesc = anim.senderDesc;  //发送提示
                            
                            //下载失败
                            if (PET_DATACHANGE_RESULT_FAIL ==[[dic valueForKey:pet_datachange_result] intValue]) { 
                                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                            } 
                        }
                    }
                }
            }
        }else if(PET_DATACHANGE_TYPE_DOWNLOADING == [[dic valueForKey:pet_datachange_type] intValue]){
            if (K_PET_DATA_TYPE_FEELING == [[dic valueForKey:pet_datachange_category] intValue]) {  //类别
                NSString *resid = [dic valueForKey:pet_datachange_id];
                for (UIView *aView in [self subviews]) {
                    if ([aView isKindOfClass:[PetActionItem class]]) {
                        PetActionItem *item = (PetActionItem *)aView;
                        if ([item.resourceID isEqualToString:resid]) {
                            
                            CPUIModelPetFeelingAnim *anim = [[CPUIModelManagement sharedInstance] feelingObjectOfID:item.resourceID fromPet:@"pet_default"];
                            //[item setIsDownloaded:[anim isAvailable]];        //下载状态
                            [item setDownloadStatus:anim.downloadStatus];
                            item.senderDesc = anim.senderDesc;  //发送提示
                            
                            //下载失败
                            if (PET_DATACHANGE_RESULT_FAIL ==[[dic valueForKey:pet_datachange_result] intValue]) { 
                                [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
                            } 
                        }
                    }
                }
            }
        }
    }
}

#pragma mark -
#pragma mark parse feelings

-(void)parseFeelings{

    //小双动作
    CPUIModelPetActionAnim *actionZhanli = [[CPUIModelManagement sharedInstance] actionObjectOfID:PET_ACTION_ZHALNI];
    CPUIModelPetActionAnim *actionShuohua = [[CPUIModelManagement sharedInstance] actionObjectOfID:PET_ACTION_SHUOHUA];
    CPUIModelPetActionAnim *actionTing = [[CPUIModelManagement sharedInstance] actionObjectOfID:PET_ACTION_TING];
    
    zhanli = (NSMutableArray*)[actionZhanli allAnimSlides];
    shuohua = (NSMutableArray*)[actionShuohua allAnimSlides];
    
    NSArray *tingAll = [actionTing allAnimSlides];
    ting1 = [[NSMutableArray alloc] init];
    ting2 = [[NSMutableArray alloc] init];
    ting3 = [[NSMutableArray alloc] init];
    ting4 = [[NSMutableArray alloc] init];
    for (int i=0; i<=14; i++) {
        [ting1 addObject:[tingAll objectAtIndex:i]];
    }
    for (int i=13; i<=14; i++) {
        [ting2 addObject:[tingAll objectAtIndex:i]];
        [ting2 addObject:[tingAll objectAtIndex:i]];
        [ting2 addObject:[tingAll objectAtIndex:i]];
        [ting2 addObject:[tingAll objectAtIndex:i]];
        [ting2 addObject:[tingAll objectAtIndex:i]];
    }
    for (int i=15; i<=16; i++) {
        [ting3 addObject:[tingAll objectAtIndex:i]];
        [ting3 addObject:[tingAll objectAtIndex:i]];
        [ting3 addObject:[tingAll objectAtIndex:i]];
        [ting3 addObject:[tingAll objectAtIndex:i]];
        [ting3 addObject:[tingAll objectAtIndex:i]];
    }
    for (int i=14; i>=0; i--) {
        [ting4 addObject:[tingAll objectAtIndex:i]];
    }
    
 
    
    [animView addAnimArray:zhanli forName:PET_ACTION_ZHALNI];

    //PET_FEELING_TYPE_LOVE          
    //PET_FEELING_TYPE_HAPPY          
    //PET_FEELING_TYPE_SAD 
    
    // 小双情感
    NSDictionary *allFeelings =  [[CPUIModelManagement sharedInstance] allFeelingObjects];
    
    sads = [[allFeelings valueForKey:PET_FEELING_TYPE_SAD] allValues];
    happys = [[allFeelings valueForKey:PET_FEELING_TYPE_HAPPY] allValues];
    loves = [[allFeelings valueForKey:PET_FEELING_TYPE_LOVE] allValues];
    
}
#pragma mark -
#pragma mark animImage delegate

-(void)animImageViewDidStartAnim:(AnimImageView*) animView_{
    //CPLogInfo(@"start   %@",animView.name);
}

-(void)animImageViewDidStopAnim:(AnimImageView *)animView_{
    
    
    //CPLogInfo(@"stop   %@",animView.name);
    
    //听
    if ([animView.name isEqualToString:@"ting1"]) {
        [animView addAnimArray:ting2 forName:@"ting2"];
    }else if([animView.name isEqualToString:@"ting2"]){
        
        if (1==arc4random()%2) {
            [animView addAnimArray:ting3 forName:@"ting3"];
        }else {
            [animView addAnimArray:ting2 forName:@"ting2"];
        }
        
    }else if([animView.name isEqualToString:@"ting3"]){
        if (1==arc4random()%2) {
            [animView addAnimArray:ting3 forName:@"ting3"];
        }else {
            [animView addAnimArray:ting2 forName:@"ting2"];
        }
    }else if([animView.name isEqualToString:@"ting4"]){
        //CPLogInfo(@"record end");
        [animView addAnimArray:zhanli forName:PET_ACTION_ZHALNI];
    }
    
    
    //站立
    if ([animView_.name isEqualToString:PET_ACTION_ZHALNI]) {
        [animView addAnimArray:zhanli forName:PET_ACTION_ZHALNI];
    }
    
    //说话
    if ([animView_.name isEqualToString:PET_ACTION_SHUOHUA]) {
        [animView addAnimArray:shuohua forName:PET_ACTION_SHUOHUA];
    }
    
}


#pragma mark -
#pragma mark animations

-(CAKeyframeAnimation *)animationFromAngle:(CGFloat)startAngle toAngle:(CGFloat)endAngle duration:(CGFloat)duration {
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathAddArc(curvedPath, NULL, 160, 211, kRadius, startAngle, endAngle, 0);
    
    //CGPathAddArcToPoint(curvedPath, NULL, 160, 200, 50, 100, 120);
    
    //below for the animation
    CAKeyframeAnimation * theAnimation;
    theAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.delegate = self;
    theAnimation.duration = duration;
    theAnimation.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                 nil];
    theAnimation.path = curvedPath;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    
    return theAnimation;
}


-(void)expandItem:(PetActionItem *)item angle:(CGFloat)angle{
    
    CGPoint farPoint = CGPointMake(160+((kRadius+10)*cos(angle)), 211+((kRadius+10)*sin(angle)));
    CGPoint nearPoint = CGPointMake(160+((kRadius-7)*cos(angle)), 211+((kRadius-5)*sin(angle)));
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.4f;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.center.x, item.center.y);
    CGPathAddLineToPoint(path, NULL, farPoint.x, farPoint.y);
    CGPathAddLineToPoint(path, NULL, nearPoint.x, nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.center.x, item.center.y); 
    positionAnimation.path = path;
    
    [item.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
}

#pragma mark -
#pragma mark animation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    /*main*/
    ///////////////////////////////////////////////////////////////////////////////////////
    
    if ([anim isEqual:[mainItem[5].layer animationForKey:@"mainAnimation0"]]) {
        //
        for (int i = 1; i<6; i++) {
            [mainItem[i].layer addAnimation:mainAnimation[1] forKey:@"mainAnimation1"];
        }
    }else if ([anim isEqual:[mainItem[5].layer animationForKey:@"mainAnimation1"]]) {
        //
        for (int i = 2; i<6; i++) {
            [mainItem[i].layer addAnimation:mainAnimation[2] forKey:@"mainAnimation2"];
        }
    }else if ([anim isEqual:[mainItem[5].layer animationForKey:@"mainAnimation2"]]) {
        //
        for (int i = 3; i<6; i++) {
            [mainItem[i].layer addAnimation:mainAnimation[3] forKey:@"mainAnimation3"];
        }
    }else if ([anim isEqual:[mainItem[5].layer animationForKey:@"mainAnimation3"]]) {
        //
        for (int i = 4; i<6; i++) {
            [mainItem[i].layer addAnimation:mainAnimation[4] forKey:@"mainAnimation4"];
        }
    }else if ([anim isEqual:[mainItem[5].layer animationForKey:@"mainAnimation4"]]) {
        //
        for (int i = 5; i<6; i++) {
            [mainItem[i].layer addAnimation:mainAnimation[5] forKey:@"mainAnimation5"];
        }
    }else if ([anim isEqual:[mainItem[5].layer animationForKey:@"mainAnimation5"]]) {
        
        [self showTip1];
        
        //主菜单位置调整
        for (int i = 0; i<6; i++) {
            CGFloat angle = [[mainAngles objectAtIndex:i+1] floatValue];
            CGFloat x = (kRadius*cos(angle));
            CGFloat y = (kRadius*sin(angle));
            mainItem[i].center = CGPointMake(160+x, 211+y);
            
            
            [self expandItem:mainItem[i] angle:angle];
            
        }
        
        if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_alarm_tip_once"]) {

            OverlayGuidView *guid = [[OverlayGuidView alloc] initWithFrame:CGRectMake(10, 310, 410/2, 216/2)];
            guid.backgroundColor = [UIColor clearColor];
            [guid setImage:[UIImage imageNamed:@"pet_item_float"]];
            [guid showInView:self];

            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_alarm_tip_once"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    /*sad*/
    ///////////////////////////////////////////////////////////////////////////////////////
    
    if ([anim isEqual:[sadItem[0].layer animationForKey:@"sadAnimation0"]]) {
        
        [self layoutSadItems:1];
        for (int i = 1; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[1] forKey:@"sadAnimation1"];
        }
    }else if ([anim isEqual:[sadItem[1].layer animationForKey:@"sadAnimation1"]]) {
        [self layoutSadItems:2];
        for (int i = 2; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[2] forKey:@"sadAnimation2"];
        }
    }else if ([anim isEqual:[sadItem[2].layer animationForKey:@"sadAnimation2"]]) {
        [self layoutSadItems:3];
        for (int i = 3; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[3] forKey:@"sadAnimation3"];
        }
    }else if ([anim isEqual:[sadItem[3].layer animationForKey:@"sadAnimation3"]]) {
        [self layoutSadItems:4];
        for (int i = 4; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[4] forKey:@"sadAnimation4"];
        }
    }else if ([anim isEqual:[sadItem[4].layer animationForKey:@"sadAnimation4"]]) {
        [self layoutSadItems:5];
        for (int i = 5; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[5] forKey:@"sadAnimation5"];
        }
    }else if ([anim isEqual:[sadItem[5].layer animationForKey:@"sadAnimation5"]]) {
        [self layoutSadItems:6];
        for (int i = 6; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[6] forKey:@"sadAnimation6"];
        }
    }else if ([anim isEqual:[sadItem[6].layer animationForKey:@"sadAnimation6"]]) {
        [self layoutSadItems:7];
        for (int i = 7; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[7] forKey:@"sadAnimation7"];
        }
    }else if ([anim isEqual:[sadItem[7].layer animationForKey:@"sadAnimation7"]]) {
        [self layoutSadItems:8];
        for (int i = 8; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[8] forKey:@"sadAnimation8"];
        }
    }else if ([anim isEqual:[sadItem[8].layer animationForKey:@"sadAnimation8"]]) {
        [self layoutSadItems:9];
        for (int i = 9; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[9] forKey:@"sadAnimation9"];
        }
    }else if ([anim isEqual:[sadItem[9].layer animationForKey:@"sadAnimation9"]]) {
        [self layoutSadItems:10];
        for (int i = 10; i<11; i++) {
            [sadItem[i].layer addAnimation:sadAnimation[10] forKey:@"sadAnimation10"];
        }
    }else if ([anim isEqual:[sadItem[10].layer animationForKey:@"sadAnimation10"]]) {
        [self layoutSadItems:11];

        
    }
    
    
    /*happy*/
    ///////////////////////////////////////////////////////////////////////////////////////
    
    if ([anim isEqual:[happyItem[0].layer animationForKey:@"happyAnimation0"]]) {
        [self layoutHappyItems:1];
        for (int i = 1; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[1] forKey:@"happyAnimation1"];
        }
    }else if ([anim isEqual:[happyItem[1].layer animationForKey:@"happyAnimation1"]]) {
        [self layoutHappyItems:2];
        for (int i = 2; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[2] forKey:@"happyAnimation2"];
        }
    }else if ([anim isEqual:[happyItem[2].layer animationForKey:@"happyAnimation2"]]) {
        [self layoutHappyItems:3];
        for (int i = 3; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[3] forKey:@"happyAnimation3"];
        }
    }else if ([anim isEqual:[happyItem[3].layer animationForKey:@"happyAnimation3"]]) {
        [self layoutHappyItems:4];
        for (int i = 4; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[4] forKey:@"happyAnimation4"];
        }
    }else if ([anim isEqual:[happyItem[4].layer animationForKey:@"happyAnimation4"]]) {
        [self layoutHappyItems:5];
        for (int i = 5; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[5] forKey:@"happyAnimation5"];
        }
    }else if ([anim isEqual:[happyItem[5].layer animationForKey:@"happyAnimation5"]]) {
        [self layoutHappyItems:6];
        for (int i = 6; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[6] forKey:@"happyAnimation6"];
        }
    }else if ([anim isEqual:[happyItem[6].layer animationForKey:@"happyAnimation6"]]) {
        [self layoutHappyItems:7];
        for (int i = 7; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[7] forKey:@"happyAnimation7"];
        }
    }else if ([anim isEqual:[happyItem[7].layer animationForKey:@"happyAnimation7"]]) {
        [self layoutHappyItems:8];
        for (int i = 8; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[8] forKey:@"happyAnimation8"];
        }
    }else if ([anim isEqual:[happyItem[8].layer animationForKey:@"happyAnimation8"]]) {
        [self layoutHappyItems:9];
        for (int i = 9; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[9] forKey:@"happyAnimation9"];
        }
    }else if ([anim isEqual:[happyItem[9].layer animationForKey:@"happyAnimation9"]]) {
        [self layoutHappyItems:10];
        for (int i = 10; i<11; i++) {
            [happyItem[i].layer addAnimation:happyAnimation[10] forKey:@"happyAnimation10"];
        }
    }else if ([anim isEqual:[happyItem[10].layer animationForKey:@"happyAnimation10"]]) {
        [self layoutHappyItems:11];

    }
    
    /*love*/
    ///////////////////////////////////////////////////////////////////////////////////////
    
    if ([anim isEqual:[loveItem[0].layer animationForKey:@"loveAnimation0"]]) {
        [self layoutLoveItems:1];
        for (int i = 1; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[1] forKey:@"loveAnimation1"];
        }
    }else if ([anim isEqual:[loveItem[1].layer animationForKey:@"loveAnimation1"]]) {
        [self layoutLoveItems:2];
        for (int i = 2; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[2] forKey:@"loveAnimation2"];
        }
    }else if ([anim isEqual:[loveItem[2].layer animationForKey:@"loveAnimation2"]]) {
        [self layoutLoveItems:3];
        for (int i = 3; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[3] forKey:@"loveAnimation3"];
        }
    }else if ([anim isEqual:[loveItem[3].layer animationForKey:@"loveAnimation3"]]) {
        [self layoutLoveItems:4];
        for (int i = 4; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[4] forKey:@"loveAnimation4"];
        }
    }else if ([anim isEqual:[loveItem[4].layer animationForKey:@"loveAnimation4"]]) {
        [self layoutLoveItems:5];
        for (int i = 5; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[5] forKey:@"loveAnimation5"];
        }
    }else if ([anim isEqual:[loveItem[5].layer animationForKey:@"loveAnimation5"]]) {
        [self layoutLoveItems:6];
        for (int i = 6; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[6] forKey:@"loveAnimation6"];
        }
    }else if ([anim isEqual:[loveItem[6].layer animationForKey:@"loveAnimation6"]]) {
        [self layoutLoveItems:7];
        for (int i = 7; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[7] forKey:@"loveAnimation7"];
        }
    }else if ([anim isEqual:[loveItem[7].layer animationForKey:@"loveAnimation7"]]) {
        [self layoutLoveItems:8];
        for (int i = 8; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[8] forKey:@"loveAnimation8"];
        }
    }else if ([anim isEqual:[loveItem[8].layer animationForKey:@"loveAnimation8"]]) {
        [self layoutLoveItems:9];
        for (int i = 9; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[9] forKey:@"loveAnimation9"];
        }
    }else if ([anim isEqual:[loveItem[9].layer animationForKey:@"loveAnimation9"]]) {
        [self layoutLoveItems:10];
        for (int i = 10; i<11; i++) {
            [loveItem[i].layer addAnimation:loveAnimation[10] forKey:@"loveAnimation10"];
        }
    }else if ([anim isEqual:[loveItem[10].layer animationForKey:@"loveAnimation10"]]) {
        [self layoutLoveItems:11];

    }
    
}


#pragma mark -
#pragma mark tips


-(void)resetTipFrame{
    tipsLabel.frame = CGRectMake(0, 26, 320, 50);
}

-(void)showTip1{
    tipsLabel.text = @"想让我帮你做点什么呀：）";
    //
    //tipsLabel.text = @"我能把你的话和情绪表演给另一半，还能在聊天时把声音变得有趣、变声帮你匿名打听小秘密";
    //tipsLabel.frame = CGRectMake(0, 17, 320, 50);
    
    if (PetViewTypeGroup == petViewType) {  //群聊只有传声
        tipsLabel.text = @"帮你换个有趣的声音，卖萌最管用";
        [self resetTipFrame];
    }
}

-(void)showTip2{
    tipsLabel.text = @"让小双表达喜怒哀乐吧";
    [self resetTipFrame];
}

-(void)showTip3{
    tipsLabel.text = @"成为couple才能使用哦～";
    [self resetTipFrame];
}

-(void)showTip4{
    tipsLabel.text = @"帮你换个有趣的声音，卖萌最管用";
    [self resetTipFrame];
}

-(void)showTip5{
    tipsLabel.text = @"录下问题，小双会匿名发给对方求答案";
    [self resetTipFrame];
}

//////////
-(void)showTip6{
    tipsLabel.text = @"不开心么，告诉Ta来安慰你";
    [self resetTipFrame];
}

-(void)showTip7{
    tipsLabel.text = @"心情不错？找Ta乐一乐";
    [self resetTipFrame];
}

-(void)showTip8{
    tipsLabel.text = @"爱，就要让Ta知道";
    [self resetTipFrame];
}


-(void)showTip:(NSString *)text{
    tipsLabel.text = text;
    [self resetTipFrame];
}


-(void)showInView:(UIView *)aView{
    
    [[HPStatusBarTipView shareInstance] setHidden:YES];
    
    self.transform = CGAffineTransformScale(self.transform,
                                               0.1, 0.1);
    [aView addSubview:self];
    [UIView animateWithDuration:0.5 
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                     } 
                     completion:^(BOOL finished) {
                         [self showCycle];
                         
                         // 必要时关闭键盘，避免键盘出现在pet上层
                         [[KeyboardView sharedKeyboardView] closeSystemKeyboard];

                     }];
    
}

#pragma mark -
#pragma mark init

- (id)initWithFrame:(CGRect)frame type:(PetViewType) type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        petViewType = type;
        
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        
        isSubItemShow = NO;
        
        tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 320, 50)];
        [self addSubview:tipsLabel];
        tipsLabel.numberOfLines = 0;
        //tipsLabel.font = [UIFont systemFontOfSize:16];
        tipsLabel.font = [UIFont systemFontOfSize:14];
        tipsLabel.textAlignment = UITextAlignmentCenter;
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.backgroundColor = [UIColor clearColor];
        
        //480 × 720
        
        animView = [[AnimImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 360)];
        animView.center = CGPointMake(160, 200-20+11);
        animView.delegate = self;
        [self addSubview:animView];
        
        // 录音
        longPressRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        longPressRecordButton.frame = CGRectMake(160-152/2, 460-49-44.5, 152, 44.5);
        [longPressRecordButton setTitle:@"长按住说话" forState:UIControlStateNormal]; //长按住提问
        longPressRecordButton.titleLabel.font = [UIFont systemFontOfSize:15];
        longPressRecordButton.titleLabel.shadowColor = [UIColor colorWithHexString:@"#333333"];
        longPressRecordButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        [longPressRecordButton setBackgroundImage:[UIImage imageNamed:@"btn_pet_listenanswer"] forState:UIControlStateNormal];
        [longPressRecordButton setBackgroundImage:[UIImage imageNamed:@"btn_pet_listenanswerpress"] forState:UIControlStateHighlighted];
        [longPressRecordButton addTarget:self action:@selector(recordDidBegin) forControlEvents:UIControlEventTouchDown];
        [longPressRecordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpInside];
        [longPressRecordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchUpOutside];
        [longPressRecordButton addTarget:self action:@selector(recordDidFinish) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:longPressRecordButton];
        longPressRecordButton.exclusiveTouch = YES;
        longPressRecordButton.hidden = YES;
        
    
        // 下载全部
        downloadAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        downloadAllButton.frame = CGRectMake(160-107/2, 460-73/2-30, 107, 73/2);
        downloadAllButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [downloadAllButton setTitle:@"下载全部表情" forState:UIControlStateNormal];
        //[downloadAllButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        
        [downloadAllButton setBackgroundImage:[UIImage imageNamed:@"btn_pet_downloadall"] forState:UIControlStateNormal];
        [downloadAllButton setBackgroundImage:[UIImage imageNamed:@"btn_pet_downloadallpress"] forState:UIControlStateHighlighted];
        [downloadAllButton addTarget:self action:@selector(downloadAllButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:downloadAllButton];
        downloadAllButton.hidden = YES;

        
        micView = [[ARMicView alloc] initWithCenter:CGPointMake(160, 300+16.5)];
        micView.delegate = self;
        
        progressView = [[PetProgressView alloc] init];
        
        goHome = [UIButton buttonWithType:UIButtonTypeCustom];
        goHome.frame = CGRectMake(0, 460-96/2, 96/2, 96/2);
        [self addSubview:goHome];
        [goHome addTarget:self action:@selector(goHomeTaped:) forControlEvents:UIControlEventTouchUpInside];
        [goHome setBackgroundImage:[UIImage imageNamed:@"pet_menu_back"] forState:UIControlStateNormal];
        [goHome setBackgroundImage:[UIImage imageNamed:@"pet_menu_back_graypress"] forState:UIControlStateHighlighted];
        
        mainAngles = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:kAngle0], 
                      [NSNumber numberWithFloat:kAngle1], 
                      [NSNumber numberWithFloat:kAngle2],
                      [NSNumber numberWithFloat:kAngle3],
                      [NSNumber numberWithFloat:kAngle4],
                      [NSNumber numberWithFloat:kAngle5],
                      [NSNumber numberWithFloat:kAngle6],
                      nil];
        
        
        [self initMainItems];
        
        [self parseFeelings];
        
        if (PetViewTypeCouple ==petViewType) {
            [self initHappyItems];
            [self initSadItems];
            [self initLoveItems];
        }
        
        
        timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        timeButton.frame = CGRectMake(0, 365, 320, 41);
        [timeButton addTarget:self action:@selector(timeButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        [timeButton setBackgroundImage:[UIImage imageNamed:@"pet_bar_time"] forState:UIControlStateNormal];
        [timeButton setBackgroundImage:[UIImage imageNamed:@"pet_bar_time_press"] forState:UIControlStateHighlighted];
        
        
        NSString *daterepresent=[[NSString alloc] init];
        NSDateFormatter *dateformate= [[NSDateFormatter alloc] init];
        [dateformate setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        daterepresent=[dateformate stringFromDate:[NSDate date]];
        [timeButton setTitle:daterepresent forState:UIControlStateNormal];
        
        sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame = CGRectMake((320 - 214/2)/2, 415, 214/2, 72/2);
        [sendButton addTarget:self action:@selector(sendButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_red_nor"] forState:UIControlStateNormal];
        [sendButton setBackgroundImage:[UIImage imageNamed:@"profile_btn_red_press"] forState:UIControlStateHighlighted];
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 480, 320, 300)];
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        
//        switcher = [HPSwitch switchWithLeftText:@"神秘" andRight:@"普通"];
//        switcher.frame = CGRectMake(225, 330, 90, 27);
        
        switcher = [[HPSwitch alloc] initWithFrame:CGRectMake(245, 330, 136/2, 43/2)];
        switcher.backgroundColor = [UIColor clearColor];
        [switcher setThumbImage:[UIImage imageNamed:@"btn_hidecircle_im"] forState:UIControlStateNormal];
        [switcher setThumbImage:[UIImage imageNamed:@"btn_hidecirclepress_im"] forState:UIControlStateHighlighted];
        
        UIImage *image = [UIImage imageNamed:@"btn_hidepiece_im02"];
        image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        
        UIImage *image1 = [UIImage imageNamed:@"btn_hidepiece_im"];
        image1 = [image1 stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [switcher setMinimumTrackImage:image forState:UIControlStateNormal];
        [switcher setMaximumTrackImage:image1 forState:UIControlStateNormal];
        
        switcher.leftLabel.text = @"神秘";
        switcher.rightLabel.text = @"普通";
        [switcher addTarget:self action:@selector(switcherValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        replayAlermButton = [UIButton buttonWithType:UIButtonTypeCustom];
        replayAlermButton.backgroundColor = [UIColor clearColor];
        replayAlermButton.frame = CGRectMake((320-286/2)/2, 140-30, 286/2, 286/2+60);
        [replayAlermButton addTarget:self action:@selector(replayAlermButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        imageArray = [[NSArray alloc] initWithObjects:
                      @"shuohua01",
                      @"shuohua02",
                      @"shuohua03",
                      @"shuohua04",
                      @"shuohua05",
                      @"shuohua06",
                      @"shuohua07",
                      @"shuohua08",
                      @"shuohua09",
                      @"shuohua10",
                      @"shuohua11",
                      @"shuohua12",
                      @"shuohua13",
                      @"shuohua14",
                      @"shuohua15",
                      @"shuohua16",
                      nil];
        
    }
    
    return self;
}

#pragma mark -
#pragma mark init items

-(void)initMainItems{
    
    if (PetViewTypeGroup == petViewType) {
        return;
    }
    
    
    NSArray *array1 = [NSArray arrayWithObjects:@"btn_pet_cry",@"btn_pet_cry_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"btn_pet_smile",@"btn_pet_smilepress",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"btn_pet_heart",@"btn_pet_heart_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array4 = [NSArray arrayWithObjects:@"pet_btn_clock",@"pet_btn_clock_press",@"pet_btn_back_yellow",@"pet_btn_back_yellow_press",nil]; // alarm
    NSArray *array5 = [NSArray arrayWithObjects:@"btn_pet_microphone",@"btn_pet_microphone_press",@"btn_pet_back_blue",@"btn_pet_back_blue_press",nil];
    NSArray *array6 = [NSArray arrayWithObjects:@"btn_pet_ask",@"btn_pet_ask_press",@"pet_btn_back_ask",@"pet_btn_back_ask_press",nil]; 
    
    
    NSArray *array11 = [NSArray arrayWithObjects:@"btn_pet_cry_grey",@"btn_pet_cry_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array22 = [NSArray arrayWithObjects:@"btn_pet_smile_grey",@"btn_pet_smile_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array33 = [NSArray arrayWithObjects:@"btn_pet_heart_grey",@"btn_pet_heart_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    
    NSArray *images;
    
    if (PetViewTypeCouple == petViewType) {
        images = [NSArray arrayWithObjects:array1,array2,array3,array4,array5,array6, nil];
    }else {
        images = [NSArray arrayWithObjects:array11,array22,array33,array4,array5,array6, nil];
    }
    
    
    for (int i = 0; i<6; i++) {
        if (nil== mainItem[i]) {
            mainItem[i]= [[PetActionItem alloc] initWithFrame:CGRectMake(160 -20, 211-20-120, kItemSizeBig, kItemSizeBig)];
            mainItem[i].delegate = self;
            mainItem[i].itemType = PetItemTypeMain;
            mainItem[i].canFlip = YES;
            mainItem[i].tag = i+1;
            
            
            NSArray *imagesArray = [images objectAtIndex:i];
            
            
            [mainItem[i] setFrontNormalImage:[UIImage imageNamed:[imagesArray objectAtIndex:0]]
                       frontHighlightedImage:[UIImage imageNamed:[imagesArray objectAtIndex:1]] 
                             backNormalImage:[UIImage imageNamed:[imagesArray objectAtIndex:2]] 
                        backHighlightedImage:[UIImage imageNamed:[imagesArray objectAtIndex:3]]];
            

            
            
            CGFloat fromAngle = [[mainAngles objectAtIndex:i] floatValue];
            CGFloat toAngle = [[mainAngles objectAtIndex:i+1] floatValue];
            if (i== 3) {
                mainAnimation[i] = [self animationFromAngle:fromAngle toAngle:toAngle duration:0.4];
            }else {
                mainAnimation[i] = [self animationFromAngle:fromAngle toAngle:toAngle duration:0.2];
            }
            
        }
    }
    
    /*
    if (PetViewTypeCouple != petViewType) {
        [mainItem[0] setUserInteractionEnabled:NO];
        [mainItem[1] setUserInteractionEnabled:NO];
        [mainItem[2] setUserInteractionEnabled:NO];
    }
    */
    
    if (PetViewTypeNoneCouple == petViewType) {
        //mainItem[0].userInteractionEnabled = mainItem[1].userInteractionEnabled = mainItem[2].userInteractionEnabled = NO;
        mainItem[0].canFlip = mainItem[1].canFlip = mainItem[2].canFlip = NO;
    }
    
}



-(void)initSadItems{
    CGFloat angleUp = 2*M_PI/12;
    CGFloat fromAngle = kAngle1;
    CGFloat toAngle = 0;
    
    for (int i = 0; i<[sads count]; i++) {
        if (nil==sadItem[i]) {
            sadItem[i] = [[PetActionItem alloc] initWithFrame:CGRectMake(160 -20, 211-20-120, kItemSizeSmall, kItemSizeSmall)];
            sadItem[i].delegate = self;
            sadItem[i].itemType = PetItemTypeSad;
            [sadItem[i] setFrontNormalImage:[UIImage imageNamed:@"pet_cq_circle"] 
                       frontHighlightedImage:[UIImage imageNamed:@"pet_cq_circle_press"] 
                             backNormalImage:[UIImage imageNamed:@"pet_cq_circle"] 
                        backHighlightedImage:[UIImage imageNamed:@"pet_cq_circle_press"]];
            
            CPUIModelPetFeelingAnim *anim = [sads objectAtIndex:i];
            NSString *name = anim.name;
            
            [sadItem[i] setTitle:name forState:UIControlStateNormal];
            sadItem[i].resourceID = anim.resourceID;
            sadItem[i].senderDesc = anim.senderDesc;
            sadItem[i].isDownloaded = [anim isAvailable];
            sadItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
            
            if (i!=0) {
                fromAngle = fromAngle + angleUp;
            }
            
            toAngle = fromAngle + angleUp;
            
            sadAnimation[i] = [self animationFromAngle:fromAngle toAngle:toAngle duration:0.07];
        }
    }
}

- (void)initHappyItems{
    
    CGFloat angleUp = 2*M_PI/12;
    CGFloat fromAngle = kAngle2;
    CGFloat toAngle = 0;
    
    for (int i = 0; i<[happys count]; i++) {
        if (nil==happyItem[i]) {
            happyItem[i] = [[PetActionItem alloc] initWithFrame:CGRectMake(160 -20, 211-20-120, kItemSizeSmall, kItemSizeSmall)];
            happyItem[i].delegate = self;
            happyItem[i].itemType = PetItemTypeHappy;
            [happyItem[i] setFrontNormalImage:[UIImage imageNamed:@"pet_cq_circle"] 
                      frontHighlightedImage:[UIImage imageNamed:@"pet_cq_circle_press"] 
                            backNormalImage:[UIImage imageNamed:@"pet_cq_circle"] 
                       backHighlightedImage:[UIImage imageNamed:@"pet_cq_circle_press"]];
            
            CPUIModelPetFeelingAnim *anim = [happys objectAtIndex:i];
            NSString *name = anim.name;
            
            [happyItem[i] setTitle:name forState:UIControlStateNormal];
            happyItem[i].resourceID = anim.resourceID;
            
            happyItem[i].senderDesc = anim.senderDesc;
            
            happyItem[i].isDownloaded = [anim isAvailable];
            
            happyItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
            
            if (i!=0) {
                fromAngle = fromAngle + angleUp;
            }
            
            toAngle = fromAngle + angleUp;
            
            happyAnimation[i] = [self animationFromAngle:fromAngle toAngle:toAngle duration:0.1];
        }
    }
}



- (void)initLoveItems{
    CGFloat angleUp = 2*M_PI/12;
    CGFloat fromAngle = kAngle3;
    CGFloat toAngle = 0;
    
    for (int i = 0; i<[loves count]; i++) {
        if (nil==loveItem[i]) {
            loveItem[i] = [[PetActionItem alloc] initWithFrame:CGRectMake(160 -20, 211-20-120, kItemSizeSmall, kItemSizeSmall)];
            loveItem[i].delegate = self;
            loveItem[i].itemType = PetItemTypeLove;
            [loveItem[i] setFrontNormalImage:[UIImage imageNamed:@"pet_cq_circle"] 
                        frontHighlightedImage:[UIImage imageNamed:@"pet_cq_circle_press"] 
                              backNormalImage:[UIImage imageNamed:@"pet_cq_circle"] 
                         backHighlightedImage:[UIImage imageNamed:@"pet_cq_circle_press"]];
            
            CPUIModelPetFeelingAnim *anim = [loves objectAtIndex:i];
            NSString *name = anim.name;
            
            [loveItem[i] setTitle:name forState:UIControlStateNormal];
            loveItem[i].resourceID = anim.resourceID;
            loveItem[i].senderDesc = anim.senderDesc;
            loveItem[i].isDownloaded = [anim isAvailable];
            
            loveItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
            
            if (i!=0) {
                fromAngle = fromAngle + angleUp;
            }
            
            toAngle = fromAngle + angleUp;
            
            loveAnimation[i] = [self animationFromAngle:fromAngle toAngle:toAngle duration:0.1];
        }
    }
}





#pragma mark -
#pragma mark layout items

-(void)layoutSadItems:(int)count{
    //sadItem 按钮位置调整
    
    if (count == [sads count]) {
        CGFloat angleUp = 2*M_PI/12;
        CGFloat fromAngle = kAngle1;
        CGFloat toAngle = 0;
        for (int i = 0; i<11; i++) {
            
            if (i!=0) {
                fromAngle = fromAngle + angleUp;
            }
            
            toAngle = fromAngle + angleUp;
            
            CGFloat x = (kRadius*cos(toAngle));
            CGFloat y = (kRadius*sin(toAngle));
            sadItem[i].center = CGPointMake(160+x, 211+y);
            
            [self expandItem:sadItem[i] angle:toAngle];
            
        }
    }
}

-(void)layoutHappyItems:(int)count{
    //happy 按钮位置调整
    if (count == [happys count]) {
        CGFloat angleUp = 2*M_PI/12;
        CGFloat fromAngle = kAngle2;
        CGFloat toAngle = 0;
        for (int i = 0; i<11; i++) {
            
            if (i!=0) {
                fromAngle = fromAngle + angleUp;
            }
            
            toAngle = fromAngle + angleUp;
            
            CGFloat x = (kRadius*cos(toAngle));
            CGFloat y = (kRadius*sin(toAngle));
            happyItem[i].center = CGPointMake(160+x, 211+y);
            
            [self expandItem:happyItem[i] angle:toAngle];
        }
    }
}


-(void)layoutLoveItems:(int)count{
    
    //loveItem 按钮位置调整
    
    if (count == [loves count]) {
        
        CGFloat angleUp = 2*M_PI/12;
        CGFloat fromAngle = kAngle3;
        CGFloat toAngle = 0;
        for (int i = 0; i<11; i++) {
            
            if (i!=0) {
                fromAngle = fromAngle + angleUp;
            }
            
            toAngle = fromAngle + angleUp;
            
            CGFloat x = (kRadius*cos(toAngle));
            CGFloat y = (kRadius*sin(toAngle));
            loveItem[i].center = CGPointMake(160+x, 211+y);
            
            [self expandItem:loveItem[i] angle:toAngle];
        }
    }
}


#pragma mark -
#pragma mark progress update

-(void)progressUpdate:(NSTimer *)timer{

    CGFloat angle = 350.0f/360.0f;  //修正按钮占据的角度
    
    progressView.progress =  progressView.progress+angle/300.0f;
    
    if (angle-progressView.progress<0.001) {
        [self stopTimer];
    }
}

#pragma mark -
#pragma mark timer control

-(void)startTimer{
    if (!voiceRecordTimer) {
        [progressView resetProgress];
        voiceRecordTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 
                                                            target:self 
                                                          selector:@selector(progressUpdate:) 
                                                          userInfo:nil 
                                                           repeats:YES];
    }else {
        [self stopTimer];
    }
    
}

-(void)stopTimer{
    if (voiceRecordTimer) {
        [voiceRecordTimer invalidate];
        voiceRecordTimer = nil;
    }
}


#pragma mark -
#pragma mark item touchable controls

-(void)disableItems{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[PetActionItem class]]) {
            aView.userInteractionEnabled = NO;
        }
    }
}

-(void)enableItems{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[PetActionItem class]]) {
            aView.userInteractionEnabled = YES;
        }
    }
    /*
    if (PetViewTypeCouple != petViewType) {  //非couple 不能传情
        [mainItem[0] setUserInteractionEnabled:NO];
        [mainItem[1] setUserInteractionEnabled:NO];
        [mainItem[2] setUserInteractionEnabled:NO];
    }*/
}


#pragma mark -
#pragma mark audio play
-(void)musicPlayer:(MusicPlayerManager *) player playToTime:(NSTimeInterval) time playerName:(NSString *)name{
    
    [player.audioPlayer updateMeters];
    //NSLog(@"Peak left: %f Avg right: %f", [player peakPowerForChannel:0],[player averagePowerForChannel:0]);
    
    //double peakPowerForChannel = pow(10, (0.05 * [player peakPowerForChannel:0]));
    double avgPowerForChannel = pow(10, (0.05 * [player.audioPlayer averagePowerForChannel:0]));
    //NSLog(@"Peak amp: %f, Avg amp:%f", peakPowerForChannel*100, avgPowerForChannel*100);
    
    int nIdx = (int)(avgPowerForChannel*16);
    
    //int nIdx = npeakPowerDB/10;
    
    //NSLog(@"amp nIdx: %d", nIdx);     
    
    [animView setImage:[UIImage imageNamed:[imageArray objectAtIndex:nIdx]]];
}

-(void)musicPlayerDidFinishPlaying:(MusicPlayerManager *) player playerName:(NSString *)name{
    CPLogInfo(@"musicPlayerDidFinishPlaying");
    [animView addAnimArray:zhanli forName:PET_ACTION_ZHALNI];  //说完保持站立
}

-(void)musicPlayerDecodeErrorDidOccur:(MusicPlayerManager *) player error:(NSError *)error playerName:(NSString *)name{
    CPLogError(@"musicPlayerDidFinishPlaying");
    [animView addAnimArray:zhanli forName:PET_ACTION_ZHALNI];  //说完保持站立
}

-(void)playAudioTip:(PetActionItem *)item{
    
    
    
    
    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:item.resourceID]) {
        CPUIModelPetFeelingAnim *anim = [[CPUIModelManagement sharedInstance] feelingObjectOfID:item.resourceID fromPet:@"pet_default"];
        if ([anim audioSlideCount]>0) {
            
            CPUIModelAudioSlideInfo *info = [[anim allAudioSlide] objectAtIndex:0];
            NSString *path = info.fileName;
            
            [[MusicPlayerManager sharedInstance] stop];
            [MusicPlayerManager sharedInstance].delegate = self;
            [[MusicPlayerManager sharedInstance] playMusic:path playerName:path];
            [animView pause];
            //[animView addAnimArray:shuohua forName:PET_ACTION_SHUOHUA];  //开始说话
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:item.resourceID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    

}




-(void)downloadWithItem:(PetActionItem *)item{
    
    if ([[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) { // wifi直接下载
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断"];
        [[CPUIModelManagement sharedInstance] downloadPetRes:item.resourceID ofPet:@"pet_default"];
        return;
    }
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isChecked"] boolValue]) {  // 非wifi
        // 不提示
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断"];
        [[CPUIModelManagement sharedInstance] downloadPetRes:item.resourceID ofPet:@"pet_default"];
        
    }else {
        if ([[Reachability reachabilityForInternetConnection] isReachable]) { 
            
            if (![[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) { // 非wifi条件下
                
                CPUIModelPetFeelingAnim *anim = [[CPUIModelManagement sharedInstance] feelingObjectOfID:item.resourceID fromPet:@"pet_default"];

                NSString *msg = [NSString stringWithFormat:@"该传情%0.1fM，你处于非wifi环境，现在下载么？",[[anim size] floatValue]/1024.0f];
                
                CheckMessageView *msgView = [[CheckMessageView alloc] initWithMessage:msg 
                                                                       withButtonType:DownLoadingSource 
                                                                          withContext:item];
                msgView.delegate = self;
                
            }
        }else {
            [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        }
    }

}

#pragma mark -
#pragma mark item action

- (void)itemTaped:(PetActionItem *)item{
    CPLogInfo(@"itemTaped");

    
    
    mainItem[0].canFlip = mainItem[1].canFlip =mainItem[2].canFlip = YES;
    
    if (PetViewTypeNoneCouple == petViewType) {
        mainItem[0].canFlip = mainItem[1].canFlip = mainItem[2].canFlip = NO;
    }
    
    
    [self disableItems];
    [self performSelector:@selector(enableItems) withObject:nil afterDelay:0.8];
    
    [progressView resetProgress];
    
    
    switch (item.itemType) {
        case PetItemTypeMain:    //主菜单按钮
        {
            isAlarm = NO;
            
            switch (item.tag) {
                case 1:          //不开心
                {

                    if (PetViewTypeNoneCouple == petViewType) {
                        [[HPTopTipView shareInstance] showMessage:@"好友不能传情哦，再亲密一点就能用啦"];
                        return;
                    }
                    
                    
                    longPressRecordButton.hidden = YES;
                    
                    [self hideMainItems:item];
                    
                    if (!isSubItemShow) {
                        [self performSelector:@selector(showSadItems) withObject:nil afterDelay:0.5];
                    }else {
                        [self hideSadItems];
                    }
                    
                    isSubItemShow = !isSubItemShow;
                    
                }
                    break;
                case 2:          //开心
                {

                    if (PetViewTypeNoneCouple == petViewType) {
                        [[HPTopTipView shareInstance] showMessage:@"好友不能传情哦，再亲密一点就能用啦"];
                        return;
                    }
                    
                    longPressRecordButton.hidden = YES;
                    
                    [self hideMainItems:item];
                    
                    if (!isSubItemShow) {
                        [self performSelector:@selector(showHappyItems) withObject:nil afterDelay:0.5];
                    }else {
                        [self hideHappyItems];
                    }
                    
                    isSubItemShow = !isSubItemShow;
                }
                    break;
                case 3:        //爱情
                {
                    if (PetViewTypeNoneCouple == petViewType) {
                        [[HPTopTipView shareInstance] showMessage:@"好友不能传情哦，再亲密一点就能用啦"];
                        return;
                    }
                    
                    longPressRecordButton.hidden = YES;
                    
                    [self hideMainItems:item];
                    if (!isSubItemShow) {
                        [self performSelector:@selector(showLoveItems) withObject:nil afterDelay:0.5];
                    }else {
                        [self hideLoveItems];
                    }
                    
                    isSubItemShow = !isSubItemShow;
                    
                    
                    
                }
                    break;
                case 4:{     // 闹钟
                    
                    //
                    NSLog(@"alarm");
                    
                    isAlarm = YES;
                    
                    [self hideMainItems:item];
                    
                    
                    
                    //self.currentMsgContentType = MSG_CONTENT_TYPE_CS;
                    
                    [progressView setProgressStartAngle:kAngle4+M_PI/18.0f];
                    
                    longPressRecordButton.hidden = !longPressRecordButton.hidden;
                    
                    [longPressRecordButton setTitle:@"长按录提醒" forState:UIControlStateNormal];
                    
                    
                    if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_alarm_tap_once"]) {
                        [[HPTopTipView shareInstance] showMessage:@"录好提醒发给Ta，有普通/神秘两种哦"];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_alarm_tap_once"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
                    if (!isSubItemShow) {
                        
                        //[self showTip4];
                        tipsLabel.text = @"把想提醒对方的话录下来";
                        
                        longPressRecordButton.hidden = NO;
                        
                        /*
                        //////
                        NSString *path = [[NSBundle mainBundle] pathForResource:@"pet_sound_chuansheng.mp3" ofType:nil];
                        [[MusicPlayerManager sharedInstance] stop];
                        [MusicPlayerManager sharedInstance].delegate = self;
                        [[MusicPlayerManager sharedInstance] playMusic:path playerName:path];
                        
                        [animView addAnimArray:shuohua forName:PET_ACTION_SHUOHUA];  //开始说话
                         */
                    }else {
                        [timeButton removeFromSuperview];
                        [sendButton removeFromSuperview];
                        [switcher removeFromSuperview];
                        [replayAlermButton removeFromSuperview];
                        
                        longPressRecordButton.hidden = YES;
                        
                        [self showTip1];
                        
                    }
                    
                    isSubItemShow = !isSubItemShow;
                    
                    
                }
                    break;
                case 5:        //传声
                {
                    
                    [self hideMainItems:item];
                    
                    
                    
                    self.currentMsgContentType = MSG_CONTENT_TYPE_CS;
                    
                    [progressView setProgressStartAngle:kAngle5+M_PI/18.0f];
                    
                    longPressRecordButton.hidden = !longPressRecordButton.hidden;
                    
                    if (!isSubItemShow) {
                        
                        [self showTip4];
                        //////
                        
                        if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_chuansheng_play_once"]) {
                            
                            NSString *path = [[NSBundle mainBundle] pathForResource:@"pet_sound_chuansheng.mp3" ofType:nil];
                            [[MusicPlayerManager sharedInstance] stop];
                            [MusicPlayerManager sharedInstance].delegate = self;
                            [[MusicPlayerManager sharedInstance] playMusic:path playerName:path];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_chuansheng_play_once"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                        

                        [animView pause];
                        //[animView addAnimArray:shuohua forName:PET_ACTION_SHUOHUA];  //开始说话
                    }else {
                        [self showTip1];
                    }
                    
                    isSubItemShow = !isSubItemShow;
                    
                }
                    break;
                case 6:         //提问
                {
                    
                    [self hideMainItems:item];
                    
                    
                    self.currentMsgContentType = MSG_CONTENT_TYPE_TTW;
                    
                    [progressView setProgressStartAngle:kAngle6+M_PI/18.0f];
                    
                    longPressRecordButton.hidden = !longPressRecordButton.hidden;
                    
                    if (!isSubItemShow) {
                        
                        [self showTip5];
                        
                        if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_toutouwen_play_once"]) {
                            
                            NSString *path = [[NSBundle mainBundle] pathForResource:@"pet_sound_toutouwen.mp3" ofType:nil];
                            [[MusicPlayerManager sharedInstance] stop];
                            [MusicPlayerManager sharedInstance].delegate = self;
                            [[MusicPlayerManager sharedInstance] playMusic:path playerName:path];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_toutouwen_play_once"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                        [longPressRecordButton setTitle:@"长按住提问" forState:UIControlStateNormal]; //长按住说话
                        //////

                        [animView pause];
                        //[animView addAnimArray:shuohua forName:PET_ACTION_SHUOHUA];  //开始说话
                    }else {
                        [self showTip1];
                        [longPressRecordButton setTitle:@"长按住说话" forState:UIControlStateNormal]; //
                    }

                    
                    isSubItemShow = !isSubItemShow;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case PetItemTypeHappy:
            //
        {
            CPLogInfo(@"PetItemTypeHappy taped");
            if ([self.delegate respondsToSelector:@selector(petActionItemTaped:)]) {
                [self.delegate petActionItemTaped:item];
            }
            
            self.currentResourceID = item.resourceID;
            self.currentMsgContentType = MSG_CONTENT_TYPE_CQ;
            
            [progressView setProgressStartAngle:kAngle2 + M_PI/18.0f];
            
            
            
            
            
            if (item.isDownloaded) {      //已经下载完成
                longPressRecordButton.hidden = NO;
                [self hideHappyItems];
                
                isSubItemShow = NO;
                mainItem[0].canFlip = mainItem[1].canFlip =mainItem[2].canFlip = NO;   //第一次返回不翻转
                
                [self playAudioTip:item];
                
            }else {                       //未下载，开始下载
                longPressRecordButton.hidden = YES;
                //[[CPUIModelManagement sharedInstance] downloadPetRes:item.resourceID ofPet:@"pet_default"];
                [self downloadWithItem:item];
            }
            
            [self showTip:item.senderDesc];
            
        }
            
            break;
        case PetItemTypeSad:
            //
        {
            CPLogInfo(@"PetItemTypeSad taped");
            
            self.currentResourceID = item.resourceID;
            self.currentMsgContentType = MSG_CONTENT_TYPE_CQ;
            
            [progressView setProgressStartAngle:kAngle1 + M_PI/18.0f];
            
            
            
            if (item.isDownloaded) {      //已经下载完成
                longPressRecordButton.hidden = NO;
                [self hideSadItems];
                
                isSubItemShow = NO;
                mainItem[0].canFlip = mainItem[1].canFlip =mainItem[2].canFlip = NO; //第一次返回不翻转
                
                [self playAudioTip:item];
                
            }else {                       //未下载，开始下载
                longPressRecordButton.hidden = YES;
                //[[CPUIModelManagement sharedInstance] downloadPetRes:item.resourceID ofPet:@"pet_default"];
                [self downloadWithItem:item];
            }
            
            [self showTip:item.senderDesc];
        }

            break;
        case PetItemTypeLove:
            //
        {
            CPLogInfo(@"PetItemTypeLove taped");
            
            self.currentResourceID = item.resourceID;
            self.currentMsgContentType = MSG_CONTENT_TYPE_CQ;
            
            [progressView setProgressStartAngle:kAngle3 + M_PI/18.0f];
            
            
            
            
            if (item.isDownloaded) {      //已经下载完成
                longPressRecordButton.hidden = NO;
                [self hideLoveItems];
                
                isSubItemShow = NO;
                mainItem[0].canFlip = mainItem[1].canFlip =mainItem[2].canFlip = NO; //第一次返回不翻转
                
                [self playAudioTip:item];
                
            }else {                       //未下载，开始下载
                longPressRecordButton.hidden = YES;
                //[[CPUIModelManagement sharedInstance] downloadPetRes:item.resourceID ofPet:@"pet_default"];
                [self downloadWithItem:item];
            }
            
            [self showTip:item.senderDesc];
        }
            break;
        case PetItemTypeVoice:
            //
            CPLogInfo(@"PetItemTypeVoice taped");
            break;
        case PetItemTypeAsk:
            //
            CPLogInfo(@"PetItemTypeAsk taped");
            //psdh.mp3
        {

        }

            
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark show or hide items 

-(void)hideMainItems:(PetActionItem *)item{
    NSMutableArray *items = [NSMutableArray array];
    
    for (int i=0 ; i<6; i++) {
        [items addObject:mainItem[i]];
    }
    
    
    for (PetActionItem *theItem in items) {
        if (theItem.tag != item.tag) {
            
            if (!isSubItemShow) {
                [theItem dismiss];
            }else {
                [theItem performSelector:@selector(show) withObject:nil afterDelay:0.5 ];
            }
        }
    }
}


-(void)showDownloadButton{
    
    if (![[CPUIModelManagement sharedInstance] isAllFeelingResAvailable]) {
        downloadAllButton.hidden = NO;
    }
}

-(void)hideDownloadButton{
    downloadAllButton.hidden = YES;
}

-(void)hideHappyItems{
    
    [self hideDownloadButton];
    
    [self showTip1];
    
    for (int i = 0; i<11; i++) {
        [happyItem[i] dismiss];
    }
}


-(void)hideSadItems{
    
    [self hideDownloadButton];
    
    [self showTip1];
    
    for (int i = 0; i<11; i++) {
        [sadItem[i] dismiss];
    }
}

- (void)hideLoveItems{
    
    [self hideDownloadButton];
    
    [self showTip1];
    
    for (int i = 0; i<11; i++) {
        [loveItem[i] dismiss];
    }
}


-(void)showMainItems{
    
    [self showTip1];
    
    for (int i = 0; i<6; i++) {
        [self addSubview:mainItem[5-i]];
        [mainItem[i].layer addAnimation:mainAnimation[0] forKey:@"mainAnimation0"];
    } 
}

-(void)showHappyItems{
    
    [self showDownloadButton];
    
    [self showTip7];
    
    for (int i = 0; i<11; i++) {
        [self addSubview:happyItem[10-i]];
        happyItem[i].transform = CGAffineTransformIdentity;
        happyItem[i].hidden = NO;
        [happyItem[i].layer addAnimation:happyAnimation[0] forKey:@"happyAnimation0"];
    }
}

-(void)showSadItems{
    
    [self showDownloadButton];
    
    [self showTip6];
    
    for (int i = 0; i<11; i++) {
        [self addSubview:sadItem[10-i]];
        sadItem[i].transform = CGAffineTransformIdentity;
        sadItem[i].hidden = NO;
        [sadItem[i].layer addAnimation:sadAnimation[0] forKey:@"sadAnimation0"];
    }
}


- (void)showLoveItems{
    
    [self showDownloadButton];
    
    [self showTip8];
    
    for (int i = 0; i<11; i++) {
        [self addSubview:loveItem[10-i]];
        loveItem[i].transform = CGAffineTransformIdentity;
        loveItem[i].hidden = NO;
        [loveItem[i].layer addAnimation:loveAnimation[0] forKey:@"loveAnimation0"];
    }
}

-(void)showCycle{
    
    //petDataDict
    
    [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"petDataDict" options:0 context:NULL];
    
    [self addSubview:progressView];
    [self bringSubviewToFront:animView];
    
    progressView.progress = 0.0f;
    progressView.center = CGPointMake(160, 200+11);
    progressView.transform = CGAffineTransformScale(progressView.transform,
                                                0.1, 0.1);

    [UIView animateWithDuration:0.5 
                     animations:^{
                         progressView.transform = CGAffineTransformIdentity;
                     } 
                     completion:^(BOOL finished) {
                         [self showMainItems];
                         
                         //群聊的时候直接录音
                         if (PetViewTypeGroup ==petViewType) {
                             longPressRecordButton.hidden = NO;
                         }
                         

                     }];
    
}

#pragma mark -
#pragma mark downloadall action

-(void)downloadAllButtonTaped:(id)sender{
    

    if ([[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) { // wifi直接下载
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断"];
        [[CPUIModelManagement sharedInstance] downloadAllFeelingResOfPet:@"pet_default"];
        //[[CPUIModelManagement sharedInstance] downloadAllFeelingResOfPet:nil];
        
        for (int i = 0; i<[sads count]; i++) {
            if (sadItem[i]) {
                CPUIModelPetFeelingAnim *anim = [sads objectAtIndex:i];
                sadItem[i].isDownloaded = [anim isAvailable];
                sadItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        for (int i = 0; i<[happys count]; i++) {
            if (happyItem[i]) {
                CPUIModelPetFeelingAnim *anim = [happys objectAtIndex:i];
                happyItem[i].isDownloaded = [anim isAvailable];
                happyItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        for (int i = 0; i<[loves count]; i++) {
            if (loveItem[i]) {
                CPUIModelPetFeelingAnim *anim = [loves objectAtIndex:i];
                loveItem[i].isDownloaded = [anim isAvailable];
                loveItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        return;
    }
    
    // 非wifi
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"isChecked"] boolValue]) {
        // 不提示
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断"];
        [[CPUIModelManagement sharedInstance] downloadAllFeelingResOfPet:@"pet_default"];
        //[[CPUIModelManagement sharedInstance] downloadAllFeelingResOfPet:nil];
        
        for (int i = 0; i<[sads count]; i++) {
            if (sadItem[i]) {
                CPUIModelPetFeelingAnim *anim = [sads objectAtIndex:i];
                sadItem[i].isDownloaded = [anim isAvailable];
                sadItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        for (int i = 0; i<[happys count]; i++) {
            if (happyItem[i]) {
                CPUIModelPetFeelingAnim *anim = [happys objectAtIndex:i];
                happyItem[i].isDownloaded = [anim isAvailable];
                happyItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        for (int i = 0; i<[loves count]; i++) {
            if (loveItem[i]) {
                CPUIModelPetFeelingAnim *anim = [loves objectAtIndex:i];
                loveItem[i].isDownloaded = [anim isAvailable];
                loveItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
    }else {
        if ([[Reachability reachabilityForInternetConnection] isReachable]) { 
            
            if (![[Reachability reachabilityForInternetConnection] isReachableViaWiFi]) { // 非wifi条件下
                
                
                CGFloat size = 0.0f;
                int animCount = 0;

                for (int i = 0; i<[sads count]; i++) {
                    CPLogInfo(@"sads");
                    CPUIModelPetFeelingAnim *anim = [sads objectAtIndex:i];
                    if (![anim isAvailable]) {
                        size = size + [[anim size] floatValue];
                        animCount++;
                    }
                }
                
                for (int i = 0; i<[happys count]; i++) {
                    CPLogInfo(@"happys");
                    CPUIModelPetFeelingAnim *anim = [happys objectAtIndex:i];
                    if (![anim isAvailable]) {
                        size = size + [[anim size] floatValue];
                        animCount++;
                    }
                }
                
                for (int i = 0; i<[loves count]; i++) {
                    CPLogInfo(@"loves");
                    CPUIModelPetFeelingAnim *anim = [loves objectAtIndex:i];
                    if (![anim isAvailable]) {
                        size = size + [[anim size] floatValue];
                        animCount++;
                    }
                }
                
                NSString *msg = [NSString stringWithFormat:@"共%d个传情表情（%0.1fM），你处于非wifi环境，现在下载么？",animCount,size/1024.0f];
                CheckMessageView *msgView = [[CheckMessageView alloc] initWithMessage:msg
                                                                       withButtonType:DownLoadingSource 
                                                                          withContext:sender];
                msgView.delegate = self;
                
            }
        }else {
            [[HPTopTipView shareInstance] showMessage:@"网络不是很给力哦，稍等后再试试"];
        }
    }
}


-(void) clickConfirm : (id) context{
    CPLogInfo(@"clickConfirm");
}

-(void) clickConfirm : (BOOL) isChecked withContext : (id) context{
    CPLogInfo(@"isChecked");
    
    if (isChecked) {  //
        CPLogInfo(@"111");
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"isChecked"];
    }else {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"isChecked"];
    }
    
    if ([context isKindOfClass:[PetActionItem class]]) {   // 单个表情下载
        PetActionItem *item = (PetActionItem *)context;
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断"];
        [[CPUIModelManagement sharedInstance] downloadPetRes:item.resourceID ofPet:@"pet_default"];
        return;
    }
    
    if ([context isKindOfClass:[UIButton class]]) {   // 全部下载
        [[HPTopTipView shareInstance] showMessage:@"高速下载中...请不要退出双双以免中断"];
        [[CPUIModelManagement sharedInstance] downloadAllFeelingResOfPet:@"pet_default"];
        //[[CPUIModelManagement sharedInstance] downloadAllFeelingResOfPet:nil];
        
        for (int i = 0; i<[sads count]; i++) {
            if (sadItem[i]) {
                CPUIModelPetFeelingAnim *anim = [sads objectAtIndex:i];
                sadItem[i].isDownloaded = [anim isAvailable];
                sadItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        for (int i = 0; i<[happys count]; i++) {
            if (happyItem[i]) {
                CPUIModelPetFeelingAnim *anim = [happys objectAtIndex:i];
                happyItem[i].isDownloaded = [anim isAvailable];
                happyItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        
        for (int i = 0; i<[loves count]; i++) {
            if (loveItem[i]) {
                CPUIModelPetFeelingAnim *anim = [loves objectAtIndex:i];
                loveItem[i].isDownloaded = [anim isAvailable];
                loveItem[i].downloadStatus = anim.downloadStatus;  //正在下载状态
                
            }
        }
        return;
    }
}


-(void) clickCancel : (id) context{
    CPLogInfo(@"clickCancel");
    
}

#pragma mark -
#pragma mark homebutton action

-(void)goHomeTaped:(id)sender{
    
    [datePicker removeFromSuperview];
    
    [animView stop];
    [self stopTimer];
    
    self.transform = CGAffineTransformIdentity;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height);
        datePicker.frame = CGRectMake(0, 480, 320, 300);
    } completion:^(BOOL finished) {
        //
        [datePicker removeFromSuperview];
        [UIView animateWithDuration:0.5 
                         animations:^{
                             self.transform = CGAffineTransformScale(self.transform,
                                                                     0.01, 0.01);
                         } 
                         completion:^(BOOL finished) {
                             
                             if (self.delegate&&[self.delegate respondsToSelector:@selector(petViewDidDismiss)]) {
                                 [self.delegate petViewDidDismiss];
                             }
                             
                             [self hidePetView];
                         }];
    }];
    
}

-(void)hidePetView{
    
    [[HPStatusBarTipView shareInstance] setHidden:NO];
    
    [[MusicPlayerManager sharedInstance] stop];
    [MusicPlayerManager sharedInstance].delegate = nil;
    
    [self stopTimer];
    [self removeFromSuperview];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (isAlarm) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0, 20, self.frame.size.width, self.frame.size.height);
            datePicker.frame = CGRectMake(0, 480, 320, 300);
        } completion:^(BOOL finished) {
            //
            [datePicker removeFromSuperview];
            goHome.hidden = NO;
        }];
    }
    


}

#pragma mark -
#pragma mark voice record



-(void)recordDidBegin{
    

    //开始录音按钮变灰色
    for (int i = 0; i<5; i++) {
        if (nil!= mainItem[i]) {
            
            UIImage *grayImage = [UIImage imageNamed:@"btn_pet_back_gray"];
            
            [mainItem[i] setFrontNormalImage:grayImage
                       frontHighlightedImage:grayImage
                             backNormalImage:grayImage 
                        backHighlightedImage:grayImage];
            
            //mainItem[i].userInteractionEnabled = NO;
            
        }
    }
    
    
    //开始录音的时候，其他按钮不允许点击
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[PetActionItem class]]) {
            aView.userInteractionEnabled = NO;
        }
    }
    
    // 如果正在播放提示，先停止播放
    [animView stop];
    [[MusicPlayerManager sharedInstance] stop];
    
    // 开始倾听
    [animView addAnimArray:ting1 forName:@"ting1"];
    
    isTimeOut = NO;
    
    [micView startRecord];
    
    [self startTimer];
    
    goHome.enabled = NO;
    
    

}

-(void)recordDidFinish{
    
    CPLogInfo(@"recordDidFinish");
    
    if (!isTimeOut) {    // 非自动停止
        [micView stopRecord];
        
        [animView addAnimArray:ting4 forName:@"ting4"];
        
        [self stopTimer];
        longPressRecordButton.hidden = YES;
    }
    

    if (isAlarm&&isTimeOut) {
        [micView stopRecord];
        
        [animView addAnimArray:ting4 forName:@"ting4"];
        
        [self stopTimer];
        longPressRecordButton.hidden = YES;
    }
     CPLogInfo(@"recordDidFinish");
    
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
    [self resetPet];
}

// 正确录音
-(void)arMicViewRecordDidEnd:(id) arMicView_ pcmPath:(NSString *)pcmPath_ length:(CGFloat) audioLength_{
    CPLogInfo(@"arMicViewRecordDidEnd");
    
    isTimeOut = YES;
    
    if (isAlarm) {  // 录闹钟,pet不自动消失
        
        tipsLabel.text = @"设定提醒时间，发给对方";
        
        [self addSubview:timeButton];
        [self addSubview:sendButton];
        [self addSubview:switcher];
        [self addSubview:replayAlermButton];
        goHome.enabled = YES;
        
        [self resetPet];
        //[self disableItems];
        
        
        if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_alarm_record_once"]) {
            [[HPTopTipView shareInstance] showMessage:@"点击时间栏可以编辑闹钟播放时间哦"];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_alarm_record_once"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        longPressRecordButton.hidden = YES;
        
        self.alarmFilePath = pcmPath_;
        self.alarmFileLength = audioLength_;
        
        if (nil == [[NSUserDefaults standardUserDefaults] objectForKey:@"pet_alarm_replay_once"]) {

            OverlayGuidView *guid1 = [[OverlayGuidView alloc] initWithFrame:CGRectMake((320-286/2)/2, 140, 286/2, 286/2)];
            guid1.backgroundColor = [UIColor clearColor];
            [guid1 setImage:[UIImage imageNamed:@"pet_float_guide01"]];
            [guid1 showInView:self];

            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"pet_alarm_replay_once"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        return;
    }
    
    [self goHomeTaped:nil];
    
    if (PetViewTypeGroup ==petViewType) {      //群聊的时候，直接录音，当传声处理
        CPUIModelMessage *msg = [[CPUIModelMessage alloc] init];
        //msg.msgData = data;
        msg.filePath = pcmPath_;
        msg.mediaTime = [NSNumber numberWithFloat:audioLength_];
        msg.petMsgID = @"pet_default";
        msg.contentType = [NSNumber numberWithInt:MSG_CONTENT_TYPE_CS]; 
        if ([self.delegate respondsToSelector:@selector(petFeelingStartSend:message:)]) {
            [self.delegate petFeelingStartSend:self message:msg];
        }
        msg = nil;
    }else {
        switch (self.currentMsgContentType) {
            case MSG_CONTENT_TYPE_CQ:   //传情
            {
                CPUIModelMessage *msg = [[CPUIModelMessage alloc] init];
                //msg.msgData = data;
                msg.filePath = pcmPath_;
                msg.mediaTime = [NSNumber numberWithFloat:audioLength_];
                msg.petMsgID = @"pet_default";
                msg.magicMsgID = self.currentResourceID;
                msg.contentType = [NSNumber numberWithInt:MSG_CONTENT_TYPE_CQ]; 
                if ([self.delegate respondsToSelector:@selector(petFeelingStartSend:message:)]) {
                    [self.delegate petFeelingStartSend:self message:msg];
                }
                
                msg = nil;
            }
                break;
            case MSG_CONTENT_TYPE_CS:  // 传声
            {
                CPUIModelMessage *msg = [[CPUIModelMessage alloc] init];
                //msg.msgData = data;
                msg.filePath = pcmPath_;
                msg.mediaTime = [NSNumber numberWithFloat:audioLength_];
                msg.petMsgID = @"pet_default";
                msg.contentType = [NSNumber numberWithInt:MSG_CONTENT_TYPE_CS]; 
                if ([self.delegate respondsToSelector:@selector(petFeelingStartSend:message:)]) {
                    [self.delegate petFeelingStartSend:self message:msg];
                }
                
                msg = nil;
            }
                break;
            case MSG_CONTENT_TYPE_TTW:  // 偷偷问
            {
                CPUIModelMessage *msg = [[CPUIModelMessage alloc] init];
                //msg.msgData = data;
                msg.filePath = pcmPath_;
                msg.mediaTime = [NSNumber numberWithFloat:audioLength_];
                msg.petMsgID = @"pet_default";
                msg.contentType = [NSNumber numberWithInt:MSG_CONTENT_TYPE_TTW]; 
                if ([self.delegate respondsToSelector:@selector(petFeelingStartSend:message:)]) {
                    [self.delegate petFeelingStartSend:self message:msg];
                }
                
                msg = nil;
            }
                break;
            default:
                
                CPLogInfo(@"Error !!!!!");
                break;
        }
    }
}

// 录音转码失败或者被中断
-(void)arMicViewRecordErrorDidOccur:(id) arMicView_ error:(NSError *)error{
    CPLogInfo(@"arMicViewRecordErrorDidOccur");
    [[HPTopTipView shareInstance] showMessage:@"录音失败！"];
    [self resetPet];
}


-(void)resetPet{
    
    NSArray *array1 = [NSArray arrayWithObjects:@"btn_pet_cry",@"btn_pet_cry_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"btn_pet_smile",@"btn_pet_smilepress",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"btn_pet_heart",@"btn_pet_heart_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array4 = [NSArray arrayWithObjects:@"pet_btn_clock",@"pet_btn_clock_press",@"pet_btn_back_yellow",@"pet_btn_back_yellow_press",nil]; // alarm
    NSArray *array5 = [NSArray arrayWithObjects:@"btn_pet_microphone",@"btn_pet_microphone_press",@"btn_pet_back_blue",@"btn_pet_back_blue_press",nil];
    NSArray *array6 = [NSArray arrayWithObjects:@"btn_pet_ask",@"btn_pet_ask_press",@"pet_btn_back_ask",@"pet_btn_back_ask_press",nil]; 
    
    
    NSArray *array11 = [NSArray arrayWithObjects:@"btn_pet_cry_grey",@"btn_pet_cry_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array22 = [NSArray arrayWithObjects:@"btn_pet_smile_grey",@"btn_pet_smile_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array33 = [NSArray arrayWithObjects:@"btn_pet_heart_grey",@"btn_pet_heart_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    
    NSArray *images;
    
    if (PetViewTypeCouple == petViewType) {
        images = [NSArray arrayWithObjects:array1,array2,array3,array4,array5,array6, nil];
    }else {
        images = [NSArray arrayWithObjects:array11,array22,array33,array4,array5,array6, nil];
    }
    /*
    // 返回图片
    NSArray *array1 = [NSArray arrayWithObjects:@"btn_pet_cry",@"btn_pet__cry_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array2 = [NSArray arrayWithObjects:@"btn_pet_smile",@"btn_pet_smile_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array3 = [NSArray arrayWithObjects:@"btn_pet_heart",@"btn_pet_heart_press",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array4 = [NSArray arrayWithObjects:@"btn_pet_microphone",@"btn_pet_microphone_press",@"btn_pet_back_blue",@"btn_pet_back_blue_press",nil];
    NSArray *array5 = [NSArray arrayWithObjects:@"btn_pet_ask",@"btn_pet_ask_press",@"btn_pet_back_blue",@"btn_pet_back_blue_press",nil]; 
    
    NSArray *array11 = [NSArray arrayWithObjects:@"btn_pet_cry_grey",@"btn_pet_cry_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array22 = [NSArray arrayWithObjects:@"btn_pet_smile_grey",@"btn_pet_smile_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    NSArray *array33 = [NSArray arrayWithObjects:@"btn_pet_heart_grey",@"btn_pet_heart_grey",@"btn_pet_back",@"btn_pet_back_press",nil];
    
    NSArray *images;
    
    if (PetViewTypeCouple == petViewType) {
        images = [NSArray arrayWithObjects:array1,array2,array3,array4,array5, nil];
    }else {
        images = [NSArray arrayWithObjects:array11,array22,array33,array4,array5, nil];
    }
    */
    
    for (int i = 0; i<6; i++) {
        if (nil!= mainItem[i]) {
            
            NSArray *imagesArray = [images objectAtIndex:i];
            
            [mainItem[i] setFrontNormalImage:[UIImage imageNamed:[imagesArray objectAtIndex:0]]
                       frontHighlightedImage:[UIImage imageNamed:[imagesArray objectAtIndex:1]] 
                             backNormalImage:[UIImage imageNamed:[imagesArray objectAtIndex:2]] 
                        backHighlightedImage:[UIImage imageNamed:[imagesArray objectAtIndex:3]]];
        }
    }
    
    
    // 允许按钮点击
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[PetActionItem class]]) {
            aView.userInteractionEnabled = YES;
        }
    }
    

    [self stopTimer];
    
    [progressView resetProgress];
    goHome.enabled = YES;
    longPressRecordButton.hidden = NO;
}

#pragma mark -
#pragma mark dealloc

-(void)dealloc{
    
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"petDataDict" context:NULL];
}

@end
