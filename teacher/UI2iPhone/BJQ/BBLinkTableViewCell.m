//
//  BBLinkTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBLinkTableViewCell.h"

@implementation BBLinkTableViewCell


-(void)linkButtonTaped:(id)sender{

    if (self.delegate&&[self.delegate respondsToSelector:@selector(bbBaseTableViewCell:linkButtonTaped:)]) {
        [self.delegate bbBaseTableViewCell:self linkButtonTaped:sender];
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
        
        content = [[UILabel alloc] init];
        [self addSubview:content];
        content.backgroundColor = [UIColor clearColor];
        
        link = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self addSubview:link];
        [link setBackgroundImage:[UIImage imageNamed:@"BBNotification"] forState:UIControlStateNormal];
        link.backgroundColor = [UIColor clearColor];
        [link addTarget:self action:@selector(linkButtonTaped:) forControlEvents:UIControlEventTouchUpInside];
        
        linkIcon = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        [link addSubview:linkIcon];
        
        linkTitle = [[UILabel alloc] initWithFrame:CGRectMake(65, 5, 160, 20)];
        [link addSubview:linkTitle];
        linkTitle.backgroundColor = [UIColor clearColor];
        
        linkContent = [[UILabel alloc] initWithFrame:CGRectMake(65, 25, 155, 30)];
        [link addSubview:linkContent];
        linkContent.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        linkContent.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)setData:(BBTopicModel *)data{
    [super setData:data];
    
    content.frame = CGRectMake(K_LEFT_PADDING, 20, 225, 30);//
    
    //
//    link.backgroundColor = [UIColor whiteColor];
//    CALayer *roundedLayer = [link layer];
//    [roundedLayer setMasksToBounds:YES];
//    roundedLayer.cornerRadius = 8.0;
//    roundedLayer.borderWidth = 1;
//    roundedLayer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    linkIcon.backgroundColor = [UIColor grayColor];
    
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
    
    content.text = self.data.content;
    content.font = [UIFont systemFontOfSize:14];
    content.numberOfLines = 0;
    [content sizeToFit];
    
    linkTitle.text = self.data.forward.title;
    linkTitle.font = [UIFont systemFontOfSize:14];
    
    linkContent.text = self.data.forward.summary;
    linkContent.font = [UIFont systemFontOfSize:12];
    linkContent.numberOfLines = 2;
    
    if (self.data.forward.author_avatar) {
        
        NSString *url = [NSString stringWithFormat:@"%@/mlogo",self.data.forward.author_avatar];
        linkIcon.imageURL = [NSURL URLWithString:url];
    }
    
    link.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(content)+5, 222, 63);
    
    self.like.frame = CGRectMake(165, kViewFoot(link)+5, 62, 27);
    self.reply.frame = CGRectMake(165+70, kViewFoot(link)+5, 62, 27);
    
    self.time.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(link)+5, 60, 27);
    self.time.text = [self timeStringFromNumber:self.data.ts];
    
    if ([self.data.praisesStr length]>0||[self.data.commentsStr length]>0) {
        //
//        self.relpyContent.hidden = NO;
        self.likeContent.hidden = NO;
        self.relpyContentBack.hidden = NO;
        self.relpyContentLine.hidden = NO;
        for (int i = 0 ; i<[self.labelArray count]; i++) {
            OHAttributedLabel *tempLabel = [self.labelArray objectAtIndex:i];
            UIButton *tempButton = [self.buttonArray objectAtIndex:i];
            [tempLabel removeFromSuperview];
            [tempButton removeFromSuperview];
        }
        [self.labelArray removeAllObjects];
        [self.buttonArray removeAllObjects];
        
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
        
        self.relpyContentBack.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time)+10, 210+10, imageHeight);
        self.relpyContentBack.image = image2;
    }else{
//        self.relpyContent.hidden = YES;
        self.likeContent.hidden = YES;
        self.relpyContentBack.hidden = YES;
        self.relpyContentLine.hidden = YES;
//        for (UIView *view in self.subviews) {
//            if ([view isMemberOfClass:[OHAttributedLabel class]]) {
//                [view removeFromSuperview];
//            }
//            if ([view isMemberOfClass:[UIButton class]]) {
//                if (view.tag != 0) {
//                    [view removeFromSuperview];
//                }
//            }
//        }
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

@end
