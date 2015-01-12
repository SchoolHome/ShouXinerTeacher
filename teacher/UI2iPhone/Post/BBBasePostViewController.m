//
//  BBBasePostViewController.m
//  teacher
//
//  Created by ZhangQing on 14-10-30.
//  Copyright (c) 2014年 ws. All rights reserved.
//
#define ThingsTextViewHeight 60.f
#define ThingsTextViewSpaceing 5.f

#import "BBBasePostViewController.h"
#import "ZYQAssetPickerController.h"
#import "ViewImageViewController.h"

#import "CPUIModelManagement.h"
#import "AppDelegate.h"
@interface BBBasePostViewController()<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
BBBasePostTableviewTouchDelegate,
ZYQAssetPickerControllerDelegate,
viewImageDeletedDelegate>
{
    NSUInteger selectedImagesCount;
    CGFloat chooseImageViewHeight;
    
    UIPlaceHolderTextView *thingsTextView;
    
}
@property (nonatomic, readwrite) BBBasePostTableview *postTableview;
@property (nonatomic, readwrite) BBGroupModel *currentGroup;
@property (nonatomic, strong) NSArray *classModels;

@property int topicType;
@property (nonatomic)POST_TYPE postType;
@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, readwrite) BBChooseImgViewInPostPage *chooseImageView;

@end

@implementation BBBasePostViewController
-(NSMutableArray *)attachList
{
    if (!_attachList) _attachList = [[NSMutableArray alloc] initWithCapacity:9];
    return _attachList;
}
- (NSArray *)classModels
{
    if (!_classModels) _classModels = [[NSArray alloc] init];
    return _classModels;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
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
                
                NSString *title = nil;
                switch (_postType) {
                    case POST_TYPE_FZY:
                        //
                        title = @"最新作业";
                        break;
                    case POST_TYPE_FTZ:
                        //
                        title = @"最新通知";
                        break;
                    case POST_TYPE_PBX:
                        //
                        title = @"拍表现";
                        
                        break;
                    case POST_TYPE_SBS:
                        //
                        title = @"随便说";
                        break;
                    default:
                        title = @"随便说";
                        break;
                }
                
                NSString *attach = [self.attachList componentsJoinedByString:@"***"];
                [[PalmUIManagement sharedInstance] postTopic:[[self getGroupID] intValue]
                                               withTopicType:_topicType
                                                 withSubject:_selectedIndex
                                                   withTitle:title
                                                 withContent:thingsTextView.text
                                                  withAttach:attach
                                                  activityid:self.activeID];
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
            if (_postType == POST_TYPE_HDFX) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WebDetailNeedCallBack" object:dic[@"data"][@"topicid"]];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self backToBJQRoot];
            }
        }
    }
    
    if ([@"groupListResult" isEqualToString:keyPath])  // 班级列表
    {
        NSDictionary *result = [PalmUIManagement sharedInstance].groupListResult;
        
        if (![result[@"hasError"] boolValue]) { // 没错
            self.classModels = [NSArray arrayWithArray:result[@"data"]];
            /*
            if (self.classModels.count > 0) {
                self.currentGroup = self.classModels[0];
            }
            [self.postTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
             */
        }else{
            //[self showProgressWithText:@"班级列表加载失败" withDelayTime:2.f];
        }
    }

    
}


- (id)initWithPostType:(POST_TYPE)postPageType
{
    self = [super init];
    if (self) {
        _postType = postPageType;
        
        chooseImageViewHeight = IMAGE_HEIGHT+IMAGE_INTERVAL*2;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_postType != POST_TYPE_PBX) {
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateImageResult" options:0 context:NULL];
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"topicResult" options:0 context:NULL];
    }
    
        [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupListResult" options:0 context:NULL];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (_postType != POST_TYPE_PBX) {
        [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateImageResult"];
        [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"topicResult"];
    }
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupListResult"];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0.f, 7.f, 60.f, 30.f)];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    //sendButton.backgroundColor = [UIColor blackColor];
    [sendButton setTitleColor:[UIColor colorWithRed:251/255.f green:76/255.f blue:7/255.f alpha:1.f] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    self.postTableview = [[BBBasePostTableview alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight-44.f) style:UITableViewStyleGrouped];
    self.postTableview.dataSource = self;
    self.postTableview.delegate = self;
    self.postTableview.touchDelegate = self;
    self.postTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.postTableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, 1.f)];
    self.postTableview.backgroundColor = [UIColor clearColor];
    if (!IOS7) {
        UIView *tableviewBGView = [[UIView alloc] initWithFrame:self.postTableview.frame];
        tableviewBGView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        self.postTableview.backgroundView = tableviewBGView;
    }
    [self.view addSubview:self.postTableview];
    
    [self setStyle];
    
    [[PalmUIManagement sharedInstance] getGroupList];
}

