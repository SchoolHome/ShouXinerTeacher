//
//  BBProfileModel.h
//  teacher
//
//  Created by mac on 14/11/12.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBProfileModel : NSObject
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *jid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic) NSInteger sex;
@property (nonatomic, strong) NSString *brithday;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *cityname;
@property (nonatomic, strong) NSString *city;
+(id)shareProfileModel;
-(void)coverWithJson:(NSDictionary *)jsonDic;
@end
