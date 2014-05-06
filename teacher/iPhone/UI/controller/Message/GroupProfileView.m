//
//  GroupProfileView.m
//  iCouple
//
//  Created by qing zhang on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GroupProfileView.h"
#import "ImageUtil.h"


#define LabelTextDotTag 1017
#define tableviewFootTag 1018
#define quitBtnTag 1019
#define quitTextTag 1020

@interface GroupProfileView ()
@property(nonatomic,strong) GroupProfileScrollView *groupUserInforScroll;
@property(nonatomic,strong) NSMutableArray *groupItems;

@end

@implementation GroupProfileView
@synthesize profiletype = _profiletype , modelMessageGroup = _modelMessageGroup , groupMembers = _groupMembers , imageviewMemberNameBG = _imageviewMemberNameBG,
            groupProfileDelegate = _groupProfileDelegate;
@synthesize groupUserInforScroll = _groupUserInforScroll , groupItems = groupItems;

-(NSMutableDictionary *)groupMembers
{
    if (!_groupMembers) {
            _groupMembers = [[NSMutableDictionary alloc] init];
    }
    return _groupMembers;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame andProfileType : (NSInteger)type andModelMessageGroup:(CPUIModelMessageGroup *)messageGroup
{
    //self = [super initWithFrame:frame andProfileType:type andModelMessageGroup:messageGroup];
    self = [super initWithFrame:frame];
    if (self) {
        self.modelMessageGroup = messageGroup;

        
        self.profiletype = type;
        //群名的背景
        self.imageviewMemberNameBG = [[UIView alloc] initWithFrame:CGRect_imageviewMemberNameBG];
        self.imageviewMemberNameBG.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageviewMemberNameBG];
        
        UIImageView *imageviewNameBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRect_imageviewMemberNameBG.size.width, CGRect_imageviewMemberNameBG.size.height)];
        imageviewNameBG.backgroundColor = [UIColor blackColor];
        imageviewNameBG.alpha = 0.44;
        [self.imageviewMemberNameBG addSubview:imageviewNameBG];
        //人数
        
        UILabel *labelMemberNumber = [[UILabel alloc] initWithFrame:CGRectMake(64.f, 0.f, 41.f, 36.f)];
        labelMemberNumber.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
        labelMemberNumber.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:36.f];
        labelMemberNumber.shadowColor = [UIColor colorWithRed:9/255.f green:9/255.f blue:11/255.f alpha:0.5f];
        labelMemberNumber.shadowOffset = CGSizeMake(0.f, 1.5f);
        if (self.modelMessageGroup.memberList.count == 0) {
            labelMemberNumber.text = [NSString stringWithFormat:@"%d",1];    
        }else {
            int i = 0;
            for (CPUIModelMessageGroupMember *member in self.modelMessageGroup.memberList) {
                if (![member isHiddenMember]) {
                    i++;
                }
            }
            labelMemberNumber.text = [NSString stringWithFormat:@"%d",i+1];
        }
        CGSize size = CGSizeMake(41.0f,9999.0f);
        CGSize stringSize = [labelMemberNumber.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:36.f] constrainedToSize:size lineBreakMode:labelMemberNumber.lineBreakMode];
        labelMemberNumber.frame = CGRectMake(64.f, 10.f, 41.f, stringSize.height / 2.0f + 5.0f);

//        [labelMemberNumber sizeToFit];
        labelMemberNumber.textAlignment = UITextAlignmentRight;
        labelMemberNumber.backgroundColor = [UIColor clearColor];
        labelMemberNumber.tag = LabelTextGroupMemberNumberTag;
        [self.imageviewMemberNameBG addSubview:labelMemberNumber];
        //"人"
        UILabel *textPeople = [[UILabel alloc] initWithFrame:CGRectMake(102.f, 26.f, 12.f, 12.f)];
        textPeople.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
        textPeople.shadowColor = [UIColor colorWithRed:9/255.f green:9/255.f blue:11/255.f alpha:0.5f];
        textPeople.shadowOffset = CGSizeMake(0.f, 0.5f);        
        textPeople.font = [UIFont systemFontOfSize:12.f];
        textPeople.backgroundColor = [UIColor clearColor];
        textPeople.tag = LabelTextRenTag;
        textPeople.text = @"人";
        [self.imageviewMemberNameBG addSubview:textPeople];
        
        //"+"按钮
        UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPlus setFrame:CGRect_btnPlus];
        btnPlus.backgroundColor = [UIColor clearColor];
        [btnPlus setBackgroundImage:[UIImage imageNamed:@"bt_im_+.png"] forState:UIControlStateNormal];
        [btnPlus setBackgroundImage:[UIImage imageNamed:@"bt_im_+press.png"] forState:UIControlStateHighlighted];
        [btnPlus addTarget:self action:@selector(plusFriend) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonView addSubview:btnPlus];
        
        //多人会话时随机3个成员名字，群是群名字
        //多人会话
        if ([self.modelMessageGroup isMsgMultiConver]) {
            [self setMutilGroupContent];
//            UIImage *image = [UIImage imageNamed:@"bg_default.jpg"];
//            [self.imageviewBGInMainView setImage:image];
//        //if (type == MSG_GROUP_UI_TYPE_CONVER) {
//            int j = 0;
//            if (self.modelMessageGroup.memberList.count >3) {
//                j = 4;
//            }else if (self.modelMessageGroup.memberList.count >0 && self.modelMessageGroup.memberList.count <= 3)
//            {
//                j = self.modelMessageGroup.memberList.count;
//            }
//            NSMutableArray *arrRandomNumber = [[NSMutableArray alloc] initWithCapacity:3];
//            if (j>2) {
//                while (arrRandomNumber.count != 3) {
//                    int randomNumber = arc4random()%(self.modelMessageGroup.memberList.count);   
//                    if (![arrRandomNumber containsObject:[NSNumber numberWithInt:randomNumber]]) {
//                        [arrRandomNumber addObject:[NSNumber numberWithInt:randomNumber]];
//                    }
//                    
//                }                
//            }else {
//                for (int i= 0; i<self.modelMessageGroup.memberList.count; i++) {
//                    [arrRandomNumber addObject:[NSNumber numberWithInt:i]];
//                }
//            }
//
//            
//            for (int i = 0; i< j ; i++) {
//                
//                
//                UILabel *member = [[UILabel alloc] init];
//                
//                if (i == 3) {
//                    [member setFrame:CGRectMake(10.f, 44.0f+19*i, 22, 10.0f)];
//                    member.text = @"...";
//                    
//                }else {
//                    CPUIModelMessageGroupMember *memberInfo = [self.modelMessageGroup.memberList objectAtIndex:[[arrRandomNumber objectAtIndex:i]intValue]];
//                    CPUIModelUserInfo *userinfo = memberInfo.userInfo;
//                    [member setFrame:CGRectMake(10.f, 44.0f+19*i, 60, 16.5f)];
//                    if (!userinfo) {
//                        member.text = memberInfo.nickName;    
//                    }else {
//                        member.text = userinfo.nickName;
//                    }
//                    
//                }
//                member.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f];
//                member.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
//                member.shadowOffset = CGSizeMake(0, 1);
//                member.textAlignment = UITextAlignmentLeft;
//                member.font = [UIFont systemFontOfSize:15];  
//                member.backgroundColor = [UIColor clearColor];
//                [self.imageviewMemberNameBG addSubview:member];
//                
//            }
//            //保存到大家列表按钮
            UIButton *btnSaveToGroup = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnSaveToGroup setFrame:CGRect_changeRelationAndSave];
            [btnSaveToGroup setBackgroundImage:[UIImage imageNamed:@"login_btn_login.png"] forState:UIControlStateNormal];
            [btnSaveToGroup setBackgroundImage:[UIImage imageNamed:@"login_btn_login_hover.png"] forState:UIControlStateHighlighted];
            //            [btnSaveToGroup setTitle:@"保存到大家列表" forState:UIControlStateNormal];
            //            [btnSaveToGroup setTitle:@"保存到大家列表" forState:UIControlStateHighlighted];
            btnSaveToGroup.tag = btnSaveToGroupTag;
            [btnSaveToGroup addTarget:self action:@selector(saveToGroup) forControlEvents:UIControlEventTouchUpInside];
            btnSaveToGroup.backgroundColor = [UIColor clearColor];
            [self.buttonView addSubview:btnSaveToGroup];
            
            
