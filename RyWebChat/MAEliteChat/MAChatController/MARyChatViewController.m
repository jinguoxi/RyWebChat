//
//  MARyChatViewController.m
//  RyWebChat
//
//  Created by nwk on 2017/2/9.MARyChatViewController.h
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MARyChatViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "EliteMessage.h"
#import "MAChat.h"
#import "MAJSONObject.h"
#import "MARequest.h"
#import "MASession.h"
#import "MAEliteChat.h"
#import "MAMessageUtils.h"
#import "MAConfig.h"
#import "MJExtension.h"
#import "MASaveMessage.h"
#import "MASatisfactionView.h"
#import "MALocationViewController.h"
#import "MALocationDetailController.h"
#import "RobotMessageCell.h"
#import "RobotMessage.h"
#import "NSString+Category.h"
#import "UnSendMessage.h"
#import "CardMessageCell.h"
#import "CardMessage.h"

@interface MARyChatViewController ()<RCIMReceiveMessageDelegate,MASatisfactionViewDelegate,MALocationDelegate, RCAttributedLabelDelegate>

@end

@implementation MARyChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.displayUserNameInCell = NO;
    NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1547114000938&di=fec250aca7835b1f8f6ad52322368707&imgtype=0&src=http%3A%2F%2Fpic.90sjimg.com%2Fdesign%2F00%2F16%2F13%2F58%2F592a709d9ef9f.png"];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:image title:@"结束服务" atIndex:3 tag:2019];
    
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    //[[RCIM sharedRCIM] setUserInfoDataSource:self];
    [[MAEliteChat shareEliteChat] sendQueueRequest];
    [self registerClass:[RobotMessageCell class] forMessageClass:[RobotMessage class]];
    [self registerClass:[CardMessageCell class] forMessageClass:[CardMessage class]];
}

//小灰色提示条
- (void)addTipsMessage:(NSString *)msg {
    RCInformationNotificationMessage *warningMsg = [RCInformationNotificationMessage
                                                    notificationWithMessage:msg extra:nil];
    
    // 如果不保存到本地数据库，需要初始化消息实体并将messageId要设置为－1。
    RCMessage *insertMessage =[[RCMessage alloc] initWithType:self.conversationType
                                                     targetId:self.targetId
                                                    direction:MessageDirection_SEND
                                                    messageId:-1
                                                      content:warningMsg];
    
    // 在当前聊天界面插入该消息
    [self appendAndDisplayMessage:insertMessage];
}

- (RCMessageContent *)willSendMessage:(RCMessageContent *)messageContent {
    if ([messageContent isKindOfClass:[RCTextMessage class]] || [messageContent isKindOfClass:[RCLocationMessage class]]) {
        RCTextMessage *textMsg = (RCTextMessage *)messageContent;
        textMsg.extra = [MAMessageUtils getTextMessageJsonStr];
        
    } else if ([messageContent isKindOfClass:[RCVoiceMessage class]]) {
        RCVoiceMessage *voiceMessage = (RCVoiceMessage *)messageContent;
        voiceMessage.extra = [MAMessageUtils getVoiceMessageJsonStr:voiceMessage.duration];
    } else if ([messageContent isKindOfClass:[RCHQVoiceMessage class]]) {
        RCHQVoiceMessage *hqVoiceMessage = (RCHQVoiceMessage *)messageContent;
        NSLog(@"%@",  hqVoiceMessage.remoteUrl);
        hqVoiceMessage.extra = [MAMessageUtils getVoiceMessageJsonStr:hqVoiceMessage.duration];
    } else if ([messageContent isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)messageContent;
        sightMsg.extra = [MAMessageUtils getTextMessageJsonStr];
        
    } else if ([messageContent isKindOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)messageContent;
        imageMessage.extra = [MAMessageUtils getTextMessageJsonStr];
        NSLog(@"localPath:%@ ", imageMessage.localPath);
        NSLog(@"imageUri:%@ ", imageMessage.imageUrl);
        NSLog(@"imageData%@ ", imageMessage.originalImageData);

    }
    
    return messageContent;
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    NSLog(@"mes]sage.content:%@",message.content);
    if ([message.content isKindOfClass:[RCInformationNotificationMessage class]]) {
        RCInformationNotificationMessage *infoMsg = (RCInformationNotificationMessage *)message.content;
        NSLog(@"---%@",infoMsg.message);
        [self parseMessage:infoMsg.message rcMsg:message];
    } else if ([message.content isKindOfClass:[EliteMessage class]]) {
        EliteMessage *eliteMsg = (EliteMessage *)message.content;
        
        NSLog(@"---%@",eliteMsg.message);
        
        [self parseMessage:eliteMsg.message rcMsg:message];
        
    }else if ([message.content isKindOfClass:[RCFileMessage class]]) {
        RCFileMessage *fileMsg = (RCFileMessage *)message.content;
        
        NSLog(@"localPath---%@",fileMsg.localPath);
        NSLog(@"extra---%@",fileMsg.extra);
        NSLog(@"name---%@",fileMsg.name);
        NSLog(@"type---%@",fileMsg.type);
    }
    
}

