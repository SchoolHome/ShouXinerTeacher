//
//  BBFSDropdownView.h
//  teacher
//
//  Created by xxx on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BBFSDropdownViewDelegate;
@interface BBFSDropdownView : UIControl<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_list;
}

@property (nonatomic,weak) id<BBFSDropdownViewDelegate> delegate;
@property (nonatomic,strong) NSArray *listData;
@property BOOL unfolded;

-(void)show;
-(void)dismiss;

@end

@protocol BBFSDropdownViewDelegate <NSObject>

-(void)bbFSDropdownView:(BBFSDropdownView *) dropdownView_ didSelectedAtIndex:(NSInteger) index_;
-(void)bbFSDropdownViewTaped:(BBFSDropdownView *) dropdownView_;

@end