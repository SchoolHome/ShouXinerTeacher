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
#import <AVFoundation/AVAssetImageGenerator.h>

@implementation CropVideo
+(NSDictionary *) cropVideoByPath:(NSURL *) videoPath andSavePath:(NSString*) videoSavePath {
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *error = nil;
    if ([fm fileExistsAtPath:videoSavePath]) {
        NSLog(@"video is have. then delete that");
        if ([fm removeItemAtPath:videoSavePath error:&error]) {
            NSLog(@"delete is ok");
        }else {
            NSLog(@"delete is no error = %@",error.description);
        }
    }
    
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    BOOL isSucess = YES;
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoPath options:nil];
    
    long long videoValue = videoAsset.duration.value;
    NSInteger videoTimeScale = videoAsset.duration.timescale;
    long long videoTime = videoValue/videoTimeScale;
    if (videoValue%videoTimeScale>0){
        videoTime ++;
    }
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(360,480);
    
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    AVAssetTrack *sourceVideo = [[videoAsset tracksWithMediaType:AVMediaTypeVideo]lastObject];
    [compositionVideoTrack setPreferredTransform:sourceVideo.preferredTransform];
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:videoAsset
                                                                          presetName:AVAssetExportPresetMediumQuality];
    
    NSURL *exportUrl = [NSURL fileURLWithPath:videoSavePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoSavePath]){
        [[NSFileManager defaultManager] removeItemAtPath:videoSavePath error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = exportUrl;
    _assetExport.timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero,CMTimeMakeWithSeconds(60.0f, 30));
    _assetExport.shouldOptimizeForNetworkUse = YES;
    __block NSNumber *fileSize = nil;
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         if (_assetExport.status == AVAssetExportSessionStatusCompleted){
             fileSize = [self getFileSizeWithName:videoSavePath];
             CropVideoModel *crop = [[CropVideoModel alloc] init];
             crop.state = kCropVideoCompleted;
             [PalmUIManagement sharedInstance].videoState = crop;
         }else{
             CPLogInfo(@"convert mpeg-4  error %@ ||  %@ ||%@ ||%@||%d",
                       _assetExport.debugDescription,_assetExport.description,[_assetExport.error localizedDescription],
                       [_assetExport.error localizedFailureReason],[_assetExport.error code]);
             CropVideoModel *crop = [[CropVideoModel alloc] init];
             crop.state = kCropVideoCompleted;
             crop.error = _assetExport.description;
             [PalmUIManagement sharedInstance].videoState = crop;
             
         }
     }
     ];
    if (error){
        CPLogError(@"convert mpeg-4 error is  %@",[error localizedDescription]);
    }
    [resDic setObject:[NSNumber numberWithBool:isSucess] forKey:convertMpeg4IsSucess];
    if (fileSize){
        [resDic setObject:fileSize forKey:convertMpeg4FileSize];
    }
    return resDic;
    
//    AVAsset *avAsset = [AVAsset assetWithURL:videoPath];
//    CMTime assetTime = [avAsset duration];
//    Float64 duration = CMTimeGetSeconds(assetTime);
//    NSLog(@"视频时长 %f\n",duration);
//    
//    AVMutableComposition *avMutableComposition = [AVMutableComposition composition];
//    
//    AVMutableCompositionTrack *avMutableCompositionTrack = [avMutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    AVAssetTrack *avAssetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    
//    NSError *error = nil;
//    [avMutableCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60.0f, 30))
//                                       ofTrack:avAssetTrack
//                                        atTime:kCMTimeZero
//                                         error:&error];
//    
//    AVMutableVideoComposition *avMutableVideoComposition = [AVMutableVideoComposition videoComposition];
//    avMutableVideoComposition.renderSize = CGSizeMake(320.0f, 480.0f);
//    avMutableVideoComposition.frameDuration = CMTimeMake(1, 30);
//    
//    AVMutableVideoCompositionInstruction *avMutableVideoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    
//    [avMutableVideoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, [avMutableComposition duration])];
//    
//    AVMutableVideoCompositionLayerInstruction *avMutableVideoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:avAssetTrack];
//    [avMutableVideoCompositionLayerInstruction setTransform:avAssetTrack.preferredTransform atTime:kCMTimeZero];
//    
//    avMutableVideoCompositionInstruction.layerInstructions = [NSArray arrayWithObject:avMutableVideoCompositionLayerInstruction];
//    
//    
//    avMutableVideoComposition.instructions = [NSArray arrayWithObject:avMutableVideoCompositionInstruction];
//    
//    
//    NSFileManager *fm = [[NSFileManager alloc] init];
//    if ([fm fileExistsAtPath:videoSavePath]) {
//        NSLog(@"video is have. then delete that");
//        if ([fm removeItemAtPath:videoSavePath error:&error]) {
//            NSLog(@"delete is ok");
//        }else {
//            NSLog(@"delete is no error = %@",error.description);
//        }
//    }
//    
//    AVAssetExportSession *avAssetExportSession = [[AVAssetExportSession alloc] initWithAsset:avMutableComposition presetName:AVAssetExportPreset640x480];
//    [avAssetExportSession setVideoComposition:avMutableVideoComposition];
//    avAssetExportSession.timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero,CMTimeMakeWithSeconds(60.0f, 30));
//    [avAssetExportSession setOutputURL:[NSURL fileURLWithPath:videoSavePath]];
//    [avAssetExportSession setOutputFileType:AVFileTypeQuickTimeMovie];
//    [avAssetExportSession setShouldOptimizeForNetworkUse:YES];
//    [avAssetExportSession exportAsynchronouslyWithCompletionHandler:^(void){
//        CropVideoModel *model = [[CropVideoModel alloc] init];
//        switch (avAssetExportSession.status) {
//            case AVAssetExportSessionStatusFailed:
//                model.state = KCropVideoError;
//                model.error = [[avAssetExportSession error] debugDescription];
//                [[PalmUIManagement sharedInstance] willChangeValueForKey:@"videoState"];
//                [PalmUIManagement sharedInstance].videoState = model;
//                [[PalmUIManagement sharedInstance] didChangeValueForKey:@"videoState"];
//                break;
//            case AVAssetExportSessionStatusCompleted:
//                model.state = kCropVideoCompleted;
//                model.error = @"";
//                [[PalmUIManagement sharedInstance] willChangeValueForKey:@"videoState"];
//                [PalmUIManagement sharedInstance].videoState = model;
//                [[PalmUIManagement sharedInstance] didChangeValueForKey:@"videoState"];
//                break;
//            case AVAssetExportSessionStatusCancelled:
//                NSLog(@"export cancelled");
//                break;
//            case AVAssetExportSessionStatusUnknown:
//                break;
//            case AVAssetExportSessionStatusWaiting:
//                model.state = kCropingVideo;
//                model.error = @"";
//                [[PalmUIManagement sharedInstance] willChangeValueForKey:@"videoState"];
//                [PalmUIManagement sharedInstance].videoState = model;
//                [[PalmUIManagement sharedInstance] didChangeValueForKey:@"videoState"];
//                break;
//            case AVAssetExportSessionStatusExporting:
//                break;
//        }
//    }];
}