/**
 *  刷新用户信息，更新session
 */
- (void)refreshUserInfoSession{
    MASession *session = [[MAChat getInstance] getSession];
    NSString *icon = session.currentAgent.portraitUri;
    if (icon && ![icon isEqualToString:@""]) {
        if(! ([icon hasPrefix:@"http"] || [icon hasPrefix:@"https"])){
            MAChat *maChat = [MAChat getInstance];
            int queue = [maChat getQueueId];
            NSString *strQueue = [NSString stringWithFormat:@"%d",queue];
            MAClient * maClient = [maChat getClient];
            NSString *serverAddr = [maClient serverAddr];
            NSRange range = [serverAddr rangeOfString:@"/rcs"];//匹配得到的下标
            if(range.location > 0){
                serverAddr = [serverAddr substringToIndex:range.location];//截取范围类的字符串
            }
            icon = [[[[serverAddr stringByAppendingString:@"/ngsIcon.do?path="] stringByAppendingString:icon] stringByAppendingString: @"&queue="] stringByAppendingString:strQueue];
        }
    }
    
    session.currentAgent.portraitUri = icon;
    NSString * userId = self.targetId;
    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
    userInfo.name = session.currentAgent.name;
    userInfo.portraitUri = icon;
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:userId];
}

-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message {
    //定义一个SystemSoundID
    SystemSoundID soundID = 1307;//具体参数详情下面贴出来
    //播放声音
    AudioServicesPlaySystemSound(soundID);
    
    return YES;
}

-(void)sentRobotMessage:(NSString *)message state: (NSString *)state receivedTime:(long long)receivedTime{
    
    RCMessageContent *simpleMessgae = [RobotMessage messageWithContent:message extra:state];
    NSString *agentId =  [[[MAChat getInstance] getSession ] currentAgent].userId;
    [[RCIMClient sharedRCIMClient] insertIncomingMessage:self.conversationType targetId:self.targetId senderUserId:agentId receivedStatus:ReceivedStatus_UNREAD content:simpleMessgae sentTime:receivedTime];
    RCMessage *insertMessage =[[RCMessage alloc] initWithType:self.conversationType
                                                     targetId:self.targetId
                                                    direction:MessageDirection_RECEIVE
                                                    messageId:-1
                                                      content:simpleMessgae];
    // 在当前聊天界面插入该消息
    [self appendAndDisplayMessage:insertMessage];
    

}

/**
 *  解析消息
 *
 *  @param message 消息
 */
