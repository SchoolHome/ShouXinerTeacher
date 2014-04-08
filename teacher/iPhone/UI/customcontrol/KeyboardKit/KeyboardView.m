//
//  KeyboardView.m
//  Keyboard_dev
//
//  Created by ming bright on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "KeyboardView.h"
#import "ColorUtil.h"
#import "MusicPlayerManager.h"
#import "AudioPlayerManager.h"

//// 底部按钮的高度
//#define kBottomButtonHeight (103/2)
//// 底部按钮的宽度
//#define kBottomButtonWidth  80
//// 中间表情键盘高度
//#define kEmotionViewHeight  200
//// 上方工具条的高度
#define kTopHeight          56
// 组建部分和下面按钮的总高度
//#define kMidAndBottomHeight 40.0f
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//#define kSuperViewHeight 460

@interface KeyboardView()<UIActionSheetDelegate>

-(void)sendText:(NSString *)text;

@end

@implementation KeyboardView
@synthesize delegate;
@synthesize cachedString;

+(KeyboardView *)sharedKeyboardView{
    static KeyboardView *_instance = nil;
    @synchronized(self){
        if(_instance == nil){
            NSLog(@"######################  sharedKeyboardView  ###################################");
            int y;
            if (isIPhone5) {
                y = 1136.0f/2.0f;
            }else{
                y = 960.0f/2.0f;
            }
            _instance = [[KeyboardView alloc] initWithFrame:CGRectMake(0, y - kTopHeight, 320, kTopHeight)];
            _instance.currentScreenHeight = y;
        }
    }
    return _instance;
}

-(void)closeSystemKeyboard{
    [textView resignFirstResponder];
}

-(void)show{
    //if (![self.superview isEqual:[UIApplication sharedApplication].keyWindow]) {
    
        [self removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [keyboardTopBar removeFromSuperview];
        [[UIApplication sharedApplication].keyWindow addSubview:keyboardTopBar];
    //}
    
    self.hidden = NO;
    keyboardTopBar.hidden = NO;
    [self layoutKeyboardTopBar:textView.frame.size.height];
}

-(void)showInView:(UIView *)aView{
    
    [self removeFromSuperview];
    [aView addSubview:self];
    [keyboardTopBar removeFromSuperview];
    [aView addSubview:keyboardTopBar];
    self.hidden = NO;
    keyboardTopBar.hidden = NO;
    [self layoutKeyboardTopBar:textView.frame.size.height];
}

-(void)dismiss{
    [self reset];
    self.hidden = YES;
    keyboardTopBar.hidden = YES;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
//    [self layoutKeyboardTopBar:textView.frame.size.height];
}

-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    keyboardTopBar.hidden = hidden;
}

-(void)resetFrame{ 
    // 键盘下去
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidDisappear)]) {
        [self.delegate keyboardViewDidDisappear];
    }
    
    //convertButton.isUp = YES;
    emotionButton.isUp = YES;
    //captureButton.isUp = YES;
    
    [textView resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.frame = CGRectMake(0, self.currentScreenHeight - kTopHeight, self.frame.size.width, self.frame.size.height); // 始终在下面
    [UIView commitAnimations];

}

-(UIView *)keyboardTopBar{
    return keyboardTopBar;
}
#pragma mark - set status

-(void)reset{
    
    photoSwitch.hidden = YES;
    
    petButton.enabled = YES;
    textView.text = nil;
    recordButton.hidden = YES;
    
    convertButton.isUp = YES;
    emotionButton.isUp = YES;
    captureButton.isUp = YES;
    
    
    //smallPageView.hidden = NO;
    //magicPageView.hidden = YES;
    //emojiPageView.hidden = YES;
    
    //smallPageView.currentPage = 0;
    //magicPageView.currentPage = 0;
    //emojiPageView.currentPage = 0;
    
    //emojiPageControl.currentPage = 0;
    
    //smallButton.isUp = NO;
    //magicButton.isUp = YES;
    //emojiButton.isUp = YES;
    
    self.cachedString = nil;
    
    [textView resignFirstResponder];
    self.frame = CGRectMake(0, self.currentScreenHeight - kTopHeight, self.frame.size.width, self.frame.size.height); // 始终在下面
}

-(CGFloat)currentHeight{
/*2012.8.17 高度修正为12 ZQ*/    
    return 10 + textView.frame.size.height;//kMidAndBottomHeight + 20 + textView.frame.size.height;
}

-(void)hidePhotoSwitch // 隐藏选择按钮
{
    photoSwitch.hidden = YES;
    captureButton.isUp = YES;
}

-(void)setEmotionButtonEnabled:(BOOL) enabled // 能否使用表情键盘
{
    emotionButton.enabled = enabled;
}
-(void)setPetButtonEnabled:(BOOL) enabled  // 小双能否使用
{
    petButton.enabled = enabled;
}

-(void)clearText;
{
    textView.text = @"";
    self.cachedString = nil;
}

-(void)sendText:(NSString *)text{
    textView.text = nil;
    self.cachedString = nil;
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewSendText:)]) {
        [self.delegate keyboardViewSendText:text];
    }
}

#pragma mark - top button actions

-(void)petButtonTaped:(UIButton *)sender{
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewOpenPet)]) {
        [self.delegate keyboardViewOpenPet];
    }
    
    // 键盘下去
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidDisappear)]) {
        [self.delegate keyboardViewDidDisappear];
    }
    
    photoSwitch.hidden = YES;
    
    emotionButton.isUp = YES;
    captureButton.isUp = YES;
    
    [textView resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.frame = CGRectMake(0, self.currentScreenHeight - kTopHeight, self.frame.size.width, self.frame.size.height); // 始终在下面
    [UIView commitAnimations];
}


