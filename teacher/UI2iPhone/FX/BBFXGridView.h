//
//  BBFXGridView.h
//  teacher
//
//  Created by mac on 14/11/7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBFXModel.h"
#import "EGOImageView.h"

@interface BBFXGridView : UIButton
@property (nonatomic) NSInteger colIndex;
@property (nonatomic) NSInteger rowIndex;
@property (nonatomic, strong) UILabel *txtName;
@property (nonatomic, strong) EGOImageView *egoLogo;
@property (nonatomic, strong) UIView *flagNew;

-(void)setViewData:(BBFXModel *)model;
@end
