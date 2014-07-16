//
//  AFTableViewCell.m
//  AllFriends_dev
//
//  Created by ming bright on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AFTableViewCell.h"
#import "UIView+DebugRect.h"
@implementation AFTableViewCell

@synthesize delegate = _delegate;
@synthesize cellData = _cellData;
@synthesize cellIndexPath = _cellIndexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        for (int i = 0; i<4; i++) {
            _item[i] = [[AFHeadItem alloc] initWithFrame:CGRectMake(10+i*(55+20), 0, 55+20, 80+10)];
            _item[i].backgroundColor = [UIColor clearColor];
            _item[i].delegate = self;
            [self addSubview:_item[i]];
            
#ifdef RECTDEBUG
            [self showDebugRect:YES];
#endif
        }
    }
    return self;
}

-(void)setCellIndexPath:(NSIndexPath *)cellIndexPath_{
    _cellIndexPath = cellIndexPath_;
    for (int i= 0; i<4; i++) {
        _item[i].indexPath = [AFIndexPath indexPathWithCellIndexPath:_cellIndexPath itemIndex:i];
    }
}

-(void)setCellData:(NSArray *)cellData_{
    _cellData = cellData_;
    
    int count = [_cellData count];
    
    for (int i = 0; i<4; i++) {
        if (i<count) {
            _item[i].hidden = NO;
            _item[i].headItemData = [_cellData objectAtIndex:i];
        }else {
            _item[i].hidden = YES;
            _item[i].headItemData = nil;
        }
    }
}

@end
