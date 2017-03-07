//
//  MAMessageUtils.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EliteMessage.h"

@interface MAMessageUtils : NSObject
/**
 *  发送排队请求
 *
 *  @param queueId 队列号
 *  @param from    请求来源
 */
+ (void)sendChatRequest:(int)queueId from:(NSString *)from;
/**
 *  发送文本消息
 *
 *  @param msg 消息对象
 */
+ (NSString *)getTextMessageJsonStr;
/**
 *  发送语音消息
 *
 *  @param msg 消息对象
 */
+ (NSString *)getVoiceMessageJsonStr:(long long)duration;
/**
 *  发送位置消息
 *
 *  @param msg 消息对象
 */
+ (NSString *)getLocationMessageJsonStr:(BOOL *) isBaidyMapType;

/**
 * 发送自定义消息
 * @param message
 * @return 发送成功还是失败
 */
+ (BOOL)sendCustomMessage:(NSString *)message;
/*
* 构造一个自定义消息对象
* @param message
* @return
*/
+ (EliteMessage *)generateCustomMessage:(NSString *) token sessionId:(long) sessionId message:(NSString *) message;

/**
 * 添加自定义未读消息 在初始化之前，用于传递相关业务数据到前台，比如商品信息
 * @param message json字符串，自己定义
 */

+ (void)addUnsendCustomMessage:(NSString *) message;

@end
