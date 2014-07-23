//
//  CPXmppEngine.m
//  Couple
//
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>

#import "Reachability.h"

#import "CPXmppEngineConst.h"
#import "CPXmppEngine.h"
#import "CPXmppEngineTransactionContext.h"
#import "CPXmppEngineObserver.h"

#import "XMPPMessage+SYS.h"
#import "XMPPSystemMessage.h"
#import "XMPPUserMessage.h"
#import "XMPPGroupMessage.h"
#import "XMPPNoticeMessage.h"

#import "XMPPMessage+XEP0045.h"

#import "XMPPMessage+GMC.h"
#import "XMPPGroupMemberChangeMessage.h"

#import "HPTopTipView.h"
#import "PalmUIManagement.h"

@interface CPXmppEngine(/*Private Methods*/)
{
    __strong XMPPStream *xmppStream;
    __strong XMPPReconnect *xmppReconnect;
    
    BOOL isXmppConnected;
    int state;
    
    BOOL shouldAutoRec;
    BOOL shouldNotifyStateChange;
}

@property (strong, nonatomic) Reachability *reachability;

@property (nonatomic, readonly) XMPPStream *xmppStream;
@property (nonatomic, readonly) XMPPReconnect *xmppReconnect;
@property (strong, nonatomic) NSString *jid;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSMutableDictionary *contextDict;

@property (strong, nonatomic) NSMutableArray *observerArray;

- (void)setupStream;
- (void)teardownStream;

- (void)goOnline;
- (void)goOffline;

- (void)notifyStateChanged:(NSInteger)curState;

- (void)sendFeedbackMessageWithMessage:(XMPPMessage *)message;

@end

static int haha;

@implementation CPXmppEngine

@synthesize reachability = _reachability;

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize jid = _jid;
@synthesize password = _password;
@synthesize contextDict = _contextDict;

@synthesize observerArray = _observerArray;

- (id) init
{    
    if((self = [super init]))
    {
        self.observerArray = [[NSMutableArray alloc] init];
        self.contextDict = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification 
                                                   object:nil];
        
        self.reachability = [Reachability reachabilityForInternetConnection];
//        self.reachability = [Reachability reachabilityWithHostname:@"chat1.fanxer.com"];
        [self.reachability startNotifier];
        
        state = STATE_XMPPENGINE_DISCONNECTED;
        
        isXmppConnected = NO;
        shouldAutoRec = YES;
        shouldNotifyStateChange = YES;
    }
    
    return self;
}

- (void)dealloc
{    
    shouldAutoRec = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
	[self teardownStream];
}

//
- (void) addObserver:(id<CPXmppEngineObserver>) observer;
{
    if( [self.observerArray containsObject:observer] == NO )
    {
        [self.observerArray addObject:observer];
    }
}

- (void) removeObserver:(id<CPXmppEngineObserver>) observer;
{
    if( [self.observerArray containsObject:observer] == YES )
    {
        [self.observerArray removeObject:observer];
    }
}

#pragma mark -
#pragma mark Reachability related

