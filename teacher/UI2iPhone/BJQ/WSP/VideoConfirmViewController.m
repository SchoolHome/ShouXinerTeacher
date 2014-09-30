//
//  VideoConfirmViewController.m
//  teacher
//
//  Created by ZhangQing on 14-9-27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "VideoConfirmViewController.h"
#import "MediaPlayer/MediaPlayer.h"

@interface VideoConfirmViewController ()
{
    NSURL *_videoURL;
    BBGroupModel *model;
    VIDEO_CHOOSEN_TYPE chooseType;
}
@property (nonatomic, strong)UILabel *videoTime;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
//@property (nonatomic, strong)NSDictionary *videoInfo;
@end

@implementation VideoConfirmViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithVideoUrl:(NSURL *)url andType:(VIDEO_CHOOSEN_TYPE)type andGroupModel:(BBGroupModel *)groupModel;
{
    self = [super init];
    if (self) {
        _videoURL = url;
        model = groupModel;
        chooseType = type;
        //self.videoInfo = [[NSDictionary alloc] initWithDictionary:info];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    NSLog(@"width==%f,height==%f",self.screenWidth,self.screenHeight);

    
//    _videoTime = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 20.f)];
//    _videoTime.font = [UIFont systemFontOfSize:16.f];
//    _videoTime.textAlignment = NSTextAlignmentCenter;
//    _videoTime.text = @"00:00";
//    [self.navigationItem setTitleView:_videoTime];
    
    
    // 显示视频
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_videoURL];
    //    self.moviePlayer.view.frame = self.videoRect;
    self.moviePlayer.view.frame = CGRectMake(0.0f, 0.0f, self.screenWidth, self.screenHeight-140.f);

    
    self.moviePlayer.useApplicationAudioSession = NO;
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.initialPlaybackTime = 0.01f;
    self.moviePlayer.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer play];
//    // 添加视频播放结束监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//    // 添加视频加载完成的监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateChanged:)
//                                                 name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    UIButton *reChoose = [UIButton buttonWithType:UIButtonTypeCustom];
    [reChoose setFrame:CGRectMake(30.f, self.screenHeight-120.f,60.f, 30.f)];
    [reChoose setTitle:chooseType== VIDEO_TYPE_PHOTO?@"重选":@"重录" forState:UIControlStateNormal];
    [reChoose addTarget:self action:@selector(rechoose) forControlEvents:UIControlEventTouchUpInside];
    [reChoose setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:reChoose];
    
    UIButton *useVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    [useVideo setFrame:CGRectMake(self.screenWidth-90.f, self.screenHeight-120.f,60.f , 30.f)];
    [useVideo setTitle:@"使用" forState:UIControlStateNormal];
    [useVideo addTarget:self action:@selector(useVideo) forControlEvents:UIControlEventTouchUpInside];
    [useVideo setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:useVideo];
    
    NSLog(@"%@",self.view.subviews);
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - ViewControllerMethod
-(void)rechoose
{
    [self.moviePlayer stop];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setMediaTypes:@[(NSString *)kUTTypeMovie]];
    
    imagePicker.delegate = self;
    switch (chooseType) {
        case VIDEO_TYPE_CARMER:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                //拍摄视频
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.videoMaximumDuration = 30.f;
            }
        }
            break;
        case VIDEO_TYPE_PHOTO:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
                //选取视频
                imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
            break;
        default:
            break;
    }
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        //        NSLog(@"found a video");
        //        NSData *videoData = nil;
        //        videoData = [NSData dataWithContentsOfURL:videoURL];
        //        NSMutableData *webData = [[NSMutableData alloc] init];
        //        [webData appendData:videoData];
        //        if (webData != nil) {
        //            NSLog(@"SUCCESS!");
        //        }
        _videoURL = videoURL;
        [self.moviePlayer setContentURL:videoURL];
        [self.moviePlayer play];
    }
    
    
}
-(void)useVideo
{
    [self.moviePlayer stop];


    BBWSPViewController *wsp = [[BBWSPViewController alloc] initWithVideoUrl:_videoURL andType:chooseType andGroupModel:model];
    [self.navigationController pushViewController:wsp animated:YES];
}
@end
