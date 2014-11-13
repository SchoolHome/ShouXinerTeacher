//
//  MessageGroupCell.m
//  teacher
//
//  Created by ZhangQing on 14-3-16.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBMessageGroupBaseCell.h"
#import "CoreUtils.h"
#import "DateUtil.h"
@implementation BBMessageGroupBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.imageView setImage:[UIImage imageNamed:@"BJQPraise"]];
        
        //姓名
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.f, 10.f, 160.f, 18.f)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.textColor = [UIColor colorWithRed:75/255.f green:120/255.f blue:148/255.f alpha:1.f];
        //_userNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _userNameLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_userNameLabel];
        //内容
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.f, 40.f, 200.f, 18.f)];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textColor = [UIColor colorWithRed:110/255.f green:110/255.f blue:110/255.f alpha:1.f];
        _contentLabel.font = [UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:_contentLabel];
        //头像
        _userHeadImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(5.f, 10.f, 50.f, 50.f)];
        [self.contentView addSubview:_userHeadImageView];
        //时间
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(255.f, 8.f, 70.f, 14.f)];
        _dateLabel.textColor = [UIColor colorWithRed:110/255.f green:110/255.f blue:110/255.f alpha:1.f];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont systemFontOfSize:12.f];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_dateLabel];
        
        _imageviewMessageAlert = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *tempImage = [UIImage imageNamed:@"ZJZBaige"];
        UIImage *image = [tempImage stretchableImageWithLeftCapWidth:tempImage.size.width/2.f topCapHeight:0];
        [self.imageviewMessageAlert setImage:image];
        [self.contentView addSubview:_imageviewMessageAlert];
        

        //未读数
//        _unreadedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10.f, 20.f, 20.f)];
//        _unreadedCountLabel.textAlignment = NSTextAlignmentCenter;
//        _unreadedCountLabel.backgroundColor = [UIColor orangeColor];
//        _unreadedCountLabel.font = [UIFont boldSystemFontOfSize:18.f];
//        _unreadedCountLabel.textColor = [UIColor whiteColor];
//        _unreadedCountLabel.font = [UIFont systemFontOfSize:9];
//        _unreadedCountLabel.layer.cornerRadius = 10.0;
//        _unreadedCountLabel.layer.borderWidth = 0.5;
//        _unreadedCountLabel.layer.borderColor = [[UIColor grayColor] CGColor];
//        [self.contentView addSubview:_unreadedCountLabel];

        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:212/255.f green:212/255.f blue:212/255.f alpha:1.f];
    }else
    {
        //self.contentView.backgroundColor = [UIColor colorWithRed:242/255.f green:236/255.f blue:230/255.f alpha:1.f];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    // Configure the view for the selected state
}

