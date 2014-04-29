//
//  AlarmClockHelper.m
//  iCouple
//
//  Created by wang shuo on 12-8-14.
//
//

#import "AlarmClockHelper.h"
#import "CPUIModelMessage.h"
#import "CPUIModelManagement.h"
#import "CPLGModelAccount.h"

@interface AlarmClockHelper (private)

// 初始化闹钟数据
-(void) initAlarmClockData;

// 添加一个本地通知
-(BOOL) addLocalNotification : (AlarmObject *) alarm;
// 移除一个闹钟
-(void) removeLocalNotification : (NSString *) msgID;
// 时钟到时，沉淀提醒消息
-(void) sendAlarmMessage : (NSTimer *) time;
@end

@implementation AlarmClockHelper
//@synthesize alarmClock = _alarmClock;

static AlarmClockHelper *helper = nil;
static NSString *docmentPath = nil;
// 闹钟数据
static NSMutableDictionary *alarmClock;
// 程序内提醒NSTimer
//static NSTimer *alarmTime = nil;

+(AlarmClockHelper *) sharedInstance{
    if ( nil == helper ) {
        helper = [[AlarmClockHelper alloc] init];
    }
    return helper;
}

-(id) init{
    self = [super init];
    
    if (self) {
//        CPLGModelAccount *account = [[CPUIModelManagement sharedInstance] getCurrentAccountModel];
        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        docmentPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/AlarmClock.plist" , account.loginName]];
//        
////        NSLog(@"%@",docmentPath);
//        
//        NSMutableDictionary* dictRank = nil;
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        //文件不存在则创建文件
//        if(![fileManager fileExistsAtPath:docmentPath]) {
//            dictRank = [[NSMutableDictionary alloc] init];
//            [dictRank writeToFile:docmentPath atomically:YES];
////            alarmClock = dictRank;
////            [self performSelector:@selector(reloadData) withObject:nil afterDelay:1000];
//            [self reloadData];
////            [alarmClock writeToFile:docmentPath atomically:YES];
//        }else{
//            [self reloadData];
//        }
    }
    
    return self;
}

-(void) changeUser{
    helper = nil;
}

// 重新加载闹钟数据
-(void) reloadData{
    
    CPLGModelAccount *account = [[CPUIModelManagement sharedInstance] getCurrentAccountModel];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    docmentPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/AlarmClock.plist" , account.loginName]];
    NSMutableDictionary* dictRank = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"%@",docmentPath);
    if(![fileManager fileExistsAtPath:docmentPath]) {
        dictRank = [[NSMutableDictionary alloc] init];
        [dictRank writeToFile:docmentPath atomically:YES];
    }
    
    alarmClock = nil;
    alarmClock = [[NSMutableDictionary alloc] initWithContentsOfFile:docmentPath];
    
    // 如果闹钟数量大于100 删除过期的闹钟
    if ([alarmClock count] > 100) {
        [self analysisAlarmData];
    }
}

// 获得闹钟的详细信息
-(AlarmObject *)getAlarm:(NSString *)msgID{
    NSDictionary *alarmData = [alarmClock objectForKey:msgID];
    
    if (nil == alarmData) {
        return nil;
    }
    
    AlarmObject *alarmObject = [[AlarmObject alloc] init];
    
    alarmObject.msgID = msgID;
    alarmObject.alarmTime = (NSDate *)[alarmData objectForKey:@"AlarmTime"];
    alarmObject.state = (NSNumber *)[alarmData objectForKey:@"State"];
    alarmObject.groupID = (NSNumber *)[alarmData objectForKey:@"GroupID"];
    alarmObject.userNickName = (NSString *)[alarmData objectForKey:@"UserNickName"];
    alarmObject.alarmClockType = (NSNumber *)[alarmData objectForKey:@"AlarmClockType"];
    alarmObject.msgText = (NSString *)[alarmData objectForKey:@"MsgText"];
    return alarmObject;
}

