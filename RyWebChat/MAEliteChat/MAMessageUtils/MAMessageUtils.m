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
#import "MAJSONObject.h"
#import "MJExtension.h"

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
    contentDic[@"tracks"] = [[MAChat getInstance] getClient].tracks;//添加轨迹参数
    
    //contentDic[@"messageId"] = @([[MAChat getInstance] getSessionId]);//messageId
    NSString *content = [contentDic mj_JSONString];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"type"] = @(MASEND_CHAT_REQUEST);//人工聊天请求
    extraDic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    extraDic[@"targetId"] = [[MAChat getInstance] getChatTargetId];//添加房间号
    NSString *extra = [extraDic mj_JSONString];
    EliteMessage *messageContent = [EliteMessage messageWithContent:content];
    messageContent.extra = extra;
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:messageContent pushContent:nil pushData:nil success:^(long messageId) {
            
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
+ (NSString *)getLocationMessageJsonStr:(BOOL *) mapType{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
//    if(mapType == MAMAPTYPE_Baidu){
//        dic[@"map"] = @"baidu";//坐席使用百度地图打开
//    }
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
 * 获取EliteMessage对象
 * @param message
 * @return 返回EliteMessage对象
 */
+ (EliteMessage *)generateCustomerMessage:message {
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"type"] = @(MASEND_CUSTOM_MESSAGE);//自定义消息请求
    extraDic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    extraDic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//sessionId
    NSString *extra = [extraDic mj_JSONString];
    EliteMessage *messageContent = [EliteMessage messageWithContent:message];
    messageContent.extra = extra;
    
    return messageContent;
    
}

/**
 * 构造一个自定义RCTxtMessage消息对象
 * @param message
 * @return
 */
+ (RCTextMessage *)generateTxtMessage:message{
    RCTextMessage *txtMessage = [RCTextMessage messageWithContent:message];
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"type"] = @(MASEND_CHAT_MESSAGE);//自定义消息请求
    extraDic[@"messageType"] = @(MATEXT);
    extraDic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    extraDic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//sessionId
    NSString *extra = [extraDic mj_JSONString];
    txtMessage.extra = extra;
    return txtMessage;
}

/**
 * 添加自定义未读消息 在初始化之前，用于传递相关业务数据到前台，比如商品信息
 * @param message json字符串，自己定义
 */
+ (void)sendCustomMessage :(NSString *) message{
    
    if([[MAChat getInstance] getSessionId]){
        EliteMessage *eliteMessage = [self generateCustomerMessage:message];
        NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
        [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:eliteMessage pushContent:nil pushData:nil success:^(long messageId) {
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
            
        }];
    }else{
        MASaveMessage *maSaveMessage = [MASaveMessage new];
        maSaveMessage.objectName = ELITE_MSG;
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        content[@"type"] = @(MASEND_CUSTOM_MESSAGE);
        content[@"content"] = message;
        maSaveMessage.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:content,@"content",nil];
        [[MAChat getInstance] addUnsendMessage:maSaveMessage];
    }
}

/**
 * 添加自定义未读消息 在初始化之前，用于传递相关提示语，比如之前点了哪个商品 传入商品名称
 * @param message 字符串，自己定义
 */

+ (void)sendTxtMessage:(NSString *) message{
    if([[MAChat getInstance] getSessionId]){
        RCTextMessage *txtMessage = [self generateTxtMessage:message];
        NSString *extra = [[self getMessageExtra] mj_JSONString];
        txtMessage.extra = extra;
        NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];

        [[RCIM sharedRCIM] sendMessage:ConversationType_PRIVATE targetId:chatTargetId content:txtMessage pushContent:nil pushData:nil success:^(long messageId) {
            
        } error:^(RCErrorCode nErrorCode, long messageId) {
            
        }];

    }else {
        MASaveMessage *txtMessage = [MASaveMessage new];
        txtMessage.objectName = TXT_MSG;
        txtMessage.contentDic = [NSDictionary dictionaryWithObjectsAndKeys:message, @"content", nil];
        [[MAChat getInstance] addUnsendMessage:txtMessage];
    }
}



/**
 * 构造一个自定义RCTxtMessage消息对象
 * @param message
 * @return
 */
+ (NSMutableDictionary *)getMessageExtra {
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"type"] = @(MASEND_CHAT_MESSAGE);
    extraDic[@"token"] = [MAChat getInstance].tokenStr;//登录成功后获取到的凭据
    extraDic[@"sessionId"] = @([[MAChat getInstance] getSessionId]);//sessionId
    return extraDic;
}

/**
 * 添加发送图片消息
 * @param imageUri String字符串，网络图片地址
 * @param content   String字符串，图片的base64
 */
+ (void)sendImageMessageWithData :(NSData *) data{
    UIImage *image = [UIImage imageWithData:data];
    [self sendImageMessage2:image imageUri:nil];
}

/**
 * 预发送图片消息
 * @param content   String字符串，图片的base64
 * @param imageUri String字符串，网络图片地址
 * 注： 两者选其一
 */
+ (void)sendImageMessage :(NSString *) content imageUri:(NSString *) imageUri{
    UIImage *image = nil;
    if(content != nil && content != NULL){
        NSData * base64Data =[content dataUsingEncoding:NSUTF8StringEncoding];
        NSData * imageData = [[NSData alloc] initWithBase64EncodedData:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        image = [UIImage imageWithData:imageData ];
    } else if (imageUri != nil && imageUri != NULL) {
        NSURL *url=[NSURL URLWithString: imageUri];
        NSData *data = [NSData dataWithContentsOfURL:url];
        image = [UIImage imageWithData:data];
    }
    [self sendImageMessage2:image imageUri:imageUri];
    
}

/**
* 预发送图片消息
* @param content   UIImage
* @param imageUri String字符串，网络图片地址
*/
+ (void)sendImageMessage2 :(UIImage *) image imageUri:(NSString *) imageUri{
    RCImageMessage *imageMessage = [RCImageMessage messageWithImage:image];
    NSMutableDictionary *extraDic = [self getMessageExtra];
    if (imageUri != nil) {
         extraDic[@"imageUri"] = imageUri;
    }
    extraDic[@"messageType"] = @(MAIMG);
    NSString *extra = [extraDic mj_JSONString];
    imageMessage.extra =[extra mj_JSONString];
    NSString *chatTargetId = [[MAChat getInstance] getChatTargetId];
    [[RCIM sharedRCIM] sendMediaMessage:ConversationType_PRIVATE targetId:chatTargetId content:imageMessage pushContent:nil pushData:nil progress:nil success:nil error:nil cancel:nil];
}
@end
