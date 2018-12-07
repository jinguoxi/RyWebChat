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
#import "SimpleMessageCell.h"
#import "SimpleMessage.h"
#import "NSString+Category.h"

@interface MARyChatViewController ()<RCIMReceiveMessageDelegate,MASatisfactionViewDelegate,MALocationDelegate, RCAttributedLabelDelegate>

@end

@implementation MARyChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.displayUserNameInCell = NO;
    
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    //[[RCIM sharedRCIM] setUserInfoDataSource:self];
    [[MAEliteChat shareEliteChat] sendQueueRequest];
    [self registerClass:[SimpleMessageCell class] forMessageClass:[SimpleMessage class]];
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
    if ([messageContent isKindOfClass:[RCTextMessage class]] || [messageContent isKindOfClass:[RCLocationMessage class]] ||
        [messageContent isKindOfClass:[RCImageMessage class]]) {
        RCTextMessage *textMsg = (RCTextMessage *)messageContent;
        textMsg.extra = [MAMessageUtils getTextMessageJsonStr];
        
    } else if ([messageContent isKindOfClass:[RCVoiceMessage class]]) {
        RCVoiceMessage *voiceMsg = (RCVoiceMessage *)messageContent;
        voiceMsg.extra = [MAMessageUtils getVoiceMessageJsonStr:voiceMsg.duration];
    }else if ([messageContent isKindOfClass:[RCSightMessage class]]) {
        RCSightMessage *sightMsg = (RCSightMessage *)messageContent;
        sightMsg.extra = [MAMessageUtils getTextMessageJsonStr];
    }
    
    return messageContent;
}

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    NSLog(@"message.content:%@",message.content);
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
            NSString *ngs = [[[MAChat getInstance] getClient] ngsAddr];
            icon = [[ngs stringByAppendingPathComponent:@"fs/get?file="] stringByAppendingPathComponent:icon];
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

-(void)sentRobotMessage:(NSString *)content state: (NSString *)state receivedTime:(long long)receivedTime{
    
    RCMessageContent *simpleMessgae = [SimpleMessage messageWithContent:content extra:state];
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
                            //                       NSString *questionName = [relatedTemp getObject:@"name"];
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
            NSLog(@"结束聊天");
            
            break;
        case MARATE_SESSION: //满意度评价
            NSLog(@"满意度评价");
            
            break;
        case MASEND_CHAT_MESSAGE: //客户端发送的消息
            NSLog(@"客户端发送的消息");
            //TODO 当收到发送的消息返回session不合法时候，认为服务端会话已经关闭了，而客户端由于某些原因没能收到关闭信息
            //TODO 这时候也去清空会话，并且把原始消息缓存起来，同时发出聊天排队请求
            int result = [json getInt:@"result"];
            if(result == MAINVAILD_CHAT_SESSION_ID) {
                [[MAChat getInstance] clearRequestAndSession];
                
                NSDictionary *originalMessage = [json getObject:@"originalMessage"];
                NSString *objectName = [originalMessage getString:@"objectName"];
                
                MASaveMessage *saveUnmsg = nil;
                if([objectName isEqual:TXT_MSG]) {
                    
                    saveUnmsg = [MASaveMessage saveMessageWithText:originalMessage];
                    
                } else if ([objectName isEqual:IMG_MSG]) {
                    
                    saveUnmsg = [MASaveMessage saveMessageWithImage:originalMessage];
                    
                } else if ([objectName isEqual:FILE_MSG]) {
                    
                } else if ([objectName isEqual:LBS_MSG]) {
                    
                    saveUnmsg = [MASaveMessage saveMessageWithLocation:originalMessage];
                    
                } else if ([objectName isEqual:VC_MSG]) {
                    
                    saveUnmsg = [MASaveMessage saveMessageWithVoice:originalMessage];
                    
                }else if([objectName isEqual:SIGHT_MSG]){
                    saveUnmsg = [MASaveMessage saveMessageWithSight:originalMessage];
                }
                if(saveUnmsg != nil){
                    [[MAChat getInstance] addUnsendMessage:saveUnmsg];
                }
                
                [[MAEliteChat shareEliteChat] sendQueueRequest];
            }
             //[MAMessageUtils sendTxtMessage:@"txtMessage__"];
            
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
            [self sendUnsendMessages];
        }
            break;
        case MAAGENT_PUSH_RATING://坐席推送了满意度
            NSLog(@"坐席推送了满意度");
            [self pushSatisfactionView];
            
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
            NSLog(@"坐席关闭");
            [[MAChat getInstance] clearRequestAndSession];
            [self addTipsMessage:@"会话结束"];
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

/**
 * 发送之前未送达的消,当排队之前发出的消息,会先缓存起来，如果排上队了，就会补发这些消息
 */
