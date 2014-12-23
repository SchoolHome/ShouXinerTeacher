//
//  CalculateCellHeight.m
//  iCouple
//
//  Created by shuo wang on 12-5-4.
//  Copyright (c) 2012年 fanxer. All rights reserved.
//

#import "CalculateCellHeight.h"
#import "CellTypeHeader.h"



@implementation CalculateCellHeight



+(CGFloat)heightOfSmallExpressionCell:(NSArray *)heightArray{
    
    CGFloat viewHeight = 0;
    for (NSNumber *nb in heightArray) {
        if ([nb boolValue]) {
            viewHeight = viewHeight + kExpressionSizeHeight+kTwoLinePadding;
        }else {
            viewHeight = viewHeight + kTextSizeHeight+kTwoLinePadding;
        }
    }
    return viewHeight+kCellTopPadding + (kTopAndButtomPadding-2)*2 + kTimestampLabelHeight+1 - kTwoLinePadding + 4.0f;  //每行高度 * 行数
}

+(CGFloat)heightOfTextAlarmExpressionCell:(NSArray *)heightArray{
    CGFloat viewHeight = [CalculateCellHeight heightOfSmallExpressionCell:heightArray];
    return viewHeight + kTextDateHeight;
}

+(CGFloat)heightOfTextAlarmedExpressionCell : (NSArray *)heightArray{
    CGFloat viewHeight = [CalculateCellHeight heightOfSmallExpressionCell:heightArray];
    return viewHeight + kTextDateHeight;
}

+(CGFloat)heightOfMagicExpressionCell{
    return kCellTopPadding + kMagicBackgroundHeight  + kTimestampLabelHeight;
}

//语音未读闹钟消息高度
+(CGFloat)heightOfSoundAlarmCell:(BOOL) isMysticalSoundAlarm{
    if (isMysticalSoundAlarm) {
        return kCellTopPadding + kMysticalSoundAlarmHeight + kTimestampLabelHeight;
    }else{
        return kCellTopPadding + kSoundAlarmHeight  + kTimestampLabelHeight;
    }
}
//语音已读闹钟消息高度
+(CGFloat)heightOfSoundAlarmedCell{
    return kCellTopPadding + kSoundAlarmedHeight  + kTimestampLabelHeight;
}

// 损坏的小双闹钟的高度
+(CGFloat)heightOfBreakSoundAlarmCell{
    return kCellTopPadding + kBreakSoundAlarmHeight + kTimestampLabelHeight;
}

+(CGFloat)heightOfMagicExpressionCell:(UIImage *)image text:(NSString *)text{
    
    if (text) {
        //CGFloat w = image.size.width/2 + 11+ 11+33.5 - 10;
        CGFloat w = image.size.width/2 + 33.5;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:10];
        lab.text = text;
        [lab sizeToFit];
        
        CGFloat h = lab.frame.size.height;
        lab = nil;
        //CGSize size=[text sizeWithFont:[UIFont systemFontOfSize:10] constrainedToSize:CGSizeMake(w, 20)];
        return kCellTopPadding + kMagicBackgroundHeight  + kTimestampLabelHeight+1 + h+5;
    }
    
    return kCellTopPadding + kMagicBackgroundHeight  + kTimestampLabelHeight;
}


+(CGFloat)heightOfSoundCell{
    return kCellTopPadding + kHeightOfSound  + kTimestampLabelHeight+2;
}

+(CGFloat)heightOfImageCell:(UIImage *)image{
    
    //CGFloat imageHeight = image.size.height;
    
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    
    CGRect imageRect;
    
//    if (w<kMaxImageWidth&&h<kMaxImageHeight) { //宽高都不超越
//        imageRect = CGRectMake((320 - w)/2, kTopAndButtomPadding+kCellTopPadding, w, h);
//    }else {
//        CGFloat wScale = w/kMaxImageWidth;
//        CGFloat hScale = h/kMaxImageHeight;
//        
//        if (wScale>hScale) {  //以宽为基准
//            CGFloat wNew = kMaxImageWidth;
//            CGFloat hNew = h * wNew / w;
//            imageRect = CGRectMake((320 -wNew)/2 , kTopAndButtomPadding+kCellTopPadding, wNew, hNew);
//        }else {
//            CGFloat hNew = kMaxImageHeight;
//            CGFloat wNew = w * hNew / h;
//            imageRect = CGRectMake((320 -wNew)/2 , kTopAndButtomPadding+kCellTopPadding, wNew, hNew);
//        }
//    }
    
    if (w>=h) {
        if (w<kMaxImageHeight&&h<kMaxImageHeight) { //宽高都不超越，用原始大小
            imageRect = CGRectMake((320 - w)/2, kTopAndButtomPadding+kCellTopPadding, w, h);
        }else {
            
            CGFloat wNew = kMaxImageHeight;
            CGFloat hNew = h * wNew / w;
            imageRect = CGRectMake((320 -wNew)/2 , kTopAndButtomPadding+kCellTopPadding, wNew, hNew);
        }
    }else {
        if (w<kMaxImageHeight&&h<kMaxImageHeight) { //宽高都不超越，用原始大小
            imageRect = CGRectMake((320 - w)/2, kTopAndButtomPadding+kCellTopPadding, w, h);
        }else {
            CGFloat hNew = kMaxImageHeight;
            CGFloat wNew = w * hNew / h;
            imageRect = CGRectMake((320 -wNew)/2 , kTopAndButtomPadding+kCellTopPadding, wNew, hNew);
        }
    }
    
    
     return imageRect.size.height + kTopAndButtomPadding*2  + kTimestampLabelHeight+1 + 2.0f;
}

+(CGFloat)heightOfVideoCell:(UIImage *)image{
    
    if (image.size.height>=image.size.width) {
        return kCellTopPadding + kMaxImageHeight + kTopAndButtomPadding*2 + kTimestampLabelHeight+1;
    }
    
    return kCellTopPadding + kMaxImageWidth + kTopAndButtomPadding*2 + kTimestampLabelHeight+1;
     
}

+(CGFloat)heightOfSystemTextCell{
     return kCellTopPadding + 18  + kTimestampLabelHeight;
}

+(CGFloat)heightOfSystemTextCell:(NSString *)text{
    if (text) {
        CGFloat w = 235-2*kLeftAndRightPadding;  //最大宽度
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:11];
        lab.text = text;
        [lab sizeToFit];
        
        CGFloat h = lab.frame.size.height;
        lab = nil;
        return kCellTopPadding + kTimestampLabelHeight+1 +2*4+ h+2;
    }
    
    return kCellTopPadding + 18  + kTimestampLabelHeight+1+2*4+2;
}

+(CGFloat)heightOfSystemTextActionCell{
     return kCellTopPadding + 18  + kTimestampLabelHeight;
}

+(CGFloat)heightOfSystemTextActionCell:(NSString *)text{
    if (text) {
        CGFloat w = 173;
        
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, 0)];
        lab.numberOfLines = 0;
        lab.font = [UIFont systemFontOfSize:11];
        lab.text = text;
        [lab sizeToFit];
        
        CGFloat h = lab.frame.size.height;
        lab = nil;
        return kCellTopPadding + kTimestampLabelHeight+1 +2*4+ h+2;
    }
    
    return kCellTopPadding + 18  + kTimestampLabelHeight+1+2*4+2;
}

@end