//            UILabel *labelUp = [[UILabel alloc] initWithFrame:CGRectMake(42.f, 5.f, 24.f, 12.f)];
//            labelUp.backgroundColor = [UIColor clearColor];
//            labelUp.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
//            labelUp.font = [UIFont systemFontOfSize:12.f];
//            labelUp.text = @"保存";
//            labelUp.textAlignment = UITextAlignmentCenter;
//            [btnSaveToGroup addSubview:labelUp];

            UILabel *labelDown = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 12.f, 80.f, 14.f)];
            labelDown.backgroundColor = [UIColor clearColor];
            labelDown.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
            labelDown.font = [UIFont systemFontOfSize:14.f];
            labelDown.text = @"保存到蜜友";
            labelDown.textAlignment = UITextAlignmentCenter;
            [btnSaveToGroup addSubview:labelDown];
            
            
        }
        //群
        else if([self.modelMessageGroup isMsgConverGroup]) {
        //else if(type == MSG_GROUP_UI_TYPE_MULTI) {
            
            [self changeMutilToGroup];
            
            
        }
        //根据groupID获取背景图
        [self.imageviewBGInMainView setImage:[UIImage imageNamed:[self getGroupAndMutilPictureNameWithGroupID]]];
        UIImageView *imageviewTableviewBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_im__graybackround.png"]];
        [imageviewTableviewBG setFrame:CGRect_tableview];
        [self.viewContentBG addSubview:imageviewTableviewBG];
        
        
        
//        UITableView *tableview = [[UITableView alloc] initWithFrame:CGRect_tableview style:UITableViewStylePlain];
//        tableview.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
//        tableview.delegate = self;
//        tableview.dataSource = self;
//        tableview.tableFooterView = tableviewFoot;
//        tableview.tag = TableViewTag;
//        tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//        tableview.backgroundColor = [UIColor clearColor];
//        [self.viewContentBG addSubview:tableview];
        
//<<<<<<< .mine
        self.groupUserInforScroll = [[GroupProfileScrollView alloc] initWithFrame:CGRect_tableview];
        self.groupUserInforScroll.backgroundColor = [UIColor clearColor];
        self.groupUserInforScroll.groupProfileScrollDelegate = self;
        //self.groupUserInforScroll.contentSize = CGSizeMake(320.f, 300);
        [self.viewContentBG addSubview:self.groupUserInforScroll];
        self.groupItems = [[NSMutableArray alloc] initWithCapacity:20];
        [self refreshGroupMembers];
