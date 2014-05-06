//
//  RegistFirstViewController.m
//  iCouple
//


//  Created by 振杰 李 on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RegistFirstViewController.h"
#import "RegistViewController.h"
#define LEFT_X 4.0/2
#define LEFT_Y 6.0/2
#define LEFT_WIDTH 72.0/2
#define LEFT_HIGH 72.0/2

#define RIGHT_X 556.0/2.0
#define RIGHT_Y 6.0/2
#define RIGHT_WIDTH 72.0/2
#define RIGHT_HIGH  72.0/2


#define NAV_X 0.0
#define NAV_Y 0.0
#define NAV_WIDTH 640.0/2.0
#define NAV_HIGH  86.0/2

#define PR_X 216.0/2.0
#define PR_Y 30.0/2.0
#define PR_WIDTH 203/2
#define PR_HIGH 22/2


#define PART_ONE_X 0.0
#define PART_ONE_Y 0.0
#define PART_ONE_WIDTH 320
#define PART_ONE_HIGH 230

#define PART_TWO_X 0.0
#define PART_TWO_Y 230.0
#define PART_TWO_WIDTH 320.0
#define PART_TWO_HIGH 230.0

#define IMG_BAR_X 0.0
#define IMG_BAR_Y 230.0-15
#define IMG_BAR_WIDTH 640.0/2.0
#define IMG_BAR_HIGH 30.0/2.0

#define MASTER_INIT_X 130
#define MASTER_INIT_Y 165
#define MASTER_INIT_WIDTH 136.0/2.0
#define MASTER_INIT_HIGH 136.0/2.0

#define DEAR_WIDTH 118/2
#define DEAR_HIGH 118/2

#define LABEL_X 178.0/2.0
#define LABEL_Y 165.0/2.0
#define LABEL_WIDTH 140/2
#define LABEL_HIGH 32/2

#define SEX_CHANGER_X 264.0/2.0
#define SEX_CHANGER_Y 130.0/2.0
#define SEX_CHANGER_WIDTH 103.0/2.0
#define SEX_CHANGER_HIGH 103.0/2.0

#define STATUS_BUTTON_X 166.0/2.0
#define STATUS_BUTTON_Y 258.0/2.0
#define STATUS_BUTTON_WIDTH 309.0/2.0 
#define STATUS_BUTTON_HIGH 94.0/2.0


#define STATUS_PANEL_X 55/2
#define STATUS_PANEL_Y 321/2
#define STATUS_PANEL_WIDTH 532/2
#define STATUS_PANEL_HIGH 429/2


#define CHECK_BOX_X 192.0/2.0
#define CHECK_BOX_Y 418.0/2.0
#define CHECK_BOX_WIDTH 23.0/2.0
#define CHECK_BOX_HIGH  21.0/2.0


#define PICTURE_WIDTH 230
@interface RegistFirstViewController (Private)

-(void)doCaptureImg:(id)sender;

-(void)ChooseImgFor:(NSInteger)imgtype withtag:(NSInteger)tag;

-(void)loadImgWithTag:(UIImage *)img withtag:(NSInteger)tag;

-(void)doShowOtherPicpanle:(NSInteger)i;

-(void)RunPanelAnimation:(int)i;

-(void)ShowStatusPanel:(id)sender;

-(void)ChangeColor:(id)sender;

-(void)RunPanel;

-(void)RiseBottomView;

-(void)LowDownBottomView;

-(void)ReCoverFrom;

-(void)DoCheck;

-(void)doAnimation;

-(BOOL)doValidate;

-(void)ChangeBackGroundColor;

-(void)do_shake;

-(void)WarnningTipHide;

-(void)WarnningTipShow;
@end

@implementation RegistFirstViewController
@synthesize fnav;
@synthesize registviewcontroller;
-(UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(void)ChangeBackGroundColor{
    if (isgray) {
        
        shakefield.shake_image_view.image= SIGN_NAME_WHITE_IMG;
        shakefield.shake_text_field.textColor=[UIColor blackColor];
        isgray=NO;
    }else {
        
        shakefield.shake_image_view.image=SIGN_NAME_IMG;
        shakefield.shake_text_field.textColor=[UIColor grayColor];
        isgray=YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    helper=[RegistHelper defaultHelper];
    /*
     进入填写个人信息页面的用户数 调用（1)
     */
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
//-(void)doAnimation{
//    CATransition *animations = [CATransition animation];
//    animations.delegate = self;
//    animations.duration = 1.25f;
//    animations.timingFunction = UIViewAnimationCurveEaseInOut;
//    animations.fillMode = kCAFillModeBackwards;
//    animations.type = kCATransitionFromRight;
//    animations.subtype = kCATransitionFromRight;
//    [self.view.layer addAnimation:animations forKey:@"animation"];  
//}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    isopenstatuspanel=NO;
    array=[[NSArray alloc] initWithObjects:@"宝宝",@"亲爱的",@"她/他",nil];
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"#FFFEF6"]];
    [self InitPart2];
    [self InitPart1];
    
    [self loadNav];
}


