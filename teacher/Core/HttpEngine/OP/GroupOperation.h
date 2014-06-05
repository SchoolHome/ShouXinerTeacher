//
//  GroupOperation.h
//  teacher
//
//  Created by singlew on 14-3-17.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmOperation.h"

typedef enum {
    kGetGroupList,
    kGetGroupStudent,
}GroupListType;

@interface GroupOperation : PalmOperation
-(GroupOperation *) initGetGroupList;
-(GroupOperation *) initGetGroupStudent : (NSString *) groupids;
@property(nonatomic) GroupListType type;
@end
