//
//  AFNHttpHelp.h
//  IosProject
//
//  Created by nwk on 16/8/9.
//  Copyright © 2016年 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASessionTimeOut.h"

@interface MAFNetworkingTool : NSObject

NSString * getContentTypeForPath(NSURL *url);
/**
 *  POST的请求
 *  @param mark         请求标记(根据标记可以获得对应的请求路径以及请求的SerivceID)
 *  @param parameters   请求参数
 *  @param successBlock 成功回调
 *  @param failedBlock  失败回调
 */
+ (void)POST:(NSString *)name parameters:(id)parameters successBlock:(void (^)(id responesObj))successBlock failedBlock:(void (^)(NSError *error))failedBlock;

/**
 *  上传文件
 *  @param postUrl  请求路径（.do）
 *  @param filePath 本地文件路径
 */
+ (void)uploadWithPOST:(NSString *)url parameters:(NSDictionary *)parameters filePath:(NSString *)filePath successBlock:(void (^)(NSDictionary *result))successBlock faileBlock:(void (^)(NSError *error))faileBlock;

/**
 *  通过请求的tag值去cancle请求
 *
 *  @param tag 请求标示
 */
+ (void)cancleOperationWithHttpMark:(NSString *)name;
/**
 *  cancle所有请求
 */
+ (void)cancelAllHttp;

BOOL whetherNetworkWithOnline();
@end
