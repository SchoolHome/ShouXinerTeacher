//
//  ButtonWithFace.h
//  iStation
//
//  Created by 郑 帅 on 13-5-23.
//  Copyright (c) 2013年 北京友宝昂莱科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
//typedef enum Face_Type
//{
//    FaceNone=0,
//    Face1,
//    Face2,
//    Face3,
//    Face4,
//    Face5
//    
//}Face_Type;
@interface ButtonWithFace : UIView
{
    EGOImageButton * imageButton;
    int type;
    UIImageView * faceView ;
    
}
- (id)initWithPlaceholderImage:(UIImage*)anImage withFrame:(CGRect) frame FaceType:(Face_Type)_type;

@end
