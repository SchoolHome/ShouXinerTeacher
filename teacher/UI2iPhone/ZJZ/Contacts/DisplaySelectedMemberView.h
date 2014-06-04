//
//  DisplaySelectedMemberView.h
//  teacher
//
//  Created by ZhangQing on 14-3-24.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DisplaySelectedMemberViewDelegate <NSObject>
-(void)confirmBtnTapped:(NSArray *)userinfos;
@end

@interface DisplaySelectedMemberView : UIView
@property (nonatomic , assign) BOOL isAddMember;
@property (nonatomic , strong) NSArray *selectedMembersArray;
@property (nonatomic , strong) UIScrollView *membersScrollview;
@property (nonatomic , strong) UIButton *confirmBtn;
@property (nonatomic , strong) UIImageView *emptyHeadImageview;
@property (nonatomic , weak) id<DisplaySelectedMemberViewDelegate> delegate;




@end
