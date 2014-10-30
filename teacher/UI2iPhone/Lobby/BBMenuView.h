//
//  BBMenuView.h
//  teacher
//
//  Created by singlew on 14/10/29.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    kPBXItem = 0,
    kHomeWorkItem,
    kNoticeItem,
    kSBSItem,
}ClickMenuItem;

@protocol MenuDelegate <NSObject>

@optional
-(void) clickItemIndex : (ClickMenuItem) item;
@end

@interface BBMenuView : UIView
@property (nonatomic,weak) id<MenuDelegate> delegate;
@property (nonatomic,strong) UIButton *homeWorkButton;
@property (nonatomic,strong) UIButton *noticeButton;
@property (nonatomic,strong) UIButton *PBXButton;
@property (nonatomic,strong) UIButton *SBSButton;
@property (nonatomic,strong) UIButton *closeViewButton;
@end
