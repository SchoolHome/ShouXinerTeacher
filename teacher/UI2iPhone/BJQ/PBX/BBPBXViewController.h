

#import "PalmViewController.h"
#import "BBGroupModel.h"
@protocol ReachTouchScrollviewDelegate <NSObject>

-(void)scrollviewTouched;

@end
/*
 拍表现
 */
@interface BBPBXViewController : PalmViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
ReachTouchScrollviewDelegate,
UITextViewDelegate,
UIScrollViewDelegate>
{

}
@property(nonatomic,strong) BBGroupModel *currentGroup;
@end



@interface ReachTouchScrollview : UIScrollView
@property (nonatomic, weak) id<ReachTouchScrollviewDelegate> touchDelegate;
@end