//
//  AppDelegate.m
//  RyWebChat
//
//  Created by nwk on 2017/2/9.
//  Copyright © 2017年 nwkcom.sh.n22. All rights reserved.
//

#import "AppDelegate.h"
#import "MAEliteChat.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>

//#define MARyAppKey @"pgyu6atqpg77u" //服务器
#define MARyAppKey @"pgyu6atqpg77u" //dev
//#define MARyAppKey @"e5t4ouvpe60oa"

@interface AppDelegate ()<BMKGeneralDelegate>
{
    BMKMapManager* _mapManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[MAEliteChat shareEliteChat] startRyWithAppKey:MARyAppKey];
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"Z6yG7WrkRXFfiqGosOBTIOk4MoDE9Gcl"  generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
//    [[RCIM sharedRCIM] initWithAppKey:MARyAppKey];
//    
//    [[RCIM sharedRCIM] registerMessageType:[EliteMessage class]];
//    //开启用户信息和群组信息的持久化
//    [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
//    
//    [RCIM sharedRCIM].enableMessageAttachUserInfo = YES;
//    
//    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    
    //设置Log级别，开发阶段打印详细log
//    [RCIMClient sharedRCIMClient].logLevel = RC_Log_Level_Info;
    
    /* 点击通知栏的远程推送时，如果此时 App 已经被系统冻结，则您在 AppDelegate 的 -application:didFinishLaunchingWithOptions: 中可以捕获该消息。
     * 远程推送的内容
     */
//    NSDictionary *remoteNotificationUserInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    [self registerPush:application];
    
    return YES;
}

- (void)onGetPermissionState:(int)iError {
    NSLog(@"%d",iError);
}
/**
 * 推送处理1
 * 注册推送
 */
- (void)registerPush:(UIApplication *)application {
    
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //注册推送, 用于iOS8以及iOS8之后的系统
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        //注册推送，用于iOS8之前的系统
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeAlert |
        UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
}

/**
 * 推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    NSLog(@"token: %@", token);
    [[MAEliteChat shareEliteChat] setDeviceToken:token];
}


/**
 *  如果 App 未被系统冻结，则您在 AppDelegate 的 -application:didReceiveRemoteNotification: 中可以捕获该消息。
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // userInfo为远程推送的内容
    NSLog(@"%@", userInfo);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
