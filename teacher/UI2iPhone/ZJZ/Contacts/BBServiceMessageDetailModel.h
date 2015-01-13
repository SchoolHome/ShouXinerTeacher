//
//  BBServiceMessageDetailModel.h
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

typedef enum
{
    DETAIL_CELL_TYPE_BANNER = 1,
    DETAIL_CELL_TYPE_SINGLE = 2,
    
}DETAIL_CELL_TYPE;

#import <Foundation/Foundation.h>

@interface BBServiceMessageDetailModel : NSObject

@property (nonatomic, strong)NSString *mid;
@property (nonatomic)DETAIL_CELL_TYPE type;
@property (nonatomic, strong)NSString *imageUrl;
@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSString *avatar;
@property (nonatomic, strong)NSString *link;
@property (nonatomic, strong)NSNumber *ts;
@property (nonatomic, strong)NSString *userName;
@property (nonatomic, strong)NSNumber *uid;
@property (nonatomic, strong)NSString *title;

+ (BBServiceMessageDetailModel  *)convertByDic:(NSDictionary *)dic;
+ (BBServiceMessageDetailModel  *)convertByNotifyMsgDic:(NSDictionary *)dic;
@end
