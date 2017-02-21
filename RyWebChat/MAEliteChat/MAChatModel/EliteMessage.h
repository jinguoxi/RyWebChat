//
//  EliteMessage.h
//  RyWebChat
//
//  Created by nwk on 2017/2/10.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

/*!
 测试消息的类型名
 */
#define RCDTestMessageTypeIdentifier @"E:Msg"

/*!
 Demo测试用的自定义消息类
 
 @discussion Demo测试用的自定义消息类，此消息会进行存储并计入未读消息数。
 */
@interface EliteMessage : RCMessageContent <NSCoding>

/*!
 测试消息的内容
 */
@property(nonatomic, strong) NSString *message;

/*!
 测试消息的附加信息
 */
@property(nonatomic, strong) NSString *extra;

/*!
 初始化测试消息
 
 @param content 文本内容
 @return        测试消息对象
 */
+ (instancetype)messageWithContent:(NSString *)content;
@end