#pragma mark setter
//notifyMessage change
-(void)setUIModelMsgGroup:(CPUIModelMessageGroup *)msgGroup
{
        if (msgGroup) {
            _msgGroup = msgGroup;
            if ([msgGroup.unReadedCount integerValue] == 0) self.imageviewMessageAlert.hidden = YES;
            else self.imageviewMessageAlert.hidden = NO;
            
            
            //        if ([msgGroup.unReadedCount integerValue] < 100) {
            //            _unreadedCountLabel.text = [NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]];
            //        }else {
            //            _unreadedCountLabel.text = @"99+";
            //        }
            //        [_unreadedCountLabel sizeThatFits:CGSizeMake(20, 20)];
            //        _unreadedCountLabel.layer.cornerRadius = 10.0;
            //        _unreadedCountLabel.layer.borderWidth = 0.5;
            //        _unreadedCountLabel.layer.borderColor = [[UIColor grayColor] CGColor];
            
//            if ([msgGroup.unReadedCount integerValue] < 100) {
//                CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]] sizeWithFont:[UIFont systemFontOfSize:12]];
//                [self.imageviewMessageAlert setFrame:CGRectMake(55/4*3.f-unReaderTextSize.width/2.f, -55/4.f+15.f, unReaderTextSize.width + 13.f, 20.f)];
//            }else {
//                CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d+",99] sizeWithFont:[UIFont systemFontOfSize:12]];
//                [self.imageviewMessageAlert setFrame:CGRectMake(55/4*3.f-unReaderTextSize.width/2.f, -55/4.f+15.f, unReaderTextSize.width + 10.f, 20.f)];
//            }
            
            if ([msgGroup.unReadedCount integerValue] < 100) {
                CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]] sizeWithFont:[UIFont systemFontOfSize:12]];
                [self.imageviewMessageAlert setFrame:CGRectMake(320-unReaderTextSize.width-30.f, CGRectGetMaxY(_dateLabel.frame)+10.f, unReaderTextSize.width + 13.f, 20.f)];
            }else {
                CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d+",99] sizeWithFont:[UIFont systemFontOfSize:12]];
                [self.imageviewMessageAlert setFrame:CGRectMake(320-unReaderTextSize.width-30.f, CGRectGetMaxY(_dateLabel.frame)+10.f, unReaderTextSize.width + 10.f, 20.f)];
            }
            
            //未读数
            
            
            if (!_unreadedCountLabel) {
                _unreadedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(3.f, 4.f, self.imageviewMessageAlert.frame.size.width-6, 12)];
                _unreadedCountLabel.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
                _unreadedCountLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.f];
                _unreadedCountLabel.backgroundColor = [UIColor clearColor];
                _unreadedCountLabel.textAlignment = UITextAlignmentCenter;
                [self.imageviewMessageAlert addSubview:_unreadedCountLabel];
            }else {
                [_unreadedCountLabel setFrame:CGRectMake(3.f, 4.f, self.imageviewMessageAlert.frame.size.width-6, 12)];
            }
            if ([msgGroup.unReadedCount integerValue] < 100) {
                _unreadedCountLabel.text = [NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]];
            }else {
                _unreadedCountLabel.text = @"99+";
            }
            
            
            
            if (msgGroup.msgList.count >0) {
                CPUIModelMessage *message = [msgGroup.msgList objectAtIndex:msgGroup.msgList.count-1];
                // _dateLabel.text = [CoreUtils getStringNormalFormatWithNumber:msgGroup.updateDate];
                if ([message.date longLongValue]/1000 > [msgGroup.updateDate longLongValue]/1000 ) {
                    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:[message.date longLongValue]/1000];
                    //NSString *messageStr = [[HomeInfo shareObject] compareDate:messageDate];
                    NSString *messageStr = [[[DateUtil alloc] init] compareDate:messageDate];
                    _dateLabel.text = messageStr;
                    
                }else {
                    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:[msgGroup.updateDate longLongValue]/1000];
                    //NSString *messageStr = [[HomeInfo shareObject] compareDate:messageDate];
                    NSString *messageStr = [[[DateUtil alloc] init] compareDate:messageDate];
                    _dateLabel.text = messageStr;
                    
                }
                
                if ([message.flag integerValue] == MSG_FLAG_RECEIVE) {
                    switch ([message.contentType integerValue]) {
                        case MSG_CONTENT_TYPE_TEXT:
                        {
                            _contentLabel.text = message.msgText;
                        }
                            break;
                        case MSG_CONTENT_TYPE_IMG:
                        {
                            _contentLabel.text = @"收到一张图片";
                        }
                            break;
                        case MSG_CONTENT_TYPE_AUDIO:
                        {
                            _contentLabel.text = @"收到一条语音";
                        }
                            break;
                        case MSG_CONTENT_TYPE_VIDEO:
                        {
                            _contentLabel.text = @"收到一段视频";
                        }
                            break;
                        default:
                        {
                            _contentLabel.text = message.msgText;
                        }
                            break;
                    }
                }else
                {
                    switch ([message.contentType integerValue]) {
                        case MSG_CONTENT_TYPE_TEXT:
                        {
                            _contentLabel.text = [NSString stringWithFormat:@"我:%@",message.msgText];
                        }
                            break;
                        case MSG_CONTENT_TYPE_IMG:
                        {
                            _contentLabel.text = @"我:发送一张图片";
                        }
                            break;
                        case MSG_CONTENT_TYPE_AUDIO:
                        {
                            _contentLabel.text = @"我:发送一条语音";
                        }
                            break;
                        case MSG_CONTENT_TYPE_VIDEO:
                        {
                            _contentLabel.text = @"我:发送一断视频";
                        }
                            break;
                        default:
                        {
                            _contentLabel.text = message.msgText;
                        }
                            break;
                    }
                }
                
            }else
            {
                NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:[msgGroup.updateDate longLongValue]/1000];
                NSString *messageStr = [[[DateUtil alloc] init] compareDate:messageDate];
                _dateLabel.text = messageStr;
                _contentLabel.text = @"你们还没聊过天哦，快来说两句";
            }
        }
}

