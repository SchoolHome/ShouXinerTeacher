//
//  BBMeProfileController.m
//  teacher
//
//  Created by mac on 14-3-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeProfileController.h"
#import "BBMeProfileTableViewCell.h"
#import "BBPhoneModifyViewController.h"
#import "BBSignModifyViewController.h"
#import "CPUIModelManagement.h"
#import "CoreUtils.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"
#import "CPLGModelAccount.h"

#define ActionSheetSex 100
#define ActionSheetPhoto 101

@interface BBMeProfileController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIButton *headerImgBtn;
    UIImage *pickImage;
    NSData *imageData;
    NSInteger sexTag;
    BBProfileModel *userProfile;
}
@end

@implementation BBMeProfileController
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"个人信息";
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setFrame:CGRectMake(0.f, 7.f, 22.f, 22.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    userProfile = [BBProfileModel shareProfileModel];
    
    listData = [[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@"名字", @"地区", nil],
                [NSArray arrayWithObjects:@"性别", @"手机号", nil], [NSArray arrayWithObjects:@"个性签名", nil], nil];
    
    profileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)
                                                    style:UITableViewStyleGrouped];
    [profileTableView setDataSource:(id<UITableViewDataSource>)self];
    [profileTableView setDelegate:(id<UITableViewDelegate>)self];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, profileTableView.frame.size.width, profileTableView.frame.size.height)];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:242.f/255.f green:242.f/255.f blue:242.f/255.f alpha:1.0f]];
    [profileTableView setBackgroundView:backgroundView];
    backgroundView = nil;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 170)];
    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:headerView.bounds];
    [bgImage setImage:[UIImage imageNamed:@"BBTopBGNew.png"]];
    [headerView addSubview:bgImage];
    bgImage = nil;
    headerImgBtn = [[UIButton alloc] initWithFrame:CGRectMake((headerView.frame.size.width-80)/2, (headerView.frame.size.height-80)/2, 80, 80)];
    [headerImgBtn setContentMode:UIViewContentModeScaleAspectFit];
    [headerImgBtn addTarget:self action:@selector(clickHeaderImg:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerImgBtn];
    [profileTableView setTableHeaderView:headerView];
    
    NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
    if (path) {
        [headerImgBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    }else{
        [headerImgBtn setImage:[UIImage imageNamed:@"girl.png"]forState:UIControlStateNormal];
    }
    [headerImgBtn.layer setCornerRadius:40];
    [headerImgBtn.layer setBorderWidth:2];
    [headerImgBtn.layer setMasksToBounds:YES];
    [headerImgBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.view addSubview:profileTableView];
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateUserHeader" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateUserHeaderResult" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"postUserInfoResult" options:0 context:nil];
    if (profileTableView) {
        [profileTableView reloadData];
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateUserHeader"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateUserHeaderResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"postUserInfoResult"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqual:@"updateUserHeader"]) {
        if ([[[PalmUIManagement sharedInstance].updateUserHeader objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
            [self showProgressWithText:@"头像上传失败" withDelayTime:1.0f];
            return;
        }
        NSDictionary *data = [[PalmUIManagement sharedInstance].updateUserHeader objectForKey:ASI_REQUEST_DATA];
        if ([data[@"ret"] isEqual:@"OK"]) {
            NSArray *array = (NSArray *)data[@"data"];
            array = (NSArray *)array[0];
            NSString *fileName = array[4];
            [[PalmUIManagement sharedInstance] updateuserHeaderResult:fileName];
        }else{
            [self showProgressWithText:@"头像上传失败" withDelayTime:1.0f];
        }
    }else if([keyPath isEqual:@"updateUserHeaderResult"]){
        if ([[[PalmUIManagement sharedInstance].updateUserHeaderResult objectForKey:ASI_REQUEST_HAS_ERROR] boolValue]) {
            [self showProgressWithText:@"头像上传失败" withDelayTime:1.0f];
            return;
        }
        NSDictionary *data = [[PalmUIManagement sharedInstance].updateUserHeaderResult objectForKey:ASI_REQUEST_DATA];
        if ([[data objectForKey:@"errno"] integerValue] == 0) {
            
            CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
            NSString *filePath = [NSString stringWithFormat:@"/%@/",account.loginName];
            [CoreUtils createPath:filePath];
            NSString *path = [[CPUIModelManagement sharedInstance].uiPersonalInfo selfHeaderImgPath];
            NSRange range = [path rangeOfString:[NSString stringWithFormat:@"/%@/", account.loginName]];
            NSString *writeFileName = [path substringFromIndex:range.location + range.length];
            if ([CoreUtils writeToFileWithData:imageData file_name:writeFileName andPath:filePath]) {
                dispatch_block_t updateTagBlock = ^{
                    [[CPUIModelManagement sharedInstance] setUiPersonalInfoTag:0];
                };
                dispatch_async(dispatch_get_main_queue(), updateTagBlock);
            }
            [headerImgBtn setImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            [self showProgressWithText:@"头像上传成功" withDelayTime:1.0f];
        }else{
            [self showProgressWithText:@"头像上传失败" withDelayTime:1.0f];
        }
    }else if([@"postUserInfoResult" isEqualToString:keyPath]){
        NSDictionary *resultDic = [[PalmUIManagement sharedInstance] postUserInfoResult];
        NSDictionary *errDic = resultDic[@"data"];
        if ([errDic[@"errno"] integerValue] == 0) {
            userProfile.sex = sexTag;
            [self showProgressWithText:@"更新成功" withDelayTime:2];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showProgressWithText:resultDic[@"errorMessage"] withDelayTime:2];
        }
    }/*else if([@"userProfile" isEqualToString:keyPath]){
        self.userProfile = [[PalmUIManagement sharedInstance].userProfile objectForKey:ASI_REQUEST_DATA];
        if (profileTableView) {
            [profileTableView reloadData];
        }
    }*/
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[listData objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (BBMeProfileTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProfileCell = @"profileCell";
    BBMeProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfileCell];
    if (cell == nil) {
        cell = [[BBMeProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ProfileCell];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    }
    switch (indexPath.section) {
        case 0:
        {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            switch (indexPath.row) {
                case 0:
                    [cell.detailTextLabel setText:userProfile.username];
                    break;
                default:
                    [cell.detailTextLabel setText:userProfile.cityname];
                    break;
            }
        }
            break;
        case 1:
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            switch (indexPath.row) {
                case 0:
                    if(userProfile.sex == 1){
                        [cell.detailTextLabel setText:@"男"];
                    }
                    else{
                        [cell.detailTextLabel setText:@"女"];
                    }
                    break;
                default:
                {
                    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
                    [cell.detailTextLabel setText:account.loginName];
                }
                    break;
            }
        }
            break;
        default:
        {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            if (userProfile.sign.length > 0) {
                
                [cell.detailTextLabel setText:userProfile.sign];
            }else{
                [cell.detailTextLabel setText:@"说点什么吧。"];
            }
        }
            break;
    }
    [cell.textLabel setText:[[listData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                             delegate:(id<UIActionSheetDelegate>)self
                                                                    cancelButtonTitle:@"取消"
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:@"女", @"男", nil];
                    [actionSheet setTag:ActionSheetSex];
                    [actionSheet showInView:self.view];
                }
                    break;
                default:
                {
                    //更新电话
                    BBPhoneModifyViewController *viewController = [[BBPhoneModifyViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                    break;
            }
        }
            break;
        case 2:
        {
            BBSignModifyViewController *viewController = [[BBSignModifyViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)clickHeaderImg:(UIButton *)btn
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:(id<UIActionSheetDelegate>)self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"拍摄照片"
                                                    otherButtonTitles:@"选择照片", nil];
    [actionSheet setTag:ActionSheetPhoto];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (ActionSheetPhoto == actionSheet.tag) {
        if (buttonIndex == 0) {//拍照
            [self takePhotoFromCamera];
        }else if(buttonIndex == 1){//选照片
            [self takePhotoFromAssets];
        }
    }
    if (ActionSheetSex == actionSheet.tag) {
        if(buttonIndex == 0){
            NSLog(@"女");
            sexTag = 0;
        }else if(buttonIndex == 1){
            NSLog(@"男");
            sexTag = 1;
        }else{
            return;
        }
        [[PalmUIManagement sharedInstance] postUserInfo:nil withMobile:nil withVerifyCode:nil withPasswordOld:nil withPasswordNew:nil withSex:sexTag withSign:nil];
    }
}

//从相机中取图片
-(void)takePhotoFromCamera
{
    //资源类型为照相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        //资源类型为照相机
        picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
    }else {
        // NSLog(@"该设备无摄像头");
    }
}

//从图片库中取图片
-(void)takePhotoFromAssets
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    if (image != nil) {
        if (pickImage) {
            pickImage = nil;
        }
        
        imageData = UIImageJPEGRepresentation(image, 0.5f);
        pickImage = [[UIImage alloc] initWithData:imageData];
        //这里要处理image上传
        [self showProgressWithText:@"正在上传头像"];
        [[PalmUIManagement sharedInstance] updateUserHeader:imageData];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
//    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateUserHeader"];
//    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateUserHeaderResult"];
}

@end
