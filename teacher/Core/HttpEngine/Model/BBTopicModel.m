//
//  BBTopicModel.m
//  teacher
//
//  Created by xxx on 14-4-1.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBTopicModel.h"
#import "ColorUtil.h"

@implementation BBTopicModel

+(BBTopicModel *)fromJson:(NSDictionary *)dict{
    
    if (dict) {
        BBTopicModel *tp = [[BBTopicModel alloc] init];
        
        tp.topicid = dict[@"topicid"];
        tp.title = dict[@"title"];
        tp.content = dict[@"content"];
        tp.author_uid = dict[@"author_uid"];
        tp.author_username = dict[@"author_username"];
        
        if ([dict[@"author_avatar"] isKindOfClass:[NSNull class]]) {
            tp.author_avatar = nil;
        }else{
            tp.author_avatar = dict[@"author_avatar"];
        }
        
        tp.ts = dict[@"ts"];
        tp.topictype = dict[@"topictype"];
        tp.subject = dict[@"subject"];
        tp.am_i_like = dict[@"am_i_like"];
        tp.num_praise = dict[@"num_praise"];
        tp.num_comment = dict[@"num_comment"];
        tp.award = [dict[@"award"] boolValue];
        tp.recommendToGroups = [dict[@"recommendToGroups"] boolValue];
        tp.recommendToHomepage = [dict[@"recommendToHomepage"] boolValue];
        tp.recommendToUpGroup = [dict[@"recommendToUpGroup"] boolValue];
        tp.recommended = [dict[@"recommended"] boolValue];
        tp.editable = [dict[@"editable"] boolValue];
        // 赞列表
        NSArray *praises = dict[@"praises"];
        if (praises) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            //praisesStr
            NSMutableString *str = [[NSMutableString alloc] init];
            [praises enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBPraiseModel *pr = [BBPraiseModel fromJson:obj];
                if (pr) {
                    [arr addObject:pr];
                    [str appendString:[NSString stringWithFormat:@"%@,",pr.username]];
                }
            }];
            
            if ([str length]>0) {
                [str deleteCharactersInRange:NSMakeRange([str length]-1, 1)];
            }
            
            tp.praises = arr;
            tp.praisesStr = str;
        }
        
        //  评论列表
        NSArray *comments = dict[@"comments"];
        if (comments) {
            
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
            tp.commentStr = [[NSMutableArray alloc] init];
            tp.commentText = [[NSMutableString alloc] init];
            tp.commentTextArray = [[NSMutableArray alloc] init];
            [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBCommentModel *cm = [BBCommentModel fromJson:obj];
                if (cm) {
                    [arr addObject:cm];
                    NSUInteger len = [cm.username length]+1;
                    NSMutableAttributedString *attributedText;
                    if ([cm.username isEqualToString:cm.replyto_username]) {
                        NSString *text = [NSString stringWithFormat:@"%@: %@",cm.username,cm.comment];
                        attributedText = [[NSMutableAttributedString alloc] initWithString:text];
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6) {
                            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(0,len)];
                        }
                        [tp.commentText appendString:text];
                        [tp.commentTextArray addObject:text];
                    }else{
                        NSString *text = [NSString stringWithFormat:@"%@ 回复 %@: %@",cm.username,cm.replyto_username,cm.comment];
                        attributedText = [[NSMutableAttributedString alloc] initWithString:text];
                        NSUInteger len1 = [cm.replyto_username length];
                        NSUInteger temp = [[NSString stringWithFormat:@"%@ 回复 ",cm.username] length];
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 6) {
                            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(0,len)];
                            [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(temp,len1)];
                        }
                        [tp.commentText appendString:text];
                        [tp.commentTextArray addObject:text];
                    }
                    
                    [str appendAttributedString:attributedText];
                    [tp.commentStr addObject:attributedText];
                }
            }];
            
            tp.comments = arr;
            tp.commentsStr = str;
        }

        // 附件
        NSDictionary *attach = dict[@"attach"];
        if (attach) {
            NSArray *list = attach[@"image"];
            if ([list count]>=8) {  // 避免图片太多引起错误
                tp.imageList = [list subarrayWithRange:NSMakeRange(0, 7)];
            }else{
                tp.imageList = list;
            }
            
            tp.fileList = attach[@"file"];
            tp.audioList = attach[@"audio"];
            
            
            NSArray *forwards = attach[@"forward"];
            if ([forwards isKindOfClass:[NSArray class]]) {
                
                if ([forwards count]>0) {
                    tp.forward = [BBForwardModel fromJson:forwards[0]];
                }
            }
            tp.videoList = attach[@"video"];
        }
        
        return tp;
    }
    
    return nil;
}

@end


@implementation BBForwardModel

+(BBForwardModel *)fromJson:(NSDictionary *)dict{

    if (dict) {
        BBForwardModel *fd = [[BBForwardModel alloc] init];
        fd.type = dict[@"type"];
        fd.id = dict[@"id"];
        fd.title = dict[@"title"];
        fd.summary = dict[@"summary"];
        fd.author_name = dict[@"author_name"];
        if ([dict[@"author_avatar"] isKindOfClass:[NSNull class]]) {
            fd.author_avatar = nil;
        }else{
            fd.author_avatar = dict[@"author_avatar"];
        }
        
        fd.ts = dict[@"ts"];
        fd.url = dict[@"url"];
        return fd;
    }

    return nil;
}

@end

@implementation BBPraiseModel

+(BBPraiseModel *)fromJson:(NSDictionary *)dict{
    if (dict) {
        BBPraiseModel *pr = [[BBPraiseModel alloc] init];
        pr.uid = dict[@"uid"];
        pr.username = dict[@"username"];
        return pr;
    }
    return nil;
}

@end


@implementation BBCommentModel

+(BBCommentModel *)fromJson:(NSDictionary *)dict{

    if (dict) {
        BBCommentModel *cm = [[BBCommentModel alloc] init];
        cm.comment = dict[@"comment"];
         cm.id = dict[@"id"];
         cm.replyto = dict[@"replyto"];
         cm.replyto_username = dict[@"replyto_username"];
         cm.timestamp = dict[@"timestamp"];
         cm.uid = dict[@"uid"];
         cm.username = dict[@"username"];
        
        return cm;
    }
    return nil;
}

@end

