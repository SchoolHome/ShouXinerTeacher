

#import "BBPBXViewController.h"
#import "CTAssetsPickerController.h"
#import "ViewImageViewController.h"
#import "BBStudentsListViewController.h"
#import "BBRecommendedRangeViewController.h"

#import "UIPlaceHolderTextView.h"

#import "BBStudentModel.h"

@interface BBPBXViewController ()<CTAssetsPickerControllerDelegate,viewImageDeletedDelegate>
{
    UIPlaceHolderTextView *thingsTextView;
    UIButton *imageButton[8];
    UILabel *studentList;
    UILabel *reCommendedList;
    UILabel *studentListTitle;
    
    int selectCount;
    int imageCount;
    
    NSArray *selectedStuArray;
    NSArray *selectedRangeArray;
}
@property (nonatomic, strong)NSMutableArray *attachList;
@property (nonatomic, strong)ReachTouchScrollview *contentScrollview;
@end

@implementation BBPBXViewController
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
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
            //-(void) showProgressWithText : (NSString *) context withDelayTime : (NSUInteger) sec;
            [self showProgressWithText:[dic objectForKey:ASI_REQUEST_ERROR_MESSAGE] withDelayTime:3];
        }else
        {
            NSDictionary *students = [[[dic objectForKey:ASI_REQUEST_DATA] objectForKey:@"list"] objectForKey:[self.currentGroup.groupid stringValue]];
            BBStudentsListViewController *studentListVC = [[BBStudentsListViewController alloc] initWithSelectedStudents:selectedStuArray withStudentModel:students];
            [self.navigationController pushViewController:studentListVC animated:YES];
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
                
                if ([self.attachList count]==imageCount) {  // 所有都上传完毕
                    
                    
                    
                    
                    NSString *attach = [self.attachList componentsJoinedByString:@"***"];
                    BOOL hasHomePage = NO;
                    BOOL hasTopGroup = NO;
                    for (NSString *tempRange in selectedRangeArray) {
                        if ([tempRange isEqualToString:@"班级圈"]) {
                            hasTopGroup = YES;
                        }else if ([tempRange isEqualToString:@"手心网"])
                        {
                            hasTopGroup = YES;
                        }
                    }
                    
                    
                    [[PalmUIManagement sharedInstance] postPBX:[self.currentGroup.groupid intValue] withTitle:@"拍表现" withContent:thingsTextView.text withAttach:attach withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
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
                [self.navigationController popViewControllerAnimated:YES];
            }
        }


        [self closeProgress];
    
}
-(NSMutableArray *)attachList
{
    if (!_attachList) {
        _attachList = [[NSMutableArray alloc] init];
    }
    return _attachList;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"拍表现";
    
    selectedStuArray = [[NSArray alloc] init];
    selectedRangeArray = [[NSArray alloc] init];
    
    
    
    //取消发送按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    
    _contentScrollview = [[ReachTouchScrollview alloc] initWithFrame:CGRectMake(0.f, 0.f, 320.f, self.view.bounds.size.height-40.f)];
    _contentScrollview.touchDelegate = self;
    _contentScrollview.delegate = self;
    _contentScrollview.showsVerticalScrollIndicator = NO;
    _contentScrollview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentScrollview];
    
    //学生列表
    UIView *listBack = [[UIView alloc] initWithFrame:CGRectMake(15.f, 15.f, 320-30.f, 40.f)];
    listBack.tag = 1001;
    [_contentScrollview addSubview:listBack];
    
    CALayer *roundedLayerList = [listBack layer];
    [roundedLayerList setMasksToBounds:YES];
    roundedLayerList.cornerRadius = 8.0;
    roundedLayerList.borderWidth = 1;
    roundedLayerList.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UIButton *turnStudentList = [UIButton buttonWithType:UIButtonTypeCustom];
    [turnStudentList setFrame:CGRectMake(5, 5, 320-40, 30)];
    [turnStudentList addTarget:self action:@selector(turnStudentList) forControlEvents:UIControlEventTouchUpInside];
    turnStudentList.titleLabel.textAlignment = NSTextAlignmentLeft;
    [listBack addSubview:turnStudentList];
    
    studentList = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, 190, 20.f)];
    studentList.backgroundColor = [UIColor clearColor];
    studentList.text = @"@:点名表扬,可不选...";
    studentList.numberOfLines = 50;
    studentList.font = [UIFont boldSystemFontOfSize:14.f];
    studentList.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [turnStudentList addSubview:studentList];
    
    studentListTitle = [[UILabel alloc] initWithFrame:CGRectMake(195.f, 5.f, 70, 20.f)];
    studentListTitle.backgroundColor = [UIColor clearColor];
    studentListTitle.text = @"学生列表 >";
    studentListTitle.textAlignment = NSTextAlignmentRight;
    studentListTitle.font = [UIFont boldSystemFontOfSize:14.f];
    studentListTitle.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [turnStudentList addSubview:studentListTitle];
    
    //说赞美的话
    UIView *textBack = [[UIView alloc] initWithFrame:CGRectMake(15, listBack.frame.origin.y+listBack.frame.size.height+10, 320-30, 70)];
    textBack.tag = 1002;
    [_contentScrollview addSubview:textBack];
    
    CALayer *roundedLayer0 = [textBack layer];
    [roundedLayer0 setMasksToBounds:YES];
    roundedLayer0.cornerRadius = 8.0;
    roundedLayer0.borderWidth = 1;
    roundedLayer0.borderColor = [[UIColor lightGrayColor] CGColor];
    
    thingsTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(5, 5, 320-40, 60)];
    [textBack addSubview:thingsTextView];
    thingsTextView.font = [UIFont boldSystemFontOfSize:14.f];
    thingsTextView.delegate = self;
    thingsTextView.placeholder = @"说点赞美话...";
    thingsTextView.backgroundColor = [UIColor clearColor];
    


    //选择图片
    UIView *imageBack = [[UIView alloc] initWithFrame:CGRectMake(15,textBack.frame.origin.y+textBack.frame.size.height+10, 320-30, 140)];
    [_contentScrollview addSubview:imageBack];
    CALayer *roundedLayer2 = [imageBack layer];
    [roundedLayer2 setMasksToBounds:YES];
    roundedLayer2.cornerRadius = 8.0;
    roundedLayer2.borderWidth = 1;
    roundedLayer2.borderColor = [[UIColor lightGrayColor] CGColor];
    
    

        
        for (int i = 0; i<8; i++) {
            imageButton[i] = [UIButton buttonWithType:UIButtonTypeCustom];
            imageButton[i].frame = CGRectMake(20+i*65, 10, 55, 55);
            
            if (i>3) {
                imageButton[i].frame = CGRectMake(20+(i-4)*65, 10+65, 55, 55);
            }
            
            imageButton[i].backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
            [imageBack addSubview:imageButton[i]];
            
            if (i<7) {
                [imageButton[i] addTarget:self action:@selector(imageButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
                imageButton[i].tag = i;
            }else{
                
                [imageButton[i] setBackgroundImage:[UIImage imageNamed:@"BBSendAddImage"] forState:UIControlStateNormal];
                [imageButton[i] addTarget:self action:@selector(imagePickerButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    
    //推荐到
    UIView *reCommendedBack = [[UIView alloc] initWithFrame:CGRectMake(15,imageBack.frame.origin.y+imageBack.frame.size.height+10, 320-30, 40)];
    reCommendedBack.tag = 1003;
    [_contentScrollview addSubview:reCommendedBack];
    CALayer *roundedLayer3 = [reCommendedBack layer];
    [roundedLayer3 setMasksToBounds:YES];
    roundedLayer3.cornerRadius = 8.0;
    roundedLayer3.borderWidth = 1;
    roundedLayer3.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UIButton *turnReCommendedList = [UIButton buttonWithType:UIButtonTypeCustom];
    [turnReCommendedList setFrame:CGRectMake(5, 5, 320-40, 30)];
    [turnReCommendedList addTarget:self action:@selector(turnReCommendedList) forControlEvents:UIControlEventTouchUpInside];
    [reCommendedBack addSubview:turnReCommendedList];
    
    
    reCommendedList = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 5.f, 200, 20.f)];
    reCommendedList.backgroundColor = [UIColor clearColor];
    reCommendedList.text = @"推荐到:可不选...";
    reCommendedList.font = [UIFont boldSystemFontOfSize:14.f];
    reCommendedList.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    
    [turnReCommendedList addSubview:reCommendedList];
    
    UILabel *reCommendedListTitle = [[UILabel alloc] initWithFrame:CGRectMake(205.f, 5.f, 60, 20.f)];
    reCommendedListTitle.backgroundColor = [UIColor clearColor];
    reCommendedListTitle.text = @"范围 >";
    reCommendedListTitle.textAlignment = NSTextAlignmentRight;
    reCommendedListTitle.font = [UIFont boldSystemFontOfSize:14.f];
    reCommendedListTitle.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
    [turnReCommendedList addSubview:reCommendedListTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedStudentList:) name:@"SelectedStudentList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSeletedRangeList:) name:@"SeletedRangeList" object:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear:animated];
    
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"updateImageResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"topicResult" options:0 context:NULL];
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"groupStudents" options:0 context:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    //[super viewWillDisappear:animated];
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"updateImageResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"topicResult"];
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"groupStudents"];
}


#pragma mark NavAction
-(void)cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)send
{
    /*
     -(void) postPBX : (int) groupid withTitle : (NSString *) title withContent : (NSString *) content withAttach : (NSString *) attach
     withAward : (NSString *) students withToHomePage : (BOOL) hasHomePage withToUpGroup : (BOOL) hasTopGroup;
     */
    
    if ([thingsTextView.text length]==0) {  // 没有输入文本
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
        
        return;
    }
    
    imageCount = 0;
    

        for (int i = 0; i<7; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                image = [self imageWithImage:image];
                NSData *data = UIImageJPEGRepresentation(image, 0.5f);
                [[PalmUIManagement sharedInstance] updateUserImageFile:data withGroupID:[_currentGroup.groupid intValue]];
                imageCount++;
            }
        }
    
    
    if (imageCount == 0) {  // 没有图片
        //
    
        BOOL hasHomePage = NO;
        BOOL hasTopGroup = NO;
        for (NSString *tempRange in selectedRangeArray) {
            if ([tempRange isEqualToString:@"班级圈"]) {
                hasTopGroup = YES;
            }else if ([tempRange isEqualToString:@"手心网"])
            {
                hasTopGroup = YES;
            }
        }
        

        [[PalmUIManagement sharedInstance] postPBX:[self.currentGroup.groupid intValue] withTitle:@"拍表现" withContent:thingsTextView.text withAttach:@"" withAward:[self getAward] withToHomePage:hasHomePage withToUpGroup:hasTopGroup];
    }
    
    [thingsTextView resignFirstResponder];
    [self showProgressWithText:@"正在发送..."];
    

    


    
   //
}

