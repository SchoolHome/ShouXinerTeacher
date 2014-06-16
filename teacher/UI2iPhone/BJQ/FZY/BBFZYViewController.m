
#import "BBFZYViewController.h"
#import "CTAssetsPickerController.h"
#import "ViewImageViewController.h"
#import "ZYQAssetPickerController.h"

@interface BBFZYViewController ()<ZYQAssetPickerControllerDelegate,viewImageDeletedDelegate>

@property (nonatomic,strong) NSString *placeholder;

@property BOOL hasClazz;

@end

@implementation BBFZYViewController

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([@"updateImageResult" isEqualToString:keyPath])  // 图片上传成功
    {
        NSDictionary *dic = [PalmUIManagement sharedInstance].updateImageResult;
        NSLog(@"dic %@",dic);
        if (![dic[@"hasError"] boolValue]) { // 上传成功
            NSDictionary *data = dic[@"data"];
            if (data) {
                [attachList addObject:[data JSONString]];
            }
            
            if ([attachList count]==imageCount) {  // 所有都上传完毕
                
                NSString *title = nil;
                switch (_style) {
                    case 0:
                        //
                        title = @"最新作业";
                        break;
                    case 1:
                        //
                        title = @"最新通知";
                        break;
                    case 2:
                        //
                        title = @"拍表现";

                        break;
                    case 3:
                        //
                        title = @"随便说";
                        break;
                    default:
                        break;
                }
                
                NSString *attach = [attachList componentsJoinedByString:@"***"];
                [[PalmUIManagement sharedInstance] postTopic:[_currentGroup.groupid intValue]
                                               withTopicType:_topicType
                                                 withSubject:_selectedIndex
                                                   withTitle:title
                                                 withContent:thingsTextView.text
                                                  withAttach:attach];
            }
            
        }else{  // 上传失败
            [attachList removeAllObjects]; // 只要有一个失败，删除所有返回结果
            [self showProgressWithText:@"亲，网络不给力哦！" withDelayTime:0.5];
        }
    }
    
    if ([@"topicResult" isEqualToString:keyPath])  // 图片上传成功
    {
        NSDictionary *dic = [PalmUIManagement sharedInstance].topicResult;
        NSLog(@"dic %@",dic);
        
        [attachList removeAllObjects]; // 清空列表
        
        if ([dic[@"hasError"] boolValue]) {
            [self showProgressWithText:@"亲，网络不给力哦！" withDelayTime:0.5];
        }else{
        
            [self showProgressWithText:@"发送成功" withDelayTime:0.5];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)setStyle:(int)style{

    _style = style;
    
    switch (_style) {
        case 0:
            //
            _hasClazz = YES;
            _placeholder = @"作业内容...";
            self.title = @"发作业";
            
            _topicType = 2;
            break;
        case 1:
            //
            _placeholder = @"通知内容...";
            self.title = @"发通知";
            
            _topicType = 1;
            
            break;
        case 2:
            //
            _placeholder = @"说点赞美话...";
            self.title = @"拍表现";
            
            _topicType = 4;
            break;
        case 3:
            //
            _placeholder = @"分享新鲜事...";
            self.title = @"随便说";
            
            _topicType = 4;
            
            break;
        default:
            break;
    }
}

-(void)kemuButtonTaped:(id)sender{

    BBXKMViewController *xkm = [[BBXKMViewController alloc] init];
    xkm.selectedIndex = _selectedIndex;
    xkm.xkmDelegate = self;
    [self.navigationController pushViewController:xkm animated:YES];
}

-(void)kejianButtonTaped:(id)sender{

}

-(void)imageButtonTaped:(id)sender{
    [thingsTextView resignFirstResponder];
    
    int tag = ((UIButton*)sender).tag;
    UIImage *temp = [imageButton[tag] backgroundImageForState:UIControlStateNormal];
    if (!temp) {
        return;
    }
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    if (_style==1) {
        for (int i = 0; i<3; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                [images addObject:image];
            }
        }
    }else{
        for (int i = 0; i<7; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                [images addObject:image];
            }
        }
    }
    ViewImageViewController *imagesVC = [[ViewImageViewController alloc] initViewImageVC:images withSelectedIndex:tag];
    imagesVC.delegate = self;
    [self.navigationController pushViewController:imagesVC animated:YES];
}

-(void) delectedIndex:(int)index{
    [imageButton[index] setBackgroundImage:nil forState:UIControlStateNormal];
}

-(void) reloadView{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    if (_style==1) {
        for (int i = 0; i<3; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                [images addObject:image];
                [imageButton[i] setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }
    }else{
        for (int i = 0; i<7; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                [images addObject:image];
                [imageButton[i] setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }
    }
    
    for (int i = 0; i<[images count]; i++) {
        [imageButton[i] setBackgroundImage:[images objectAtIndex:i] forState:UIControlStateNormal];
    }
    selectCount = [images count];
}

-(void)imagePickerButtonTaped:(id)sender{

    if (_style == 1) { // 发通知只有3张图
        if (selectCount<3) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
            [sheet showInView:self.view];
        }
    }else{
        if (selectCount<7) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
            [sheet showInView:self.view];
        }
    }
}

