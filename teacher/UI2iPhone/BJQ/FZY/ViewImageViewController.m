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
@property(nonatomic) NSInteger selectedIndex;
@end

@implementation ViewImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initViewImageVC : (NSArray *) images withSelectedIndex : (NSInteger ) index{
    self = [super init];
    if (self) {
        self.dataSource = images;
        self.selectedIndex = index;
        
        self.title = [NSString stringWithFormat:@"%d/%d",index+1,images.count];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // left
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.f, 7.f, 24.f, 24.f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    // right
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(8.f, 7.f, 60.f, 30.f)];
    [sendButton setTitle:@"删除" forState:UIControlStateNormal];
    //sendButton.backgroundColor = [UIColor blackColor];
    [sendButton setTitleColor:[UIColor colorWithRed:251/255.f green:76/255.f blue:7/255.f alpha:1.f] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(deleteButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    /*
    // right
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(0.f, 7.f, 30.f, 30.f)];
    [deleteButton setBackgroundImage:[UIImage imageNamed:@"BBDelete"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    */
    self.csView = [[XLCycleScrollView alloc] initCycleScrollView:(int)self.selectedIndex withFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight)];
    self.csView.backgroundColor = [UIColor redColor];
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
            self.title = [NSString stringWithFormat:@"%d/%d",self.csView.currentPage+1,images.count];
        }else if (self.csView.currentPage == 0 && [images count] > 0 ){
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(delectedIndex:)]) {
                [self.delegate delectedIndex:self.csView.currentPage];
            }
            self.csView.currentPage = 0;
            self.title = [NSString stringWithFormat:@"1/%d",images.count];
        }else if (self.csView.currentPage == 0 && [images count] == 0)
        {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(delectedIndex:)]) {
                [self.delegate delectedIndex:0];
            }
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
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.screenWidth, self.screenHeight)];
    imageView.image = [self imageWithImage:[self.dataSource objectAtIndex:index]];
    imageView.contentMode = UIViewContentModeScaleAspectFit & UIViewContentModeCenter;
    
    return imageView;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index;
{
    NSMutableArray *images = [[NSMutableArray alloc] initWithArray:self.dataSource];
    self.title = [NSString stringWithFormat:@"%d/%d",index+1,images.count];
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