- (void)sendUnsendMessages {
    
    NSMutableArray *array = [[MAChat getInstance] getUnsendMessage];
    
    NSArray *tempArray = [NSArray arrayWithArray:array];
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    for (MASaveMessage *message in tempArray) {
        
        id content = [message.contentDic getString:@"content"];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        EliteMessage *messageContent = [EliteMessage messageWithContent:content];
        extra[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
        extra[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
        if(!([message.objectName isEqual:ELITE_MSG])){
            extra[@"type"] = @(MASEND_CHAT_MESSAGE);
            if ([message.objectName isEqual:TXT_MSG]) {
                RCTextMessage *txtMessage = [MAMessageUtils generateTxtMessage:content];
                extra[@"messageType"] = @(MATEXT);
                txtMessage.extra = [extra mj_JSONString];
                [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:txtMessage pushContent:nil pushData:nil success:^(long messageId) {
                    [array removeObject:message];
                    [[MAChat getInstance] updateUnsendMessage:array];
                } error:nil];
            } else{
                if ([message.objectName isEqual:IMG_MSG]) {
                    extra[@"imageUri"] = [message.contentDic getString:@"imageUri"];
                    extra[@"messageType"] = @(MAIMG);
                } else if ([message.objectName isEqual:VC_MSG]) {
                    extra[@"length"] = [message.contentDic getString:@"duration"];
                    extra[@"messageType"] = @(MAVOICE);
                } else if ([message.objectName isEqual:LBS_MSG]) {
                    extra[@"latitude"] = [message.contentDic getString:@"latitude"];
                    extra[@"longitude"] = [message.contentDic getString:@"longitude"];
                    extra[@"poi"] = [message.contentDic getString:@"poi"];
                    extra[@"imgUri"] = [message.contentDic getString:@"imgUri"];
                    extra[@"messageType"] = @(MALOCATION);
                    if(self.mapType == MAMAPTYPE_Baidu){
                        extra[@"map"] = @"baidu";
                    }
                } if([message.objectName isEqual:SIGHT_MSG]){
                    extra[@"messageType"] = @(MASIGHT);
                    extra[@"content"] = [message.contentDic getString:@"content"];
                    extra[@"name"] = [message.contentDic getString:@"name"];
                    extra[@"sightUrl"] = [message.contentDic getString:@"sightUrl"];
                    extra[@"duration"] = [message.contentDic getString:@"duration"];
                    extra[@"size"] = [message.contentDic getString:@"size"];
                }
                messageContent.extra = [extra mj_JSONString];
                [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
                    [array removeObject:message];
                    [[MAChat getInstance] updateUnsendMessage:array];
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
            [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
                [array removeObject:message];
                [[MAChat getInstance] updateUnsendMessage:array];
            } error:nil];
        }
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
    extra[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
    message.extra = [extra mj_JSONString];
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionary];
    messageDic[@"ratingId"] = @(ratingId);
    messageDic[@"ratingComments"] = comment?comment:@"";
    message.message = [messageDic mj_JSONString];
    
    [[RCIM sharedRCIM] sendMessage:ConversationType_SYSTEM targetId:self.targetId content:message pushContent:nil pushData:nil success:nil error:nil];
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
                break;
            }
        }
        default:
            
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            
            break;
            
    }
}

-(void)sendlocation:(CLLocationCoordinate2D)coordinate title:(NSString *)title detail:(NSString *)detail image:(UIImage *)image {
    RCLocationMessage *locationMessage = [RCLocationMessage messageWithLocationImage:image location:coordinate locationName:title];
    BOOL isBaiduMapType = self.mapType == MAMAPTYPE_Baidu;
    locationMessage.extra = [MAMessageUtils getLocationMessageJsonStr : &isBaiduMapType];
    
    [[RCIM sharedRCIM] sendMessage:self.conversationType targetId:self.targetId content:locationMessage pushContent:nil pushData:nil success:nil error:nil];
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
    } else {
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
    
    if ([cell isKindOfClass:[SimpleMessageCell class]]) {
        SimpleMessageCell *newCell = (SimpleMessageCell *)cell;
        SimpleMessage *msg = (SimpleMessage *)msgModel.content;
        if([msg.extra isEqualToString:@"2"]){
            NSArray *array = [msg.content splitStringWithSymbol:@"\n\n"];//你好
            int count = (int)array.count;
            
            NSMutableAttributedString *muString = [[NSMutableAttributedString alloc] initWithString:msg.content];
            NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blueColor],
                                         NSFontAttributeName:[UIFont systemFontOfSize:16]};
            for( int i=0; i<count; i++){
                NSString *temp = [array objectAtIndex:i];//卖假酒
                NSLog(@"%i-%@", i, temp);
                NSString *confirmString = temp;
                NSRange range = [msg.content rangeOfString:confirmString];
                [muString addAttributes:attributes range:range];
                NSString *encodedString=(NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                              (CFStringRef)temp,
                                                                                                              NULL,
                                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                              kCFStringEncodingUTF8));
                NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:encodedString]];
                [newCell.textLabel.attributedStrings addObject:textCheckingResult];
            }
            newCell.textLabel.attributedText = muString;
        }else if([msg.extra isEqualToString:@"1"]){
            NSString *confirmString = @"【转人工】";
            NSMutableAttributedString *muString = [[NSMutableAttributedString alloc] initWithString:msg.content];
            NSRange range = [msg.content rangeOfString:confirmString];
            NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blueColor],
                                         NSFontAttributeName:[UIFont systemFontOfSize:16]};
            [muString addAttributes:attributes range:range];
            NSString *encodedString=(NSString*) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                          (CFStringRef)@"【转人工】",
                                                                                                          NULL,
                                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                          kCFStringEncodingUTF8));
            NSTextCheckingResult *textCheckingResult = [NSTextCheckingResult linkCheckingResultWithRange:range URL:[NSURL URLWithString:encodedString]];
            [newCell.textLabel.attributedStrings addObject:textCheckingResult];
            newCell.textLabel.attributedText = muString;
        }
        MASession *session = [[MAChat getInstance] getSession];
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