-(void)convertButtonTaped:(UIButton *)sender{
    
    photoSwitch.hidden = YES;
    
    emotionButton.isUp = YES;
    captureButton.isUp = YES;
    
    if (convertButton.isUp) {
        
        self.cachedString = textView.text;
        
        textView.text = nil; // 先清空内容，计算高度
        // 键盘下去
        if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidDisappear)]) {
            [self.delegate keyboardViewDidDisappear];
        }
        
        
        recordButton.hidden = NO;
        [textView resignFirstResponder];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.frame = CGRectMake(0, self.currentScreenHeight - kTopHeight, self.frame.size.width, self.frame.size.height); // 始终在下面
        [UIView commitAnimations];
        
    }else {
        recordButton.hidden = YES;
        
        textView.text = self.cachedString;
        [textView becomeFirstResponder];
    }
    
    convertButton.isUp = !convertButton.isUp;
}


-(void)emotionButtonTaped:(UIButton *)sender{
    photoSwitch.hidden = YES;
    recordButton.hidden = YES;

    convertButton.isUp = YES;
    captureButton.isUp = YES;
    
    [textView resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (emotionButton.isUp) {
//        self.frame = CGRectMake(0, kSuperViewHeight-self.frame.size.height, self.frame.size.width, self.frame.size.height);
        
    }else {
        self.frame = CGRectMake(0, self.currentScreenHeight - kTopHeight, self.frame.size.width, self.frame.size.height); // 始终在下面
    }
	[UIView commitAnimations];
    
    if (emotionButton.isUp) { // 键盘起来
        if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidAppear:)]) {
            [self.delegate keyboardViewDidAppear:0];
        }
    }else {
        // 键盘下去
        if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidDisappear)]) {
            [self.delegate keyboardViewDidDisappear];
        }
    }
    emotionButton.isUp = !emotionButton.isUp;
}



-(void)captureButtonTaped:(UIButton *)sender{
    
    // 键盘下去
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidDisappear)]) {
        [self.delegate keyboardViewDidDisappear];
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相片" otherButtonTitles:@"拍照", nil];
    [sheet showInView:self.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex == 0) {
        [self photoSwitchTapedIndex:0];
    }else if (buttonIndex == 1){
        [self photoSwitchTapedIndex:1];
    }
}

-(void)photoSwitchTapedIndex:(NSInteger) index{
    
    photoSwitch.hidden = YES;
    captureButton.isUp = YES;

    switch (index) {
        case 0:
            //
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewOpenPhotoLibrary)]) {
                [self.delegate keyboardViewOpenPhotoLibrary];
            }
        }
            break;
        case 1:
            //
        {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewOpenCamera)]) {
                [self.delegate keyboardViewOpenCamera];
            }
        }
            break;
        default:
            break;
    }
}

-(void)recordBegin{
    isRecordTimeOut = NO;
    [[MusicPlayerManager sharedInstance] stop];
    [[AudioPlayerManager sharedManager] stopBackgroundMusic];
    [[AudioPlayerManager sharedManager] stopEffect];
    [micView startRecord];
}

-(void)recordEnd{

    if (isRecordTimeOut) { //自动停止
        CPLogInfo(@"##### recordDidFinish 60s time out");
    }else {
        CPLogInfo(@"##### recordDidFinish");
        [micView stopRecord];
    }
}

#pragma mark - init and layout

-(void)initTop{
    
    keyboardTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.currentScreenHeight - kTopHeight, 320, kTopHeight)];
    keyboardTopBar.backgroundColor = [UIColor clearColor];
    keyboardTopBar.userInteractionEnabled = YES;
    
    topBarBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 100)];
    topBarBack.backgroundColor = [UIColor colorWithHexString:@"D8D6CE"];//@"#f5f0e9"
    
    //topBarBack.image= [UIImage imageNamed:@"line02_im"];
    
    //    CGRect rect1 = [self convertRect:CGRectMake(0, self.frame.size.height - kMidAndBottomHeight-kTopHeight, 320, kTopHeight) toView:[UIApplication sharedApplication].keyWindow];
