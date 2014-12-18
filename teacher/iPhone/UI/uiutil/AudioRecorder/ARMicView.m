//
//  ARMicView.m
//  iCouple
//
//  Created by ming bright on 12-6-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ARMicView.h"
#import "CoreUtils.h"
#import "ColorUtil.h"
@implementation ARMicView
@synthesize delegate;
@synthesize recoderType;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(id)initWithCenter:(CGPoint )center_{
    
    self = [self initWithFrame:CGRectMake(0, 0, 159/2, 159/2)];
    if (self) {
        self.center = center_;

        recoderType = RECORDER_TYPE_COMMON;
        
        totalCount = 60.0f; 
        
        micBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        micBackground.image = [UIImage imageNamed:@"im_recording"];
        micBackground.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        [self addSubview:micBackground];
        
        countDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(11,62,60,15)];
        countDownLabel.backgroundColor = [UIColor clearColor];
        //countDownLabel.textColor = [UIColor colorWithHexString:@"#CCCCCC"];
        countDownLabel.textColor = [UIColor whiteColor];
        countDownLabel.shadowColor = [UIColor blackColor];
        countDownLabel.shadowOffset = CGSizeMake(0,-1);
        countDownLabel.textAlignment = UITextAlignmentCenter;
        countDownLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:countDownLabel];
        countDownLabel.text = [NSString stringWithFormat:@"%ds",(int)totalCount];
        
        levelView = [[ARLevelView alloc] initWithFrame:CGRectMake(54.0, 22.0, 17.0, 37.0)];
        [self addSubview:levelView];
        
        audioRecorder = [[AudioRecorder alloc] init];
        audioRecorder.delegate = self;
    }
    
    return self;
}

-(void)startTimer{
    if (!recordTimer) {
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 
                                                       target:self 
                                                     selector:@selector(updateTimer:) 
                                                     userInfo:nil 
                                                      repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:recordTimer forMode:NSRunLoopCommonModes];
        //[[NSRunLoop currentRunLoop] run];
    }
}

-(void)stopTimer{
    if (recordTimer) {
        [recordTimer invalidate];
        recordTimer = nil;
    }
}

-(void)updateTimer:(NSTimer *) timer{
    
    
    CGFloat volume = [audioRecorder currentVolume];  //0~30
    
    int level = (int)volume/3;
    
    [self updateVolume:level];
    
    totalCount = totalCount - 0.2;
    
    if (totalCount<=0.0f) {  // 录音满60s，自动停止
        [self stopRecord]; 
    }
    
    countDownLabel.text = [NSString stringWithFormat:@"%ds",(int)totalCount];
    
}

-(void)showShortError{
    micBackground.image = [UIImage imageNamed:@"im_recording_error"];
}

-(void)resetBack{
    micBackground.image = [UIImage imageNamed:@"im_recording"];
}

-(void)updateVolume:(int)lv{
    [levelView setLevel:lv];
}

-(void)startRecord{
    
    // 删除残留文件
    NSString *pcmPath = [[NSString alloc] initWithFormat:@"%@/%@",RECORDER_PATH_DOCUMENT,RECORDER_PATH_PCM];
    [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
    
    // 恢复背景
    [self resetBack];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // 重置倒计时
    totalCount = 60.0f;
    
    // 开始计时录音
    [self startTimer];

    [audioRecorder start];

    // 开始回调
    if (self.delegate&&[self.delegate respondsToSelector:@selector(arMicViewRecordDidStarted:)]) {
        [self.delegate arMicViewRecordDidStarted:self];
    }
}

-(void)stopRecord{
    [self stopTimer];
    [audioRecorder stop];
}

-(void)audioRecorderDidFinish:(NSString *)pcmPath_{
    
    if (totalCount>59) {    //录音太短
        [self showShortError];
        
        if (self.delegate&&[self.delegate respondsToSelector:@selector(arMicViewRecordTooShort:)]) {
            [self.delegate arMicViewRecordTooShort:self];
        }
        
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1];
        
    }else {    // 正常录音
        if (self.delegate&&[self.delegate respondsToSelector:@selector(arMicViewRecordDidEnd:pcmPath:length:)]) {
            
            // 拷贝文件
            NSString *pcmPath = [NSString stringWithFormat:@"%@/%@",RECORDER_PATH_DOCUMENT,RECORDER_PATH_PCM];
            NSString *destPath = [NSString stringWithFormat:@"%@/%@.caf",RECORDER_PATH_DOCUMENT,[CoreUtils getUUID]];
            [[NSFileManager defaultManager] copyItemAtPath:pcmPath toPath:destPath error:NULL];
            

            CGFloat len = 60.0-totalCount;
            
            [self.delegate arMicViewRecordDidEnd:self pcmPath:destPath length:len];
        }
        [self removeFromSuperview];
    }
}

-(void)audioRecorderErrorDidOccur:(NSError *)error_{    // 转码失败或录音中断
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(arMicViewRecordErrorDidOccur:error:)]) {
        [self.delegate arMicViewRecordErrorDidOccur:self error:error_];
    }
    
    [self removeFromSuperview];
}


@end