// 添加一个新的闹钟到plist文件内
-(BOOL) addAlarmClockObject:(AlarmObject *)object{
    
    NSMutableDictionary *alarm = [[NSMutableDictionary alloc] init];
    [alarm setObject:object.alarmTime forKey:@"AlarmTime"];
    [alarm setObject:object.state forKey:@"State"];
    [alarm setObject:object.groupID forKey:@"GroupID"];
    [alarm setObject:object.userNickName forKey:@"UserNickName"];
    [alarm setObject:object.alarmClockType forKey:@"AlarmClockType"];
    if ( nil == object.msgText) {
        [alarm setObject:@"" forKey:@"MsgText"];
    }else{
        [alarm setObject:object.msgText forKey:@"MsgText"];
    }
    [alarmClock setObject:alarm forKey:object.msgID];
    
    if ([alarmClock writeToFile:docmentPath atomically:YES]) {
        if ([self addLocalNotification:object]) {
            [self reloadData];
            return YES;
        }else{
            [self removeAlarmClockObject:object.msgID];
            return NO;
        }
    }else{
        return NO;
    }
}

// 添加一个本地通知
-(BOOL) addLocalNotification:(AlarmObject *)alarm{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    NSString *date = [dateFormatter stringFromDate:alarm.alarmTime];
    
    
    localNotification.fireDate = [dateFormatter dateFromString:date];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    if ([alarm.alarmClockType intValue] == TextAlarmClock) {
        localNotification.alertBody = [NSString stringWithFormat:@"来自%@的有爱提醒：%@",alarm.userNickName,alarm.msgText];
    }else if([alarm.alarmClockType intValue] == SoundAlarmClock){
        localNotification.alertBody = [NSString stringWithFormat:@"%@托小双捎来了1个有爱的提醒给你哦",alarm.userNickName];
    }else if ([alarm.alarmClockType intValue] == MysticalSoundAlarm){
        localNotification.alertBody = [NSString stringWithFormat:@"%@托小双捎来了1个有爱的提醒给你哦",alarm.userNickName];
    }
//    localNotification.applicationIconBadgeNumber = localNotification.applicationIconBadgeNumber + 1;
    localNotification.alertAction = @"查看";
//    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.soundName = @"AlarmRing.caf";
    localNotification.userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:alarm.msgID,@"msgID",nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    for (UILocalNotification *local in [UIApplication sharedApplication].scheduledLocalNotifications) {
        NSLog(@"%@",local);
    }
    
    return YES;
}

// 从plist内删除一个闹钟信息
-(BOOL) removeAlarmClockObject:(NSString *)msgID{
    NSDictionary *alarmData = [alarmClock objectForKey:msgID];
    if (nil == alarmData) {
        return YES;
    }
    
    [self removeLocalNotification:msgID];
    
    [alarmClock removeObjectForKey:msgID];
    return [alarmClock writeToFile:docmentPath atomically:YES];
}

// 移除一个闹钟
-(void) removeLocalNotification : (NSString *) msgID{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications ) {
        if( [[notification.userInfo objectForKey:@"msgID"] isEqualToString:msgID] ) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            break;
        }
    }
}

// 移除一组闹钟
-(void) removeAlarmClockObjectWithGroupID:(NSNumber *)groupID{
    BOOL isUpdate = NO;
    NSDictionary *alarmData = nil;
    NSEnumerator * enumeratorKey = [alarmClock keyEnumerator];
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:10];
    for (NSObject *key in enumeratorKey) {
        alarmData = (NSDictionary *)[alarmClock objectForKey:key];
        if ( nil == alarmData ) {
            continue;
        }
        
        NSNumber *state = (NSNumber *)[alarmData objectForKey:@"State"];
        if ([state intValue] == Finish) {
            continue;
        }
    
        NSNumber *alarmGroupID = (NSNumber *)[alarmData objectForKey:@"GroupID"];
        if ([alarmGroupID longLongValue] == [groupID longLongValue]) {
            isUpdate = YES;
            [self removeLocalNotification:(NSString *)key];
//            [alarmClock removeObjectForKey:(NSString *)key];
            [keys addObject:key];
        }
    }
    
    if (isUpdate) {
        for (NSString *key in keys) {
            [alarmClock removeObjectForKey:(NSString *)key];
        }
    }
    
    if(isUpdate){
        [alarmClock writeToFile:docmentPath atomically:YES];
    }
}

