//
//  BBDisplaySelectedStudentsView.h
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BBDisplaySelectedStudentsViewDelegate<NSObject>
-(void)confirmBtnTapped;
@end
@interface BBDisplaySelectedStudentsView : UIView
{
    UIScrollView *selectedStudentsScrollview;
    UIButton *confirmBtn;
    UILabel *studentNamesLabel;
}
@property (nonatomic, weak)id<BBDisplaySelectedStudentsViewDelegate> delegate;

-(void)setStudentNames:(NSArray *)studentNames;
@end