-(void)setDBModelNotifyMsgGroup:(CPDBModelNotifyMessage *)msgGroup
{
    if (msgGroup) {
        _msgGroup = msgGroup;
        if ([msgGroup.unReadedCount integerValue] == 0) self.imageviewMessageAlert.hidden = YES;
        else self.imageviewMessageAlert.hidden = NO;
        
        
        //        if ([msgGroup.unReadedCount integerValue] < 100) {
        //            _unreadedCountLabel.text = [NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]];
        //        }else {
        //            _unreadedCountLabel.text = @"99+";
        //        }
        //        [_unreadedCountLabel sizeThatFits:CGSizeMake(20, 20)];
        //        _unreadedCountLabel.layer.cornerRadius = 10.0;
        //        _unreadedCountLabel.layer.borderWidth = 0.5;
        //        _unreadedCountLabel.layer.borderColor = [[UIColor grayColor] CGColor];
        
        if ([msgGroup.unReadedCount integerValue] < 100) {
            CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]] sizeWithFont:[UIFont systemFontOfSize:12]];
            [self.imageviewMessageAlert setFrame:CGRectMake(320-unReaderTextSize.width-30.f, CGRectGetMaxY(_dateLabel.frame)+10.f, unReaderTextSize.width + 13.f, 20.f)];
        }else {
            CGSize unReaderTextSize = [[NSString stringWithFormat:@"%d+",99] sizeWithFont:[UIFont systemFontOfSize:12]];
            [self.imageviewMessageAlert setFrame:CGRectMake(320-unReaderTextSize.width-30.f, CGRectGetMaxY(_dateLabel.frame)+10.f, unReaderTextSize.width + 10.f, 20.f)];
        }
        
        //未读数
        
        
        if (!_unreadedCountLabel) {
            _unreadedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(3.f, 4.f, self.imageviewMessageAlert.frame.size.width-6, 12)];
            _unreadedCountLabel.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
            _unreadedCountLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.f];
            _unreadedCountLabel.backgroundColor = [UIColor clearColor];
            _unreadedCountLabel.textAlignment = UITextAlignmentCenter;
            [self.imageviewMessageAlert addSubview:_unreadedCountLabel];
        }else {
            [_unreadedCountLabel setFrame:CGRectMake(3.f, 4.f, self.imageviewMessageAlert.frame.size.width-6, 12)];
        }
        if ([msgGroup.unReadedCount integerValue] < 100) {
            _unreadedCountLabel.text = [NSString stringWithFormat:@"%d",[msgGroup.unReadedCount integerValue]];
        }else {
            _unreadedCountLabel.text = @"99+";
        }
        
        
        
        NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:[msgGroup.date longLongValue]/1000];
        //NSString *messageStr = [[HomeInfo shareObject] compareDate:messageDate];
        NSString *messageStr = [[[DateUtil alloc] init] compareDate:messageDate];
        _dateLabel.text = messageStr;
        _contentLabel.text = msgGroup.content;
        
    }
}

@end
