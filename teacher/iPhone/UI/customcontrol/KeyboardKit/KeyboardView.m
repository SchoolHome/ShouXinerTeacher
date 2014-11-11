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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"拍照", nil];
    [sheet showInView:[UIApplication sharedApplication].windows[0]];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self photoSwitchTapedIndex:0];
    }else if(buttonIndex == 1){
        [self photoSwitchTapedIndex:1];
    }else{
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
    topBarBack.backgroundColor = [UIColor colorWithHexString:@"fafafa"];//@"#f5f0e9"
    
    textView = [[KBGrowingTextView alloc] initWithFrame:CGRectMake(42, keyboardTopBar.frame.size.height-61/2-6, 230.5f, 32.0f)]; //一行高度32
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
    UIImage *image = [[UIImage imageNamed:@"text_blank"] stretchableImageWithLeftCapWidth:0 topCapHeight:33/2];
    textViewBack.image = image;
    
    [keyboardTopBar addSubview:topBarBack];
    [keyboardTopBar addSubview:textViewBack];
    [keyboardTopBar addSubview:textView];
    
    recordButton = [[KBRecordButton alloc] initWithFrame:CGRectMake(45, keyboardTopBar.frame.size.height- 63/2, 461/2, 63/2)];
    [keyboardTopBar addSubview:recordButton];
    [recordButton addTarget:self action:@selector(recordBegin) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpOutside];
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchCancel];
    recordButton.hidden = YES;
    
    captureButton = [[KBCaptureButton alloc] initWithFrame:CGRectMake(570/2, keyboardTopBar.frame.size.height - 54/2-10, 54/2, 54/2)];
    [keyboardTopBar addSubview:captureButton];
    [captureButton addTarget:self action:@selector(captureButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    convertButton = [[KBConvertButton alloc] initWithFrame:CGRectMake(7, keyboardTopBar.frame.size.height - 36.0f, 28.0f, 28.0f)];
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
    CGRect rect1 = CGRectMake(0, self.superview.frame.size.height - (height+22), 320, height+22);
    keyboardTopBar.frame = rect1;
    
    textView.frame = CGRectMake(42, keyboardTopBar.frame.size.height-height-6+2, textView.frame.size.width, height);
    textViewBack.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
    
    topBarBack.frame = CGRectMake(0, 10, keyboardTopBar.frame.size.width, keyboardTopBar.frame.size.height-10); // 背景
    recordButton.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
    captureButton.frame = CGRectMake(570/2, keyboardTopBar.frame.size.height - 35.0f, 28.0f, 28.0f);
    convertButton.frame = CGRectMake(7, keyboardTopBar.frame.size.height - 35.0f, 28.0f, 28.0f);
}

-(void)initSmallView{
    if (!smallPageView) {

    }
}
-(void)initMagicView{
    if (!magicPageView) {

    }
}
-(void)initEmojiView{
    if (!emojiPageView) {

    }
}

-(void)initMiddle{

}

-(void)initBottom{
  
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
    CGRect rect1;
    if (growingTextView.frame.size.height < height) {
        rect1 = CGRectMake(0, self.keyboardTopBar.frame.origin.y - (height - growingTextView.frame.size.height), 320, height+22);
    }else{
        rect1 = CGRectMake(0, self.keyboardTopBar.frame.origin.y + (growingTextView.frame.size.height - height), 320, height+22);
    }
    keyboardTopBar.frame = rect1;
    textView.frame = CGRectMake(42, keyboardTopBar.frame.size.height-height-6+2, textView.frame.size.width, height);
    textViewBack.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
    
    topBarBack.frame = CGRectMake(0, 10, keyboardTopBar.frame.size.width, keyboardTopBar.frame.size.height-10); // 背景
    recordButton.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.frame.size.width, textView.frame.size.height);
    captureButton.frame = CGRectMake(570/2, keyboardTopBar.frame.size.height - 35.0f, 28.0f, 28.0f);
    convertButton.frame = CGRectMake(7, keyboardTopBar.frame.size.height - 35.0f, 28.0f, 28.0f);
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
