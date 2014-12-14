//
//  BBPBXTableViewCell.m
//  teacher
//
//  Created by singlew on 14-6-5.
//  Copyright (c) 2014年 ws. All rights reserved.
//

#import "BBPBXTableViewCell.h"

@implementation BBPBXTableViewCell

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
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(K_LEFT_PADDING, 10, 200, 20)];
        [self addSubview:title];
        title.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        title.backgroundColor = [UIColor clearColor];
        
        typeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"state"]];
        typeImage.frame = CGRectMake(280.0f, 10.0f, 28.0f, 15.0f);
        [self addSubview:typeImage];
        
        self.RongYuImage = [[UIImageView alloc] initWithFrame:CGRectMake(typeImage.frame.origin.x - 25.0f, 7.0f, 15, 24.0f)];
        self.RongYuImage.image = [UIImage imageNamed:@"BJQRongYun"];
        self.RongYuImage.hidden = YES;
        [self addSubview:self.RongYuImage];
        
        self.TuiJianImage = [[UIImageView alloc] initWithFrame:CGRectMake(typeImage.frame.origin.x - 50.0f, 2.0f, 15, 24.0f)];
        self.TuiJianImage.image = [UIImage imageNamed:@"BJQTuiJian"];
        self.TuiJianImage.hidden = YES;
        [self addSubview:self.TuiJianImage];
        
        
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

-(EGOImageButton *) imageContentWithIndex:(int)index{
    return imageContent[index];
}

