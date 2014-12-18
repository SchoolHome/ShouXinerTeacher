//
//  MsgPlaySound.h
//  teacher
//
//  Created by singlew on 14/12/17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface MsgPlaySound : NSObject{
    SystemSoundID sound;
}
- (id)initSystemShake;
- (id)initSystemSoundWithName:(NSString *)soundName SoundType:(NSString *)soundType;
- (void)play;
@end
