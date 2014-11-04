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

#import "BBStudentModel.h"
#import "CropVideo.h"
#import "CropVideoModel.h"
#import "CoreUtils.h"

@interface BBPostPBXViewController ()
{
    NSArray *selectedStuArray;
    NSArray *selectedRangeArray;
    
    NSString *selectedStuStr;
    NSString *selectedRangeStr;
}
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
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
            NSDictionary *students = (NSDictionary *)[[[dic objectForKey:ASI_REQUEST_DATA] objectForKey:@"list"] objectForKey:[self.currentGroup.groupid stringValue]];
            
            if (students && [students isKindOfClass:[NSDictionary class]]) {
                BBStudentsListViewController *studentListVC = [[BBStudentsListViewController alloc] initWithSelectedStudents:selectedStuArray withStudentModel:students];
                [self.navigationController pushViewController:studentListVC animated:YES];
            }else
            {
                [self showProgressWithText:@"学生列表获取失败" withDelayTime:3];
            }
            
        }
        [self closeProgress];
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
                
                
                [[PalmUIManagement sharedInstance] postPBX:[self.currentGroup.groupid intValue] withTitle:@"拍表现" withContent:[self getThingsText] withAttach:attach withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
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
                [self closeProgress];
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
                [[PalmUIManagement sharedInstance] postPBX:[self.currentGroup.groupid intValue] withTitle:@"拍表现" withContent:[self getThingsText] withAttach:attach withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
            }
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateImageResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"topicResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupStudents" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"videoCompressionState" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"uploadVideoResult" options:0 context:nil];
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateImageResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"topicResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupStudents"];
    [[PalmUIManagement sharedInstance]removeObserver:self forKeyPath:@"videoCompressionState"];
    [[PalmUIManagement sharedInstance]removeObserver:self forKeyPath:@"uploadVideoResult"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedStuArray = [[NSArray alloc] init];
    selectedRangeArray = [[NSArray alloc] init];
    selectedStuStr = @"@点名表扬";

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedStudentList:) name:@"SelectedStudentList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedRangeList:) name:@"SeletedRangeList" object:nil];
}

- (void)receiveSeletedRangeList:(NSNotification *)noti
{
    NSArray *selectedRanges = (NSArray *)[noti object];
    selectedRangeArray = [[NSArray alloc] initWithArray:selectedRanges];
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
    
    selectedStuArray = [[NSArray alloc] initWithArray:selectedStudents];
    
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
        selectedStuStr = @"@点名表扬";
    }else
    {
        selectedStuStr = [selectedStuStr stringByAppendingString:studentListText];
    }
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
    if ([self videoIsExist]) {
        [self sendVideo];
    }else{
        
    }

}
- (void)sendVideo
{
    [self showProgressWithText:@"正在上传"];
    [[PalmUIManagement sharedInstance] updateUserVideoFile:[NSURL fileURLWithPath:[self getTempSaveVideoPath]] withGroupID:[self.currentGroup.groupid intValue]];
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
            image = [self imageWithImage:image];
            NSData *data = UIImageJPEGRepresentation(image, 0.5f);
            [[PalmUIManagement sharedInstance] updateUserImageFile:data withGroupID:[self.currentGroup.groupid intValue]];
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
        
        
        [[PalmUIManagement sharedInstance] postPBX:[self.currentGroup.groupid intValue] withTitle:@"拍表现" withContent:[self getThingsText] withAttach:@"" withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
    }
    
    [self closeThingsText];
    [self showProgressWithText:@"正在发送..."];
}

-(NSString *)getTempSaveVideoPath
{
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)[0];
    NSString *savePath = [documentsDirectory stringByAppendingFormat:@"/%@/temp.MP4",account.loginName];
    return savePath;
}

- (BOOL)videoIsExist
{
    if (self.videoUrl && ![self.videoUrl.absoluteString isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
#pragma mark - Video
- (void)initMoviePlayer
{
    //videoPlayer
    // 显示视频
    NSLog(@"cropSize==%@",[CropVideo getFileSizeWithName:[self getTempSaveVideoPath]]);
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[self getTempSaveVideoPath]]];
    NSLog(@"%@",self.moviePlayer.contentURL);
    self.moviePlayer.view.frame = CGRectMake(0.0f, 0.0f, self.screenWidth, self.screenHeight);
    
    
    self.moviePlayer.useApplicationAudioSession = NO;
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.moviePlayer.shouldAutoplay = NO;
    self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    self.moviePlayer.view.hidden = YES;
    
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer requestThumbnailImagesAtTimes:@[[NSNumber numberWithFloat:0.f]] timeOption:MPMovieTimeOptionExact];
    //[self.moviePlayer setFullscreen:YES animated:NO];
    
}
- (void)convertMp4
{
    [self showProgressWithText:@"正在压缩"];
    [CropVideo convertMpeg4WithUrl:_videoUrl andDstFilePath:[self getTempSaveVideoPath]];
}

- (void)playVideo
{
    if ([[CropVideo getFileSizeWithName:[self getTempSaveVideoPath]] integerValue] > 0) {
        [self.navigationController setNavigationBarHidden:YES];
        self.moviePlayer.view.hidden = NO;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer play];
    }else
    {
        NSLog(@"not ready");
    }
}

#pragma mark - VideoNoti
- (void) playerPlaybackDidFinish:(NSNotification*)notification
{
    [self.navigationController setNavigationBarHidden:NO];
    [self.moviePlayer stop];
    self.moviePlayer.view.hidden = YES;
}


- (void)getThumbnailImage:(NSNotification *)notification
{
    
    UIImage *image = [self.moviePlayer thumbnailImageAtTime:0.f timeOption:MPMovieTimeOptionExact];
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
        CGSize strSize = [selectedStuStr sizeWithFont:[UIFont boldSystemFontOfSize:14.f] constrainedToSize:CGSizeMake(220.f, 800.f)];
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
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:studentIden];
                cell.textLabel.numberOfLines = 100;
                cell.textLabel.backgroundColor = [UIColor blackColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = selectedStuStr;
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
            [self.postTableview deselectRowAtIndexPath:indexPath animated:NO];
            [[PalmUIManagement sharedInstance] getGroupStudents:[self.currentGroup.groupid stringValue]];
        }else
        {
            BBRecommendedRangeViewController *recommendedRangeVC = [[BBRecommendedRangeViewController alloc] initWithRanges:selectedRangeArray];
            [self.navigationController pushViewController:recommendedRangeVC animated:YES];
        }
    }else
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - BBChooseImageDelegate
- (void)shouldAddImage:(NSInteger)imagesCount
{
    if ([self videoIsExist]) {
        [self showProgressWithText:@"只能添加一个视频" withDelayTime:2.f];
    }
}

- (void)imageDidDelete
{
    if ([self videoIsExist]) {
        _videoUrl = nil;
    }
}
@end