//    CGRect rect1 = [self convertRect:CGRectMake(0, self.frame.size.height - kMidAndBottomHeight-kTopHeight, 320, kTopHeight) toView:self.superview];
//    NSLog(@"convertRect     ======================= %f",rect1.origin.y);
//    keyboardTopBar.frame = rect1;
    /*
    textView = [[KBGrowingTextView alloc] initWithFrame:CGRectMake(50, keyboardTopBar.frame.size.height-34-6, 160, 34)];  //一行的高度 34
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
    textView.returnKeyType = UIReturnKeySend; //just as an example
    textView.font = [UIFont systemFontOfSize:14.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.enablesReturnKeyAutomatically = YES;
    
    textViewBack = [[UIImageView alloc] initWithFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width+60, textView.frame.size.height)];
    UIImage *image = [[UIImage imageNamed:@"item_im_bar_input"] stretchableImageWithLeftCapWidth:0 topCapHeight:33/2];
    textViewBack.image = image;
    
    
    textViewMask = [[UIImageView alloc] initWithFrame:CGRectMake(textView.frame.origin.x+5, textView.frame.origin.y+textView.frame.size.height, textView.frame.size.width+5+3, 5.5)];
    UIImage *image1 = [[UIImage imageNamed:@"item_im_bar_input_mask"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    textViewMask.image = image1;
    //textViewMask.backgroundColor =[UIColor colorWithHexString:@"#f5f0e9"];
    
    [keyboardTopBar addSubview:topBarBack];
    [keyboardTopBar addSubview:textViewBack];
    [keyboardTopBar addSubview:textView];
    [keyboardTopBar addSubview:textViewMask];
    
    UIImageView *topBarTop = [[UIImageView alloc] initWithFrame:CGRectMake(-50, -24, 320, 24)];
    [textView addSubview:topBarTop];
    topBarTop.image = [UIImage imageNamed:@"bg_im_bar_above"];
    
    petButton = [[KBPetButton alloc] initWithFrame:CGRectMake(6, keyboardTopBar.frame.size.height - 112/2, 87/2, 112/2)];
    [keyboardTopBar addSubview:petButton];
    [petButton addTarget:self action:@selector(petButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    recordButton = [[KBRecordButton alloc] initWithFrame:CGRectMake(50, keyboardTopBar.frame.size.height- 106/2, 365/2, 106/2)];
    [keyboardTopBar addSubview:recordButton];
    [recordButton addTarget:self action:@selector(recordBegin) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpOutside];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchCancel];
    recordButton.hidden = YES;
    
    captureButton = [[KBCaptureButton alloc] initWithFrame:CGRectMake(320 - 71/2 - 5, keyboardTopBar.frame.size.height - 71/2-5, 78/2, 71/2)];
    [keyboardTopBar addSubview:captureButton];
    [captureButton addTarget:self action:@selector(captureButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    convertButton = [[KBConvertButton alloc] initWithFrame:CGRectMake(320 - 71*2/2 - 106/2 - 5, keyboardTopBar.frame.size.height- 106/2, 92/2, 106/2)];
    [keyboardTopBar addSubview:convertButton];
    [convertButton addTarget:self action:@selector(convertButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    emotionButton = [[KBEmotionButton alloc] initWithFrame:CGRectMake(320 - 71*2/2 - 5-5, keyboardTopBar.frame.size.height - 71/2-5, 78/2, 71/2)];
    [keyboardTopBar addSubview:emotionButton];
    [emotionButton addTarget:self action:@selector(emotionButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
//    photoSwitch = [[KBPhotoSwitch alloc] initWithFrame:CGRectMake(320 - 100 - 5, kSuperViewHeight - kTopHeight-50+10, 100, 50)];
    photoSwitch.hidden = YES;
    photoSwitch.delegate = self;
    //[[UIApplication sharedApplication].keyWindow addSubview:photoSwitch];
*/
    
    textView = [[KBGrowingTextView alloc] initWithFrame:CGRectMake(50, keyboardTopBar.frame.size.height-32-6, 220, 32)]; //一行高度32
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 4;
    textView.returnKeyType = UIReturnKeySend; //just as an example
    textView.font = [UIFont systemFontOfSize:14.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor clearColor];
    textView.enablesReturnKeyAutomatically = YES;
    
    
    textViewBack = [[UIImageView alloc] initWithFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height)];
    UIImage *image = [[UIImage imageNamed:@"keyboard_text_back"] stretchableImageWithLeftCapWidth:0 topCapHeight:33/2];
    textViewBack.image = image;
    
    [keyboardTopBar addSubview:topBarBack];
    [keyboardTopBar addSubview:textViewBack];
    [keyboardTopBar addSubview:textView];
    
    recordButton = [[KBRecordButton alloc] initWithFrame:CGRectMake(89/2, keyboardTopBar.frame.size.height- 64/2, 462/2, 64/2)];
    [keyboardTopBar addSubview:recordButton];
    [recordButton addTarget:self action:@selector(recordBegin) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpOutside];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchCancel];
    recordButton.hidden = YES;
    
    captureButton = [[KBCaptureButton alloc] initWithFrame:CGRectMake(570/2, keyboardTopBar.frame.size.height - 54/2-10, 54/2, 54/2)];
    [keyboardTopBar addSubview:captureButton];
    [captureButton addTarget:self action:@selector(captureButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    convertButton = [[KBConvertButton alloc] initWithFrame:CGRectMake(7, keyboardTopBar.frame.size.height- 54/2-10, 54/2, 54/2)];
    [keyboardTopBar addSubview:convertButton];
    [convertButton addTarget:self action:@selector(convertButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    /*
    emotionButton = [[KBEmotionButton alloc] initWithFrame:CGRectMake(494/2, keyboardTopBar.frame.size.height - 62/2-10, 62/2, 62/2)];
    [keyboardTopBar addSubview:emotionButton];
    [emotionButton addTarget:self action:@selector(emotionButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    */
    //    photoSwitch = [[KBPhotoSwitch alloc] initWithFrame:CGRectMake(320 - 100 - 5, kSuperViewHeight - kTopHeight-50+10, 100, 50)];
    photoSwitch.hidden = YES;
    photoSwitch.delegate = self;
    //[[UIApplication sharedApplication].keyWindow addSubview:photoSwitch];
    [self layoutKeyboardTopBar:textView.frame.size.height];
}

-(void)layoutKeyboardTopBar:(CGFloat) height{
    //keyboardTopBar.frame =  CGRectMake(0, self.frame.size.height - kMidAndBottomHeight - (height+22), keyboardTopBar.frame.size.width, height+22);  // 22 = kTopHeight - 34 
//    CGRect rect1 = [self convertRect:CGRectMake(0, self.frame.size.height - kMidAndBottomHeight - (height+22), 320, height+22) toView:[UIApplication sharedApplication].keyWindow];
    /*
    CGRect rect1 = CGRectMake(0, self.superview.frame.size.height - (height+22), 320, height+22);
    keyboardTopBar.frame = rect1;
    
    textView.frame = CGRectMake(50, keyboardTopBar.frame.size.height-height-6+2, textView.frame.size.width, height);
    textViewBack.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width+22, textView.frame.size.height);
    textViewMask.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y+textView.frame.size.height-2, textView.frame.size.width+5+3, 5.5);
                        
    topBarBack.frame = CGRectMake(0, 15, keyboardTopBar.frame.size.width, keyboardTopBar.frame.size.height-15); // 背景
    petButton.frame = CGRectMake(6, keyboardTopBar.frame.size.height - 112/2, 87/2, 112/2);
    recordButton.frame = CGRectMake(50, keyboardTopBar.frame.size.height- 106/2-1+2, 365/2, 106/2);
    captureButton.frame = CGRectMake(320 - 71/2 - 5-1, keyboardTopBar.frame.size.height - 71/2-5-1+2, 78/2, 71/2);
    convertButton.frame = CGRectMake(320 - 71*2/2 - 106/2 - 5, keyboardTopBar.frame.size.height- 106/2-1+2, 92/2, 106/2);
    emotionButton.frame = CGRectMake(320 - 71*2/2 - 5-5-2, keyboardTopBar.frame.size.height - 71/2-5-1+2, 78/2, 71/2);
     */
    CGRect rect1 = CGRectMake(0, self.superview.frame.size.height - (height+22), 320, height+22);
    keyboardTopBar.frame = rect1;
    
    textView.frame = CGRectMake(50, keyboardTopBar.frame.size.height-height-6+2, textView.frame.size.width, height);
    textViewBack.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
    
    topBarBack.frame = CGRectMake(0, 10, keyboardTopBar.frame.size.width, keyboardTopBar.frame.size.height-10); // 背景
  //  petButton.frame = CGRectMake(6, keyboardTopBar.frame.size.height - 112/2, 87/2, 112/2);
    recordButton.frame = CGRectMake(89/2, keyboardTopBar.frame.size.height- 64/2-5-1+2, 462/2, 64/2);
    captureButton.frame = CGRectMake(570/2, keyboardTopBar.frame.size.height - 54/2-5-1+2, 54/2, 54/2);
    convertButton.frame = CGRectMake(7, keyboardTopBar.frame.size.height- 54/2-5-1+2, 54/2, 54/2);
  //  emotionButton.frame = CGRectMake(494/2, keyboardTopBar.frame.size.height - 62/2-5-1+2, 62/2, 62/2);
}

-(void)initSmallView{
    if (!smallPageView) {
//        smallPageView = [[KBScrollView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kBottomButtonHeight - kEmotionViewHeight, 320, kEmotionViewHeight)];
//        smallPageView.backgroundColor = [UIColor clearColor];
//        smallPageView.delegate = self;
//        [self addSubview:smallPageView];
//        smallPageView.currentPage = 0;
//        smallPageView.tag = KB_SCROLL_VIEW_TAG_SAMLL;
//        
//        smallPageView.hidden = YES;
    }
}
-(void)initMagicView{
    if (!magicPageView) {
//        magicPageView = [[KBScrollView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kBottomButtonHeight - kEmotionViewHeight, 320, kEmotionViewHeight)];
//        magicPageView.backgroundColor = [UIColor clearColor];
//        magicPageView.delegate = self;
//        [self addSubview:magicPageView];
//        magicPageView.currentPage = 0;
//        magicPageView.tag = KB_SCROLL_VIEW_TAG_MAGIC;
//        
//        magicPageView.hidden = NO;
    }
}
-(void)initEmojiView{
    if (!emojiPageView) {
//        emojiPageView = [[KBScrollView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kBottomButtonHeight - kEmotionViewHeight, 320, kEmotionViewHeight)];
//        emojiPageView.backgroundColor = [UIColor clearColor];
//        emojiPageView.delegate = self;
//        [self addSubview:emojiPageView];
//        emojiPageView.currentPage = 2;   // 预加载
//        emojiPageView.currentPage = 0;
//        emojiPageView.tag = KB_SCROLL_VIEW_TAG_EMOJI;
//        
//        emojiPageView.hidden = YES;
    }
}

-(void)initMiddle{
//    [self performSelector:@selector(initSmallView) withObject:nil afterDelay:0.1];
//    [self performSelector:@selector(initMagicView) withObject:nil afterDelay:0.1];
//    [self performSelector:@selector(initEmojiView) withObject:nil afterDelay:0.2];
}

-(void)initBottom{
    
//    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kMidAndBottomHeight, 320, kMidAndBottomHeight)];
//    [self addSubview:background];
//    background.image = [UIImage imageNamed:@"bg_im_emotion"];
//    [self sendSubviewToBack:background];
//    
//    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height -kBottomButtonHeight-5 , 320, 1)];
//    [self addSubview:line];
//    line.image = [UIImage imageNamed:@"line02_im"];
//    [self sendSubviewToBack:line];
//
//    smallPageControl= [[KBPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -kBottomButtonHeight - 17, 320, 17)];
//    smallPageControl.backgroundColor = [UIColor clearColor];
//    smallPageControl.numberOfPages = 1;
//    smallPageControl.currentPage = 1;
//    [self addSubview:smallPageControl];
//    
//    magicPageControl= [[KBPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -kBottomButtonHeight - 17, 320, 17)];
//    magicPageControl.backgroundColor = [UIColor clearColor];
//    magicPageControl.numberOfPages = 1;
//    magicPageControl.currentPage = 1;
//    [self addSubview:magicPageControl];
//    
//    emojiPageControl= [[KBPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -kBottomButtonHeight - 17, 320, 17)];
//    emojiPageControl.backgroundColor = [UIColor clearColor];
//    emojiPageControl.numberOfPages = 3;
//    emojiPageControl.currentPage = 1;
//    [self addSubview:emojiPageControl];
//    
//    smallPageControl.hidden = YES;
//    magicPageControl.hidden = NO;
//    emojiPageControl.hidden = YES;
//    
//    
//    
//    magicButton = [[KBMagicButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height-kBottomButtonHeight, kBottomButtonWidth, kBottomButtonHeight)];
//    [self addSubview:magicButton];
//    [magicButton addTarget:self action:@selector(magicButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
//    magicButton.isUp = NO;
//    
//    smallButton = [[KBSmallButton alloc] initWithFrame:CGRectMake(kBottomButtonWidth, self.frame.size.height-kBottomButtonHeight, kBottomButtonWidth, kBottomButtonHeight)];
//    [self addSubview:smallButton];
//    [smallButton addTarget:self action:@selector(smallButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    emojiButton = [[KBEmojiButton alloc] initWithFrame:CGRectMake(kBottomButtonWidth*2 , self.frame.size.height-kBottomButtonHeight, kBottomButtonWidth, kBottomButtonHeight)];
//    [self addSubview:emojiButton];
//    [emojiButton addTarget:self action:@selector(emojiButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    UIImageView *sendBack = [[UIImageView alloc] initWithFrame:CGRectMake(kBottomButtonWidth*3, self.frame.size.height-kBottomButtonHeight, kBottomButtonWidth, kBottomButtonHeight)];
//    sendBack.image = [UIImage imageNamed:@"btn_im_emotion_tab02"];
//    [self addSubview:sendBack];
//    sendButton  = [[KBSendButton alloc] initWithFrame:CGRectMake(kBottomButtonWidth*3, self.frame.size.height-kBottomButtonHeight+7, kBottomButtonWidth, kBottomButtonHeight-10)];
//    [self addSubview:sendButton];
//    [sendButton addTarget:self action:@selector(sendButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.backgroundColor = [UIColor colorWithHexString:@"#f9f6f1"];
        self.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillHide:) 
													 name:UIKeyboardWillHideNotification 
												   object:nil];	
        
        
        
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"kbemoji.plist" ofType:nil];
        emojis = [[NSArray alloc] initWithContentsOfFile:path];
        escapeChars = [[NSMutableArray alloc] init];
        
        for (NSString *str in emojis) {
            [escapeChars addObject:[[str componentsSeparatedByString:@","] lastObject]];
        }
        
        [self initTop];
        [self initMiddle];
        [self performSelector:@selector(initBottom) withObject:nil afterDelay:0.1];
        //[self initBottom];
        
        micView = [[ARMicView alloc] initWithCenter:CGPointMake(160, 240)];
        micView.delegate = self;
        
        
        [[CPUIModelManagement sharedInstance] addObserver:self forKeyPath:@"petDataDict" options:0 context:NULL];
        
     }
    return self;
}

