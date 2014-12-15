//
//  SingleSoundCell.m
//  iCouple
//
//  Created by ming bright on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SingleSoundCell.h"

@interface SingleSoundCell ()
-(void) changeState;
@property (nonatomic,strong) UIImageView *unReadImage;
@end

@implementation SingleSoundCell




- (void)playButtonTaped:(UIButton *)sender{
    CPLogInfo(@"start");
    //sender.backgroundColor = [UIColor blackColor];
    if ([self.delegate respondsToSelector:@selector(soundCellTaped:)]) {
        [self.delegate soundCellTaped:self];
    }

}

- (void)createAvatar{
    [self createAvatarControl];
}


-(void)refreshPlayStatus:(BOOL) isPlaying_{
    [self changeState];

}

-(void) changeState{
    ExMessageModel *exModel = (ExMessageModel *)self.data;
    CPLogInfo(@"%@",exModel.isPlaySound == YES ? @"YES" : @"NO");
    
    if (nil != self.unReadImage) {
        [self.unReadImage removeFromSuperview];
        self.unReadImage = nil;
    }
    
    if (exModel.isPlaySound) {
        if (self.isBelongMe) {
            [playButton setBackgroundImage:[[UIImage imageNamed:@"i_voice_talk"] stretchableImageWithLeftCapWidth:38.0f topCapHeight:0] forState:UIControlStateNormal];
            [playButton setBackgroundImage:[[UIImage imageNamed:@"i_voice_talk"] stretchableImageWithLeftCapWidth:38.0f topCapHeight:0] forState:UIControlStateHighlighted];
        }else {
            [playButton setBackgroundImage:[[UIImage imageNamed:@"other_voice_talk"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0] forState:UIControlStateNormal];
            [playButton setBackgroundImage:[[UIImage imageNamed:@"other_voice_talk"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0] forState:UIControlStateHighlighted];
        }
    }else {
        if (self.isBelongMe) {
            [playButton setBackgroundImage:[[UIImage imageNamed:@"i_voice_talk"] stretchableImageWithLeftCapWidth:38.0f topCapHeight:0] forState:UIControlStateNormal];
            [playButton setBackgroundImage:[[UIImage imageNamed:@"i_voice_talk"] stretchableImageWithLeftCapWidth:38.0f topCapHeight:0] forState:UIControlStateHighlighted];
        }else {
            if ([exModel.messageModel.sendState intValue] == MSG_SEND_STATE_AUDIO_READED) {
                [playButton setBackgroundImage:[[UIImage imageNamed:@"other_voice_talk"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0] forState:UIControlStateNormal];
                [playButton setBackgroundImage:[[UIImage imageNamed:@"other_voice_talk"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0] forState:UIControlStateHighlighted];
            }else {
                [playButton setBackgroundImage:[[UIImage imageNamed:@"other_voice_talk"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0] forState:UIControlStateNormal];
                [playButton setBackgroundImage:[[UIImage imageNamed:@"other_voice_talk"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:0] forState:UIControlStateHighlighted];
                self.unReadImage = [[UIImageView alloc] initWithFrame:CGRectMake(-12.0f, 24.0f, 10.0f, 10.0f)];
                self.unReadImage.image = [UIImage imageNamed:@"new_mes"];
                [playButton addSubview:self.unReadImage];
            }
        }
    }
    
}

-(void)playCompleted{
    ExMessageModel *model = (ExMessageModel*)self.data;
    playTimeLabel.text = [NSString stringWithFormat:@"%d\"",[model.messageModel.mediaTime intValue]];

}

- (id)initWithType : (MessageCellType) messageCellType  withBelongMe : (BOOL) isBelongMe withKey:(NSString *)key{
    
    self = [super initWithType:messageCellType withBelongMe:isBelongMe withKey:key];
    if (self) {
        
        playButton = [[UIButton alloc] initWithFrame: CGRectMake(kAvatarWidth + 7.5f, kCellTopPadding, kWidthOfSound, kHeightOfSound)];
        playButton.backgroundColor = [UIColor clearColor];
        [playButton addTarget:self action:@selector(playButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        playButton.exclusiveTouch = YES;
        
        stateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kWidthOfSound/2 - 50, 5, 50, kHeightOfSound-10)];
        stateImageView.userInteractionEnabled = YES;
        stateImageView.backgroundColor = [UIColor redColor];
        
        playTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(playButton.frame.origin.x + 10.0f, 10, 35, kHeightOfSound -20)];
        playTimeLabel.backgroundColor = [UIColor clearColor];
        playTimeLabel.textColor = [UIColor colorWithHexString:@"#999999"];
        playTimeLabel.font = [UIFont systemFontOfSize:12];
        
    }
    return self;
}

-(CGFloat)cellHeight{
    return 60.0;
}

-(void)updatePlayTime:(float)second{
    if (second <= 0.0f) {
        second = 0.0f;
    }
    playTimeLabel.text = [NSString stringWithFormat:@"%.0f\"",second];
}

- (void)refreshCell{
    [super refreshCell];
    
    ExMessageModel *model = (ExMessageModel*)self.data;
    CPLogInfo(@"model.messageModel.filePath :  %@",model.messageModel.filePath);
    
    int maxWidth = kWidthOfSound + 6.0f * [model.messageModel.mediaTime integerValue];
    if (maxWidth > 220.0f) {
        maxWidth = 220.0f;
    }
    if (self.isBelongMe) {
        playButton.frame = CGRectMake(kAvatarWidth + 7.5f, kCellTopPadding, maxWidth, kHeightOfSound);
        playTimeLabel.frame = CGRectMake(playButton.frame.size.width + 4.0f, 2, 35, kHeightOfSound -20);
    }else{
        playButton.frame = CGRectMake(320.0f - maxWidth -kAvatarWidth- 7.5f, kCellTopPadding, maxWidth, kHeightOfSound);
        playTimeLabel.frame = CGRectMake(-15.0f, 2.0f, 35.0f, kHeightOfSound - 20);
    }
    
    playTimeLabel.text = [NSString stringWithFormat:@"%d\"",[model.messageModel.mediaTime intValue]];

    [self addSubview:playButton];
    [playButton addSubview:playTimeLabel];
    
    
    [self changeState];
    
    timestampLabel.frame = CGRectMake((320 -50)/2, playButton.frame.size.height+kCellTopPadding, 50, kTimestampLabelHeight);
    timestampLabel.text = [self timeStringFromNumber:model.messageModel.date];
    
    self.resendButton.frame = CGRectMake(playButton.frame.origin.x + playButton.frame.size.width + 10.0f, 
                                         ( playButton.frame.size.height - kResendButtonWidth ) /2.0f + 2.0f,
                                         kResendButtonWidth, kResendButtonWidth);
    
    if (self.isBelongMe) {
        avatar.frame = CGRectMake(7.5f, kCellTopPadding - 6.0f, kAvatarWidth, kAvatarHeight);
    }else{
        avatar.frame = CGRectMake(320.0f-7.5f-kAvatarWidth, kCellTopPadding - 6.0f, kAvatarWidth, kAvatarHeight);
    }
    
    if (!self.userHeadImage) {
        avatar.backImage = [UIImage imageNamed:@"headpic_index_normal_120x120"];
    }else {
        avatar.backImage = self.userHeadImage;
    }
    
}


@end
