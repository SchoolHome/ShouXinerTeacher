//
//  BBTopicModel.h
//  teacher
//
//  Created by xxx on 14-4-1.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSAttributedString+Attributes.h"

/*
 * topic
 */
@class BBForwardModel;
@class BBPraiseModel;
@class BBCommentModel;

@interface BBTopicModel : NSObject

@property(nonatomic,strong) NSNumber *topicid;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) NSNumber *author_uid;
@property(nonatomic,strong) NSString *author_username;
@property(nonatomic,strong) NSString *author_avatar;
@property(nonatomic,strong) NSNumber *ts;
@property(nonatomic,strong) NSNumber *topictype;
@property(nonatomic,strong) NSNumber *subject;
@property(nonatomic,strong) NSNumber *am_i_like;
@property(nonatomic,strong) NSNumber *num_praise;
@property(nonatomic,strong) NSNumber *num_comment;
@property(nonatomic,strong) NSArray *praises;
@property(nonatomic,strong) NSArray *comments;
@property(nonatomic,strong) NSMutableArray *commentStr;
@property(nonatomic) BOOL award;
@property(nonatomic) BOOL recommended;
@property(nonatomic) BOOL recommendToGroups;
@property(nonatomic) BOOL recommendToHomepage;
@property(nonatomic) BOOL recommendToUpGroup;


// attach
@property(nonatomic,strong) NSArray *imageList;
@property(nonatomic,strong) NSArray *fileList;
@property(nonatomic,strong) NSArray *audioList;
@property(nonatomic,strong) BBForwardModel *forward;


// shortcut
@property(nonatomic,strong) NSString *praisesStr;
@property(nonatomic,strong) NSAttributedString *commentsStr;


+(BBTopicModel *)fromJson:(NSDictionary *)dict;

@end

/*
 * BBForwordModel
 */
@interface BBForwardModel : NSObject
{
    
}
@property(nonatomic,strong) NSNumber *type;  // oa 有指示
@property(nonatomic,strong) NSNumber *id;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *summary;
@property(nonatomic,strong) NSString *author_name;
@property(nonatomic,strong) NSString *author_avatar;
@property(nonatomic,strong) NSNumber *ts;
@property(nonatomic,strong) NSString *url;

+(BBForwardModel *)fromJson:(NSDictionary *)dict;

@end

/*
 * BBPraiseModel
 */
@interface BBPraiseModel : NSObject
{

}
@property(nonatomic,strong) NSNumber *uid;
@property(nonatomic,strong) NSString *username;

+(BBPraiseModel *)fromJson:(NSDictionary *)dict;
@end

/*
 * BBCommentModel
 */

@interface BBCommentModel : NSObject
{
    
}

@property(nonatomic,strong) NSString *comment;
@property(nonatomic,strong) NSNumber *id;
@property(nonatomic,strong) NSNumber *replyto;
@property(nonatomic,strong) NSString *replyto_username;
@property(nonatomic,strong) NSNumber *timestamp;
@property(nonatomic,strong) NSNumber *uid;
@property(nonatomic,strong) NSString *username;

+(BBCommentModel *)fromJson:(NSDictionary *)dict;

@end