-(void)InitPart1{
    
    partoneview=[[UIView alloc] initWithFrame:FXRect(PART_ONE_X, PART_ONE_Y, PART_ONE_WIDTH, PART_ONE_HIGH)];
    
    partoneview.backgroundColor=[UIColor blackColor];
    
    partoneview.tag=901;
    
    capturebutton=[[UIImageView alloc] initWithFrame:FXRect(PART_ONE_X, PART_ONE_Y, PART_ONE_WIDTH, PART_ONE_HIGH)];
    
    captureimg=[self imageByCropping:REGIST_DEFAULT_IMG toRect:FXRect(0.0, 0.0, 400.0, 300.0)];
    
    capturebutton.backgroundColor=[UIColor blackColor];
    
    capturebutton.image=REGIST_DEFAULT_IMG;
    
    UILabel *firstline=[[UILabel alloc] initWithFrame:FXRect(38/2-2, 11, 208/2, 15)];
    firstline.text=@"设置漂亮的背景";
    firstline.font=[UIFont boldSystemFontOfSize:13.0];
    firstline.backgroundColor=[UIColor clearColor];
    firstline.textColor=[UIColor whiteColor];
    firstline.textAlignment=UITextAlignmentCenter;
    firstline.shadowColor = [UIColor blackColor];
    
    firstline.shadowOffset = CGSizeMake(0.7, 0.7);
    
    UILabel *secondline=[[UILabel alloc] initWithFrame:FXRect(33, 30, 150/2, 25/2)];
    secondline.text=@"朋友们都会看到";
    secondline.font=[UIFont systemFontOfSize:10.0];
    secondline.backgroundColor=[UIColor clearColor];
    secondline.textColor=[UIColor  colorWithHexString:@"#CCCCCC"];
    secondline.textAlignment=UITextAlignmentCenter;
    secondline.shadowColor = [UIColor blackColor];
    
    secondline.shadowOffset = CGSizeMake(0.7, 0.7);
    
    NSArray *labelarray=[[NSArray alloc] initWithObjects:firstline,secondline,nil];
    
    recaptureimg=[[FxButton alloc] initWithFrame:FXRect(178.0/2.0+3.0, 160.0/2.0, 281.0/2.0, 100.0/2.0)
                             backGroundImgNormal:FX_CHOOSE_IMG
                              backGroundImgHight:FX_CHOOSE_HOVER_IMG 
                                    ControlArray:labelarray operationTag:0];
    
    
    [recaptureimg addTarget:self action:@selector(doCaptureImg:) forControlEvents:UIControlEventTouchUpInside];
    
    recaptureimg.tag=909;
    
    capturebutton.tag=905;
    
    
    
    
    [partoneview addSubview:capturebutton];
    
    [partoneview addSubview:recaptureimg];
    
    barview=[[UIImageView alloc] initWithFrame:FXRect(IMG_BAR_X, IMG_BAR_Y, IMG_BAR_WIDTH, IMG_BAR_HIGH)];
        
    barview.image=REGIST_IMG_BAR;
    
    [partoneview addSubview:barview];
    
    leftlabel=[[UILabel alloc] initWithFrame:FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH)];
    leftlabel.alpha=0.0;
    [leftlabel setBackgroundColor:[UIColor clearColor]];
    [leftlabel setHidden:YES];
    [leftlabel setFont:[UIFont systemFontOfSize:12.0]];
    [leftlabel setTextColor:[UIColor whiteColor]];
    [partoneview addSubview:leftlabel];
    
    rightlabel=[[UILabel alloc] initWithFrame:FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH)];
    
    rightlabel.alpha=0.0;
    
    [rightlabel setBackgroundColor:[UIColor clearColor]];
    
    [rightlabel setFont:[UIFont systemFontOfSize:12.0]];
    
    [rightlabel setHidden:YES];
    
    [rightlabel setTextColor:[UIColor whiteColor]];
    
    [partoneview addSubview:rightlabel];
    
    childrenimg=[[FxImgBall alloc] initWithFrame:FXRect(MASTER_INIT_X-5, MASTER_INIT_Y+15, DEAR_WIDTH, DEAR_HIGH) img:REGIST_IMG_DEAR opttype:0];
    
    childrenimg.delegate=self;
    
    childrenimg.tag=910;
    
    childrenimg.alpha=0.0;
    
    beginleftpanelrect=FXRect(MASTER_INIT_X, MASTER_INIT_Y+15, DEAR_WIDTH, DEAR_HIGH);
    
    [partoneview addSubview:childrenimg];
    
    wifeimg=[[FxImgBall alloc] initWithFrame:FXRect(MASTER_INIT_X-5, MASTER_INIT_Y+15, DEAR_WIDTH, DEAR_HIGH) img:REGIST_IMG_DEAR opttype:0];
    
    wifeimg.delegate=self;
    
    wifeimg.tag=903;
    
    wifeimg.alpha=0.0;
    
    beginrightpanelrect=FXRect(MASTER_INIT_X, MASTER_INIT_Y+15, DEAR_WIDTH, DEAR_HIGH);
    
    [partoneview addSubview:wifeimg];
    
    masterimg=[[FxImgBall alloc] initWithFrame:FXRect(MASTER_INIT_X-5, MASTER_INIT_Y+5, MASTER_INIT_WIDTH, MASTER_INIT_HIGH) img:REGIST_IMG_ME opttype:1];
    
    masterimg.delegate=self;
    
    masterimg.tag=904;
    
    [partoneview addSubview:masterimg];
    
    [self.view addSubview:partoneview];
    
    NSMutableArray *status=[[NSMutableArray alloc] init];
    
    stringarray=[[NSArray alloc] initWithObjects:@"家有宝宝",@"恩爱夫妻",@"甜蜜情侣",@"默默喜欢",@"单身无敌",@"不告诉你", nil];
    
    StatusPanelItem *item;
    for (int i=0; i<[stringarray count]; i++) {
        
        item=[[StatusPanelItem alloc] initWithFrame:FXRect(0.0, 0.0, 124.0/2.0, 124.0/2.0) title:[stringarray objectAtIndex:i] img:STATUS_BABY_IMG];
        item.tag=i+1;
        
        [status addObject:item];
        
    }
    
    
    statuspanel =[[FXStatusPanel alloc] initWithFrame:FXRect(STATUS_PANEL_X, 295/2, STATUS_PANEL_WIDTH, STATUS_PANEL_HIGH) withArray:status];
    
    statuspanel.delegate=self;
    
    statuspanel.alpha=0.0;
    
    
    
    [self.view addSubview:statuspanel];
    
}


