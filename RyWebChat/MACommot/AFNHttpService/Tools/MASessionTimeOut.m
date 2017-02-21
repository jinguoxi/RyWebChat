//
//  MATimeOut.m
//  IosProject
//
//  Created by nwk on 2016/10/16.
//  Copyright © 2016年 ZL. All rights reserved.
//

#import "MASessionTimeOut.h"
#import "AFNetworking.h"
#import "CommendConfig.h"

@interface MASessionTimeOut()<UIAlertViewDelegate>

@end

@implementation MASessionTimeOut

/** 离线 */
NSString *const NetworkOfflineStatus = @"NetworkOfflineStatus";
/** 在线 */
NSString *const NetworkOnlineStatus = @"NetworkOnlineStatus";
/** 默认 */
NSString *const NetworkDefaultStatus = @"NetworkDefaultStatus";

static MASessionTimeOut *sessionTimeOut=nil;

+ (instancetype)sharedSessionTimeOut{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionTimeOut = [[MASessionTimeOut alloc] init];
    });
    
    return sessionTimeOut;
}
+ (void)addNetworkListen{
    if (!sessionTimeOut) {
        [MASessionTimeOut sharedSessionTimeOut];
    }
    
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    //网络只有在startMonitoring完成后才可以使用检查网络状态
    [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkListen:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
}
+ (void)setNetStatus:(NSString *)status{
    SAVEDEFUAIL(status, @"NetworkStatus");
}

+ (NSString *)getNetStatus{
    return GETDEFUAIL(@"NetworkStatus");
}


+ (void)networkListen:(NSNotification *)not{

    NSDictionary *userInfo = not.userInfo;
    AFNetworkReachabilityStatus status = [userInfo[@"AFNetworkingReachabilityNotificationStatusItem"] intValue];
    switch (status) {
        case AFNetworkReachabilityStatusUnknown://未识别的网络
        case AFNetworkReachabilityStatusNotReachable://不可达的网络(未连接)
        {
            
            if (isEqualToString([MASessionTimeOut getNetStatus], NetworkOfflineStatus)) return;
            
            if (sessionTimeOut && sessionTimeOut.offlineBlock) {
                sessionTimeOut.offlineBlock();
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络提示" message:@"网络已断开，请连接网络！" delegate:sessionTimeOut cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                [alertView show];
            }
            
            [MASessionTimeOut setNetStatus:NetworkOfflineStatus];
            
            break;
        }
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            
            [MASessionTimeOut setNetStatus:NetworkOnlineStatus];
            
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusUnknown ||
        status == AFNetworkReachabilityStatusNotReachable) {
        [MASessionTimeOut setNetStatus:NetworkDefaultStatus];
    }
}
BOOL isEqualToString(NSString *str,NSString *flag){
    if ([str isEqualToString:flag]) {
        return YES;
    }
    return NO;
}
@end