- (void)dealloc{
    [[CPUIModelManagement sharedInstance] removeObserver:self forKeyPath:@"petDataDict"];
}

#pragma mark -  petDataDict observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"petDataDict"]){
        NSDictionary * dataDict = [CPUIModelManagement sharedInstance].petDataDict;
        NSNumber * typeNum = [dataDict valueForKey:pet_datachange_type];
        NSNumber * resultCodeNum = [dataDict valueForKey:pet_datachange_result];
        NSNumber * categoryNum = [dataDict valueForKey:pet_datachange_category];
        NSString * petIDString = [dataDict valueForKey:pet_datachange_petid];
        NSString * resourceIDString = [dataDict valueForKey:pet_datachange_id];
        
        
        if([categoryNum integerValue] == K_PET_DATA_TYPE_MAGIC){
            //
            CPUIModelPetMagicAnim *anim = [[CPUIModelManagement sharedInstance] magicObjectOfID:resourceIDString fromPet:petIDString];
            
            NSInteger typeInt = [typeNum integerValue];
            if(typeInt == PET_DATACHANGE_TYPE_ADD_RES || typeInt == PET_DATACHANGE_TYPE_UPDATE_RES){

                if([resultCodeNum integerValue] == PET_DATACHANGE_RESULT_SUC){
                    // 下载成功
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMagicItemDataDownloadFinished object:anim];
                }
                else if([resultCodeNum integerValue] == PET_DATACHANGE_RESULT_FAIL){
                    // 下载失败
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMagicItemDataDownloadFailed object:anim];
                }
            
            }else if(typeInt == PET_DATACHANGE_TYPE_DOWNLOADING){
                // 正在下载
                [[NSNotificationCenter defaultCenter] postNotificationName:kMagicItemDataDownloadStarted object:anim];
            }
        }
        if([typeNum integerValue] == PET_DATACHANGE_TYPE_PETSYS_INITIALIZED){
            // 切换pet 重新初始化
            [magicPageView reloadData];
        }
    }
}