- (void)parseMessage:(NSString *)message rcMsg:(RCMessage *)rcMsg {
    
    MAJSONObject *json = [MAJSONObject initJSONObject:message];
    switch ([json getInt:@"type"]) {
            //机器人消息
        case ROBOT_MESSAGE_STATUS:{
            NSDictionary *robotContent = [json getObject:@"content"];
            NSString *msgType = [robotContent getString:@"type"];
            NSString *content = @"";
            long receivedTime = rcMsg.receivedTime;
            if([@"error" isEqualToString:msgType]){
                content = [robotContent getString:@"message"];
                [self sentRobotMessage:content state: @"3" receivedTime:receivedTime];
            }else if([@"text" isEqualToString:msgType]){
                if([robotContent objectForKey:@"content"]){
                    content = [robotContent getString: @"content"];
                    content=[content stringByReplacingOccurrencesOfString:@"&nbsp;"withString:@" "];
                    NSRange beginIndex = [content rangeOfString:@"<img"];
                    if(beginIndex.location > 0 && beginIndex.length > 0){
                        content = [content substringToIndex: beginIndex.location];
                    }

                    [self sentRobotMessage:content state: @"3" receivedTime:receivedTime];
                } else if([robotContent objectForKey:@"relatedQuestions"]){
                    NSArray *relatedQuestions = [robotContent getObject:@"relatedQuestions"];
                    int relatedQuestionsLength = (int)relatedQuestions.count;
                    if(relatedQuestionsLength > 0){
                        for( int i = 0; i < relatedQuestionsLength; i++){
                            NSLog(@"%i-%@", i, [relatedQuestions objectAtIndex:i]);
                            MAJSONObject *relatedQuestionsTemp = [relatedQuestions objectAtIndex:i];
                            NSString *questionTitle = [relatedQuestionsTemp getString:@"title"];
                            NSArray *relates = [relatedQuestionsTemp getObject:@"relates"];
                            int relatesLength = (int)relates.count;
                            for( int j = 0; j < relatesLength; j++){
                                MAJSONObject *relatedTemp = [relates objectAtIndex:j];
                                NSString *questionName = [relatedTemp getString:@"name"];
                                if(j != (relatesLength - 1)){
                                    content = [[content stringByAppendingString:questionName] stringByAppendingString:@"\n\n"];
                                }else {
                                    content = [content stringByAppendingString:questionName];
                                }
                                
                            }
                            content = [[questionTitle stringByAppendingString: @"\n"] stringByAppendingString:content];
                            NSLog(@"answers: %@",content);
                        }
                        
                    }
                    [self sentRobotMessage:content state: @"2" receivedTime:receivedTime];
                }
            }else if([@"command" isEqualToString:msgType]){
                NSDictionary *commandObj = [robotContent getObject: @"content"];
                if ([@"AUTO_ZRG" isEqualToString:[commandObj getString: @"code"]] || [robotContent objectForKey: @"extra"]) {
                    content = [robotContent getString: @"extra"];
                    [self sentRobotMessage:content state: @"3" receivedTime:receivedTime];
                } else if ([@"ZRG" isEqualToString:[commandObj getString: @"code"]]) {
                    content = @"【转人工】";
                    [self sentRobotMessage:content state: @"1" receivedTime:receivedTime];
                }
                
            }else {
                 [self addTipsMessage:@"消息类型暂时无法识别"];
            }
            break;
           
        }
            //转人工
        case ROBOT_TRANSFER_MESSAGE:{
            int result = [json getInt:@"result"];
            NSString *message = [json getString:@"message"];;
            if(result == MASUCCESS){
                int queueLength = [json getInt:@"queueLength"];
                if (queueLength != 0) {
                    message = [[@"当前排在第" stringByAppendingString:[NSString stringWithFormat:@"%d",queueLength]] stringByAppendingString:@"位"];
                }
            }
            [self addTipsMessage:message];
            break;
        }
            //客户发送
        case MASEND_CHAT_REQUEST: //发出聊天请求 tips 提示
        {
            NSLog(@"发出聊天请求");
            NSString *msg = [json getString:@"message"];
            if ([json getInt:@"result"] == MASUCCESS) {
                int queueLength = [json getInt:@"queueLength"];
                if (queueLength == 0) {
                    msg = [json getString:@"message"];
                } else {
                    msg = [NSString stringWithFormat:@"还有%d位，等待中...",queueLength];
                }
            } else {
                msg = [json getString:@"message"];
            }
            
            long requestId = [json getLong:@"requestId"];
            
            MARequest *request = [MARequest initWithRequestId:requestId];
            [[MAChat getInstance] setRequest:request];
            if(msg != nil && ![@"" isEqualToString:msg]){
                [self addTipsMessage:msg];
            }
            break;
        }
            
        case MACANCEL_CHAT_REQUEST: //取消聊天请求
            NSLog(@"取消聊天请求");
            
            break;
        case MACLOSE_SESSION: //结束聊天
        {
            NSLog(@"结束聊天");
            /**判断之前是否推送过满意度 如没有需要主动推送*/
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger pushSatisfactionCount = [defaults integerForKey:@"pushSatisfactionCount"];
            if(pushSatisfactionCount == nil || pushSatisfactionCount == 0){
                [self pushSatisfactionView];
            }
        }
            break;
        case MARATE_SESSION: //满意度评价
            NSLog(@"满意度评价");
            
            break;
        case MASEND_CHAT_MESSAGE: //客户端发送的消息
        {
            NSLog(@"客户端发送的消息");
            //TODO 当收到发送的消息返回session不合法时候，认为服务端会话已经关闭了，而客户端由于某些原因没能收到关闭信息
            //TODO 这时候也去清空会话，并且把原始消息缓存起来，同时发出聊天排队请求
            int result = [json getInt:@"result"];
            if(result == MAINVAILD_CHAT_SESSION_ID) {
                [[MAChat getInstance] clearRequestAndSession];
                
                NSDictionary *originalMessage = [json getObject:@"originalMessage"];
                NSString *objectName = [originalMessage getString:@"objectName"];
                NSNumber *longNumber = [NSNumber numberWithInt:ConversationType_PRIVATE];
                NSString *contervationType = [longNumber stringValue];
                if([objectName isEqual:TXT_MSG]) {
                    
                    [MASaveMessage saveMessageWithText:originalMessage :(NSString *) contervationType :(NSString *) self.targetId];
                    
                } else if ([objectName isEqual:IMG_MSG]) {
                    
                    [MASaveMessage saveMessageWithImage:originalMessage:(NSString *) contervationType :(NSString *) self.targetId];
                    
                } else if ([objectName isEqual:FILE_MSG]) {
                    
                } else if ([objectName isEqual:LBS_MSG]) {
                    
                    [MASaveMessage saveMessageWithLocation:originalMessage:(NSString *) contervationType :(NSString *) self.targetId];
                    
                } else if ([objectName isEqual:VC_MSG]) {
                    
                    [MASaveMessage saveMessageWithVoice:originalMessage:(NSString *) contervationType :(NSString *) self.targetId];
                    
                } else if([objectName isEqual:SIGHT_MSG]){
                    [MASaveMessage saveMessageWithSight:originalMessage:(NSString *) contervationType :(NSString *) self.targetId];
                } else if([objectName isEqual:HQVCMsg]){
                    [MASaveMessage saveMessageWithHQVoice:originalMessage:(NSString *) contervationType :(NSString *) self.targetId];
                }
                
                
                
                [[MAEliteChat shareEliteChat] sendQueueRequest];
            }else if([json getObject:@"sessionId"] != nil){
                long sessionId = [json getLong:@"sessionId"];
                NSArray *agents = [json getObject:@"agents"];
                NSDictionary *dic = agents.firstObject;
                MAAgent *currentAgent = [MAAgent initWithUserId:[dic getString:@"agentId"] name:[dic getString:@"agentName"] portraitUri:[dic getString:@"icon"]];
                BOOL robotMode = [json objectForKey:@"robotMode"];
                MASession *session = [MASession initWithSessionId:sessionId agent:currentAgent robotMode:robotMode];
                [[MAChat getInstance] setSession:session];
                
            }
             //[MAMessageUtils sendTxtMessage:@"txtMessage__"];
        }
            break;
        case MASEND_PRE_CHAT_MESSAGE: //发送预消息（还没排完队时候的消息）
            NSLog(@"发送预消息（还没排完队时候的消息）");
            
            break;
            
            //客户接受
        case MACHAT_REQUEST_STATUS_UPDATE://聊天排队状态更新
            NSLog(@"聊天排队状态更新");
        {
            NSDictionary *dic = [json getObject:@"data"];
            int requestStatus = [dic getInt:@"requestStatus"];
            int queueLength = [dic getInt:@"queueLength"];
            NSString *content = nil;
            if(requestStatus == MAWAITING){
                content = [NSString stringWithFormat:@"还有%d位，等待中...",queueLength];
                
            } else if (requestStatus == MADROPPED){
                content = @"请求异常丢失";
            } else if (requestStatus == MATIMEOUT){
                content = @"排队超时";
            }
            if (content) [self addTipsMessage:content];
            
        }
            break;
        case MACHAT_STARTED://通知客户端可以开始聊天
        {
            //TODO 记录本次聊天的 sessionId
            NSLog(@"通知客户端可以开始聊天");
            long sessionId = [json getLong:@"sessionId"];
            NSArray *agents = [json getObject:@"agents"];
            BOOL robotMode = [json objectForKey:@"robotMode"];
            
            NSDictionary *dic = agents.firstObject; //你好请问你那边有假酒吗
            
            MAAgent *currentAgent = [MAAgent initWithUserId:[dic getString:@"id"] name:[dic getString:@"name"] portraitUri:[dic getString:@"icon"]];
            MASession *session = [MASession initWithSessionId:sessionId agent:currentAgent robotMode:robotMode];
            [[MAChat getInstance] setSession:session];
            
            [self refreshUserInfoSession];
            
            NSString *tipsMsg = [NSString stringWithFormat:@"坐席[%@]为您服务",currentAgent.name];
            [self addTipsMessage:tipsMsg];
            
//            [MAMessageUtils sendTxtMessage:@"nihaohao"];
            //这里支持预发送图片消息
            [MAMessageUtils sendImageMessage:@"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" imageUri:@"http://rongcloud-image.ronghub.com/image_jpeg__RC-2020-06-15_4664_1592215147737.jpg?e=1607767148&token=CddrKW5AbOMQaDRwc3ReDNvo3-sL_SO1fSUBKV3H:rwcNxh83CaHFqjPRSCjz2b8vDIg="];
            [self sendUnsendMessages];
        }
            break;
        case MAAGENT_PUSH_RATING://坐席推送了满意度
        {
            NSLog(@"坐席推送了满意度");
            [self pushSatisfactionView];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:1 forKey:@"pushSatisfactionCount"];
        }
            break;
        case MAAGENT_UPDATED://坐席人员变更
        {
            NSLog(@"坐席人员变更");
            NSArray *agents = [json getObject:@"agents"];
            NSDictionary *dic = agents.firstObject;
            MAAgent *currentAgent = [MAAgent initWithUserId:[dic getString:@"id"] name:[dic getString:@"name"] portraitUri:[dic getString:@"icon"]];
            
            [[MAChat getInstance] updateSession:currentAgent];
            
            [self refreshUserInfoSession];
        }
            break;
        case MAAGENT_CLOSE_SESSION://坐席关闭
        {
            NSLog(@"坐席关闭");
            [[MAChat getInstance] clearRequestAndSession];
            [self addTipsMessage:@"会话结束"];
            /**判断之前是否推送过满意度 如没有需要主动推送*/
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSInteger pushSatisfactionCount = [defaults integerForKey:@"pushSatisfactionCount"];
            if(pushSatisfactionCount == nil || pushSatisfactionCount == 0){
                [self pushSatisfactionView];
            }else {
                [defaults setInteger:0 forKey:@"pushSatisfactionCount"];
            }
        }
            break;
        case MAAGENT_SEND_MESSAGE://坐席发送消息
            NSLog(@"坐席发送消息");
        {
            NSDictionary *msgDic = [json getObject:@"msg"];
            int msgType = [msgDic getInt:@"type"];
            if(msgType == MASYSTEM_NOTICE) {
                int noticeType = [msgDic getInt:@"noticeType"];
                if(noticeType == MANORMAL) {
                    NSString *content = [msgDic getString:@"content"];
                    RCTextMessage *textMsg = [RCTextMessage messageWithContent:content];
                    RCMessage *message = [[RCMessage alloc] initWithType:self.conversationType targetId:self.targetId direction:rcMsg.messageDirection messageId:rcMsg.messageId content:textMsg];
                    [self appendAndDisplayMessage:message];
                    // [[RCIMClient sharedRCIMClient] insertOutgoingMessage:self.conversationType targetId:self.targetId sentStatus:rcMsg.sentStatus content:rcMsg.content];
                } else if (noticeType == MATRANSFER_NOTICE || noticeType == MAINVITE_NOTICE) {
                    NSString *content = [msgDic getString:@"content"];
                    [self addTipsMessage:content];
                }
            }
        }
            break;
            
        default:
            break;
    }
}
/**
 *  是否启动会话页面下方的输入工具栏
 *
 *  @param enable 启用
 */