//=======
//        UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRect_tableview];
//        scrollview.tag = TableViewTag;
//        scrollview.backgroundColor = [UIColor clearColor];
//        [self.viewContentBG addSubview:scrollview];
//>>>>>>> .r9388
        
        UIView *viewTest = [[UIView alloc] initWithFrame:CGRectMake(220.f, 160.f, 70.f, 40)];
        viewTest.backgroundColor = [UIColor clearColor];
        [self.viewContentBG addSubview:viewTest];
    }

    return self;
}
#pragma mark Method
-(void)touchInScrollView
{
    [self removeDelButton];
}
-(void)refreshGroupMembers{
    for (UIView *view in self.groupUserInforScroll.subviews) {
        if ([view isKindOfClass:[GroupUserItemView class]]) {
            [view removeFromSuperview];
        }else if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    int i = 0;
    if (self.modelMessageGroup.memberList > 0) {
        GroupUserItemView *userItem = nil;
        for (CPUIModelMessageGroupMember *member in self.modelMessageGroup.memberList) {
            //2012.8.6 加入是否是隐藏成员判断
            if (![member isHiddenMember]) {
                int row = i/4;
                int col = i%4;
                userItem = [[GroupUserItemView alloc] initGroupUserItem:member];
                userItem.frame = CGRectMake(20.0f + 75.0f * col, 15.0f + 85.0f *row, 75.0f, 85.0f);
                userItem.delegate = self;
                userItem.delButton.frame = CGRectMake(userItem.frame.origin.x - 23.0f, userItem.frame.origin.y - 23.0f, 47.5f, 47.5f);
                [self.groupUserInforScroll addSubview:userItem];
                [self.groupUserInforScroll addSubview:userItem.delButton];
                
                i++;     
            }
           
        }
        //int row = [self.modelMessageGroup.memberList count] / 4;
        int row = i / 4;
        if (i%4 == 0) {
            row -= 1;
        }
        UIView *scrollviewFoot = [self viewWithTag:tableviewFootTag];
        if (scrollviewFoot) {
            scrollviewFoot.center = CGPointMake(160.f, row*85.0f + 145.0f);    
            
        }else {
            //群成员tableview
            UIView *scrollviewFoot = [[UIView alloc] initWithFrame:CGRectMake(0, row*85.0f + 105.0f, 320.f, 80.f)];
            scrollviewFoot.tag = tableviewFootTag;
            scrollviewFoot.backgroundColor = [UIColor clearColor];
            UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            //[quitBtn setTitleColor:[UIColor colorWithRed:67/255.f green:67/255.f blue:67/255.f alpha:1.f] forState:UIControlStateNormal];
            [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

            
            quitBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
            quitBtn.titleLabel.textAlignment = UITextAlignmentCenter;
            [quitBtn setFrame:CGRectMake(106.f, 10.f, 107.f, 36.5f)];
            quitBtn.tag = quitBtnTag;
            [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_pet_downloadall.png"] forState:UIControlStateNormal];
            [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_pet_downloadallpress.png"] forState:UIControlStateHighlighted];
            [quitBtn addTarget:self action:@selector(quitGroup:) forControlEvents:UIControlEventTouchUpInside];
            [scrollviewFoot addSubview:quitBtn];
            
            UILabel *quitText = [[UILabel alloc] initWithFrame:CGRectMake(90.f, 56.5f, 130, 10.f)];
            quitText.font = [UIFont systemFontOfSize:10.f];
            quitText.textColor = [UIColor colorWithRed:185/255.f green:185/255.f blue:185/255.f alpha:1.f];
            quitText.textAlignment =  UITextAlignmentCenter;
            quitText.tag = quitTextTag;
            quitText.backgroundColor = [UIColor clearColor];
            [scrollviewFoot addSubview:quitText];
            
            [self.groupUserInforScroll addSubview:scrollviewFoot];
        }
        UIButton *quitBtn = (UIButton *)[self.groupUserInforScroll viewWithTag:quitBtnTag];
        UILabel *quitText = (UILabel *)[self.groupUserInforScroll viewWithTag:quitTextTag];
        if ([self.modelMessageGroup isMsgMultiConver]) {
            [quitBtn setTitle:@"退出" forState:UIControlStateNormal];
            quitText.text = @"不再接收新消息，且清空记录";
        }else if([self.modelMessageGroup isMsgConverGroup])
        {
            [quitBtn setTitle:@"我们" forState:UIControlStateNormal];
            quitText.text = @"";
        }
        
        self.groupUserInforScroll.contentSize = CGSizeMake(320.f,scrollviewFoot.frame.origin.y+scrollviewFoot.frame.size.height);
    }
}

-(void) longPressGroupUserItem:(GroupUserItemView *)item{
    GroupUserItemView *userItem = nil;
    for (UIView *view in self.groupUserInforScroll.subviews) {
        if ([view isKindOfClass:[GroupUserItemView class]]) {
            userItem = (GroupUserItemView *)view;
            [userItem hiddenDelButton];
        }
    }
    [item showDelButton];
}

-(void) clickGroupUserItem : (GroupUserItemView *) item{
    
    if (item.isDel) {
        if ([CPUIModelManagement sharedInstance].sysOnlineStatus == SYS_STATUS_ONLINE) {
            if ([self.groupProfileDelegate respondsToSelector:@selector(deleteGroupMember:andMemberArr:)]) {
                [self.groupProfileDelegate deleteGroupMember:self.modelMessageGroup andMemberArr:[NSArray arrayWithObject:item.member]];
            }
        }
    }else {
        GroupUserItemView *userItem = nil;
        for (UIView *view in self.groupUserInforScroll.subviews) {
            if ([view isKindOfClass:[GroupUserItemView class]]) {
                userItem = (GroupUserItemView *)view;
                [userItem hiddenDelButton];
            }
        }
        
        CPUIModelUserInfo *oldUserInfo = item.member.userInfo;
        CPUIModelUserInfo *userInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:oldUserInfo.name];
        
        if (userInfo) {
//            if ([userInfo.type integerValue] == USER_RELATION_TYPE_LOVER || [userInfo.type integerValue] == USER_RELATION_TYPE_COUPLE || [userInfo.type integerValue] == USER_RELATION_TYPE_MARRIED) {
//                if ([self.groupProfileDelegate respondsToSelector:@selector(turnToCoupleProfileView)]) {
//                    [self.groupProfileDelegate turnToCoupleProfileView];
//                }
//            }else {
//                if ([self.groupProfileDelegate respondsToSelector:@selector(turnToProfileView:)]) {
//                    [self.groupProfileDelegate turnToProfileView:userInfo.name];
//                }        
//            }     
            if ([self.groupProfileDelegate respondsToSelector:@selector(turnToIndependentProfileView:)]) {
                [self.groupProfileDelegate turnToIndependentProfileView:userInfo];
            } 
        }else {
            userInfo = [[CPUIModelUserInfo alloc] init];
            
            [userInfo setHeaderPath:item.member.headerPath];
            [userInfo setNickName:item.member.nickName];
            [userInfo setName:item.member.userName];
            if (!item.member.mobileNumber) {
                [userInfo setMobileNumber:item.member.userInfo.mobileNumber];
            }else {
                [userInfo setMobileNumber:item.member.mobileNumber];    
            }
            
            if ([self.groupProfileDelegate respondsToSelector:@selector(turnToContactProfileDelegate:)]) {
                [self.groupProfileDelegate turnToContactProfileDelegate:userInfo];
            } 
        }
    }
}

-(void) removeDelButton{
//    GroupUserItemView *userItem = nil;
    for (GroupUserItemView *view in self.groupUserInforScroll.subviews) {
        if ([view isKindOfClass:[GroupUserItemView class]]) {
            [view hiddenDelButton];
            //[userItem hiddenDelButton];
        }
    }
}


-(void)setMutilGroupContent
{
    if ([self.modelMessageGroup isMsgMultiConver]) {
//    UIImage *image = [UIImage imageNamed:@"bg_default.jpg"];
//    [self.imageviewBGInMainView setImage:image];
        
    //if (type == MSG_GROUP_UI_TYPE_CONVER) {
        NSMutableArray *memberListArr = [[NSMutableArray alloc] init];
        int k = 0;
        for (CPUIModelMessageGroupMember *member in self.modelMessageGroup.memberList) {
            if (![member isHiddenMember]) {
                [memberListArr addObject:member];
                k++;
            }
        }
    int j = 0;
    if (k >3) {
        j = 4;
    }else if (k >0 && k <= 3)
    {
        j = k;
        if ([self.imageviewMemberNameBG viewWithTag:LabelTextFirstMemberTag]) {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextFirstMemberTag] removeFromSuperview];
        } 
        if([self.imageviewMemberNameBG viewWithTag:LabelTextSecondMemberTag])
        {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextSecondMemberTag] removeFromSuperview];
        }
        if([self.imageviewMemberNameBG viewWithTag:LabelTextThirdMemberTag])
        {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextThirdMemberTag] removeFromSuperview];
        }
        if([self.imageviewMemberNameBG viewWithTag:LabelTextDotTag])
        {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextDotTag] removeFromSuperview];
        }
    }else if(k == 0 ){
        j = 0;
        if ([self.imageviewMemberNameBG viewWithTag:LabelTextFirstMemberTag]) {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextFirstMemberTag] removeFromSuperview];
        } 
        if([self.imageviewMemberNameBG viewWithTag:LabelTextSecondMemberTag])
        {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextSecondMemberTag] removeFromSuperview];
        }
        if([self.imageviewMemberNameBG viewWithTag:LabelTextThirdMemberTag])
        {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextThirdMemberTag] removeFromSuperview];
        }
        if([self.imageviewMemberNameBG viewWithTag:LabelTextDotTag])
        {
            [[self.imageviewMemberNameBG viewWithTag:LabelTextDotTag] removeFromSuperview];
        }
    }
    NSMutableArray *arrRandomNumber = [[NSMutableArray alloc] initWithCapacity:3];
    if (j>2) {
        while (arrRandomNumber.count != 3) {
            int randomNumber = arc4random()%k;   
            if (![arrRandomNumber containsObject:[NSNumber numberWithInt:randomNumber]]) {
                [arrRandomNumber addObject:[NSNumber numberWithInt:randomNumber]];
            }
            
        }                
    }else {
        for (int i= 0; i<k; i++) {
            [arrRandomNumber addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    
    for (int i = 0; i< j ; i++) {
        UILabel *member ;
        switch (i) {
            case 0:
            {
                if ([self.imageviewMemberNameBG viewWithTag:LabelTextFirstMemberTag]) {
                    member = (UILabel *)[self.imageviewMemberNameBG viewWithTag:LabelTextFirstMemberTag];
                }else {
                    member = [[UILabel alloc] init];
                    member.tag = LabelTextFirstMemberTag;
                    [self.imageviewMemberNameBG addSubview:member];
                }
            }
                break;
            case 1:
            {
                if ([self.imageviewMemberNameBG viewWithTag:LabelTextSecondMemberTag]) {
                    member = (UILabel *)[self.imageviewMemberNameBG viewWithTag:LabelTextSecondMemberTag];
                }else {
                    member = [[UILabel alloc] init];
                    member.tag = LabelTextSecondMemberTag;
                    [self.imageviewMemberNameBG addSubview:member];
                }                
            }
                break;
            case 2:
            {
                if ([self.imageviewMemberNameBG viewWithTag:LabelTextThirdMemberTag]) {
                    member = (UILabel *)[self.imageviewMemberNameBG viewWithTag:LabelTextThirdMemberTag];
                }else {
                    member = [[UILabel alloc] init];
                    member.tag = LabelTextThirdMemberTag;
                    [self.imageviewMemberNameBG addSubview:member];
                }
            }
                break;
            case 3:
            {
                if ([self.imageviewMemberNameBG viewWithTag:LabelTextDotTag]) {
                    member = (UILabel *)[self.imageviewMemberNameBG viewWithTag:LabelTextDotTag];
                }else {
                    member = [[UILabel alloc] init];
                    member.tag = LabelTextDotTag;
                    [self.imageviewMemberNameBG addSubview:member];
                }
            }
                break;
            default:
                break;
        }
        member.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f];
        member.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
        member.shadowOffset = CGSizeMake(0, 1);
        member.textAlignment = UITextAlignmentLeft;
        member.font = [UIFont systemFontOfSize:15];  
        member.backgroundColor = [UIColor clearColor];
        
        
        if (i == 3) {
            
            [member setFrame:CGRectMake(10.f, 44.0f+19*i, 22, 10.0f)];
            member.text = @"...";
            
        }else {
            CPUIModelMessageGroupMember *memberInfo = [memberListArr objectAtIndex:[[arrRandomNumber objectAtIndex:i]intValue]];
            CPUIModelUserInfo *userinfo = memberInfo.userInfo;
            [member setFrame:CGRectMake(10.f, 44.0f+19*i, 60, 16.5f)];

            if (!userinfo) {
                member.text = memberInfo.nickName;    
            }else {
                member.text = userinfo.nickName;
            }
            
        }

        
    }
       
}
}
//刷新群profile内容
-(void)refreshGroupProfileContent
{
    UILabel *labelGroupNumber = (UILabel *)[self viewWithTag:LabelTextGroupMemberNumberTag];
    if (labelGroupNumber) {
        if (self.modelMessageGroup.memberList.count == 0) {
            labelGroupNumber.text = [NSString stringWithFormat:@"%d",1];    
        }else {
            int i = 0;
            for (CPUIModelMessageGroupMember *member in self.modelMessageGroup.memberList) {
                if (![member isHiddenMember]) {
                    i++;
                }
            }
            labelGroupNumber.text = [NSString stringWithFormat:@"%d",i+1];   
        }        
    }
    [self setMutilGroupContent];
    [self refreshGroupMembers];
    /*
     重构群成员tableview
     */
//    UITableView *tableview = (UITableView *)[self viewWithTag:TableViewTag];
//    [tableview reloadData];
}
//修改群名
-(void)changeGroupName
{
    [self viewWithTag:LabelGroupNameTag].hidden = YES;
    [self viewWithTag:ButtonChangeGroupNameTag].hidden = YES;
    UIImageView *imageviewTextfiledBG = (UIImageView *)[self viewWithTag:imageviewTextfiledBGTag];
    if (!imageviewTextfiledBG) {
        //输入框背景图
        imageviewTextfiledBG = [[UIImageView alloc] initWithFrame:CGRect_imageviewTextfiledBG];
        UIImage *image1 = [UIImage imageNamed:@"bt_im_profile_inputgroupname.png"];
        UIImage *image = [image1 stretchableImageWithLeftCapWidth:image1.size.width/2.f topCapHeight:image1.size.height/2.f];
        [imageviewTextfiledBG setImage:image];
        imageviewTextfiledBG.tag = imageviewTextfiledBGTag;
        imageviewTextfiledBG.backgroundColor = [UIColor clearColor];
        [self.buttonView addSubview:imageviewTextfiledBG];        
    }else {
        imageviewTextfiledBG.hidden = NO;
    }
    UITextField *textfield = (UITextField *)[self viewWithTag:TextfiledChangeGroupNameTag];
    if (!textfield) {
        //输入框
        textfield = [[UITextField alloc] initWithFrame:CGRect_textfiled];
        textfield.font = [UIFont systemFontOfSize:15.f];
        textfield.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
        textfield.delegate = self;
        textfield.enablesReturnKeyAutomatically = YES;
        textfield.returnKeyType = UIReturnKeyDone;
        textfield.textAlignment = UITextAlignmentLeft;
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.tag = TextfiledChangeGroupNameTag;
        [imageviewTextfiledBG addSubview:textfield];
        
    }else {
        textfield.hidden = NO;
    }
    
    [textfield becomeFirstResponder];        
   
    //self.buttonView.center = CGPointMake(self.buttonView.center.x, self.buttonView.center.y-12.f);

}
//退群
-(void)quitGroup:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"退出"]) {
        if ([CPUIModelManagement sharedInstance].sysOnlineStatus == SYS_STATUS_ONLINE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"以后不会再接收消息，确定退出么?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",@"取消", nil];
            alert.delegate = self;
            [alert show];
        }else
        {
            [[HPTopTipView shareInstance] showMessage:@"当前网络未连接,请稍后再试"];
        }
    }else if([sender.titleLabel.text isEqualToString:@"我们"])
    {
        if ([self.groupProfileDelegate respondsToSelector:@selector(turnToGroupindependentProfile:)]) {
            [self.groupProfileDelegate turnToGroupindependentProfile:self.modelMessageGroup];
        }
        
    }

}
//添加friend
-(void)plusFriend
{
    
    if (self.modelMessageGroup.memberList.count < 19) {
        [self recoverGroupPrifleDeleteStatus];    
        if ([self.profileViewDelegate respondsToSelector:@selector(addFriendInFriendViewController)]) {
            [self.profileViewDelegate addFriendInFriendViewController];
        }        
    }else {
        if ([self.modelMessageGroup.type integerValue] == MSG_GROUP_UI_TYPE_MULTI || [self.modelMessageGroup.type integerValue] == MSG_GROUP_UI_TYPE_CONVER) {
        [[HPTopTipView shareInstance] showMessage:@"这里很热闹，已经满20人啦" duration:1.5];    
          }  
//        else if([self.modelMessageGroup.type integerValue] == MSG_GROUP_UI_TYPE_CONVER)
//        {
//        [[HPTopTipView shareInstance] showMessage:@"群组很热闹，已经满20人啦" duration:1.5];    
//        }
        
    }

}
//获取到图片
-(NSString *)getGroupAndMutilPictureNameWithGroupID
{
    NSString *msgGroupID = [self.modelMessageGroup.msgGroupID stringValue];
    //没有群ID字典时
    if (![[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]) {
        NSMutableDictionary *groupIdWithGroupNameDic = [[NSMutableDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setValue:groupIdWithGroupNameDic forKey:GroupIdWithNameDic];
    }
    NSMutableDictionary *groupId = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]];
    //对应groupID有值的话直接取，没有的话则获取个新的
    if ([groupId objectForKey:msgGroupID]) {
        return [groupId objectForKey:msgGroupID];
    }else {
        //没有群名字典时
        NSDictionary *tempGroupPicNameWithStatusDic = [[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic];
        if (!tempGroupPicNameWithStatusDic||[tempGroupPicNameWithStatusDic count]==0) {
            NSMutableDictionary *groupNameDic = [[NSMutableDictionary alloc] init];
            for (int i = 1; i<6; i++) {
                NSString *str = [NSString stringWithFormat:@"pic_im_drlt00%d.jpg",i];
                [groupNameDic setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:str];
            }
            [[NSUserDefaults standardUserDefaults] setObject:groupNameDic forKey:GroupPicNameWithStatusDic];
        }
        
        NSMutableDictionary *groupName = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic]];
        //判断是否当前都是以用的图片
        if (![groupName.allValues containsObject:[NSNumber numberWithInt:PictureUnUsed]]) {
            //重置图片状态
            
            for (NSString *strPicName in groupName.allKeys) {
                [groupName setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:strPicName];
            }
        }
        

        
        for (NSString *str in groupName.allKeys) {
            //如果取出来的是未使用
            if ([[groupName objectForKey:str] intValue] == PictureUnUsed) {
                //改变图片状态为已使用
                [groupName setValue:[NSNumber numberWithInt:PicturenUsed] forKey:str];
                //存入对应groupID的图片
                [groupId setValue:str forKey:msgGroupID];
                [[NSUserDefaults standardUserDefaults] setValue:groupId forKey:GroupIdWithNameDic];
                [[NSUserDefaults standardUserDefaults] setValue:groupName forKey:GroupPicNameWithStatusDic];
                return str;
            }
        }
    }
    
    return [NSString stringWithFormat:@"pic_im_drlt00%d.jpg",1];
    
}