+(NSDictionary *)convertMpeg4WithUrl:(NSURL *)url andDstFilePath:(NSString *)dstFilePath{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *error = nil;
    if ([fm fileExistsAtPath:dstFilePath]) {
        NSLog(@"video is have. then delete that");
        if ([fm removeItemAtPath:dstFilePath error:&error]) {
            NSLog(@"delete is ok");
        }else {
            NSLog(@"delete is no error = %@",error.description);
        }
    }
    
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc] init];
    BOOL isSucess = YES;
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:url options:nil];
    
    long long videoValue = videoAsset.duration.value;
    NSInteger videoTimeScale = videoAsset.duration.timescale;
    long long videoTime = videoValue/videoTimeScale;
    if (videoValue%videoTimeScale>0){
        videoTime ++;
    }
    NSNumber *mediaTime = [NSNumber numberWithLongLong:videoTime];
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(360,480);
    //NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(1, 60) actualTime:NULL error:&error];
    
    UIImage *uiImg = [UIImage imageWithCGImage:img];
    NSData *imgData = UIImageJPEGRepresentation(uiImg, 0.5f);
    
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                   preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                    atTime:kCMTimeZero error:nil];
    
    AVAssetTrack *sourceVideo = [[videoAsset tracksWithMediaType:AVMediaTypeVideo]lastObject];
    [compositionVideoTrack setPreferredTransform:sourceVideo.preferredTransform];
        AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:videoAsset
                                                                          presetName:AVAssetExportPresetMediumQuality];
    
    NSURL *exportUrl = [NSURL fileURLWithPath:dstFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:dstFilePath error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    __block NSNumber *fileSize = nil;
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         if (_assetExport.status == AVAssetExportSessionStatusCompleted){
             fileSize = [self getFileSizeWithName:dstFilePath];
         }else{
             CPLogInfo(@"convert mpeg-4  error %@ ||  %@ ||%@ ||%@||%d",
            _assetExport.debugDescription,_assetExport.description,[_assetExport.error localizedDescription],
            [_assetExport.error localizedFailureReason],[_assetExport.error code]);
         }
     }
     ];
    if (error){
        CPLogError(@"convert mpeg-4 error is  %@",[error localizedDescription]);
    }
    
    NSString *thubFilePath = [NSString stringWithFormat:@"%@.jpg",[dstFilePath substringToIndex:[dstFilePath rangeOfString:@"."].location]];
    [imgData writeToFile:thubFilePath atomically:YES];
    [resDic setObject:[NSNumber numberWithBool:isSucess] forKey:convertMpeg4IsSucess];
    if (fileSize){
        [resDic setObject:fileSize forKey:convertMpeg4FileSize];
    }
    [resDic setObject:mediaTime forKey:convertMpeg4MediaTime];
    return resDic;
}

+(NSNumber *)getFileSizeWithName:(NSString *)fileName{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:fileName error:nil];
    NSNumber * fileSizeBit = (NSNumber *)[fileAttributes objectForKey:NSFileSize];
    return [NSNumber numberWithLongLong:[fileSizeBit longLongValue]/1024];
}
@end
