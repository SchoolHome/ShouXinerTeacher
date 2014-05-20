//
//  ViewImageViewController.h
//  teacher
//
//  Created by singlew on 14-5-18.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"
#import "XLCycleScrollView.h"

@protocol viewImageDeletedDelegate <NSObject>

@required
-(void) delectedIndex: (int) index;
-(void) reloadView;
@end

@interface ViewImageViewController : PalmViewController<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate>

@property(nonatomic,assign) id<viewImageDeletedDelegate> delegate;
-(id) initViewImageVC : (NSArray *) images withSelectedIndex : (int) index;

@end