//获取到图片
-(NSString *)getPictureNameWithGroupID
{
    NSString *msgGroupID = [self.modelMessageGroup.msgGroupID stringValue];
    //没有群ID字典时
    if (![[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]) {
        NSMutableDictionary *groupIdWithGroupNameDic = [[NSMutableDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setValue:groupIdWithGroupNameDic forKey:GroupIdWithNameDic];
    }
    NSMutableDictionary *groupId = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupIdWithNameDic]];
    //对应groupID有值的话直接取，没有的话则获取个新的
    if ([groupId objectForKey:msgGroupID]) {
        return [groupId objectForKey:msgGroupID];
    }else {
        //没有群名字典时
        NSDictionary *tempGroupPicNameWithStatusDic = [[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic];
        if (!tempGroupPicNameWithStatusDic||[tempGroupPicNameWithStatusDic count]==0) {
            NSMutableDictionary *groupNameDic = [[NSMutableDictionary alloc] init];
            for (int i = 1; i<10; i++) {
                NSString *str = [NSString stringWithFormat:@"pic_im_drlt00%d.jpg",i];
                [groupNameDic setValue:[NSNumber numberWithInt:PictureUnUsed] forKey:str];
            }
            [[NSUserDefaults standardUserDefaults] setObject:groupNameDic forKey:GroupPicNameWithStatusDic];
        }
        
        NSMutableDictionary *groupName = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:GroupPicNameWithStatusDic]];
        for (NSString *str in groupName.allKeys) {
            //如果取出来的是未使用
            if ([[groupName objectForKey:str] intValue] == PictureUnUsed) {
                //改变图片状态为已使用
                [groupName setValue:[NSNumber numberWithInt:PicturenUsed] forKey:str];
                //存入对应groupID的图片
                [groupId setValue:str forKey:msgGroupID];
                [[NSUserDefaults standardUserDefaults] setValue:groupId forKey:GroupIdWithNameDic];
                [[NSUserDefaults standardUserDefaults] setValue:groupName forKey:GroupPicNameWithStatusDic];
                return str;
            }
        }
    }
    
    return [NSString stringWithFormat:@"pic_im_drlt00%d.jpg",1];
    
}
//改变多人会话到群的状态
-(void)changeMutilToGroup
{
    
    
    //[self.imageviewBGInMainView setImage:[UIImage imageNamed:[self getPictureNameWithGroupID]]];
    if ([self viewWithTag:btnSaveToGroupTag]) {
        [[self viewWithTag:btnSaveToGroupTag] removeFromSuperview];
    }
    if (([self viewWithTag:imageviewTextfiledBGTag].hidden && [self viewWithTag:TextfiledChangeGroupNameTag].hidden) || (![self viewWithTag:TextfiledChangeGroupNameTag] && ![self viewWithTag:imageviewTextfiledBGTag])) {
        UILabel *groupNameLabel = (UILabel *)[self viewWithTag:GroupNameLabelTag];
        if (!groupNameLabel) {
            for (UILabel *label in self.imageviewMemberNameBG.subviews) {
                if (label.tag != LabelTextRenTag && label.tag != LabelTextGroupMemberNumberTag && [label isKindOfClass:[UILabel class]]) {
                    [label removeFromSuperview];
                }
            }
            //右上角群名
            UILabel *groupName = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 40.f, 100.f, 60.f)];
            groupName.font = [UIFont systemFontOfSize:15.f];
            groupName.numberOfLines = 3.f;
            groupName.lineBreakMode = UILineBreakModeWordWrap;
            groupName.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f];
            groupName.textAlignment = UITextAlignmentLeft;
            groupName.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
            groupName.shadowOffset = CGSizeMake(0, 1);
            groupName.tag = GroupNameLabelTag;
            groupName.text = self.modelMessageGroup.groupName;
            groupName.backgroundColor = [UIColor clearColor];
            [self.imageviewMemberNameBG addSubview:groupName];            
        }else {
            groupNameLabel.text = self.modelMessageGroup.groupName;
        }
        

        
        UILabel *labelGroupName = (UILabel *)[self viewWithTag:LabelGroupNameTag];
        if (!labelGroupName) {
            labelGroupName = [[UILabel alloc] initWithFrame:CGRectMake(160.f, 12.f, 107.f, 20.f)];
            labelGroupName.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.f];
            labelGroupName.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
            labelGroupName.shadowOffset = CGSizeMake(0.0f, 1.0f);
            labelGroupName.font = [UIFont boldSystemFontOfSize:15.f];
            labelGroupName.text = self.modelMessageGroup.groupName;
            labelGroupName.backgroundColor = [UIColor clearColor];
            labelGroupName.tag = LabelGroupNameTag;
            [self.buttonView addSubview:labelGroupName];        
        }else {
            labelGroupName.hidden = NO;
            labelGroupName.text = self.modelMessageGroup.groupName;
        }
        
        if (![self viewWithTag:ButtonChangeGroupNameTag]) {
            UIButton *btnChangeGroupName = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnChangeGroupName setFrame:CGRectMake(160.f, 17.f, 140.f, 15.f)];
