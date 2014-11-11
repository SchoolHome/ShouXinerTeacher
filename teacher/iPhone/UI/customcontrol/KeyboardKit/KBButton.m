//
//  KBButton.m
//  Keyboard_dev
//
//  Created by ming bright on 12-8-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KBButton.h"
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
@implementation KBButton
@synthesize isUp = _isUp;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setIsUp:YES];
    }
    return self;
}


-(void)setIsUp:(BOOL)isUp_{
    _isUp = isUp_;
    
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
#pragma mark - 工具条按钮

@implementation KBPetButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundImage:[UIImage imageNamed:@"icon_im_ss_onbar"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"icon_im_ss_press_onbar"] forState:UIControlStateHighlighted];
    }
    return self;
}


-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBConvertButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
    /*
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_say"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_say_press"] forState:UIControlStateHighlighted];
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_text"] forState:UIControlStateNormal]; 
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_text_hover"] forState:UIControlStateHighlighted];
    }
    */
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"t_voice"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"t_voice_press"] forState:UIControlStateHighlighted];
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"t_voice"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"t_voice_press"] forState:UIControlStateHighlighted];
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBEmotionButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
    
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_face"] forState:UIControlStateNormal]; 
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_face_press"] forState:UIControlStateNormal]; 
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBCaptureButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
    /*
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_camera"] forState:UIControlStateNormal]; 
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_camera_press"] forState:UIControlStateNormal]; 
    }
    */
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"t_pic"] forState:UIControlStateNormal];
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"t_pic_press"] forState:UIControlStateNormal];
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBRecordButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        /*
        [self setBackgroundImage:[UIImage imageNamed:@"item_im_speak"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"item_im_speak_hover"] forState:UIControlStateHighlighted];
         */
        [self setBackgroundImage:[UIImage imageNamed:@"button_talk"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"button_talk_press"] forState:UIControlStateHighlighted];
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - 底部切换按钮

@implementation KBSmallButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self setTitle:@"小表情" forState:UIControlStateNormal];
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
    
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateHighlighted]; 
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02press"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02press"] forState:UIControlStateHighlighted]; 
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBMagicButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self setTitle:@"魔法表情" forState:UIControlStateNormal];
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
    
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateHighlighted]; 
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02press"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02press"] forState:UIControlStateHighlighted]; 
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBEmojiButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
        [self setTitle:@"Emoji" forState:UIControlStateNormal];
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
    
    if (_isUp) {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateHighlighted]; 
    }else {
        //
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02press"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02press"] forState:UIControlStateHighlighted]; 
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

@implementation KBSendButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundImage:[UIImage imageNamed:@"btn_sent_orange"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_sent_orange_press"] forState:UIControlStateHighlighted];
        
        //[self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateNormal];
        //[self setBackgroundImage:[UIImage imageNamed:@"btn_im_emotion_tab02"] forState:UIControlStateHighlighted];
        
        [self setTitle:@"发送" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
    }
    return self;
}

-(void)setIsUp:(BOOL)isUp_{
    [super setIsUp:isUp_];
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


@implementation KBPhotoSwitch 
@synthesize delegate;
@synthesize selectedSegmentIndex = _selectedSegmentIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _selectedSegmentIndex = 0;
        
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton setFrame:CGRectMake(0, 0, 50, 50)];
        [_photoButton setImage:[UIImage imageNamed:@"float_im_camera_left"] forState:UIControlStateNormal];
        [_photoButton setImage:[UIImage imageNamed:@"float_im_camera_left_press"] forState:UIControlStateHighlighted];
        [_photoButton addTarget:self action:@selector(photoButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setFrame:CGRectMake(50, 0, 50, 50)];
        [_cameraButton setImage:[UIImage imageNamed:@"float_im_camera_right"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"float_im_camera_right_press"] forState:UIControlStateHighlighted];
        [_cameraButton addTarget:self action:@selector(cameraButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_photoButton];
        [self addSubview:_cameraButton];
    }
    return self;
}


-(void)photoButtonTaped:(id)sender{
    _selectedSegmentIndex = 0;
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(photoSwitchTapedIndex:)]) {
        [self.delegate photoSwitchTapedIndex:_selectedSegmentIndex];
    }
}

-(void)cameraButtonTaped:(id)sender{
    _selectedSegmentIndex = 1;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(photoSwitchTapedIndex:)]) {
        [self.delegate photoSwitchTapedIndex:_selectedSegmentIndex];
    }
}

@end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
