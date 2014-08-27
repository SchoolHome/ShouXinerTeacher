//
//  ExpressionsParser.m
//  Components_xxx
//
//  Created by ming bright on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ExpressionsParser.h"
#import "SingleSmallExpressionCell.h"
#import "CPUIModelManagement.h"
#import "CPUIModelPetSmallAnim.h"

@interface ExpressionsParser(private)
-(void)parseMessage:(NSString*)message withArray:(NSMutableArray*)array;
- (NSArray *)departToLines;  //拆分成多行，每一个元素是一行的内容
@end

static NSArray *expressions = nil;

static NSArray *nationalFlags = nil;

@implementation ExpressionsParser
@synthesize inputText;
@synthesize font;
@synthesize resultArray;
@synthesize widthsArray;
@synthesize departedContentArray;
@synthesize departedHeightArray;
@synthesize departedWidthArray;

//表情集合
+(NSArray *)expressions{
    if (!expressions) {
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (CPUIModelPetSmallAnim *anim in [[CPUIModelManagement sharedInstance] allSmallAnimObjects]) {
            //CPLogInfo(@"[anim escapeChar] ====================================================%@",[anim escapeChar]);
            [array addObject:[anim escapeChar]];
        }

        
        expressions = array;//[[NSArray alloc] initWithObjects:@"[坏笑]",@"[愤怒]",@"[坏笑]",@"[愤怒]",@"[坏笑]", nil];
    }
    return expressions;
}

// 国旗
+(NSArray *)nationalFlags{
    if (!nationalFlags) {
        NSArray *flags = [[NSArray alloc] initWithObjects:@"🇩🇪",@"🇬🇧",@"🇷🇺",@"🇮🇹",@"🇪🇸",@"🇫🇷",@"🇺🇸",@"🇨🇳",@"🇰🇷",@"🇯🇵", nil];
        
        NSMutableArray *theHalfFlags = [[NSMutableArray alloc] init];
        
        for (NSString *str in flags) {
            [theHalfFlags addObject:str];
            [theHalfFlags addObject:[str substringWithRange:NSMakeRange(0, 2)]];
            [theHalfFlags addObject:[str substringWithRange:NSMakeRange(2, 2)]];
        }
        nationalFlags = theHalfFlags;
    }
    return nationalFlags;
}


-(id)initWithMessage:(NSString *)text font:(UIFont *) ft;{

    self = [super init];
    if (self) {
        
        if (!text||[text isEqualToString:@""]||[text isEqualToString:@"(null)"]) {
            self.inputText = @" ";
        }else {
             self.inputText = text;
        }
       
        self.font = ft;
        //expressions = [[NSArray alloc] initWithObjects:@"[笑1]",@"[笑2]",@"[笑3]",@"[笑4]",@"[笑5]", nil];
    }
    
    return self;
}


-(id)initWithMessage:(NSString *)text{
    
    return [self initWithMessage:text font:[UIFont systemFontOfSize:14.0f]];
}