//            [btnChangeGroupName setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_pen.png"] forState:UIControlStateNormal];
//            [btnChangeGroupName setBackgroundImage:[UIImage imageNamed:@"bt_im_profile_penpress.png"] forState:UIControlStateHighlighted];
            [btnChangeGroupName setImage:[UIImage imageNamed:@"bt_im_profile_pen.png"] forState:UIControlStateNormal];
            [btnChangeGroupName setImage:[UIImage imageNamed:@"bt_im_profile_penpress.png"] forState:UIControlStateHighlighted];
            [btnChangeGroupName setImageEdgeInsets:UIEdgeInsetsMake(0, 125.f, 0, 0)];
            [btnChangeGroupName addTarget:self action:@selector(changeGroupName) forControlEvents:UIControlEventTouchUpInside];
            btnChangeGroupName.tag = ButtonChangeGroupNameTag;
            [self.buttonView addSubview:btnChangeGroupName];        
        }else {
            [self viewWithTag:ButtonChangeGroupNameTag].hidden = NO;
        }
        [self refreshGroupMembers];
    }else if(![self viewWithTag:imageviewTextfiledBGTag].hidden && ![self viewWithTag:TextfiledChangeGroupNameTag].hidden)
    {
        [self viewWithTag:imageviewTextfiledBGTag].hidden = YES;
        [self viewWithTag:TextfiledChangeGroupNameTag].hidden = YES;
        [self changeMutilToGroup];
    }
   
}
//点击空白区域
-(void)tapByController
{
    if ([[self viewWithTag:TextfiledChangeGroupNameTag] isFirstResponder]) {
        UITextField *textfield = (UITextField *)[self viewWithTag:TextfiledChangeGroupNameTag];
        [textfield resignFirstResponder];
        if (![textfield.text isEqualToString:@""] && textfield.text.length<18) {
            if ([self.groupProfileDelegate respondsToSelector:@selector(modifyFavoriteGroupName:andGroupName:)]) {
                [self.groupProfileDelegate modifyFavoriteGroupName:self.modelMessageGroup andGroupName:textfield.text];
            }            
        }else {
            if ([textfield.text isEqualToString:@""]) {
                [[HPTopTipView shareInstance] showMessage:@"群名称不能为空" duration:1.5];
            }else if(textfield.text.length > 18)
            {
                [[HPTopTipView shareInstance] showMessage:@"名字不能超过18个字符" duration:1.5];
            }
            [self changeMutilToGroup];
            [textfield resignFirstResponder];
        }

    }
    
    [self removeDelButton];
    //[self recoverGroupPrifleDeleteStatus];

}
#pragma mark AlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
       // [[CPUIModelManagement sharedInstance] quitGroupWithGroup:self.modelMessageGroup];
        if ([self.groupProfileDelegate respondsToSelector:@selector(quitGroup:)]) {
            [self.groupProfileDelegate quitGroup:self.modelMessageGroup];
        }
    }
}
#pragma mark SetGroupNameView
//保存多人会话成为群
-(void)saveToGroup
{
    [self recoverGroupPrifleDeleteStatus];
    int i =0;
    NSArray *groupList = [CPUIModelManagement sharedInstance].userMessageGroupList;
    for (CPUIModelMessageGroup *group in groupList) {
        if ([group isMsgConverGroup]) {
            i++;
        }
    }
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
    }else if(i == 10) {
        [[HPTopTipView shareInstance] showMessage:@"群数达到上线"];        
    }
    
    else {
        UIView *setGroupName = [[UIView alloc] initWithFrame:CGRectMake(42.f, 45.f, 236.f, 176.f)];
        setGroupName.backgroundColor = [UIColor clearColor];
        setGroupName.tag = SetGroupNameViewTag;
        [self addSubview:setGroupName];
        
        
        
        UIImageView *imageviewBG = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"im_float_profile" ofType:@"png"]]];
        [imageviewBG setFrame:CGRectMake(0, 0, setGroupName.frame.size.width, setGroupName.frame.size.height)];
        [setGroupName addSubview:imageviewBG];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25.f, 22.5f, 186.f, 15.f)];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"起个名字吧";
        label.textColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15.f];
        [setGroupName addSubview:label];
        
        UIButton *closeView = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeView setFrame:CGRectMake(206.f, 2.5f, 33.f, 33.f)];