#pragma mark -  keyboard notification

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{

    
    if ([textView isFirstResponder]) {  // 过滤
        // get keyboard size and loctaion
        CGRect keyboardBounds;
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        // Need to translate the bounds to account for rotation.
        keyboardBounds = [self convertRect:keyboardBounds toView:nil];
        
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        self.keyboardTopBar.frame = CGRectMake(0, self.superview.frame.size.height-keyboardBounds.size.height-textView.frame.size.height-22.0f, self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
    }

}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if ([textView isFirstResponder]) {  // 过滤
        NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        self.keyboardTopBar.frame = CGRectMake(0, self.superview.frame.size.height-textView.frame.size.height-22.0f, self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
    }
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - KBGrowingTextViewDelegate

- (void)growingTextViewDidBeginEditing:(KBGrowingTextView *)growingTextView{
    photoSwitch.hidden = YES;
    
    //convertButton.isUp = YES;
    emotionButton.isUp = YES;
    captureButton.isUp = YES;
    
    
    // 键盘起来
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDidAppear:)]) {
        [self.delegate keyboardViewDidAppear:0];
    }
    
}
- (void)growingTextViewDidEndEditing:(KBGrowingTextView *)growingTextView{
}

- (BOOL)growingTextView:(KBGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    
    NSLog(@"text  === %@",text);
    
    int length = [textView.text length];
    if(length > 208){
        NSString * endTextString = [textView.text substringToIndex:208];
        textView.text = endTextString;
    }
    
    
    if ([text isEqualToString:@"\n"]) {
        // 发送
        [self sendText:textView.text];
        return NO;
    }
    return YES;
}