-(NSString *)getAward
{
    NSString *award;
    for (int i= 0; i <selectedStuArray.count ;i++ ) {
        BBStudentModel *model = [selectedStuArray objectAtIndex:i];
        if (i == 0) award = [NSString stringWithFormat:@"%d",model.studentID];
        else [award stringByAppendingFormat:@",%d",model.studentID];
    }
    return award;
}
#pragma mark ViewControllerMethod
-(void)receiveSeletedRangeList:(NSNotification *)noti
{
    NSArray *selectedRanges = (NSArray *)[noti object];
    selectedRangeArray = [[NSArray alloc] initWithArray:selectedRanges];
    
    if (selectedRanges.count == 0) {
        reCommendedList.text = @"推荐到:可不选...";
        return;
    }
    
    NSString *rangeNames = @"推荐到：";
    for (int i =0 ; i< selectedRanges.count ; i++) {
        NSString *tempRangeName = [selectedRanges objectAtIndex:i];
        if (i == 0) rangeNames = [rangeNames stringByAppendingString:tempRangeName];
        else rangeNames = [rangeNames stringByAppendingFormat:@"、%@",tempRangeName];
        
    }
    
    if (IOS6) {
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:rangeNames];

        [attributedStr addAttribute:NSForegroundColorAttributeName
                              value:[UIColor colorWithRed:59/255.f green:107/255.f blue:139/255.f alpha:1.f] range:NSMakeRange(4, attributedStr.length-4)];
        reCommendedList.attributedText = attributedStr;
    }else
    {
        reCommendedList.text = rangeNames;
    }
}
-(void)receiveSeletedStudentList:(NSNotification *)noti
{
    NSArray *selectedStudents = (NSArray *)[noti object];
    
    selectedStuArray = [[NSArray alloc] initWithArray:selectedStudents];
    
    NSMutableString *studentListText = [NSMutableString string];
    for ( int i = 0; i< selectedStudents.count; i++) {
        BBStudentModel *tempModel = [selectedStudents objectAtIndex:i];
        if (i == 0) {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"@:%@",tempModel.studentName]];
        }else
        {
            studentListText = [NSMutableString stringWithString:[studentListText stringByAppendingFormat:@"、%@",tempModel.studentName]];
        }

    }
    NSLog(@"%d",studentListText.length);