//        [closeView setBackgroundImage:[UIImage imageNamed:@"im_x_profile.png"] forState:UIControlStateNormal];
//        [closeView setBackgroundImage:[UIImage imageNamed:@"im_xpress_profile.png"] forState:UIControlStateHighlighted];
        [closeView setImage:[UIImage imageNamed:@"im_x_profile.png"] forState:UIControlStateNormal];
        [closeView setImage:[UIImage imageNamed:@"im_xpress_profile.png"] forState:UIControlStateHighlighted];
        closeView.imageEdgeInsets = UIEdgeInsetsMake(7, 5, 13, 15);
        [closeView addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        [setGroupName addSubview:closeView];
        
        UIImageView *imageviewTextField= [[UIImageView alloc] initWithFrame:CGRectMake(25.f, 60.f, 186.f, 36.f)];
        imageviewTextField.layer.cornerRadius = 20.f;
        imageviewTextField.layer.masksToBounds = YES;
        imageviewTextField.backgroundColor = [UIColor whiteColor];
        [setGroupName addSubview:imageviewTextField];
        
        UITextField *textFieldGroupName = [[UITextField alloc] initWithFrame:CGRectMake(11.f, 9, 164.f, 17.f)];
        textFieldGroupName.font = [UIFont systemFontOfSize:14.f];
        textFieldGroupName.delegate = self;
        textFieldGroupName.returnKeyType = UIReturnKeyDone;
        textFieldGroupName.tag = TextfiledGroupNameTag;
        [imageviewTextField addSubview:textFieldGroupName];
        [textFieldGroupName becomeFirstResponder];
        
        
        UIButton *Save = [UIButton buttonWithType:UIButtonTypeCustom];
        [Save setBackgroundImage:[UIImage imageNamed:@"sure_im_magicdownload.png"] forState:UIControlStateNormal];
        [Save setBackgroundImage:[UIImage imageNamed:@"surepress_im_magicdownload.png"] forState:UIControlStateHighlighted];
        [Save setFrame:CGRectMake(75.f, 118.5f, 86.f, 36.f)];
        Save.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [Save setTitleColor:[UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1.f] forState:UIControlStateNormal];
        [Save setTitle:@"保存" forState:UIControlStateNormal];
        Save.titleLabel.backgroundColor = [UIColor clearColor];
        Save.titleLabel.textAlignment = UITextAlignmentCenter;
        [Save addTarget:self action:@selector(saveGroupName) forControlEvents:UIControlEventTouchUpInside];
        [setGroupName addSubview:Save];

    }
    
        
