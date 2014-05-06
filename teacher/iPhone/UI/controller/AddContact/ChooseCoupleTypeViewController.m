//
//  ChooseCoupleTypeViewController.m
//  iCouple
//
//  Created by yong wei on 12-4-10.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "ChooseCoupleTypeViewController.h"

@implementation NotificationContext

@synthesize requestType = _requestType;
@synthesize chooseedType = _chooseedType;
@end

@interface ChooseCoupleTypeViewController ()

@property (nonatomic,assign) RequestType requestType;

-(void) popChooseCoupleView;
-(void) chooseAddLover : (id) sender;
-(void) chooseAddMarried : (id) sender;
-(void) initView;
@end

@implementation ChooseCoupleTypeViewController
@synthesize topImageView = _topImageView , lineImageView = _lineImageView , leftButton = _leftButton , rightButton = _rightButton;
@synthesize loverLabel = _loverLabel , marriedLabel = _marriedLabel ,labelFont = _labelFont;
@synthesize fnav = _fnav;
@synthesize requestType = _requestType;

-(id) initChooseCoupleTypeView{
    self = [super init];
    if (self) {
        self.labelFont = [UIFont fontWithName:@"Times New Roman" size:14.0f];
        
        [self initView];
        
    }
    return self;
}

-(id) initChooseCoupleTypeView:(RequestType)requestType{
    self = [super init];
    
    if (self) {
        self.labelFont = [UIFont fontWithName:@"Times New Roman" size:14.0f];
        self.requestType = requestType;
        [self initView];
    }
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void) initView{
    // 添加navigtionBar
    UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame=CGRectMake(2.5f, 4.0f, 36.0f, 36.0f);
    [leftButton setImage:[UIImage imageNamed:@"icon_nav_list_back.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"icon_nav_list_back_press.png"] forState:UIControlStateHighlighted];
    
    NavigationBothStyle *style=[[NavigationBothStyle alloc] initWithTitle:@"你是哪种双双？" Leftcontrol:leftButton Rightcontrol:nil];
    style.background = [UIImage imageNamed:@"list_top_bg.png"];
    
    self.fnav =[[FanxerNavigationBarControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f) withStyle:style withDefinedUserControl:YES];
    self.fnav.backageview.frame =CGRectMake(0.0f, 0.0f, 320.0f, 44.0f);
    
    self.fnav._delegate = self;
    [self.view addSubview:self.fnav];
    
    
    // 增加Top图片view
    self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 186.0f)];
    self.topImageView.image = [UIImage imageNamed:@"add_couple_img.jpg"];
    [self.view addSubview:self.topImageView];
    
    // 增加灰线图片view
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(159.5f, 295.0f, 1.0f, 97.5f)];
    self.lineImageView.image = [UIImage imageNamed:@"addcouple_line.png"];
    [self.view addSubview:self.lineImageView];
    
    //添加恋爱ing按钮
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"icon_lovers@2x.jpg"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage imageNamed:@"icon_lovers_hover@2x.jpg"] forState:UIControlStateHighlighted];
    self.leftButton.frame = CGRectMake(11.5f, self.view.frame.size.height - 43.5f - 134.5f, 134.5f, 121.0f);
    [self.view addSubview:self.leftButton];
    [self.leftButton addTarget:self action:@selector(chooseAddLover:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加夫妻按钮
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"btn_addcouple2_Ice-breaking@2x.jpg"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage imageNamed:@"btn_addcouple2_Ice-breakingpress@2x.jpg"] forState:UIControlStateHighlighted];
    self.rightButton.frame = CGRectMake(174.5f, self.view.frame.size.height - 43.5f - 134.5f, 134.5f, 121.0f);
    [self.view addSubview:self.rightButton];
    [self.rightButton addTarget:self action:@selector(chooseAddMarried:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加恋爱ing文本
//    self.loverLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
//    self.loverLabel.text = @"恋爱ing";
//    self.loverLabel.font = self.labelFont;
//    self.loverLabel.backgroundColor = [UIColor clearColor];
//    [self.loverLabel sizeToFit];
//    self.loverLabel.frame = CGRectMake(62.0f, 376.5f, self.loverLabel.frame.size.width, self.loverLabel.frame.size.height);
//    self.loverLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//    [self.view addSubview:self.loverLabel];
//    
//    // 添加小夫妻文本
//    self.marriedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
//    self.marriedLabel.text = @"小夫妻";
//    self.marriedLabel.font = self.labelFont;
//    self.marriedLabel.backgroundColor = [UIColor clearColor];
//    [self.marriedLabel sizeToFit];
//    self.marriedLabel.frame = CGRectMake(209.0f, 376.5f, self.marriedLabel.frame.size.width, self.marriedLabel.frame.size.height);
//    self.marriedLabel.textColor = [UIColor colorWithHexString:@"#666666"];
//    [self.view addSubview:self.marriedLabel];
    
    [ChooseCoupleModel sharedInstance].chooseedType = IsNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#FFFEF3"];
}

-(void) chooseAddLover:(id)sender{
    [ChooseCoupleModel sharedInstance].chooseedType = IsLover;
    [self popChooseCoupleView];
}

-(void) chooseAddMarried:(id)sender{
    [ChooseCoupleModel sharedInstance].chooseedType = IsMarried;
    [self popChooseCoupleView];
}

-(void) doLeft{
    [self popChooseCoupleView];
}

-(void) popChooseCoupleView{
    [self.navigationController popViewControllerAnimated:YES];
    
    NotificationContext *notificationContext = [[NotificationContext alloc] init];
    notificationContext.chooseedType = [ChooseCoupleModel sharedInstance].chooseedType;
    notificationContext.requestType = self.requestType;
    
    NSNotification* notification = [NSNotification notificationWithName:@"ChooseCoupleNotification" object:notificationContext];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
