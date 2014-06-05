//
//  BBDisplaySelectedStudentsView.m
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBDisplaySelectedStudentsView.h"
#import "BBStudentModel.h"
@implementation BBDisplaySelectedStudentsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:207/255.f green:204/255.f blue:195/255.f alpha:1.f];
        
        selectedStudentsScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, 320-80.f, frame.size.height)];
        selectedStudentsScrollview.showsVerticalScrollIndicator = NO;
        selectedStudentsScrollview.backgroundColor = [UIColor clearColor];
        [self addSubview:selectedStudentsScrollview];
        
        studentNamesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        studentNamesLabel.backgroundColor = [UIColor clearColor];
        studentNamesLabel.font = [UIFont systemFontOfSize:14.f];
        studentNamesLabel.textColor = [UIColor colorWithRed:59/255.f green:107/255.f blue:139/255.f alpha:1.f];
        [selectedStudentsScrollview addSubview:studentNamesLabel];
        
        confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setFrame:CGRectMake(320.f-70.f, (frame.size.height-32)/2, 59.f, 32.f)];
        [confirmBtn addTarget:self action:@selector(confirmSelected) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setBackgroundImage:[UIImage imageNamed:@"ZJZGroupChat"] forState:UIControlStateNormal];
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        confirmBtn.enabled = NO;
        [self addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)confirmSelected
{
    if ([self.delegate respondsToSelector:@selector(confirmBtnTapped)]) {
        [self.delegate confirmBtnTapped];
    }
}
-(void)setStudentNames:(NSArray *)studentNames
{
    if (studentNames.count == 0) {
        studentNamesLabel.text = @"";
        [selectedStudentsScrollview setContentSize:CGSizeZero];
        
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        confirmBtn.enabled = NO;
        return;
    }
    
    NSString *names;
    for (int i = 0;i<studentNames.count;i++) {
        BBStudentModel *studentModel = [studentNames objectAtIndex:i];
        NSString *name = studentModel.studentName;
        if (i==0) names = [NSString stringWithFormat:@"@%@",name];
        else names = [names stringByAppendingFormat:@"、%@",name];
    }
    
    
    CGSize textSize = [names sizeWithFont:[UIFont systemFontOfSize:14.f]];
    if (textSize.width > 240) {
        selectedStudentsScrollview.contentSize = CGSizeMake(textSize.width, selectedStudentsScrollview.frame.size.height);
        [studentNamesLabel setFrame:CGRectMake(2.f, 0.f, textSize.width+2, selectedStudentsScrollview.frame.size.height)];
    }else
    {
        selectedStudentsScrollview.contentSize = CGSizeMake(240.f, selectedStudentsScrollview.frame.size.height);
        [studentNamesLabel setFrame:CGRectMake(2.f, 0.f, 222.f, selectedStudentsScrollview.frame.size.height)];
    }
    
    studentNamesLabel.text = names;
    

    [confirmBtn setTitle:[NSString stringWithFormat:@"确定(%d)",studentNames.count] forState:UIControlStateNormal];
    confirmBtn.enabled = YES;


}
@end