-(void)DoLimited:(id)sender{
    /*
    UITextField *tf=(UITextField *)sender;
    if ([tf.text length]>10) {
        NSString *substring=[tf.text substringToIndex:10];
        tf.text=substring;
        
        return;
    }
     */
}
-(void)InitPart2{
    
    parttwoview=[[UIView alloc] initWithFrame:FXRect(PART_TWO_X, PART_TWO_Y, PART_TWO_WIDTH, PART_TWO_HIGH)];
    
    parttwoview.backgroundColor=[UIColor colorWithHexString:@"#FFFEF6"];
    
    parttwoview.tag=902;
    
    isuploadcontact=YES;
    
    donotmove=NO;
    
    twostaycount=1;
    
    needoneload=YES;
    
    needtwoload=NO;
    
    isgray=YES;
    
    shakefield = [[FXShakeField alloc] initWithFrame:FXRect(138/2, 18/2, 358/2, 91/2) ground_image:SIGN_NAME_IMG];
    [shakefield do_set_placeholder_string:@"填写昵称..."];
    
    [shakefield.shake_text_field addTarget:self action:@selector(ChangeBackGroundColor) forControlEvents:UIControlEventEditingDidBegin];
    
    [shakefield.shake_text_field addTarget:self action:@selector(ChangeBackGroundColor) forControlEvents:UIControlEventEditingDidEnd];
    
    [shakefield setKeyBoardReturnType:UIReturnKeyDone];
    
    [shakefield.shake_text_field setKeyboardType:UIKeyboardTypeDefault];
    
    shakefield.shake_text_field.textAlignment=UITextAlignmentCenter;
    
    //[shakefield.shake_text_field addTarget:self action:@selector(DoLimited:) forControlEvents:UIControlEventEditingChanged];
    
    shakefield.delegate=self;
    
    
    [shakefield.shake_text_field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [parttwoview addSubview:shakefield];
    
    
    remark=[[UILabel alloc] initWithFrame:FXRect(LABEL_X, LABEL_Y, LABEL_WIDTH, LABEL_HIGH)];
    [remark setBackgroundColor:[UIColor clearColor]];
    remark.text=@"我是";
    [remark setTextColor:[UIColor colorWithHexString:@"#B8B8B8"]];
    
    sexchanger=[[FXSexChanger alloc] initWithFrame:FXRect(SEX_CHANGER_X, SEX_CHANGER_Y, SEX_CHANGER_WIDTH, SEX_CHANGER_HIGH)];
    
    sexchanger.delegate=self;
    
    [parttwoview addSubview:sexchanger];
    sex=[[UILabel alloc] initWithFrame:FXRect(LABEL_X+103/2+50, LABEL_Y, LABEL_WIDTH, LABEL_HIGH)];
    
    [sex setBackgroundColor:[UIColor clearColor]];
    sex.text=@"好姑娘";

    
    sexinfo=2;
    
    lifestatus=0;
    
    checkbox=[[FXCheckBox alloc] initWithFrame:FXRect(CHECK_BOX_X, CHECK_BOX_Y-1+3, CHECK_BOX_WIDTH, CHECK_BOX_HIGH) isCheck:YES];
    
    [checkbox addTarget:self action:@selector(DoCheck) forControlEvents:UIControlEventTouchUpInside];
    
    [parttwoview addSubview:checkbox];
    
    
    agreelabel=[[UILabel alloc] initWithFrame:FXRect(CHECK_BOX_X+CHECK_BOX_WIDTH+6, CHECK_BOX_Y-1+3, 102, 12)];

    [agreelabel setText:@"告诉我谁在用双双"];
    
    [agreelabel setFont:[UIFont systemFontOfSize:12.0]];
    
    [agreelabel setTextColor:[UIColor colorWithHexString:@"#D7D7D7"]];
    
    [parttwoview addSubview:agreelabel];

    /*
    statusbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    statusbutton.frame=FXRect(STATUS_BUTTON_X, STATUS_BUTTON_Y+2, STATUS_BUTTON_WIDTH, STATUS_BUTTON_HIGH);
    [statusbutton setBackgroundImage:STATUS_BUTTON_IMG forState:UIControlStateNormal];
    
    [statusbutton setBackgroundImage:STATUS_BUTTON_HOVER_IMG forState:UIControlStateHighlighted];
    
    [statusbutton setTitle:@"我的生活状态" forState:UIControlStateNormal];
    [statusbutton setTitle:@"我的生活状态" forState:UIControlStateHighlighted];
    
    [statusbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [statusbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [statusbutton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    [statusbutton addTarget:self action:@selector(ShowStatusPanel:) forControlEvents:UIControlEventTouchUpInside];

    [statusbutton setTitleEdgeInsets:UIEdgeInsetsMake(30.0, 5.0, 30.0, 15.0)];
    [parttwoview addSubview:statusbutton];
     */
    [parttwoview addSubview:remark];
    
    [parttwoview addSubview:sex];
    
    [self.view addSubview:parttwoview];
    
   
    
    
}


-(void)ShowStatusPanel:(id)sender{
    
    
 
    [partoneview setUserInteractionEnabled:NO];
    [UIView beginAnimations:@"hid" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    if (isopenstatuspanel==NO) {
        [statusbutton setBackgroundImage:STATUS_BUTTON_HOVER_IMG forState:UIControlStateNormal];
        [statusbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [statuspanel setAlpha:1.0];
        isopenstatuspanel=YES;
    }else {
        [statusbutton setBackgroundImage:STATUS_BUTTON_IMG forState:UIControlStateNormal];
        [statusbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [statuspanel setAlpha:0.0];
        isopenstatuspanel=NO;
    }
    
    [UIView commitAnimations];
}

-(void)ChangeColor:(id)sender{
     
    
    
}




-(void)loadNav{
    
    UIButton *leftbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    leftbutton.frame=FXRect(10, LEFT_Y, LEFT_WIDTH, LEFT_HIGH);
    
    [leftbutton setImage:FX_NAV_CLOSE_BTN  forState:UIControlStateNormal];
    
    [leftbutton setImage:FX_NAV_CLOSE_BTN_HOVER forState:UIControlStateHighlighted];
    
    UIButton *rightbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    
    rightbutton.frame=FXRect(RIGHT_X, RIGHT_Y, RIGHT_WIDTH, RIGHT_HIGH);
    
    [rightbutton setImage:REGIST_GORIGHT_NORMAL forState:UIControlStateNormal];
    
    [rightbutton setImage:REGIST_GORIGHT_HIGHTLIGHT forState:UIControlStateHighlighted];
    
    NavigationBothStyle *style=[[NavigationBothStyle alloc] initWithTitle:@"" Leftcontrol:leftbutton Rightcontrol:rightbutton];
    
    process=[[FxProcessFixed alloc] initWithFrame:FXRect(PR_X+1.5, PR_Y, PR_WIDTH, PR_HIGH) withstep:0 withtitle:@"关于我"];
    
    fnav =[[FanxerNavigationBarControl alloc] initWithFrame:FXRect(NAV_X, NAV_Y, NAV_WIDTH, NAV_HIGH) withStyle:style withDefinedUserControl:YES];
    
    fnav._delegate=self;
    
    [fnav addSubview:process];
    
   
    
    [self.view addSubview:fnav];
    
    toptippanel=[[FXTopTipPanel alloc] initWithFrame:FXRect(35.0, -46.0, 250, 46) message:@""];
    
    toptippanel.alpha=0.0;
    
    [self.view addSubview:toptippanel];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void)doCaptureImg:(id)sender{
    currentcapturetag = [(UIButton *)sender tag];
    if (currentcapturetag==909) {
        currentcapturetag=905;
    }
   
    UIActionSheet *actionsheet=[[UIActionSheet alloc] initWithTitle:@"选择照片" delegate:self cancelButtonTitle:@"取  消" destructiveButtonTitle:nil otherButtonTitles:@"拍  照",@"从相册选择", nil];
    [actionsheet showInView:self.view];
}


-(void)ChooseImgFor:(NSInteger)imgtype withtag:(NSInteger)tag{
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    picker.allowsEditing=YES;
    
    if (imgtype==0) {
        
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        
        picker.delegate=self;
        
        optype=0;
    }
    if (imgtype==1) {
        
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        
        picker.delegate=self;
        
        optype=1;
        
    }
    [self.navigationController presentModalViewController:picker animated:YES];
    
}

-(void)loadImgWithTag:(UIImage *)img withtag:(NSInteger)tag{
    
    if (tag==905) {
        captureimg=[self imageByCropping:img toRect:FXRect(0.0, 0.0, 640.0, 460.0)];
        capturebutton.image=[self imageByCropping:img toRect:FXRect(0.0, 0.0, 640.0, 460.0)];
    }else {
        FxImgBall *imgball=(FxImgBall *)[self.view viewWithTag:tag];
        [imgball ResetImage:[img imageByScalingAndCroppingForSize:CGSizeMake(640.0,640.0)]];
    }
    
}

-(void)RunPanel{
    
    [self doShowOtherPicpanle:currentstatus];
    
}
//-(UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
-(void)ReCoverFrom{
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.75];
    
    [UIView setAnimationDelegate:self];
    if (laststatustype==2) {
        if (twostaycount<=1) {
            childrenimg.frame=beginleftpanelrect;
            childrenimg.alpha=0.0;
            leftlabel.alpha=0.0;
            leftlabel.frame=FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH);
            leftlabel.hidden=YES;
            rightlabel.alpha=0.0;
            rightlabel.frame=FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH);
            rightlabel.hidden=YES; 
            needoneload=NO;
        }
        twostaycount++;
    }
    
    if (laststatustype==1) {
        childrenimg.frame=beginleftpanelrect;
        childrenimg.alpha=0.0;
        leftlabel.alpha=0.0;
        leftlabel.frame=FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH);
        leftlabel.hidden=YES;
        rightlabel.alpha=0.0;
        rightlabel.frame=FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH);
        rightlabel.hidden=YES; 
        twostaycount=1;
        needtwoload=YES;
        donotmove=YES;
    }
    
    if (laststatustype==0) {
        childrenimg.frame=beginleftpanelrect;
        childrenimg.alpha=0.0;
        leftlabel.alpha=0.0;
        leftlabel.frame=FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH);
        leftlabel.hidden=YES;
        wifeimg.frame=FXRect(MASTER_INIT_X-5, MASTER_INIT_Y+15, DEAR_WIDTH, DEAR_HIGH);
        wifeimg.alpha=0.0;
        
        rightlabel.frame=FXRect(MASTER_INIT_X, IMG_BAR_Y, MASTER_INIT_WIDTH, IMG_BAR_HIGH);
        rightlabel.alpha=0.0;
        
        rightlabel.hidden=YES;
        twostaycount=1;
        donotmove=NO;
        needoneload=YES;
        needtwoload=YES;
    }
    [UIView commitAnimations];
    
}

