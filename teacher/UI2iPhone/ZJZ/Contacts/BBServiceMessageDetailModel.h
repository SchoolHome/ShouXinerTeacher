//
//  BBServiceMessageDetailModel.h
//  teacher
//
//  Created by ZhangQing on 14/11/27.
//  Copyright (c) 2014年 ws. All rights reserved.
//

typedef enum
{
    DETAIL_CELL_TYPE_MUTIL = 1,
    DETAIL_CELL_TYPE_SINGLE = 2,
    
}DETAIL_CELL_TYPE;

#import <Foundation/Foundation.h>

@interface BBServiceMessageDetailModel : NSObject

@property (nonatomic)DETAIL_CELL_TYPE type;
@property (nonatomic, strong)NSString *bannerImageUrl;
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSArray *items;


@end
