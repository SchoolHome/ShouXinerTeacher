//
//  ViewImageViewController.m
//  teacher
//
//  Created by singlew on 14-5-18.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "ViewImageViewController.h"

@interface ViewImageViewController ()<UIActionSheetDelegate>
@property(nonatomic,strong) XLCycleScrollView *csView;
@property(nonatomic,strong) NSArray *dataSource;
@property(nonatomic) int selectedIndex;
@end

@implementation ViewImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initViewImageVC : (NSArray *) images withSelectedIndex : (int) index{
    self = [super init];
    if (self) {
        self.dataSource = images;
        self.selectedIndex = index;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"BBBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"BBDelete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
    self.csView = [[XLCycleScrollView alloc] initCycleScrollView:self.selectedIndex withFrame:self.view.bounds];
    self.csView.delegate = self;
    self.csView.datasource = self;
    [self.view addSubview:self.csView];
}

- (NSInteger)numberOfPages{
    return [self.dataSource count];
}

-(void) backButtonTaped : (id)sender{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(reloadView)]) {
        [self.delegate reloadView];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) deleteButtonTap : (id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
    [sheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        // 删除
        NSMutableArray *images = [[NSMutableArray alloc] initWithArray:self.dataSource];
        [images removeObjectAtIndex:self.csView.currentPage];
        if (self.csView.currentPage > 0) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(delectedIndex:)]) {
                [self.delegate delectedIndex:self.csView.currentPage];
            }
            self.csView.currentPage -= 1;
        }else if (self.csView.currentPage == 0 && [images count] > 0 ){
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(delectedIndex:)]) {
                [self.delegate delectedIndex:self.csView.currentPage];
            }
            self.csView.currentPage = 0;
        }
        
        if ([images count] == 0) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(reloadView)]) {
                [self.delegate reloadView];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        self.dataSource = images;
        [self.csView reloadData];
    }
}


- (UIView *)pageAtIndex:(NSInteger)index{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [self.dataSource objectAtIndex:index];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
