
//
//  ImageUtil.h
//  iCouple
//
//  Created by 振杰 李 on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "UIImage+ProportionalFill.h"
#import "CPUIModelManagement.h"
#import "CPUIModelMessageGroupMember.h"
#import "CPUIModelUserInfo.h"
#import "CPUIModelPersonalInfo.h"
#import "CPUIModelMessageGroup.h"
#import <QuartzCore/QuartzCore.h>
#import "ColorUtil.h"
@implementation UIImage (Extras)  
 
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize  
{  
    UIImage *sourceImage = self;  
    UIImage *newImage = nil;          
    CGSize imageSize = sourceImage.size;  
    CGFloat width = imageSize.width;  //1431
    CGFloat height = imageSize.height;  // 2164
    CGFloat targetWidth = targetSize.width;  //640
    CGFloat targetHeight = targetSize.height;  //960
    CGFloat scaleFactor = 0.0;  
    CGFloat scaledWidth = targetWidth;  // 640
    CGFloat scaledHeight = targetHeight;  // 960
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);  
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)   
    {  
        CGFloat widthFactor = targetWidth / width; //0.4472
        CGFloat heightFactor = targetHeight / height; // 0.4436
        if (widthFactor > heightFactor)   
            scaleFactor = widthFactor; // scale to fit height  
        else  
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;  // 640
        scaledHeight = height * scaleFactor;  // 960
        // center the image  
        if (widthFactor > heightFactor)  {  
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;  //  
        }  
        else if (widthFactor < heightFactor)  {  
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;  
        }  
    }         
    UIGraphicsBeginImageContext(targetSize); // this will crop  
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.origin = thumbnailPoint;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
    [sourceImage drawInRect:thumbnailRect];  
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
//    if(newImage == nil)   
//        NSLog(@"could not scale image");  
    //pop the context to get back to the default  
    UIGraphicsEndImageContext();  
    return newImage;  
}  

