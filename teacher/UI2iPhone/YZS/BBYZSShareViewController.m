//
//  BBYZSShareViewController.m
//  teacher
//
//  Created by xxx on 14-3-20.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBYZSShareViewController.h"
#import "BBGroupModel.h"

@interface BBYZSShareViewController ()

@end

@implementation BBYZSShareViewController


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([@"postForwardResult" isEqualToString:keyPath])
    {
        NSDictionary *dict=[PalmUIManagement sharedInstance].postForwardResult;
        
        NSLog(@"%@",dict);
        
        if ([dict[@"hasError"] boolValue]) {
            [self showProgressWithText:@"转发失败" withDelayTime:0.1];
        }else{
            [self showProgressWithText:@"转发成功" withDelayTime:0.1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(void)sendButtonTaped:(id)sender{

//    groupid = 8;
//    groupid = 1000666;
//    groupid = 1000675;
    // 转发有指示
    
    [thingsTextView resignFirstResponder];
    
    if ([thingsTextView.text length]>0) {
        [self showProgressWithText:@"正在转发..."];
        
        
        NSDictionary *result = [PalmUIManagement sharedInstance].groupListResult;
        
        NSArray *groupList = [NSArray arrayWithArray:result[@"data"]];
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        int index = [def integerForKey:@"saved_topic_group_index"];  // 上次选中的班级
        
        BBGroupModel *group = nil;
        if ([groupList count]>index) {
            group = groupList[index];
        }else{
            group = groupList[0];
        }
        
        [[PalmUIManagement sharedInstance] postForwardNoti:[_oaDetailModel.oaid intValue]
                                               withGroupID:[group.groupid intValue]
                                               withMessage:thingsTextView.text];
    }else{
        
        [self showProgressWithText:@"请输入文字" withDelayTime:0.1];
    }
}

-(void)backButtonTaped:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addObservers{
    [[PalmUIManagement sharedInstance] addObserver:self forKeyPath:@"postForwardResult" options:0 context:NULL];
}

-(void)removeObservers{
    
    [[PalmUIManagement sharedInstance] removeObserver:self forKeyPath:@"postForwardResult"];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self addObservers];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [self removeObservers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.title = @"分享";
    
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"BBSendButton"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    
    UIView *textBack = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 320-30, 70)];
    [self.view addSubview:textBack];
    CALayer *roundedLayer0 = [textBack layer];
    [roundedLayer0 setMasksToBounds:YES];
    roundedLayer0.cornerRadius = 8.0;
    roundedLayer0.borderWidth = 1;
    roundedLayer0.borderColor = [[UIColor lightGrayColor] CGColor];
    
    thingsTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(20, 20, 320-40, 60)];
    [self.view addSubview:thingsTextView];
    thingsTextView.backgroundColor = [UIColor clearColor];
    thingsTextView.placeholder = @"分享新鲜事...";
    
    UIButton *link = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:link];
    
    EGOImageView *linkIcon = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
    [link addSubview:linkIcon];
    if ([_oaDetailModel.images count]>0) {
        linkIcon.imageURL  = [NSURL URLWithString:_oaDetailModel.images[0]];
    }
    
    UILabel *linkTitle = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 320-30-70, 20)];
    [link addSubview:linkTitle];
    
    UILabel *linkContent = [[UILabel alloc] initWithFrame:CGRectMake(65, 25, 320-30-70, 30)];
    [link addSubview:linkContent];
    linkContent.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
    
    link.frame = CGRectMake(15, 100, 320-30, 65);//
    link.backgroundColor = [UIColor whiteColor];
    CALayer *roundedLayer = [link layer];
    [roundedLayer setMasksToBounds:YES];
    roundedLayer.cornerRadius = 8.0;
    roundedLayer.borderWidth = 1;
    roundedLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    linkIcon.backgroundColor = [UIColor grayColor];
    
    linkTitle.text = _oaDetailModel.title;
    linkTitle.font = [UIFont systemFontOfSize:14];
    
    linkContent.text = _oaDetailModel.content;//@"教育局新指示，发言人说XXXXX、教育局新指示，发言人说XXXXX、教育局新指示，";
    linkContent.font = [UIFont systemFontOfSize:12];
    linkContent.numberOfLines = 2;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [thingsTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