- (void)growingTextView:(KBGrowingTextView *)growingTextView willChangeHeight:(float)height
{
/*
    NSLog(@"%f",height);
    CGRect rect1;
    if (growingTextView.frame.size.height < height) {
        rect1 = CGRectMake(0, self.keyboardTopBar.frame.origin.y - (height - growingTextView.frame.size.height), 320, height+22);
    }else{
        rect1 = CGRectMake(0, self.keyboardTopBar.frame.origin.y + (growingTextView.frame.size.height - height), 320, height+22);
    }
    
    keyboardTopBar.frame = rect1;
    textView.frame = CGRectMake(50, keyboardTopBar.frame.size.height-height-6+2, textView.frame.size.width, height);
    textViewBack.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width+22, textView.frame.size.height);
    textViewMask.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y+textView.frame.size.height-2, textView.frame.size.width+5+3, 5.5);
    
    topBarBack.frame = CGRectMake(0, 15, keyboardTopBar.frame.size.width, keyboardTopBar.frame.size.height-15); // 背景
    petButton.frame = CGRectMake(6, keyboardTopBar.frame.size.height - 112/2, 87/2, 112/2);
    recordButton.frame = CGRectMake(50, keyboardTopBar.frame.size.height- 106/2-1+2, 365/2, 106/2);
    captureButton.frame = CGRectMake(320 - 71/2 - 5-1, keyboardTopBar.frame.size.height - 71/2-5-1+2, 78/2, 71/2);
    convertButton.frame = CGRectMake(320 - 71*2/2 - 106/2 - 5, keyboardTopBar.frame.size.height- 106/2-1+2, 92/2, 106/2);
    emotionButton.frame = CGRectMake(320 - 71*2/2 - 5-5-2, keyboardTopBar.frame.size.height - 71/2-5-1+2, 78/2, 71/2);
 */
    CGRect rect1;
    if (growingTextView.frame.size.height < height) {
        rect1 = CGRectMake(0, self.keyboardTopBar.frame.origin.y - (height - growingTextView.frame.size.height), 320, height+22);
    }else{
        rect1 = CGRectMake(0, self.keyboardTopBar.frame.origin.y + (growingTextView.frame.size.height - height), 320, height+22);
    }
    keyboardTopBar.frame = rect1;
    textView.frame = CGRectMake(50, keyboardTopBar.frame.size.height-height-6+2, textView.frame.size.width, height);
    textViewBack.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
    
    topBarBack.frame = CGRectMake(0, 10, keyboardTopBar.frame.size.width, keyboardTopBar.frame.size.height-10); // 背景
    //  petButton.frame = CGRectMake(6, keyboardTopBar.frame.size.height - 112/2, 87/2, 112/2);
    recordButton.frame = CGRectMake(89/2, keyboardTopBar.frame.size.height- 64/2-5-1+2, 462/2, 64/2);
    captureButton.frame = CGRectMake(570/2, keyboardTopBar.frame.size.height - 54/2-5-1+2, 54/2, 54/2);
    convertButton.frame = CGRectMake(7, keyboardTopBar.frame.size.height- 54/2-5-1+2, 54/2, 54/2);
  //  emotionButton.frame = CGRectMake(494/2, keyboardTopBar.frame.size.height - 62/2-5-1+2, 62/2, 62/2);
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - KBScrollViewDelegate

- (NSUInteger)numberOfPagesInPagedView:(KBScrollView *)pagedView{
    
    int pages = 1;
    
    switch (pagedView.tag) {
        case KB_SCROLL_VIEW_TAG_SAMLL:
            
            break;
        case KB_SCROLL_VIEW_TAG_MAGIC:
            break;
        case KB_SCROLL_VIEW_TAG_EMOJI:
            pages = 3;
            break;
        default:
            break;
    }
    
    if (1==pages) { // 只有一页不让滑动
        pagedView.scrollEnabled = NO;
    }
    return pages;
}

- (UIView *)pagedView:(KBScrollView *)pagedView viewForPageAtIndex:(NSUInteger)index{
    
    switch (pagedView.tag) {
        case KB_SCROLL_VIEW_TAG_SAMLL:
        {
            KBSmallView *_smallView = (KBSmallView *) [pagedView dequeueReusableViewWithTag:0];
            if (!_smallView) {
                
                NSLog(@"_smallView");
                
                _smallView = [[KBSmallView alloc] initWithFrame:pagedView.frame];
                _smallView.delagate = self;
                _smallView.userInteractionEnabled = YES;
                
            }
            _smallView.backgroundColor = [UIColor clearColor];
        
            //NSArray *anim = [[CPUIModelManagement sharedInstance] allSmallAnimObjects];
            for(CPUIModelPetSmallAnim * smallAnim in [[CPUIModelManagement sharedInstance] allSmallAnimObjects]){
                [escapeChars addObject:smallAnim.escapeChar];
            }
            
            
            
            NSArray *smallResArray = [NSArray arrayWithObjects:@"xiaohaha", @"huaixiao",@"baibai",@"bishi",@"bizui",@"daku",@"fennu",
                                      @"haixiu",@"han",@"heng",@"jingya",@"kunle",@"beida",@"se",
                                      @"taiweiqu",@"touxiao",@"tu",@"zhuakuang",@"zhuangku",@"zuoguilian",
                                      nil];
            
            NSMutableArray * smallModelArray = [[NSMutableArray alloc] init];
            
            
            for (NSString *resID in smallResArray) {
                CPUIModelPetSmallAnim *anim = [[CPUIModelManagement sharedInstance] smallAnimObectOfID:resID];
                
                if (anim) {
                    [smallModelArray addObject:anim];
                }
            }
            
            /*
            int smallIndex_ = 0;
            for(smallIndex_ = 0;smallIndex_ < 20;smallIndex_ ++ ){
                [smallModelArray addObject:@" "];
            }
            
            
            
            for(CPUIModelPetSmallAnim * smallAnim in [[CPUIModelManagement sharedInstance] allSmallAnimObjects]){
                if([smallAnim.resourceID isEqualToString:@"xiaohaha"]){
                    [smallModelArray replaceObjectAtIndex:0 withObject:smallAnim];
                }                
                else if([smallAnim.resourceID isEqualToString:@"huaixiao"]){
                    [smallModelArray replaceObjectAtIndex:1 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"baibai"]){  
                    [smallModelArray replaceObjectAtIndex:2 withObject:smallAnim];
                }                
                else if([smallAnim.resourceID isEqualToString:@"bishi"]){ 
                    [smallModelArray replaceObjectAtIndex:3 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"bizui"]){
                    [smallModelArray replaceObjectAtIndex:4 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"daku"]){
                    [smallModelArray replaceObjectAtIndex:5 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"fennu"]){
                    [smallModelArray replaceObjectAtIndex:6 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"haixiu"]){
                    [smallModelArray replaceObjectAtIndex:7 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"han"]){
                    [smallModelArray replaceObjectAtIndex:8 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"heng"]){
                    [smallModelArray replaceObjectAtIndex:9 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"jingya"]){
                    [smallModelArray replaceObjectAtIndex:10 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"kunle"]){
                    [smallModelArray replaceObjectAtIndex:11 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"beida"]){
                    [smallModelArray replaceObjectAtIndex:12 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"se"]){
                    [smallModelArray replaceObjectAtIndex:13 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"taiweiqu"]){
                    [smallModelArray replaceObjectAtIndex:14 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"touxiao"]){
                    [smallModelArray replaceObjectAtIndex:15 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"tu"]){
                    [smallModelArray replaceObjectAtIndex:16 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"zhuakuang"]){
                    [smallModelArray replaceObjectAtIndex:17 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"zhuangku"]){
                    [smallModelArray replaceObjectAtIndex:18 withObject:smallAnim];
                }
                else if([smallAnim.resourceID isEqualToString:@"zuoguilian"]){
                    [smallModelArray replaceObjectAtIndex:19 withObject:smallAnim];
                }
            }
            */
            
            [_smallView setSmallData:smallModelArray];
            
            return _smallView;
        }
            break;
        case KB_SCROLL_VIEW_TAG_MAGIC:
        {
            
            KBMagicView *_magicView = (KBMagicView *) [pagedView dequeueReusableViewWithTag:0];
            if (!_magicView) {
                
                NSLog(@"_magicView");
                
                _magicView = [[KBMagicView alloc] initWithFrame:pagedView.frame];
                _magicView.userInteractionEnabled = YES;
                _magicView.delagate = self;
                //[_magicView setMagicData:nil];
                
            }
            
           // NSArray *anim = [[CPUIModelManagement sharedInstance] allMagicObjects];

            NSMutableArray *magicModelArray = [[NSMutableArray alloc] init];
            
            NSArray *resourceIDArray = [NSArray arrayWithObjects:
                                        @"psdh",
                                        @"qiaoqiaoni",
                                        @"baobao",
                                        @"xianyinqin",
                                        @"anweini",
                                        @"tiaodou",
                                        @"jiaban", nil];
            
            for (NSString *resID in resourceIDArray) {
                CPUIModelPetMagicAnim *anim = [[CPUIModelManagement sharedInstance] magicObjectOfID:resID fromPet:@"pet_default"];
                if (anim) {
                    [magicModelArray addObject:anim];
                }
            }
            
            
            /*
            int tempIndex_ = 0;
            for(tempIndex_ = 0;tempIndex_<7;tempIndex_++){
                [magicModelArray addObject:@" "];
            }
            */
            
            /*
            for(CPUIModelPetMagicAnim * magicAnim in [[CPUIModelManagement sharedInstance] allMagicObjects]){
                // CPLogInfo(@"maigcname:%@",magicAnim.resourceID);
                
                if([magicAnim.resourceID isEqualToString:@"psdh"]){ 
                    [magicModelArray replaceObjectAtIndex:0 withObject:magicAnim];
                }
                else if([magicAnim.resourceID isEqualToString:@"qiaoqiaoni"]){ 
                    [magicModelArray replaceObjectAtIndex:1 withObject:magicAnim];
                }
                else if([magicAnim.resourceID isEqualToString:@"baobao"]){ 
                    [magicModelArray replaceObjectAtIndex:2 withObject:magicAnim];
                }
                else if([magicAnim.resourceID isEqualToString:@"xianyinqin"]){ 
                    [magicModelArray replaceObjectAtIndex:3 withObject:magicAnim];
                }
                else if([magicAnim.resourceID isEqualToString:@"anweini"]){ 
                    [magicModelArray replaceObjectAtIndex:4 withObject:magicAnim];
                }
                else if([magicAnim.resourceID isEqualToString:@"tiaodou"]){ 
                    [magicModelArray replaceObjectAtIndex:5 withObject:magicAnim];
                }
                else if([magicAnim.resourceID isEqualToString:@"jiaban"]){ 
                    [magicModelArray replaceObjectAtIndex:6 withObject:magicAnim];
                } 
                
            }
            */
            //[_magicView setMagicData:anim];
            [_magicView setMagicData:magicModelArray];
            
            return _magicView;
             
        }
            break;
        case KB_SCROLL_VIEW_TAG_EMOJI:
        {
            KBEmojiView *_emojiView = (KBEmojiView *) [pagedView dequeueReusableViewWithTag:0];
            if (!_emojiView) {
                
                NSLog(@"_emojiView");
                
                _emojiView = [[KBEmojiView alloc] initWithFrame:pagedView.frame];
                _emojiView.delagate = self;
                _emojiView.userInteractionEnabled = YES;
                
            }
            
            _emojiView.backgroundColor = [UIColor clearColor];
            
            if (index*27+27<=[emojis count]) {
                NSArray *array = [emojis subarrayWithRange:NSMakeRange(index*27, 27)];
                
                [_emojiView setEmojiData:array];
            }
            return _emojiView;
        }
            break;
        default:
            break;
    }
	return nil;
}

- (void)pagedView:(KBScrollView *)pagedView didScrollToPageAtIndex:(NSUInteger)index{
    switch (pagedView.tag) {
        case KB_SCROLL_VIEW_TAG_SAMLL:
        {
            [smallPageControl setCurrentPage:index];
        }
            break;
        case KB_SCROLL_VIEW_TAG_MAGIC:
        {
            [magicPageControl setCurrentPage:index];
        }
            break;
        case KB_SCROLL_VIEW_TAG_EMOJI:
        {
            //NSLog(@"  index  %d",index  );
            [emojiPageControl setCurrentPage:index];

        }
            break;
        default:
            break;
    }
}
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - KBSmallViewDelegate

-(void)smallTaped:(KBSmallItem *)sender{
    
    textView.text = [NSString stringWithFormat:@"%@%@",textView.text,sender.smallItemData.escapeChar];
    
    
    int length = [textView.text length];
    if(length > 208){
        NSString * endTextString = [textView.text substringToIndex:208];
        textView.text = endTextString;
    }
    
    
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length,0)];
}

