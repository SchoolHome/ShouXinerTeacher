//
//  KBButton.h
//  Keyboard_dev
//
//  Created by ming bright on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface KBButton : UIButton
{
    BOOL _isUp;   // 按下状态
}

@property (nonatomic, assign) BOOL isUp;

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - 工具条按钮

@interface KBPetButton : KBButton
{
}
@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


@interface KBConvertButton : KBButton
{
}
@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface KBEmotionButton : KBButton
{
}
@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface KBCaptureButton : KBButton
{
    
}
@end


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface KBRecordButton : KBButton
{
    
}
@end


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - 底部切换按钮

@interface KBSmallButton : KBButton
{
    
}
@end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface KBMagicButton : KBButton
{
    
}
@end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@interface KBEmojiButton : KBButton
{
    
}
@end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


@interface KBSendButton : KBButton
{
    
}
@end
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@protocol KBPhotoSwitchDelegate <NSObject>
-(void)photoSwitchTapedIndex:(NSInteger) index;
@end


@interface KBPhotoSwitch : UIView
{ 
    NSInteger _selectedSegmentIndex;
    
    UIButton * _photoButton;
    UIButton * _cameraButton;
}
@property(nonatomic,assign) id<KBPhotoSwitchDelegate> delegate;
@property(nonatomic,assign) NSInteger selectedSegmentIndex;

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////