-(void) reachabilityChanged:(NSNotification*) notification
{
    if([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        CPLogInfo(@"ReachableViaWiFi");
        CPLogInfo(@"Tring to connect to server...");
        [self.xmppReconnect manualStart];
    }
    else if([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        CPLogInfo(@"ReachableViaWWAN");
        CPLogInfo(@"Tring to connect to server...");
        [self.xmppReconnect manualStart];
    }
    else if([self.reachability currentReachabilityStatus] == NotReachable)
    {
        CPLogInfo(@"NotReachable");
        CPLogInfo(@"Tring to disconnect...");
        //[self disconnect];
    }   
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    xmppStream = [[XMPPStream alloc] init];
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Activate xmpp modules
    [xmppReconnect activate:xmppStream];
    
    //add delegate.
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
//warning !!!!!!!!!!!!!!
//#ifndef PM_TEST
#if !defined(PM_TEST) && !defined (WWAN_TEST)
    [xmppStream setHostName:@"192.168.50.0"];
#endif
    [xmppStream setHostName:@"124.95.168.71"];
    [xmppStream setHostPort:5222];
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppReconnect removeDelegate:self];
    
	[xmppReconnect deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
}

- (BOOL)isDisconnected
{
    return [self.xmppStream isDisconnected];
}

- (BOOL)isConnected
{
    return [self.xmppStream isConnected];
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connectWithJID:(NSString *)JID Password:(NSString *)password
{
    CPLogInfo(@"");

    //attention???
    [xmppStream setHostName:[PalmUIManagement sharedInstance].imServerIP];
    if (![xmppStream isDisconnected])
    {
		return YES;
	}

    shouldAutoRec = YES;
    shouldNotifyStateChange = YES;
    isXmppConnected = NO;
    state = STATE_XMPPENGINE_DISCONNECTED;
    
//	if (![xmppStream isDisconnected])
//    {
//		return YES;
//	}
    
    if( JID == nil || password == nil/*self.userName == nil || self.password == nil*/ )
    {
        return NO;
    }
    
    self.jid = JID;
    self.password = password;
    
    CPLogInfo(@"jid:%@\n", self.jid);
    CPLogInfo(@"password:%@\n", self.password);
    
    [xmppStream setMyJID:[XMPPJID jidWithString:self.jid]];
    
	NSError *error = nil;
	if (![xmppStream connect:&error])
	{
//        [[HPTopTipView shareInstance] showMessage:@"Error connecting"];  
        
//		DDLogError(@"Error connecting: %@", error);
        CPLogError(@"Error connecting:%@\n", error);

		return NO;
	}
    
    state = STATE_XMPPENGINE_CONNECTING;
    
    xmppReconnect.autoReconnect = YES;
    
	return YES;
}

- (void)disconnect
{
    shouldAutoRec = NO;
    shouldNotifyStateChange = NO;
    
    [xmppReconnect stop];
    xmppReconnect.autoReconnect = NO;

    isXmppConnected = NO;
    state = STATE_XMPPENGINE_DISCONNECTED;
    
    if(/*isXmppConnected*/state == STATE_XMPPENGINE_CONNECTED/*[xmppStream isConnected]*/)
    {
        [self goOffline];
    }
    
    [xmppStream disconnect];
}

- (void)notifyStateChanged:(NSInteger)curState
{
    if( NO == shouldNotifyStateChange )
    {
        return;
    }
    
    for(id<CPXmppEngineObserver> obs in self.observerArray)
    {
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
            && [obs respondsToSelector:@selector(XmppEngineStatusChanged:)] )
        {
            [obs XmppEngineStatusChanged:curState];
        }
    }
}

- (void)notifySystemMessageReceived:(XMPPSystemMessage *)sysMsg
{
    for(id<CPXmppEngineObserver> obs in self.observerArray)
    {
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
           && [obs respondsToSelector:@selector(handleSystemMessageReceived:)] )
        {
            [obs handleSystemMessageReceived:sysMsg];
        }
    }
}

- (void)notifyUserMessageReceived:(XMPPUserMessage *)userMessage
{
    for(id<CPXmppEngineObserver> obs in self.observerArray)
    {
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
           && [obs respondsToSelector:@selector(handleUserMessageReceived:)] )
        {
            CPLogInfo(@"handleUserMessageReceived messagecontent: %@",userMessage.message);
            [obs handleUserMessageReceived:userMessage];
        }
    }
}

//2014-7
-(void) notifyNoticeMessageReceived:(XMPPNoticeMessage *)noticeMessage{
    for(id<CPXmppEngineObserver> obs in self.observerArray){
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
           && [obs respondsToSelector:@selector(handleNoticeMessageReceived:)] ){
            [obs handleNoticeMessageReceived:noticeMessage];
        }
    }
}

- (void)notifyGroupMessageReceived:(XMPPGroupMessage *)groupMessage
{
    for(id<CPXmppEngineObserver> obs in self.observerArray)
    {
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
           && [obs respondsToSelector:@selector(handleGroupMessageReceived:)] )
        {
            CPLogInfo(@"-3- %@",groupMessage);
            [obs handleGroupMessageReceived:groupMessage];
        }
    }
}

- (void)notifyGMCMessageReceived:(XMPPGroupMemberChangeMessage *)gmcMessage
{
    for(id<CPXmppEngineObserver> obs in self.observerArray)
    {
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
           && [obs respondsToSelector:@selector(handleGroupMemberChangeMessageReceived:)] )
        {
            [obs handleGroupMemberChangeMessageReceived:gmcMessage];
        }
    }
}

