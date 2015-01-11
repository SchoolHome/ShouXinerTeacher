//
//  BBPostPBXViewController.m
//  teacher
//
//  Created by ZhangQing on 14-10-31.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBPostPBXViewController.h"

#import "MediaPlayer/MediaPlayer.h"
#import <AVFoundation/AVFoundation.h>

#import "BBRecommendedRangeViewController.h"
#import "BBStudentsListViewController.h"
#import "BBCameraViewController.h"
#import "BBImagePreviewVIewController.h"
#import "BBRecordViewController.h"

#import "BBStudentModel.h"
#import "CropVideo.h"
#import "CropVideoModel.h"
#import "CoreUtils.h"

#import "CPUIModelManagement.h"

//#import "SDAVAssetExportSession.h"
@interface BBPostPBXViewController ()
{
    NSMutableArray *selectedStuArray;
    NSMutableArray *selectedRangeArray;
    
    NSString *selectedStuStr;
    NSString *selectedRangeStr;
    
    NSArray *tempImages;
}
//@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@end

@implementation BBPostPBXViewController
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /*
     #define ASI_REQUEST_HAS_ERROR @"hasError"
     #define ASI_REQUEST_ERROR_MESSAGE @"errorMessage"
     #define ASI_REQUEST_DATA @"data"
     #define ASI_REQUEST_CONTEXT @"context"
     */
    if ([keyPath isEqualToString:@"groupStudents"]) {
        NSDictionary *dic = [PalmUIManagement sharedInstance].groupStudents;
        if (![dic objectForKey:ASI_REQUEST_HAS_ERROR]) {
            [self showProgressWithText:[dic objectForKey:ASI_REQUEST_ERROR_MESSAGE] withDelayTime:3];
        }else
        {
            [self closeProgress];
            NSDictionary *students = (NSDictionary *)[[[dic objectForKey:ASI_REQUEST_DATA] objectForKey:@"list"] objectForKey:[[self getGroupID] stringValue]];
            
            if (students && [students isKindOfClass:[NSDictionary class]]) {
                BBStudentsListViewController *studentListVC = [[BBStudentsListViewController alloc] initWithSelectedStudents:selectedStuArray withStudentModel:students];
                [self.navigationController pushViewController:studentListVC animated:YES];
            }else
            {
                [self showProgressWithText:@"学生列表获取失败" withDelayTime:2.f];
            }
            
        }
        
    }
    if ([@"updateImageResult" isEqualToString:keyPath])  // 图片上传成功
    {
        NSDictionary *dic = [PalmUIManagement sharedInstance].updateImageResult;
        NSLog(@"dic %@",dic);
        if (![dic[@"hasError"] boolValue]) { // 上传成功
            NSDictionary *data = dic[@"data"];
            if (data) {
                [self.attachList addObject:[data JSONString]];
            }
            
            if ([self.attachList count]==[self getImagesCount]) {  // 所有都上传完毕
                
                
                
                
                NSString *attach = [self.attachList componentsJoinedByString:@"***"];
                BOOL hasHomePage = NO;
                BOOL hasTopGroup = NO;
                for (NSString *tempRange in selectedRangeArray) {
                    if ([tempRange isEqualToString:@"校园圈"]) {
                        hasTopGroup = YES;
                    }else if ([tempRange isEqualToString:@"手心网"])
                    {
                        hasHomePage = YES;
                    }
                }
                
                
                [[PalmUIManagement sharedInstance] postPBX:[[self getGroupID] intValue] withTitle:@"拍表现" withContent:[self getThingsText] withAttach:attach withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
            }
            
        }else{  // 上传失败
            [self.attachList removeAllObjects]; // 只要有一个失败，删除所有返回结果
            [self showProgressWithText:@"亲，网络不给力哦！" withDelayTime:0.5];
        }
    }
    
    if ([@"topicResult" isEqualToString:keyPath])  // 图片上传成功
    {
        NSDictionary *dic = [PalmUIManagement sharedInstance].topicResult;
        NSLog(@"dic %@",dic);
        
        [self.attachList removeAllObjects]; // 清空列表
        
        if ([dic[@"hasError"] boolValue]) {
            [self showProgressWithText:@"亲，网络不给力哦！" withDelayTime:0.5];
        }else{
            
            [self showProgressWithText:@"发送成功" withDelayTime:0.5];
            [self backToBJQRoot];
        }
    }
    
    if ([@"groupListResult" isEqualToString:keyPath]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

    //压缩
     if ([keyPath isEqualToString:@"videoCompressionState"])
    {
        CropVideoModel *model = [PalmUIManagement sharedInstance].videoCompressionState;
        if (model.state == kCropVideoCompleted) {
            [self closeProgress];
            [[NSFileManager defaultManager] removeItemAtURL:self.videoUrl error:nil];
            [self initMoviePlayer];
        }else if (model.state == KCropVideoError){
            [self closeProgress];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"压缩错误" message:[NSString stringWithFormat:@"%@",model.error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            NSLog(@"%@",model.error);
        }else{
            NSLog(@"croping");
        }
    }
    if ([keyPath isEqualToString:@"uploadVideoResult"]){
        NSDictionary *dic = [PalmUIManagement sharedInstance].uploadVideoResult;
        if (![dic objectForKey:ASI_REQUEST_HAS_ERROR]) {
            [self showProgressWithText:[dic objectForKey:ASI_REQUEST_ERROR_MESSAGE] withDelayTime:3];
        }else{
            NSDictionary *resultData = dic[ASI_REQUEST_DATA];
            if ([resultData[@"ret"] isEqualToString:@"OK"])
            {
                //[self closeProgress];
                NSString *attach = [resultData JSONString];//[data JSONString]
                BOOL hasHomePage = NO;
                BOOL hasTopGroup = NO;
                for (NSString *tempRange in selectedRangeArray) {
                    if ([tempRange isEqualToString:@"校园圈"]) {
                        hasTopGroup = YES;
                    }else if ([tempRange isEqualToString:@"手心网"])
                    {
                        hasHomePage = YES;
                    }
                }
                [[PalmUIManagement sharedInstance] postPBX:[[self getGroupID] intValue] withTitle:@"拍表现" withContent:[self getThingsText] withAttach:attach withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
            }
        }
    }
}

- (id) initWithImages:(NSArray *)images
{
    self = [super initWithPostType:POST_TYPE_PBX];
    if (self) {
        tempImages = [NSArray arrayWithArray:images];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateImageResult" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"topicResult" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupStudents" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"videoCompressionState" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"uploadVideoResult" options:0 context:nil];
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
     */
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateImageResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"topicResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupStudents"];
    [[PalmUIManagement sharedInstance]removeObserver:self forKeyPath:@"videoCompressionState"];
    [[PalmUIManagement sharedInstance]removeObserver:self forKeyPath:@"uploadVideoResult"];
    
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
     */
}

- (void)viewDidAppear:(BOOL)animated
{
    
    NSMutableArray *navControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (id controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[BBCameraViewController class]] || [controller isKindOfClass:[BBRecordViewController class]] || [controller isKindOfClass:[BBImagePreviewVIewController  class]]) {
            [navControllers removeObject:controller];
        }
    }
    [self.navigationController setViewControllers:[NSArray arrayWithArray:navControllers] animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedStuArray = [[NSMutableArray alloc] init];
    selectedRangeArray = [[NSMutableArray alloc] initWithCapacity:2];
    selectedStuStr = @"";

    
    // 添加视频播放结束监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getThumbnailImage:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedStudentList:) name:@"SelectedStudentList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedRangeList:) name:@"SeletedRangeList" object:nil];
}

- (void)receiveSeletedRangeList:(NSNotification *)noti
{
    NSArray *selectedRanges = (NSArray *)[noti object];
    selectedRangeArray = [[NSMutableArray alloc] initWithArray:selectedRanges];
    selectedRangeStr = @"";
    
    for (int i =0 ; i< selectedRanges.count ; i++) {
        NSString *tempRangeName = [selectedRanges objectAtIndex:i];
        if (i == 0) selectedRangeStr = [selectedRangeStr stringByAppendingString:tempRangeName];
        else selectedRangeStr = [selectedRangeStr stringByAppendingFormat:@"、%@",tempRangeName];
    }
    
    [self.postTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)receiveSeletedStudentList:(NSNotification *)noti
{
    NSArray *selectedStudents = (NSArray *)[noti object];
    
    selectedStuArray = [[NSMutableArray alloc] initWithArray:selectedStudents];
    selectedStuStr = @"";
    NSMutableString *studentListText = [NSMutableString string];
    for ( int i = 0; i< selectedStudents.count; i++) {
        BBStudentModel *tempModel = [selectedStudents objectAtIndex:i];
        if (i == 0) {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"%@",tempModel.studentName]];
        }else
        {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"、%@",tempModel.studentName]];
        }
    }

    if (selectedStudents.count == 0) {
        selectedStuStr = @"";
    }else
    {
        selectedStuStr = [selectedStuStr stringByAppendingString:studentListText];
    }
    [self.postTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSString *)getAward
{
    
    NSMutableString *studentListText = [NSMutableString string];
    for ( int i = 0; i< selectedStuArray.count; i++) {
        BBStudentModel *tempModel = [selectedStuArray objectAtIndex:i];
        if (i == 0) {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"%d",tempModel.studentID]];
        }else
        {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@",%d",tempModel.studentID]];
        }
        
    }
    return [NSString stringWithFormat:@"%@",studentListText];
}

