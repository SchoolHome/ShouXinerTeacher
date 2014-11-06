//
//  DiscoverOperation.h
//  teacher
//
//  Created by singlew on 14/11/6.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmOperation.h"

typedef enum{
    kGetDiscover,
}DiscoverType;

@interface DiscoverOperation : PalmOperation
-(DiscoverOperation *) initGetDiscoverInfo;
@end