- (void)notifyMessageStatus:(NSNumber *)msgId changedTo:(NSNumber *)status
{
    for(id<CPXmppEngineObserver> obs in self.observerArray)
    {
        if( [obs conformsToProtocol:@protocol(CPXmppEngineObserver)]
           && [obs respondsToSelector:@selector(xmppEngineMessageSendingStatusOf:changedTo:)] )
        {
            [obs xmppEngineMessageSendingStatusOf:msgId changedTo:status];
        }
    }
}
- (void)sendFeedbackMessageWithMessage:(XMPPMessage *)message
{
    //    if( STATE_XMPPENGINE_CONNECTED != state)
    if( ![xmppStream isConnected] )
    {
        //temp++
        //        if( STATE_XMPPENGINE_DISCONNECTED == state )
        if( [xmppStream isDisconnected] )
        {
            if( self.jid != nil && self.password != nil )
            {
                //???
                //                state = STATE_XMPPENGINE_CONNECTING;
                [xmppReconnect manualStart];
            }
        }
        //temp--
        
        return;
    }
    NSLog(@"===FEEDBACK==to:%@",[message from] );
    XMPPMessage *newMessage = [XMPPMessage message];
    [newMessage addAttributeWithName:@"from" stringValue:[[message to] bare]];
    [newMessage addAttributeWithName:@"to" stringValue:[[message from] bare]];
    [newMessage addAttributeWithName:@"subType" stringValue:@"ack"];
    [newMessage addAttributeWithName:@"id" stringValue:[[[NSNumberFormatter alloc]init] stringFromNumber:[CoreUtils getLongFormatWithNowDate]]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[message attributeStringValueForName:@"id"] forKey:@"id"];
    NSString * toJson = [dict JSONString];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:toJson];
    
    [newMessage addChild:body];
    [xmppStream sendElement:newMessage];
}

- (void)handleUserMessage:(XMPPMessage *)message
{
    XMPPUserMessage *userMessage = [XMPPUserMessage fromXMLElement:message];
    
    if(userMessage)
    {
        CPLogInfo(@"notifyUserMessageReceived message.body.stringvalue: %@",[[message elementForName:@"body"] stringValue]);
        [self notifyUserMessageReceived:userMessage];
    }
    
#ifdef SEND_FEEDBACK
    [self sendFeedbackMessageWithMessage:message];
#endif
}

- (void)handleGroupMessage:(XMPPMessage *)message
{
    XMPPGroupMessage *groupMessage = [XMPPGroupMessage fromXMLElement:message];
    
    if(groupMessage)
    {
        CPLogInfo(@"-2- %@",message);
        [self notifyGroupMessageReceived:groupMessage];
    }
}

- (void)handleGMCMessage:(XMPPMessage *)message
{
    XMPPGroupMemberChangeMessage *gmcMessage = [XMPPGroupMemberChangeMessage fromXMLElement:message];
    
    if(gmcMessage)
    {
        [self notifyGMCMessageReceived:gmcMessage];
    }
}

- (void)handleSystemMessage:(XMPPMessage *)message
{
    XMPPSystemMessage *systemMessage = [XMPPSystemMessage fromXMLElement:message];
    
    if(systemMessage)
    {
        [self notifySystemMessageReceived:systemMessage];
    }
}