-(id)init{

    self = [super init];
    if (self) {
        _hasClazz = NO;
    }
    return self;
}

-(void)backButtonTaped:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendButtonTaped:(id)sender{
    
    if ([thingsTextView.text length]==0) {  // 没有输入文本
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
        
        return;
    }
    
    imageCount = 0;
    
    if (_style==1) {
        for (int i = 0; i<3; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                image = [self imageWithImage:image];
                NSData *data = UIImageJPEGRepresentation(image, 0.5f);
                [[PalmUIManagement sharedInstance] updateUserImageFile:data withGroupID:[_currentGroup.groupid intValue]];
                imageCount++;
            }
        }
    }else{
        for (int i = 0; i<7; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                image = [self imageWithImage:image];
                NSData *data = UIImageJPEGRepresentation(image, 0.5f);
                [[PalmUIManagement sharedInstance] updateUserImageFile:data withGroupID:[_currentGroup.groupid intValue]];
                imageCount++;
            }
        }
    }
    
    if (imageCount == 0) {  // 没有图片
        //
        
        NSString *title = nil;
        switch (_style) {
            case 0:
                //
                title = @"最新作业";
                break;
            case 1:
                //
                title = @"最新通知";
                break;
            case 2:
                //
                title = @"拍表现";
                
                break;
            case 3:
                //
                title = @"随便说";
                break;
            default:
                break;
        }
        
        [[PalmUIManagement sharedInstance] postTopic:[_currentGroup.groupid intValue]
                                       withTopicType:_topicType
                                         withSubject:_selectedIndex
                                           withTitle:title
                                         withContent:thingsTextView.text
                                          withAttach:@""];
    }
    
    [thingsTextView resignFirstResponder];
    [self showProgressWithText:@"正在发送..."];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateImageResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"topicResult" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateImageResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"topicResult"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    attachList = [[NSMutableArray alloc] init];
    
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"BBCancelSendButton"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"BBSendButton"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    
    kmList = @[@"不指定科目",@"数学",@"语文",@"英语",@"体育",@"自然科学",@"其它"];
    
    UIView *textBack = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 320-30, 70)];
    [self.view addSubview:textBack];
    CALayer *roundedLayer0 = [textBack layer];
    [roundedLayer0 setMasksToBounds:YES];
    roundedLayer0.cornerRadius = 8.0;
    roundedLayer0.borderWidth = 1;
    roundedLayer0.borderColor = [[UIColor lightGrayColor] CGColor];
    
    thingsTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, 20, 320-40, 60)];
    [self.view addSubview:thingsTextView];
    thingsTextView.placeholder = _placeholder;
    thingsTextView.backgroundColor = [UIColor clearColor];
    
    UIView *imageBack = [[UIView alloc] initWithFrame:CGRectMake(15, 95, 320-30, 140)];
    [self.view addSubview:imageBack];
    CALayer *roundedLayer2 = [imageBack layer];
    [roundedLayer2 setMasksToBounds:YES];
    roundedLayer2.cornerRadius = 8.0;
    roundedLayer2.borderWidth = 1;
    roundedLayer2.borderColor = [[UIColor lightGrayColor] CGColor];
    
    
    if (_style == 1) { // 发通知只有3张图
        
        for (int i = 0; i<4; i++) {
            imageButton[i] = [UIButton buttonWithType:UIButtonTypeCustom];
            imageButton[i].frame = CGRectMake(35+i*65, 105, 55, 55);

            imageButton[i].backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            [self.view addSubview:imageButton[i]];
            
            if (i<3) {
                [imageButton[i] addTarget:self action:@selector(imageButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
                imageButton[i].tag = i;
            }else{
                [imageButton[i] setBackgroundImage:[UIImage imageNamed:@"BBSendAddImage"] forState:UIControlStateNormal];
                [imageButton[i] addTarget:self action:@selector(imagePickerButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        imageBack.frame = CGRectMake(15, 95, 320-30, 75);
        
    }else{
    
        for (int i = 0; i<8; i++) {
            imageButton[i] = [UIButton buttonWithType:UIButtonTypeCustom];
            imageButton[i].frame = CGRectMake(35+i*65, 105, 55, 55);
            
            if (i>3) {
                imageButton[i].frame = CGRectMake(35+(i-4)*65, 105+65, 55, 55);
            }
            
            imageButton[i].backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            [self.view addSubview:imageButton[i]];
            
            if (i<7) {
                [imageButton[i] addTarget:self action:@selector(imageButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
                imageButton[i].tag = i;
            }else{
                
                [imageButton[i] setBackgroundImage:[UIImage imageNamed:@"BBSendAddImage"] forState:UIControlStateNormal];
                [imageButton[i] addTarget:self action:@selector(imagePickerButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    kemuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //kemuButton.backgroundColor = [UIColor brownColor];
    kemuButton.frame = CGRectMake(15, 245, 320-30, 50);
    [kemuButton addTarget:self action:@selector(kemuButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:kemuButton];
    
    CALayer *roundedLayer = [kemuButton layer];
    [roundedLayer setMasksToBounds:YES];
    roundedLayer.cornerRadius = 8.0;
    roundedLayer.borderWidth = 1;
    roundedLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 50)];
    [kemuButton addSubview:label1];
    label1.text = @"科目";
    label1.font = [UIFont boldSystemFontOfSize:18];
    label1.backgroundColor = [UIColor clearColor];
    
    kemuLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-30-100-30, 0, 100, 50)];
    kemuLabel.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
    kemuLabel.textAlignment = NSTextAlignmentRight;
    [kemuButton addSubview:kemuLabel];
    kemuLabel.text = kmList[0];
    kemuLabel.backgroundColor = [UIColor clearColor];
    
//    kejianButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    //kemuButton.backgroundColor = [UIColor brownColor];
//    kejianButton.frame = CGRectMake(15, 245+60, 320-30, 50);
//    [kejianButton addTarget:self action:@selector(kejianButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:kejianButton];
//    
//    CALayer *roundedLayer1 = [kejianButton layer];
//    [roundedLayer1 setMasksToBounds:YES];
//    roundedLayer1.cornerRadius = 8.0;
//    roundedLayer1.borderWidth = 1;
//    roundedLayer1.borderColor = [[UIColor lightGrayColor] CGColor];
//    
//    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 50)];
//    [kejianButton addSubview:label2];
//    label2.text = @"可见范围";
//    label2.font = [UIFont boldSystemFontOfSize:18];
//    
//    kejianLabel = [[UILabel alloc] initWithFrame:CGRectMake(320-30-100-30, 0, 100, 50)];
//    kejianLabel.textColor = [UIColor blueColor];
//    kejianLabel.textAlignment = NSTextAlignmentRight;
//    [kejianButton addSubview:kejianLabel];
//    kejianLabel.text = @"公开";
    
    if (!_hasClazz) {
        kejianButton.frame = kemuButton.frame;
        [kemuButton removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)bbXKMViewController:(BBXKMViewController *)controller didSelectedIndex:(int)index{

    NSLog(@"");
    
    _selectedIndex = index;
    
    kemuLabel.text = kmList[_selectedIndex];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [thingsTextView resignFirstResponder];
}

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
            if (_style == 1) {
                if (selectCount >= 3) {
                    return;
                }
            }else{
                if (selectCount >= 7) {
                    return;
                }
            }
//            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
//            picker.assetsFilter = [ALAssetsFilter allPhotos];
//            if (_style == 1){
//                picker.maximumNumberOfSelection = 3 - selectCount;
//            }else{
//                picker.maximumNumberOfSelection = 7 - selectCount;
//            }
//            picker.delegate = self;
//            
//            [self presentViewController:picker animated:YES completion:NULL];
            
            
            ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
            if (_style == 1){
                picker.maximumNumberOfSelection = 3 - selectCount;
            }else{
                picker.maximumNumberOfSelection = 7 - selectCount;
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
            
//            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
//                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//            }
//            [self presentViewController:imagePicker animated: YES completion:^{
//                //
//            }];
        }
            
            break;
        case 2:
            //
            
            break;
        default:
            break;
    }
}

//#pragma mark - Assets Picker Delegate
//
//- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
//    int count = 0;
//    if (_style == 1) { // 发通知只有3张图
//        count = 3;
//        if (selectCount<4) {
//            [imageButton[selectCount] setBackgroundImage:image forState:UIControlStateNormal];
//            selectCount++;
//        }
//    }else{
//        count = 7;
//        if (selectCount<7) {
//            [imageButton[selectCount] setBackgroundImage:image forState:UIControlStateNormal];
//            selectCount++;
//        }
//    }
    
//    for (int i = 0; i<[assets count]; i++) {
//        ALAsset *asset = [assets objectAtIndex:i];
//        [imageButton[selectCount] setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
//        selectCount++;
//    }
//}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    for (int i = 0; i<[assets count]; i++) {
        ALAsset *asset = [assets objectAtIndex:i];
        [imageButton[selectCount] setBackgroundImage:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forState:UIControlStateNormal];
        selectCount++;
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *image = nil;
    if ([mediaType isEqualToString:@"public.image"]){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    NSData *data = UIImageJPEGRepresentation(image, 0.6f);
    image = [[UIImage alloc] initWithData:data];
    
    if (_style == 1) { // 发通知只有3张图
        
        if (selectCount<4) {
            [imageButton[selectCount] setBackgroundImage:image forState:UIControlStateNormal];
            selectCount++;
        }
    }else{
    
        if (selectCount<7) {
            [imageButton[selectCount] setBackgroundImage:image forState:UIControlStateNormal];
            selectCount++;
        }
    }
    
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

@end
