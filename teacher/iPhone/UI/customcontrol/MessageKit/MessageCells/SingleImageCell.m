//
//  SingleImageCell.m
//  iCouple
//
//  Created by ming bright on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SingleImageCell.h"



@implementation SingleImageCell
@synthesize displayImageView;





-(void)backgroundTaped:(id)sender{
    if ([self.delegate respondsToSelector:@selector(imageCellTaped:)]) {
        [self.delegate imageCellTaped:self];
    }
}


- (id)initWithType : (MessageCellType) messageCellType  withBelongMe : (BOOL) isBelongMe withKey:(NSString *)key{
    self = [super initWithType:messageCellType withBelongMe:isBelongMe withKey:key];
    if (self) {
        
        displayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        ellipticalBackground.exclusiveTouch = YES;
        [ellipticalBackground addTarget:self action:@selector(backgroundTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)createAvatar{
    [self createAvatarControl];
}

- (void)refreshCell{
    [super refreshCell];
    
    ExMessageModel *model = (ExMessageModel*)self.data;
    UIImage *image = [model getUserImage];
    
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    
    CGRect imageRect;
    
    
    if (w>=h) {
        if (w<kMaxImageHeight&&h<kMaxImageHeight) { //宽高都不超越，用原始大小
            imageRect = CGRectMake((320 - w)/2, kTopAndButtomPadding+kCellTopPadding, w, h);
        }else {

            CGFloat wNew = kMaxImageHeight;  // 宽为基准
            CGFloat hNew = h * wNew / w;
            imageRect = CGRectMake((320 -wNew)/2 , kTopAndButtomPadding+kCellTopPadding, wNew, hNew);
        }
    }else {
        if (w<kMaxImageHeight&&h<kMaxImageHeight) { //宽高都不超越，用原始大小
            imageRect = CGRectMake((320 - w)/2, kTopAndButtomPadding+kCellTopPadding, w, h);
        }else {
            CGFloat hNew = kMaxImageHeight;  // 高为基准
            CGFloat wNew = w * hNew / h;
            imageRect = CGRectMake((320 -wNew)/2 , kTopAndButtomPadding+kCellTopPadding, wNew, hNew);
        }
    }
    
    if (self.isBelongMe) {
        ellipticalBackground.frame = CGRectMake(56.0f, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
    }else{
        ellipticalBackground.frame = CGRectMake(320.0f - 47.0f - imageRect.size.width, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
    }
    
    if (self.isBelongMe) {
        displayImageView.frame = CGRectMake(56.0f, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
    }else{
        displayImageView.frame = CGRectMake(320.0f - 56.0f - imageRect.size.width, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
    }
    
    [displayImageView removeFromSuperview];
    displayImageView.layer.masksToBounds =YES;
    displayImageView.layer.cornerRadius = 15.0f;
    [self addSubview:displayImageView];
    displayImageView.image = image;
    
    timestampLabel.frame = CGRectMake((320 -50)/2, ellipticalBackground.frame.size.height+16.0f, 50, kTimestampLabelHeight);
    timestampLabel.text = [self timeStringFromNumber:model.messageModel.date];
    
    self.resendButton.frame = CGRectMake(ellipticalBackground.frame.origin.x + ellipticalBackground.frame.size.width + 10.0f, 
                                         ( ellipticalBackground.frame.size.height - kResendButtonWidth ) /2.0f ,
                                         kResendButtonWidth, kResendButtonWidth);
    
    if (self.isBelongMe) {
        avatar.frame = CGRectMake(7.5f, ellipticalBackground.frame.origin.y + ellipticalBackground.frame.size.height -  kAvatarHeight, kAvatarWidth, kAvatarHeight);
    }else{
        avatar.frame = CGRectMake(320.0f-7.5f-kAvatarWidth, ellipticalBackground.frame.origin.y+ ellipticalBackground.frame.size.height -  kAvatarHeight, kAvatarWidth, kAvatarHeight);
    }
    if (!self.userHeadImage) {
        avatar.backImage = [UIImage imageNamed:@"headpic_index_normal_120x120"];
    }else {
        avatar.backImage = self.userHeadImage;
    }
}

@end