// 2014-7
-(void) handleNoticeMessage : (XMPPMessage *)message{
    XMPPNoticeMessage *noticeMessage = [XMPPNoticeMessage fromXMLElement:message];
    if (noticeMessage) {
        [self notifyNoticeMessageReceived:noticeMessage];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Message
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)sendInstantMessage:(id)msg
{        
    XMPPUserMessage *userMsg = (XMPPUserMessage *)msg;
    
//    if( STATE_XMPPENGINE_CONNECTED != state)
    if( ![xmppStream isConnected] )
    {
        [self notifyMessageStatus:userMsg.messageID changedTo:[NSNumber numberWithInt:MESSAGE_SENDING_STATE_SEND_FAILED]];
        
        //temp++
//        if( STATE_XMPPENGINE_DISCONNECTED == state )
        if( [xmppStream isDisconnected] )
        {
            if( self.jid != nil && self.password != nil )
            {
                //???
//                state = STATE_XMPPENGINE_CONNECTING;
                [xmppReconnect manualStart];
            }
        }   
        //temp--
        
        return;
    }
    
    XMPPMessage *message = [XMPPMessage message];
    [message addAttributeWithName:@"from" stringValue:/*userMsg.from*/[[XMPPJID jidWithString:userMsg.from] bare]];
    [message addAttributeWithName:@"to" stringValue:/*userMsg.to*/[[XMPPJID jidWithString:userMsg.to] bare]];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"id" stringValue:[xmppStream generateUUID]];
    
    if(userMsg.getXMPPSubType)
    {
        [message addAttributeWithName:@"subType" stringValue:userMsg.getXMPPSubType];
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:userMsg.encodeBody];
    [message addChild:body];
    
    [self.contextDict setObject:userMsg.messageID forKey:[message elementID]];
    
    [xmppStream sendElement:message];
}

- (void)sendGroupMessage:(id)groupMsg
{
    XMPPGroupMessage *gMsg = (XMPPGroupMessage *)groupMsg;
    
//    if( STATE_XMPPENGINE_CONNECTED != state)
    if( ![xmppStream isConnected] )
    {
        [self notifyMessageStatus:gMsg.messageID changedTo:[NSNumber numberWithInt:MESSAGE_SENDING_STATE_SEND_FAILED]];
        
        //temp++
//        if( STATE_XMPPENGINE_DISCONNECTED == state )
        if( [xmppStream isDisconnected] )
        {
            if( self.jid != nil && self.password != nil )
            {
                //???
//                state = STATE_XMPPENGINE_CONNECTING;
                [xmppReconnect manualStart];
            }
        }   
        //temp--

        return;
    }
    
    XMPPMessage *message = [XMPPMessage message];
    [message addAttributeWithName:@"from" stringValue:/*userMsg.from*/[[XMPPJID jidWithString:gMsg.from] bare]];
    [message addAttributeWithName:@"to" stringValue:/*userMsg.to*/[[XMPPJID jidWithString:gMsg.to] bare]];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    [message addAttributeWithName:@"id" stringValue:[xmppStream generateUUID]];
    
    if(gMsg.getXMPPSubType)
    {
        [message addAttributeWithName:@"subType" stringValue:gMsg.getXMPPSubType];
    }
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:gMsg.encodeBody];
    [message addChild:body];
    
    //ctx++
    [self.contextDict setObject:gMsg.messageID forKey:[message elementID]];
    //ctx--
    
    [xmppStream sendElement:message];
}

- (void)manualReconnect{
    [xmppReconnect manualStart];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method is called before the stream begins the connection process.
 *
 * If developing an iOS app that runs in the background, this may be a good place to indicate
 * that this is a task that needs to continue running in the background.
 **/
- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    CPLogInfo(@"");

    state = STATE_XMPPENGINE_CONNECTING;
    
    [self notifyStateChanged:state];
}

/**
 * This method is called after the tcp socket has connected to the remote host.
 * It may be used as a hook for various things, such as updating the UI or extracting the server's IP address.
 * 
 * If developing an iOS app that runs in the background,
 * please use XMPPStream's enableBackgroundingOnSocket property as opposed to doing it directly on the socket here.
 **/
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket 
{
    CPLogInfo(@"");
    
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    state = STATE_XMPPENGINE_SOCKET_CONNECTED;
    
    [self notifyStateChanged:state];
}

/**
 * This method is called after the XML stream has been fully opened.
 * More precisely, this method is called after an opening <xml/> and <stream:stream/> tag have been sent and received,
 * and after the stream features have been received, and any required features have been fullfilled.
 * At this point it's safe to begin communication with the server.
 **/
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    CPLogInfo(@"");
	
	isXmppConnected = YES;
    state = STATE_XMPPENGINE_STREAM_CONNECTED;
    
    [self notifyStateChanged:state];
    
	NSError *error = nil;
	
	if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
	{
//		DDLogError(@"Error authenticating: %@", error);
        CPLogError(@"Error authenticating: %@", error);
	}
    
    state = STATE_XMPPENGINE_AUTHING;
    
    [self notifyStateChanged:state];
}