//等比例改变图片大小
+ (UIImage *)changeImage:(UIImage*) img Width:(float)width Height:(float)height
{
    UIImage *image = img;
    CGSize size = image.size;
    
    float scale1 = width/height;    //特定给的比值
    float scale2 = size.width/size.height;   //图片比例
    CGFloat ratio = 0;
    if (scale2>scale1)
    {
        if (size.width > size.height) 
        {
            ratio = height / size.width;
        }
        else
        {
            ratio = height / size.height;
        }
    }
    else 
    {
        if (size.width > size.height) 
        {
            ratio = width / size.width;
        } else 
        {
            ratio = width / size.height;
        }
    }
    CPLogInfo(@"%f    %f    %f    %f   %f",width,height,ratio * size.width,ratio * size.height,ratio);
    return [image imageByScalingAndCroppingForSizeEx:CGSizeMake(ratio * size.width, ratio * size.height)];
}
+(UIImage *)groupHeader:(CPUIModelMessageGroup *) groupModel{
    
    
    UIImage *backImage = [UIImage imageNamed:@"headpic_group_110x110"];
    
    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(backImage.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(backImage.size);
    
    [backImage drawInRect:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    int count = 0;
    CGFloat radius = 5.0f;
    
    for (int i = 0; i < [groupModel.memberList count]; i++) {
        
        CPUIModelMessageGroupMember *member =  [groupModel.memberList objectAtIndex:i]; 
        if (![member isHiddenMember]) {
            
            CPUIModelUserInfo *userInfo = member.userInfo;
            
            UIImage *image;
            if ((userInfo.nickName.length == 0 || [userInfo.nickName isEqualToString:[CPUIModelManagement sharedInstance].uiPersonalInfo.nickName]) && groupModel.memberList.count < 5) {
                image = [UIImage imageWithContentsOfFile:[CPUIModelManagement sharedInstance].uiPersonalInfo.selfHeaderImgPath];
            }else
            {
                image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
            }
            
            

            if (!image) {
                image = [UIImage imageWithContentsOfFile:member.headerPath];
            }
            
            if (!image) {
                image = [UIImage imageNamed:@"girl"];
            }
            
            if (image) {
                if (0 == count) {
                    [image drawInRect:CGRectMake(5, 5, 20, 20)];
                    
                    [[UIColor colorWithHexString:@"#DDDDDD"] set];  // 底图颜色
                    //[[UIColor redColor] set];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(5-radius/2, 5-radius/2, 20+radius, 20+radius) cornerRadius: radius+4];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                }else if (1 == count) {
                    [image drawInRect:CGRectMake(30, 5, 20, 20)];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(30-radius/2, 5-radius/2, 20+radius, 20+radius) cornerRadius: radius+4];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                }else if (2 == count) {
                    [image drawInRect:CGRectMake(5, 30, 20, 20)];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(5-radius/2, 30-radius/2, 20+radius, 20+radius) cornerRadius: radius+4];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                }else if (3 == count) {
                    [image drawInRect:CGRectMake(30, 30, 20, 20)];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(30-radius/2, 30-radius/2, 20+radius, 20+radius) cornerRadius: radius+4];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                     count ++;
                    break;
                }
                count ++;
            }
        }
    }
    
    
    //如果没满的话就用色块填充够4个
    /*
    for (int i = count; i<4; i++) {
        UIImage *image = [UIImage imageNamed:@"wall_bg_noone.png"];
        if (0 == count) {
            [image drawInRect:CGRectMake(5, 5, 20, 20)];
            
            [[UIColor colorWithHexString:@"#DDDDDD"] set];  // 底图颜色

        }else if (1 == count) {
            [image drawInRect:CGRectMake(30, 5, 20, 20)];

        }else if (2 == count) {
            [image drawInRect:CGRectMake(5, 30, 20, 20)];

        }else if (3 == count) {
            [image drawInRect:CGRectMake(30, 30, 20, 20)];

            break;
        }
    }
     */
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    
    return resultingImage;  
}
+(UIImage *)groupHeaderForFriendWall:(CPUIModelMessageGroup *) groupModel{
    
    
    
     UIImage *backImage = [UIImage imageNamed:@"wall_bg_group01.png"];

    
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(backImage.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(backImage.size);
    
    [backImage drawInRect:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    int count = 0;
    
    CGFloat radius = 3.0f;
    
    for (int i = 0; i < [groupModel.memberList count]; i++) {
        
        CPUIModelMessageGroupMember *member =  [groupModel.memberList objectAtIndex:i]; 
        if (![member isHiddenMember]) {
            
            CPUIModelUserInfo *userInfo = member.userInfo;
            UIImage *image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
            
            
            
            if (!image) {
                image = [UIImage imageWithContentsOfFile:member.headerPath];
            }
            
            if (image) {
                if (0 == count) {
                    [image drawInRect:CGRectMake(0, 0, 20, 20)];
                    [[UIColor colorWithRed:1 green:1 blue:1 alpha:1.0] set];
                    //[[UIColor colorWithHexString:@"#DDDDDD"] set];  // 底图颜色
                    
                    //[[UIColor redColor] set];
                   // [[UIColor clearColor] set];
                    
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(0-radius/2, 0-radius/2, 20+radius, 20+radius) cornerRadius: 5.0];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                }else if (1 == count) {
                    [image drawInRect:CGRectMake(23, 0, 20, 20)];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(23-radius/2, 0-radius/2, 20+radius, 20+radius) cornerRadius: 5.0];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                }else if (2 == count) {
                    [image drawInRect:CGRectMake(0, 23, 20, 20)];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(0-radius/2, 23-radius/2, 20+radius, 20+radius) cornerRadius: 5.0];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                }else if (3 == count) {
                    [image drawInRect:CGRectMake(23, 23, 20, 20)];
                    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: 
                                                          CGRectMake(23-radius/2, 23-radius/2, 20+radius, 20+radius) cornerRadius: 5.0];
                    [roundedRectanglePath setLineWidth:radius];
                    [roundedRectanglePath stroke];
                     count ++;
                    break;
                }
                count ++;
            }
        }
        
        
    }

        //如果没满的话就用色块填充够4个
        for (int i = count; i<4; i++) {
            UIImage *image = [UIImage imageNamed:@"wall_bg_noone.png"];
            if (0 == i) {
                [image drawInRect:CGRectMake(0, 0, 20, 20)];
            }else if (1 == i) {
                [image drawInRect:CGRectMake(23, 0, 20, 20)];

            }else if (2 == i) {
                [image drawInRect:CGRectMake(0, 23, 20, 20)];

            }else if (3 == i) {
                [image drawInRect:CGRectMake(23, 23, 20, 20)];

                break;
            }
        }
    
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();  
    UIGraphicsEndImageContext();  
    
    return resultingImage;  
}