-(void)smallDeleteTaped:(UIButton *)sender{
    
    if ([textView.text length]>0) {
        BOOL hasSuffix = NO;
        for ( NSString *str in escapeChars) {
            if ([textView.text hasSuffix:str]) {
                textView.text = [textView.text substringToIndex:[textView.text length]-[str length]];
                hasSuffix = YES;
                break;
            }
        }
        if (!hasSuffix) {
            textView.text = [textView.text substringToIndex:[textView.text length]-1];
        }
    }
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length,0)];
}


#pragma mark - KBMagicViewDelegate
-(void)magicTaped:(KBMagicItem *)sender{
    if (sender.isAvailable) {
        emotionButton.isUp = YES;
        
        // 发送
        if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewSendMagic:ofPet:)]) {
            [self.delegate keyboardViewSendMagic:[sender.magicItemData resourceID] ofPet:[sender.magicItemData petID]];
        }
        // 键盘对画
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.frame = CGRectMake(0, self.currentScreenHeight-kTopHeight, self.frame.size.width, self.frame.size.height); // 始终在下面
        [UIView commitAnimations];
        
    }else {
        // 下载
        
        if (sender.magicItemData.downloadStatus == K_PETRES_DOWNLOD_STATUS_DOWNLOADING) { // 正在下载
        }else { //开始下载
            //[[CPUIModelManagement sharedInstance] downloadPetRes:sender.magicItemData.resourceID ofPet:sender.magicItemData.petID];
            
            if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDownloadMagic:ofPet:)]) {
                [self.delegate keyboardViewDownloadMagic:sender.magicItemData.resourceID ofPet:sender.magicItemData.petID];
            }
        }
    }
}