/**
 * This method is called after registration of a new user has successfully finished.
 * If registration fails for some reason, the xmppStream:didNotRegister: method will be called instead.
 **/
//- (void)xmppStreamDidRegister:(XMPPStream *)sender;

/**
 * This method is called if registration fails.
 **/
//- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error;

/**
 * This method is called after authentication has successfully finished.
 * If authentication fails for some reason, the xmppStream:didNotAuthenticate: method will be called instead.
 **/
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    CPLogInfo(@"");
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    shouldNotifyStateChange = YES;
    
    state = STATE_XMPPENGINE_AUTHENTICATED;
	
	[self goOnline];
    
    [self notifyStateChanged:state];
    
    state = STATE_XMPPENGINE_CONNECTED;
    
    [self notifyStateChanged:state];
    
    shouldAutoRec = YES;
    
    //test only ++
//    [[HPTopTipView shareInstance] showMessage:[NSString stringWithFormat:@"%@\n%@", [[XMPPJID jidWithString:self.jid] user], @"^Connected^" ]];  
    //test only --
}

/**
 * This method is called if authentication fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    CPLogInfo(@"");
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    CPLogInfo(@"%@\n", error);
    
    shouldAutoRec = NO;
    shouldNotifyStateChange = YES;
    xmppReconnect.autoReconnect = NO;
    [xmppReconnect stop];
    
    //temp++
//    [[HPTopTipView shareInstance] showMessage:[NSString stringWithFormat:@"%@\n%@",[[XMPPJID jidWithString:self.jid] user],@"^Auth Failed^"]];
    //temp--
    
//warning state......
    state = STATE_XMPPENGINE_AUTHFAILED;
    
    [self notifyStateChanged:state];
    
//warning do we need to disconnected to server? which bebaviour was expected?
}

/**
 * This method is called if the disconnect method is called.
 * It may be used to determine if a disconnection was purposeful, or due to an error.
 **/
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    CPLogInfo(@"");
    
    state = STATE_XMPPENGINE_DISCONNECTING;
    
    [self notifyStateChanged:state];
}

/**
 * This method is called after the stream is closed.
 * 
 * The given error parameter will be non-nil if the error was due to something outside the general xmpp realm.
 * Some examples:
 * - The TCP socket was unexpectedly disconnected.
 * - The SRV resolution of the domain failed.
 * - Error parsing xml sent from server. 
 **/
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    CPLogInfo(@"");
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
	
	if (!isXmppConnected)
	{
        //		DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        CPLogError(@"Unable to connect to server. Check xmppStream.hostName");
	}
    
    isXmppConnected = NO;
    
    //temp++
    if(error)
    {
        CPLogInfo(@"error:%@\n", error);
//        [[HPTopTipView shareInstance] showMessage:[NSString stringWithFormat:@"%@\n%@", @"Disconnected", @"With Err!"]];  
    }
    //temp--
    
    state = STATE_XMPPENGINE_DISCONNECTED;
    
    if( NO == shouldAutoRec )
    {
        [self notifyStateChanged:state];
    }
}

