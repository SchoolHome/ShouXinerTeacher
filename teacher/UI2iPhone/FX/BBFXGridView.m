//
//  BBFXGridView.m
//  teacher
//
//  Created by mac on 14/11/7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBFXGridView.h"

@implementation BBFXGridView
@synthesize txtName = _txtName, egoLogo = _egoLogo, imageFlag = _imageFlag;
-(id)init{
    self = [super init];
    if (self) {
        _egoLogo = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@""]];
        [_egoLogo setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_egoLogo];
        
        _txtName = [[UILabel alloc] init];
        [_txtName setTextAlignment:NSTextAlignmentCenter];
        [_txtName setFont:[UIFont boldSystemFontOfSize:12]];
        [self addSubview:_txtName];
        
        _imageFlag = [[UIImageView alloc] init];
        [_imageFlag setImage:[UIImage imageNamed:@"fx_grid_flag.png"]];
        [_imageFlag setBackgroundColor:[UIColor redColor]];
        [_imageFlag setHidden:YES];
        [self addSubview:_imageFlag];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    UIImageView *bgImgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [bgImgv setImage:[UIImage imageNamed:@"fx_grid_bg.png"]];
    [self addSubview:bgImgv];
    bgImgv = nil;
    
    [self.egoLogo setFrame:CGRectMake(0, 0, frame.size.width-1, frame.size.height-20)];
    [self.txtName setFrame:CGRectMake(0, frame.size.height-20, frame.size.width-1, 20)];
    [self.imageFlag setFrame:CGRectMake(frame.size.width-20, 10, 10, 10)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setViewData:(BBFXModel *)model
{
    [self.egoLogo setImageURL:[NSURL URLWithString:model.image]];
    [self.txtName setText:model.title];
    if (model.isNew) {
        [self.imageFlag setHidden:NO];
    }
}
@end