// 每次系统启动时，分析闹钟是否已完成,如果完成，则沉淀一条消息
-(void) analysisAlarmed{
    NSDictionary *alarmData = nil;
    NSDate *date = [NSDate date];
    NSTimeInterval second = [date timeIntervalSince1970];
        
    NSEnumerator * enumeratorKey = [alarmClock keyEnumerator];
    BOOL isUpdate = NO;
    for (NSObject *key in enumeratorKey) {
        alarmData = (NSDictionary *)[alarmClock objectForKey:key];
        
        if ( nil == alarmData ) {
            continue;
        }
        
        NSDate *tempDate = (NSDate *)[alarmData objectForKey:@"AlarmTime"];
        NSTimeInterval tempSec = [tempDate timeIntervalSince1970];
        NSNumber *state = (NSNumber *)[alarmData objectForKey:@"State"];
        NSNumber *alarmType = (NSNumber *)[alarmData objectForKey:@"AlarmClockType"];
        
        if (nil != state && [state intValue] != Finish && second >= tempSec) {
            
            if ([alarmType integerValue] == TextAlarmClock) {
                isUpdate = YES;
                [alarmData setValue:[NSNumber numberWithInt:Finish] forKey:@"State"];
                
                CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
                [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARMED_TEXT]];
                [message setMsgText:(NSString *)[alarmData objectForKey:@"MsgText"]];
                NSNumber *dateNumber = [NSNumber numberWithLongLong:tempSec * 1000];
                [message setAlarmTime: dateNumber];
                NSNumber *groupID = (NSNumber *)[alarmData objectForKey:@"GroupID"];
                [[CPUIModelManagement sharedInstance] sendMsgWithGroupID:groupID andMsg:message];
            }else{
                isUpdate = YES;
                [alarmData setValue:[NSNumber numberWithInt:Finish] forKey:@"State"];
                
                CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
                [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARMED_AUDIO]];
                NSNumber *dateNumber = [NSNumber numberWithLongLong:tempSec * 1000];
                [message setAlarmTime: dateNumber];
                NSNumber *groupID = (NSNumber *)[alarmData objectForKey:@"GroupID"];
                message.linkMsgID = (NSNumber *)key;
                [[CPUIModelManagement sharedInstance] sendMsgWithGroupID:groupID andMsg:message];
            }
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSLog(@"闹钟时间------------%@",[dateFormatter stringFromDate:tempDate]);
            NSLog(@"当前时间------------%@",[dateFormatter stringFromDate:date]);
        }
    }
    
    if (isUpdate) {
        [alarmClock writeToFile:docmentPath atomically:YES];
        [self reloadData];
    }
}

// 重新整理闹钟文件，删除过期闹钟
-(void) analysisAlarmData{
    NSDictionary *alarmData = nil;
    for (NSDictionary *alarm in alarmClock) {
        alarmData = (NSDictionary *)[[alarm allValues] objectAtIndex:0];
        
        NSNumber *state = (NSNumber *)[alarm objectForKey:@"State"];
        if (nil != state && [state intValue] == Finish) {
            [self removeAlarmClockObject:(NSString *)[[alarm allKeys] objectAtIndex:0]];
        }
    }
}

