//
//  BBInputView.h
//  inhouse
//
//  Created by xxx on 14-3-26.
//  Copyright (c) 2014年 bright. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBTopicModel.h"


@protocol BBInputViewDelegate;

@interface BBInputView : UIView<UITextFieldDelegate>
{
    UITextField *inputTextField;
}

@property(nonatomic,weak) id <BBInputViewDelegate> delegate;
@property(nonatomic,strong) BBTopicModel *data;

-(void)beginEdit;
-(void)beginEdit : (NSString *) placeholder;
-(void)endEdit;
@end

@protocol BBInputViewDelegate <NSObject>
-(void)bbInputView:(BBInputView *)view sendText:(NSString *)text;
@end