-(void)setData:(BBTopicModel *)data{
    [super setData:data];
    title.text = self.data.author_username;
    title.font = [UIFont systemFontOfSize:14];
    title.lineBreakMode = NSLineBreakByTruncatingTail;
    [title sizeToFit];
    
    content.frame = CGRectMake(K_LEFT_PADDING, title.frame.origin.y + title.frame.size.height + 10.0f, 225, 0);
    
    if (data.recommended) {
        self.TuiJianImage.hidden = NO;
    }else{
        self.TuiJianImage.hidden = YES;
    }
    
    if (data.award) {
        self.RongYuImage.hidden = NO;
    }else{
        self.RongYuImage.hidden = YES;
    }
    
    content.text = self.data.content;
    content.font = [UIFont systemFontOfSize:14];
    content.numberOfLines = 0;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [content addGestureRecognizer:longPress];
    content.userInteractionEnabled = YES;
    [content sizeToFit];
    
    
    for (int i = 0; i<8; i++) {
        imageContent[i].hidden = YES;
    }
    
    if ([self.data.imageList count]>0) {
        int cnt = [self.data.imageList count];
        for (int i = 0; i<cnt; i++) {
            
            if(i<8&&i>=6){
                imageContent[i].frame = CGRectMake(K_LEFT_PADDING+(i-6)*80, kViewFoot(content)+10+80*2, 75, 75);
                imageContent[i].backgroundColor = [UIColor grayColor];
            }else if(i<6&&i>=3){
                imageContent[i].frame = CGRectMake(K_LEFT_PADDING+(i-3)*80, kViewFoot(content)+10+80, 75, 75);
                imageContent[i].backgroundColor = [UIColor grayColor];
            }else if (i<3) {
                imageContent[i].frame = CGRectMake(K_LEFT_PADDING+i*80, kViewFoot(content)+10, 75, 75);
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
        timeBegin = kViewFoot(content);
    }
    
    if (self.data.recommendToGroups || self.data.recommendToHomepage || self.data.recommendToUpGroup) {
        self.recommendButton.frame = CGRectMake(232.0f, timeBegin + 2.0f, 29.0, 26.0f);
        [self.recommendButton setBackgroundImage:[UIImage imageNamed:@"BJQHasTuiJian"] forState:UIControlStateNormal];
        [self.recommendButton setBackgroundImage:[UIImage imageNamed:@"BJQHasTuiJian"] forState:UIControlStateHighlighted];
        [self.recommendButton removeTarget:self action:@selector(recommendTaped:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.recommendButton.frame = CGRectMake(232.0f, timeBegin + 2.0f, 29.0, 26.0f);
        [self.recommendButton setBackgroundImage:[UIImage imageNamed:@"BJQHaveNotTuiJian"] forState:UIControlStateNormal];
        [self.recommendButton setBackgroundImage:[UIImage imageNamed:@"BJQHaveNotTuiJian"] forState:UIControlStateHighlighted];
        [self.recommendButton addTarget:self action:@selector(recommendTaped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.moreButton.frame = CGRectMake(280.0f, timeBegin + 2.0f, 26.0f, 26.0f);
    self.time.frame = CGRectMake(K_LEFT_PADDING, timeBegin, 60, 30);
    self.time.text = [self timeStringFromNumber:self.data.ts];
    
    self.deleteTopic.frame = CGRectMake(K_LEFT_PADDING + 62.0f, self.time.frame.origin.y + 6.0f, 40.0f, 20.0f);
    CPLGModelAccount *account = [[CPSystemEngine sharedInstance] accountModel];
    if ([account.uid integerValue] == [data.author_uid integerValue]) {
        self.deleteTopic.hidden = NO;
    }else{
        self.deleteTopic.hidden = YES;
    }
    
    if ([self.data.praisesStr length] > 0 || [self.data.commentsStr length] > 0) {
        self.likeContent.hidden = YES;
        self.relpyContentBack.hidden = YES;
        self.relpyContentLine.hidden = YES;
        self.heart.hidden = YES;
        self.line.hidden = YES;
        for (int i = 0 ; i<[self.labelArray count]; i++) {
            OHAttributedLabel *tempLabel = [self.labelArray objectAtIndex:i];
            UIButton *tempButton = [self.buttonArray objectAtIndex:i];
            [tempLabel removeFromSuperview];
            [tempButton removeFromSuperview];
        }
        [self.labelArray removeAllObjects];
        [self.buttonArray removeAllObjects];
        [self.heart removeFromSuperview];
        [self.line removeFromSuperview];
        
        if ([self.data.praisesStr length]>0 && [self.data.commentsStr length] == 0) {
            UIFont *font = [UIFont fontWithName:[self.likeContent.font fontName] size:12];
            CGSize size = [self.data.praisesStr sizeWithFont:font constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0];
            if (size.height < 17.0f) {
                size.height = 17.0f;
            }
            self.likeContent.frame = CGRectMake(31.0f,15.0f, 180.f, size.height);
            self.likeContent.text = self.data.praisesStr;
            [self.relpyContentBack addSubview:self.likeContent];
            
            self.heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BJQPraise"]];
            self.heart.frame = CGRectMake(7.0f, 15.0f, 18.0f, 16.0f);
            [self.relpyContentBack addSubview:self.heart];
            
            UIImage *contentImage = [[UIImage imageNamed:@"BJQCommentBG"] stretchableImageWithLeftCapWidth:125.0f topCapHeight:19.0f];
            self.relpyContentBack.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time), 250.0f, 23.0f+size.height);
            self.relpyContentBack.image = contentImage;
            self.likeContent.hidden = NO;
            self.relpyContentBack.hidden = NO;
        }else if ([self.data.praisesStr length] == 0 && [self.data.commentsStr length] > 0){
            CGSize per = CGSizeMake(9.0f, 15.0f);
            CGFloat commentHeight = 0.0f;
            int i = 1;
            self.labelArray = [[NSMutableArray alloc] init];
            self.buttonArray = [[NSMutableArray alloc] init];
            for (NSMutableAttributedString *str in self.data.commentStr) {
                NSString *text = [self.data.commentTextArray objectAtIndex:(i-1)];
                CGSize temp = [text sizeWithFont:[UIFont systemFontOfSize:K_REPLY_SIZE] constrainedToSize:CGSizeMake(k_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                commentHeight += temp.height;
                OHAttributedLabel *replay = [[OHAttributedLabel alloc] init];
                replay.frame = CGRectMake(per.width, per.height, k_REPLY_WIDTH, temp.height);
                replay.attributedText = str;
                replay.font = [UIFont systemFontOfSize:K_REPLY_SIZE];
                [replay setBackgroundColor:[UIColor clearColor]];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor clearColor];
                button.frame = replay.frame;
                [button addTarget:self action:@selector(hEvent:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
                [self.relpyContentBack addSubview:replay];
                [self.relpyContentBack addSubview:button];
                [self.labelArray addObject:replay];
                [self.buttonArray addObject:button];
                i++;
                per.height = replay.frame.origin.y + replay.frame.size.height;
            }
            UIImage *contentImage = [[UIImage imageNamed:@"BJQCommentBG"] stretchableImageWithLeftCapWidth:125.0f topCapHeight:19.0f];
            self.relpyContentBack.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time), 250.0f, 23.0f+commentHeight);
            self.relpyContentBack.image = contentImage;
            self.relpyContentBack.hidden = NO;
        }else{
            UIFont *font = [UIFont fontWithName:[self.likeContent.font fontName] size:12];
            CGSize size = [self.data.praisesStr sizeWithFont:font constrainedToSize:CGSizeMake(180.f, CGFLOAT_MAX) lineBreakMode:0];
            if (size.height < 17.0f) {
                size.height = 17.0f;
            }
            self.likeContent.frame = CGRectMake(31.0f,15.0f, 180.f, size.height);
            self.likeContent.text = self.data.praisesStr;
            [self.relpyContentBack addSubview:self.likeContent];
            
            self.heart = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BJQPraise"]];
            self.heart.frame = CGRectMake(7.0f, 15.0f, 18.0f, 16.0f);
            [self.relpyContentBack addSubview:self.heart];
            
            UIImage *lineImage = [UIImage imageNamed:@"BJQCommentLine"];
            self.line = [[UIImageView alloc] initWithImage:lineImage];
            self.line.frame = CGRectMake(5.0f, self.likeContent.frame.origin.y + self.likeContent.frame.size.height + 5.0f, 240.0f, 2.0f);
            [self.relpyContentBack addSubview:self.line];
            
            CGFloat commentHeight = 0.0f;
            CGSize per = CGSizeMake(9.0f, self.line.frame.origin.y + self.line.frame.size.height + 5.0f);
            int i = 1;
            self.labelArray = [[NSMutableArray alloc] init];
            self.buttonArray = [[NSMutableArray alloc] init];
            for (NSMutableAttributedString *str in self.data.commentStr) {
                NSString *text = [self.data.commentTextArray objectAtIndex:(i-1)];
                CGSize temp = [text sizeWithFont:[UIFont systemFontOfSize:K_REPLY_SIZE] constrainedToSize:CGSizeMake(k_REPLY_WIDTH, CGFLOAT_MAX) lineBreakMode:0];
                commentHeight += temp.height;
                OHAttributedLabel *replay = [[OHAttributedLabel alloc] init];
                replay.frame = CGRectMake(per.width, per.height, k_REPLY_WIDTH, temp.height);
                replay.attributedText = str;
                replay.font = [UIFont systemFontOfSize:K_REPLY_SIZE];
                [replay setBackgroundColor:[UIColor clearColor]];
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor redColor];
                button.frame = replay.frame;
                [button addTarget:self action:@selector(hEvent:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = i;
                [self.relpyContentBack addSubview:replay];
                [self.relpyContentBack addSubview:button];
                [self.labelArray addObject:replay];
                [self.buttonArray addObject:button];
                i++;
                per.height = replay.frame.origin.y + replay.frame.size.height;
            }
            UIImage *contentImage = [[UIImage imageNamed:@"BJQCommentBG"] stretchableImageWithLeftCapWidth:125.0f topCapHeight:19.0f];
            self.relpyContentBack.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time), 250.0f, 35.0f + commentHeight + size.height);
            self.relpyContentBack.image = contentImage;
            self.likeContent.hidden = NO;
            self.relpyContentBack.hidden = NO;
            self.line.hidden = NO;
        }
    }else{
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
    if (self.cellLine != nil) {
        [self.cellLine removeFromSuperview];
        self.cellLine = nil;
    }
    self.cellLine = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"BJQCellLine"] stretchableImageWithLeftCapWidth:1.0f topCapHeight:1.0f]];
    [self addSubview:self.cellLine];
    if (self.relpyContentBack.hidden == NO) {
        self.cellLine.frame = CGRectMake(0.0f, self.relpyContentBack.frame.origin.y + self.relpyContentBack.frame.size.height - k_CELLLINE_OFFSET, 320.0f, 1.0f);
    }else{
        self.cellLine.frame = CGRectMake(0.0f, self.moreButton.frame.origin.y + self.moreButton.frame.size.height + k_CELLLINE_OFFSET2, 320.0f, 1.0f);
    }
#ifdef RECTDEBUG
    [self showDebugRect:YES];
#endif
}


@end
