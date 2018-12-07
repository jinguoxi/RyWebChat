//
//  MAChat.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+MAJSON.h"
#import "MAClient.h"
#import "MARequest.h"
#import "MASession.h"
#import "MASaveMessage.h"

@interface MAChat : NSObject

@property (strong, nonatomic, readonly) NSString *tokenStr;
@property(atomic,assign) int *queueId;
@property (strong, nonatomic, readonly) NSString *chatTargetId;

+ (instancetype)getInstance;

- (void)setClient:(MAClient *)client;
- (void)setRequest:(MARequest *)request;
- (void)setSession:(MASession *)session;
- (void)setTokenStr:(NSString *)tokenStr;
- (void)setChatTargetId:(NSString *)chatTargetId;
- (void)setQueueId:(int *)queueId;

- (MAClient *)getClient;
- (MASession *)getSession;
- (long)getRequestId;
- (long)getSessionId;
- (NSString *)getChatTargetId;
- (int *)getQueueId;
/**
 *  更新坐席信息
 *
 *  @param agent 坐席信息
 */
- (void)updateSession:(MAAgent *)currentAgent;
/**
 *  保存未发送消息
 *
 *  @param message 未发送的消息
 */
- (void)addUnsendMessage:(MASaveMessage *)message;
/**
 *  清除request和session
 */
- (void)clearRequestAndSession;
/**
 *  获取未发送消息集合
 *
 *  @return 消息集合
 */
- (NSMutableArray *)getUnsendMessage;
/**
 *  更新未发送的消息
 *
 *  @param array 消息集合
 */
- (void)updateUnsendMessage:(NSArray *)array;
/**
 *  判断当前session是否有效
 *
 *  @return flag
 */
- (bool *)isSessionAvailable;

/**
 *  判断当前token
 *
 *  @return flag
 */
- (NSString *)getTokenStr;

@end