#pragma mark - Setter & Getter
- (void)setVideoUrl:(NSURL *)videoUrl
{
    if (![videoUrl.absoluteString isEqualToString:@""]) {
        _videoUrl = videoUrl;
        [self convertMp4];
    }
}

#pragma mark - ViewController
- (void)sendButtonTaped
{
    if ([[self getThingsText] length]==0) {  // 没有输入文本
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
        
        return;
    }
    
    if(![[CPUIModelManagement sharedInstance] canConnectToNetwork]){
        [self showProgressWithText:NETWORK_ERROR_TEXT withDelayTime:2.f];
        return;
    }
    
    if ([self videoIsExist]) {
        [self sendVideo];
    }else{
        [self sendImages];
    }

}
- (void)sendVideo
{
    [self closeThingsText];
    [self showProgressWithText:@"正在上传"];
    [[PalmUIManagement sharedInstance] updateUserVideoFile:[NSURL fileURLWithPath:[self getTempSaveVideoPath]] withGroupID:[[self getGroupID] intValue]];
}

- (void)sendImages
{
    
    if ([[self getThingsText] length]==0) {  // 没有输入文本
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
        
        return;
    }
    

    
    
    for (int i = 0; i<self.chooseImageView.images.count; i++) {
        UIImage *image = self.chooseImageView.images[i];
        if (image) {
            //image = [self imageWithImage:image];
            NSData *data = UIImageJPEGRepresentation(image, 0.6f);
            [[PalmUIManagement sharedInstance] updateUserImageFile:data withGroupID:[[self getGroupID] intValue]];
        }
    }
    
    
    if ([self getImagesCount] == 0) {  // 没有图片
        //
        
        BOOL hasHomePage = NO;
        BOOL hasTopGroup = NO;
        for (NSString *tempRange in selectedRangeArray) {
            if ([tempRange isEqualToString:@"校园圈"]) {
                hasTopGroup = YES;
            }else if ([tempRange isEqualToString:@"手心网"])
            {
                hasHomePage = YES;
            }
        }
        
        
        [[PalmUIManagement sharedInstance] postPBX:[self getGroupID].intValue withTitle:@"拍表现" withContent:[self getThingsText] withAttach:@"" withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
    }
    
    [self closeThingsText];
    [self showProgressWithText:@"正在发送..."];
}

-(NSString *)getTempSaveVideoPath
{
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *savePath = [documentsDirectory stringByAppendingFormat:@"/%@/tempVideo.mp4",account.loginName];
    return savePath;
}

- (BOOL)videoIsExist
{
    if (self.videoUrl && ![self.videoUrl.absoluteString isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

- (void)chooseImageViewLoaded
{
    [self.chooseImageView addImages:tempImages];
}

-(void)playVideo
{
    if ([[CropVideo getFileSizeWithName:[self getTempSaveVideoPath]] integerValue] > 0) {
        //self.moviePlayer.moviePlayer.shouldAutoplay = YES;
        //[self.moviePlayer.moviePlayer setContentURL:[NSURL fileURLWithPath:[self getTempSaveVideoPath]]];
        [self.navigationController setNavigationBarHidden:YES];
        //self.moviePlayer.view.hidden = NO;
        [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
        //[self presentViewController:self.moviePlayer animated:YES completion:nil];
        [self.moviePlayer.moviePlayer prepareToPlay];
        [self.moviePlayer.moviePlayer play];
        

    }else
    {
        NSLog(@"not ready");
    }
}

#pragma mark - ChooseClassViewControllerDelegate
- (void)classChoose:(NSInteger)index
{
    
    [selectedStuArray removeAllObjects];
    [selectedRangeArray removeAllObjects];
    selectedStuStr = @"";
    selectedRangeStr = @"";
    
    [super classChoose:index];

}
#pragma mark - Video
- (void)initMoviePlayer
{
    //videoPlayer
    // 显示视频
    NSLog(@"cropSize==%@",[CropVideo getFileSizeWithName:[self getTempSaveVideoPath]]);
    
    //self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[self getTempSaveVideoPath]]];
    self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:[self getTempSaveVideoPath]]];
    self.moviePlayer.moviePlayer.shouldAutoplay = NO;
    NSLog(@"%@",self.moviePlayer.moviePlayer.contentURL);
    
    //self.moviePlayer.view.frame = CGRectMake(0.0f, IOS7?0.f:-20.f, self.screenWidth, IOS7?self.screenHeight:self.screenHeight+20.f);
    
    self.moviePlayer.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.moviePlayer.moviePlayer.useApplicationAudioSession = NO;
    //self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    //self.moviePlayer.view.hidden = YES;
    
    //[self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer.moviePlayer requestThumbnailImagesAtTimes:@[[NSNumber numberWithFloat:1.f]] timeOption:MPMovieTimeOptionExact];
    //[self.moviePlayer setFullscreen:YES animated:NO];
    
}
- (void)convertMp4
{
    [CropVideo convertMpeg4WithUrl:_videoUrl andDstFilePath:[self getTempSaveVideoPath]];
    /*
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:_videoUrl]];
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.outputURL = [NSURL fileURLWithPath:[self getTempSaveVideoPath]];
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey: @360,
    AVVideoHeightKey: @480,
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @600000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^{
        
        if (encoder.status == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"Video export succeeded");
            //[self performSelector:@selector(initMoviePlayer) withObject:nil afterDelay:1.f];
            [self initMoviePlayer];
        }
        else if (encoder.status == AVAssetExportSessionStatusCancelled)
        {
            NSLog(@"Video export cancelled");
        }
        else
        {
            [self closeProgress];
            NSLog(@"Video export failed with error:");
        }
        
    }];

*/
}



#pragma mark - VideoNoti
- (void) playerPlaybackDidFinish:(NSNotification*)notification
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.moviePlayer dismissMoviePlayerViewControllerAnimated];
    [self.moviePlayer.moviePlayer stop];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    //[self.view setFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight)];
    //self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    
    //self.moviePlayer.view.hidden = YES;
}


- (void)getThumbnailImage:(NSNotification *)notification
{
    [self closeProgress];
    UIImage *image = [self.moviePlayer.moviePlayer thumbnailImageAtTime:1.f timeOption:MPMovieTimeOptionExact];
    NSLog(@"getThumbnailImage==%@",image);
    if (!image) {
        [self showProgressWithText:@"获取图片失败,请重试" withDelayTime:2.f];
        //[self setChoosenImages:@[image] andISVideo:YES];
        //[self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [self setChoosenImages:@[image] andISVideo:YES];
}

#pragma mark - UITableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TABLEVIEW_SECTION_COUNT+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        CGSize strSize = [selectedStuStr sizeWithFont:[UIFont boldSystemFontOfSize:14.f] constrainedToSize:CGSizeMake(180.f, 800.f)];
        if (strSize.height < 40) return 40;
        else return strSize.height;
    }else
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2) {
        return 2;
    }else
    {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        static NSString *studentIden = @"CellIdentifierStudent";
        static NSString *recomandedIden = @"CellIdentifierRecomanded";

        
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentIden];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:studentIden];
                cell.detailTextLabel.numberOfLines = 100;
                cell.textLabel.font = [UIFont systemFontOfSize:14.f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
                cell.textLabel.backgroundColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = @"@:发小红花:";
                cell.backgroundColor = [UIColor whiteColor];
                
            }
            cell.detailTextLabel.text = selectedStuStr;
            return cell;
        }else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:recomandedIden];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recomandedIden];
                cell.textLabel.text = @"推荐到...";
                cell.textLabel.backgroundColor = [UIColor blackColor];
                cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font = [UIFont systemFontOfSize:14.f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
                cell.backgroundColor = [UIColor whiteColor];
            }
            cell.detailTextLabel.text = selectedRangeStr;
            return cell;
        }
    }else
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [[PalmUIManagement sharedInstance] getGroupStudents:[[self getGroupID] stringValue]];
        }else
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            BBRecommendedRangeViewController *recommendedRangeVC = [[BBRecommendedRangeViewController alloc] initWithRanges:selectedRangeArray];
            [self.navigationController pushViewController:recommendedRangeVC animated:YES];
        }
    }else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [super scrollViewWillBeginDragging:scrollView];
}
#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:0] isEqualToString:@"拍摄"] && buttonIndex == 0) {
        //进自定义拍照界面
//        if (self.moviePlayer) {
//            self.moviePlayer = nil;
//        }
        
        BBCameraViewController *camera = [[BBCameraViewController alloc] init];
        camera.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:camera animated:YES];
        NSLog(@"%@",self.navigationController.viewControllers);
        }else
    {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}
#pragma mark - BBChooseImageDelegate
- (void)shouldAddImage:(NSInteger)imagesCount
{
    if ([self videoIsExist]) {
        [self showProgressWithText:@"只能添加一个视频" withDelayTime:2.f];
    }else if (imagesCount > 0)
    {
        [super shouldAddImage:imagesCount];
    }else
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:@"拍摄",@"相册", nil];
        [sheet showInView:self.view];
    }
}

- (void)imageDidTapped:(NSArray *)images andIndex:(NSInteger)index
{
    
    if ([self videoIsExist]) {
        [self playVideo];
        [self closeThingsText];
    }else [super imageDidTapped:images andIndex:index];
}

- (void)imageDidDelete
{
    if ([self videoIsExist]) {
        _videoUrl = nil;
    }
}
@end
