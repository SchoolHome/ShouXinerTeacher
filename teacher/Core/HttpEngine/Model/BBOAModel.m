//
//  BBOAModel.m
//  teacher
//
//  Created by xxx on 14-4-2.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBOAModel.h"

@implementation BBOASumModel

-(id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (nil != self) {
        self.cacheArray = [aDecoder decodeObjectForKey:@"cacheArray"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.cacheArray forKey:@"cacheArray"];
}

-(void) updateCacheArray : (NSArray *) oaModelArray{
    if (nil == self.cacheArray) {
        self.cacheArray = [[NSMutableArray alloc] init];
    }
    
    [oaModelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BBOAModel *model = obj;
        bool isFound = NO;
        
        for (BBOAModel *sumModel in self.cacheArray) {
            if ([model.sender_uid isEqual:sumModel.sender_uid]) {
                isFound = YES;
                int unReaded = [sumModel.unReaded intValue] + 1;
                sumModel.unReaded = [NSNumber numberWithInt:unReaded];
                break;
            }
        }
        if (!isFound) {
            model.unReaded = [NSNumber numberWithInt:1];
            [self.cacheArray addObject:model];
        }
    }];
    [PalmUIModelCoding serializeModel:self.cacheArray withFileName:CacheName];
}

-(void) updateCacheUnReadedWithZero:(NSNumber *) senderUid{
    [self.cacheArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BBOAModel *model = obj;
        if ([model.sender_uid longValue] == [senderUid longValue]) {
            model.unReaded = [NSNumber numberWithInt:0];
        }
    }];
    [PalmUIModelCoding serializeModel:self.cacheArray withFileName:CacheName];
}

@end

@implementation BBOAModel

-(id) initWithCoder:(NSCoder *)aDecoder{
    /*
     @property(nonatomic,strong) NSNumber *oaid;
     @property(nonatomic,strong) NSNumber *sender_uid;
     @property(nonatomic,strong) NSString *sender_username;
     @property(nonatomic,strong) NSString *sender_avatar;
     @property(nonatomic,strong) NSNumber *title;
     @property(nonatomic,strong) NSString *content;
     @property(nonatomic,strong) NSNumber *ts;
     @property(nonatomic,strong) NSNumber *attach_num;
     @property(nonatomic,strong) NSString *url;
     */
    
    self = [super initWithCoder:aDecoder];
    if (nil != self) {
        self.oaid = [aDecoder decodeObjectForKey:@"oaid"];
        self.sender_uid = [aDecoder decodeObjectForKey:@"sender_uid"];
        self.sender_username = [aDecoder decodeObjectForKey:@"sender_username"];
        self.sender_avatar = [aDecoder decodeObjectForKey:@"sender_avatar"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.ts = [aDecoder decodeObjectForKey:@"ts"];
        self.attach_num = [aDecoder decodeObjectForKey:@"attach_num"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.unReaded = [aDecoder decodeObjectForKey:@"unReaded"];
    }
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.oaid forKey:@"oaid"];
    [aCoder encodeObject:self.sender_uid forKey:@"sender_uid"];
    [aCoder encodeObject:self.sender_username forKey:@"sender_username"];
    [aCoder encodeObject:self.sender_avatar forKey:@"sender_avatar"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.ts forKey:@"ts"];
    [aCoder encodeObject:self.attach_num forKey:@"attach_num"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.unReaded forKey:@"unReaded"];
}


-(void) conver : (NSDictionary *)json{
    if (nil != json) {
        self.oaid = json[@"oaid"];
        self.sender_uid = json[@"sender_uid"];
        self.sender_username = json[@"sender_username"];
        
        if (json[@"sender_avatar"]&&![json[@"sender_avatar"] isKindOfClass:[NSNull class]]) {
            self.sender_avatar = json[@"sender_avatar"];
        }
        self.title = json[@"title"];
        self.content = json[@"content"];
        self.ts = json[@"ts"];
        self.attach_num = json[@"attach_num"];
        self.url = json[@"url"];
        self.unReaded = [NSNumber numberWithInt:0];
    }
}

@end