//    for (int i = 18; i<studentListText.length; i++) {
//        if (i % 20 == 0) {
//            [studentListText insertString:@"\n" atIndex:i];
//        }
//        
//    }
    
    //CGSize strSize = [studentListText sizeWithFont:[UIFont boldSystemFontOfSize:14.f] forWidth:190.f lineBreakMode:UILineBreakModeWordWrap];
    CGSize strSize = [studentListText sizeWithFont:[UIFont boldSystemFontOfSize:14.f] constrainedToSize:CGSizeMake(220.f, 800.f)];
    if (strSize.height < 20) strSize.height = 20;
        
    
    CGRect tempStudentListFrame = studentList.frame;
    tempStudentListFrame.size.height = strSize.height;

    
    
    if (selectedStudents.count == 0) {
        studentListTitle.text = @"学生列表 >";
        studentList.text = @"@:点名表扬,可不选...";
        studentList.textColor = [UIColor colorWithRed:131/255.f green:131/255.f blue:131/255.f alpha:1.f];
        tempStudentListFrame.size.width = 190.f;
    }else
    {
        studentListTitle.text = @" >";
        if (IOS6) {
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:studentListText];
            [attributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 2)];
            [attributedStr addAttribute:NSForegroundColorAttributeName
                                  value:[UIColor colorWithRed:59/255.f green:107/255.f blue:139/255.f alpha:1.f] range:NSMakeRange(2, attributedStr.length-2)];
            studentList.attributedText = attributedStr;
        }else
        {
            studentList.text = studentListText;
        }

        
        tempStudentListFrame.size.width = 240.f;
    }
    
    studentList.frame = tempStudentListFrame;
    
    
    
    NSInteger offsetY ;
    for (UIView *tempView in self.contentScrollview.subviews) {
        if (tempView.tag == 1001) {
            NSInteger tempViewHeight = tempView.frame.size.height;
            CGRect tempViewFrame = tempView.frame;
            tempViewFrame.size.height = strSize.height + 20;
            tempView.frame = tempViewFrame;
            offsetY = tempView.frame.size.height - tempViewHeight;
        }else
        {
            
            tempView.center = CGPointMake(tempView.center.x, tempView.center.y+offsetY);
            if (tempView.tag == 1003) {
                self.contentScrollview.contentSize = CGSizeMake(320.f, tempView.frame.origin.y+tempView.frame.size.height + 40);
            }
        }
    }
    
    
}
-(void)turnStudentList
{
    [[PalmUIManagement sharedInstance] getGroupStudents:[self.currentGroup.groupid stringValue]];
    [self showProgressWithText:@"正在获取..."];
    
//    BBStudentsListViewController *studentListVC = [[BBStudentsListViewController alloc] initWithSelectedStudents:selectedStuArray];
//    //[studentList setStudentList:nil];
//    [self.navigationController pushViewController:studentListVC animated:YES];
}
-(void)turnReCommendedList
{
    BBRecommendedRangeViewController *recommendedRangeVC = [[BBRecommendedRangeViewController alloc] initWithRanges:selectedRangeArray];
    [self.navigationController pushViewController:recommendedRangeVC animated:YES];
}
-(void)imageButtonTaped:(id)sender{
    [thingsTextView resignFirstResponder];
    
    int tag = ((UIButton*)sender).tag;
    UIImage *temp = [imageButton[tag] backgroundImageForState:UIControlStateNormal];
    if (!temp) {
        return;
    }
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    

        for (int i = 0; i<7; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                [images addObject:image];
            }
        }
    
    ViewImageViewController *imagesVC = [[ViewImageViewController alloc] initViewImageVC:images withSelectedIndex:tag];
    imagesVC.delegate = self;
    [self.navigationController pushViewController:imagesVC animated:YES];
}