- (void)isEnableInputBarControl:(BOOL)enable {
    self.chatSessionInputBarControl.userInteractionEnabled = enable;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/**
 * 发送之前未送达的消,当排队之前发出的消息,会先缓存起来，如果排上队了，就会补发这些消息
 */
- (void)sendUnsendMessages {
    
    NSArray *array = [[MAChat getInstance] getUnsendMessage];
    for (UnSendMessage *message in array) {
        NSDictionary *contentDic = [self dictionaryWithJsonString:message.content];
//        NSInteger conversation_type = [message.conversation_type integerValue];
        id content = [contentDic getString:@"content"];
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        EliteMessage *messageContent = [EliteMessage messageWithContent:content];
        extra[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
        extra[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
        if(!([message.object_name isEqual:ELITE_MSG])){
            extra[@"type"] = @(MASEND_CHAT_MESSAGE);
            if ([message.object_name isEqual:TXT_MSG]) {
                RCTextMessage *txtMessage = [MAMessageUtils generateTxtMessage:content];
                extra[@"messageType"] = @(MATEXT);
                txtMessage.extra = [extra mj_JSONString];
                [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:message.target_id content:txtMessage pushContent:nil pushData:nil success:^(long messageId) {
//                    [array removeObject:message];
                    //[[MAChat getInstance] updateUnsendMessage:array];
                } error:nil];
//                [[RCIMClient sharedRCIMClient] insertOutgoingMessage:conversation_type targetId:message.target_id sentStatus:ReceivedStatus_UNREAD content:txtMessage];
            } else{
                if ([message.object_name isEqual:IMG_MSG]) {
                    extra[@"imageUri"] = [contentDic getString:@"imageUri"];
                    extra[@"messageType"] = @(MAIMG);
                } else if ([message.object_name isEqual:VC_MSG]) {
                    extra[@"length"] = [contentDic getString:@"duration"];
                    extra[@"messageType"] = @(MAVOICE);
                } else if ([message.object_name isEqual:LBS_MSG]) {
                    extra[@"latitude"] = [contentDic getString:@"latitude"];
                    extra[@"longitude"] = [contentDic getString:@"longitude"];
                    extra[@"poi"] = [contentDic getString:@"poi"];
                    extra[@"imgUri"] = [contentDic getString:@"imgUri"];
                    extra[@"messageType"] = @(MALOCATION);
                    if(self.mapType == MAMAPTYPE_Baidu){
                        extra[@"map"] = @"baidu";
                    }
                } if([message.object_name isEqual:SIGHT_MSG]){
                    extra[@"messageType"] = @(MASIGHT);
                    extra[@"content"] = [contentDic getString:@"content"];
                    extra[@"name"] = [contentDic getString:@"name"];
                    extra[@"sightUrl"] = [contentDic getString:@"sightUrl"];
                    extra[@"duration"] = [contentDic getString:@"duration"];
                    extra[@"size"] = [contentDic getString:@"size"];
                } else if ([message.object_name isEqual:HQVCMsg]) {
                    extra[@"length"] = [contentDic getString:@"duration"];
                    extra[@"messageType"] = @(MAQHVOICE);
                    extra[@"remoteUrl"] = [contentDic getString:@"remoteUrl"];
                    extra[@"name"] = [contentDic getString:@"name"];
                }
                NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
                messageContent.extra = [extra mj_JSONString];
                [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
                } error:nil];
            }
        }else{
            id contentMsg = [content getString:@"content"];
            messageContent = [EliteMessage messageWithContent:contentMsg];
            if(contentMsg != nil){
                id type = [content getString:@"type"];
                extra[@"type"] = type;//elite消息类型
            }
            messageContent.extra = [extra mj_JSONString];
            [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_PRIVATE targetId:message.target_id content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
//                [array removeObject:message];
               // [[MAChat getInstance] updateUnsendMessage:array];
            } error:nil];
        }
        
        [UnSendMessage deleteData:message.guid];
    }
}
/**
 *  满意度评价
 *
 *  @param ratingId 满意1 不满意0
 *  @param comment  描述
 */
- (void)sendRating:(NSInteger)ratingId comment:(NSString *)comment {
    EliteMessage *message = [EliteMessage messageWithContent:@""];
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    extra[@"type"] = @(MARATE_SESSION);
    extra[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    extra[@"sessionId"] = [[MAChat getInstance] getSessionId] != (long) 0 ? @([[MAChat getInstance] getSessionId]) : @(self.currentSessionId);//聊天会话号，排队成功后返回
    message.extra = [extra mj_JSONString];
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
    messageDic[@"ratingId"] = @(ratingId);
    messageDic[@"ratingComments"] = comment?comment:@"";
    message.message = [messageDic mj_JSONString];
    
    [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:self.targetId content:message pushContent:nil pushData:nil success:nil error:nil];
}
/**
 *  推送满意度评价
 */
- (void)pushSatisfactionView {
    
    // 主线程执行：
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.satisfactionView) {
            self.satisfactionView = [MASatisfactionView newSatisfactionView:self];
        }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.satisfactionView];
    });
}
#define mark 满意评价 回调函数
/**
 *  满意评价
 *
 *  @param comment  备注
 *  @param ratingId 0 不满意 1 满意
 */