-(void)parse{
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    [self parseMessage:self.inputText withArray:mutableArray];
    self.resultArray = mutableArray;
    mutableArray = nil;
    
    
    //CPLogInfo(@"self.resultArray == %@",self.resultArray);
    
    
    NSMutableArray *widths = [NSMutableArray array];
    
    for (NSString *str in self.resultArray) {
        if ([[ExpressionsParser expressions] containsObject:str]) { //表情
            //
            [widths addObject:[NSNumber numberWithFloat:35.0]];
        }else {
            CGSize size= [str sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
            [widths addObject:[NSNumber numberWithFloat:size.width]];
        }
    }
    
    self.widthsArray = widths; 
    
    self.departedContentArray = [self departToLines];
    
    
//    NSMutableArray *rowWidthArray = [[NSMutableArray alloc] init];
//    for (int i = 0; i<=[departedContentArray count]; i++) {
//        //
//        
//        
//    }
    
}


- (NSArray *)departToLines{
    
    NSMutableArray *dest = [NSMutableArray array];   //拆分点
    
    CGFloat width = 0.0f;
    
    for (int i =0 ;i<[self.resultArray count];i++) {
        width = width + [[widthsArray objectAtIndex:i] floatValue];

        if (width<=kMaxWidth) {   // 优先处理遇到换行的情况
            if ([[self.resultArray objectAtIndex:i] isEqualToString:@"\n"]) {
                [dest addObject:[NSNumber numberWithInt:i]];
                width = 0.0f;
                //CPLogInfo(@"i %d",i);
                continue;
            }
        }else {
            //CPLogInfo(@"i == %d",i);   //拆分点
            //CPLogInfo(@"i %d",i);
            if ([[widthsArray objectAtIndex:i] floatValue]>=kExpressionSizeWidth) {  // 最后一个是表情，为避免超出范围，减少一个
                [dest addObject:[NSNumber numberWithInt:i]];
                width = kExpressionSizeWidth;
                continue;
            }else {
                [dest addObject:[NSNumber numberWithInt:i]];
                width = [[widthsArray objectAtIndex:i] floatValue];//0.0f;
                continue;
            }
        }
    }
    
    NSMutableArray *resArray = [[NSMutableArray alloc] init];
    
    
    NSMutableArray *heightArray = [[NSMutableArray alloc] init];
    NSMutableArray *rowWidthArray = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i<[dest count]; i++) {
        
        NSArray *departArray;
        
        if (0==i) {
            int loc = 0;
            int len = [[dest objectAtIndex:i] intValue];
            departArray = [self.resultArray subarrayWithRange:NSMakeRange(loc, len)];
            [resArray addObject:departArray];
            
            
            // 求一行宽度
            CGFloat rowWidth = 0;
            for (int m = loc; m<loc+len; m++) {
                rowWidth = rowWidth + [[self.widthsArray objectAtIndex:m] floatValue];
            }
            [rowWidthArray addObject:[NSNumber numberWithFloat:rowWidth]];
            
            /////////////////////////////////////
            BOOL haveExpression = NO;
            for (NSString *str in departArray) {
                if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]) {  //这一行有表情符号
                    haveExpression = YES;
                    break;
                }
            }
            
            [heightArray addObject:[NSNumber numberWithBool:haveExpression]];
            /////////////////////////////////////
            
        }else {
            int loc = [[dest objectAtIndex:i-1] intValue];
            int len = [[dest objectAtIndex:i] intValue]-[[dest objectAtIndex:i-1] intValue];
            
            departArray = [self.resultArray subarrayWithRange:NSMakeRange(loc, len)];
            [resArray addObject:departArray];
            
            // 求一行宽度
            CGFloat rowWidth = 0;
            for (int m = loc; m<loc+len; m++) {
                rowWidth = rowWidth + [[self.widthsArray objectAtIndex:m] floatValue];
            }
            [rowWidthArray addObject:[NSNumber numberWithFloat:rowWidth]];
            
            /////////////////////////////////////
            BOOL haveExpression = NO;
            for (NSString *str in departArray) {
                if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]) {  //这一行有表情符号

                    haveExpression = YES;
                    break;
                }
            }
            
            [heightArray addObject:[NSNumber numberWithBool:haveExpression]];
            /////////////////////////////////////
        }
        
        //CPLogInfo(@"departArray == %@",departArray);
    }
    
    NSArray *lastDepartArray;
    if ([resultArray count]>[[dest lastObject] intValue]) {
        int loc = [[dest lastObject] intValue];
        int len = [self.resultArray count]-loc;
        
        lastDepartArray = [self.resultArray subarrayWithRange:NSMakeRange(loc, len)];
        
        // 求一行宽度
        CGFloat rowWidth = 0;
        for (int m = loc; m<loc+len; m++) {
            rowWidth = rowWidth + [[self.widthsArray objectAtIndex:m] floatValue];
        }
        [rowWidthArray addObject:[NSNumber numberWithFloat:rowWidth]];
        
    }
    
    //CPLogInfo(@"lastDepartArray == %@",lastDepartArray);
    if ([lastDepartArray count]>0) {
        [resArray addObject:lastDepartArray];
        
        
        
        /////////////////////////////////////
        BOOL haveExpression = NO;
        for (NSString *str in lastDepartArray) {

            if ([str hasPrefix:@"["]&&[str hasSuffix:@"]"]) {  //这一行有表情符号
                haveExpression = YES;
                break;
            }
        }
        
        [heightArray addObject:[NSNumber numberWithBool:haveExpression]];
        /////////////////////////////////////
    }
    
    
    self.departedHeightArray = heightArray;
    
    self.departedWidthArray = rowWidthArray;
    
    return resArray;
}