+(UIImage *)returnGroupImgByPeopleNumber:(CPUIModelMessageGroup *)modelMessageGroup ;
{
    // UIView *groupBGView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 55, 55)];
    //UIImage *bgImage = [UIImage imageNamed:@"headpic_group_110x110.png"];
    UIImageView *bgImageview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 55, 55)];
    bgImageview.backgroundColor = [UIColor clearColor];
   // [bgImageview setFrame:CGRectMake(10, 10, 55, 55)];
//    for (int i = 0; i < 4; i++) {
//        UIImageView *contentImageview;
//        if (i >= modelMessageGroup.memberList.count) {
//            //contentImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_40x40.png"]];            
//        }else {
//            CPUIModelMessageGroupMember *member =  [modelMessageGroup.memberList objectAtIndex:i];   
//            CPUIModelUserInfo *userInfo = member.userInfo;
//            UIImage *image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
//            
//            if (!image) {
//                contentImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_40x40.png"]];                            
//                //image = [UIImage imageNamed:@"headpic_40x40.png"];
//                
//            }else {
//                contentImageview = [[UIImageView alloc] initWithImage:[image imageByScalingAndCroppingForSize:CGSizeMake(20.f, 20.f)]];       
//                //[contentImageview.image transformWidth:20.f height:20.f];
//            }            
//        }
//        if (i < 2) {
//            [contentImageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
//        }else {
//            [contentImageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
//        }
//        
//        contentImageview.layer.cornerRadius = 3.f;
//        contentImageview.layer.masksToBounds = YES;
//        [bgImageview addSubview:contentImageview];
//    }
    int j = 0;
    for (int i = 0; i < modelMessageGroup.memberList.count; i++) {
        //2012.8.6 加入隐藏群成员
        CPUIModelMessageGroupMember *member =  [modelMessageGroup.memberList objectAtIndex:i];   
        if (![member isHiddenMember]) {
            
       
        UIImageView *contentImageview;

        CPUIModelUserInfo *userInfo = member.userInfo;
        UIImage *image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
        //UIImage *image = [UIImage changeImage:[UIImage imageWithContentsOfFile:userInfo.headerPath] Width:20.f Height:20.f];
        if (j==4) {
            break;
        }
        
   
        
        if (image) {
            
            contentImageview = [[UIImageView alloc] initWithImage:[image imageByScalingAndCroppingForSizeExe:CGSizeMake(20.f, 20.f)]];
            j++;
        }else {
            UIImage *imageMember = [UIImage imageWithContentsOfFile:member.headerPath];
            if (imageMember) {
                contentImageview = [[UIImageView alloc] initWithImage:[imageMember imageByScalingAndCroppingForSizeExe:CGSizeMake(20.f, 20.f)]];    

                j++;
            }else {
                //contentImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_group_40x40.png"]]; 
                continue;    
            }
            
        }
        
        if (j < 3) {
            [contentImageview setFrame:CGRectMake(25*(j-1)+5, 5.f, 20.f, 20.f)];
        }else {
            [contentImageview setFrame:CGRectMake(25*(j-3)+5, 30.f, 20.f, 20.f)];
        }
        
        contentImageview.layer.cornerRadius = 3.f;
        contentImageview.layer.masksToBounds = YES;
        [bgImageview addSubview:contentImageview];
        }
    }
    //人数超过4时
    if (modelMessageGroup.memberList.count>=4) {
        for (int i = j; i<4; i++) {
            UIImageView *Imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_group_40x40.png"]]; 
            
            
            if (i < 2) {
                [Imageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
            }else {
                [Imageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
            }
            
            Imageview.layer.cornerRadius = 3.f;
            Imageview.layer.masksToBounds = YES;
            [bgImageview addSubview:Imageview];
        }    
    }else {
        //人数小于4时
        for (int i = j; i<modelMessageGroup.memberList.count; i++) {
            UIImageView *Imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_group_40x40.png"]]; 
            
            if (i < 2) {
                [Imageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
            }else {
                [Imageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
            }
            
            Imageview.layer.cornerRadius = 3.f;
            Imageview.layer.masksToBounds = YES;
            [bgImageview addSubview:Imageview];
        }
    }
    
    //UIGraphicsBeginImageContext(bgImageview.bounds.size);
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(bgImageview.bounds.size, NO, 0);
    else
        UIGraphicsBeginImageContext(bgImageview.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [bgImageview.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    

    return tImage;
    
}
+(UIImageView *)returnGroupImgViewByPeopleNumber:(CPUIModelMessageGroup *)modelMessageGroup 
{
    // UIView *groupBGView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 55, 55)];
    UIImage *bgImage = [UIImage imageNamed:@"headpic_group_110x110.png"];
    UIImageView *bgImageview = [[UIImageView alloc] initWithImage:bgImage];
    [bgImageview setFrame:CGRectMake(10, 10, 55, 55)];
    //    for (int i = 0; i < 4; i++) {
    //        UIImageView *contentImageview;
    //        if (i >= modelMessageGroup.memberList.count) {
    //            //contentImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_40x40.png"]];            
    //        }else {
    //            CPUIModelMessageGroupMember *member =  [modelMessageGroup.memberList objectAtIndex:i];   
    //            CPUIModelUserInfo *userInfo = member.userInfo;
    //            UIImage *image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
    //            
    //            if (!image) {
    //                contentImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_40x40.png"]];                            
    //                //image = [UIImage imageNamed:@"headpic_40x40.png"];
    //                
    //            }else {
    //                contentImageview = [[UIImageView alloc] initWithImage:[image imageByScalingAndCroppingForSize:CGSizeMake(20.f, 20.f)]];       
    //                //[contentImageview.image transformWidth:20.f height:20.f];
    //            }            
    //        }
    //        if (i < 2) {
    //            [contentImageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
    //        }else {
    //            [contentImageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
    //        }
    //        
    //        contentImageview.layer.cornerRadius = 3.f;
    //        contentImageview.layer.masksToBounds = YES;
    //        [bgImageview addSubview:contentImageview];
    //    }
    int j = 0;
    for (int i = 0; i < modelMessageGroup.memberList.count; i++) {
        UIImageView *contentImageview;
        CPUIModelMessageGroupMember *member =  [modelMessageGroup.memberList objectAtIndex:i];   
        CPUIModelUserInfo *userInfo = member.userInfo;
        UIImage *image = [UIImage imageWithContentsOfFile:userInfo.headerPath];
        //UIImage *image = [UIImage changeImage:[UIImage imageWithContentsOfFile:userInfo.headerPath] Width:20.f Height:20.f];
        if (j==4) {
            break;
        }
        if (image) {
            
            contentImageview = [[UIImageView alloc] initWithImage:[image imageByScalingAndCroppingForSizeExe:CGSizeMake(20.f, 20.f)]];
            j++;
        }else {
            UIImage *imageMember = [UIImage imageWithContentsOfFile:member.headerPath];
            if (imageMember) {
                contentImageview = [[UIImageView alloc] initWithImage:[imageMember imageByScalingAndCroppingForSizeExe:CGSizeMake(20.f, 20.f)]];    
                
                j++;
            }else {
                //contentImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_group_40x40.png"]]; 
                continue;    
            }
            
        }
        if (i < 2) {
            [contentImageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
        }else {
            [contentImageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
        }
        
        contentImageview.layer.cornerRadius = 3.f;
        contentImageview.layer.masksToBounds = YES;
        [bgImageview addSubview:contentImageview];
    }
    //人数超过4时
    if (modelMessageGroup.memberList.count>=4) {
        for (int i = j; i<4; i++) {
            UIImageView *Imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_group_40x40.png"]]; 
            
            
            if (i < 2) {
                [Imageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
            }else {
                [Imageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
            }
            
            Imageview.layer.cornerRadius = 3.f;
            Imageview.layer.masksToBounds = YES;
            [bgImageview addSubview:Imageview];
        }    
    }else {
        //人数小于4时
        for (int i = j; i<modelMessageGroup.memberList.count; i++) {
            UIImageView *Imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headpic_group_40x40.png"]]; 
            
            if (i < 2) {
                [Imageview setFrame:CGRectMake(25*i+5, 5.f, 20.f, 20.f)];
            }else {
                [Imageview setFrame:CGRectMake(25*(i-2)+5, 30.f, 20.f, 20.f)];
            }
            
            Imageview.layer.cornerRadius = 3.f;
            Imageview.layer.masksToBounds = YES;
            [bgImageview addSubview:Imageview];
        }
    }
    
//    UIGraphicsBeginImageContext(bgImageview.bounds.size);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [bgImageview.layer renderInContext:ctx];
//    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
    return bgImageview;
    
}

+(UIImage *) scaleImage: (UIImage *)image scaleFactor:(float)scaleFloat
{
    CGSize size = CGSizeMake(image.size.width * scaleFloat, image.size.height * scaleFloat);
    
    UIGraphicsBeginImageContext(CGSizeMake(floor(size.width), floor(size.height)));
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    
//    transform = CGAffineTransformScale(transform, scaleFloat, scaleFloat);
//    CGContextConcatCTM(context, transform);
    
    // Draw the image into the transformed context and return the image
//    [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newimg;  
}
- (UIImage*)imageByScalingAndCroppingForSizeExe:(CGSize)targetSize
{

    
    UIImage *sourceImage = self;  
    
    UIImage *newImage = nil;          
    
    CGSize imageSize = sourceImage.size;  
    
    CGFloat width = imageSize.width;  
    
    CGFloat height = imageSize.height;  
    
    CGFloat targetWidth = targetSize.width;  
    
    CGFloat targetHeight = targetSize.height;  
    
    CGFloat scaleFactor = 0.0;  
    
    CGFloat scaledWidth = targetWidth;  
    
    CGFloat scaledHeight = targetHeight;  
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);  
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)   
        
    {  
        
        CGFloat widthFactor = targetWidth / width;  
        
        CGFloat heightFactor = targetHeight / height;  
        
        if (widthFactor > heightFactor)   
            
            scaleFactor = widthFactor; // scale to fit height  
        
        else  
            
            scaleFactor = heightFactor; // scale to fit width  
        
        scaledWidth  = width * scaleFactor;  
        
        scaledHeight = height * scaleFactor;  
        
        // center the image  
        
        if (widthFactor > heightFactor)  
            
        {  
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;   
            
        }  
        
        else   
            
            if (widthFactor < heightFactor)  
                
            {  
                
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;  
                
            }  
        
    }         
    
    // UIGraphicsBeginImageContext(targetSize); // this will crop  
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0); // 0.0 for scale means "correct scale for device's main screen".
    
    CGRect thumbnailRect = CGRectZero;  
    
    thumbnailRect.origin = thumbnailPoint;  
    
    thumbnailRect.size.width  = scaledWidth;  
    
    thumbnailRect.size.height = scaledHeight;  
    
    [sourceImage drawInRect:thumbnailRect];  
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
    
    if(newImage == nil)   
        
        CPLogInfo(@"could not scale image");  
    
    //pop the context to get back to the default  
    
    UIGraphicsEndImageContext();  
    
    return newImage;  
    
}
/*
-(UIImage*)getSubImage:(CGRect)rect  
{  
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);  
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));  
    
    UIGraphicsBeginImageContext(smallBounds.size);  
    CGContextRef context = UIGraphicsGetCurrentContext();  
    CGContextDrawImage(context, smallBounds, subImageRef);  
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];  
    UIGraphicsEndImageContext();  
    
    return smallImage;  
} 
 */
@end;