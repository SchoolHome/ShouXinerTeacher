//
//  BBBasePostViewController.h
//  teacher
//
//  Created by ZhangQing on 14-10-30.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#define TABLEVIEW_SECTION_COUNT 2

#import "PalmViewController.h"

#import "UIPlaceHolderTextView.h"
#import "BBChooseImgViewInPostPage.h"

#import "BBGroupModel.h"
@class BBBasePostTableview;
typedef enum
{
    POST_TYPE_PBX = 1,
    POST_TYPE_FZY = 2,
    POST_TYPE_FTZ = 3,
    POST_TYPE_SBS = 4
}POST_TYPE;

@protocol BBBasePostTableviewTouchDelegate <NSObject>

- (void)tableviewTouched;

@end

@interface BBBasePostViewController : PalmViewController
<UITableViewDataSource,UITableViewDelegate,BBChooseImgViewInPostPageDelegate>
{
    
    
}
@property (nonatomic, readonly) BBBasePostTableview *postTableview;

@property (nonatomic, readonly) BBGroupModel *currentGroup;

@property (nonatomic, readonly) BBChooseImgViewInPostPage *chooseImageView;

@property (nonatomic, strong) NSMutableArray *attachList;
//发作业科目index
@property int selectedIndex;
//init
- (id)initWithPostType:(POST_TYPE)postPageType;

- (void) sendButtonTaped;
- (void) backToBJQRoot;

- (void)setChoosenImages:(NSArray *)images andISVideo:(BOOL)isVideo;

- (NSString *)getThingsText;
- (void)closeThingsText;

- (NSInteger)getImagesCount;
-(UIImage*)imageWithImage:(UIImage*)image;
@end

@interface BBBasePostTableview : UITableView <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<BBBasePostTableviewTouchDelegate> touchDelegate;
@end
