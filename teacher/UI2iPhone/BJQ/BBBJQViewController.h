
#import "PalmViewController.h"
#import "BBLinkTableViewCell.h"
#import "BBWorkTableViewCell.h"
#import "BBImageTableViewCell.h"
#import "BBFZYViewController.h"

#import "BBBJDropdownView.h"
#import "BBFSDropdownView.h"


#import "BBInputView.h"
#import "BBGroupModel.h"

#import "SVPullToRefresh.h"
#import "EGOImageView.h"

#import "MessagePictrueViewController.h"

typedef enum{
    TopicLoadStatusRefresh, // 刷新
    TopicLoadStatusAppend,  // 追加
} TopicLoadStatus;

@interface BBBJQViewController : PalmViewController<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIActionSheetDelegate,
BBBJDropdownViewDelegate,
BBFSDropdownViewDelegate,
BBBaseTableViewCellDelegate,
BBInputViewDelegate,
UserMessageImageDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
{
    UIButton *titleButton;
    EGOImageView *avatar;
    OHAttributedLabel *point;
    UITableView *bjqTableView;
    
    BBBJDropdownView *bjDropdownView;
    BBFSDropdownView *fsDropdownView;
    
    BBInputView *inputBar;
    
    BOOL hasNew;
    
    int notifyCount;
    UIButton *copyContentButton;
}

@property(nonatomic,strong) BBGroupModel *currentGroup;
@property(nonatomic) TopicLoadStatus loadStatus;
@property(nonatomic,strong) NSMutableArray *allTopicList;
@property BOOL isLoading;
@property (nonatomic,strong) NSString *webUrl;
@property (nonatomic,strong) NSString *imageUrl;
@end
