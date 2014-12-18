//
//  MsgPlaySound.m
//  teacher
//
//  Created by singlew on 14/12/17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "MsgPlaySound.h"

@implementation MsgPlaySound

- (id)initSystemShake{
    self = [super init];
    if (self) {
        sound = kSystemSoundID_Vibrate;//震动
    }
    return self;
}

- (id)initSystemSoundWithName:(NSString *)soundName SoundType:(NSString *)soundType{
    self = [super init];
    if (self) {
        NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.%@",soundName,soundType];
        if (path) {
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&sound);
            if (error != kAudioServicesNoError) {
                sound = 0;
            }
        }
    }
    return self;
}

- (void)play{
    if (sound != 0) {
        AudioServicesPlaySystemSound(sound);
    }
}
@end
