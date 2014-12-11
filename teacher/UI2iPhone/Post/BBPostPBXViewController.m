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

#import "BBStudentModel.h"
#import "CropVideo.h"
#import "CropVideoModel.h"
#import "CoreUtils.h"



@interface BBPostPBXViewController ()
{
    NSMutableArray *selectedStuArray;
    NSMutableArray *selectedRangeArray;
    
    NSString *selectedStuStr;
    NSString *selectedRangeStr;
    
    NSArray *tempImages;
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
            [self closeProgress];
            NSDictionary *students = (NSDictionary *)[[[dic objectForKey:ASI_REQUEST_DATA] objectForKey:@"list"] objectForKey:[self.currentGroup.groupid stringValue]];
            
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
    //selectedStuStr = @"";
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
        [self.navigationController setNavigationBarHidden:YES];
        self.moviePlayer.view.hidden = NO;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer play];
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
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[self getTempSaveVideoPath]]];
    NSLog(@"%@",self.moviePlayer.contentURL);
    self.moviePlayer.view.frame = CGRectMake(0.0f, 0.0f, self.screenWidth, self.screenHeight);
    
    
    self.moviePlayer.useApplicationAudioSession = NO;
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    self.moviePlayer.shouldAutoplay = NO;
    self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    self.moviePlayer.view.hidden = YES;
    
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer requestThumbnailImagesAtTimes:@[[NSNumber numberWithFloat:1.f]] timeOption:MPMovieTimeOptionExact];
    //[self.moviePlayer setFullscreen:YES animated:NO];
    
}
- (void)convertMp4
{
    [CropVideo convertMpeg4WithUrl:_videoUrl andDstFilePath:[self getTempSaveVideoPath]];
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
    [self closeProgress];
    UIImage *image = [self.moviePlayer thumbnailImageAtTime:1.f timeOption:MPMovieTimeOptionExact];
    NSLog(@"getThumbnailImage==%@",image);
    if (!image) {
        [self showProgressWithText:@"获取图片失败,请重试" withDelayTime:2.f];
        [self.navigationController popToRootViewControllerAnimated:YES];
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
                cell.textLabel.text = @"@点名表扬:";
                
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
            [[PalmUIManagement sharedInstance] getGroupStudents:[self.currentGroup.groupid stringValue]];
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
#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:0] isEqualToString:@"拍摄"] && buttonIndex == 0) {
        //进自定义拍照界面
        /*
        for (id viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[BBCameraViewController class]]) {
                [self.navigationController popToViewController:(BBCameraViewController *)viewController animated:YES];
                return;
            }
        }
        */
        BBCameraViewController *camera = [[BBCameraViewController alloc] init];
        [self.navigationController pushViewController:camera animated:YES];
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
    }else [super imageDidTapped:images andIndex:index];
}

- (void)imageDidDelete
{
    if ([self videoIsExist]) {
        _videoUrl = nil;
    }
}
@end
