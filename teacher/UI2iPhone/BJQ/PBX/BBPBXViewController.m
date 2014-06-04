

#import "BBPBXViewController.h"
#import "CTAssetsPickerController.h"
#import "ViewImageViewController.h"
#import "UIPlaceHolderTextView.h"
@interface BBPBXViewController ()<CTAssetsPickerControllerDelegate,viewImageDeletedDelegate>
{
    UIPlaceHolderTextView *thingsTextView;
    UIButton *imageButton[8];
    
    int selectCount;
    int imageCount;
    
}
@property (nonatomic, strong)NSMutableArray *attachList;
@end

@implementation BBPBXViewController
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
    
    //取消发送按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    //学生列表
    //说赞美的话
    UIView *textBack = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 320-30, 70)];
    [self.view addSubview:textBack];
    CALayer *roundedLayer0 = [textBack layer];
    [roundedLayer0 setMasksToBounds:YES];
    roundedLayer0.cornerRadius = 8.0;
    roundedLayer0.borderWidth = 1;
    roundedLayer0.borderColor = [[UIColor lightGrayColor] CGColor];
    
    thingsTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, 20, 320-40, 60)];
    [self.view addSubview:thingsTextView];
    thingsTextView.placeholder = @"说点赞美话...";
    thingsTextView.backgroundColor = [UIColor clearColor];
    


    //选择图片
    UIView *imageBack = [[UIView alloc] initWithFrame:CGRectMake(15, 95, 320-30, 140)];
    [self.view addSubview:imageBack];
    CALayer *roundedLayer2 = [imageBack layer];
    [roundedLayer2 setMasksToBounds:YES];
    roundedLayer2.cornerRadius = 8.0;
    roundedLayer2.borderWidth = 1;
    roundedLayer2.borderColor = [[UIColor lightGrayColor] CGColor];
    
    

        
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
    
    //推荐到
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{

}
-(void)viewDidDisappear:(BOOL)animated
{
    
}
#pragma mark NavAction
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)send
{
    
}
#pragma mark ViewControllerMethod
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