- (void)satisfactionView:(NSString *)comment sureEvent:(NSInteger)ratingId {
    NSLog(@"---满意评价：%@",comment);
    
    [self sendRating:ratingId comment:comment];
    
    NSString *tips = [NSString stringWithFormat:@"您的评价是【%@】",ratingId==0?@"不满意":@"满意"];
    
    [self addTipsMessage:tips];
    
    [self.satisfactionView removeFromSuperview];
    
    self.satisfactionView = nil;
}

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    
    switch (tag) {
            
        case  PLUGIN_BOARD_ITEM_LOCATION_TAG : {
            if (self.mapType == MAMAPTYPE_Baidu) {
                // 主线程执行：
                dispatch_async(dispatch_get_main_queue(), ^{
                    MALocationViewController *locationController = [MALocationViewController new];
                    locationController.delegate = self;
                    [self presentViewController:locationController animated:YES completion:nil];
                });
                
            }else{
                [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            }
            break;
        }
        case  PLUGIN_BOARD_ITEM_CLOSESERVICE_TAG : {
            
            // 主线程执行：
            dispatch_async(dispatch_get_main_queue(), ^{
                MAChat *maChat = [MAChat getInstance];
                NSString *session = [maChat getSession];
                if(session != nil){
                    MAClient *maClient = [maChat getClient];
                    int queueId = [maChat getQueueId];
                    NSString * serverAddr = maClient.serverAddr;
                    NSRange range = [serverAddr rangeOfString:@"/rcs"];
                    if (range.location != NSNotFound) {
                        serverAddr = [serverAddr substringToIndex:range.location];
                    }
                    self.currentSessionId = [[MAChat getInstance] getSessionId];
                    [[MAEliteChat alloc] closeSessionService: serverAddr token:maChat.tokenStr userId:maClient.userId name:maClient.name portraitUri:maClient.portraitUri chatTargetId: [maChat getChatTargetId] queueId:queueId ngsAddr:maClient.ngsAddr tracks:[maChat getClient].tracks complete:nil];
                    [self addTipsMessage:@"会话结束"];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSInteger pushSatisfactionCount = [defaults integerForKey:@"pushSatisfactionCount"];
                    
                    if(pushSatisfactionCount == nil || pushSatisfactionCount == 0){
                        [self pushSatisfactionView];
                    }else {
                        [defaults setInteger:0 forKey:@"pushSatisfactionCount"];
                    }
                }
            });
            break;
        }
        default:
            
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            
            break;
            
    }
}

