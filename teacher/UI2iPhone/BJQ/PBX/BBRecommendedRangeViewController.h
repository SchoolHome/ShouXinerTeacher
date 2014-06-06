//
//  BBRecommendedRangeViewController.h
//  teacher
//
//  Created by ZhangQing on 14-6-4.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "BBStudentListTableViewCell.h"
#import "BBDisplaySelectedStudentsView.h"
@class BBdisplaySelectedRangeView;
@class BBRecommendedRangeTableViewCell;

@protocol RangeTableViewCellDelegate <NSObject>

-(void)selectedRange:(NSIndexPath *)indexPath;

@end

@interface BBRecommendedRangeViewController : PalmViewController
<BBStudentListTableViewCellDelegate,
BBDisplaySelectedStudentsViewDelegate,
RangeTableViewCellDelegate,
UITableViewDelegate,UITableViewDataSource>

-(id)initWithRanges:(NSArray *)ranges;

@end



@interface BBRecommendedRangeTableViewCell : UITableViewCell
{
    
}
@property (nonatomic, strong)UILabel *rangeLabel;
@property (nonatomic, strong)UIButton *selectedBtn;
@property (nonatomic, strong)NSIndexPath *indexPath;
@property (nonatomic, weak)id<RangeTableViewCellDelegate> delegate;
-(void)setContent:(NSIndexPath *)indexpath;

@end



@interface BBdisplaySelectedRangeView : BBDisplaySelectedStudentsView

-(void)setRanges:(NSArray *)ranges;


@end