-(void)RunPanelAnimation:(int)i{
    
    [self ReCoverFrom];
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.75];
    
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect rect;
    CGRect lrect;
   
    if (i==2 && twostaycount<=2) {
        rect=childrenimg.frame;
        lrect=leftlabel.frame;
        float newx=rect.origin.x-childrenimg.frame.size.width+6;
        rect.origin.x=newx;
        lrect.origin.x=newx-20;
    
        if (newx==77.000000) {
            childrenimg.frame=rect;
           // [childrenimg ReloadImg:REGIST_IMG_DEAR];//注释此处保留小孩头像
            childrenimg.alpha=1.0;
            leftlabel.frame=lrect;
            leftlabel.alpha=1.0;
            leftlabel.text=lefttext;
            leftlabel.hidden=NO;
        }
        rect=wifeimg.frame;
        newx=rect.origin.x+wifeimg.frame.size.width-2;
        rect.origin.x=newx;
        lrect=rightlabel.frame;
        lrect.origin.x=newx+52;
        if (newx<=187.000000) {
            wifeimg.frame=rect;
            [wifeimg ReloadImg:REGIST_IMG_DEAR];
            wifeimg.alpha=1.0;
            rightlabel.text=righttext;
            rightlabel.hidden=NO;
            rightlabel.alpha=1.0;
            rightlabel.frame=lrect;
            needtwoload=NO;
        }
        
        if (needtwoload==YES) {
            newx=MASTER_INIT_X-5;
            lrect.origin.x=newx+110;
            rightlabel.text=righttext;
            rightlabel.hidden=NO;
            rightlabel.alpha=1.0;
            rightlabel.frame=lrect;
            needtwoload=NO;
        }
    }
    
    if (i==1) {
        rect=wifeimg.frame;
        
        float newx=rect.origin.x+wifeimg.frame.size.width-2;
        
        rect.origin.x=newx;
        
        lrect=rightlabel.frame;
        
        if (donotmove==NO) {
             lrect.origin.x=newx+55; 
           
        }else {
            newx=MASTER_INIT_X-5;
            lrect.origin.x=newx+110;
        }
        rightlabel.alpha=1.0;
        
        
        rightlabel.frame=lrect;
        
        rightlabel.text=righttext;
        
        rightlabel.hidden=NO;
       
        if (newx<=125.000000 && needoneload==YES) {
            wifeimg.frame=rect;
            [wifeimg ReloadImg:REGIST_IMG_DEAR];
            wifeimg.alpha=1.0;
            leftlabel.hidden=YES;
            needoneload=NO;
        }
        
        if (newx<=125.000000 && donotmove==NO) {
            wifeimg.frame=rect;
             [wifeimg ReloadImg:REGIST_IMG_DEAR];
            wifeimg.alpha=1.0;
            leftlabel.hidden=YES;
        }
    }
    [UIView commitAnimations];
}
-(void)doShowOtherPicpanle:(NSInteger)i{
    isopenstatuspanel=NO;
    switch (i) {
        case 1:
            lefttext=[array objectAtIndex:0];
            righttext=[array objectAtIndex:1];
            lifestatus=6;
            [statusbutton setTitle:[stringarray objectAtIndex:0] forState:UIControlStateNormal];
            [statusbutton setTitle:[stringarray objectAtIndex:0] forState:UIControlStateHighlighted];
            laststatustype=2;
            [self RunPanelAnimation:2];  
            break;
        case 2:
            lifestatus=5;
            [statusbutton setTitle:[stringarray objectAtIndex:1] forState:UIControlStateNormal];
            [statusbutton setTitle:[stringarray objectAtIndex:1] forState:UIControlStateHighlighted];
            laststatustype=1;
            righttext=[array objectAtIndex:1];
            [self RunPanelAnimation:1];
            break;
        case 3:
            lifestatus=4;
            righttext=[array objectAtIndex:1];
            [statusbutton setTitle:[stringarray objectAtIndex:2] forState:UIControlStateNormal];
            [statusbutton setTitle:[stringarray objectAtIndex:2] forState:UIControlStateHighlighted];
            laststatustype=1;
            [self RunPanelAnimation:1];
            break;
        case 4:
            lifestatus=3;
            laststatustype=1;
            righttext=[array objectAtIndex:2 ];
            [statusbutton setTitle:[stringarray objectAtIndex:3] forState:UIControlStateNormal];
            [statusbutton setTitle:[stringarray objectAtIndex:3] forState:UIControlStateHighlighted];
            [self RunPanelAnimation:1];
            break;
        case 5:
            lifestatus=2;
            laststatustype=0;
            [statusbutton setTitle:[stringarray objectAtIndex:4] forState:UIControlStateNormal];
            [statusbutton setTitle:[stringarray objectAtIndex:4] forState:UIControlStateHighlighted];
            [self RunPanelAnimation:0];
            break;
        case 6:
            lifestatus=1;
            laststatustype=0;
            [self RunPanelAnimation:0];
            [statusbutton setTitle:[stringarray objectAtIndex:5] forState:UIControlStateNormal];
            [statusbutton setTitle:[stringarray objectAtIndex:5] forState:UIControlStateHighlighted];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark FanxerNavigationBarDelegate method

- (void)do_shake{
    CABasicAnimation *animation = 
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:FX_SHAKE_DURATION];
    [animation setRepeatCount:FX_SHAKE_REPEATE];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([statusbutton center].x - FX_SHAKE_LENGTH, [statusbutton center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([statusbutton center].x + FX_SHAKE_LENGTH, [statusbutton center].y)]];
    [[statusbutton layer] addAnimation:animation forKey:@"position"];
}


-(void)DoCheck{
    
    if (isuploadcontact==YES) {
        isuploadcontact=[checkbox CheckFor:NO];
        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"" 
                                                          message:@"这样朋友们就找不到你啦，赶快勾选吧：）" 
                                                         delegate:self 
                                                cancelButtonTitle:@"取消" 
                                                otherButtonTitles:@"确定", nil];
        
        [alertview show];
        
    }else {
        isuploadcontact=[checkbox CheckFor:YES];
    }
}