/**
 * These methods are called after their respective XML elements are received on the stream.
 * 
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 **/
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    CPLogInfo(@"");
    //	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [iq elementID]);
	
	return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    CPLogInfo(@"");
    
	if ([message isChatMessageWithBody])//if([message isChatMessage])
	{
        CPLogInfo(@"isChatMessageWithBody message.body: %@",[[message elementForName:@"body"] stringValue]);
        [self handleUserMessage:message];
	}
    else if([message isGroupChatMessageWithBody])
    {
        [self handleGroupMessage:message];
    }
    else if([message isGMCMessageWithBody])
    {
        [self handleGMCMessage:message];
    }
    else if([message isSystemMessageWithBody])//if([message isSystemMessage])
    {
        [self handleSystemMessage:message];
    }else if ([[[message attributeForName:@"type"] stringValue] isEqualToString:@"normal"] &&
              [[[message attributeForName:@"subType"] stringValue] isEqualToString:@"sys_direct"]){
        // 2014-7
        [self handleNoticeMessage:message];
    }
    
    else 
    {
        CPLogInfo(@"-1- %@",message);
        //如果不在所列的subtype类型中，则视为系统消息中的升级消息
//        [self handleSystemMessage:message];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    CPLogInfo(@"");
    //	DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

/**
 * This method is called if an XMPP error is received.
 * In other words, a <stream:error/>.
 * 
 * However, this method may also be called for any unrecognized xml stanzas.
 * 
 * Note that standard errors (<iq type='error'/> for example) are delivered normally,
 * via the other didReceive...: methods.
 **/
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    CPLogInfo(@"");
    //	DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

/**
 * These methods are called before their respective XML elements are sent over the stream.
 * These methods can be used to customize elements on the fly.
 * (E.g. add standard information for custom protocols.)
 **/
- (void)xmppStream:(XMPPStream *)sender willSendIQ:(XMPPIQ *)iq
{
    CPLogInfo(@"");
}

- (void)xmppStream:(XMPPStream *)sender willSendMessage:(XMPPMessage *)message
{
    CPLogInfo(@"");
    
#if 0
    NSString *elementID = [message elementID];
    
    if(elementID)
    {
//        CPXmppEngineTransactionContext * ctx = [[self contextDict] objectForKey:elementID];
        NSNumber *srcID = [[self contextDict] objectForKey:elementID];
        if(srcID)
        {
            [[self contextDict] removeObjectForKey:elementID];
        }
    }
#endif
}

- (void)xmppStream:(XMPPStream *)sender willSendPresence:(XMPPPresence *)presence
{
    CPLogInfo(@"");
}

/**
 * These methods are called after their respective XML elements are sent over the stream.
 * These methods may be used to listen for certain events (such as an unavailable presence having been sent),
 * or for general logging purposes. (E.g. a central history logging mechanism).
 **/
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    CPLogInfo(@"");
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    CPLogInfo(@"");
    
    NSString *elementID = [message elementID];
    
    if(elementID)
    {
        NSNumber *srcID = [[self contextDict] objectForKey:elementID];
        if(srcID)
        {
            [self notifyMessageStatus:srcID changedTo:[NSNumber numberWithInt:MESSAGE_SENDING_STATE_SEND_SUCCESSFUL]];
            
            [self.contextDict removeObjectForKey:[message elementID]];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    CPLogInfo(@"");
}

/**
 * These methods are called as xmpp modules are registered and unregistered with the stream.
 * This generally corresponds to xmpp modules being initailzed and deallocated.
 * 
 * The methods may be useful, for example, if a more precise auto delegation mechanism is needed
 * than what is available with the autoAddDelegate:toModulesOfClass: method.
 **/
- (void)xmppStream:(XMPPStream *)sender didRegisterModule:(id)module
{
    CPLogInfo(@"");
}

- (void)xmppStream:(XMPPStream *)sender willUnregisterModule:(id)module
{
    CPLogInfo(@"");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPReconnect Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * This method may be used to fine tune when we
 * should and should not attempt an auto reconnect.
 * 
 * For example, if on the iPhone, one may want to prevent auto reconnect when WiFi is not available.
 **/
#if MAC_OS_X_VERSION_MIN_REQUIRED <= MAC_OS_X_VERSION_10_5

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags
{
    CPLogInfo(@"");
    
//warning need more attention!
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags
{
    CPLogInfo(@"");
    
//warning auto reconnect!
    
    haha++;
    
    return YES;
    
    if( ([self.reachability currentReachabilityStatus] == ReachableViaWiFi || [self.reachability currentReachabilityStatus] == ReachableViaWWAN )
        && shouldAutoRec
        /*&& (haha <= 3)*/ )
    {
        [self notifyStateChanged:STATE_XMPPENGINE_RECONNECTING];
        
        return YES;
    }
    else
    {
        haha = 0;
        shouldAutoRec = NO;
        
//warning !!!!!!!!!!!!!
        //TODO:
        //notif xmpp disconnected!
        [self notifyStateChanged:STATE_XMPPENGINE_DISCONNECTED];
        
        return NO;
    }
}

#else

- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    CPLogInfo(@"");
    
#warning need more attention!
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    CPLogInfo(@"");
    
#warning auto reconnect!
    return YES;
}

#endif

@end