-(void)extraTaped:(UIButton *)sender{
    // 
    //[[CPUIModelManagement sharedInstance] updatePetResOfPet:@"pet_default"];
    
    
     // 统计下载总量
    int downloadCount = 0;
    CGFloat downloadSize = 0.0;
    
    for (CPUIModelPetMagicAnim *anim in [[CPUIModelManagement sharedInstance] allMagicObjects]) {
        if (![anim isAvailable]) {  // 需要下载的
            downloadCount = downloadCount +1;
            downloadSize = downloadSize + [[anim size] intValue];
        }
    }

    if (0==downloadCount) {  // 全部下载完毕
       if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewNeedMoreAlert)]) {
            [self.delegate keyboardViewNeedMoreAlert];
        }
    }else {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewDownloadCount:size:)]) {
            [self.delegate keyboardViewDownloadCount:downloadCount size:downloadSize];
        }
    }
}



#pragma mark - KBEmojiViewDelegate
-(void)emojiTaped:(KBEmojiItem *)sender{
    
    textView.text = [NSString stringWithFormat:@"%@%@",textView.text,sender.nativeEmoji];
    
    int length = [textView.text length];
    if(length > 208){
        NSString * endTextString = [textView.text substringToIndex:length - [sender.nativeEmoji length]];  // 去掉最后一个完整的emoji
        textView.text = endTextString;
    }
    
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length,0)];
}
-(void)emojiDeleteTaped:(KBEmojiItem *)sender{
    
    if ([textView.text length]>0) {
        
        BOOL hasSuffix = NO;
        for ( NSString *str in escapeChars) {
            if ([textView.text hasSuffix:str]) {
                textView.text = [textView.text substringToIndex:[textView.text length]-[str length]];
                hasSuffix = YES;
                break;
            }
        }
        if (!hasSuffix) {
            textView.text = [textView.text substringToIndex:[textView.text length]-1];
        }
    }
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length,0)];
}


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


#pragma mark -
#pragma mark MicMete delegate

// 开始
-(void)arMicViewRecordDidStarted:(id) arMicView_{
    CPLogInfo(@"arMicViewRecordDidStarted");
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewRecordDidStarted:)]) {
        [self.delegate keyboardViewRecordDidStarted:arMicView_];
    }
}

// 录音太短
-(void)arMicViewRecordTooShort:(id) arMicView_{
    CPLogInfo(@"arMicViewRecordTooShort");
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewRecordTooShort:)]) {
        [self.delegate keyboardViewRecordTooShort:arMicView_];
    }

}

// 正确录音
-(void)arMicViewRecordDidEnd:(id) arMicView_ pcmPath:(NSString *)pcmPath_ length:(CGFloat) audioLength_{
    CPLogInfo(@"arMicViewRecordDidEnd");
    
    isRecordTimeOut = YES;
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewRecordDidEnd:pcmPath:length:)]) {
        [self.delegate keyboardViewRecordDidEnd:arMicView_ pcmPath:pcmPath_ length:audioLength_];
    }
    
}

// 录音转码失败或者被中断
-(void)arMicViewRecordErrorDidOccur:(id) arMicView_ error:(NSError *)error_{
    CPLogInfo(@"arMicViewRecordErrorDidOccur");
    //[[HPTopTipView shareInstance] showMessage:@"录音失败！"];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(keyboardViewRecordErrorDidOccur:error:)]) {
        [self.delegate keyboardViewRecordErrorDidOccur:arMicView_ error:error_];
    }
}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

#pragma mark - bottom  button actions
-(void)smallButtonTaped:(id)sender{
    
    smallPageView.hidden = NO;
    magicPageView.hidden = YES;
    emojiPageView.hidden = YES;
    
    smallPageControl.hidden = NO;
    magicPageControl.hidden = YES;
    emojiPageControl.hidden = YES;
    
    smallButton.isUp = NO;
    magicButton.isUp = YES;
    emojiButton.isUp = YES;
}

-(void)magicButtonTaped:(id)sender{
    
    smallPageView.hidden = YES;
    magicPageView.hidden = NO;
    emojiPageView.hidden = YES;
    
    smallPageControl.hidden = YES;
    magicPageControl.hidden = NO;
    emojiPageControl.hidden = YES;
    
    smallButton.isUp = YES;
    magicButton.isUp = NO;
    emojiButton.isUp = YES;
}

-(void)emojiButtonTaped:(id)sender{
    
    smallPageView.hidden = YES;
    magicPageView.hidden = YES;
    emojiPageView.hidden = NO;
    
    smallPageControl.hidden = YES;
    magicPageControl.hidden = YES;
    emojiPageControl.hidden = NO;
    
    smallButton.isUp = YES;
    magicButton.isUp = YES;
    emojiButton.isUp = NO;
    
}

-(void)sendButtonTaped:(id)sender{
    [self sendText:textView.text];
}

@end
