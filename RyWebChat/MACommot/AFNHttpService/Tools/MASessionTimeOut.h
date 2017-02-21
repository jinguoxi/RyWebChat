//
//  MATimeOut.h
//  IosProject
//
//  Created by nwk on 2016/10/16.
//  Copyright © 2016年 ZL. All rights reserved.
//

/**
 //例子
 [MASessionTimeOut sharedSessionTimeOut].offlineBlock = ^{
    NSLog(@"网络已断开！");
 };
 */
#import "UIKit/UIKit.h"
#import <Foundation/Foundation.h>

@interface MASessionTimeOut : NSObject
/** 离线 */
UIKIT_EXTERN NSString *const NetworkOfflineStatus;
/** 在线 */
UIKIT_EXTERN NSString *const NetworkOnlineStatus;
/** 默认 */
UIKIT_EXTERN NSString *const NetworkDefaultStatus;

typedef void (^OfflineBlock)(void);
/**
 *  离线回调
 */
@property (copy, nonatomic) OfflineBlock offlineBlock;

+ (instancetype)sharedSessionTimeOut;

+ (void)addNetworkListen;

+ (void)setNetStatus:(NSString *)status;

+ (NSString *)getNetStatus;
@end
