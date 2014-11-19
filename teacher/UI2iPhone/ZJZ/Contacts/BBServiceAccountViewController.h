//
//  BBServiceAccountViewController.h
//  teacher
//
//  Created by ZhangQing on 14-11-19.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmViewController.h"

#import "CPDBModelNotifyMessage.h"
@class ServiceItem;

@protocol ServiceItemDelegate <NSObject>

@required
- (void)itemTappedWithRow:(NSInteger)row andIndex:(NSInteger)index;

@end

@interface BBServiceAccountViewController : PalmViewController<ServiceItemDelegate>

- (id)initWithServiceItems:(NSArray *)items;

@end


#define ItemHeight 130.f

#define ItemImageWidht 80.f
#define ItemCount 3

#import "EGOImageButton.h"
@interface ServiceItem : UIView

@property (nonatomic, strong)EGOImageButton *itemHead;
@property (nonatomic, strong)UILabel *itemTitle;
@property (nonatomic)NSInteger itemRow;
@property (nonatomic)NSInteger itemIndex;
@property (nonatomic, weak)id<ServiceItemDelegate> delegate;

- (void)setContent:(CPDBModelNotifyMessage *)message;

@end