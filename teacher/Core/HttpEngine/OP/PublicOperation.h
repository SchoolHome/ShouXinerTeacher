//
//  PubulicOperation.h
//  teacher
//
//  Created by singlew on 14/11/20.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "PalmOperation.h"
typedef enum{
    kGetPublicMessage,
    kPostPublicMessage,
}PublicMessageType;
@interface PublicOperation : PalmOperation
-(PublicOperation *) initGetPublicMessage : (NSString *) mids;
-(PublicOperation *) initPostPublicMessageForward : (NSString *) mid withGroupID : (int) groupID withMessage : (NSString *) message;
@end
