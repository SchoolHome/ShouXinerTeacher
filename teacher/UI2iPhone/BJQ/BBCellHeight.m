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
#define K_TITLE_HEIGHT 5
#define K_TIME_HEIGHT  27
#define K_REPLY_FONT_SIZE 12.0f
#define K_REPLY_WIDTH 235.0f

@implementation BBCellHeight


+(CGFloat)heightOfData:(BBTopicModel *)data{

    switch ([data.topictype intValue]) {
        case 1:{
            // 通知
            // 留白高度
            CGFloat spaceHeight = K_TITLE_HEIGHT;
            
            // title高度 + 下方留白
            CGFloat titleHeight = 30.0f;
            
            // 内容高度 + 下方留白
            CGFloat contentHeight = 0;
            if (data.subject.integerValue == 1) {//拍表现
                contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                         constrainedToSize:CGSizeMake(175, CGFLOAT_MAX)].height;
            }else{//随便说
                contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                         constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
            }
            contentHeight += 10.0f;
            
            // image高度 + 下方留白
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
                    case 9:
                    {
                        imageHeight = 75*3+5*2;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                imageHeight = imageHeight +10; // 上下空隙
            }
            
            // 按钮高度 + 下方留白
            CGFloat buttonHeight = 30.0f;
            
            CGFloat commentHeight = 0;
            if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                // 只有点赞 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                // 点赞 + 评论 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                
                // 分割线
                commentHeight += 12.0f;
                
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }
            
            CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
            return totalHeight;
        }
            break;
        case 2:
        {
            // 作业
            // 留白高度
            CGFloat spaceHeight = K_TITLE_HEIGHT;
            
            // title高度 + 下方留白
            CGFloat titleHeight = 30.0f;
            
            // 内容高度 + 下方留白
            CGFloat contentHeight = 0;
            if (data.subject.integerValue == 1) {//拍表现
                contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                         constrainedToSize:CGSizeMake(175, CGFLOAT_MAX)].height;
            }else{//随便说
                contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                         constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
            }
            contentHeight += 10.0f;
            
            // image高度 + 下方留白
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
                    case 9:
                    {
                        imageHeight = 75*3+5*2;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                imageHeight = imageHeight +10; // 上下空隙
            }
            
            // 按钮高度 + 下方留白
            CGFloat buttonHeight = 30.0f;
            
            CGFloat commentHeight = 0;
            if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                // 只有点赞 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                // 点赞 + 评论 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                
                // 分割线
                commentHeight += 12.0f;
                
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }
            
            CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
            return totalHeight;
            
        }
            break;
        case 4:  // 拍表现4，随便说4
            //
        {
            if ([data.subject integerValue] == 1) {
                if (data.imageList != nil && [data.imageList count] != 0) {
                    // 留白高度
                    CGFloat spaceHeight = K_TITLE_HEIGHT;
                    
                    // title高度 + 下方留白
                    CGFloat titleHeight = 30.0f;
                    
                    // 内容高度 + 下方留白
                    CGFloat contentHeight = 0;
                    if (data.subject.integerValue == 1) {//拍表现
                        contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                    }else{//随便说
                        contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                    }
                    contentHeight += 10.0f;
                    
                    // image高度 + 下方留白
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
                            case 9:
                            {
                                imageHeight = 75*3+5*2;
                            }
                                break;
                                
                            default:
                                break;
                        }
                        
                        imageHeight = imageHeight +10; // 上下空隙
                    }
                    
                    // 按钮高度 + 下方留白
                    CGFloat buttonHeight = 30.0f;
                    
                    CGFloat commentHeight = 0;
                    if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                        // 只有点赞 不留白
                        commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                    constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                        if (commentHeight < 17.0f) {
                            commentHeight = 17.0f;
                        }
                        commentHeight += 23.0f;
                    }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                        // 只有评论 不留白
                        for (NSString *str in data.commentTextArray) {
                            CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                            commentHeight += temp.height;
                        }
                        commentHeight += 23.0f;
                    }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                        // 点赞 + 评论 不留白
                        commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                    constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                        if (commentHeight < 17.0f) {
                            commentHeight = 17.0f;
                        }
                        
                        // 分割线
                        commentHeight += 12.0f;
                        
                        // 只有评论 不留白
                        for (NSString *str in data.commentTextArray) {
                            CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                            commentHeight += temp.height;
                        }
                        commentHeight += 23.0f;
                    }
                    
                    CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
                    return totalHeight;
                }else if (data.videoList != nil && [data.videoList count] != 0){
                    // 留白高度
                    CGFloat spaceHeight = K_TITLE_HEIGHT;
                    
                    // title高度 + 下方留白
                    CGFloat titleHeight = 30.0f;
                    
                    // 内容高度 + 下方留白
                    CGFloat contentHeight = 0;
                    if (data.subject.integerValue == 1) {//拍表现
                        contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                    }else{//随便说
                        contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                    }
                    contentHeight += 10.0f;
                    
                    // image高度 + 下方留白
                    CGFloat imageHeight = 0;
                    if ([data.videoList count]>0) {
                        switch ([data.videoList count]) {
                            case 1:
                            {
                                imageHeight = 85;
                            }
                                break;
                            default:
                                break;
                        }
                        
                        imageHeight = imageHeight +10; // 上下空隙
                    }
                    
                    // 按钮高度 + 下方留白
                    CGFloat buttonHeight = 30.0f;
                    
                    CGFloat commentHeight = 0;
                    if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                        // 只有点赞 不留白
                        commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                    constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                        if (commentHeight < 17.0f) {
                            commentHeight = 17.0f;
                        }
                        commentHeight += 23.0f;
                    }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                        // 只有评论 不留白
                        for (NSString *str in data.commentTextArray) {
                            CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                            commentHeight += temp.height;
                        }
                        commentHeight += 23.0f;
                    }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                        // 点赞 + 评论 不留白
                        commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                    constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                        if (commentHeight < 17.0f) {
                            commentHeight = 17.0f;
                        }
                        
                        // 分割线
                        commentHeight += 12.0f;
                        
                        // 只有评论 不留白
                        for (NSString *str in data.commentTextArray) {
                            CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                            commentHeight += temp.height;
                        }
                        commentHeight += 23.0f;
                    }
                    
                    CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
                    return totalHeight;
                }else{
                    // 留白高度
                    CGFloat spaceHeight = K_TITLE_HEIGHT;
                    
                    // title高度 + 下方留白
                    CGFloat titleHeight = 30.0f;
                    
                    // 内容高度 + 下方留白
                    CGFloat contentHeight = 0;
                    if (data.subject.integerValue == 1) {//拍表现
                        contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                    }else{//随便说
                        contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                    }
                    contentHeight += 10.0f;
                    
                    // image高度 + 下方留白
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
                            case 9:
                            {
                                imageHeight = 75*3+5*2;
                            }
                                break;
                                
                            default:
                                break;
                        }
                        
                        imageHeight = imageHeight +10; // 上下空隙
                    }
                    
                    // 按钮高度 + 下方留白
                    CGFloat buttonHeight = 30.0f;
                    
                    CGFloat commentHeight = 0;
                    if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                        // 只有点赞 不留白
                        commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                    constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                        if (commentHeight < 17.0f) {
                            commentHeight = 17.0f;
                        }
                        commentHeight += 23.0f;
                    }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                        // 只有评论 不留白
                        for (NSString *str in data.commentTextArray) {
                            CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                            commentHeight += temp.height;
                        }
                        commentHeight += 23.0f;
                    }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                        // 点赞 + 评论 不留白
                        commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                    constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                        if (commentHeight < 17.0f) {
                            commentHeight = 17.0f;
                        }
                        
                        // 分割线
                        commentHeight += 12.0f;
                        
                        // 只有评论 不留白
                        for (NSString *str in data.commentTextArray) {
                            CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                            commentHeight += temp.height;
                        }
                        commentHeight += 23.0f;
                    }
                    
                    CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
                    return totalHeight;
                }
            }else{
                // 留白高度
                CGFloat spaceHeight = K_TITLE_HEIGHT;
                
                // title高度 + 下方留白
                CGFloat titleHeight = 30.0f;
                
                // 内容高度 + 下方留白
                CGFloat contentHeight = 0;
                if (data.subject.integerValue == 1) {//拍表现
                    contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                             constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                }else{//随便说
                    contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                             constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
                }
                contentHeight += 10.0f;
                
                // image高度 + 下方留白
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
                        case 9:
                        {
                            imageHeight = 75*3+5*2;
                        }
                            break;
                            
                        default:
                            break;
                    }
                    
                    imageHeight = imageHeight +10; // 上下空隙
                }
                
                // 按钮高度 + 下方留白
                CGFloat buttonHeight = 30.0f;
                
                CGFloat commentHeight = 0;
                if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                    // 只有点赞 不留白
                    commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                    if (commentHeight < 17.0f) {
                        commentHeight = 17.0f;
                    }
                    commentHeight += 23.0f;
                }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                    // 只有评论 不留白
                    for (NSString *str in data.commentTextArray) {
                        CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                        commentHeight += temp.height;
                    }
                    commentHeight += 23.0f;
                }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                    // 点赞 + 评论 不留白
                    commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                                constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                    if (commentHeight < 17.0f) {
                        commentHeight = 17.0f;
                    }
                    
                    // 分割线
                    commentHeight += 12.0f;
                    
                    // 只有评论 不留白
                    for (NSString *str in data.commentTextArray) {
                        CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                        commentHeight += temp.height;
                    }
                    commentHeight += 23.0f;
                }
                
                CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
                return totalHeight;
            }
        }
            break;
            
        case 7:  // 转发 forword
            //
        {
            // 留白高度
            CGFloat spaceHeight = K_TITLE_HEIGHT;
            
            // title高度 + 下方留白
            CGFloat titleHeight = 30.0f;
            
            // 内容高度 + 下方留白
            CGFloat contentHeight = 0;
            contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                     constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
            contentHeight += 10.0f;
            
            // 转发高度 + 下方留白
            CGFloat linkHeight = 55.0f;
            
            // 按钮高度 + 下方留白
            CGFloat buttonHeight = 30.0f;
            
            CGFloat commentHeight = 0;
            if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                // 只有点赞 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                // 点赞 + 评论 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                
                // 分割线
                commentHeight += 12.0f;
                
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }
            
            CGFloat totalHeight = spaceHeight + titleHeight + linkHeight + contentHeight + buttonHeight + commentHeight;
            return totalHeight;

        }
            break;
        default:   // 默认，随便说
            
            //
        {
            // 留白高度
            CGFloat spaceHeight = K_TITLE_HEIGHT;
            
            // title高度 + 下方留白
            CGFloat titleHeight = 30.0f;
            
            // 内容高度 + 下方留白
            CGFloat contentHeight = 0;
            contentHeight = [data.content sizeWithFont:[UIFont systemFontOfSize:14]
                                        constrainedToSize:CGSizeMake(225, CGFLOAT_MAX)].height;
            contentHeight += 10.0f;
            
            // image高度 + 下方留白
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
                    case 9:
                    {
                        imageHeight = 75*3+5*2;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                imageHeight = imageHeight +10; // 上下空隙
            }
            
            // 按钮高度 + 下方留白
            CGFloat buttonHeight = 30.0f;
            
            CGFloat commentHeight = 0;
            if ([data.praisesStr length]>0 && [data.commentsStr length]==0) {
                // 只有点赞 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]==0 && [data.commentsStr length]>0){
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }else if ([data.praisesStr length]>0 && [data.commentsStr length]>0){
                // 点赞 + 评论 不留白
                commentHeight = [data.praisesStr sizeWithFont:[UIFont systemFontOfSize:12.f]
                                            constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0].height; // 固定高度
                if (commentHeight < 17.0f) {
                    commentHeight = 17.0f;
                }
                
                // 分割线
                commentHeight += 12.0f;
                
                // 只有评论 不留白
                for (NSString *str in data.commentTextArray) {
                    CGSize temp = [str sizeWithFont:[UIFont systemFontOfSize:K_REPLY_FONT_SIZE] constrainedToSize:CGSizeMake(K_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                    commentHeight += temp.height;
                }
                commentHeight += 23.0f;
            }
            
            CGFloat totalHeight = spaceHeight + titleHeight + contentHeight + imageHeight + buttonHeight + commentHeight;
            return totalHeight;
        }
            
            break;
    }
    
    return 300;
}

@end