//    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancel setBackgroundImage:[UIImage imageNamed:@"btn_cancle_profile.png"] forState:UIControlStateNormal];
//    [cancel setBackgroundImage:[UIImage imageNamed:@"btn_canclepress_profile.png"] forState:UIControlStateHighlighted];
//    [cancel setFrame:CGRectMake(125.f, 118.5f, 73.5f, 36.5f)];
//    cancel.titleLabel.font = [UIFont systemFontOfSize:14.f];
//    [cancel setTitleColor:[UIColor colorWithRed:66/255.f green:66/255.f blue:66/255.f alpha:1.f] forState:UIControlStateNormal];
//    [cancel setTitle:@"取消" forState:UIControlStateNormal];
//    cancel.titleLabel.backgroundColor = [UIColor clearColor];
//    cancel.titleLabel.textAlignment = UITextAlignmentCenter;
//    [cancel addTarget:self action:@selector(cancelGroupName) forControlEvents:UIControlEventTouchUpInside];
//    [setGroupName addSubview:cancel];
    
}
//关闭
-(void)closeView
{
    if ([self viewWithTag:SetGroupNameViewTag]) {
        [[self viewWithTag:SetGroupNameViewTag] removeFromSuperview];
    }
}
//保存
-(void)saveGroupName
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[HPTopTipView shareInstance] showMessage:@"当前未连接网络，请联网后重试"];
        
    }else {
        
        UIView *view = [self viewWithTag:SetGroupNameViewTag];
        UITextField *textfield = (UITextField *)[view viewWithTag:TextfiledGroupNameTag];
        if ([textfield.text isEqualToString:@""] || [textfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
            
            UILabel *label = (UILabel *)[self viewWithTag:WaringTextLabelTag];
            if (!label) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 102.5, 135.f, 10.f)];
                label.text = @"还没有名字呢";
                label.textColor = [UIColor colorWithRed:234/255.f green:80/255.f blue:50/255.f alpha:1.f];
                label.textAlignment = UITextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:10.f];
                label.backgroundColor = [UIColor clearColor];
                label.tag = WaringTextLabelTag;
                [view addSubview:label];            
            }
            UIImageView *imageview = (UIImageView *)[self viewWithTag:WaringImgTag];
            if (!imageview) {
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_！_im.png"]];
                [imageview  setFrame:CGRectMake(193.f, 51.f, 17.f, 17.f)];
                [imageview  setTag:WaringImgTag];
                [view addSubview:imageview];            
            }
        }else{
            
            if (textfield.text.length > 18) {
                UILabel *label = (UILabel *)[self viewWithTag:WaringTextLabelTag];
                if (!label) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 102.5, 135.f, 10.f)];
                    label.text = @"名字最多18个字";
                    label.textColor = [UIColor colorWithRed:234/255.f green:80/255.f blue:50/255.f alpha:1.f];
                    label.textAlignment = UITextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:10.f];
                    label.backgroundColor = [UIColor clearColor];
                    label.tag = WaringTextLabelTag;
                    [view addSubview:label];            
                }
                UIImageView *imageview = (UIImageView *)[self viewWithTag:WaringImgTag];
                if (!imageview) {
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_！_im.png"]];
                    [imageview  setFrame:CGRectMake(193.f, 51.f, 17.f, 17.f)];
                    [imageview  setTag:WaringImgTag];
                    [view addSubview:imageview];            
                }
            }else {
                if ([CPUIModelManagement sharedInstance].sysOnlineStatus == SYS_STATUS_ONLINE) {
//                    [[CPUIModelManagement sharedInstance] addFavoriteGroupWithGroup:self.modelMessageGroup andName:textfield.text];
//                    
//
//                    [self closeView];
                    if ([self.groupProfileDelegate respondsToSelector:@selector(addFavoriteGroup:andGroupName:)]) {
                        [self.groupProfileDelegate addFavoriteGroup:self.modelMessageGroup andGroupName:textfield.text];
                        [self closeView];
                    }
                }
            }
        }
    }
}
//取消
-(void)cancelGroupName
{
    UIView *view = [self viewWithTag:SetGroupNameViewTag];
    UITextField *textfield = (UITextField *)[view viewWithTag:TextfiledGroupNameTag];
    textfield.text = @"";
}

