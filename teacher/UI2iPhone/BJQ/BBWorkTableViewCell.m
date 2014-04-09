//
//  BBWorkTableViewCell.m
//  BBTeacher
//
//  Created by xxx on 14-3-4.
//  Copyright (c) 2014年 xxx. All rights reserved.
//

#import "BBWorkTableViewCell.h"

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
        
        title = [[UILabel alloc] initWithFrame:CGRectMake(K_LEFT_PADDING, 0, 225, 20)];
        [self addSubview:title];
        title.textColor = [UIColor colorWithHexString:@"#4a7f9d"];
        
        mark = [[UIImageView alloc] initWithFrame:CGRectMake(K_LEFT_PADDING, 20, 41, 41)];
        [self addSubview:mark];
        //mark.backgroundColor = [UIColor redColor];
        mark.image = [UIImage imageNamed:@"BBYuWen"];

        contentBack = [[UIImageView alloc] init];
        [self addSubview:contentBack];
        
        content = [[UILabel alloc] init];
        [self addSubview:content];
        
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

    title.text = self.data.title;
    title.font = [UIFont systemFontOfSize:14];
    
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
    
        mark.image = [UIImage imageNamed:@"BBComentNotification"];
        backimage = [UIImage imageNamed:@"BBComentNotificationContent"];
        
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
            imageContent[i].imageURL = [NSURL URLWithString:self.data.imageList[i]];
        }
    }
    
    // 有图片
    CGFloat timeBegin = 0;
    if ([self.data.imageList count]>0) {
        timeBegin = kViewFoot(imageContent[[self.data.imageList count]-1]);
    }else{
        timeBegin = kViewFoot(contentBack);
    }
    
    self.like.frame = CGRectMake(165, timeBegin+5, 62, 27);
    self.reply.frame = CGRectMake(165+70, timeBegin+5, 62, 27);
    
    self.time.frame = CGRectMake(K_LEFT_PADDING, timeBegin+5, 60, 27);
    self.time.text = [self timeStringFromNumber:self.data.ts];
    
    if ([self.data.praisesStr length]>0||[self.data.commentsStr length]>0) {
        //
        self.relpyContent.hidden = NO;
        self.likeContent.hidden = NO;
        self.relpyContentBack.hidden = NO;
        
        CGSize s = [self.data.commentsStr sizeConstrainedToSize:CGSizeMake(210, CGFLOAT_MAX)];
        self.relpyContent.frame = CGRectMake(K_LEFT_PADDING+5, kViewFoot(self.time)+10+45, 210, s.height);
        self.relpyContent.attributedText = self.data.commentsStr;
        
        self.likeContent.frame = CGRectMake(K_LEFT_PADDING+40, kViewFoot(self.time)+10+16, 175, 20);
        self.likeContent.text = self.data.praisesStr;
        
        UIImage *image2 = [UIImage imageNamed:@"BBComentBG"];
        image2 = [image2 resizableImageWithCapInsets:UIEdgeInsetsMake(45,100,14,100) resizingMode:UIImageResizingModeStretch];
        
        self.relpyContentBack.frame = CGRectMake(K_LEFT_PADDING, kViewFoot(self.time)+10, 210+10, s.height+10+45);
        self.relpyContentBack.image = image2;
    }else{
        self.relpyContent.hidden = YES;
        self.likeContent.hidden = YES;
        self.relpyContentBack.hidden = YES;
    }
    
    //[self showDebugRect:YES];
}

@end
