 //
//  MARyChatViewController.m
//  RyWebChat
//
//  Created by nwk on 2017/2/9.
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

@interface MARyChatViewController ()<RCIMReceiveMessageDelegate,MASatisfactionViewDelegate,MALocationDelegate>

@end

@implementation MARyChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.displayUserNameInCell = NO;
    
    [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
    
    [[MAEliteChat shareEliteChat] sendQueueRequest];
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
- (void)refreshUserInfoSession {
    MASession *session = [[MAChat getInstance] getSession];
    
    NSString *icon = session.currentAgent.portraitUri;
    if (icon && ![icon isEqualToString:@""]) {
        NSString *ngs = [[[MAChat getInstance] getClient] ngsAddr];
        
        icon = [[ngs stringByAppendingPathComponent:@"fs/get?file="] stringByAppendingPathComponent:icon];
    }
    
    session.currentAgent.portraitUri = icon;
    
    RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:self.targetId];
    userInfo.name = session.currentAgent.name;
    userInfo.portraitUri = icon;
    [[RCIM sharedRCIM] refreshUserInfoCache:userInfo withUserId:self.targetId];
}

-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message {
    //定义一个SystemSoundID
    SystemSoundID soundID = 1307;//具体参数详情下面贴出来
    //播放声音
    AudioServicesPlaySystemSound(soundID);
    
    return YES;
}

/**
 *  解析消息
 *
 *  @param message 消息
 */
- (void)parseMessage:(NSString *)message rcMsg:(RCMessage *)rcMsg {
    
    MAJSONObject *json = [MAJSONObject initJSONObject:message];
    
    switch ([json getInt:@"type"]) {
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
            
            [self addTipsMessage:msg];
        }
            break;
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
                [MAChat clearRequestAndSession];
                
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
                    
                }
                if(saveUnmsg != nil){
                    [[MAChat getInstance] addUnsendMessage:saveUnmsg];
                }
                
                [[MAEliteChat shareEliteChat] sendQueueRequest];
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
            
            NSDictionary *dic = agents.firstObject;
            
            MAAgent *currentAgent = [MAAgent initWithUserId:[dic getString:@"id"] name:[dic getString:@"name"] portraitUri:[dic getString:@"icon"]];
            
            MASession *session = [MASession initWithSessionId:sessionId agent:currentAgent];
            
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
            [MAChat clearRequestAndSession];
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
    
    for (MASaveMessage *message in tempArray) {
        
        id content = [message.contentDic getString:@"content"];
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        EliteMessage *messageContent = [EliteMessage messageWithContent:content];
        
        extra[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
        extra[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
        if(!([message.objectName isEqual:ELITE_MSG])){
            extra[@"type"] = @(MASEND_CHAT_MESSAGE);
            if ([message.objectName isEqual:TXT_MSG]) {
                extra[@"messageType"] = @(MATEXT);
            } else if ([message.objectName isEqual:IMG_MSG]) {
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
            }
        }else{
            id contentMsg = [content getString:@"content"];
            messageContent = [EliteMessage messageWithContent:contentMsg];
            if(contentMsg != nil){
                id type = [content getString:@"type"];
                extra[@"type"] = type;//elite消息类型
            }
           
        }
        messageContent.extra = [extra mj_JSONString];
        
        [[RCIM sharedRCIM] sendMessage:ConversationType_SYSTEM targetId:self.targetId content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
            [array removeObject:message];
            [[MAChat getInstance] updateUnsendMessage:array];
        } error:nil];
        
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

@end