- (CGFloat)height{
    return [[self departToLines] count] *35.0f;
}

////////////////////////////////////////////////////////////////

-(void)parseMessage:(NSString*)message withArray:(NSMutableArray*)array
{
	NSRange range=[message rangeOfString:@"["];
	NSRange range1=[message rangeOfString:@"]"];
    //判断当前字符串是否还有表情的标志。
    if (range.location!=NSNotFound &&range1.location!=NSNotFound) {
        if (range.location>0) {  //文字在先
            
            //[array addObject:[message substringToIndex:range.location]];
            //////////////////////////////////////////////////////////////
            NSString *expStr = [message substringToIndex:range.location];   //非表情部分,拆分成单个字符
            for (int i= 0; i<[expStr length]; i++) {
                //[array addObject:[expStr substringWithRange:NSMakeRange(i, 1)]];  
                
                NSString *str = [expStr substringWithRange:NSMakeRange(i, 1)];
                CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0==width) {
                    //CPLogInfo(@"emoji error");
                    
                    if ([str isEqualToString:@"\n"]) {
                        [array addObject:str];
                    }else {
                        
                        // 截取4个字符
                        if ((i+4)<=[expStr length]) {
                            str = [expStr substringWithRange:NSMakeRange(i, 4)];
                            
                            if ([[ExpressionsParser nationalFlags] containsObject:str]) {
                                [array addObject:str];
                            }else {
                                
                                if ((i+2)<=[expStr length]) {
                                    str = [expStr substringWithRange:NSMakeRange(i, 2)];
                                }
                                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                                if (0!=width) {
                                    //CPLogInfo(@"2 length");
                                    if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                        [array addObject:str];
                                    }
                                }
                            }
                        }else {
                            if ((i+2)<=[expStr length]) {
                                str = [expStr substringWithRange:NSMakeRange(i, 2)];
                            }
                            width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                            if (0!=width) {
                                //CPLogInfo(@"2 length");
                                if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                    [array addObject:str];
                                } 
                            }
                        }
                        
                        /*
                         if ((i+2)<=[message length]) {
                         str = [message substringWithRange:NSMakeRange(i, 2)];
                         }
                         */
                    }
                }else {
                    [array addObject:str];
                }
                
                /*
                ///////////////////////////////////
                NSString *str = [message substringWithRange:NSMakeRange(i, 1)];
                CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0==width) {
                    CPLogInfo(@"emoji error");
                    if ((i+2)<=[message length]) {
                        str = [message substringWithRange:NSMakeRange(i, 2)];
                    }
                }
                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0!=width) {
                    [array addObject:str];  
                }
                ///////////////////////////////////
                 */
            }
            
            //[array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            //////////////////////////////////////////////////////////////////
            
            NSString *emoStr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //CPLogInfo(@"emoStr == %@",emoStr);
            
            if ([[ExpressionsParser expressions] containsObject:emoStr]) {
                //CPLogInfo(@"emoStr == %@ 是表情！",emoStr);
                
                [array addObject:emoStr];                //表情符号，直接添加到数组
            }else {   
                //CPLogInfo(@"emoStr == %@ 不是表情！继续拆分！",emoStr);
                for (int i= 0; i<[emoStr length]; i++) {  //伪表情，继续拆分成单个字符
                    //[array addObject:[emoStr substringWithRange:NSMakeRange(i, 1)]];
                    
                    NSString *str = [emoStr substringWithRange:NSMakeRange(i, 1)];
                    CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                    
                    if (0==width) {
                        //CPLogInfo(@"emoji error");
                        if ([str isEqualToString:@"\n"]) {
                            [array addObject:str];
                        }else {
                            
                            // 截取4个字符
                            if ((i+4)<=[emoStr length]) {
                                str = [emoStr substringWithRange:NSMakeRange(i, 4)];
                                
                                if ([[ExpressionsParser nationalFlags] containsObject:str]) {
                                    [array addObject:str];
                                }else {
                                    
                                    if ((i+2)<=[emoStr length]) {
                                        str = [emoStr substringWithRange:NSMakeRange(i, 2)];
                                    }
                                    width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                                    if (0!=width) {
                                        //CPLogInfo(@"2 length");
                                        if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                            [array addObject:str];
                                        }
                                    }
                                }
                            }else {
                                if ((i+2)<=[emoStr length]) {
                                    str = [emoStr substringWithRange:NSMakeRange(i, 2)];
                                }
                                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                                if (0!=width) {
                                    //CPLogInfo(@"2 length");
                                    if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                        [array addObject:str];
                                    } 
                                }
                            }
                            
                            /*
                             if ((i+2)<=[message length]) {
                             str = [message substringWithRange:NSMakeRange(i, 2)];
                             }
                             */
                        }
                    }else {
                        [array addObject:str];
                    }
                    
                    /*
                    ///////////////////////////////////
                    NSString *str = [emoStr substringWithRange:NSMakeRange(i, 1)];
                    CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                    
                    if (0==width) {
                        CPLogInfo(@"emoji error");
                        if ((i+2)<=[emoStr length]) {
                            str = [emoStr substringWithRange:NSMakeRange(i, 2)];
                        }
                    }
                    width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                    
                    if (0!=width) {
                        [array addObject:str];  
                    }
                    ///////////////////////////////////
                     */
                }
            }
            
            NSString *str=[message substringFromIndex:range1.location+1];
            //CPLogInfo(@"str == %@",str);
            [self parseMessage:str withArray:array];
            
        }else {           //第一个就是表情
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            
            //CPLogInfo(@"nextstr == %@",nextstr);
            
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                if ([[ExpressionsParser expressions] containsObject:nextstr]) {  //表情符号，直接添加到数组
                    [array addObject:nextstr];
                }else{   //伪表情，继续拆分成单个字符
                    for (int i= 0; i<[nextstr length]; i++) {  //伪表情，继续拆分成单个字符
                        //[array addObject:[nextstr substringWithRange:NSMakeRange(i, 1)]];
                        
                        NSString *str = [nextstr substringWithRange:NSMakeRange(i, 1)];
                        CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                        
                        if (0==width) {
                            //CPLogInfo(@"emoji error");
                            
                            if ([str isEqualToString:@"\n"]) {
                                [array addObject:str];
                            }else {
                                
                                // 截取4个字符
                                if ((i+4)<=[nextstr length]) {
                                    str = [nextstr substringWithRange:NSMakeRange(i, 4)];
                                    
                                    if ([[ExpressionsParser nationalFlags] containsObject:str]) {
                                        [array addObject:str];
                                    }else {
                                        
                                        if ((i+2)<=[nextstr length]) {
                                            str = [nextstr substringWithRange:NSMakeRange(i, 2)];
                                        }
                                        width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                                        if (0!=width) {
                                            //CPLogInfo(@"2 length");
                                            if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                                [array addObject:str];
                                            }
                                        }
                                    }
                                }else {
                                    if ((i+2)<=[nextstr length]) {
                                        str = [nextstr substringWithRange:NSMakeRange(i, 2)];
                                    }
                                    width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                                    if (0!=width) {
                                        //CPLogInfo(@"2 length");
                                        if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                            [array addObject:str];
                                        }
                                    }
                                }
                                
                                /*
                                 if ((i+2)<=[message length]) {
                                 str = [message substringWithRange:NSMakeRange(i, 2)];
                                 }
                                 */
                            }
                        }else {
                            [array addObject:str];
                        }
                        
                        /*
                        ///////////////////////////////////
                        NSString *str = [nextstr substringWithRange:NSMakeRange(i, 1)];
                        CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                        
                        if (0==width) {
                            CPLogInfo(@"emoji error");
                            if ((i+2)<=[nextstr length]) {
                                str = [nextstr substringWithRange:NSMakeRange(i, 2)];
                            }
                        }
                        width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                        
                        if (0!=width) {
                            CPLogInfo(@"2 length");
                            [array addObject:str];  
                        }
                        ///////////////////////////////////
                         */
                    }
                }
                
                NSString *str=[message substringFromIndex:range1.location+1];
                //CPLogInfo(@"str1 == %@",str);
            
                [self parseMessage:str withArray:array];
                
            }else {
                return;
            }
        }
    }else {    //没发现有表情符号
        if (![message isEqualToString:@""]){
            
            
            for (int i= 0; i<[message length]; i++) {
                /*
                NSString *str = [message substringWithRange:NSMakeRange(i, 1)];
                
                CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0==width) {
                    CPLogInfo(@"emoji error  111111");
                    if ((i+2)<=[message length]) {
                        str = [message substringWithRange:NSMakeRange(i, 2)];
                    }
                }else {
                    [array addObject:str];
                    
                    i = i+2;
                    
                    continue;
                }
                
                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0==width) {
                    CPLogInfo(@"emoji error  2222222");
                    if ((i+3)<=[message length]) {
                        str = [message substringWithRange:NSMakeRange(i, 3)];
                    }
                }else {
                    [array addObject:str];
                    i = i+3;
                    continue;
                }
                
                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0==width) {
                    CPLogInfo(@"emoji error  33333333");
                    if ((i+4)<=[message length]) {
                        str = [message substringWithRange:NSMakeRange(i, 4)];
                    }
                }else {
                    [array addObject:str];
                    i = i+4;
                    continue;
                }*/
                
                ////🇩🇪🇬🇧🇷🇺🇮🇹🇪🇸🇫🇷🇺🇸🇨🇳🇰🇷🇯🇵  特别处理
                ///////////////////////////////////
                NSString *str = [message substringWithRange:NSMakeRange(i, 1)];
                CGFloat width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                if (0==width) {
                    //CPLogInfo(@"emoji error");
                    
                    if ([str isEqualToString:@"\n"]) {
                        [array addObject:str];
                    }else {
                        // 截取4个字符
                        if ((i+4)<=[message length]) {
                            str = [message substringWithRange:NSMakeRange(i, 4)];
                            
                            if ([[ExpressionsParser nationalFlags] containsObject:str]) {
                                [array addObject:str];
                            }else {
                                // 截取2个字符
                                if ((i+2)<=[message length]) {
                                    str = [message substringWithRange:NSMakeRange(i, 2)];
                                }
                                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                                if (0!=width) {
                                    //CPLogInfo(@"2 length");
                                    if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                        [array addObject:str];
                                    }
                                }
                            }
                        }else {    //只输入一个表情的情况
                            if ((i+2)<=[message length]) {
                                str = [message substringWithRange:NSMakeRange(i, 2)];
                            }
                            width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                            if (0!=width) {
                                //CPLogInfo(@"2 length");
                                if (![[ExpressionsParser nationalFlags] containsObject:str]) {
                                    [array addObject:str];
                                } 
                            }
                        }
                        
                        /*
                         if ((i+2)<=[message length]) {
                         str = [message substringWithRange:NSMakeRange(i, 2)];
                         }
                         */
                    }
                    

                }else {
                    [array addObject:str];
                }
                /*
                width = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)].width;
                
                
                if (0!=width) {
                    CPLogInfo(@"2 length");
                    [array addObject:str];  
                }
                 */
                ///////////////////////////////////
            
        }
        
        //CPLogInfo(@"array ============ %@",array);
        
        return;
        //[array addObject:message];
    }
}
}


@end
