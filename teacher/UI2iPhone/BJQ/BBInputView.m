//
//  BBInputView.m
//  inhouse
//
//  Created by xxx on 14-3-26.
//  Copyright (c) 2014年 bright. All rights reserved.
//

#import "BBInputView.h"

@implementation BBInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor lightGrayColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
        
        inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 7, 300, 30)];
        inputTextField.delegate = self;
        inputTextField.returnKeyType = UIReturnKeySend;
        inputTextField.backgroundColor = [UIColor whiteColor];
        inputTextField.placeholder = @"评论...";
        [self addSubview:inputTextField];
        
        CALayer *roundedLayer = [inputTextField layer];
        [roundedLayer setMasksToBounds:YES];
        roundedLayer.cornerRadius = 5.0;
        roundedLayer.borderWidth = 1;
        roundedLayer.borderColor = [[UIColor lightGrayColor] CGColor];

    }
    return self;
}

-(void)beginEdit{
    inputTextField.placeholder = @"评论...";
    [inputTextField becomeFirstResponder];
}

-(void)beginEdit : (NSString *) placeholder{
    inputTextField.placeholder = placeholder;
    [inputTextField becomeFirstResponder];
}

-(void)endEdit{
    [inputTextField resignFirstResponder];
}

-(void) keyboardFrameDidChanged:(NSNotification *)note{
    if ([inputTextField isFirstResponder]) {  // 过滤
        // get keyboard size and loctaion
        CGRect keyboardBounds;
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        // Need to translate the bounds to account for rotation.
        keyboardBounds = [self convertRect:keyboardBounds toView:nil];

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];

        CGFloat h = [[UIScreen mainScreen] bounds].size.height;
        self.frame = CGRectMake(0, h-keyboardBounds.size.height-44, 320, 44);
        
        [UIView commitAnimations];
    }
}

-(void) keyboardWillShow:(NSNotification *)note{
    if ([inputTextField isFirstResponder]) {  // 过滤
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
        
        CGFloat h = [[UIScreen mainScreen] bounds].size.height;
        self.frame = CGRectMake(0, h-keyboardBounds.size.height-44, 320, 44);
        
        [UIView commitAnimations];
    }
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    if ([inputTextField isFirstResponder]) {  // 过滤
        NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        //
        CGFloat h = [[UIScreen mainScreen] bounds].size.height;
        self.frame = CGRectMake(0, h, 320, 44);
        
        [UIView commitAnimations];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (inputTextField.text.length>0) {
        [inputTextField resignFirstResponder];
        if (_delegate&&[_delegate respondsToSelector:@selector(bbInputView:sendText:)]) {
            [_delegate bbInputView:self sendText:inputTextField.text];
        }
        inputTextField.text = nil;
    }else{
    
    }
    
    return YES;
}

@end