// 用户在应用内不使用本地通知机制，开始程序监听
-(void) beginTimeAlarm{
//    NSDictionary *alarmData = nil;
//    NSDate *date = [NSDate date];
//    NSTimeInterval second = [date timeIntervalSince1970];
//    
//    NSEnumerator * enumeratorKey = [alarmClock keyEnumerator];
//    NSMutableArray *minKey = [[NSMutableArray alloc] initWithCapacity:5];
//    NSTimeInterval nearAlarm = 999999999999999.0f;
//    for (NSObject *key in enumeratorKey) {
//        alarmData = (NSDictionary *)[alarmClock objectForKey:key];
//        
//        if ( nil == alarmData ) {
//            continue;
//        }
//        
//        NSDate *tempDate = (NSDate *)[alarmData objectForKey:@"AlarmTime"];
//        NSTimeInterval tempSec = [tempDate timeIntervalSince1970];
//        NSNumber *state = (NSNumber *)[alarmData objectForKey:@"State"];
//        
//        if (nil != state && [state intValue] != Finish && tempSec > second) {
//            if (tempSec < nearAlarm) {
//                nearAlarm = tempSec;
//                [minKey removeAllObjects];
//                [minKey addObject:key];
//            }else if(tempSec == nearAlarm){
//                [minKey addObject:key];
//            }
//        }
//    }
    
//    if (nil != minKey && [minKey count] != 0) {
//        NSTimeInterval temp = nearAlarm - second;
//        alarmTime = [NSTimer scheduledTimerWithTimeInterval:temp target:self selector:@selector(sendAlarmMessage:) userInfo:minKey repeats:NO];
//    }
}

-(void) sendAlarmMessage:(NSString *)msgID{
//    NSMutableArray *keys = (NSMutableArray *)[time userInfo];
    BOOL isUpdate = NO;
//    for (NSString *key in keys) {
        AlarmObject *object = [self getAlarm:msgID];
        
        if (nil != object) {
            if ([object.alarmClockType intValue] == TextAlarmClock) {
                
                isUpdate = YES;
                NSDictionary *alarmData = (NSDictionary *)[alarmClock objectForKey:msgID];
                [alarmData setValue:[NSNumber numberWithInt:Finish] forKey:@"State"];
                
                CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
                [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARMED_TEXT]];
                [message setMsgText:object.msgText];
                NSNumber *dateNumber = [NSNumber numberWithLongLong:[object.alarmTime timeIntervalSince1970] * 1000];
                [message setAlarmTime: dateNumber];
                NSNumber *groupID = object.groupID;
                [[CPUIModelManagement sharedInstance] sendMsgWithGroupID:groupID andMsg:message];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
                [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
                
                NSString *str = [NSString stringWithFormat:@"%@\n %@发来了一个闹闹:%@",[dateFormatter stringFromDate:object.alarmTime],object.userNickName,object.msgText];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"双双" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                [alertView show];
            }else{
                isUpdate = YES;
                NSDictionary *alarmData = (NSDictionary *)[alarmClock objectForKey:msgID];
                [alarmData setValue:[NSNumber numberWithInt:Finish] forKey:@"State"];
                
                CPUIModelMessage *message = [[CPUIModelMessage alloc] init];
                [message setContentType:[NSNumber numberWithInt:MSG_CONTENT_TYPE_ALARMED_AUDIO]];
                NSNumber *dateNumber = [NSNumber numberWithLongLong:[object.alarmTime timeIntervalSince1970] * 1000];
                [message setAlarmTime: dateNumber];
                NSNumber *groupID = object.groupID;
                message.linkMsgID = (NSNumber *)object.msgID;
                [[CPUIModelManagement sharedInstance] sendMsgWithGroupID:groupID andMsg:message];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
                [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
                
                NSString *str = [NSString stringWithFormat:@"%@\n %@托小双捎来了1个有爱的提醒给你哦",[dateFormatter stringFromDate:object.alarmTime],object.userNickName];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"双双" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                [alertView show];
            }
        }
//    }
    
    if (isUpdate) {
        [alarmClock writeToFile:docmentPath atomically:YES];
//        [self reloadData];
    }
    
    for (UILocalNotification *local in [UIApplication sharedApplication].scheduledLocalNotifications) {
        NSLog(@"%@",local);
    }
//    [self endTimeAlarm];
//    [self beginTimeAlarm];
}

// 用户在应用外不使用程序监听机制，使用本地通知机制
-(void) endTimeAlarm{
//    if ( nil != alarmTime ) {
//        if ([alarmTime isValid]) {
//            [alarmTime invalidate];
//        }
//    }
}

@end
