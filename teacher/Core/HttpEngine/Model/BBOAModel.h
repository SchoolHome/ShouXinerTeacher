//
//  BBOAModel.h
//  teacher
//
//  Created by xxx on 14-4-2.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PalmUIModelCoding.h"

#define CacheName @"cacheArray"

@interface BBOASumModel : PalmUIModelCoding

@property NSMutableArray *cacheArray;

// 通过oalist获取的数据更新列表
-(void) updateCacheArray : (NSArray *) oaModelArray;
// 更新该条记录未读数为零
-(void) updateCacheUnReadedWithZero:(NSNumber *) senderUid;
@end

@interface BBOAModel : PalmUIModelCoding

@property(nonatomic,strong) NSNumber *oaid;
@property(nonatomic,strong) NSNumber *sender_uid;
@property(nonatomic,strong) NSString *sender_username;
@property(nonatomic,strong) NSString *sender_avatar;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) NSNumber *ts;
@property(nonatomic,strong) NSNumber *attach_num;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSNumber *unReaded;

-(void) conver : (NSDictionary *)json;
@end
