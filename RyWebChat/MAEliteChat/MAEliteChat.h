//
//  MAEliteChat.h
//  RyWebChat
//
//  Created by nwk on 2017/2/15.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *CHAT_TITLE = @"客服";
//static NSString *CHAT_TARGET_ID = @"EliteCRM";

@interface MAEliteChat : NSObject

+ (instancetype)shareEliteChat;
/**
 *  初始化并启动融云SDK
 *
 *  @param key appKey
 */
- (void)startRyWithAppKey:(NSString *)key;


/**
 * 初始化EliteChat， 并且启动聊天
 * @param serverAddr EliteWebChat服务地址
 * @param userId 用户登录id
 * @param name 用户名
 * @param portraitUri 用户头像uri
 * @param complete 回调
 * @param ngs 坐席头像地址前缀
 */
- (void)startChat:(NSString *)serverAddr token:(NSString *)token userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSArray *)tracks complete:(void (^)(BOOL result))complete;


/**
 * 初始化EliteChat， 并且启动聊天
 * @param serverAddr EliteWebChat服务地址
 * @param userId 用户登录id
 * @param name 用户名
 * @param portraitUri 用户头像uri
 * @param complete 回调
 * @param ngs 坐席头像地址前缀
 */
- (void)initAndStart:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSArray *)tracks complete:(void (^)(BOOL result))complete;
/**
 * 初始化EliteChat
 * @param serverAddr EliteWebChat服务地址
 * @param userId 用户登录id
 * @param name 用户名
 * @param portraitUri 用户头像uri
 */
- (void)initElite:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId  tracks:(NSArray *)tracks;
/**
 * 初始化EliteChat
 * @param serverAddr EliteWebChat服务地址
 * @param userId 用户登录id
 * @param name 用户名
 * @param portraitUri 用户头像uri
 * @param ngs 坐席头像地址前缀
 */
- (void)initElite:(NSString *)serverAddr userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri queueId:(int)queueId ngsAddr:(NSString *)ngsAddr;
/**
 * 启动聊天
 * @param complete 回调
 */
- (void)startChat:(void (^)(BOOL result))complete;
/**
 *  设备的token
 *
 *  @param token
 */
- (void)setDeviceToken:(NSString *)token;

/**
 *  发出聊天排队请求
 *
 *  @param queueId 队列号
 */
- (void)sendQueueRequest;

- (void)closeSessionService:(NSString *)serverAddr token:(NSString *) token userId:(NSString *)userId name:(NSString *)name portraitUri:(NSString *)portraitUri chatTargetId:(NSString *)chatTargetId queueId:(int)queueId ngsAddr:(NSString *)ngsAddr tracks:(NSArray *)tracks complete:(void (^)(BOOL result))complete;

@end
