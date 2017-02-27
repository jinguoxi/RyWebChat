//
//  MAMessageUtils.m
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MAMessageUtils.h"
#import <RongIMKit/RongIMKit.h>
#import "MJExtension.h"
#import "MAChat.h"
#import "MAEliteChat.h"
#import "MAConfig.h"
#import "EliteMessage.h"

@implementation MAMessageUtils
/**
 *  发送排队请求
 *
 *  @param queueId 队列号
 *  @param from    请求来源
 */
+ (void)sendChatRequest:(int)queueId from:(NSString *)from {
    
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    contentDic[@"queueId"] = @(queueId);//排队的队列号
    contentDic[@"from"] = from;//请求来源
    //contentDic[@"messageId"] = @([[MAChat getInstance] getSessionId]);//messageId
    NSString *content = [contentDic mj_JSONString];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"type"] = @(MASEND_CHAT_REQUEST);//人工聊天请求
    extraDic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    NSString *extra = [extraDic mj_JSONString];
    EliteMessage *messageContent = [EliteMessage messageWithContent:content];
    messageContent.extra = extra;
    //EliteMessage
    // RCInformationNotificationMessage *warningMsg =
    // [RCInformationNotificationMessage
    //notificationWithMessage:jsonStr extra:nil];
    
    [[RCIM sharedRCIM] sendMessage:ConversationType_SYSTEM targetId:CHAT_TARGET_ID content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
            
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
    }];
}

/**
 *  发送文本消息
 *
 *  @param msg 消息对象
 */
+ (NSString *)getTextMessageJsonStr{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    
    if ([[MAChat getInstance] getSessionId] == 0) {
        dic[@"requestId"] = @([[MAChat getInstance] getRequestId]);//聊天会话号，排队成功后返回
    } else {
        dic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
    }
    
    return [dic mj_JSONString];
}
/**
 *  发送位置消息
 *
 *  @param msg 消息对象
 */
+ (NSString *)getLocationMessageJsonStr:(BOOL *) isBaidyMapType{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    if(isBaidyMapType){
        dic[@"map"] = @"baidu";//坐席使用百度地图打开
    }
    if ([[MAChat getInstance] getSessionId] == 0) {
        dic[@"requestId"] = @([[MAChat getInstance] getRequestId]);//聊天会话号，排队成功后返回
    } else {
        dic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
    }
    
    return [dic mj_JSONString];
}

/**
 *  发送语音消息
 *
 *  @param msg 消息对象
 */
+ (NSString *)getVoiceMessageJsonStr:(long long)duration {

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    dic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    dic[@"length"] = @(duration);//时长
    if ([[MAChat getInstance] getSessionId] == 0) {
        dic[@"requestId"] = @([[MAChat getInstance] getRequestId]);//聊天会话号，排队成功后返回
    } else {
        dic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//聊天会话号，排队成功后返回
    }

    return [dic mj_JSONString];
}

/**
 * 发送自定义消息
 * @param message
 * @return 发送成功还是失败
 */
+ (BOOL)sendCustomMessage:(NSString *)message { 
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"type"] = @(MASEND_CUSTOM_MESSAGE);//自定义消息请求
    extraDic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    extraDic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//sessionId
    NSString *extra = [extraDic mj_JSONString];
    EliteMessage *messageContent = [EliteMessage messageWithContent:message];
    messageContent.extra = extra;
    [[RCIM sharedRCIM] sendMessage:ConversationType_SYSTEM targetId:CHAT_TARGET_ID content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
        
    } error:^(RCErrorCode nErrorCode, long messageId) {
        
    }];
    return true;
}

@end