-(void)doLeft{
    
        helper=[RegistHelper defaultHelper];
        [helper RemovePropertyForKey:@"mobile"];
        [helper RemovePropertyForKey:@"account"];
        [helper RemovePropertyForKey:@"pwd"];
 
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doRight{
    
    
    statuspanel.alpha=0.0;
    isopenstatuspanel=NO;
    if (isgo) {
        return;
    }
    if ([self doValidate]) {

        RegistInfo *reginfo=[[RegistInfo alloc] init];
        [reginfo setLifestatus:lifestatus];
        [reginfo setNikename:shakefield.shake_text_field.text];
        [reginfo setSex:sexinfo];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setValue:[masterimg retriveImg] forKey:@"master"];
        [dict setValue:[childrenimg retriveImg] forKey:@"children"];
        [dict setValue:[wifeimg retriveImg] forKey:@"wife"];
        [dict setValue:captureimg forKey:@"capturebg"];
        [reginfo setImgdict:dict];
        [shakefield.shake_text_field resignFirstResponder];
        registviewcontroller = [[RegistViewController alloc] initWithRegistInfo:reginfo];
        [self.navigationController pushViewController:registviewcontroller animated:YES];
        
    }
    return;
    
}


-(BOOL)doValidate{

    BOOL textfill;
    if ([shakefield.shake_text_field.text length]==0 && lifestatus==0 && [masterimg retriveImg]==nil) {
        [toptippanel ResetMessage:@"请您填写抖动项目！"];
        [self WarnningTipShow];
        [shakefield do_shake];
        [self do_shake];
        [masterimg do_shake];
        
        return NO;
    }
    
    BOOL imgfill;
    if ([masterimg retriveImg]==nil) {
        [masterimg do_shake];
        imgfill=NO;
    }else {
        imgfill=YES;
    }   
    
    if ([shakefield.shake_text_field.text length]==0) {
        [shakefield do_shake];
        textfill=NO;
    }else {
        textfill=YES;
    }
    /*
    BOOL lifestatusfill;
    if (lifestatus==0) {

        [self do_shake];

        lifestatusfill=NO;
    }else {
        lifestatusfill=YES;
    }
     LabelType_UserInfor_NextStep_UserHeadImageAndNickNameIsNull,// 点击下一步时，头像并且昵称都未填
     LabelType_UserInfor_NextStep_UserHeadImageIsNull,           // 点击下一步时，头像未填
     LabelType_UserInfor_NextStep_NickHeadImageIsNull,           // 点击下一步时，昵称未填
    */

    
    
    if (textfill && imgfill) {
        /*
         顺利完成个人信息填写页面的用户 调用（1）
         */
        return YES;
    }else {
        /*
         点击下一步时，头像并且昵称都未填 调用（2）
         */
        if(textfill==NO&&imgfill==NO){
        }
        /*&
         点击下一步时，头像未填 调用（2）
         */
        if(textfill==YES&&imgfill==NO){
        }
        /*
         点击下一步时，昵称未填 调用（2)
         */
        if(textfill==NO&&imgfill==YES){
        }
        [toptippanel ResetMessage:@"请填写抖动项目！"];
        [self WarnningTipShow];
        return NO;
    }
    return NO;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate method
-(void)imagePickerController:(UIImagePickerController *)pickers didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self loadImgWithTag:image withtag:currentcapturetag];

   [pickers dismissModalViewControllerAnimated:YES];
    
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)pickers{
    
    [pickers dismissModalViewControllerAnimated:YES];
    
}


