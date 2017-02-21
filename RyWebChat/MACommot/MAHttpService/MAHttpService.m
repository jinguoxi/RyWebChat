//
//  MAHttpService.m
//  RyWebChat
//
//  Created by nwk on 2017/2/9.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "MAHttpService.h"
#import "MAFNetworkingTool.h"
#import "MAJSONObject.h"
#import "MJExtension.h"

@implementation MAHttpService

/**
 *  获取token
 *  @param urlString 请求路径
 *  @param paramer  参数
 *  @param complete 完成回调
 */
+ (void)getRyToken:(NSString *)urlString paramer:(id)paramer success:(void (^)(NSString *token))successBlock error:(void (^)(NSError *error))errorBlock {
    [MAFNetworkingTool POST:urlString parameters:paramer successBlock:^(id responesObj) {
        
        MAJSONObject *json = [MAJSONObject initJSONObject:[responesObj mj_JSONString]];
        
        BOOL result = [json getInt:@"result"] == 1;
        if (result) {
            successBlock([json getString:@"token"]);
        } else {
            successBlock(nil);
        }
        
    } failedBlock:errorBlock];
}

@end
