//
//  BBWorkTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBWorkTableViewCell.h"

@interface BBWorkTableViewCell ()
@end

@implementation BBWorkTableViewCell


-(void)imageButtonTaped:(EGOImageButton *)sender{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbBaseTableViewCell:imageButtonTaped:)]) {
        [self.delegate bbBaseTableViewCell:self imageButtonTaped:sender];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(K_LEFT_PADDING, 0, 200, 20)];
        [self addSubview:title];
        title.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        title.backgroundColor = [UIColor clearColor];
        
        self.TuiJianImage = [[UIImageView alloc] initWithFrame:CGRectMake(title.frame.origin.x + title.frame.size.width, 2.0f, 15.0f, 15.0f)];
        self.TuiJianImage.image = [UIImage imageNamed:@"BJQTuiJian"];
        self.TuiJianImage.hidden = YES;
        [self addSubview:self.TuiJianImage];
        
        self.RongYuImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.TuiJianImage.frame.origin.x + 20.0f, 2.0f, 15.0f, 15.0f)];
        self.RongYuImage.image = [UIImage imageNamed:@"BJQRongYun"];
        self.RongYuImage.hidden = YES;
        [self addSubview:self.RongYuImage];
        
        mark = [[UIImageView alloc] initWithFrame:CGRectMake(K_LEFT_PADDING, 20, 41, 41)];
        [self addSubview:mark];
        //mark.backgroundColor = [UIColor redColor];
        mark.image = [UIImage imageNamed:@"BBYuWen"];

        contentBack = [[UIImageView alloc] init];
        [self addSubview:contentBack];
        
        content = [[UILabel alloc] init];
        [self addSubview:content];
        content.backgroundColor = [UIColor clearColor];
        
        for (int i = 0; i<8; i++) {
            imageContent[i] = [[EGOImageButton alloc] init];
            imageContent[i].tag = i;
            [self addSubview:imageContent[i]];
            [imageContent[i] addTarget:self action:@selector(imageButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
    
    return self;
}

-(void)setData:(BBTopicModel *)data{
    [super setData:data];

    title.text = self.data.author_username;
    title.font = [UIFont systemFontOfSize:14];
    title.lineBreakMode = NSLineBreakByTruncatingTail;
    [title sizeToFit];
    
    if (data.recommended) {
        self.TuiJianImage.frame = CGRectMake(title.frame.origin.x + title.frame.size.width + 5.0f, 2.0f, 15.0f, 15.0f);
        self.TuiJianImage.hidden = NO;
    }else{
        self.TuiJianImage.frame = CGRectMake(title.frame.origin.x + title.frame.size.width + 5.0f, 2.0f, 15.0f, 15.0f);
        self.TuiJianImage.hidden = YES;
    }
    
    content.frame = CGRectMake(K_LEFT_PADDING+43, 20+3, 175, 50);
    content.text = self.data.content;
    content.font = [UIFont systemFontOfSize:14];
    content.numberOfLines = 0;
    [content sizeToFit];
    
    if (content.frame.size.height>=(41-6)) {
        contentBack.frame = CGRectMake(K_LEFT_PADDING+41, 20, 180, kViewHeight(content)+6); //content.frame;
    }else{
        contentBack.frame = CGRectMake(K_LEFT_PADDING+41, 20, 180, 41);
    }
    
    UIImage *backimage = [UIImage imageNamed:@"BBYuWenContent"];

    if ([self.data.topictype intValue]==2) { // 作业
        //
        switch ([self.data.subject intValue]) {
            case 1:
            {
                mark.image = [UIImage imageNamed:@"BBShuXue"];
                backimage = [UIImage imageNamed:@"BBShuXueContent"];
            }
                break;
            case 2:
            {
                mark.image = [UIImage imageNamed:@"BBYuWen"];
                backimage = [UIImage imageNamed:@"BBYuWenContent"];
            }
                break;
            case 3:
            {
                mark.image = [UIImage imageNamed:@"BBOther"];
                backimage = [UIImage imageNamed:@"BBOtherContent"];
            }
                break;
            case 4:
            {
                mark.image = [UIImage imageNamed:@"BBOther"];
                backimage = [UIImage imageNamed:@"BBOtherContent"];
            }
                break;
            case 5:
            {
                mark.image = [UIImage imageNamed:@"BBOther"];
                backimage = [UIImage imageNamed:@"BBOtherContent"];
            }
                break;
            case 6:
            {
                mark.image = [UIImage imageNamed:@"BBOther"];
                backimage = [UIImage imageNamed:@"BBOtherContent"];
            }
                break;
                
            default:
                mark.image = [UIImage imageNamed:@"BBOther"];
                backimage = [UIImage imageNamed:@"BBOtherContent"];
                break;
        }
        
    }else{  // 通知
    
//        mark.image = [UIImage imageNamed:@"BBComentNotification"];
//        backimage = [UIImage imageNamed:@"BBComentNotificationContent"];
        mark.image = [UIImage imageNamed:@"BBComentNotification"];
        backimage = [UIImage imageNamed:@"BBYuWenContent"];
    }
    
    backimage = [backimage resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,30) resizingMode:UIImageResizingModeStretch];
    contentBack.image = backimage;
    
    
    for (int i = 0; i<7; i++) {
        imageContent[i].hidden = YES;
    }
    
    if ([self.data.imageList count]>0) {
        for (int i = 0; i<[self.data.imageList count]; i++) {
            
            if(i<8&&i>=6){
                imageContent[i].frame = CGRectMake(K_LEFT_PADDING+(i-6)*80, kViewFoot(contentBack)+5+80*2, 75, 75);
                imageContent[i].backgroundColor = [UIColor grayColor];
            }else if(i<6&&i>=3){
                imageContent[i].frame = CGRectMake(K_LEFT_PADDING+(i-3)*80, kViewFoot(contentBack)+5+80, 75, 75);
                imageContent[i].backgroundColor = [UIColor grayColor];
            }else if (i<3) {
                imageContent[i].frame = CGRectMake(K_LEFT_PADDING+i*80, kViewFoot(contentBack)+5, 75, 75);
                imageContent[i].backgroundColor = [UIColor grayColor];
            }
            
            imageContent[i].hidden = NO;
            
            NSString *url = [NSString stringWithFormat:@"%@/mlogo",self.data.imageList[i]];
            imageContent[i].imageURL = [NSURL URLWithString:url];
        }
    }
    
    // 有图片
    CGFloat timeBegin = 0;
    if ([self.data.imageList count]>0) {
        timeBegin = kViewFoot(imageContent[[self.data.imageList count]-1]);
    }else{
        timeBegin = kViewFoot(contentBack);
    }
    
    self.moreButton.frame = CGRectMake(270.0f, timeBegin+12, 22.0f, 15.0f);
//
//    self.reply.frame = CGRectMake(165+70, timeBegin+5, 62, 27);
    
    self.time.frame = CGRectMake(K_LEFT_PADDING, timeBegin+5, 60, 27);
    self.time.text = [self timeStringFromNumber:self.data.ts];
    
    if ([self.data.praisesStr length]>0||[self.data.commentsStr length]>0) {
        //
//        self.relpyContent.hidden = YES;
        for (int i = 0 ; i<[self.labelArray count]; i++) {
            OHAttributedLabel *tempLabel = [self.labelArray objectAtIndex:i];
            UIButton *tempButton = [self.buttonArray objectAtIndex:i];
            [tempLabel removeFromSuperview];
            [tempButton removeFromSuperview];
        }
        [self.labelArray removeAllObjects];
        [self.buttonArray removeAllObjects];
        
        self.likeContent.hidden = NO;
        self.relpyContentBack.hidden = NO;
        self.relpyContentLine.hidden = NO;
        UIFont *font = [UIFont fontWithName:[self.likeContent.font fontName] size:12];
        CGSize size = [self.data.praisesStr sizeWithFont:font constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0];
        if (size.height < 25) {
            size.height = 25;
        }
        self.likeContent.frame = CGRectMake(K_LEFT_PADDING+35, kViewFoot(self.time)+10+16, 180.f, size.height);
        self.likeContent.text = self.data.praisesStr;
        
        self.relpyContentLine.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time)+10+18+size.height, 220, 2);
        UIImage *image1 = [UIImage imageNamed:@"BBComentX"];
        self.relpyContentLine.image = image1;
        
        CGSize s = [self.data.commentsStr sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)];
        
        CGSize per = CGSizeMake(K_LEFT_PADDING+5, kViewFoot(self.time)+10+22+size.height);
        int i = 1;
        self.labelArray = [[NSMutableArray alloc] init];
        self.buttonArray = [[NSMutableArray alloc] init];
        for (NSMutableAttributedString *str in self.data.commentStr) {
            CGSize temp = [str sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)];
            OHAttributedLabel *replay = [[OHAttributedLabel alloc] init];
            replay.frame = CGRectMake(per.width, per.height, 210, temp.height);
            replay.attributedText = str;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = replay.frame;
            [button addTarget:self action:@selector(hEvent:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i;
            [self addSubview:replay];
            [self addSubview:button];
            [self.labelArray addObject:replay];
            [self.buttonArray addObject:button];
            i++;
            per.height = replay.frame.origin.y + replay.frame.size.height;
        }
//        self.relpyContent.frame = CGRectMake(K_LEFT_PADDING+5, kViewFoot(self.time)+10+22+size.height, 210, s.height);
//        self.relpyContent.attributedText = self.data.commentsStr;
        
        UIImage *image2 = [UIImage imageNamed:@"BBComentBG"];
        image2 = [image2 resizableImageWithCapInsets:UIEdgeInsetsMake(45,35,14,100) resizingMode:UIImageResizingModeStretch];
        
        CGFloat imageHeight = s.height+10+22+size.height;
        if (imageHeight < 60) {
            imageHeight = 60;
        }
        self.userInteractionEnabled = YES;
        self.relpyContentBack.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time)+10, 210+10, imageHeight);
        self.relpyContentBack.image = image2;
        self.relpyContentBack.userInteractionEnabled = YES;
    }else{
//        self.relpyContent.hidden = YES;
        self.likeContent.hidden = YES;
        self.relpyContentBack.hidden = YES;
        self.relpyContentLine.hidden = YES;
        for (int i = 0 ; i<[self.labelArray count]; i++) {
            OHAttributedLabel *tempLabel = [self.labelArray objectAtIndex:i];
            UIButton *tempButton = [self.buttonArray objectAtIndex:i];
            [tempLabel removeFromSuperview];
            [tempButton removeFromSuperview];
        }
        [self.labelArray removeAllObjects];
        [self.buttonArray removeAllObjects];
    }
    
    //[self showDebugRect:YES];
}


-(EGOImageButton *) imageContentWithIndex:(int)index{
    return imageContent[index];
}


@end