-(void)sendlocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image {
    RCLocationMessage *locationMessage = [RCLocationMessage messageWithLocationImage:image location:coordinate locationName:title];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    if(self.mapType == MAMAPTYPE_Baidu){
        dic[@"map"] = @"baidu";//坐席使用百度地图打开
    }
    if ([[MAChat getInstance] getSessionId] == 0) {
        dic[@"requestId"] = @([[MAChat getInstance] getRequestId]);//聊天会话号，排队成功后返回
    } else {
        dic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
    }
    locationMessage.extra = [dic mj_JSONString];
    [[RCIM sharedRCIM] sendMessage:self.conversationType targetId:self.targetId content:locationMessage pushContent:nil pushData:nil success:nil error:nil];
}


//判断是否有中文
-(BOOL)hasChinese:(NSString *)str {
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

//点击cell
- (void)didTapMessageCell:(RCMessageModel *)model {
    NSLog(@"didTapMessageCell");
    if (nil == model) return;
    RCMessageContent *_messageContent = model.content;
    if ([_messageContent isMemberOfClass:[RCLocationMessage class]] && self.mapType == MAMAPTYPE_Baidu) {
        // Show the location view controller
        RCLocationMessage *locationMessage = (RCLocationMessage *)(_messageContent);
        [self presentCustomLocationViewController:locationMessage];
    }
    else if ([_messageContent isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imgMessage = (RCImageMessage *)(_messageContent);
        if ([self hasChinese:imgMessage.imageUrl]) {
            NSString *encodedString=(NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            (CFStringRef) imgMessage.imageUrl,
            NULL,
            (CFStringRef)@"",
            kCFStringEncodingUTF8));
            imgMessage.imageUrl = encodedString;
        }
        [super didTapMessageCell:model];
    }
    else {
        [super didTapMessageCell:model];
    }
}

- (void)presentCustomLocationViewController:(RCLocationMessage *)locationMessage {
    MALocationDetailController *locationViewController = [[MALocationDetailController alloc] initWithCoordinate:locationMessage.location title:locationMessage.locationName];
    
    [self presentViewController:locationViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willDisplayConversationTableCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *msgModel = self.conversationDataRepository[indexPath.item];
    MASession *session = [[MAChat getInstance] getSession];
    if ([cell isKindOfClass:[RobotMessageCell class]]) {
        RobotMessageCell *newCell = (RobotMessageCell *)cell;
        RobotMessage *msg = (RobotMessage *)msgModel.content;
        NSMutableAttributedString *muString = [[NSMutableAttributedString alloc] initWithString:msg.message];
        NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blueColor],
                                     NSFontAttributeName:[UIFont systemFontOfSize:16]};
        NSString *pattern =  @"\\【[0-9a-zA-Z\\u4e00-\\u9fa5?？ %&',;=#^()]+\\】";
        NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *results = [regular matchesInString:msg.message options:0 range:NSMakeRange(0, msg.message.length)];
        for (NSTextCheckingResult *result in results) {
            NSRange range = result.range;
            range.length = range.length - 2;
            range.location = range.location + 1;
            NSString *temp = [msg.message substringWithRange:range];
            [muString addAttributes:attributes range:range];
            NSString *encodedString=(NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,               (CFStringRef)temp, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
            NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:encodedString]];
            [newCell.textLabel.attributedStrings addObject:textCheckingResult];
        }
        newCell.textLabel.attributedText = muString;
        if(session.currentAgent.portraitUri){
            UIImageView *portraitView = (UIImageView*)newCell.portraitImageView;
            NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:session.currentAgent.portraitUri]];
            UIImage *image =  [UIImage imageWithData:data];
            portraitView.image = image;
            newCell.portraitImageView = portraitView;
        }
    } else if ([cell isKindOfClass:[CardMessageCell class]]) {
        CardMessageCell *newCell = (CardMessageCell *)cell;
        if(session.currentAgent.portraitUri){
            UIImageView *portraitView = (UIImageView*)newCell.portraitImageView;
            NSData *data = [NSData  dataWithContentsOfURL:[NSURL URLWithString:session.currentAgent.portraitUri]];
            UIImage *image =  [UIImage imageWithData:data];
            portraitView.image = image;
            newCell.portraitImageView = portraitView;
        }
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
