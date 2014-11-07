//
//  BBFXModel.h
//  teacher
//
//  Created by mac on 14/11/7.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBFXModel : NSObject
@property (nonatomic, strong) NSString *discoverID;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL isNew;
-(id)initWithJson:(NSDictionary *)dic;
@end