- (NSString *)getThingsText
{
    return thingsTextView.text;
}
- (NSInteger)getImagesCount
{
    return self.chooseImageView.images.count;
}

- (void) backToBJQRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([appDelegate.window.rootViewController isKindOfClass:[BBUITabBarController class]]) {
        BBUITabBarController *tabbar = (BBUITabBarController *)appDelegate.window.rootViewController;
        [tabbar performSelector:@selector(selectedItem:) withObject:0 afterDelay:0.5];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BJQNeedRefresh" object:nil];
    }
}
#pragma mark - UITableview

- (void)tableviewTouched
{
    [thingsTextView resignFirstResponder];
    [self.chooseImageView closeImageBtn];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ?
    chooseImageViewHeight+ThingsTextViewHeight+2*ThingsTextViewSpaceing+10.f : 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        case 1:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TABLEVIEW_SECTION_COUNT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *titleCellIden = @"CellIdentifierTitle";
    static NSString *imageCellIden = @"CellIdentifierImage";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indexPath.section == 1 ? imageCellIden : titleCellIden];
    if (!cell) {

        switch (indexPath.section) {
            case 0:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:titleCellIden];
                cell.textLabel.text = @"当前班级";
                cell.textLabel.font = [UIFont systemFontOfSize:14.f];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14.f];
                cell.textLabel.backgroundColor = [UIColor blackColor];
                cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
                break;
            case 1:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellIden];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                thingsTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(ThingsTextViewSpaceing, ThingsTextViewSpaceing,CGRectGetWidth(cell.contentView.frame)-2*ThingsTextViewSpaceing-20, ThingsTextViewHeight)];
                thingsTextView.placeholder = _placeholder;
                thingsTextView.font = [UIFont systemFontOfSize:14.f];
                thingsTextView.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:thingsTextView];
                
                _chooseImageView = [[BBChooseImgViewInPostPage alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(thingsTextView.frame)+ThingsTextViewSpaceing,CGRectGetWidth(cell.contentView.frame)-20.f,chooseImageViewHeight)];
                _chooseImageView.delegate = self;
                
                if (_postType == POST_TYPE_FZY) {
                    _chooseImageView.maxImages = 9;
                }else
                {
                    _chooseImageView.maxImages = 9;
                }
                [cell.contentView addSubview:_chooseImageView];
                
                if (_postType == POST_TYPE_PBX) {
                    [self chooseImageViewLoaded];
                }
            }
                break;
            default:
                
                break;
        }
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (indexPath.section == 0) {
        NSLog(@"%@",[PalmUIManagement sharedInstance].currentGroupInfo.alias);
        cell.detailTextLabel.text = self.currentGroup ? self.currentGroup.alias : [PalmUIManagement sharedInstance].currentGroupInfo.alias;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self closeThingsText];
    
    if (indexPath.section == 1) {
        return;
    }else
    {
        if (self.classModels.count > 0) {
            ChooseClassViewController *chooseClass = [[ChooseClassViewController alloc] initWithClasses:self.classModels];
            chooseClass.delegate = self;
            [self.navigationController pushViewController:chooseClass animated:YES];
        }else
        {
            [self showProgressWithText:@"没有可选择的班级" withDelayTime:2.f];
        }

    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self closeThingsText];
}
#pragma mark - ViewControllerMethod
- (void)closeThingsText
{
    if ([thingsTextView isFirstResponder]) {
        [thingsTextView resignFirstResponder];
    }
    
}

