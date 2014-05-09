//
//  BBBaseTableViewCell.h
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorUtil.h"
#import "OHAttributedLabel.h"
#import "EGOImageView.h"
#import "EGOImageButton.h"

#import "BBTopicModel.h"

#define K_LEFT_PADDING 75

// view frame
#define kViewLeft(__view) (__view.frame.origin.x)
#define kViewWidth(__view) (__view.frame.size.width)

#define kViewTop(__view) (__view.frame.origin.y)
#define kViewHeight(__view) (__view.frame.size.height)

#define kViewRight(__view) ( kViewLeft(__view) + kViewWidth(__view) )
#define kViewFoot(__view) ( kViewTop(__view) + kViewHeight(__view) )


@protocol BBBaseTableViewCellDelegate;
@interface BBBaseTableViewCell : UITableViewCell
{

}

@property(nonatomic,weak) id<BBBaseTableViewCellDelegate> delegate;

@property(nonatomic,strong) EGOImageView *icon;

@property(nonatomic,strong) UIImageView *line;

@property(nonatomic,strong) UILabel *time;
@property(nonatomic,strong) UIButton *like;
@property(nonatomic,strong) UIButton *reply;


@property(nonatomic,strong) UILabel *likeContent;
@property(nonatomic,strong) OHAttributedLabel *relpyContent;

@property(nonatomic,strong) UIImageView *relpyContentBack;
@property(nonatomic, strong) UIImageView *relpyContentLine;

@property(nonatomic,strong) UIImageView *relpyContentBackTop;
@property(nonatomic,strong) UIImageView *relpyContentBackBottom;


@property(nonatomic,strong) BBTopicModel *data;

-(NSString *)timeStringFromNumber:(NSNumber *) number;
-(EGOImageButton *) imageContentWithIndex : (int) index;
@end

@protocol BBBaseTableViewCellDelegate <NSObject>
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell likeButtonTaped:(UIButton *)sender;
-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell replyButtonTaped:(UIButton *)sender;

-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell imageButtonTaped:(EGOImageButton *)sender;

-(void)bbBaseTableViewCell:(BBBaseTableViewCell *)cell linkButtonTaped:(UIButton *)sender;

@end


@interface UIView (Debug)

-(void)showDebugRect:(BOOL) show_;

@end
