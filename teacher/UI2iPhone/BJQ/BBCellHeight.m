//
//  BBCellHeight.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBCellHeight.h"
#import "NSAttributedString+Attributes.h"

// title 固定高度
#define K_TITLE_HEIGHT 20
#define K_TIME_HEIGHT  27

@implementation BBCellHeight


+(CGFloat)heightOfData:(BBTopicModel *)data{

    switch ([data.topictype intValue]) {
        case 1:
        case 2:  // 发通知1 // 发作业2
            //
        {
            //title + content + image +comment
            CGFloat titleHeight = K_TITLE_HEIGHT;
            CGFloat contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:12]
                                             constrainedToSize:CGSizeMake(175, CGFLOAT_MAX)].height;
            
            if (contentHeight>=(41-6)) {
                contentHeight = contentHeight +6; // 修正高度
            }else{
                contentHeight = 41;
            }
            
            contentHeight = contentHeight +5; //
            
            CGFloat imageHeight = 0;
            if ([data.imageList count]>0) {
                switch ([data.imageList count]) {
                    case 1:
                    case 2:
                    case 3:
                    {
                        imageHeight = 75;
                    }
                        break;
                    case 4:
                    case 5:
                    case 6:
                    {
                        imageHeight = 75*2+5;
                    }
                        break;
                    case 7:
                    case 8:
                    {
                        imageHeight = 75*3+5*2;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                imageHeight = imageHeight +10; // 上下空隙
            }
            
            CGFloat commentHeight = 0;
            if ([data.commentsStr length]>0) { // 有评论
                
                commentHeight = [data.commentsStr sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)].height;
                commentHeight = commentHeight + 10 + 45+5;
                
            }else{  // 没有评论
                if ([data.praisesStr length]>0) {
                    //
                    commentHeight = 60; // 固定高度
                }else{
                    commentHeight = 0; //修正高度
                }
            }
            
            return titleHeight+contentHeight+imageHeight+commentHeight+K_TIME_HEIGHT+5+10; // 按钮上下空隙
            
        }
            break;
        case 4:  // 拍表现4，随便说4
            //
        {
            //title + content + image +comment
            CGFloat titleHeight = K_TITLE_HEIGHT;
            CGFloat contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:12]
                                             constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)].height;
            
            CGFloat imageHeight = 0;
            if ([data.imageList count]>0) {
                switch ([data.imageList count]) {
                    case 1:
                    case 2:
                    case 3:
                    {
                        imageHeight = 75;
                    }
                        break;
                    case 4:
                    case 5:
                    case 6:
                    {
                        imageHeight = 75*2+5;
                    }
                        break;
                    case 7:
                    case 8:
                    {
                        imageHeight = 75*3+5*2;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                imageHeight = imageHeight +10; // 上下空隙
            }
            
            CGFloat commentHeight = 0;
            if ([data.commentsStr length]>0) { // 有评论
                
                commentHeight = [data.commentsStr sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)].height;
                commentHeight = commentHeight + 10 + 45+5;
                
            }else{  // 没有评论
                if ([data.praisesStr length]>0) {
                    //
                    commentHeight = 60; // 固定高度
                }else{
                    commentHeight = 0; //修正高度
                }
            }
            return titleHeight+contentHeight+imageHeight+commentHeight+K_TIME_HEIGHT+5+10; // 按钮上下空隙
        }
            break;
            
        case 7:  // 转发 forword
            //
        {
            //titleHeight+contentHeight+linkHeight+commentHeight
            
            CGFloat titleHeight = K_TITLE_HEIGHT;
            CGFloat contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:12]
                                             constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)].height;
            
            
            CGFloat linkHeight = 63+10; //修正高度
            
            
            CGFloat commentHeight = 0;
            if ([data.commentsStr length]>0) { // 有评论
                
                commentHeight = [data.commentsStr sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)].height;
                commentHeight = commentHeight + 10 + 45+5;
                
            }else{  // 没有评论
                if ([data.praisesStr length]>0) {
                    //
                    commentHeight = 60; // 固定高度
                }else{
                    commentHeight = 0; //修正高度
                }
            }
            return titleHeight+contentHeight+linkHeight+commentHeight+K_TIME_HEIGHT+5+10; // 按钮上下空隙

        }
            break;
        default:   // 默认，随便说
            
            //
        {
            //return 10;
            {
                //title + content + image +comment
                CGFloat titleHeight = K_TITLE_HEIGHT;
                CGFloat contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:12]
                                                 constrainedToSize:CGSizeMake(200, CGFLOAT_MAX)].height;
                
                CGFloat imageHeight = 0;
                if ([data.imageList count]>0) {
                    switch ([data.imageList count]) {
                        case 1:
                        case 2:
                        case 3:
                        {
                            imageHeight = 75;
                        }
                            break;
                        case 4:
                        case 5:
                        case 6:
                        {
                            imageHeight = 75*2+5;
                        }
                            break;
                        case 7:
                        case 8:
                        {
                            imageHeight = 75*3+5*2;
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    imageHeight = imageHeight +10; // 上下空隙
                }
                
                CGFloat commentHeight = 0;
                if ([data.commentsStr length]>0) { // 有评论
                    
                    commentHeight = [data.commentsStr sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)].height;
                    commentHeight = commentHeight + 10 + 45+5;
                    
                }else{  // 没有评论
                    if ([data.praisesStr length]>0) {
                        //
                        commentHeight = 60; // 固定高度
                    }else{
                        commentHeight = 0; //修正高度
                    }
                }
                return titleHeight+contentHeight+imageHeight+commentHeight+K_TIME_HEIGHT+5+10; // 按钮上下空隙
            }
        }
            
            break;
    }
    
    return 300;
}

@end