-(void)imagePickerButtonTaped:(id)sender{
    if (selectCount<7) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [sheet showInView:self.view];
    }

}


#pragma mark - ReachTouchScrolviewDelegate
-(void)scrollviewTouched
{
    if ([thingsTextView isFirstResponder]) {
        [thingsTextView resignFirstResponder];
    }
    
}
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if ([thingsTextView isFirstResponder]) {
//        [thingsTextView resignFirstResponder];
//    }
//}
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

            if (selectCount >= 7) {
                return;
            }

            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.assetsFilter = [ALAssetsFilter allPhotos];

            picker.maximumNumberOfSelection = 7 - selectCount;

            picker.delegate = self;
            
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


#pragma mark - ViewImageVC Delegate
-(void) delectedIndex:(int)index{
    [imageButton[index] setBackgroundImage:nil forState:UIControlStateNormal];
}
-(void) reloadView{
    NSMutableArray *images = [[NSMutableArray alloc] init];

        for (int i = 0; i<7; i++) {
            UIImage *image = [imageButton[i] backgroundImageForState:UIControlStateNormal];
            if (image) {
                [images addObject:image];
                [imageButton[i] setBackgroundImage:nil forState:UIControlStateNormal];
            }
        }
    
    for (int i = 0; i<[images count]; i++) {
        [imageButton[i] setBackgroundImage:[images objectAtIndex:i] forState:UIControlStateNormal];
    }
    selectCount = [images count];
}

#pragma mark TextViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    CGRect rect = [textView convertRect:textView.frame toView:self.contentScrollview];
    if (rect.origin.y > self.view.bounds.size.height - 240) {
        NSLog(@"%@",textView.superview);
        [self.contentScrollview setContentOffset:CGPointMake(0.f, rect.origin.y-50.f) animated:YES];
    }

    //[self.contentScrollview scrollRectToVisible:textView.superview.frame animated:YES];
    return YES;
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{

    
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

        if (selectCount<7) {
            [imageButton[selectCount] setBackgroundImage:image forState:UIControlStateNormal];
            selectCount++;
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




@implementation ReachTouchScrollview

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if ([self.touchDelegate respondsToSelector:@selector(scrollviewTouched)]) {
        [self.touchDelegate scrollviewTouched];
    }
}

@end