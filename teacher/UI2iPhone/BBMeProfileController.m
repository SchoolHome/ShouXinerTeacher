//
//  BBMeProfileController.m
//  teacher
//
//  Created by mac on 14-3-14.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMeProfileController.h"
#import "BBMeProfileTableViewCell.h"
#import "CPUIModelManagement.h"
#import "CoreUtils.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPersonalInfo.h"

@interface BBMeProfileController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImage *pickImage;
    NSData *imageData;
}
@end

@implementation BBMeProfileController
@synthesize userProfile;
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
    [back setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [back setBackgroundImage:[UIImage imageNamed:@"ZJZBack"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
    
    listData = [[NSArray alloc] initWithObjects:[NSArray arrayWithObjects:@"头像", @"名字", nil],
                [NSArray arrayWithObjects:@"性别", @"地区", @"个性签名", nil], nil];
    
    profileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)
                                                    style:UITableViewStyleGrouped];
    [profileTableView setDataSource:(id<UITableViewDataSource>)self];
    [profileTableView setDelegate:(id<UITableViewDelegate>)self];
    
    UIView *tableBackView = [[UIView alloc] initWithFrame:profileTableView.bounds];
    [tableBackView setBackgroundColor:[UIColor colorWithRed:0.961f green:0.941f blue:0.921f alpha:1.0f]];
    [profileTableView setBackgroundView:tableBackView];
    
    [self.view addSubview:profileTableView];
    if (!self.userProfile) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"userProfile" options:0 context:nil];
        [[PalmUIManagement sharedInstance] getUserProfile];
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateUserHeader" options:0 context:nil];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateUserHeaderResult" options:0 context:nil];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateUserHeader"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateUserHeaderResult"];
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
            BBMeProfileTableViewCell *cell = (BBMeProfileTableViewCell *)[profileTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [cell.headerImageView setImage:pickImage];
            
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
            [self showProgressWithText:@"头像上传成功" withDelayTime:1.0f];
        }else{
            [self showProgressWithText:@"头像上传失败" withDelayTime:1.0f];
        }
    }else if([@"userProfile" isEqualToString:keyPath]){
        self.userProfile = [[PalmUIManagement sharedInstance].userProfile objectForKey:ASI_REQUEST_DATA];
        if (profileTableView) {
            [profileTableView reloadData];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else{
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 44;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cellHeight = 90;
    }
    return cellHeight;
}

- (BBMeProfileTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ProfileCell = @"profileCell";
    BBMeProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfileCell];
    if (cell == nil) {
        cell = [[BBMeProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ProfileCell];
        if ([self currentVersion] == kIOS7) {
#ifdef __IPHONE_7_0
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
#endif
        }
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.headerImageView.layer setCornerRadius:35];
            [cell.headerImageView.layer setMasksToBounds:YES];
            [cell.detailTextLabel setText:nil];
            if (userProfile) {
                if (![userProfile[@"avatar"] isKindOfClass:[NSNull class]]) {
                    NSMutableString *userAvatar = [[NSMutableString alloc] initWithString:[userProfile objectForKey:@"avatar"]];
#ifdef TEST
                    NSRange range = [userAvatar rangeOfString:@"att0.shouxiner.com"];
                    if (range.length>0) {
                        [userAvatar replaceCharactersInRange:range withString:@"115.29.224.151"];
                    }
#endif
                    [cell.headerImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", userAvatar]]];
                }
            }else{
                [cell.headerImageView setImage:[UIImage imageNamed:@"girl.png"]];
            }
        }else{
            [cell.detailTextLabel setText:[self.userProfile objectForKey:@"username"]];
        }
    }else{
        if (indexPath.row == 0) {
            if ([[self.userProfile objectForKey:@"sex"] integerValue]) {
                [cell.detailTextLabel setText:@"男"];
            }else{
                [cell.detailTextLabel setText:@"女"];
            }
            
        }else if(indexPath.row == 1){
            
        }else{
            
        }
    }
    [cell.textLabel setText:[[listData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.userProfile) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:(id<UIActionSheetDelegate>)self
                                                            cancelButtonTitle:@"取消"
                                                       destructiveButtonTitle:@"拍摄照片"
                                                            otherButtonTitles:@"选择照片", nil];
            [actionSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex == 0) {//拍照
        [self takePhotoFromCamera];
    }else if(buttonIndex == 1){//选照片
        [self takePhotoFromAssets];
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