- (void)backButtonTaped:(id)sender{
    if (_postType == POST_TYPE_HDFX) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)sendButtonTaped
{
    if ([thingsTextView.text length]==0) {  // 没有输入文本
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
        
        return;
    }
    
    if(![[CPUIModelManagement sharedInstance] canConnectToNetwork]){
        [self showProgressWithText:NETWORK_ERROR_TEXT withDelayTime:2.f];
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

    
    if (self.chooseImageView.images.count == 0) {  // 没有图片
        //
        
        NSString *title = nil;
        switch (_postType) {
            case POST_TYPE_FZY:
                //
                title = @"最新作业";
                break;
            case POST_TYPE_FTZ:
                //
                title = @"最新通知";
                break;
            case POST_TYPE_PBX:
                //
                title = @"拍表现";
                
                break;
            case POST_TYPE_SBS:
                //
                title = @"随便说";
                break;
            default:
                title = @"随便说";
                break;
        }
        
        [[PalmUIManagement sharedInstance] postTopic:[[self getGroupID] intValue]
                                       withTopicType:_topicType
                                         withSubject:_selectedIndex
                                           withTitle:title
                                         withContent:thingsTextView.text
                                          withAttach:@""
                                          activityid:self.activeID];
    }
    
    [thingsTextView resignFirstResponder];
    [self showProgressWithText:@"正在发送..."];

}

- (void)setChoosenImages:(NSArray *)images andISVideo:(BOOL)isVideo;
{
    if (images.count == 0) return;
    else
        isVideo ? [self.chooseImageView addVideoImage:images[0]] : [self.chooseImageView addImages:images];
}

- (void)setStyle{
    
    switch (_postType) {
        case POST_TYPE_FZY:
            _placeholder = @"作业内容...";
            self.title = @"发作业";
            
            _topicType = 2;
            break;
        case POST_TYPE_FTZ:
            //
            _placeholder = @"通知内容...";
            self.title = @"发通知";
            
            _topicType = 1;
            
            break;
        case POST_TYPE_PBX:
            //
            _placeholder = @"说点赞美话...";
            self.title = @"拍表现";
            
            _topicType = 4;
            break;
        case POST_TYPE_SBS:
            //
            _placeholder = @"分享新鲜事...";
            self.title = @"随便说";
            
            _topicType = 4;
            
            break;
        default:
            _placeholder = self.activeContent;
            self.title = self.activeTitle;
            _topicType = 4;
            break;
    }
}

- (NSNumber *)getGroupID
{
    return self.currentGroup ? self.currentGroup.groupid:
    [PalmUIManagement sharedInstance].currentGroupInfo.groupid;
}
#pragma mark - ChooseClassViewControllerDelegate
- (void)classChoose:(NSInteger)index
{
    self.currentGroup = self.classModels[index];
    //[self.postTableview reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.postTableview reloadData];
}
#pragma mark - ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    switch (buttonIndex) {
        case 0:
            //
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }else{
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            [self presentViewController:imagePicker animated: YES completion:^{
                //
            }];
        }
            break;
        case 1:
            //
            
        {
            if (_postType == POST_TYPE_FZY) {
                if (selectedImagesCount >= _chooseImageView.maxImages) {
                    return;
                }
            }else{
                if (selectedImagesCount >= _chooseImageView.maxImages) {
                    return;
                }
            }

            
            
            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
            if (_postType == POST_TYPE_FZY){
                picker.maximumNumberOfSelection = _chooseImageView.maxImages - selectedImagesCount;
            }else{
                picker.maximumNumberOfSelection = _chooseImageView.maxImages - selectedImagesCount;
            }
            picker.assetsFilter = [ALAssetsFilter allPhotos];
            picker.showEmptyGroups=NO;
            picker.delegate=self;
            picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                    NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                    return duration >= 5;
                } else {
                    return YES;
                }
            }];
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
            
            break;
        case 2:
            //
            
            break;
        default:
            break;
    }
}



#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    for (int i = 0; i<[assets count]; i++) {
        ALAsset *asset = [assets objectAtIndex:i];
        [_chooseImageView addImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
        selectedImagesCount++;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    [_chooseImageView addImage:image];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissModalViewControllerAnimated:YES];
    
}

-(UIImage*)imageWithImage:(UIImage*)image
{
    CGSize newSize = CGSizeMake(image.size.width*0.3, image.size.height*0.3);
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - BBChooseImageDelegate
- (void)shouldAddImage:(NSInteger)imagesCount
{
    selectedImagesCount = imagesCount;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:imagesCount>0?@"再拍一张":@"拍照",@"相册", nil];
    [sheet showInView:self.view];
}
- (void)viewBoundsChanged:(CGRect)viewframe
{
    chooseImageViewHeight = viewframe.size.height;
    [self.postTableview reloadData];
}
- (void)cannotAddImage
{
    [self showProgressWithText:@"已达到最大图片" withDelayTime:2.f];
    
}

- (void)imageDidTapped:(NSArray *)images andIndex:(NSInteger)index
{
    [self closeThingsText];
    ViewImageViewController *imagesVC = [[ViewImageViewController alloc] initViewImageVC:images withSelectedIndex:index];
    imagesVC.delegate = self;
    [self.navigationController pushViewController:imagesVC animated:YES];
}

- (void) delectedIndex:(NSInteger)index
{
    [_chooseImageView removeImage:index];
}
@end

@implementation BBBasePostTableview
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableview:)];
        tapGes.delegate = self;
        [self addGestureRecognizer:tapGes];
    }
    return self;
}



- (void)tapTableview:(UITapGestureRecognizer *)ges
{
    if ([self.touchDelegate respondsToSelector:@selector(tableviewTouched)]) {
        [self.touchDelegate tableviewTouched];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            return NO;
        }
    }
    return YES;
}

@end