#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //如果是全空格则直接给textfield赋空值
    if ([textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    if (![textField.text isEqualToString:@""]) {
        //只要不为空则添加群名成功
        if (textField.tag == TextfiledGroupNameTag) {
           // [[CPUIModelManagement sharedInstance] addFavoriteGroupWithGroup:self.modelMessageGroup andName:textField.text];
            if (textField.text.length > 18) {
                 UIView *view = [self viewWithTag:SetGroupNameViewTag];
                UILabel *label = (UILabel *)[self viewWithTag:WaringTextLabelTag];
                if (!label) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.f, 102.5, 135.f, 10.f)];
                    label.text = @"名字不能超过18个字符";
                    label.textColor = [UIColor colorWithRed:234/255.f green:80/255.f blue:50/255.f alpha:1.f];
                    label.textAlignment = UITextAlignmentCenter;
                    label.font = [UIFont systemFontOfSize:10.f];
                    label.backgroundColor = [UIColor clearColor];
                    label.tag = WaringTextLabelTag;
                    [view addSubview:label];            
                }
                UIImageView *imageview = (UIImageView *)[self viewWithTag:WaringImgTag];
                if (!imageview) {
                    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"item_！_im.png"]];
                    [imageview  setFrame:CGRectMake(193.f, 51.f, 17.f, 17.f)];
                    [imageview  setTag:WaringImgTag];
                    [view addSubview:imageview];            
                }
                return NO;
            }else {
                if ([CPUIModelManagement sharedInstance].sysOnlineStatus == SYS_STATUS_ONLINE) {
                    if ([self.groupProfileDelegate respondsToSelector:@selector(addFavoriteGroup:andGroupName:)]) {
                        [self.groupProfileDelegate addFavoriteGroup:self.modelMessageGroup andGroupName:textField.text];
                        [self closeView];
                    }
                    //[[CPUIModelManagement sharedInstance] addFavoriteGroupWithGroup:self.modelMessageGroup andName:textField.text];
                    
                    
                }
                return YES;
            }
        }else if(textField.tag == TextfiledChangeGroupNameTag)
        {
            if (textField.text.length > 18) {
                [[HPTopTipView shareInstance] showMessage:@"名字不能超过18个字符"];
                return NO;
            }
            if ([self.groupProfileDelegate respondsToSelector:@selector(modifyFavoriteGroupName:andGroupName:)]) {
                [self.groupProfileDelegate modifyFavoriteGroupName:self.modelMessageGroup andGroupName:textField.text];
            }
            //[[CPUIModelManagement sharedInstance] modifyFavoriteGroupNameWithGroup:self.modelMessageGroup withGroupName:textField.text];
        }
        [textField resignFirstResponder];
        return YES;        
    }else {
        if (textField.tag == TextfiledGroupNameTag) {
           // [self closeView];
            [self saveGroupName];
            return NO;
        }
        //改群名时全空格点完成 为取消效果
        else if (textField.tag == TextfiledChangeGroupNameTag)
        {
            [self changeMutilToGroup];
            [textField resignFirstResponder];
        }
        return NO;
    }

}
-(void)textFieldDidBeginEditing:(UITextField *)textField 
{
    textField.text = self.modelMessageGroup.groupName;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (![textField.text isEqualToString:@""] && textField.text.length <18) {
        UIView *view = [self viewWithTag:SetGroupNameViewTag];
        if (view) {
            [[view viewWithTag:WaringTextLabelTag] removeFromSuperview];
            [[view viewWithTag:WaringImgTag] removeFromSuperview];            
        }

    }else {
        if (textField.text.length >= 18 &&  ![string isEqualToString:@""] ) {
            return NO;    
        }
        
//        if([textField.text length]>=30){
//            NSString * end_text_string = [textField.text substringToIndex:30];
//            textField.text = end_text_string;
//            return NO;
//        }
    }
    return YES;
}
#pragma mark TableviewDelegate
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 85.f;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.groupMembers allKeys].count;
//    //return 20;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *identifier = @"basecell";
//    GroupProfileTableViewCell *cell = nil;
//    
//    cell = (GroupProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
//    
//    if (nil == cell) {
//        cell = [[GroupProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
//                                                reuseIdentifier:identifier 
//                                                      IndexPath:indexPath 
//                                             MessageGroupMember:[self.groupMembers objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]]];
//    }else {
//        [cell setContent:indexPath MessageGroupMember:[self.groupMembers objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]]];
//    }
//    
//    cell.cellDelegate = self;
//    cell.selectionStyle = UITableViewCellEditingStyleNone;
//    return cell;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark GroupPrifleCellMethod
-(void)recoverGroupPrifleDeleteStatus
{
    if ([HomeInfo shareObject].deleteViewTag != -1) {
        UITableView *tableview = (UITableView *)[self viewWithTag:TableViewTag];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[HomeInfo shareObject].deleteViewTag/10 inSection:0];
        GroupProfileTableViewCell *cell = (GroupProfileTableViewCell *)[tableview cellForRowAtIndexPath:indexPath];
        [[[cell viewWithTag:[HomeInfo shareObject].deleteViewTag] viewWithTag:btnDelTag] removeFromSuperview];
        [HomeInfo shareObject].deleteViewTag = -1;
    }
}

#pragma mark GroupProfileCellDelegate
-(void)turnToProfileView:(NSInteger)memberTag
{
    NSMutableArray *arrMembers = [self.groupMembers objectForKey:[NSString stringWithFormat:@"%d",memberTag/10]];
    CPUIModelMessageGroupMember *member = [arrMembers objectAtIndex:memberTag%10];
    CPUIModelUserInfo *oldUserInfo = member.userInfo;
    CPUIModelUserInfo *userInfo = [[CPUIModelManagement sharedInstance] getUserInfoWithUserName:oldUserInfo.name];
    
    
    if (userInfo) {
        if ([userInfo.type integerValue] == USER_RELATION_TYPE_LOVER || [userInfo.type integerValue] == USER_RELATION_TYPE_COUPLE || [userInfo.type integerValue] == USER_RELATION_TYPE_MARRIED) {
            if ([self.groupProfileDelegate respondsToSelector:@selector(turnToCoupleProfileView)]) {
                [self.groupProfileDelegate turnToCoupleProfileView];
            }
        }else {
            if ([self.groupProfileDelegate respondsToSelector:@selector(turnToIndependentProfileView:)]) {
                [self.groupProfileDelegate turnToIndependentProfileView:userInfo];
            }        
        }        
    }else {
        userInfo = [[CPUIModelUserInfo alloc] init];
        [userInfo setHeaderPath:member.headerPath];
        [userInfo setNickName:member.nickName];
        [userInfo setName:member.userName];
        if ([self.groupProfileDelegate respondsToSelector:@selector(turnToContactProfileDelegate:)]) {
            [self.groupProfileDelegate turnToContactProfileDelegate:userInfo];
        } 
    }


}
-(void)recoverDeleteStatus
{
    [self recoverGroupPrifleDeleteStatus];
}
-(void)deleteGroupMember
{
    if ([CPUIModelManagement sharedInstance].sysOnlineStatus == SYS_STATUS_ONLINE) {
    NSMutableArray *memberArr = [self.groupMembers objectForKey:[NSString stringWithFormat:@"%d",[HomeInfo shareObject].deleteViewTag/10]];
    CPUIModelMessageGroupMember *member = [memberArr objectAtIndex:[HomeInfo shareObject].deleteViewTag%10];
        if ([self.groupProfileDelegate respondsToSelector:@selector(deleteGroupMember:andMemberArr:)]) {
            [self.groupProfileDelegate deleteGroupMember:self.modelMessageGroup andMemberArr:[NSArray arrayWithObject:member]];
        }
    //[[CPUIModelManagement sharedInstance] removeGroupMemWithUserNames:[NSArray arrayWithObject:member] andGroup:self.modelMessageGroup];

        }
}

@end
@implementation GroupProfileTableView
@synthesize groupProfileTableViewDelegate = _groupProfileTableViewDelegate;


-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        
    }
    return self;
}


@end

@implementation GroupProfileScrollView
@synthesize groupProfileScrollDelegate = _groupProfileTableViewDelegate;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    if ([self.groupProfileScrollDelegate respondsToSelector:@selector(touchInScrollView)]) {
        [self.groupProfileScrollDelegate touchInScrollView];
    }
}
@end