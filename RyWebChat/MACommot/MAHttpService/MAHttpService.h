//
//  MAHttpService.h
//  RyWebChat
//
//  Created by nwk on 2017/2/9.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAHttpService : NSObject

/**
 *  获取token
 *  @param urlString 请求路径
 *  @param paramer  参数
 *  @param complete 完成回调
 */
+ (void)getRyToken:(NSString *)urlString paramer:(id)paramer success:(void (^)(NSString *token))successBlock error:(void (^)(NSError *error))errorBlock;

/**
 *  check token
 *  @param urlString 请求路径
 *  @param paramer  参数
 *  @param complete 完成回调
 */
+ (void)checkToken:(NSString *)urlString paramer:(id)paramer success:(void (^)(NSString *token))successBlock error:(void (^)(NSError *error))errorBlock;

/**
 *  关闭session
 *  @param urlString 请求路径
 *  @param paramer  参数
 *  @param complete 完成回调
 */
+ (void)closeSession:(NSString *)urlString paramer:(id)paramer success:(void (^)(NSString *token))successBlock error:(void (^)(NSError *error))errorBlock;

@end
