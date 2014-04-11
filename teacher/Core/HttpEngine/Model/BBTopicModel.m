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
    
    NSLog(@"BBTopicModel start");
    
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
                    [str appendString:[NSString stringWithFormat:@"%@，",pr.username]];
                }
            }];
            tp.praises = arr;
            tp.praisesStr = str;
        }
        
        //  评论列表
        NSArray *comments = dict[@"comments"];
        if (comments) {
            
            
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
            
            [comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                BBCommentModel *cm = [BBCommentModel fromJson:obj];
                if (cm) {
                    [arr addObject:cm];
                    
                    NSLog(@"cm.username  %@",cm.username);
                    
                    NSUInteger len = [cm.username length]+2;
                    
                    NSLog(@"cm.username111  %@",cm.username);
                    
                    
                    NSString *text = [NSString stringWithFormat:@"%@: %@\n",cm.username,cm.comment];
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
                    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4a7f9d"] range:NSMakeRange(0,len)];
                    
                    [str appendAttributedString:attributedText];
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
            tp.forword = [BBForwordModel fromJson:attach[@"forword"]];
        }
        
        
        NSLog(@"BBTopicModel end");
        
        return tp;
    }
    
    return nil;
}

@end


@implementation BBForwordModel

+(BBForwordModel *)fromJson:(NSDictionary *)dict{

    if (dict) {
        BBForwordModel *fd = [[BBForwordModel alloc] init];
        fd.type = dict[@"type"];
        fd.id = dict[@"id"];
        fd.title = dict[@"title"];
        fd.summary = dict[@"summary"];
        fd.author_name = dict[@"author_name"];
        fd.author_avatar = dict[@"author_avatar"];
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

