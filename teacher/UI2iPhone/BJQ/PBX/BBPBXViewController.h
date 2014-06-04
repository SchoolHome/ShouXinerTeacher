

#import "PalmViewController.h"

@protocol ReachTouchScrollviewDelegate <NSObject>

-(void)scrollviewTouched;

@end
/*
 拍表现
 */
@interface BBPBXViewController : PalmViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,ReachTouchScrollviewDelegate>
{

}
@end



@interface ReachTouchScrollview : UIScrollView
@property (nonatomic, weak) id<ReachTouchScrollviewDelegate> touchDelegate;
@end