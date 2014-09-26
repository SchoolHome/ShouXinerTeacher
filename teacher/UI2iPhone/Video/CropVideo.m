//
//  CropVideo.m
//  teacher
//
//  Created by singlew on 14-9-26.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "CropVideo.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVComposition.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVCompositionTrack.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVVideoComposition.h>


@implementation CropVideo
- (void) loadVideoByPath:(NSString*) v_strVideoPath andSavePath:(NSString*) v_strSavePath {
    NSLog(@"\nv_strVideoPath = %@ \nv_strSavePath = %@\n ",v_strVideoPath,v_strSavePath);
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:v_strVideoPath]];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    NSLog(@"视频时长 %f\n",duration);
    
    AVMutableComposition *avMutableComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *avMutableCompositionTrack = [avMutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *avAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    NSError *error = nil;
    // 这块是裁剪,rangtime .前面的是开始时间,后面是裁剪多长 (我这裁剪的是从第二秒开始裁剪，裁剪2.55秒时长.)
    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(CMTimeMakeWithSeconds(0.0f, 30), CMTimeMakeWithSeconds(60.0f, 30))
                                       ofTrack:avAssetTrack
                                        atTime:kCMTimeZero
                                         error:&error];
    
    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition];
    // 这个视频大小可以由你自己设置。比如源视频640*480.而你这320*480.最后出来的是320*480这么大的，640多出来的部分就没有了。并非是把图片压缩成那么大了。
    avMutableVideoComposition.renderSize = CGSizeMake(320.0f, 480.0f);
    avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    // 这句话暂时不用理会，我正在看是否能添加logo而已。
    
    AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [avMutableComposition duration])];
    
    AVMutableVideoCompositionLayerInstruction *avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
    [avMutableVideoCompositionLayerInstruction setTransform:avAssetTrack.preferredTransform atTime:kCMTimeZero];
    
    avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObject:avMutableVideoCompositionLayerInstruction];
    
    
    avMutableVideoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
    
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    if ([fm fileExistsAtPath:v_strSavePath]) {
        NSLog(@"video is have. then delete that");
        if ([fm removeItemAtPath:v_strSavePath error:&error]) {
            NSLog(@"delete is ok");
        }else {
            NSLog(@"delete is no error = %@",error.description);
        }
    }
    
    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avMutableComposition presetName:AVAssetExportPreset640x480];
    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
    [avAssetExportSession setOutputURL:[NSURL fileURLWithPath:v_strSavePath]];
    [avAssetExportSession setOutputFileType:AVFileTypeQuickTimeMovie];
    [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (avAssetExportSession.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"exporting failed %@",[avAssetExportSession error]);
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"exporting completed");
                // 想做什么事情在这个做
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"export cancelled");
                break;
            case AVAssetExportSessionStatusUnknown:
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            case AVAssetExportSessionStatusExporting:
                break;
        }
    }];
}
@end
