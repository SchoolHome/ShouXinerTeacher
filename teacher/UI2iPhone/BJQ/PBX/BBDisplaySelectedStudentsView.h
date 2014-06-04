//
//  BBDisplaySelectedStudentsView.h
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BBDisplaySelectedStudentsViewDelegate<NSObject>
-(void)ConfirmBtnTapped:(NSArray *)selectedStudentInfos;
@end
@interface BBDisplaySelectedStudentsView : UIView
@property (nonatomic, weak)id<BBDisplaySelectedStudentsViewDelegate> delegate;
@end