#pragma mark -
#pragma mark FxImgBallDelegate method

-(void)ChooseImageFrom:(NSInteger)imgtype tag:(NSInteger)tag{
    currentcapturetag=tag;
    [self ChooseImgFor:imgtype withtag:tag];
}



#pragma mark -
#pragma mark UIActionSheetDelegate method

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            [self ChooseImgFor:0 withtag:currentcapturetag];
            break;
        case 1:
            [self ChooseImgFor:1 withtag:currentcapturetag];
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark FXSexChangerDelegate method
-(void)changeSexInfo:(NSInteger)sexval{
    
    if (sexval==0) {
        sexinfo=2;
        sex.text=@"好姑娘";
    }else{
        sexinfo=1;
        sex.text=@"纯爷们";
    }
}

#pragma mark -
#pragma mark FXStatusPanelDelegate method
-(void)ChooseStatus:(NSInteger)status{
    
    currentstatus=status;
    [partoneview setUserInteractionEnabled:YES];
  
    [UIView beginAnimations:@"hid" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [statuspanel setAlpha:0.0];
    
    [statusbutton setBackgroundImage:STATUS_BUTTON_IMG forState:UIControlStateNormal];
    [statusbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [UIView commitAnimations];
    
    [self performSelector:@selector(RunPanel) withObject:nil afterDelay:0.5f];
}

#pragma mark -
#pragma mark FXShakeFieldDelegate method
- (void)shake_field_did_begin_editing:(UITextField *)text_field{
    if ([text_field.text length] <=10) {
       [self do_rise];
    }
    else if([text_field.text length]>10){
        [text_field resignFirstResponder];
    }
    
}
- (void)shake_field_did_end_editing:(UITextField *)text_field{

    [self do_drop];
}
- (void)shake_field_should_return:(UITextField *)text_field{
    [self do_drop];
}
- (void)shake_field_did_text_edit:(UITextField *)text_field{
    
}
#pragma mark UIResponser
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [shakefield.shake_text_field resignFirstResponder];
    [partoneview setUserInteractionEnabled:YES];
    [UIView beginAnimations:@"rise" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [statuspanel setAlpha:0.0];
    [statusbutton setBackgroundImage:STATUS_BUTTON_IMG forState:UIControlStateNormal];
    [statusbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    isopenstatuspanel=NO;
    [UIView commitAnimations];
    [self do_drop];
}
#pragma mark Action
- (void)do_rise{
    [UIView beginAnimations:@"rise" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    partoneview.frame=FXRect(PART_ONE_X,PART_ONE_Y-80, PART_ONE_WIDTH, PART_ONE_HIGH);
    parttwoview.frame=FXRect(PART_ONE_X, 150, PART_ONE_WIDTH, PART_ONE_HIGH);
    [UIView commitAnimations];
}
- (void)do_drop{
    [UIView beginAnimations:@"rise" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    partoneview.frame=FXRect(PART_ONE_X, PART_ONE_Y,PART_ONE_WIDTH, PART_ONE_HIGH);
    parttwoview.frame=FXRect(PART_TWO_X, PART_TWO_Y, PART_TWO_WIDTH, PART_TWO_HIGH);
    [UIView commitAnimations];
}
-(void)HiddenStatusView{
    
    [partoneview setUserInteractionEnabled:YES];
    [UIView beginAnimations:@"rise" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [statuspanel setAlpha:0.0];
    [UIView commitAnimations];
    isopenstatuspanel=NO;
}

#pragma mark -
#pragma mark UIAlertViewDelegate method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
           isuploadcontact=[checkbox CheckFor:NO];
            break;
            
        case 1:
            isuploadcontact=[checkbox CheckFor:YES];
            break;
            
        default:
            break;
    }
}


-(void)WarnningTipHide{
    isgo=NO;
    [UIView beginAnimations:@"hid" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    toptippanel.alpha=0.0;
    CGRect rect=toptippanel.frame;
    rect.origin.y=-46.0;
    toptippanel.frame=rect;
    [UIView commitAnimations];
}


-(void)WarnningTipShow{
    isgo=YES;
    [UIView beginAnimations:@"hid" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    toptippanel.alpha=1.0;
    CGRect rect=toptippanel.frame;
    rect.origin.y=0.0;
    toptippanel.frame=rect;
    [UIView commitAnimations];
    [self performSelector:@selector(WarnningTipHide) withObject:nil afterDelay:3.5];
}

@end
